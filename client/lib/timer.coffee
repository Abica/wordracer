@Timer = class
  isRunning: false
  initialize: (delay) ->
    @delay = +delay

  elapsedTime: 0

  start: ->
    return if @isRunning

    @startedAt = Date.now()
    @isRunning = true
    @timerId = window.setInterval =>
      now = Date.now()
      @elapsedTime = now - @startedAt
      @step now
    , @delay

  step: (time) ->
    return unless @isRunning
    console.log @elapsedTime / 1000

  stop: ->
    @isRunning = false
    window.clearInterval @timerId
