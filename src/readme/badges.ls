const lgtmNotSupport = [".ls"]

buildStatus = (username,repo) -> "[![Build Status](https://travis-ci.org/#{username}/#{repo}.svg?branch=master)](https://travis-ci.org/#{username}/#{repo})"
lgtmAlert =  (username,repo) -> "[![Total alerts](https://img.shields.io/lgtm/alerts/g/#{username}/#{repo}.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/#{username}/#{repo}/alerts/)"
lgtmGrade =  (username,repo) -> "[![Language grade: JavaScript](https://img.shields.io/lgtm/grade/javascript/g/#{username}/#{repo}.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/#{username}/#{repo}/context:javascript)"
npmVersion =  (pkgName) -> "[![Npm Version](https://badgen.net/npm/v/#{pkgName})](https://www.npmjs.com/package/#{pkgName})"
npmDownloads = (pkgName) -> "![npm: total downloads](https://badgen.net/npm/dt/#{pkgName})"
types = (pkgName) -> "![Types](https://badgen.net/npm/types/#{pkgName})"
deps = (username,repo) -> "![Dep](https://badgen.net/david/dep/#{username}/#{repo})"
license = (pkgName) -> "![license](https://badgen.net/npm/license/#{pkgName})"

vsVersion = (publisher,extname) -> "[![](https://vsmarketplacebadge.apphb.com/version/#{publisher}.#{extname}.svg
)](https://marketplace.visualstudio.com/items?itemName=#{publisher}.#{extname})"
vsInstalls = (publisher,extname) -> "[![](https://vsmarketplacebadge.apphb.com/installs-short/#{publisher}.#{extname}.svg
)](https://marketplace.visualstudio.com/items?itemName=#{publisher}.#{extname})"
vsRating = (publisher,extname) -> "[![](https://vsmarketplacebadge.apphb.com/rating-short/#{publisher}.#{extname}.svg
)](https://marketplace.visualstudio.com/items?itemName=#{publisher}.#{extname})"
vsTrending = (publisher,extname) -> "[![](https://vsmarketplacebadge.apphb.com/trending-monthly/#{publisher}.#{extname}.svg
)](https://marketplace.visualstudio.com/items?itemName=#{publisher}.#{extname})"

export function vsExtBadges
    badges = 
        vsVersion publisher,extname
        vsInstalls publisher,extname
        vsRating publisher,extname
        vsTrending publisher,extname

export function nodeBadges
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

export applybadges = (badges) ->
    if fs.existsSync readme
        pkg = require path.join cwd,\package.json
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
        
        bs = []
        # j = 0
        for badge in badges.filter( (x) -> x )
            if (origin .indexOf badge) == -1
                # j += badge.length
                bs .push badge
        content =  origin.substring(0, i) + bs.join(" ") + origin.substring(i, origin.length)
        fs.writeFileSync(readme,content)