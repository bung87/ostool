require! {
  path
  "../task":{ Task }
  "../std/io":{ exists, readFile,writeFile }
  "../context": { Context }
  "../template":{ compile }
  glob
  "../qa": { prompt }
  "./badges": { vsExtBadges,nodeBadges,pybadges }
}

export class ReadMeTask extends Task
  -> return super ...

  badges: ->> 
    primary = @primaryLang
    if @isJsEcosystem
      pkg = require @proj \package.json
      username = pkg.author
      repo = if typeof pkg.repository == "object"
      then 
        path.parse(pkg.repository.url).name
      else if typeof pkg.repository == "string"
        path.parse(pkg.repository).name
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
      @answers ?= await prompt [
        * type:\input
          name:"pkgName"
          message:"package name"
        * type:\input
          name: "travisUsername"
          message:"travis username"
        * repo:\input
          name:"repoUri"
          message:"repository uri"
      ]
      _badges = pybadges @answers.pkgName,@answers.travisUsername,@answers.repoUri
      _badges.filter( (x) -> x ).join " "

  gen: ->>
    if @isJsEcosystem
      pkg = require @proj \package.json
      tpl =  @tpl (path.join \js,\README.md)
      # .badges might called by other context
      content = @render tpl,projectName: pkg.name, badges: await ReadMeTask::badges ... 
      @mergeWith @readme,content
    else if @isPyEcosystem
      tpl =  @tpl (path.join \py,\README.md)
      @answers ?= await prompt [
          * type:\input
            name:"pkgName"
            message:"package name"
          * type:\input
            name: "travisUsername"
            message:"travis username"
          * repo:\input
            name:"repoUri"
            message:"repository uri"
      ]
      content = @render tpl,projectName: @answers.pkgName, badges: await ReadMeTask::badges ... 
      @mergeWith @readme,content