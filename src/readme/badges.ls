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

# py
pypi = (pkgName) -> "[![PyPI](https://img.shields.io/pypi/v/#{pkgName}.svg)](https://pypi.python.org/pypi/#{pkgName})"

#nim
nimble = (repoUri) ->"[![nimble](https://raw.githubusercontent.com/yglukhov/nimble-tag/master/nimble.png)](#{repoUri})"

export vsExtBadges = ( publisher,extname ) ->
  badges = 
    vsVersion publisher,extname
    vsInstalls publisher,extname
    vsRating publisher,extname
    vsTrending publisher,extname

export nodeBadges = (primary,pkgName,username,repo) ->
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

export pyBadges = (pkgName,username,repo) ->
  badges =
    buildStatus username,repo
    pypi pkgName

export nimBadges = (username,repo) ->
   badges =
    buildStatus username,repo
    nimble repo
