class WBSO
  @getWBSO: (options={}) ->

    options = Metric.checkOptions(options)

    # USE ISO DATES
    startdate = options.startdate.toJSON()
    enddate = options.enddate.toJSON()

    totalTime = 0

    if options.user?
      Toggl.find({tag_names: "WBSO", start: {$gte: startdate, $lt: enddate}, user_id: options.user.toggl.id}).map( (entry) -> totalTime = totalTime + entry.duration)
    else
      Toggl.find({tag_names: "WBSO", start: {$gte: startdate, $lt: enddate}}).map( (entry) -> totalTime = totalTime + entry.duration)

    totalTime/3600