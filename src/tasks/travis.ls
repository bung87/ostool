require! {
  path
  "../task":{ Task }
  "../std/io":{ exists, readFile }
  "../context": { Context }
  "../qa": { prompt }
  glob
  "prelude-ls":{union}
  "../std/log":{log,info}
  'lodash.merge':merge
  process
}

class TravisTask extends Task
  -> return super ...
  travisTask:(ctx) !->>
    if @isJsEcosystem
      @renderTo \.travis.yml,path.join("js",\.travis.yml),ctx
    else if @isPyEcosystem
      @renderTo \.travis.yml,path.join("py",\.travis.yml),ctx
      @copyFile path.join("templates","py",\nose.cfg),\nose.cfg
      @copyFile path.join("templates","py",\tox.ini),\tox.ini
      log info "now you can use `pip install \".[test]\"`"
export TravisTask