require! {
  fs
}
export writeFile = ->
  fs.writeFileSync ...

export readFile = ->
  fs.readFileSync ... .toString!

export exists = ->
  fs.existsSync ...

export mkdir = ->
  fs.mkdirSync ...