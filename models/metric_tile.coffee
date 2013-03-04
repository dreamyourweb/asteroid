class MetricTile extends Minimongoid
  @_collection: new Meteor.Collection 'metrictiles'

  constructor: (options={}) ->
    @attributes.options = options

  value: =>
    switch @attributes.options.metric
      when "dealratio"
        DealRatio.bakeCurrentRatio()

# MetricTile.find({}).observeChanges
#   added: (id, tile) ->
#     console.log "ADDED " + tile
