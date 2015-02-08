Meteor.startup ->
  racerKey = Session.get("racerKey")

  Meteor.call "loadRacer", racerKey, (_, actualKey)  ->
    Session.set "racerKey", actualKey

  Deps.autorun ->
