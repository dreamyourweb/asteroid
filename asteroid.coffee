LiveTiles = new Meteor.Collection "livetiles"
TimeEntries = new TimeEntriesCollection "timeentries"

updateTiles = (changed_tiles) ->
  # changed_tiles = gridster.serialize_changed()
  Meteor.setTimeout ->
    console.log changed_tiles
    for tile, i in changed_tiles
      LiveTiles.update(tile.id, $set: {col: tile.col, row: tile.row})
  ,500

# updateTileMetrics = ->
#   gridster = $(".gridster ul").gridster().data('gridster')
#   for i, tile of LiveTiles.find().fetch()
#     console.log tile
#     if $("##{tile._id}").length > 0
#       gridster.remove_widget("##{tile._id}")
#     gridster.add_widget(Template.tile(tile),tile.size_x,tile.size_y,tile.col,tile.row)

checkSessions = (session_vars) ->
  for i, session_var of session_vars
    unless Session.get(session_var)
      return false
  true


if Meteor.isClient

  Meteor.Router.add
    '/': 'page_home'
    '/test': 'page_test'

  Template.page_home.events(
    'click #toggle-wizard' : ->
      $("#tile-wizard").toggle(400)
  )

  Template.gridster.tiles = ->
    if checkSessions(["subscription_livetiles","subscription_trellocardmoves","subscription_toggltimeentries","subscription_users","subscription_trellocards","subscription_metrictiles"])
      $(".loader").hide()
      LiveTiles.find().fetch()

  Template.tile.metric = ->
    result = if this.type == "Toggl"
      m = Toggl.getWorkedHours({timespan: this.timespan, user: this.user})
      "#{m.toFixed(2)} uur"
    else if this.type == "Text"
      "#{this.text}"
    else if this.type == "DealRatio"
      m = (DealRatio.bakeCurrentRatio({timespan: this.timespan, user: this.user}) * 100)
      "#{m.toFixed(2)} %"
    else if this.type == "FlowTime"
      m = (FlowTime.bakeTimes({timespan: this.timespan, user: this.user})/3600/24)
      "#{m.toFixed(0)} dagen"
    else if this.type == "DealCash"
      m = (DealCash.bakeCurrentCash({timespan: this.timespan, user: this.user}))
      "€#{m.toFixed(0)}"
    else if this.type == "BSC"
      m = (BSC.bakeCurrentBSC({timespan: this.timespan, user: this.user}))
      "€#{m.toFixed(0)}"
    else if this.type == "WBSO"
      m = (WBSO.getWBSO({timespan: this.timespan, user: this.user}))
      "#{m.toFixed(2)} uur"
    else
      "#{this.row},#{this.col}"

    Session.set("metric-#{this._id}", m)
    return result

  Template.tile.rendered = ->
    metric = Session.get("metric-#{this.data._id}")
    tile = $("##{this.data._id}")
    if this.data.threshold != 0 && this.data.threshold != null
      switch this.data.threshold_operator
        when "<" then if metric < this.data.threshold then tile.addClass('alert')
        when ">" then if metric > this.data.threshold then tile.addClass('alert')
        when "<=" then if metric <= this.data.threshold then tile.addClass('alert')
        when ">=" then if metric >= this.data.threshold then tile.addClass('alert')

  Template.gridster.events(
    'click .remove-tile' : (e)->
      gridster = $(".gridster ul").gridster().data('gridster')
      tile_id = $(e.currentTarget).parent()[0].id
      gridster.remove_widget($(e.currentTarget).parent())
      changed_tiles = gridster.serialize_changed()
      updateTiles(changed_tiles)
      LiveTiles.remove tile_id
      false
    )

  Template.gridster.rendered = ->
    $('.gridster ul').gridster(
      widget_margins: [10, 10]
      widget_base_dimensions: [140, 140]
      serialize_params: ($w, wgd) ->
        (id: wgd.el[0].id, col: wgd.col, row: wgd.row, size_x: wgd.size_x, size_y: wgd.size_y)
      draggable: (
        stop: ->
          changed_tiles = $('.gridster ul').gridster().data('gridster').serialize_changed()
          updateTiles(changed_tiles)
      )
    )

  Meteor.autorun ->
    Meteor.subscribe "livetiles", ->
      Session.set("subscription_livetiles", true)
    Meteor.subscribe "trellocardmoves", ->
      Session.set("subscription_trellocardmoves", true)
    Meteor.subscribe "toggltimeentries", ->
      Session.set("subscription_toggltimeentries", true)
    Meteor.subscribe "users", ->
      Session.set("subscription_users", true)
    Meteor.subscribe "trellocards", ->
      Session.set("subscription_trellocards", true)
    Meteor.subscribe "metrictiles", ->
      Session.set("subscription_metrictiles", true)
   
if Meteor.isServer
  Meteor.publish "toggltimeentries", ->
    startdate = new Date
    startdate.setDate(startdate.getDate()-90)
    Toggl._collection.find({$or: [{start: {$gte: startdate.toJSON()}}, {tag_names: "WBSO"}]})
  Meteor.publish "livetiles", ->
    LiveTiles.find({})
  Meteor.publish "users", ->
    Meteor.users.find({})
  Meteor.publish "trellocards", ->
    TrelloCard._collection.find({})
  Meteor.publish "metrictiles", ->
    MetricTile._collection.find({})
  Meteor.publish "trellocardmoves", ->
    TrelloCardMove._collection.find({})

  Meteor.startup ->
    Meteor.setInterval ->
      TrelloCardMove.importMoves()
      TrelloCard.importCards()
      Toggl.importTimeEntries()
     ,1000*3600
  	#Meteor.call 'getTogglTimeEntries', (e, result) ->
     # TimeEntries.remove({})
      #TimeEntries.insertFromJSON(JSON.parse(result.content))
      

