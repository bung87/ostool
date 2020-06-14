require! {
  process
  fs
  path
  "./std/io":{ writeFile, readFile, exists }
}

{ whichPm } = require "./pm"
{ compile } = require "./template"

export class Task
  cwd:process.cwd!
  installTask: (...deps) ->
    pm = whichPm!
    switch pm
    case "yarn"
      deps unshift \add
      deps push \-D
    case "npm"
      deps unshift \install
      deps push \--save-dev
    case "pnpm"
      deps unshift \install
      deps push \-d
    runOut(pm,...deps)
  
  mergeWith: (dest,content) ->
    if exists dest
      origin = readFile dest 
      cnt = mergeStr origin, content
      writeFile dest,cnt
    else
      writeFile dest,content
  
  cleanTask: ->
    pkg = require path.join cwd,\package.json
    # tsconfig = require path.join cwd,\tsconfig.json
    # outDIr = tsconfig.compilerOptions.outDir
    if "files" of pkg
      if pkg.files.length > 1
        pattern = "{#{pkg.files * \, }}"
      else if pkg.files.length  == 1
        pattern = pkg.files * ""
      # glob.sync pattern,{cwd:cwd}
      rimraf.sync(pattern)
  
  copyFile: (src,des) ->
    fs.createReadStream(path.join __dirname,src ).pipe(fs.createWriteStream( path.join @cwd,dest ))

  renderTo: (dest,tpl,ctx) ->
    tmp = readFile(path.join __dirname,tpl)
    render = compile tmp
    writeFile path.resolve(@cwd,dest),render(ctx)

  writeTo: (dest,ctn) ->
    writeFile path.resolve(@cwd,dest),ctn