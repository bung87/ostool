require! {
  fs
  path
  "../src/std/io":{ readFile }
}
const assert = require 'assert' .strict
{compile} = require "../src/template"

tmp = readFile path.join __dirname, "..", "src", "templates","js", ".travis.yml"
render = compile tmp

assert.equal (render( coverage:false ).includes \coverage),false
