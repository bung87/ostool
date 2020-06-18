#!/usr/bin/env node
require!{
  process
  yargs
  "./context": { Context }
  "./health": { HealthTask }
  "./task": { Task }
  "fix-indents":fix-indents
  glob
  util
  fs
  "ls-lint"
}
aglob = util.promisify glob
awriteFile = util.promisify fs.writeFile
areadFile = util.promisify fs.readFile
yargs.scriptName "ostool"
  ..usage('$0 <cmd> [args]')
  ..command "health","health check",
    (yargs)->
    (argv)->
      ctx = new Context process.cwd!
      task = new HealthTask <<< ctx
      task.process!
  ..command "clean","clean files",
    (yargs) ->
    (argv) ->
      ctx = new Context process.cwd!
      task = new Task <<< ctx
      task.cleanTask!
  ..command "fix-indents","fix indents",
    (yargs) ->
    (argv) !->>
      ctx = new Context process.cwd!
      files = await aglob ("**/*" + ctx.primaryLang), cwd: ctx.cwd, nodir: true
      for f in files
        origin = await areadFile f
        content = ls-lint.lint origin.toString!
        # await awriteFile f,content
        console.log content
  ..help!
  ..argv