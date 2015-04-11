require 'mongoid'
require 'mongoid/enum'

class Card
	include Mongoid::Document
	include Mongoid::Enum

	field :content, type: String
	validates_presence_of :content
	validates_length_of :content, minimum: 1

	field :image, type: String
	
	field :sequence_number, type: Integer
	validates_presence_of :sequence_number
	validates :sequence_number, numericality: { greater_than_or_equal_to: 0, only_integer: true }

	enum :category, [:general, :link, :mission, :cargo, :science, :rocket, :spacecraft, :organization, :mission_event], default: :general

	field :published_time, type: DateTime
	validates_presence_of :published_time
end