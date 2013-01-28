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
      LiveTiles.insert(size_x: parseInt($('#selectX').val()), size_y: parseInt($('#selectY').val()))
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
    # LiveTiles.insert({col:1, row:1, size_x:1, size_y:1})