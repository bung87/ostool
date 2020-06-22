require! {
  livescript: lsc
  path
  "../std/io":{readFile}
}
f = path.join __dirname,"ts.ls"
ast = lsc.ast readFile f

ast.eachChild (node, name, i) ->
  console.log node, name, i
# console.log ast,ast.toString!

