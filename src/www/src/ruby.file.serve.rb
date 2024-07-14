
require 'sinatra'

set :port, 4568

set :public_folder, '/apps/jaki.club/build/public'

before do
  cache_control :no_cache
  headers \
    "Pragma"   => "no-cache",
    "Expires" => "0"
end

configure do
  mime_type :mjs, 'application/javascript'
end

get '/frank-says' do
  'Put this in your pipe & smoke it!'
end

