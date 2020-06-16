#!/usr/bin/env node
require!{
  process
  yargs
  "./context": { Context }
  "./health": { HealthTask }
}
yargs.scriptName "ostool"
  ..usage('$0 <cmd> [args]')
  ..command "health","health check",
    (yargs)->
      
    (argv)->
      ctx = new Context process.cwd!
      task = new HealthTask <<< ctx
      task.process!
  ..help!
  ..argv