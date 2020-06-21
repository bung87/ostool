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
    @writeTo "index.py",""
    assert exists(@proj "index.py")

  nameWrote :false
  licenseSelected : false
  afterPrepare: ->
    assert @primaryLang == ".py"
  answer:(stdin,data) !~>
  ## called in subprocess, no this context
  ## cant log here
    out = data
    if out.trim!.endsWith("(Y/n)")
      stdin.write "Y\n"
    else if out.trim!.endsWith("package name")
      stdin.write "pypackage\n"
    else if out.trim!.endsWith("travis username")
      stdin.write "bung\n"
    else if out.trim!.endsWith("author")
      stdin.write "bung\n"
    else if out.trim!.endsWith("repository uri")
      stdin.write "https://github.com/bung87/ostool.git\n"
    else if out.trim!.endsWith("email")
      stdin.write "crc32@qq.com\n"
    else if out.trim!.endsWith("disc")
      stdin.write "sdsdfsd\n"
    else if out.trim!.endsWith("url")
      stdin.write "https://github.com/bung87/ostool.git\n"
    else if !@licenseSelected and out.includes "Select License"
      stdin.write "MIT\n"
      @licenseSelected = true
    else if out.includes("Select") and not out.includes "Select License"
      stdin.write "\n"
    else if !@nameWrote and out.trim!.includes "Your name in License"
      stdin.write "bung\n"
      @nameWrote = true
    
  beforeExit: !->>
  ## called in subprocess, this context is mock.task
    assert exists @proj \setup.py
    assert exists @proj \nose.cfg
    assert exists @proj \tox.ini
    assert exists @proj \README.md
    assert exists @proj \LICENSE
    license = readFile @proj \LICENSE
    readme = readFile @proj \README.md
    assert license.includes "MIT"
    assert license.includes "bung"
    assert exists @proj \.travis.yml

module.exports = mock
