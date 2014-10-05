chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'release-notification', ->
  beforeEach ->
    @robot =
      respond: sinon.spy()
      hear: sinon.spy()

    require('../src/release-notification')(@robot)

  it 'recognizes release preview command', ->
    expect(@robot.respond).to.have.been.calledWith(/release preview appneta/node-traceview#9/)
    expect(@robot.respond).to.have.been.calledWith(/release preview #9/)

  it 'recognizes release announce command', ->
    expect(@robot.respond).to.have.been.calledWith(/release announce appneta/node-traceview#9/)
    expect(@robot.respond).to.have.been.calledWith(/release announce #9/)
