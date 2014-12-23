# Description:
#   Gravatar is the most important thing in life
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot deal - deal me 5 cards from a 52 card deck
#   hubot gravatar for EMAIL - generate the gravatar URL based on the provided email
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

fairmont = require 'fairmont'
_ = require 'underscore'

suits = [ '♣', '♢', '♡', '♠' ]

spades   = [ "1♠", "2♠", "3♠", "4♠", "5♠", "6♠", "7♠", "8♠", "9♠", "10♠", "J♠", "Q♠", "K♠", "A♠" ]
hearts   = [ "1♡", "2♡", "3♡", "4♡", "5♡", "6♡", "7♡", "8♡", "9♡", "10♡", "J♡", "Q♡", "K♡", "A♡" ]
diamonds = [ "1♢", "2♢", "3♢", "4♢", "5♢", "6♢", "7♢", "8♢", "9♢", "10♢", "J♢", "Q♢", "K♢", "A♢" ]
clubs    = [ "1♣", "2♣", "3♣", "4♣", "5♣", "6♣", "7♣", "8♣", "9♣", "10♣", "J♣", "Q♣", "K♣", "A♣" ]


card_value = (card) ->
  suit = card.substr(-1);
  suit_power = suits.indexOf(suit)

  console.log("compare_cards")

###
  score = (card) ->
..   suit = card.substr(-1)
..   value = card.substr(0, card.length-1)
..   sv = suits.indexOf(suit)
..   value * 4.0 + sv
###


module.exports = (robot) ->

  robot.respond /deal/i, (msg) ->
    deck = spades.concat( hearts.concat( diamonds.concat( clubs )))
    shuffled_deck = fairmont.shuffle( deck )
    player_hand = [ shuffled_deck[0], shuffled_deck[2], shuffled_deck[4], shuffled_deck[6], shuffled_deck[8] ]
    dealer_hand = [ shuffled_deck[1], shuffled_deck[3], shuffled_deck[5], shuffled_deck[7], shuffled_deck[9] ]
    msg.send "Player's Hand: " + player_hand
    msg.send "Dealer's Hand: " + dealer_hand
 
  robot.respond /retro(vatar)? (me|for )?(.*@.*)/i, (msg) ->
    email = msg.match[3]
    if email.match /(.*)@(.*)/i
      email_hash = fairmont.md5(email.trim().toLowerCase())
      msg.send "http://www.gravatar.com/avatar/#{email_hash}.jpg?f=y&d=retro"
 
  robot.respond /wavatar (me|for )?(.*@.*)/i, (msg) ->
    email = msg.match[2]
    if email.match /(.*)@(.*)/i
      email_hash = fairmont.md5(email.trim().toLowerCase())
      msg.send "http://www.gravatar.com/avatar/#{email_hash}.jpg?f=y&d=wavatar"
 
  robot.respond /identicon (me|for )?(.*@.*)/i, (msg) ->
    email = msg.match[2]
    if email.match /(.*)@(.*)/i
      email_hash = fairmont.md5(email.trim().toLowerCase())
      msg.send "http://www.gravatar.com/avatar/#{email_hash}.jpg?f=y&d=identicon"
 
  robot.respond /monster(id)? (me|for )?(.*@.*)/i, (msg) ->
    email = msg.match[3]
    if email.match /(.*)@(.*)/i
      email_hash = fairmont.md5(email.trim().toLowerCase())
      msg.send "http://www.gravatar.com/avatar/#{email_hash}.jpg?f=y&d=monsterid"
 
  robot.respond /large gravatar (for )?(.*@.*)/i, (msg) ->
    email = msg.match[2]
    if email.match /(.*)@(.*)/i
      email_hash = fairmont.md5(email.trim().toLowerCase())
      msg.send "http://www.gravatar.com/avatar/#{email_hash}.jpg?s=200&d=mm"

  robot.respond /avatar (me|for )?(.*@.*)/i, (msg) ->
    email = msg.match[2]
    if email.match /(.*)@(.*)/i
      email_hash = fairmont.md5(email.trim())
      msg.send "http://www.gravatar.com/avatar/#{email_hash}.jpg?d=identicon"

  robot.respond /gravatar (me|for )?(.*@.*)/i, (msg) ->
    email = msg.match[2]
    if email.match /(.*)@(.*)/i
      email_hash = fairmont.md5(email.trim().toLowerCase())
      msg.send "http://www.gravatar.com/avatar/#{email_hash}.jpg?d=identicon"

# add code to get avatar from hipchat

# add code to get avatar from ???



