require!{
  process
  "../src/mock":{Mock}
  "../src/health":{HealthTask}
  'assert': { strict:assert }
  "../src/std/io": {exists}
}
mock = Mock(HealthTask) with 
  setup:->
    @writeTo "index.ts",""
    @writeJSON "package.json",{}

mock.process!