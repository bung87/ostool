require! {
  chalk
}
export warning = chalk.keyword('yellow')
export success = chalk.keyword('green')
export alert = chalk.keyword('red')
export info = chalk.keyword('cyan')
export log = console.log