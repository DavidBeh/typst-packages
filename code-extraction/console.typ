// Use this file to experiment while developing
#import "@preview/tidy:0.4.3": help, show-module
#import "lib.typ": *
#import "@preview/zebraw:0.6.1": zebraw

#set page(width: 12cm, height: auto, margin: 0.6cm)



#let to_dict(input) = {

  if type(input) == content {
    input = ("c": input.fields())
  }

  if type(input) == dictionary {
    let dict = (:)
    for (key, value) in input {
      dict.insert(key, to_dict(value))
    }

    input = dict;
  }

  if type(input) == array {
    input = input.map(to_dict)
  }

  return input;

}





#show raw.line: it => {
  let dict = to_dict(it)

  //text(repr(dict))
  //repr(json.encode(dict))

  //#type(extracted)
  it
}


The following misses a space and the convential newline after program termination.

#includefile("test.cs", tag: "bug")

This is fixed in the following:

#includefile("test.cs", tag: "fix")


#zebraw(
  ```
  Line 1
  Line 2
  Line 3
  ```
)


#zebraw(
  // The first line number will be 2.
  line-range: (2, 4),
  ```typ
  /*
  #grid(
    columns: (1fr, 1fr),
    [Hello], [world!],
  )
  */
  ```
)