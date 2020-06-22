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
      travis = @tpl path.join("js",\.travis.yml)
      origin = @render travis,ctx
      @mergeWith \.travis.yml,origin
    else if @isNimEcosystem
      travis = @tpl path.join("nim",\.travis.yml)
      origin = @render travis,ctx
      @mergeWith \.travis.yml,origin

    else if @isPyEcosystem
      travis = @tpl path.join("py",\.travis.yml)
      origin = @render travis,ctx
      @mergeWith \.travis.yml,origin
      nose = path.join("py",\nose.cfg)
      tox = path.join("py",\tox.ini)
      origin = @render @tpl  nose
      @mergeWith \nose.cfg,nose
      origin = @render @tpl tox
      @mergeWith \tox.ini,tox
      log info "now you can use `pip install \".[test]\"`"
export TravisTask