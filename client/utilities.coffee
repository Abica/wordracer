@setDefault = (name, defaultValue) ->
  Session.set name, Session.get(name) || defaultValue
