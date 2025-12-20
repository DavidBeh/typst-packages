#let default_on_error(source) = {
  panic("Error during safe_eval with: \n" + source)
}

#let safe_eval(source, mode: "code", scope: (:), on_error: default_on_error) = {
  let prefix = "safe_eval 084a396a-ff41-4cf6-aa2f-b81ab8ea7198"
  let key = prefix + source

  let guard = state(key)
  context {
    if guard.final() == true {
      return on_error(source)
    }
  }
  guard.update(true)
  eval(source, mode: mode, scope: scope)
  guard.update(false)
}

#safe_eval("[1 + 1]")



// author: laurmaedje
// Renders an image or a placeholder if it doesn't exist.
// Don’t try this at home, kids!
#let maybe-image(path, ..args) = context {
  let path-label = label(path)
  let first-time = query((context {}).func()).len() == 0
  if first-time or query(path-label).len() > 0 {
    [#eval(path, ..args)#path-label]
  } else {
    rect(width: 50%, height: 5em, fill: luma(235), stroke: 1pt)[
      #set align(center + horizon)
      Could not find #raw(path)
    ]
  }
}

#maybe-image("[1+1]")
#maybe-image("../tiger1.jpg")
