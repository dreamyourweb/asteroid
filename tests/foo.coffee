describe "Foo", ->
  describe "Bar", ->
    it "checks if 1 == 1", ->
      chai.assert.equal 1, 1

  describe "Gridster", ->
    it "Show the amount of time worked", ->
      phantompage = require('webpage').create()
      console.log(phantompage)

      chai.expect(Template.gridster.tiles()).to.include(LiveTiles.find({type: "Toggl"}).fetch()[0])

