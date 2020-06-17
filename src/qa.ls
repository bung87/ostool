require! {
  inquirer
}
inquirer.registerPrompt("search-list", require("inquirer-search-list"))

export prompt = inquirer.prompt