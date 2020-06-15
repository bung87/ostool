require! {
  path
  "./task":{ Task }
  "./std/io":{ exists, readFile }
  "./context": { Context }
  "./readme": { ReadMeTask }
  glob
  inquirer
}

export class HealthTask extends Task
  -> return super ...
  checkMetaInfo: ->
    conds = []
    if @isJsEcosystem
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
  checkHasLicense: -> exists path.join @cwd,\LICENSE
  checkHasCI: -> exists path.join @cwd,\.travis.yml
  checkScripts: ->
    if @isJsEcosystem
        pkg = require path.join(@cwd,"package.json")
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
    ::checkReadmeHasInstallation.prompt ?= ~>
        inquirer
        .prompt([
            type: \confirm
            name: "hasInstallation"
            message: "Readme has no Installatio section, would you like to?"
        ])
        .then (answers) ~>
            # Use user feedback for... whatever!!
            console.log answers
            if answers.hasInstallation
              ReadMeTask::gen ...
        .catch (error) ~> 
            if (error.isTtyError) 
            # Prompt couldn't be rendered in the current environment
                ...
            else 
            # Something else when wrong
                console.error error

    hasReadme = no
    if @hasReadme
      readme = readFile path.join @cwd,\README.md
      if /#+ Installation/i is readme
        hasReadme = yes