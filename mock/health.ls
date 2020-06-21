require!{
  process
  "../src/mock":{Mock}
  "../src/health":{HealthTask}
  'assert': { strict:assert }
  "../src/std/io": {exists,readFile}
  "../src/std/log": {log,info,success}
}
mock = Mock(HealthTask) with 
  setup:->
    @writeTo "index.ts",""
    @writeJSON "package.json",{}
    assert exists(@proj "index.ts")

  nameWrote :false
  licenseSelected : false
  answer:(subprocess,data) !~>
  ## called in subprocess, no this context
  ## cant log here
    out = data.toString!
    if out.trim!.endsWith("(Y/n)")
      subprocess.stdin.write "Y\n"
    else if !@licenseSelected and out.includes "Select License"
      subprocess.stdin.write "MIT\n"
      @licenseSelected = true
    else if out.includes("Select") and not out.includes "Select License"
      subprocess.stdin.write "\n"
    else if !@nameWrote and out.trim!.includes "Your name in License"
      subprocess.stdin.write "bung\n"
      @nameWrote = true
    
  beforeExit:(log) !->
  ## called in subprocess, this context is mock.task
    pkg = require @proj "package.json"
    assert "scripts" of pkg,"pkg has no scripts"
    assert pkg.scripts.watch == "tsc -p . --watch","pkg.scripts has no watch"
    assert exists @proj \README.md
    assert exists @proj \LICENSE
    license = readFile @proj \LICENSE
    assert license.includes "MIT"
    assert license.includes "bung"

module.exports = mock
