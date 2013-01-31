class TimeEntriesCollection extends Meteor.Collection
  

  lastMonthTotal: ~>
    month_total = 0
    for time_entry, i in this.find({}).fetch()
      month_total += time_entry.duration
    return month_total

  insertFromJSON: (json) ~>
    for time_entry, i in json.data
      this.insert(time_entry)


class User extends Model
  @_collection = new Meteor.Collection("users")