class Toggl extends Minimongoid
  @_collection: new Meteor.Collection 'toggltimeentries'
  
  @getWorkedHours: (options={}) ->
    console.log  options.timespan
    if options.startdate == undefined || options.startdate == "" || _.isNaN(options.startdate)
      options.startdate = new Date
      options.startdate.setDate(options.startdate.getDate() - 90)
    if options.enddate == undefined || options.enddate == "" || _.isNaN(options.enddate)
      options.enddate = new Date
    if options.enddate > new Date then options.enddate = new Date
    if options.timespan? && options.timespan != "" && !_.isNaN(options.timespan)
      options.startdate = new Date
      options.enddate = new Date
      options.startdate.setDate(options.startdate.getDate() - options.timespan)
    if typeof options.users == "string"
      options.users = [options.users]

    # USE ISO DATES
    startdate = options.startdate.toJSON()
    enddate = options.enddate.toJSON()

    console.log startdate
    console.log enddate

    totalTime = 0
    for i, entry of Toggl.where {start: {$gte: startdate, $lt: enddate}}
      totalTime = totalTime + entry.duration

    totalTime/3600

  @importTimeEntries: ->
    Meteor.call 'getTogglTimeEntries', (e,entries) ->
      if entries.data.data
        for i, entry of entries.data.data
          togglId = entry.id
          entry.start = new Date(entry.start).toJSON()
          entry.stop = new Date(entry.stop).toJSON()
          delete entry['id']
          if (old_entry = Toggl.where({togglId: togglId})[0]) != undefined
            console.log "UPDATE"
            console.log(old_entry.update entry)
          else
            console.log(Toggl.create entry)