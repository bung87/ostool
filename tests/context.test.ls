require! {
  process
}

const assert = require('assert').strict
{Context} = require "../src/context"
ctx = new Context
assert.equal ctx.cwd,process.cwd!
assert.equal ctx.primaryLang, \.ls
assert.equal typeof ctx.isJsEcosystem, "boolean"
assert.equal ctx.isJsEcosystem, true
assert.equal ctx.isVscodeExt, false
