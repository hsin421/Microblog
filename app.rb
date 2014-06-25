require 'sinatra'
require 'sinatra/activerecord'
require './model'
require 'bundler/setup'
require 'rack-flash'
enable :sessions
use Rack::Flash, :sweep => true
set :sessions => true

set :database, "sqlite3:microblog.sqlite3"