@Racer = null
Meteor.startup ->
  racerKey = Session.get('racerKey')

  Meteor.call 'loadRacer', racerKey, (_, actualKey)  ->
    Session.set 'racerKey', actualKey
    Meteor.subscribe 'racer', actualKey

  Deps.autorun ->
    key = Session.get('racerKey')
    @Racer = Racers.findOne(racerKey: key)

$ ->
  $(document).unbind('keydown').on 'keydown', (e) ->
    return if $(e.target).is(':input')

    charCode = e.which || e.keyCode
    if charCode in Keys.DELETE
      e.preventDefault()
