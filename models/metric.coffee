class Metric
  @checkOptions: (options={}) ->

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
    if options.user == undefined
      delete options['user']

    return options