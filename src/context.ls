require! {
  fs
  path
  process
  glob
  ini
  minimatch
  "gitignore-globs": parse
  "./std/io":{ exists,readFile }
  "prelude-ls":{filter}
  "common-path-prefix"
}


export class Context
  (@cwd = process.cwd!) ->
    @primaryLang  = (@sourceFilesOrdered @cwd)[0][0]
    # available after @sourceFilesOrdered
    # primary sources
    priSources = @sources
      |> filter (x) ~> 
        path.extname(x) == @primaryLang
      |> filter (x) ->
        minimatch(x,"**/{__tests__,test,tests}/*") == false
    # primary sources root dir
    @priSourcesRoot = common-path-prefix priSources
    @isJsEcosystem = @isJsEcosystem!
    @isVscodeExt = @isVscodeExt!
    @isPyEcosystem = @isPyEcosystem!
    if @isJsEcosystem
      @useMirror = @useMirror!
  proj:(name) ->
    path.join @cwd,name
  
  isJsEcosystem: ->
    exists @proj \package.json

  useMirror: ->
    used = no
    config = ini.parse readFile path.join require('os').homedir(),\.npmrc
    if \registry of config
      org = config.registry.includes \https://registry.npmjs.org
      com = config.registry.includes \https://registry.npmjs.com
      used = !org and !com

  isVscodeExt: ->
    if @isJsEcosystem
      pkg = require @proj \package.json
      \engines of pkg and \vscode of pkg.engines
    else
      false

  isPyEcosystem: ->
    @primaryLang == ".py"

  ignores: (cwd) ->
    result = ["**/*.json","**/*.md","**/*.lock","**/*.txt","**/*.gz","**/*.cfg","**/*.ini"]
    dotgitignores = path.join cwd, ".gitignore"
    dotnpmignores = path.join cwd, ".npmignore"
    gitignores = parse dotgitignores if exists? dotgitignores
    npmignores = parse dotnpmignores if exists? dotnpmignores
    result = result ++ that if gitignores
    result = result ++ that if npmignores
    return result

  files: (cwd) ->
    @sources = glob.sync "**", ignore:(@ignores cwd), cwd: cwd, nodir: true

  countMap: (arr)  ->
    arr.reduce( (countMap, word) -> 
      ext = path.extname(word)
      countMap[ext] = ++countMap[ext] || 1
      return countMap
    , {})

  sourceFilesOrdered: (cwd) ->
    Object.entries (@countMap @files cwd) .sort (a,b) -> b[1] - a[1]