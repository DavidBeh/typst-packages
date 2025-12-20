#import "documentation.typ": print_docs

#let doc(path) = {
  let content = read(path)
  print_docs(path, content)
}

#doc("code-extraction.typ")

#doc("comments.typ")

#doc("string-utils.typ")