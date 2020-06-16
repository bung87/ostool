require! {
  path
  "./task":{ Task }
  "./std/io":{ exists, readFile }
  "./context": { Context }
  "./readme": { ReadMeTask }
  "./license":{getLicense, maxLine}
  glob
  inquirer
}

inquirer.registerPrompt("search-list", require("inquirer-search-list"))
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
  checkScripts: ->
    if @isJsEcosystem
      pkg = require @proj "package.json"
      hasBuild = no
      hasWatch = no
      hasTest = no
      for key,val of pkg.scripts
        if key == "watch" and val.length > 0
          hasWatch = yes
        else if key == "build" and val.length > 0
          hasBuild = yes
        else if key == "test" and val.length > 0
          hasTest = yes
      return hasBuild and hasWatch and hasTest
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
    exists @proj \.git,\pre-commit

HealthTask::checkHasLicense.prompt ?= ->>
  inquirer
  .prompt([
    type: \confirm
    name: "addLicense"
    message: "would you like to create one?"
  ])
  .then (answers) ~>>
    if answers.addLicense
      inquirer
      .prompt([
        * type: "search-list",
          message: "Select License",
          name: "License",
          choices: licenseList,
        * type: "input",
          message: "Your name in License",
          name: "name"
      ])
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

HealthTask::checkReadmeHasInstallation.prompt ?= ->>
  inquirer
  .prompt([
    type: \confirm
    name: "hasInstallation"
    message: "Readme has no Installatio section, would you like to?"
  ])
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

HealthTask::checkHasSetup.prompt ?= ->>
  inquirer
  .prompt([
    type: \confirm
    name: "addSetup"
    message: "setup.py not exists would you like to?"
  ])
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
      inquirer.prompt questions
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

HealthTask::checkHas-pre-commit-hook.prompt ?= ->>
  anwsers = await inquirer
  .prompt([
    type: \confirm
    name: "addHook"
    message: "pre commit hook not exists would you like to?"
  ])
  if anwsers.addHook
    if @isJsEcosystem
      @installTask \husky
      pkg = require @proj \package.json
      if \husky of pkg == false
        pkg.husky = {"pre-commit": "npm test"}
        @writeJSON (@proj \package.json),pkg

export HealthTask 