Router.map ->
  @route '/race/:_key',
    action: ->
      @state.set 'raceKey', @params._key
      @render 'race'

    waitOn: ->
      [Meteor.subscribe('race', @params._key),
       Meteor.subscribe('racers', @params._key),
       Meteor.subscribe('raceParticipants', @params._key),
       Meteor.subscribe('sequences', @params._key)]

    onBeforeAction: ->
      check(@params._key, ValidRaceKey)
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

