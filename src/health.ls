require! {
  path
  "./task":{ Task }
  "./std/io":{ exists }
  "../src/context": { Context }
  glob
}

export class HealthTask extends Task
  -> return super ...
  checkHasReadme: -> 
    # exists path.join @cwd,\README.md or exists path.join @cwd,\README.md
    len = glob.sync "README.*",cwd:@cwd .length
    len == 1
  checkHasLicense: -> exists path.join @cwd,\LICENSE
  checkHasCI: -> exists path.join @cwd,\.travis.yml