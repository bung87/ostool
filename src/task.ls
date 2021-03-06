require! {
  process
  fs
  path
  chalk
  rimraf
  util
  "./std/io":{ writeFile, readFile, exists }
  "./pm":{ whichPm } 
  "./template":{ compile } 
  'prelude-ls':{ map,join,tail }
  'is-ci':isCI
  'universal-diff':{ mergeStr,compareStr } 
  "./std/process": { runOut,runIn}
  "./std/log":{ log,warning,success,alert,info}
  'assert': { strict:assert }
}


changeCase = (v) ->
  if /^[A-Z]+$/ is v
    v
  else
    v.toLowerCase!

camelCase2sentence = (v) ->
  v = v.replace(/([A-Z][a-z0-9]+)/g, ' $1 ') .replace(/\s{2}/g," ").trim().split(" ")
    |> map changeCase
    |> join " "
  v = v[0].toUpperCase! + v.substring 1 

handler = 
  get: (obj, prop) ->
    if prop.startsWith \check
      sentence = prop |> camelCase2sentence
      return ->
        ret = obj[prop] ...
        if prop.startsWith \checkHas
          obj[ \has + prop.substring(\checkHas .length )] = ret
        if typeof ret == "boolean"
          if (ret)
            log success "[✓] #{sentence}"
            ret
          else
            log warning "[ ] #{sentence}"
            query = (obj.__isTest or !isCI or process.stdout.isTTY)
            # if obj.__isTest
            #   console.log "query user:#{query}"
            obj.taskQueue.push that if query and obj[prop].prompt
          ret
    else
      obj[prop]

export class Task
  (@cwd = process.cwd!) -> 
    @taskQueue = []
    return new Proxy(@, handler)
  installTask: (...deps) ->
    pm = null
    if @isJsEcosystem
      pm = whichPm @cwd
      switch pm
      case "yarn"
        deps .unshift \add
        deps .push \-D
      case "npm"
        deps .unshift \install
        deps .push \--save-dev
      case "pnpm"
        deps .unshift \install
        deps .push \-d
      default 
        pm = \npm
        deps .unshift \install
        deps .push \--save-dev
    else if @isNimEcosystem
      pm = "nimble"
      deps .push \-y
    else if @isPyEcosystem
      pm = "pip"
    assert pm != null,"Can't detect package manager!"
    runOut(pm,@cwd,...deps)
  
  mergeWith: (dest,content) ->
    _dest = if path.isAbsolute(dest) then dest else path.join(@cwd,dest)
    if exists _dest
      origin = readFile _dest 
      ret = compareStr origin, content
      cnt = mergeStr origin, ret
      writeFile _dest,cnt
    else
      writeFile _dest,content
  
  cleanTask: ->
    pkg = require @proj \package.json
    # tsconfig = require path.join cwd,\tsconfig.json
    # outDIr = tsconfig.compilerOptions.outDir
    if "files" of pkg
      if pkg.files.length > 1
        pattern = "{#{pkg.files * \, }}"
      else if pkg.files.length  == 1
        pattern = pkg.files * ""
      # glob.sync pattern,{cwd:cwd}
      rimraf.sync(pattern)
  
  copyFile: (src,dest) ->
    ## from this lib to project
    _src = if path.isAbsolute(src) then src else path.join(__dirname,src)
    _dest = if path.isAbsolute(dest) then dest else path.join(@cwd,dest)
    fs.createReadStream(_src ).pipe(fs.createWriteStream( _dest ))

  renderTo: (dest,tpl,ctx) ->
    tmp = readFile @tpl tpl
    render = compile tmp
    writeFile path.resolve(@cwd,dest),render(ctx)

  render: (tpl,ctx = {}) ->
    _tpl = readFile tpl
    render = compile(_tpl)
    render ctx
    
  tpl:(...args)->
    p = path.join ...args
    path.join __dirname,"templates",p

  proj:(...args) ->
    p = path.join ...args
    path.join @cwd,p

  writeTo: (dest,ctn) ->
    writeFile path.resolve(@cwd,dest),ctn

  writeJSON:(dest,obj) ->
    writeFile path.resolve(@cwd,dest),@prettyJSON obj

  prettyJSON:(obj) -> JSON.stringify(obj,null,4)
  # printMethods: ->
  #   try
  #     for let key, value of @ 
  #       when key of super?:: == false
  #         console.log key,value
  printMethods: ->
    for let key, value of @ 
      when key of Task:: == false and typeof value == "function"
        console.log key,value

  process: ->>
    for let key, value of @ 
      if key of Task:: == false and typeof value == "function"
        value ...

    @taskQueue.reduce (p,func) ~>>
      if util.types.isAsyncFunction func
        p.then ~>>
          func ...
      else
        Promise.resolve(func ...)
    ,Promise.resolve()
