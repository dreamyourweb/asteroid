class TrelloCardMove extends Minimongoid
  @_collection: new Meteor.Collection 'trellocardmoves'

  @importMoves: ->
    Meteor.call 'getTrelloCardMoves', (e,moves) =>
      if moves?
        for i, move of moves
          if (old_move = this.where(_id: move.id)[0]) != undefined
            console.log(old_move.update move)
          else
            console.log(this.create move)


class TrelloCard extends Minimongoid
  @_collection: new Meteor.Collection 'trellocard'
  @list_ids: ["4f7b0a856f0fc2d24dabec3c", "4f7b0a856f0fc2d24dabec3b","4f7b0a856f0fc2d24dabec3d","4f7b0bac01fd2f07368c022c","4f7b0bb101fd2f07368c08b8"]

  @importCards: ->
    Meteor.call 'getTrelloCards', (e,cards) =>
      if cards?
        for i, card of cards
          card.bsc_cash = @getCash(card.desc)
          card.bsc_prob = @getDealProbability(card.desc)
          card.bsc_date = @getDealDate(card.desc)
          if (old_card = this.where(_id: card.id)[0]) != undefined
            console.log(old_card.update card)
          else
            console.log(this.create card)

  @getCash: (description) ->
    cash_regex = description.match(/BSC:(.|\n)*- (\d*)€/)
    parseFloat(cash_regex[cash_regex.length-1]) if cash_regex?

  @getDealProbability: (description) ->
    prob_regex = description.match(/BSC:(.|\n)*- (\d*)%/)
    parseFloat(prob_regex[prob_regex.length-1])/100 if prob_regex?

  @getDealDate: (description) ->
    date_regex = description.match(/BSC:(.|\n)*- date: (\d*)/)
    new Date(date_regex[date_regex.length-1]) if deal_regex?


if Meteor.isServer

  Meteor.methods 
    getTrelloCards: ->
      date = new Date
      date.setDate(date.getDate()-7)
      result = undefined
      @unblock()
      result = Meteor.http.call("GET", "https://api.trello.com/1/boards/4f7b0a856f0fc2d24dabec36/cards",
        params:
          key: "b21235703575c2c2844154615e41c3d4"
          token: _TRELLO_TOKEN
          limit: 500
          filter: 'all'
      )
      if result.statusCode is 200
        return result.data

      false

    getTrelloCardMoves: ->
      result = undefined
      if (lastActionDate = TrelloCardMove.findOne({},{sort: {date: 1}}).date)
        lastActionDate = lastActionDate.toJSON
      else
        lastActionDate = null

      @unblock()
      result = Meteor.http.call("GET", "https://api.trello.com/1/boards/4f7b0a856f0fc2d24dabec36/actions",
        params:
          key: "b21235703575c2c2844154615e41c3d4"
          token: _TRELLO_TOKEN
          filter: "updateCard,createCard"
          limit: 500
          since: lastActionDate
      )
      if result.statusCode is 200
        # return result
        moves = []
        for i, action of result.data
          do (action) ->
            if ((action.data.listBefore != undefined && action.type == "updateCard") || action.type == "createCard" || (action.type == "updateCard" && action.data.card.closed == true && action.data.old.closed == false))
              moves.push action
        return moves
