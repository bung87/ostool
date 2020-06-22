require! {
  inquirer
}
inquirer.registerPrompt("search-list", require("inquirer-search-list"))
cache = {}
export prompt = (questions) ->>
  anwsers = {}
  keys = Object.keys(cache)
  questionsNotCached = []
  for q in questions
    if keys.indexOf(q.name) == -1
      questionsNotCached.push q
    else
      console.log "cached question key:#{q.name}"
      anwsers[q.name] = cache[q.name]
  anwsers <<< await inquirer.prompt questionsNotCached
  cache <<< anwsers
  return anwsers