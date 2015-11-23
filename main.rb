require 'rubygems'
require 'sinatra'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'lem30zeW'

BLACKJACK_SCORE = 21
DEALER_MIN = 17
INITIAL_POT = 500
helpers do
  def hand_total(cards)
    total = 0
    ranks = cards.map { |card| card[0] }
    aces_count = ranks.count("A")

    ranks.each do |rank|
      if rank == "A"
        total += 11
      else
        total += (rank.to_i == 0 ? 10 : rank.to_i)
      end
    end

    aces_count.times { total -= 10 if total > 21 }
    total
  end

  def show_card(card)
    suit = case card[1]
    when 'C' then 'clubs'
    when 'D' then 'diamonds'
    when 'H' then 'hearts'
    when 'S' then 'spades'
    end

    rank = card[0]
    if rank.to_i == 0
      rank = case card[0]
      when 'J' then 'jack'
      when 'Q' then 'queen'
      when 'K' then 'king'
      when 'A' then 'ace'
      end
    end

    "<img src='/images/cards/#{suit}_#{rank}.jpg' class='card-image'/>"
  end

  def winner!(msg)
    @replay = true
    @show_action_buttons = false
    session[:player_pot] = session[:player_pot] + session[:player_bet]
    @success = "<strong>#{session[:player_name]} wins!</strong> #{msg}"
  end

  def loser!(msg)
    @replay = true
    @show_action_buttons = false
    session[:player_pot] = session[:player_pot] - session[:player_bet]
    @error = "<strong>#{session[:player_name]} loses.</strong> #{msg}"
  end

  def tie!(msg)
    @replay = true
    @show_action_buttons = false
    @success = "<strong>It's a tie!</strong> #{msg}"
  end
end

before do
  @show_action_buttons = true
end

get '/' do
  if session[:player_name]
    redirect '/game'
  else
    redirect '/new_game'
  end
end

get '/new_game' do
  session[:player_pot] = INITIAL_POT
  erb :new_game
end

post '/new_game' do
  if params[:player_name].empty?
    @error = "Please enter your name."
    halt erb(:new_game)
  end

  session[:player_name] = params[:player_name]
  redirect '/bet'
end

get '/bet' do
  session[:player_bet] = nil
  erb :bet
end

post '/bet' do
  if params[:bet_amount].nil? || params[:bet_amount].to_i == 0
    @error = "Must make a bet."
    halt erb(:bet)
  elsif params[:bet_amount].to_i > session[:player_pot]
    @error = "Bet amount can't be more than you have($#{session[:player_pot]})."
    halt erb(:bet)
  else
    session[:player_bet] = params[:bet_amount].to_i
    redirect '/game'
  end
end

get '/game' do
  session[:turn] = session[:player_name]

  suits = ['H', 'D', 'C', 'S']
  ranks = [2, 3, 4, 5, 6, 7, 8, 9, 10, 'J', 'Q', 'K', 'A']
  session[:deck] = ranks.product(suits).shuffle!

  session[:dealer_cards] = []
  session[:player_cards] = []

  2.times do
    session[:dealer_cards] << session[:deck].pop
    session[:player_cards] << session[:deck].pop
  end

  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop
  player_total = hand_total(session[:player_cards])

  if player_total == BLACKJACK_SCORE
    winner!("#{session[:player_name]} hit blackjack.")
  elsif player_total > BLACKJACK_SCORE
    loser!("#{session[:player_name]} busted with #{player_total}.")
  end

  erb :game
end

post '/game/player/stay' do
  @success = "#{session[:player_name]} stays."
  @show_action_buttons = false
  redirect '/game/dealer'
end

get '/game/dealer' do
  session[:turn] = "dealer"
  @show_action_buttons = false
  dealer_total = hand_total(session[:dealer_cards])

  if dealer_total == BLACKJACK_SCORE
    loser!("Dealer hit blackjack.")
  elsif dealer_total > BLACKJACK_SCORE
    winner!("Dealer busted with #{dealer_total}.")
  elsif dealer_total >= DEALER_MIN
    redirect '/game/compare'
  else
    @show_dealer_action = true
  end

  erb :game
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do
  @show_action_buttons = false

  player_total = hand_total(session[:player_cards])
  dealer_total = hand_total(session[:dealer_cards])

  if player_total < dealer_total
    loser!("#{session[:player_name]} stayed at #{player_total}, and the dealer stayed at #{dealer_total}.")
  elsif player_total > dealer_total
    winner!("#{session[:player_name]} stayed at #{player_total}, and the dealer stayed at #{dealer_total}.")
  else
    tie!("Both #{session[:player_name]} and the dealer stayed at #{player_total}.")
  end

  erb :game
end

get '/game_over' do
  erb :game_over
end
