Meteor.methods
  loadRacer: (racerKey)  ->
    racer = Racers.findOne
      racerKey: racerKey

    unless racer
      racerKey = Meteor.uuid()

      racer = Racers.insert
        racerKey: racerKey
        name: "Racer #{Racers.find().count() + 1}"
        avatar: 'car'

     racer.racerKey || racerKey

  createRace: (raceKey)  ->
    Races.insert
      raceKey: raceKey
      phrase: "abcdefghijklmnopqrstuvwxyz"
      state: "waiting_for_racers"
      time: 0
      maxTime: 3 * 60

  joinRace: (joinRacePacket) ->
    check(joinRacePacket, ValidJoinRacePacket)

    RaceParticipants.insert
      racerKey: joinRacePacket.racerKey
      raceKey: joinRacePacket.raceKey
      mistakes: 0
      progress: 0
      carKey: Meteor.uuid()
      state: 'pending'

  changeRacerState: (racerStatePacket) ->
    check(racerStatePacket, ValidChangeRacerStatePacket)

    state = racerStatePacket.state
    delete racerStatePacket.state

    RaceParticipants.update raceStatePacket,
      $set:
        state: state

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
