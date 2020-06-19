require! {
  'child_process':{ spawnSync,spawn }
}

export runOut = (cmd,cwd,...args) ->
  spawn(cmd, args, {cwd:cwd,stdio: <[\ignore \inherit \inherit]> })

export runIn = (cmd,cwd,...args) ->
  child = spawnSync(cmd, args, {stdio: \pipe,cwd:cwd} )
  child.stdout?.toString!.trim!