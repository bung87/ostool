require! {
  path
  "../task":{ Task }
  "../std/io":{ exists, readFile,writeFile }
  "../context": { Context }
  "../template":{ compile }
  glob
  inquirer
  "./badges": { vsExtBadges,nodeBadges,pybadges }
}

export class ReadMeTask extends Task
  -> return super ...

  badges: -> 
    readmePath = @proj \README.md
    primary = @primaryLang
    if exists readmePath
      if @isJsEcosystem
        pkg = require @proj \package.json
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
          _badges.filter( (x) -> x ).join " "
        else if @isJsEcosystem
          _badges = nodeBadges primary,pkgName,username,repo
          _badges.filter( (x) -> x ).join " "
      else if @isPyEcosystem
        # travis username 
        # pkgName 
        # setup(
        #   name='bixin',
        _badges = pybadges pkgName,username,repo
        _badges.filter( (x) -> x ).join " "

  gen: ->
    if @isJsEcosystem
      pkg = require @proj \package.json
      readmePath = @proj \README.md
      tpl =  @tpl \README.md
      # .badges might called by other context
      content = @render tpl,projectName: pkg.name, badges: ReadMeTask::badges ... 
      @mergeWith readmePath,content
    else if @isPyEcosystem
      ...