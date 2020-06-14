require! {
  process
  fs
  path
  "node-text-chunk":chunk
}
const assert = require('assert').strict
{Task} = require "../src/task"
{Context} = require "../src/context"
{getLicense,maxLine} = require "../src/license"

ctx = new Context process.cwd!
task = (new Task) with ctx
pkg = require path.join process.cwd!,\package.json
content = getLicense pkg.license, author:pkg.author,year:new Date().getFullYear!
content = maxLine content
task.writeTo  \LICENSE,content
license = path.join process.cwd!,\LICENSE
assert.equal << fs.existsSync license ,true