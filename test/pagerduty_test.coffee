{assert} = require 'chai'
nock     = require 'nock'
nconf    = require 'nconf'

config   = require '../src/config'
pd       = require '../src/pagerduty'

configPath = __dirname + '/fixtures/config.json'
configWrongPath = __dirname + '/fixtures/config-wrong.json'

describe 'Get schedules Ids', ->
  schedules = null

  before (done) ->
    config.setupConfig(configPath)

    nock('https://acme.pagerduty.com/api/v1')
      .get('/schedules')
      .replyWithFile(200, __dirname + '/fixtures/schedules.json')

    pd.getSchedulesIds (err, schedulesIds) ->
      schedules = schedulesIds
      done err

  it 'Check how many schedules', ->
    assert.equal schedules.length, 2

describe 'Check schedules', ->
  schedules = null

  before (done) ->
    config.setupConfig(configPath)

    nock('https://acme.pagerduty.com/api/v1')
      .get('/schedules')
      .replyWithFile(200, __dirname + '/fixtures/schedules.json')

    pd.checkSchedulesIds (err, res) ->
      schedules = res
      done err

  it 'Check if config ids are in pagerduty schedules', ->
    assert.ok schedules

describe 'Check schedules with wrong config', ->
  schedules = null

  before (done) ->
    config.setupConfig(configWrongPath)

    nock('https://acme.pagerduty.com/api/v1')
      .get('/schedules')
      .replyWithFile(200, __dirname + '/fixtures/schedules.json')

    pd.checkSchedulesIds (err, res) ->
      schedules = res
      done err

  it 'Check if config ids are in pagerduty schedules', ->
    assert.notOk schedules

describe 'Compare schedules', ->

  message = null

  before (done) ->
    config.setupConfig(configPath)

    nock('https://acme.pagerduty.com/api/v1')
      .get('/schedules')
      .replyWithFile(200, __dirname + '/fixtures/schedules.json')

    nock('https://acme.pagerduty.com/api/v1')
      .get('/schedules/undefined/entries')
      .replyWithFile(200, __dirname + '/fixtures/entries.json')


    pd.checkSchedulesIds (err, res) ->
      if err then return done err
      unless res
        return done new Error("Check failed")
      pd.processSchedulesFromConfig (err, msg) ->
        if err then return done err
        message = msg
        done err

  it 'Test message', ->
    assert.equal message, 'OK'
