require 'rubygems'
require 'sinatra'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'lem30zeW'

get '/' do
    redirect '/set_name' unless session[:player_name]
end

get '/set_name' do
  erb :set_name
end

post '/set_name' do
  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/bet' do
  erb :mytemplate
end

get '/game' do
  erb :game
end
