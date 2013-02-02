class Minimongoid
  id: undefined
  attributes: {}
  _saved_attributes: undefined
  @fields: {}

  constructor: (attributes = {}) ->
    if attributes._id
      @attributes = @demongoize(attributes)
      @id = attributes._id
    else
      @attributes = attributes

    for field, opts of @constructor.fields
      unless @attributes.hasOwnProperty field
        @attributes[field] = opts.default
        @makeProperty field

  isPersisted: -> @id?

  isValid: -> true

  hasChanged: ->
    changed = false
    if @_saved_attributes
      for el of @_saved_attributes
        unless @_saved_attributes[el] is @attributes[el]
          changed = true
      return changed
    else
      true

  resetChanges: ->
    @attributes = clone(@_saved_attributes)

  was: (field) ->
    if field
      @_saved_attributes[field]
    else
      @_saved_attributes

  get: (field) ->
    @attributes[field]

  set: (field,value) ->
    @attributes[field] = value

  insert: (attributes) ->
    $.extend(@attributes, attributes)
    for field, value of attributes
      @makeProperty field

    this

  # Add a field as a property. Note that if you assign a non-existing property
  # this method will not be called and hence any assignment will not be reflected
  # in the attributes.
  makeProperty: (field) ->
    unless this[field]
      Object.defineProperty this, field,
              get: -> @get field
              set: (value) ->
                @set(field,value)

  save: ->
    return false unless @isValid()
    @_saved_attributes = clone(@attributes)
    
    attributes = @mongoize(@attributes)
    attributes['_type'] = @constructor._type if @constructor._type?
    
    if @isPersisted()
      @constructor._collection.update @id, { $set: attributes }
    else
      @id = @constructor._collection.insert attributes
    
    this
    
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

