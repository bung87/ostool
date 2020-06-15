require! {
  path
  "../task":{ Task }
  "../std/io":{ exists, readFile,writeFile }
  "../context": { Context }
  "../template":{ compile }
  glob
  inquirer
  "./badges": { vsExtBadges,nodeBadges }
}

export class ReadMeTask extends Task
  -> return super ...

  badges: -> 
    readmePath = path.join @cwd,\README.md
    primary = @primaryLang
    if exists readmePath
      pkg = require path.join @cwd,\package.json
      username = pkg.author
      repo = if typeof pkg.repository == "object"
      then 
        path.basename(pkg.repository.url)    
      else if typeof pkg.repository == "string"
        path.basename(pkg.repository)
      else
        pkg.name
      pkgName = pkg.name
      
      if @isVscodeExt
        publisher = pkg.publisher
        extname = pkg.name
        _badges = vsExtBadges publisher,extname
      else if @isJsEcosystem
        _badges = nodeBadges primary,pkgName,username,repo

      _badges.filter( (x) -> x ).join " "

  gen: ->
    pkg = require path.join @cwd,\package.json
    readmePath = path.join @cwd,\README.md
    tpl = readFile path.join __dirname,"..","templates",\README.md
    render = compile(tpl)
    # .badges might called by other context
    content = render projectName: pkg.name, badges: ReadMeTask::badges ... 
    @mergeWith readmePath,content