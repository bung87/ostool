require!{
  process
  "../src/mock":{Mock}
  "../src/health":{HealthTask}
}
mock = Mock(HealthTask) with 
  setup:->
    @writeTo "index.ts",""
    @writeJSON "package.json",{}

mock.process!