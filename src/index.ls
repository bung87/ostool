require! {
  fs
  path
  glob
  rimraf
  process
  'universal-diff':{ mergeStr } 
  'child_process':{ spawnSync,spawn }
  'gitignore-globs':parse
  'prelude-ls':{reject,union}
}

const cwd = process .cwd!
const readme = path.join cwd, \README.md

export runOut = (cmd,...args) ->
  spawn(cmd, args, stdio: \inherit )

export runIn = (cmd,...args) ->
  child = spawnSync(cmd, args, stdio: \pipe )
  child.stdout?.toString!.trim!


export tsLintTask = ->
  # npx eslint . --ext .js,.jsx,.ts,.tsx
  ## see https://github.com/typescript-eslint/typescript-eslint/blob/master/docs/getting-started/linting/README.md

  installTask \@typescript-eslint/parser,\@typescript-eslint/eslint-plugin
  eslintignore = """
  don't ever lint node_modules
  node_modules
  # don't lint build output (make sure it's set to your correct build folder name)
  dist
  # don't lint nyc coverage output
  coverage
  """
  mergeWith path.join(cwd,\.eslintignore),eslintignore
  rc = require "../src/eslintrc"
  mergeWith path.join(cwd,\.eslintrc.js),"module.exports = #{JSON.stringify rc,null,4}"
  # use airbnb
  # installTask \airbnb-typescript
  # rc.extends = rc.extends |> reject (x) -> x in [ 'eslint:recommended', 'plugin:@typescript-eslint/recommended' ]
  # rc.extends = union rc.extends, [\airbnb-typescript]

  # use prettier
  # rc.extends = union rc.extends, [\prettier/@typescript-eslint]
