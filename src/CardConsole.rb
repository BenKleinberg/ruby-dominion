#!/usr/bin/env ruby

class Card
	attr_reader :icon
	attr_reader :text
	
	def initCon(icon, text)
		@icon = icon
		@text = text
	end
	
	def printCard
		puts "(#{@cost}) #{@name}"
		puts "#{self.class}"
		puts "#{@text}"
	end
end


##
## Wrapper for card class to make each card in game a unique instance
##
class Cardw
	attr_accessor :card
	
	def initialize(card, free = false)
		@card = card
		card.take unless free
	end
end