# app.rb

require 'sinatra'
require 'liquid'
require 'net/http'
require 'uri'
require 'httparty'
require 'json'

use Rack::Session::Cookie

#get '/' do
#  liquid :index
#end

get '/' do
  # Initiate authentication
  redirect "https://pandashop.myshopify.com/admin/oauth/authorize?"\
           "client_id=8ba097d4d5e099c1deb61184b8a6dce5&"\
           "scope=write_products&"\
           "redirect_uri=http://localhost:5000/callback"
end

get '/callback' do
  # Request to exchange temporary token
  code = params[:code]
  client_id = ENV['SHOPIFY_KEY']
  client_secret= ENV['SHOPIFY_SECRET']

  permanent_token_request = HTTParty.post("https://pandashop.myshopify.com/"\
                                          "admin/oauth/access_token",
                      :query => { 'client_id' => client_id, 
                                  'client_secret' => client_secret,
                                  'code' => code 
                                }
                     )

  permanent_token_json_res = JSON.parse(permanent_token_request.body)                     
  permanent_token = permanent_token_json_res["access_token"]

  # Use permanent token to get products list
  product_request = HTTParty.get("https://pandashop.myshopify.com/admin/products.json",
                                 :headers => { "X-Shopify-Access-Token" => permanent_token }
                                )
  product_json = JSON.parse(product_request.body)
  products = product_json["products"] # array of products
  liquid :index, :locals => { :products => products }
end
