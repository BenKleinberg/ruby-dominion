#!/usr/bin/env ruby


require_relative 'Card.rb'


class Player
	attr_reader :name
	
	def initialize(name)
		@name = name
		@library = Array.new
		@discard = Array.new
		@hand = Array.new
		@played = Array.new
	end
	
	##
	## Hand Manipulation Methods
	##

	def drawCard
		# If library is empty, shuffle discard into library
		if @library.size == 0
			@library, @discard = @discard, @library
			@library.shuffle!
		end
		
		# Put the top card of the library into player's hand if it exists
		cardDrawn = @library.pop
		@hand << cardDrawn if cardDrawn
	end

	def addCard(card, location = :discard)
		# Add the given card into the proper location
		case location
		when :init
			@discard << Cardw.new(card, true)
		when :discard
			@discard << Cardw.new(card)
		when :hand
			@hand << Cardw.new(card)
		end
	end

	def endTurn
		# Put the player's hand and cards played into the discard pile
		@discard += @hand
		@hand.clear
		@discard += @played
		@played.clear

		5.times do
			drawCard
		end
	end

	def play(cardw)
		@hand.delete(cardw)
		location = cardw.card.location
		case location
		when :played
			@played << cardw
		when :discard
			@discard << cardw
		end
	end

	def discard(cards, location = :discard)
		# Select proper location
		case location
		when :discard
			pile = @discard
		when :trash
			pile = nil
		end
		
		# Move cards at each given index to the selected location
		if(cards.respond_to? "each")
			cards.each do |cardw|
				@hand.delete(cardw)
				pile<< cardw if pile
			end
		else
			@hand.delete(cards)
			pile<< cards if pile
		end
	end
	
	
	##
	## Inquiry Methods
	##
	def getCard(num)
		return @hand[num - 1]
	end
		
	def coins
		# Add up total coins for player's hand
		total = 0
		@hand.each do |cardw|
			total += cardw.card.coins if cardw.card.respond_to? "coins"
		end

		return total
	end

	def victory
		total = 0

		# Value in hand
		@hand.each do |cardw|
			total += cardw.card.victory if cardw.card.respond_to? "victory"
		end
		# Value in library
		@library.each do |cardw|
			total += cardw.card.victory if cardw.card.respond_to? "victory"
		end
		# Value in discard
		@discard.each do |cardw|
			total += cardw.card.victory if cardw.card.respond_to? "victory"
		end

		return total
	end

	def handSize
		return @hand.size
	end
	
	def hasCard(card)
		@hand.each do |cardw|
			return true if cardw.card == card
		end
		
		return false
	end
end


if __FILE__ == $0

end
