# app.rb

require 'sinatra'
require 'liquid'

get '/' do
  liquid :index
end

