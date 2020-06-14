require! {
  fs
  path
  process
}

const cwd = process .cwd!

function useYarn
    fs.existsSync path.join cwd,\yarn.lock

function useNpm 
    fs.existsSync path.join cwd,\package-lock.json
    
function usePnpm
    fs.existsSync path.join cwd,\pnpm-lock.yaml

export function whichPm
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