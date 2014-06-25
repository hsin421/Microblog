require 'sinatra'
require 'sinatra/activerecord'
require './model'
require 'bundler/setup'
require 'rack-flash'
require 'paperclip'
require 'datamapper'
require 'dm-paperclip'

enable :sessions
use Rack::Flash
set :sessions => true

set :database, "sqlite3:microblog.sqlite3"
DataMapper::setup(:default, "sqlite3:microblog.sqlite3")


get '/' do
	erb :index
end

get '/profile' do
	erb :profile
end

get '/sign_up' do
	erb :sign_up
end

#This part is for images/files upload from paperclip and datamapper gems
#should do "gem install data_mapper" and "gem install paperclip" & "gem install dm-paperclip"

def make_paperclip_mash(file_hash)
  mash = Mash.new
  mash['tempfile'] = file_hash[:tempfile]
  mash['filename'] = file_hash[:filename]
  mash['content_type'] = file_hash[:type]
  mash['size'] = file_hash[:tempfile].size
  mash
end

post '/upload' do
  halt 409, "File seems to be emtpy" unless params[:file][:tempfile].size > 0
  @resource = Resource.new(:file => make_paperclip_mash(params[:file]))
  halt 409, flash[:error]="There were some errors processing your request...\n#{resource.errors.inspect}" unless @resource.save
 
  erb :upload
end
 
get '/' do
  erb :index
end

#Above == Paperclip/datamapper uploader


