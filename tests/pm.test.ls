require! {
  process
  "../src/pm": {whichPm} 
  'assert': { strict:assert }
}

assert.equal << whichPm process.cwd!, "yarn"