require! {
  fs
  path
  process
  glob
  "gitignore-globs": parse
}


export class Context
  (@cwd = process.cwd!) ->
    @primaryLang  = (sourceFilesOrdered @cwd)[0][0]
    @readmePath = path.join @cwd,\README.md
    @isJsEcosystem = @isJsEcosystem!
    @isVscodeExt = @isVscodeExt!
  
  isJsEcosystem: ->
    fs.existsSync path.join @cwd,\package.json
  
  isVscodeExt: ->
    pkg = require path.join @cwd,\package.json
    \engines of pkg and \vscode of pkg.engines

function ignores (cwd)
  result = ["*.json","*.md","*.lock"]
  dotgitignores = path.join cwd,".gitignore"
  dotnpmignores = path.join cwd,".npmignore"
  gitignores = parse dotgitignores if fs.existsSync dotgitignores
  npmignores = parse dotnpmignores if fs.existsSync dotnpmignores
  result = result ++ gitignores if gitignores
  result = result ++ npmignores if npmignores
  return result

function files (cwd)
  glob.sync "**", ignore:ignores cwd, cwd:cwd, nodir:true

function countMap  (arr)
  arr.reduce( (countMap, word) -> 
    ext = path.extname(word)
    countMap[ext] = ++countMap[ext] || 1
    return countMap
  , {})

function sourceFilesOrdered (cwd)
  Object.entries (countMap files cwd) .sort (a,b) -> b[1] - a[1]