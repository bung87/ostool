require! {
  fs
  path
}
const assert = require('assert').strict
{compile} = require "../src/template"

tmp = fs.readFileSync(path.join __dirname,"..","src","templates",".travis.yml").toString!
render = compile tmp

assert.equal (render( coverage:false ).includes \coverage),false
