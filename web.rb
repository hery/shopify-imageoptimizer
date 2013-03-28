# app.rb

require 'sinatra'
require 'liquid'
require 'net/http'
require 'uri'
require 'omniauth-shopify'
require 'httparty'

use Rack::Session::Cookie
use OmniAuth::Strategies::Shopify, ENV['SHOPIFY_KEY'], ENV['SHOPIFY_SECRET']

get '/' do
  liquid :index
end

get '/auth/shopify/callback' do
  content_type 'text/plain'
  request.env['omniauth.auth'].inspect
end
