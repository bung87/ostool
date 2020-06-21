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

class TsTask extends Task
  -> return super ...
  tsLintTask: ->>
    ## see https://github.com/typescript-eslint/typescript-eslint/blob/master/docs/getting-started/linting/README.md

    @installTask \@typescript-eslint/parser,\@typescript-eslint/eslint-plugin
    eslintignore = """
    don't ever lint node_modules
    node_modules
    # don't lint build output (make sure it's set to your correct build folder name)
    dist
    # don't lint nyc coverage output
    coverage
    """
    @mergeWith (@proj \.eslintignore),eslintignore
    rc = require path.join __dirname,"..","eslintrc"
    anwsers = await prompt [
      * type: "list",
        message: "Select Lint rules",
        name: "lint",
        choices: ["builtin","standard","airbnb with react","airbnb base"],
        default: "builtin"
      * type: "confirm",
        message: "use prettier",
        name: "prettier"
    ]

    standard = <[eslint@7 eslint-plugin-standard@4 eslint-plugin-promise@4 eslint-plugin-import@2 eslint-plugin-node@11 @typescript-eslint/eslint-plugin@2 eslint-config-standard-with-typescript]>
    airbnbWithReact = 
      \eslint-config-airbnb-typescript
      \eslint-plugin-import@^2.20.1
      \eslint-plugin-jsx-a11y@^6.2.3
      \eslint-plugin-react@^7.19.0
      \eslint-plugin-react-hooks@^2.5.0
      \@typescript-eslint/eslint-plugin@^3.1.0
    airbnb-base = 
      \eslint-config-airbnb-typescript
      \eslint-plugin-import@^2.20.1
      \@typescript-eslint/eslint-plugin@^3.1.0
 
    config = {extends:[]}
    switch anwsers.lint
    case "builtin"
      merge config, rc.recommended
    case "standard"
      @installTask ...standard
      merge config, rc.standard
    case "airbnb with react"
      @installTask ...airbnbWithReact
      merge config, rc.airbnbWithReact
    case "airbnb base"
      @installTask ...airbnb-base
      merge config, rc.airbnbBase
    if anwsers.prettier
      deps = [\prettier]
      @installTask ...deps
      config.extends = union config.extends,[\prettier/@typescript-eslint]
    @mergeWith (@proj \.eslintrc.js),"module.exports = #{@prettyJSON config}"
    log info "now you can use `npx eslint . --ext .js,.jsx,.ts,.tsx`"
    if anwsers.prettier
      log info "now you can add `prettier --write .`"

export TsTask