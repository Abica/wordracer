Router.map ->
  @route '/race/:_key',
    action: ->
      @state.set 'raceKey', @params._key

    waitOn: ->
      [Meteor.subscribe('racers', @params._key),
       Meteor.subscribe('sequences', @params._key)]

    onBeforeAction: ->
      check(@params._id, ValidRaceKey)
      @next()

  @route '/',
    action: ->
      key = Meteor.uuid()
      Meteor.call 'createRace', key
      @redirect "/race/#{key}"

    onBeforeAction: ->
      if !Meteor.userId()
        console.log "not logged in"
        @next()
      else
        console.log "logged in"
        @next()

