require!{
  path
  process
  child_process
  livescript: lsc
  "./std/io":{ writeFile,readFile,removeFile }
  pirates:{addHook}
  glob
  readline
}

tmp = """
require!{
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

for file in files

  mock = require path.join(cwd,file)
  origin = readFile path.join(cwd,file)
  changed = tmp + origin + suffix
  js = lsc.compile changed
  dir = path.dirname file
  name = path.parse(file).name
  dest = path.join dir,name + ".js"
  writeFile dest,js
  subprocess = child_process.fork dest,{stdio:['pipe', 'pipe', 'inherit',"ipc"]}

  subprocess.on 'unhandledRejection', (reason, promise) -> 
    console.error('Unhandled Rejection at:', promise, 'reason:', reason)
  subprocess.on 'uncaughtException', (err, origin) ->
    console.error err,orgin

  subprocess.on 'exit', ->
    removeFile dest

  subprocess.stdout.on "data",mock.answer.bind(null,subprocess)#(data) -> mock.answer.apply(null,[subprocess,data])
