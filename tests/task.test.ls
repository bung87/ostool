require! {
  process
  fs
  path
}
const assert = require('assert').strict
{Task} = require "../src/task"
{Context} = require "../src/context"

ctx = new Context process.cwd!
task = (new Task) with ctx
task.renderTo ".travis.yml","templates/.travis.yml",coverage:false
yml = path.join(process.cwd!,\.travis.yml)
assert.equal << fs.existsSync yml ,true