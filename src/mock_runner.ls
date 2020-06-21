require!{
  path
  fs
  process
  child_process
  livescript: lsc
  "./std/io":{ writeFile,readFile,removeFile }
  glob
}

tmp = """
require!{
  process
  livescript: lsc
  pirates:{addHook}
}

func = (code, filename) -> lsc.compile filename 
revert = addHook func,{ exts: ['ls',""] }

"""

suffix = """

if require.main == module
  module.exports.run!

"""

cwd = process.cwd!
pattern = process.argv.lsc[1]
files = glob.sync pattern,{ignore:["**/*.js"],cwd:cwd,nodir:true}
writeStream = fs.createWriteStream(path.join(cwd,"ostool.log"))

getDest = (file) ->
  
  origin = readFile path.join(cwd,file)
  changed = tmp + origin + suffix
  js = lsc.compile changed
  dir = path.dirname file
  name = path.parse(file).name
  dest = path.join dir,name + ".js"
  writeFile dest,js
  dest

  
start = (file) ->
  dest = getDest(file)
  mock = require path.join(cwd,file)
  subprocess = child_process.fork dest,{stdio:['pipe', 'pipe', 'inherit',"ipc"],execArgv:["--unhandled-rejections=strict"]}
  subprocess.on 'unhandledRejection UnhandledPromiseRejectionWarning', (reason, promise) -> 
    console.error('Unhandled Rejection at:', promise, 'reason:', reason)

  subprocess.on 'uncaughtException', (err, origin) ->
    console.error err,orgin
    subprocess.kill!

  subprocess.on 'error', (err) ->
    subprocess.kill!
    console.error err

  subprocess.on 'close', (code) ->
    removeFile dest
    console.log "finished mock:#{file}"
    next = files.shift!
    if next
      start next

  subprocess.stdout.on "data",(data) -> 
    str = data.toString!
    str = str.replace(/\[([0-9]+)?[A-Z]+/g,"")
    writeStream.write str
    mock.answer.apply(null,[subprocess.stdin,str])

next = files.shift!
start next
process.on "close", ->
  writeStream.end!