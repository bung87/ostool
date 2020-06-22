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
origin = task.render \.travis.yml,path.join("js",\.travis.yml), coverage: false
task.mergeWith \.travis.yml,origin
yml = path.join process.cwd!, \.travis.yml
assert.equal << fs.existsSync yml, true