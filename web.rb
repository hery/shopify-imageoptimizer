# app.rb

require 'sinatra'
require 'liquid'
require 'net/http'
require 'uri'
require 'httparty'
require 'json'

use Rack::Session::Cookie

get '/' do
  liquid :index
end

get '/auth' do
  redirect "https://pandashop.myshopify.com/admin/oauth/authorize?client_id=8ba097d4d5e099c1deb61184b8a6dce5&scope=write_products&redirect_uri=http://localhost:5000/auth/callback"
end

get '/auth/callback' do
  code = params[:code]
  client_id = ENV['SHOPIFY_KEY']
  client_secret= ENV['SHOPIFY_SECRET']
  uri_string = "https://pandashop.myshopify.com/admin/oauth/access_token"
  uri = URI(uri_string)
  res = Net::HTTP.post_form(uri, 'client_id' => client_id, 'client_secret' => client_secret, 'code' => code)
  json_res = JSON.parse(res.body)
  permanent_token = json_res["access_token"]
  p permanent_token 
end

