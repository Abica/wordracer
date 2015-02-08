RaceID = Match.Where (id) ->
  check(id, String)

  id.length == 36
