LiveTiles = new Meteor.Collection("livetiles")

if Meteor.isClient
  
  Session.set 'query', ""

  Template.hello.greeting = ->
    "Welcome to asteroid."

  Template.hello.messages = ->
    if Session.equals 'query',"" 
      Messages.find()
    else
      Messages.find({body: new RegExp('.*' + Session.get('query') + '.*', 'i') }) 


  Template.hello.events(
    'click #submit' : !->
      body = $('input#message_input').val()
      Messages.insert (body: body)
    'click #clear' : !->
      Messages.remove({})
    'keyup #search' : !->
      Session.set('query', $('input#search').val())
  )

  Template.gridster.events(
    'click .metro-tile' : !->
      gridster = $(".gridster ul").gridster().data('gridster')
      if LiveTiles.findOne() != undefined
        ltiles = LiveTiles.findOne()
        LiveTiles.update(ltiles._id, $set: {tiles: gridster.serialize()})
      else
        LiveTiles.insert(tiles: gridster.serialize())
  )

  Template.gridster.tiles = ->
    if LiveTiles.findOne() != undefined
      gridster_data = LiveTiles.findOne().tiles;
    else
      gridster_data = [{"col": "1", "row": "1", "size_x": "1", "size_y": "1"},
      {"col": "1", "row": "2", "size_x" : "1", "size_y": "1"},
      {"col": "1", "row": "3", "size_x" : "1", "size_y": "1"},
      {"col": "2", "row": "1", "size_x" : "2", "size_y": "1"},
      {"col": "2", "row": "2", "size_x" : "2", "size_y": "2"},
      {"col": "4", "row": "1", "size_x" : "1", "size_y": "1"},
      {"col": "4", "row": "2", "size_x" : "2", "size_y": "1"},
      {"col": "4", "row": "3", "size_x" : "1", "size_y": "1"},
      {"col": "5", "row": "1", "size_x" : "1", "size_y": "1"},
      {"col": "5", "row": "3", "size_x" : "1", "size_y": "1"},
      {"col": "6", "row": "1", "size_x" : "1", "size_y": "1"},
      {"col": "6", "row": "2", "size_x" : "1", "size_y": "2"}]

    return gridster_data

  Template.gridster.rendered = ->
    $('.gridster ul').gridster(
      widget_margins: [10, 10],
      widget_base_dimensions: [140, 140]
    )
    $('.gridster').width($('.row').width())

    tileElements = document.getElementsByClassName('metro-tile')
    for i from 0 to tileElements.length
      Tile( tileElements[i])

if Meteor.isServer
  Meteor.startup !->
    Messages.insert({body: "Hello World!"})
    Messages.insert({body: "Hello Again!"})
    Messages.insert({body: "Hello Live HTML!"})
