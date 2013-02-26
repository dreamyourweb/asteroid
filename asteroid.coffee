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
      "#{(TimeEntries.lastMonthTotal()/3600).toFixed(2)} uur"
    else if this.type == "Text"
      "#{this.text}"
    else
      "#{this.row},#{this.col}"

  Template.toolbar.reactivity = ->
    if card = TrelloCard.where(name: "Asteroid Test Card")[0]
      card.react

  Template.toolbar.events(
    'click #addTile' : ->
      gridster = $(".gridster ul").gridster().data('gridster')
      tile = gridster.add_widget("<li id='newTile' class='metro-tile'><h2>"+$('#tileText').val()+"</h2></li>", parseInt($('#selectX').val()),parseInt($('#selectY').val()),1,1)
      tile = gridster.serialize(tile)[0]
      Meteor.setTimeout ->
        updateTiles()
        LiveTiles.insert {col: tile.col, row: tile.row, size_x: tile.size_x, size_y: tile.size_y, text: $('#tileText').val(), type: $('#selectType').val()}
        ,500
    'click #clearAllTiles' : ->
      LiveTiles.remove({})   
    )

  Template.gridster.events(
    'click .remove-tile' : (e)->
      gridster = $(".gridster ul").gridster().data('gridster')
      gridster.remove_widget($(e.currentTarget).parent())
      Meteor.setTimeout ->
        updateTiles
        LiveTiles.remove $(e.currentTarget).parent()[0].id
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
    Meteor.subscribe("timeentries")
    Meteor.subscribe("users")
    Meteor.subscribe("trellocards")
    Meteor.subscribe("trellocardmoves")
 
if Meteor.isServer
  Meteor.publish "timeentries", ->
    TimeEntries.find({})
  Meteor.publish "livetiles", ->
    LiveTiles.find({})
  Meteor.publish "users", ->
    Meteor.users.find({})
  Meteor.publish "trellocards", ->
    TrelloCard._collection.find({})
  Meteor.publish "trellocardmoves", ->
    TrelloCardMove._collection.find({})

  Meteor.startup ->
    Meteor.call 'getTogglTimeEntries', (e, result) ->
      # TimeEntries.remove({})
      # TimeEntries.insertFromJSON(JSON.parse(result.content))
      

