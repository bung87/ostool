require! {
  fs
  path
}

buildStatus = (username,repo) -> "[![Build Status](https://travis-ci.org/#{username}/#{repo}.svg?branch=master)](https://travis-ci.org/#{username}/#{repo})"
lgtmAlert =  (username,repo) -> "[![Total alerts](https://img.shields.io/lgtm/alerts/g/#{username}/#{repo}.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/#{username}/#{repo}/alerts/)"
lgtmGrade =  (username,repo) -> "[![Language grade: JavaScript](https://img.shields.io/lgtm/grade/javascript/g/#{username}/#{repo}.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/#{username}/#{repo}/context:javascript)"
npmVersion =  (pkgName) -> "[![Npm Version](https://badgen.net/npm/v/#{pkgName})](https://www.npmjs.com/package/#{pkgName})"
npmDownloads = (pkgName) -> "![npm: total downloads](https://badgen.net/npm/dt/#{pkgName})"
types = (pkgName) -> "![Types](https://badgen.net/npm/types/#{pkgName})"
deps = (username,repo) -> "![Dep](https://badgen.net/david/dep/#{username}/#{repo})"
license = (pkgName) -> "![license](https://badgen.net/npm/license/#{pkgName})"

const cwd = process .cwd!
const readme = path.join(cwd,"README.md")
export applybadges ->
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
            lgtmAlert username,repo
            lgtmGrade username,repo
            npmVersion pkgName
            npmDownloads pkgName
            types pkgName
            deps username,repo
            license pkgName
        bs = []
        j = 0

        for badge in badges
            if (origin .indexOf badge) == -1
                j += badge.length
                bs .push badge
        content =  origin.substring(0, i) + bs.join(" ") + origin.substring(i, origin.length)
        fs.writeFileSync(readme,content)

    