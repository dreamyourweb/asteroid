class DealRatio extends Minimongoid
  @bakeCurrentRatio: (dateRange) ->

    deals = for i, move of TrelloCardMove.where({ 'data.listBefore.id': TrelloCard.list_ids[3], 'data.listAfter.id': TrelloCard.list_ids[4]})
      move.data.card.id
    deals = $.unique(deals)

    card_which_had_potential = for i, move of TrelloCardMove.where({'data.listAfter.id': {$in: [TrelloCard.list_ids[2],TrelloCard.list_ids[3]]}})
      move.data.card.id
    card_which_had_potential = $.unique(card_which_had_potential)

    card_closed_from_potential = for i, move of TrelloCardMove.where({'type': 'updateCard', 'data.card.closed': true, 'data.card.id': {$in: card_which_had_potential}})
      move.data.card.id
    card_closed_from_potential = $.unique(card_closed_from_potential)

    console.log(deals)
    console.log(card_which_had_potential)
    console.log(card_closed_from_potential)

    return deals.length / (card_closed_from_potential.length + deals.length)

