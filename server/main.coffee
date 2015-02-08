Meteor.methods
  loadRacer: (racerKey)  ->
    racer = Racers.findOne
      racerKey: racerKey

    unless racer
      racerKey = Meteor.uuid()

      racer = Racers.insert
        name: "Racer #{Racers.find().count() + 1}"
        racerKey: racerKey

     racer.racerKey || racerKey

  createRace: (raceKey)  ->
    Races.insert
      raceKey: raceKey
      phrase: "abcdefghijklmnopqrstuvwxyz"
      state: "waiting_for_racers"

  joinRace: (joinRacePacket) ->
    check(joinRacePacket, ValidJoinRacePacket)

    RaceParticipants.insert
      racerKey: joinRacePacket.racerKey
      raceKey: joinRacePacket.raceKey

  changeRacerStatus: (racerStatusPacket) ->
    check(racerStatusPacket, ValidChangeRacerStatusPacket)

    status = racerStatusPacket.status
    delete racerStatusPacket.status

    RaceParticipants.update raceStatusPacket,
      $set:
        status: status

  racerStep: (racePacket) ->
    check(racePacket, ValidRacePacket)

    Sequences.insert
      racerKey: racePacket.racerKey
      raceKey: racePacket.raceKey
      keycode: racePacket.keycode
      timecode: racePacket.timecode


Meteor.startup ->
  Meteor.publish "race", (raceKey) ->
    Races.find
      raceKey: raceKey

  Meteor.publish "racer", (racerKey) ->
    Racers.find
      racerKey: racerKey

  Meteor.publish "racers", (raceKey) ->
    participants = RaceParticipants.find(raceKey: raceKey)
    racerKeys = participants.map (participant) ->
      participant.racerKey

    Racers.find
      racerKey:
        $in: racerKeys

  Meteor.publish "raceParticipants", (raceKey) ->
    RaceParticipants.find
      raceKey: raceKey

  Meteor.publish "sequences", (raceKey) ->
    Sequences.find
      raceKey: raceKey
