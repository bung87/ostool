require! {
  process
  fs
  path
  os
  tmp
  "./context": { Context }
  "./task": { Task }
  "./std/io":{mkdir,writeFile,readFile}
  'assert': { strict:assert }
  "./health":{ HealthTask }
  rimraf
}

class Mock 

  (@TargetTask) ~>
    @mkProject!
    @task = (new @TargetTask(@tmpDir.name))

  mkProject: ->
    @tmpDir = tmp.dirSync!
    
    @src = path.join @tmpDir.name,"src"
    mkdir @src

  prepare: ->
    @ctx = new Context(@tmpDir.name)
    @task <<< @ctx
    @task.__isTest = true
    process.on 'exit' !~>>
      await that.apply @task if @beforeExit
      rimraf.sync(@tmpDir.name)
  run: ->>
    assert @task.cwd.length > 0,"task has no cwd"
    # assert path.normalize(@task.cwd) !=  path.normalize(process.cwd!),"task cwd is this project"
    that.apply @task if @setup
    @prepare!
    await @task.process!
    
    # @tmpDir.removeCallback!
export Mock
