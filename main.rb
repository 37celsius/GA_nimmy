require 'sinatra'
require 'sinatra/reloader'
# For database
require 'active_record'
# HTTParty
require 'httparty'
# Pretty up the URL Address
require 'uri'

require 'pry'
# Close the Database so we will not lost the connection

require_relative 'config'
require_relative 'nameData'

# binding.pry

after do
	ActiveRecord::Base.connection.close
end

get '/' do

	@name_data = NameData.all

	if @name_data

		@name_data = name_data.find_by name: params[:SearchName]
	end

	erb :index

end

get '/name' do

	data_table = NameData.all
	# data_table_row = 

	@result = NameData.find_by(name: params[:SearchName])

	if !@result
		# not found,  save
		name = "https://gender-api.com/get?name=#{params[:SearchName]}&key=DsEvdqGvUAcfgdvkej"

		@result = HTTParty.get( URI.escape(name) )

		data = NameData.new
		data.name = @result['name']
		data.gender = @result['gender']
		data.total = @result['samples']
		data.save

	end 


	# binding.pry




	# redirect to '/'

	erb :name
end





