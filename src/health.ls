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
  process
  'assert': { strict:assert }
  "./std/log":{log,info}
}


const licenseList = Array.from(require("@ovyerus/licenses/simple")).sort!

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
    files = glob.sync "README.*",cwd:@cwd 
    if files.length > 0
      @readme = files[0]
      @readmeFormat = path.extname files[0]
    else
      @readme = @proj \README.md
    files.length == 1

  checkHasLicense: -> 
    # could be LICENSE or license
    LICENSE = exists @proj \LICENSE
    license = exists @proj \license
    @license = @proj \license if license
    @license ?= @proj \LICENSE
    license or LICENSE

  checkHasCI: -> exists @proj \.travis.yml

  checkHasPublishConfig: ->
    if !isCI and @isJsEcosystem and @useMirror
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
      if not hasWatch
        questions .push type:\confirm,name:\addWatch,message:"add watch to scripts"
      if not hasBuild 
        questions .push type:\confirm,name:\addBuild,message:"add build to scripts"
      if not hasTest
        questions .push type:\confirm,name:\addTest,message:"add test to scripts"
      HealthTask::checkScripts.prompt = ~>>
        pkg = require (@proj "package.json")
        pkg.scripts ?= {}
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
            pkg.scripts.build = "tsc -p ."
        if anwsers.addTest
          switch @primaryLang
          case ".ls"
            pkg.scripts.test = "lsc tests"
        
        @writeJSON (@proj \package.json),pkg
        anwsers
      return hasBuild and hasWatch and hasTest #and hasLint and hasFormat

  checkReadmeHasInstallation: ->
    hasReadme = no
    if @hasReadme
      readme = readFile @proj \README.md
      if /#+ Installation/i is readme
        hasReadme = yes
    hasReadme

  checkHasSetup: ->
    if @isPyEcosystem 
      hasSetup = exists @proj \setup.py
  
  checkHas-pre-commit-hook: ->
    if exists @proj \.git and !isCI
      exists @proj \.git,\hooks,\pre-commit

  checkHas-vscode-extension-bundle: ->
    if @isVscodeExt and @primaryLang == ".ts"
      exists @proj \rollup.config.ts
    # yeah, someone may write in other languages that compiles to js
  checkHas-ts-lint-format: ->
    if @primaryLang == ".ts"
      pkg = require (@proj "package.json")
      hasLint = no
      hasFormat = no
      for key,val of pkg.scripts
        if /lint/i is key and val.length > 0
          hasLint = yes
        else if /format|prettier|pretty/i is key and val.length > 0
          hasFormat = yes
      hasLint and hasFormat

HealthTask::checkHas-ts-lint-format.prompt = ->>
  questions = [
    * type: \confirm
      name: "addLintFormat"
      message: "add lint format tools,would you like to?"
    ]
  answers = await prompt questions
  if answers.addLintFormat
    return await TsTask::tsLintTask ...
  else
    Promise.resolve!
  
HealthTask::checkHas-vscode-extension-bundle.prompt = ->>
  questions = [
    * type: \confirm
      name: "addRollup"
      message: "rollup.config.ts not exists,would you like to create one for bundle?"
    ]
  answers = await prompt questions
  if answers.addRollup
    deps =
      'rollup'
      'rollup-plugin-typescript2'
      '@rollup/plugin-commonjs'
      '@rollup/plugin-node-resolve'
      '@rollup/plugin-json'
    @installTask ...deps
    src = @proj \rollup.config.ts
    @renderTo src,\rollup.config.ts,src:@priSourcesRoot
    log info "now you can bundle through `rollup -c rollup.config.ts`"
    return Promise.resolve!
  else
    return Promise.resolve!

HealthTask::checkHasLicense.prompt = ->>
  questions = [
    * type: \confirm
      name: "addLicense"
      message: "License file not exists,would you like to create one?"
    ]
  answers = await prompt questions
  if answers.addLicense
    answers2 = await prompt [
      * type: "search-list",
        message: "Select License",
        name: "license",
        choices: licenseList,
        default:"MIT"
      * type: "input",
        message: "Your name in License",
        name: "authorInLicense"
    ]
    content = getLicense answers2.license, author: answers2.authorInLicense, year: String(new Date().getFullYear!)
    content = maxLine content
    @writeTo  @license,content
    return answers2
  else
    return Promise.resolve!

HealthTask::checkReadmeHasInstallation.prompt = ->>
  return prompt [
    type: \confirm
    name: "hasInstallation"
    message: "Readme has no Installation section, would you like to?"
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
    message: "setup.py not exists would you like to create one?"
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
        setupPath = @proj \setup.py
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
  anwsers = await prompt [
    type: \confirm
    name: "addHook"
    message: "pre commit hook not exists would you like to create one?"
  ]
  if anwsers.addHook
    if @isJsEcosystem
      @installTask \husky
      pkg = require (@proj \package.json)
      if \husky of pkg == false
        pkg.husky = hooks:{"pre-commit": "npm test"}
        @writeJSON (@proj \package.json),pkg
        return Promise.resolve!
  else
    return Promise.resolve!

HealthTask::checkHasPublishConfig.prompt = ->>

  anwsers = await prompt [
    type: \confirm
    name: "addPublishConfig"
    message: "publishConfig not exists in package.json would you like to create one?"
  ]
  if anwsers.addPublishConfig
    if @isJsEcosystem
      pkg = require @proj \package.json
      if \publishConfig of pkg == false
        pkg.publishConfig = 
          access: "public",
          registry: "https://registry.npmjs.com"
        @writeJSON (@proj \package.json),pkg
        return Promise.resolve!
  else
    return Promise.resolve!

export HealthTask 