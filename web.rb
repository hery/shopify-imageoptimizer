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
#
configure do 
  set :shop_name, ''
  set :client_id, ENV['SHOPIFY_KEY']
  set :client_secret, ENV['SHOPIFY_SECRET']
  set :permanent_token, ''
end

get '/' do
  if (settings.shop_name == '')
    liquid :index
  else
    # Initiate authentication
    redirect "https://#{settings.shop_name}.myshopify.com/admin/oauth/authorize?"\
             "client_id=#{settings.client_id}&"\
             "scope=write_products&"\
             "redirect_uri=http://localhost:5000/callback"
  end
end

post '/' do
  set :shop_name, params['shopName']
  redirect "/"
end

get '/callback' do
  # Request to exchange temporary token
  code = params[:code]
  permanent_token_request = HTTParty.post("https://#{settings.shop_name}.myshopify.com/"\
                                          "admin/oauth/access_token",
                      :query => { 'client_id' => settings.client_id, 
                                  'client_secret' => settings.client_secret,
                                  'code' => code })

  permanent_token_json_res = JSON.parse(permanent_token_request.body)                     
  set :permanent_token, permanent_token_json_res["access_token"]

  # Use permanent token to get products list
  product_request = HTTParty.get("https://#{settings.shop_name}.myshopify.com/admin/"\
                                  "products.json",
                                 :headers => { "X-Shopify-Access-Token" => settings.permanent_token }
                                )
  product_json = JSON.parse(product_request.body)
  products = product_json["products"] # array of products
  liquid :index, :locals => { :products => products }
end

post '/updateProduct' do
  new_alt = params['alt-tag']
  product_id = params['product_id']
  product_hash = { :product => { "title" => new_alt } }
  product_json = product_hash.to_json
  p product_json
  update_req = HTTParty.put("https://#{settings.shop_name}.myshopify.com/"\
               "admin/products/#{product_id}.json", 
                  :body => product_hash,
                  :headers => { "X-Shopify-Access-Token" => settings.permanent_token })
  redirect "/"
end
