Meteor.methods
  createRace: (raceKey)  ->
    Races.insert
      raceKey: raceKey
      phrase: "abcdefghijklmnopqrstuvwxyz"
      state: "waiting_for_racers"

  joinRace: (joinRacePacket) ->
    check(joinRacePacket, ValidJoinRacePacket)

  changeRacerStatus: (racerStatusPacket) ->
    check(racerStatusPacket, ValidChangeRacerStatusPacket)

  racerStep: (racePacket) ->
    check(racePacket, ValidRacePacket)

    Sequences.insert
      racerId: racePacket.racerId
      raceKey: racePacket.raceKey
      keycode: racePacket.keycode
      timecode: racePacket.timecode


Meteor.startup ->
  Meteor.publish "racers", (raceKey) ->
    Racers.find
      raceId: raceKey

  Meteor.publish "sequences", (raceKey) ->
    Sequences.find
      raceId: raceKey
