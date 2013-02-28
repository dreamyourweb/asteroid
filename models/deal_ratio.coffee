class DealRatio extends Minimongoid
  @bakeCurrentRatio: (options={}) ->

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

    deals = for i, move of TrelloCardMove.where({ 'data.listBefore.id': TrelloCard.list_ids[3], 'data.listAfter.id': TrelloCard.list_ids[4]})
      move.data.card.id
    deals = _.uniq(deals)

    if options.users?
      deals = for i, card of TrelloCard.where({id: {$in: deals}, idMembers: {$in: options.users}})
        card.id

    card_which_had_potential = for i, move of TrelloCardMove.where({'date': {$gte: startdate, $lt: enddate}, 'data.listAfter.id': {$in: [TrelloCard.list_ids[2],TrelloCard.list_ids[3]]}})
      move.data.card.id
    card_which_had_potential = _.uniq(card_which_had_potential)

    if options.users?
      card_which_had_potential = for i, card of TrelloCard.where({id: {$in: card_which_had_potential}, idMembers: {$in: options.users}})
        card.id

    card_closed_from_potential = for i, move of TrelloCardMove.where({'date': {$gte: startdate, $lt: enddate}, 'type': 'updateCard', 'data.card.closed': true, 'data.card.id': {$in: card_which_had_potential}})
      move.data.card.id
    card_closed_from_potential = _.uniq(card_closed_from_potential)

    # console.log(deals)
    # console.log(card_which_had_potential)
    # console.log(card_closed_from_potential)

    return deals.length / (card_closed_from_potential.length + deals.length)

