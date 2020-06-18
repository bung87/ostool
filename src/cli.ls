#!/usr/bin/env node
require!{
  process
  yargs
  "./context": { Context }
  "./health": { HealthTask }
  "./task": { Task }
  glob
  util
  fs
}

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
  ..help!
  ..argv