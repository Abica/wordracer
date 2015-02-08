@Racer = null
Meteor.startup ->
  racerKey = Session.get('racerKey')

  Meteor.call 'loadRacer', racerKey, (_, actualKey)  ->
    Session.set 'racerKey', actualKey
    Meteor.subscribe 'racer', actualKey

  Deps.autorun ->
    key = Session.get('racerKey')
    @Racer = Racers.findOne(racerKey: key)

