
require! {
  path
  "../src/context": { Context }
  "../src/task": { Task }
  "../src/health": { HealthTask }
  'assert': { strict:assert }
}

ctx = new Context process.cwd!
task = new HealthTask <<< ctx
# task.printMethods!

assert.equal task.checkHasReadme!, true
assert.equal task.checkHasLicense!, true
assert.equal task.checkHasCI!, true
assert.equal task.checkScripts!, true