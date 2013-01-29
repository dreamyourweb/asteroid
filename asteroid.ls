LiveTiles = new Meteor.Collection("livetiles")

function updateTiles
    gridster = $(".gridster ul").gridster().data('gridster')
    changed_tiles = gridster.serialize_changed()
    for tile, i in changed_tiles
      LiveTiles.update(tile.id, $set: {col: tile.col, row: tile.row})

if Meteor.isClient

  Template.gridster.tiles = ->
    return LiveTiles.find().fetch()

  Template.toolbar.events(
    'click #addTile' : !->
      gridster = $(".gridster ul").gridster().data('gridster')
      tile = gridster.add_widget("<li id='newTile' class='metro-tile'><h2>"+$('#tileText').val()+"</h2></li>", parseInt($('#selectX').val()),parseInt($('#selectY').val()),1,1)
      tile = gridster.serialize(tile)[0]
      Meteor.setTimeout(!-> (
        updateTiles()
        LiveTiles.insert({col: tile.col, row: tile.row, size_x: tile.size_x, size_y: tile.size_y, text: $('#tileText').val()})
        ), 500)
    'click #clearAllTiles' : !->
      LiveTiles.remove({})   
    )

  Template.gridster.events(
    'click .remove-tile' : (e)->
      gridster = $(".gridster ul").gridster().data('gridster')
      gridster.remove_widget($(e.currentTarget).parent())
      Meteor.setTimeout(!-> (
        updateTiles()
        LiveTiles.remove($(e.currentTarget).parent()[0].id)
        ), 500)

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

 
if Meteor.isServer
  Meteor.startup !->