#!/usr/bin/env ruby


require_relative 'Player.rb'
require_relative 'Cardlist.rb'

#require_relative 'CardConsole.rb'
#require_relative 'PlayerConsole.rb'
#require_relative 'BoardConsole.rb'


class Board
	##
	## Setup methods
	##
	def initialize()
		Gem.win_platform? ? (system "cls") : (system "clear")
		setup
		name = self.respond_to?("makeName") ? makeName : "Player 1"
		@active = createPlayer name
		name = self.respond_to?("makeName") ? makeName : "Player 2"
		@passive = createPlayer name
	end
	
	def setup
		@cardlist = Cardlist.new
		@cardlist.kingdomSelect 10
		@emptyPiles = 0
	end

	def createPlayer name
		player = Player.new name
		# Start the game with 7 coppers
		copper = @cardlist.getCard "Copper"
		7.times do
			player.addCard copper, :init
		end
		# Start the game with 7 estates
		estate = @cardlist.getCard "Estate"
		3.times do
			player.addCard estate, :init
		end
		# Shuffle and draw 5 cards
		player.endTurn
		return player
	end

	
	##
	## Helper methods
	##
	def resetStatus
		@actions = 1
		@buys = 1
		@coins = 0
	end
	
	def getPlayer(target)
		case target
		when :active
			return @active
		when :passive
			return @passive
		else
			return nil
		end
	end
	
	def getCard(name)
		return @cardlist.getCard(name)
	end

	
	##
	## Play Card Methods
	##
	def playCard(cardw)
		card = cardw.card
		if(card.is_a? Treasure)
			# Treasure cards have no requirements
			@active.play(cardw)
			card.play(self)
			success = card
		elsif(card.is_a? Action)
			# Action cards require and use up one action point
			if(@actions > 0)
				@active.play(cardw)
				card.play(self)
				# Attack cards are negated by moat (should be revealed on use)
				if(card.is_a? Attack)
					card.attack(self) unless @passive.hasCard(@cardlist.getCard("Moat"))
				end
				@actions -= 1
				success = card
			else
				success = nil
			end
		end
		
		# Return whether card was successfully played in the form of the card played
		return success
	end	

	
	##
	## Card Interface Methods
	##
	def addActions(num)
		@actions += num
	end

	def addBuys(num)
		@buys += num
	end

	def addCoins(num)
		@coins += num
	end
	
	def addCard(card, location = :discard, player = :active)
		# Select correct player
		player = getPlayer(player)
		if(card.remaining?)
			player.addCard(card, location) 
			# Modify empty pile counter if the pile ran out
			if(card.count == 0)
				@emptyPiles += 1
				@emptyPiles += 3 if card.name == "Province"
			end		
		end
	end

	def drawCards(num, player = :active)
		# Select correct player
		player = getPlayer(player)
		num.times do
			player.drawCard
		end
	end

	def discardCards(array, location = :discard, player = :active)
		# Select correct player
		player = getPlayer(player)
		player.discard(array, location)
	end

end


if __FILE__ == $0

	board = Board.new
	board.startGame
	

end

