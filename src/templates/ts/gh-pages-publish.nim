import strformat

var repoUrl
var pkg = JSON.parse(readFileSync("package.json"))
if typeof pkg.repository == "object":
  if not pkg.repository.hasOwnProperty("url"):
    raise newException(Exception,"URL does not exist in repository section")
  repoUrl = pkg.repository.url
else:
  repoUrl = pkg.repository
var parsedUrl = url.parse(repoUrl)
var repository = parsedUrl.host or "" + parsedUrl.path or ""
var ghToken = process.env.GH_TOKEN
echo("Deploying docs!!!")
cd("docs")
touch(".nojekyll")
exec("git init")
exec("git add .")
## exec('git config user.email "crc32@qq.com"')
exec("git commit -m \"docs(docs): update gh-pages\"")
exec(fmt"git push --force --quiet \"https://@\" master:gh-pages")
echo("Docs deployed!!")
