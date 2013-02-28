LiveTiles = new Meteor.Collection "livetiles"
TimeEntries = new TimeEntriesCollection "timeentries"

updateTiles = ->
  gridster = $(".gridster ul").gridster().data('gridster')
  changed_tiles = gridster.serialize_changed()
  for tile, i in changed_tiles
    LiveTiles.update(tile.id, $set: {col: tile.col, row: tile.row})

if Meteor.isClient

  Meteor.Router.add
    '/': 'page_home'
    '/test': 'page_test'


  Template.gridster.tiles = ->
    LiveTiles.find().fetch()

  Template.tile.metric = ->
    if this.type == "Toggl"
      "#{(Toggl.getWorkedHours({timespan: this.timespan})).toFixed(2)} uur"
    else if this.type == "Text"
      "#{this.text}"
    else if this.type == "DealRatio"
      "#{DealRatio.bakeCurrentRatio({timespan: this.timespan}).toFixed(2)} %"
    else if this.type == "FlowTime"
      "#{(FlowTime.bakeTimes({timespan: this.timespan})/3600/24).toFixed(0)} dagen"
    else if this.type == "DealCash"
      "€#{(DealCash.bakeCurrentCash({timespan: this.timespan})).toFixed(0)}"
    else
      "#{this.row},#{this.col}"

  Template.gridster.events(
    'click .remove-tile' : (e)->
      gridster = $(".gridster ul").gridster().data('gridster')
      tile_id = $(e.currentTarget).parent()[0].id
      gridster.remove_widget($(e.currentTarget).parent())
      Meteor.setTimeout ->
        updateTiles
        LiveTiles.remove tile_id
        , 500
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
          updateTiles()
      )
    )

  Meteor.autosubscribe ->
    Meteor.subscribe("livetiles")
    Meteor.subscribe("toggltimeentries")
    Meteor.subscribe("users")
    Meteor.subscribe("trellocards")
    Meteor.subscribe("trellocardmoves")
 
if Meteor.isServer
  Meteor.publish "toggltimeentries", ->
    Toggl._collection.find({})
  Meteor.publish "livetiles", ->
    LiveTiles.find({})
  Meteor.publish "users", ->
    Meteor.users.find({})
  Meteor.publish "trellocards", ->
    TrelloCard._collection.find({})
  Meteor.publish "trellocardmoves", ->
    TrelloCardMove._collection.find({})

  Meteor.startup ->
  	#Meteor.call 'getTogglTimeEntries', (e, result) ->
     # TimeEntries.remove({})
      #TimeEntries.insertFromJSON(JSON.parse(result.content))
      

