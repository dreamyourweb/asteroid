class Minimongoid
  id: undefined
  attributes: {}
  _saved_attributes: {}
  @fields: {}

  constructor: (attributes = {}) ->
    if attributes._id
      @attributes = @demongoize(attributes)
      @id = attributes._id
    else
      @attributes = attributes

    for field, opts of @constructor.fields
      if not @attributes.hasOwnProperty field
        @attributes[field] = opts.default

  isPersisted: -> @id?

  isValid: -> true

  hasChanged: ->
    @_saved_attributes isnt @attributes

  resetChanges: ->
    @attributes = @_saved_attributes

  was: (field) ->
    if field
      @_saved_attributes[field]
    else
      @_saved_attributes

  get: (field) ->
    @attributes[field]

  set: (field,value) ->
    @attributes[field] = value

  save: ->
    return false unless @isValid()
    @_saved_attributes = @attributes
    
    attributes = @mongoize(@attributes)
    attributes['_type'] = @constructor._type if @constructor._type?
    
    if @isPersisted()
      @constructor._collection.update @id, { $set: attributes }
    else
      @id = @constructor._collection.insert attributes
    
    
  update: (@attributes) ->
    @save()

  destroy: ->
    if @isPersisted()
      @constructor._collection.remove @id
      @id = null

  mongoize: (attributes) ->
    taken = {}
    for name, value of attributes
      continue if name.match(/^_/)
      taken[name] = value
    taken

  demongoize: (attributes) ->
    taken = {}
    for name, value of attributes
      continue if name.match(/^_/)
      taken[name] = value
    taken

  @_collection: undefined
  @_type: undefined

  # Rubists will love me, everyone else will burn me!
  #
  # Allows calls like User.new firstname: 'John'
  @new: (attributes) ->
    new @(attributes)

  @create: (attributes) ->
    @new(attributes).save()

  @where: (selector = {}, options = {}) ->
    @_collection.find(selector, options)

  @all: (selector = {}, options = {}) ->
    @_collection.find(selector, options)

  @toArray: (selector = {}, options = {}) ->
    for attributes in @where(selector, options).fetch()
      # eval is ok, because _type is never entered by user
      new(eval(attributes._type) ? @)(attributes)

  @count: (selector = {}, options = {}) ->
    @where(selector, options).count()

  @destroyAll: (selector = {}) ->
    @_collection.remove(selector)

