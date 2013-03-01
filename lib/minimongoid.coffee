class Minimongoid
  id: undefined
  attributes: {}
  _saved_attributes: undefined
  @fields: {}

  constructor: (attributes = {}) ->
    @attributes = attributes
    if attributes._id?
      @id = attributes._id

    for field, opts of @constructor.fields
      unless @attributes.hasOwnProperty field
        @attributes[field] = opts.default

    for field, value of @attributes
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
    @makeProperty field

  insert: (attributes) ->
    $.extend(@attributes, attributes)
    for field, value of attributes
      @makeProperty field

    this

  # Add a field as a property. Note that if you assign a non-existing property
  # this method will not be called and hence any assignment will not be reflected
  # in the attributes.
  makeProperty: (field) ->
    if this[field] == undefined && field != "id"
      Object.defineProperty this, field,
              get: -> @get field
              set: (value) ->
                @set(field,value)

  save: ->
    return false unless @isValid()
    @_saved_attributes = clone(@attributes)
    
    attributes = @attributes
    attributes['_type'] = @constructor._type if @constructor._type?
   
    if @isPersisted()
      @constructor._collection.update @id, { $set: @mongoize(attributes) }
        # @constructor._collection.insert attributes
    else if @attributes.id?
      @attributes._id = @attributes.id
      @id = @constructor._collection.insert attributes
    else #if attributes.id?
      # attributes._id = attributes.id
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
    @all(selector,options)

  @all: (selector = {}, options = {}) ->
    docs = []
    for i, obj of @_collection.find(selector, options).fetch()
      new_obj = @new(obj)
      new_obj._saved_attributes = clone(new_obj.attributes)
      docs.push(new_obj)
    return docs

  @toArray: (selector = {}, options = {}) ->
    for attributes in @where(selector, options).fetch()
      # eval is ok, because _type is never entered by user
      new(eval(attributes._type) ? @)(attributes)

  @count: (selector = {}, options = {}) ->
    @where(selector, options).count()

  @destroyAll: (selector = {}) ->
    @_collection.remove(selector)

