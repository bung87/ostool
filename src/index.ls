require! {
  fs
  path
  glob
  rimraf
  process
}
const {reject} = require 'prelude-ls'
const parse = require 'gitignore-globs'
const { spawnSync,spawn } = require 'child_process'
# const _ = require 'prelude-ls'
buildStatus = (username,repo) -> "[![Build Status](https://travis-ci.org/#{username}/#{repo}.svg?branch=master)](https://travis-ci.org/#{username}/#{repo})"
lgtmAlert =  (username,repo) -> "[![Total alerts](https://img.shields.io/lgtm/alerts/g/#{username}/#{repo}.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/#{username}/#{repo}/alerts/)"
lgtmGrade =  (username,repo) -> "[![Language grade: JavaScript](https://img.shields.io/lgtm/grade/javascript/g/#{username}/#{repo}.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/#{username}/#{repo}/context:javascript)"
npmVersion =  (pkgName) -> "[![Npm Version](https://badgen.net/npm/v/#{pkgName})](https://www.npmjs.com/package/#{pkgName})"
npmDownloads = (pkgName) -> "![npm: total downloads](https://badgen.net/npm/dt/#{pkgName})"
types = (pkgName) -> "![Types](https://badgen.net/npm/types/#{pkgName})"
deps = (username,repo) -> "![Dep](https://badgen.net/david/dep/#{username}/#{repo})"
license = (pkgName) -> "![license](https://badgen.net/npm/license/#{pkgName})"

const lgtmNotSupport = [".ls"]
const cwd = process .cwd!
const readme = path.join(cwd,"README.md")
const primary = sourceFilesOrdered![0][0]

function isJsEcosystem
    fs.existsSync path.join(cwd,"package.json")

function useYarn
    fs.existsSync path.join(cwd,"yarn.lock")

function useNpm 
    fs.existsSync path.join(cwd,"package-lock.json")
    
function usePnpm
    fs.existsSync path.join(cwd,"pnpm-lock.yaml")

export function runOut (cmd,...args)
    spawn(cmd, args,{stdio:'inherit'})

export function runIn (cmd,...args)
    child = spawnSync(cmd, args,{ stdio: 'pipe' })
    child.stdout?.toString!.trim!

function copyFile (src,des)
    fs.createReadStream(path.join(__dirname,src)).pipe(fs.createWriteStream(path.join(__dirname,dest)));

export function whichPm
    ## find which package manager be used (result cached)
    if not whichPm.result
        switch
        case useYarn!
            whichPm.result = "yarn"
        case useNpm!
            whichPm.result = "npm"
        case usePnpm!
            whichPm.result = "pnpm"
    else
        whichPm.result

export function cleanTask
    pkg = require path.join(cwd,"package.json")
    if "files" of pkg
        if pkg.files.length > 1
            pattern = "{#{pkg.files.join(",")}}"
        else if pkg.files.length  == 1
            pattern = pkg.files.join("")
        # glob.sync pattern,{cwd:cwd}
        rimraf.sync(pattern)

export function installTask (...deps)
    pm = whichPm!
    switch pm
    case "yarn"
        deps.splice(0,0,"add")
        deps.splice(deps.length,0,"-D")
    case "npm"
        deps.splice(0,0,"install")
        deps.splice(deps.length,0,"--save-dev")
    case "pnpm"
        deps.splice(0,0,"install")
        deps.splice(deps.length,0,"-d")
    runOut(pm,...deps)

export function tsLintTask
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
    fs.writeFileSync path.join(cwd,\.eslintignore),eslintignore
    rc = require "../src/eslintrc"
    fs.writeFileSync path.join(cwd,\.eslintrc.js),"module.exports = #{JSON.stringify rc,null,4}"
    # use airbnb
    # installTask \airbnb-typescript
    # rc.extends = rc.extends |> reject (x) -> x in [ 'eslint:recommended', 'plugin:@typescript-eslint/recommended' ]
    # rc.extends.push \airbnb-typescript

    # use prettier
    # rc.extends.push \prettier/@typescript-eslint
 
export applybadges = ->
    if fs.existsSync readme
        pkg = require path.join(cwd,"package.json")
        username = pkg.author
        repo = if typeof pkg.repository == "object"
            then 
                path.basename(pkg.repository.url)  
            else if typeof pkg.repository == "string"
                path.basename(pkg.repository)
            else
                pkg.name
        pkgName =  pkg.name
        origin = fs.readFileSync readme .toString!
        i = 0
        len = origin.length
        while i < len
            if origin[i] == "\n" or origin[i] == "["  or origin[i] == "!"
                break
            ++i
        badges = 
            buildStatus username,repo
            (if lgtmNotSupport.includes primary == false
            then  lgtmAlert username,repo
            )
            (if lgtmNotSupport.includes primary == false
            then  lgtmGrade username,repo
            )
            npmVersion pkgName
            npmDownloads pkgName
            (if primary == ".ts" 
             then types pkgName
            )
            deps username,repo
            license pkgName
        bs = []
        j = 0
        for badge in badges.filter( (x) -> x )
            if (origin .indexOf badge) == -1
                j += badge.length
                bs .push badge
        content =  origin.substring(0, i) + bs.join(" ") + origin.substring(i, origin.length)
        fs.writeFileSync(readme,content)

function ignores
    result = ["*.json","*.md","*.lock"]
    dotgitignores = path.join(cwd,".gitignore")
    dotnpmignores = path.join(cwd,".npmignore")
    gitignores = parse dotgitignores if fs.existsSync dotgitignores
    npmignores = parse dotnpmignores if fs.existsSync dotnpmignores
    result = result ++ gitignores if gitignores
    result = result ++ npmignores if npmignores
    return result

function files 
    glob.sync "**", {ignore:ignores!,cwd:cwd,nodir:true}

function countMap  (arr)
    arr.reduce( (countMap, word) -> 
        ext = path.extname(word)
        countMap[ext] = ++countMap[ext] || 1
        return countMap
    , {})

function sourceFilesOrdered 
     Object.entries (countMap files!) .sort (a,b) -> b[1] - a[1]
