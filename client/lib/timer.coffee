@Timer = class
  isRunning: false
  elapsedTime: 0

  constructor: (delay, stepFunction) ->
    @delay = +delay
    @stepFunction = stepFunction || ->

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

    @stepFunction()

  stop: ->
    @isRunning = false
    window.clearInterval @timerId
