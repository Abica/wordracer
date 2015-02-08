Router.map ->
  @route '/race/:_id',
    action: ->
      params = @params
      raceId = params._id
      @state.set 'raceId', raceId

    waitOn: ->
      [Meteor.subscribe('racers', @params._id),
       Meteor.subscribe('sequences', @params._id)]

    onBeforeAction: ->
      check(@params._id, RaceID)
      @next()

  @route '/',
    action: ->
      @redirect "/race/#{Meteor.uuid()}"

    onBeforeAction: ->
      if !Meteor.userId()
        console.log "not logged in"
        @next()
      else
        console.log "logged in"
        @next()

