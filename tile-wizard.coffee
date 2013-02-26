if Meteor.isClient
  wizardyaml =  """
                title:  "Services"
                id: "services"
                tiles:
                  - title: "Toggl"
                    index: 0
                    id: "toggl"
                    tiles:
                      - title: "Toggl Metric 1"
                        addtile: "toggl1"
                      - title: "Toggl Metric 2"
                  - title: "Trello"
                    index: 1
                    id: "trello"
                    tiles:
                      - title: "Trello Metric 1"
                        addtile: "trello1"
                      - title: "Trello Metric 2"
                      - title: "Trello Metric 3"
                  - title: "Text"
                    index: 2
                    id: "text"
                    inputs:
                      - type: "text"
                        default: "Tile text"
                        id: "tiletext"
                    addtile: "text"
                """

  wizardscreens = YAML.parse(wizardyaml)

  Template.tw_screen.screen = ->
    screen = {}

    if Session.get('screenChoices')?
      screen = wizardscreens
      for chosenTile in Session.get('screenChoices')
        screen = screen.tiles[chosenTile]
      Session.set('currentWizardTileId',screen.id)
      return screen
    else
      return wizardscreens

  Template.tw_screen.equals = (l,r) ->
    l == r

  Template.tw_screen.events(
    'click .tilebutton' : (e) ->
      button = $(e.currentTarget)
      Session.set("screenChoices", [button.data('index')])

    'click #clear-button' : ->
      Session.set("screenChoices", undefined)

    'click #addTile' : (e) ->
      button = $(e.currentTarget)
      if button.data('addtile') == "text"
        addTiles "Text", $('#tiletext').val()

      $("#tile-wizard").hide(400)
      Session.set("screenChoices", undefined)
  )

  Template.tile_wizard.events(
    'click #close-wizard' : ->
      $("#tile-wizard").hide(400)
      Session.set("screenChoices", undefined)
  )

  Template.wizard_toggle.events(
    'click #show-wizard' : ->
      $("#tile-wizard").show(400)
  )

addTiles = (type, text)->
  gridster = $(".gridster ul").gridster().data('gridster')
  tile = gridster.add_widget("<li id='newTile' class='metro-tile'><h2>"+text+"</h2></li>",2,1,1,1)
  tile = gridster.serialize(tile)[0]
  Meteor.setTimeout ->
    updateTiles()
    LiveTiles.insert {col: tile.col, row: tile.row, size_x: tile.size_x, size_y: tile.size_y, text: text, type: type}
    ,500