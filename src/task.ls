require! {
  process
  fs
  path
}

const {whichPm} = require "./pm"
const { compile } = require "./template"

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
        if fs.existsSync dest
            origin = fs.readFileSync dest .toString!
            cnt = mergeStr origin, content
            fs.writeFileSync dest,cnt
        else
            fs.writeFileSync dest,content
    
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
        tmp = fs.readFileSync(path.join __dirname,tpl).toString!
        render = compile tmp
        fs.writeFileSync path.resolve(@cwd,dest),render(ctx)

    writeTo: (dest,ctn) ->
        fs.writeFileSync path.resolve(@cwd,dest),ctn