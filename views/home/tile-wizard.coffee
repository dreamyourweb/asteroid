if Meteor.isClient
  Meteor.startup ->
    wizardscreens = YAML.data.views.home.tilewizard

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
        if Session.get("screenChoices")?
          oldScreenChoices = Session.get("screenChoices")
        else
          oldScreenChoices = []

        if button.data('index') != ""
          oldScreenChoices.push(button.data('index'))
          Session.set("screenChoices", oldScreenChoices)

      'click #clear-button' : ->
        Session.set("screenChoices", undefined)

      'click #addTile' : (e) ->
        button = $(e.currentTarget)
        tiletype = button.data('addtile')
        switch tiletype
          when "text"
            addTile "Text", {text: $('#tiletext').val(), color: $(".colorpicker").val(), size_x: parseInt($("#tilesizex").val()), size_y: parseInt($("#tilesizey").val())}
          when "toggl1"
            addTile "Toggl", {timespan: parseInt($("input#timespan").val()), color: $(".colorpicker").val(), title: "hours worked", size_x: parseInt($("#tilesizex").val()), size_y: parseInt($("#tilesizey").val()), threshold: parseInt($("#threshold-value").val()), threshold_operator: $("#threshold-operator").val()}
          when "dealratio"
            addTile "DealRatio", {timespan: parseInt($("input#timespan").val()), color: $(".colorpicker").val(), title: "dealratio", size_x: parseInt($("#tilesizex").val()), size_y: parseInt($("#tilesizey").val())}
          when "flowtime"
            addTile "FlowTime", {timespan: parseInt($("input#timespan").val()), color: $(".colorpicker").val(), title: "Cycle Time", size_x: parseInt($("#tilesizex").val()), size_y: parseInt($("#tilesizey").val())}
          when "dealcash"
            addTile "DealCash", {timespan: parseInt($("input#timespan").val()), color: $(".colorpicker").val(), title: "Deal Cash", size_x: parseInt($("#tilesizex").val()), size_y: parseInt($("#tilesizey").val())}

        $("#tile-wizard").hide(400)
        Session.set("screenChoices", undefined)

      'click #back-wizard' : ->
        screenChoices = Session.get("screenChoices")
        screenChoices.pop()
        Session.set("screenChoices", screenChoices)
    )

    Template.tw_screen.rendered = ->
      $(".datepicker").datepicker();
      $(".colorpicker").colorpicker();
      $(document).foundationCustomForms();


    Template.tile_wizard.events(
      'click #close-wizard' : ->
        $("#tile-wizard").hide(400)
        Session.set("screenChoices", undefined)
    )

    Template.wizard_toggle.events(
      'click #show-wizard' : ->
        $("#tile-wizard").show(400)
    )

addTile = (type, options)->
  gridster = $(".gridster ul").gridster().data('gridster')

  if !options?
    options = {}

  if !options.color? || options.color == ""
    options.color = "green"

  console.log options

  tile = gridster.add_widget("<li id='newTile' style='background: #{options.color}' class='metro-tile'><h2>"+options.text+"</h2></li>",options.size_x,options.size_y,1,1)
  tile = gridster.serialize(tile)[0]
  Meteor.setTimeout ->
    updateTiles()
    LiveTiles.insert {timespan: options.timespan, title: options.title, col: tile.col, row: tile.row, size_x: tile.size_x, size_y: tile.size_y, text: options.text, type: type, color: options.color, threshold: options.threshold, threshold_operator: options.threshold_operator}
    ,1000