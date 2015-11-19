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

  def show_card(cards)

  end
end
get '/' do
  if session[:player_name]
    redirect '/game'
  else
    redirect '/set_name'
  end
end

get '/set_name' do
  erb :set_name
end

post '/set_name' do
  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/bet' do

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
