class NameData < ActiveRecord::Base
	# This one validating the input field, so user can't submit an empty field
	validates :name, :presence => true
end