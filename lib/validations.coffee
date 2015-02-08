@ValidRace = Match.Where (key) ->
  Races.findOne(raceKey: key)

@ValidKeycode = Match.Where (keycode) ->
  check(keycode, Integer)

  keycode > 0

# TODO(nick): make more robust; possibly check code is within known race bounds
@ValidTimecode = Match.Where (timecode) ->
  check(timecode, Integer)

  timecode > 0

@ValidRaceKey = Match.Where (id) ->
  check(id, String)

  id.length == 36

@ValidRacerKey = Match.Where (id) ->
  check(id, String)

  true

@ValidRacerStatus = Match.Where (status) ->
  check(status, String)

  status in RacerStatuses

@ValidJoinRacePacket = Match.Where (packet) ->
  check(packet.raceKey, ValidRaceKey)
  check(packet.racerKey, ValidRacerKey)
  check(packet.raceKey, ValidRace)

  true

@ValidChangeRacerStatusPacket = Match.Where (packet) ->
  check(packet, ValidJoinRacePacket)
  check(packet.status, ValidRacerStatus)

  true

@ValidRacePacket = Match.Where (packet) ->
  check(racePacket.raceKey, ValidRaceKey)
  check(racePacket.keycode, ValidKeycode)
  check(racePacket.timecode, ValidTimecode)
  check(packet.raceKey, ValidRace)

  Racers.findOne(_id: packet.racerKey)
