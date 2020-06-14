const assert = require('assert').strict

{whichPm} = require "../src/pm"

assert.equal whichPm!,"yarn"
