require! {
  process
  fs
  path
  os
  tmp
  "./context": { Context }
  "./task": { Task }
  "./std/io":{mkdir,writeFile}
  'assert': { strict:assert }
  "./health":{ HealthTask }
  rimraf
}
class Mock 
  (@TargetTask) ~>
    @mkProject!
    @task = (new @TargetTask)
    # give cwd first
    @task.cwd = @tmpDir.name

  mkProject: ->
    @tmpDir = tmp.dirSync!
    @src = path.join @tmpDir.name,"src"
    mkdir @src

  prepare: ->
    @ctx = new Context(@tmpDir.name)
    @task <<< @ctx
  
  process: ->>
    that.apply @task if @setup
    @prepare!
    @task.process!
    rimraf.sync(@tmpDir.name)
    # @tmpDir.removeCallback!

mock = Mock(HealthTask) with 
  setup:->
    @writeTo "index.ts",""
    @writeJSON "package.json",{}

mock.process!
