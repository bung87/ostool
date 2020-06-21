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
    subprocess.stdout.pause!

    if out.trim!.endsWith("(Y/n)")
      subprocess.stdin.pause!
      subprocess.stdin.write "Y\n"
      subprocess.stdin.resume!
    else if !@licenseSelected and out.includes "Select License"
      subprocess.stdin.pause!
      subprocess.stdin.write "MIT\n"
      @licenseSelected = true
      subprocess.stdin.resume!
    else if out.includes("Select") and not out.includes "Select License"
      subprocess.stdin.pause!
      subprocess.stdin.write "\n"
      subprocess.stdin.resume!
    else if !@nameWrote and out.trim!.includes "Your name in License"
      subprocess.stdin.pause!
      subprocess.stdin.write "bung\n"
      subprocess.stdin.resume!
      @nameWrote = true
    subprocess.stdout.resume!
    
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
