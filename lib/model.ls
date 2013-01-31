class Model
  id = void
  attributes = {}
  

  (attributes) ->
    if $.type(attributes) === "object"
      if attributes.id
        @id = attributes.id
        attributes.id = {}
        @attributes = attributes
      else
        @attributes = attributes

  save: -> 
    if @has-id!
      alert(@id)
      this.@@_collection.update @id, {$set: attributes}
    else
      @id = this.@@_collection.insert attributes

  has-id: -> @id?

  get-collection: -> this.@@_collection


  @all = (selector = {}, options = {}) ->
    @_collection.find

