{ getLicense } = require "license"

export getLicense

export function maxLine (content)
  j = 0
  _maxLine = (p,c,i) -> 
    if c.includes "\n"
      j := 0
    else
      j := j + c.length
    if j + c.length >= 80
      p = p.trimRight! + "\n" + c + " "
      j := 0
    else
      p += c + " "
    return p
  content.split(" ").reduce _maxLine,"" .trimRight!