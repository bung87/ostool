require! {
    process
}
{reject} = require 'prelude-ls'
{whichPm,runOut,tsLintTask,runIn,installTask} = require "../src/index"
rc = require "../src/eslintrc"
const assert = require('assert').strict

assert.equal whichPm!,"yarn"
assert.equal runIn("node","-v"),process.version

rc.extends = rc.extends |> reject (x) -> x in [ 'eslint:recommended', 'plugin:@typescript-eslint/recommended' ]
assert.equal rc.extends.length,0