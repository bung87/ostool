require! {
  path
  "./task":{ Task }
  "./std/io":{ exists }
  "../src/context": { Context }
  glob
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
        hasBuild = false
        hasWatch = false
        hasTest = false
        for key,val of pkg.scripts
          if key == "watch" and val.length > 0
            hasWatch = true
          else if key == "build" and val.length > 0
            hasBuild = true
          else if key == "test" and val.length > 0
            hasTest = true
        return hasBuild and hasWatch and hasTest