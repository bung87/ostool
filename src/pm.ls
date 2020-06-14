require! {
  fs
  path
  process
  "./std/io":{ exists }
}

const cwd = process .cwd!
useYarn = ->
  exists path.join cwd, \yarn.lock

useNpm = ->
  exists path.join cwd, \package-lock.json

usePnpm = ->
  exists path.join cwd, \pnpm-lock.yaml

export whichPm = ->
  ## find which package manager be used (result cached)
  if not whichPm.result
    switch
    case useYarn!
      whichPm.result = \yarn
    case useNpm!
      whichPm.result = \npm
    case usePnpm!
      whichPm.result = \pnpm
  else
    whichPm.result