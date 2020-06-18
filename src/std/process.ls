require! {
  'child_process':{ spawnSync,spawn }
}

export runOut = (cmd,...args) ->
  spawn(cmd, args, stdio: <[\ignore \inherit \inherit]> )

export runIn = (cmd,...args) ->
  child = spawnSync(cmd, args, stdio: \pipe )
  child.stdout?.toString!.trim!