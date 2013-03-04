class Toggl extends Minimongoid
  @_collection: new Meteor.Collection 'toggltimeentries'
  @workspace: 138404
  
  @getWorkedHours: (options={}) ->

    options = Metric.checkOptions(options)

    # USE ISO DATES
    startdate = options.startdate.toJSON()
    enddate = options.enddate.toJSON()

    totalTime = 0

    if options.user?
      Toggl.find({start: {$gte: startdate, $lt: enddate}, user_id: options.user.toggl.id}).map( (entry) -> totalTime = totalTime + entry.duration)
    else
      Toggl.find({start: {$gte: startdate, $lt: enddate}}).map( (entry) -> totalTime = totalTime + entry.duration)

    totalTime/3600

  @importTimeEntries: ->
    Meteor.users.find({}).forEach (user) ->

      Meteor.call 'getTogglTimeEntries', user.toggl, (e,entries) ->
        if entries.data? && entries.data.data?
          for i, entry of entries.data.data
            if entry.duration > 0
              togglId = entry.id
              entry.start = new Date(entry.start).toJSON()
              entry.stop = new Date(entry.stop).toJSON()
              delete entry['id']
              if (old_entry = Toggl.where({togglId: togglId})[0]) != undefined
                console.log(old_entry.update entry)
              else
                console.log(Toggl.create entry)