require 'sinatra'
# require 'sinatra/reloader'
# For database
require 'active_record'
# HTTParty
require 'httparty'
# For checking things in terminal
# require 'pry'

# Connect to nameData.erb
require_relative 'nameData'

local_db_settings = {
  :adapter => 'postgresql',
  :username => 'ThirtySevenCelsiusAir', 
  :database => 'nimmy'
}


# Close the Database so we will not lost the connection
after do
	ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || local_db_settings)
end

# Link to the index page
get '/' do
	erb :index
end

# This is where all the actions are
get '/name' do
	if !params[:SearchName].empty?

		# Create an instant variable that can be access anywhere
		# The instant variable finding the name from the user input in our NameData Class which connecting to the nimmy table
		@result = NameData.find_by(name: params[:SearchName])


		if !@result

			name = "https://gender-api.com/get?name=#{params[:SearchName]}&key=DsEvdqGvUAcfgdvkej"
			age = "https://proapi.whitepages.com/2.1/person.json?api_key=4a8f78e11e2770a4a46bffe34a496d53&first_name=#{params[:SearchName]}"


			@result = HTTParty.get( URI.escape(name) )
			@result_age = HTTParty.get( URI.escape(age) )
			
			data = NameData.new
				data.name = @result['name']
				data.gender = @result['gender']
				data.total = @result['samples']
				data.min_age = @result_age['results'].map {|data| data['age_range']['start'] if data['age_range'] }.compact.min
				data.max_age = @result_age['results'].map {|data| data['age_range']['end'] if data['age_range'] }.compact.min
				data.last_name = @result_age['results'].first['names'][0]['last_name']
				data.best_name = @result_age['results'].last['best_name']
			data.save

			@result['min_age'] = data.min_age
			@result['max_age'] = data.max_age
			@result['best_name'] = data.best_name

			# Save to variable so we can use it
			@result['last_name'] = data.last_name

		end 

		criminal = "http://www.jailbase.com/api/1/search/?source_id=az-mcso&last_name=#{ @result['last_name']}"  
		@criminal_charge = HTTParty.get( URI.escape(criminal))
		@charges = @criminal_charge['records'].map {|x| x['charges']}.compact.first(2).flatten
		# binding.pry
	end

	erb :name
end

get '/about' do
	erb :about
end

get '/privacypolicy' do
  erb :privacypolicy
end

get '/termsconditions' do
  erb :termsconditions
end



