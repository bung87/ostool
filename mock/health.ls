require!{
  process
  "../src/mock":{Mock}
  "../src/health":{HealthTask}
  'assert': { strict:assert }
  "../src/std/io": {exists,readFile}
}
mock = Mock(HealthTask) with 
  setup:->
    @writeTo "index.ts",""
    @writeJSON "package.json",{}
    assert exists(@proj "index.ts")

  answer:(subprocess,data) ->
  ## called in subprocess, no this context
    out = data.toString!
    console.log out
    if out.trim!.endsWith("(Y/n)")
      subprocess.stdin.write "Y\n"
    else if out.includes("Select")
      subprocess.stdin.write "\n"
    else if out.includes "Your name"
      subprocess.stdin.write "bung\n"

  beforeExit:(log) !->
  ## called in subprocess, this context is mock.task
    pkg = require @proj "package.json"
    assert "scripts" of pkg,"pkg has no scripts"
    assert pkg.scripts.watch == "tsc -p . --watch","pkg.scripts has no watch"
    assert exists @proj \README.md
    assert exists @proj \LICENSE
    log readFile @proj "package.json"
    log readFile @proj \README.md
    log readFile @proj \LICENSE

module.exports = mock
