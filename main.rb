require 'rubygems'
require 'sinatra'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'lem30zeW'

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
  erb :new_game
end

post '/new_game' do
  if params[:player_name].empty?
    @error = "Please enter your name."
    halt erb(:new_game)
  end

  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/game' do
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

  if player_total > 21
    @error = "#{session[:player_name]} busted!"
    @show_action_buttons = false
  elsif player_total == 21
    @success = ""
  end

  erb :game
end

post '/game/player/stay' do
  @success = "#{session[:player_name]} stays."
  @show_action_buttons = false
  erb :game
end
