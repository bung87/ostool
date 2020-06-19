require! {
  livescript: lsc
  path
  "../std/io":{readFile}
}
f = path.join __dirname,"ts.ls"
ast = lsc.ast readFile f
console.log ast.toString!

