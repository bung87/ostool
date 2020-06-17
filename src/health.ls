require! {
  path
  "./task":{ Task }
  "./std/io":{ exists, readFile }
  "./context": { Context }
  "./readme": { ReadMeTask }
  "./license":{getLicense, maxLine}
  "./qa": { prompt }
  'is-ci':isCI
  "./tasks/ts": { TsTask }
  glob
  
}

const licenseList = Array.from require("@ovyerus/licenses/simple")

class HealthTask extends Task
  -> return super ...

  checkMetaInfo: ->
    if @isJsEcosystem
      conds = []
      pkg = require path.join(@cwd,"package.json")
      hasName = "name" of pkg
      hasAuthor = "author" of pkg
      hasLicence = "license" of pkg
      hasRepository = "repository" of pkg
      conds.push hasName,hasAuthor,hasLicence,hasRepository
      if @isVscodeExt
        publisher = "publisher" of pkg
        conds.push publisher
      conds.every (v) -> v == true

  checkHasReadme: -> 
    # exists path.join @cwd,\README.md or exists path.join @cwd,\README.md
    len = glob.sync "README.*",cwd:@cwd .length
    len == 1

  checkHasLicense: -> 
    exists @proj \LICENSE

  checkHasCI: -> exists @proj \.travis.yml

  checkHasPublishConfig: ->
    if @isJsEcosystem and @useMirror
      pkg = require @proj "package.json"
      \publishConfig of pkg

  checkScripts: ->
    if @isJsEcosystem
      pkg = require @proj "package.json"
      hasBuild = no
      hasWatch = no
      hasTest = no
      hasLint = no
      hasFormat = no
      for key,val of pkg.scripts
        if key == "watch" and val.length > 0
          hasWatch = yes
        else if key == "build" and val.length > 0
          hasBuild = yes
        else if key == "test" and val.length > 0
          hasTest = yes
      questions = []
      ::checkScripts.prompt ?= ~>>
        pkg = require @proj "package.json"
        anwsers = await prompt questions
        if anwsers.addWatch
          switch @primaryLang
          case ".ls"
            pkg.scripts.watch = "lsc -wco dist src"
          case ".ts"
            pkg.scripts.watch = "tsc -p . --watch"
        if anwsers.addBuild
          switch @primaryLang
          case ".ls"
            pkg.scripts.build = "lsc -co dist src"
          case ".ts"
            pkg.scripts.watch = "tsc -p ."
        if anwsers.addTest
          switch @primaryLang
          case ".ls"
            pkg.scripts.test = "lsc tests"
        @writeJSON (@proj \package.json),pkg
      return hasBuild and hasWatch and hasTest #and hasLint and hasFormat

  checkReadmeHasInstallation: ->
    hasReadme = no
    if @hasReadme
      readme = readFile @proj \README.md
      if /#+ Installation/i is readme
        hasReadme = yes

  checkHasSetup: ->
    if @isPyEcosystem 
      hasSetup = exists @proj \setup.py
  
  checkHas-pre-commit-hook: ->
    if exists @proj \.git and !isCI
      exists @proj \.git,\hooks,\pre-commit

HealthTask::checkHasLicense.prompt = ->>
  questions =
    * type: \confirm
      name: "addLicense"
      message: "would you like to create one?"
  prompt questions
  .then (answers) ~>>
    if answers.addLicense
      prompt [
        * type: "search-list",
          message: "Select License",
          name: "License",
          choices: licenseList,
        * type: "input",
          message: "Your name in License",
          name: "name"
      ]
      .then (answers) ~>
        content = getLicense answers.License, author: answers.name, year: new Date().getFullYear!
        content = maxLine content
        @writeTo  \LICENSE,content
  .catch (error) ~> 
    if (error.isTtyError) 
      # Prompt couldn't be rendered in the current environment
        ...
    else 
      # Something else when wrong
      console.error error

HealthTask::checkReadmeHasInstallation.prompt = ->>
  prompt [
    type: \confirm
    name: "hasInstallation"
    message: "Readme has no Installatio section, would you like to?"
  ]
  .then (answers) ~>>
    # Use user feedback for... whatever!!
    console.log answers
    if answers.hasInstallation
      await ReadMeTask::gen ...
  .catch (error) ~> 
    if (error.isTtyError) 
      # Prompt couldn't be rendered in the current environment
      ...
    else 
      # Something else when wrong
      console.error error

HealthTask::checkHasSetup.prompt = ->>

  prompt [
    type: \confirm
    name: "addSetup"
    message: "setup.py not exists would you like to?"
  ]
  .then (answers) ~>
    # Use user feedback for... whatever!!
    console.log answers
    questions =
      * type: \input
        name: "pkgName"
        message: "pkgName"
      * type: \input
        name: "disc"
        message: "disc"
      * type: \input
        name: "url"
        message: "url"
      * type: \input
        name: "email"
        message: "email"
      * type: \input
        name: "author"
        message: "author"
    if answers.addSetup
      prompt questions
      .then (answers) ~>
        tpl = @tpl \setup.py
        setupPath = path.join @cwd,\setup.py
        content = @render tpl,answers 
        @mergeWith setupPath,content
  .catch (error) ~> 
    if (error.isTtyError) 
      # Prompt couldn't be rendered in the current environment
      ...
    else 
      # Something else when wrong
      console.error error

HealthTask::checkHas-pre-commit-hook.prompt = ->>
  anwsers = await  prompt [
    type: \confirm
    name: "addHook"
    message: "pre commit hook not exists would you like to?"
  ]
  if anwsers.addHook
    if @isJsEcosystem
      @installTask \husky
      pkg = require @proj \package.json
      if \husky of pkg == false
        pkg.husky = hooks:{"pre-commit": "npm test"}
        @writeJSON (@proj \package.json),pkg

HealthTask::checkHasPublishConfig.prompt = ->>
  anwsers = await  prompt [
    type: \confirm
    name: "addPublishConfig"
    message: "publishConfig not exists in package.json would you like to?"
  ]
  if anwsers.addPublishConfig
    if @isJsEcosystem
      pkg = require @proj \package.json
      if \publishConfig of pkg == false
        pkg.publishConfig = 
          access: "public",
          registry: "https://registry.npmjs.com"
        @writeJSON (@proj \package.json),pkg

export HealthTask 