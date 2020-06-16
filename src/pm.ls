require! {
  fs
  path
  process
  "./std/io":{ exists }
}

useYarn = (cwd) ->
  exists path.join cwd, \yarn.lock

useNpm = (cwd) ->
  exists path.join cwd, \package-lock.json

usePnpm = (cwd) ->
  exists path.join cwd, \pnpm-lock.yaml

export whichPm = (cwd) ->
  ## find which package manager be used (result cached)
  if not whichPm.result
    switch
    case useYarn cwd
      whichPm.result = \yarn
    case useNpm cwd
      whichPm.result = \npm
    case usePnpm cwd
      whichPm.result = \pnpm
  else
    whichPm.result