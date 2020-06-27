require! {
  path
  "../task":{ Task }
  "../std/io":{ exists, readFile }
  "../context": { Context }
  "../qa": { prompt }
  "prelude-ls":{union}
  "../std/log":{log,info}
  'lodash.merge':merge
  process
}

class LsTask extends Task
  -> return super ...
  lsLintTask: ->>

    anwsers = await prompt [
      * type: "confirm",
        message: "use ls-lint",
        name: "lsLint"
    ]

    if anwsers.lsLint
      deps = [\ls-lint]
      @installTask ...deps
    p = path.join("ls",\ls-lint.lson)
    @mergeWith (@proj \ls-lint.lson),@render @tpl p
    log info "now you can use `ls-lint \\\"{,!(node_modules)/**/}*.ls?(on)\\\"`"

export LsTask