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
	erb :index
end

get '/name' do
	if !params[:SearchName].nil? && !params[:SearchName].empty?

		# @name_data = NameData.find_by name: params[:SearchName]


		@result = NameData.find_by(name: params[:SearchName])

		if !@result
			# not found,  save
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

		@charges = @criminal_charge['records'].map {|x| x['charges']}.compact.first(2).join(', ')



	end

	erb :name
end

# get '/' do

# 	if !params[:SearchName].nil? && !params[:SearchName].empty?

# 		# @name_data = NameData.find_by name: params[:SearchName]


# 		@result = NameData.find_by(name: params[:SearchName])

# 		if !@result
# 			# not found,  save
# 			name = "https://gender-api.com/get?name=#{params[:SearchName]}&key=DsEvdqGvUAcfgdvkej"
# 			age = "https://proapi.whitepages.com/2.1/person.json?api_key=4a8f78e11e2770a4a46bffe34a496d53&first_name=#{params[:SearchName]}"
			
# 			@result = HTTParty.get( URI.escape(name) )
# 			@result_age = HTTParty.get( URI.escape(age) )

# 			data = NameData.new
# 			data.name = @result['name']
# 			data.gender = @result['gender']
# 			data.total = @result['samples']
# 			data.min_age = @result_age['results'].map {|data| data['age_range']['start'] if data['age_range'] }.compact.min
# 			data.max_age = @result_age['results'].map {|data| data['age_range']['end'] if data['age_range'] }.compact.max
# 			data.last_name = @result_age['results'].first['names'][0]['last_name']
# 			data.best_name = @result_age['results'].last['best_name']
# 			data.save

# 		end 
# 	end

# 	erb :index

# end

# get '/name' do

# 	data_table = NameData.all
# 	# data_table_row = 

# 	@result = NameData.find_by(name: params[:SearchName])

# 	if !@result
# 		# not found,  save
# 		name = "https://gender-api.com/get?name=#{params[:SearchName]}&key=DsEvdqGvUAcfgdvkej"
# 		age = "https://proapi.whitepages.com/2.1/person.json?api_key=4a8f78e11e2770a4a46bffe34a496d53&name=#{params[:SearchName]}"
		
# 		@result = HTTParty.get( URI.escape(name) )
# 		@result_age = HTTParty.get( URI.escape(age) )

# 		data = NameData.new
# 		data.name = @result['name']
# 		data.gender = @result['gender']
# 		data.total = @result['samples']
# 		data.min_age = @resultdata['results'].map {|data| data['age_range']['start'] if data['age_range'] }.compact.min
# 		data.max_age = @resultdata['results'].map {|data| data['age_range']['end'] if data['age_range'] }.compact.max
# 		data.save

# 	end 


	# binding.pry




	# redirect to '/'

# 	erb :name
# end





