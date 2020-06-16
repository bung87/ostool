require! {
  process
  fs
  path
  "../src/context": { Context }
  "../src/task": { Task }
  'assert': { strict:assert }
}

ctx = new Context process.cwd!
task = new Task <<< ctx
task.renderTo ".travis.yml",".travis.yml", coverage: false
yml = path.join process.cwd!, \.travis.yml
assert.equal << fs.existsSync yml, true