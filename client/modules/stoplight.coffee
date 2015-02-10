Template.stoplight.events

Template.stoplight.helpers

Template.stoplight.rendered = ->
  $stoplight = $('#stoplight-section')
  $ready = $stoplight.find('.ready')
  $set = $stoplight.find('.set')
  $go = $stoplight.find('.go')
  setTimeout ->
    $ready.fadeOut
      complete: ->
        $ready.show().addClass 'dim'
        $set.fadeOut
          complete: ->
            $set.show().addClass 'dim'
            $go.fadeOut
              complete: ->
                $go.show().addClass 'dim'
                $stoplight.hide()

  , 1000
