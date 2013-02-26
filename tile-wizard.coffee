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
                      - title: "Toggl Metric 2"
                  - title: "Trello"
                    index: 1
                    id: "trello"
                    tiles:
                      - title: "Trello Metric 1"
                      - title: "Trello Metric 2"
                      - title: "Trello Metric 3"
                  - title: "Text"
                    index: 2
                    id: "text"
                    inputs:
                      - type: "text"
                        default: "Tile text"
                        id: "tiletext"
                    submit:
                      type: "button"
                      value: "Add text tile"
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
    'click .button' : (e) ->
      button = $(e.currentTarget)
      Session.set("screenChoices", [button.data('index')])

    'click #clear-button' : ->
      Session.set("screenChoices", undefined)

    'click #addTile' : (e) ->
      button = $(e.currentTarget)
      if button.data('id') == "text"
        type = "Text"
        tiletext = $('#tiletext').val()

        gridster = $(".gridster ul").gridster().data('gridster')
        tile = gridster.add_widget("<li id='newTile' class='metro-tile'><h2>"+tiletext+"</h2></li>",2,1,1,1)
        tile = gridster.serialize(tile)[0]
        Meteor.setTimeout (tiletext) ->
          updateTiles()
          LiveTiles.insert {col: tile.col, row: tile.row, size_x: tile.size_x, size_y: tile.size_y, text: tiletext, type: type}
          ,500
  )
