require! {
  fs
  path
  process
  glob
  "gitignore-globs": parse
  "./std/io":{ exists }
}


export class Context
  (@cwd = process.cwd!) ->
    @primaryLang  = (sourceFilesOrdered @cwd)[0][0]
    @readmePath = path.join @cwd,\README.md
    @isJsEcosystem = @isJsEcosystem!
    @isVscodeExt = @isVscodeExt!
  
  isJsEcosystem: ->
    exists path.join @cwd, \package.json
  
  isVscodeExt: ->
    pkg = require path.join @cwd, \package.json
    \engines of pkg and \vscode of pkg.engines

ignores = (cwd) ->
  result = ["*.json","*.md","*.lock"]
  dotgitignores = path.join cwd, ".gitignore"
  dotnpmignores = path.join cwd, ".npmignore"
  gitignores = parse dotgitignores if exists? dotgitignores
  npmignores = parse dotnpmignores if exists? dotnpmignores
  result = result ++ that if gitignores
  result = result ++ that if npmignores
  return result

files = (cwd) ->
  glob.sync "**", ignore:ignores cwd, cwd: cwd, nodir: true

countMap = (arr)  ->
  arr.reduce( (countMap, word) -> 
    ext = path.extname(word)
    countMap[ext] = ++countMap[ext] || 1
    return countMap
  , {})

sourceFilesOrdered = (cwd) ->
  Object.entries (countMap files cwd) .sort (a,b) -> b[1] - a[1]