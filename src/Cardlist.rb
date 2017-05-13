#!/usr/bin/env ruby

class Cardlist
	attr_reader :supply
	attr_reader :kingdom
	attr_reader :back
	
	##
	## Setup Methods
	##
	def initialize
		# Load the default cards
		@supply = Array.new
		supplyInitialize
		@kingdom = Array.new
		kingdomInitialize
		
		@back = Card.new("Back", 0, 0, :trash)
		@back.loadImage if @back.respond_to? "loadImage"
	end
	
	def addKingdom(kingdom)
		@kingdom += kingdom
	end

	
	##
	## Helper Methods
	## 
	def getCard(name)
		# Find a card by a given name
		@supply.each do |card|
			return card if card.name == name
		end
		@kingdom.each do |card|
			return card if card.name == name
		end
		
		return nil
	end

	def kingdomSelect(count = 10)
		# Pick a given number of kingdom cards for the game
		kingdom = @kingdom.shuffle
		@kingdom.clear

		count.times do
			card = kingdom.pop
			@kingdom << card if card
		end
		
		@kingdom.sort!
	end
	
	
	##
	## Initialize supply with base set cards
	##
	def supplyInitialize
		#Treasure cards
		text = "Gain 1 coin."
		card = Treasure.new("Copper", 0, 60, 1)
		card.initCon("C", text) if card.respond_to? "initCon"
		card.loadImage if card.respond_to? "loadImage"
		@supply<< card

		text = "Gain 2 coins."
		card = Treasure.new("Silver", 3, 40, 2)
		card.initCon("S", text) if card.respond_to? "initCon"
		card.loadImage if card.respond_to? "loadImage"
		@supply<< card

		text = "Gain 3 coins."
		card = Treasure.new("Gold", 6, 30, 3)
		card.initCon("G", text) if card.respond_to? "initCon"
		card.loadImage if card.respond_to? "loadImage"
		@supply<< card

		#Victory cards
		text = "Worth 1 victory point."
		card = Victory.new("Estate", 2, 1)
		card.initCon("E", text) if card.respond_to? "initCon"
		card.loadImage if card.respond_to? "loadImage"
		@supply<< card

		text = "Worth 3 victory points."
		card = Victory.new("Duchy", 5, 3)
		card.initCon("D", text) if card.respond_to? "initCon"
		card.loadImage if card.respond_to? "loadImage"
		@supply<< card

		text = "Worth 6 victory points."
		card = Victory.new("Province", 8, 6)
		card.initCon("P", text) if card.respond_to? "initCon"
		card.loadImage if card.respond_to? "loadImage"
		@supply<< card

		#Curse cards
		text = "Worth -1 victory point."
		card = Curse.new("Curse", 0, 10, 1)
		card.initCon("U", text) if card.respond_to? "initCon"
		card.loadImage if card.respond_to? "loadImage"
		@supply<< card
	end
	
	
	##
	## Initialize kingdom with base set cards
	##
	def kingdomInitialize
		#Action cards
		text = "Gain 1 card. Gain 2 actions."
		card = Action.new("Village", 3)
		card.initCon("V", text) if card.respond_to? "initCon"
		card.loadImage if card.respond_to? "loadImage"
		def card.play(board)
			board.drawCards 1
			board.addActions 2
		end
		@kingdom<< card

		text = "Gain 1 buy. Gain 2 coins."
		card = Action.new("Woodcutter", 3)
		card.initCon("W", text) if card.respond_to? "initCon"
		card.loadImage if card.respond_to? "loadImage"
		def card.play(board)
			board.addBuys 1
			board.addCoins 2
		end
		@kingdom<< card

		text = "Draw 3 cards."
		card = Action.new("Smithy", 4)
		card.initCon("Y", text) if card.respond_to? "initCon"
		card.loadImage if card.respond_to? "loadImage"
		def card.play(board)
			board.drawCards 3
		end
		@kingdom<< card

		text = "Gain 2 actions. Gain 1 buy. Gain 2 coins."
		card = Action.new("Festival", 5)
		card.initCon("F", text) if card.respond_to? "initCon"
		card.loadImage if card.respond_to? "loadImage"
		def card.play(board)
			board.addActions 2
			board.addBuys 1
			board.addCoins 2
		end
		@kingdom<< card

		text = "Draw 2 cards. Gain 1 action."
		card = Action.new("Laboratory", 5)
		card.initCon("L", text) if card.respond_to? "initCon"
		card.loadImage if card.respond_to? "loadImage"
		def card.play(board)
			board.drawCards 2
			board.addActions 1
		end
		@kingdom<< card

		text = "Draw 1 card. Gain 1 action. Gain 1 buy. Gain 1 coin."
		card = Action.new("Market", 5)
		card.initCon("M", text) if card.respond_to? "initCon"
		card.loadImage if card.respond_to? "loadImage"
		def card.play(board)
			board.drawCards 1
			board.addActions 1
			board.addBuys 1
			board.addCoins 1
		end
		@kingdom<< card

		text = "Trash up to 4 cards from your hand."
		card = Action.new("Chapel", 2)
		card.initCon("A", text) if card.respond_to? "initCon"
		card.loadImage if card.respond_to? "loadImage"
		def card.play(board)
			callback = Proc.new { |list| board.discardCards(list, :trash) if list.any? }
			board.selectCards(callback, "Trash up to 4 cards from your hand.", 4)
		end
		@kingdom<< card

		text = "Gain 1 action. Discard any number of cards. Gain 1 card per card discarded."
		card = Action.new("Cellar", 2)
		card.initCon("*", text) if card.respond_to? "initCon"
		card.loadImage if card.respond_to? "loadImage"
		def card.play(board)
			board.addActions 1
			callback = Proc.new do |list|
				if list.any?
					board.discardCards list
					board.drawCards list.size
				end
			end
			board.selectCards(callback, "Discard any number of cards. Gain 1 card per card discarded.")
		end
		@kingdom<< card

		text = "Trash a Copper card in your hand. If you do, gain 3 coins."
		card = Action.new("Moneylender" , 4)
		card.initCon("O", text) if card.respond_to? "initCon"
		card.loadImage if card.respond_to? "loadImage"
		def card.play(board)
			callback = Proc.new do |list|
				if list.any?
					board.discardCards list, :trash
					board.addCoins 3
				end
			end
			board.selectCards(callback, "Trash a Copper card in your hand. If you do, gain 3 coins.", 1) { |cardSelected| cardSelected.name == "Copper" }
		end
		@kingdom<< card

		text = "Gain a card costing up to 4 coins"
		card = Action.new("Workshop", 3)
		card.initCon("K", text) if card.respond_to? "initCon"
		card.loadImage if card.respond_to? "loadImage"
		def card.play(board)
			board.buyMenu("Gain a card costing up to 4 coins.", true) { |cardSelected| cardSelected.cost <= 4 }
		end
		@kingdom<< card
		
		text = "Trash this card. Gain a card costing up to 5 coins."
		card = Action.new("Feast", 4, :trash)
		card.initCon("T", text) if card.respond_to? "initCon"
		card.loadImage if card.respond_to? "loadImage"
		def card.play(board)
			board.buyMenu("Gain a card costing up to 5 coins.", true) { |cardSelected| cardSelected.cost <= 5 }
		end
		@kingdom<< card
		
		text = "Draw 2 cards. Each other player gains a Curse card."
		card = Attack.new("Witch", 5)
		card.initCon("I", text) if card.respond_to? "initCon"
		card.loadImage if card.respond_to? "loadImage"
		def card.play(board)
			board.drawCards(2)
		end
		def card.attack(board)
			board.addCard(board.getCard("Curse"), :discard, :passive)
		end
		@kingdom<< card
		
		text = "Draw 4 cards. Gain 1 buy. Each other player draws a card."
		card = Action.new("Council Room", 5)
		card.initCon("@", text) if card.respond_to? "initCon"
		card.loadImage if card.respond_to? "loadImage"
		def card.play(board)
			board.drawCards(4)
			board.addBuys(1)
			board.drawCards(1, :passive)
		end
		@kingdom<< card
		
		text = "Trash a Treasure card from your hand. Gain a Treasure card costing up to 3 coins more; put it into your hand."
		card = Action.new("Mine", 5)
		card.initCon("$", text) if card.respond_to? "initCon"
		card.loadImage if card.respond_to? "loadImage"
		def card.play(board)
			callback = Proc.new do |list|
				if list.any?
					board.discardCards(list, :trash)
					maxCost = list[0].card.cost + 3
					board.buyMenu("Gain a treasure card costing up to #{maxCost} coins.", true, :hand) { |cardSelected| cardSelected.cost <= maxCost }
				end
			end
			board.selectCards(callback, "Trash a Treasure card from your hand.", 1) { |cardSelected| cardSelected.is_a? Treasure }
		end
		@kingdom<< card
		
		text = "Draw 2 cards. While this card is in your hand, you are unaffected by Attack cards."
		card = Reaction.new("Moat", 2)
		card.initCon("~", text) if card.respond_to? "initCon"
		card.loadImage if card.respond_to? "loadImage"
		def card.play(board)
			board.drawCards(2)
		end
		@kingdom<< card
		
		text = "Trash a card in your hand. Gain a card costing up to 2 coins more than the trashed card."
		card = Action.new("Remodel", 4)
		card.initCon("R", text) if card.respond_to? "initCon"
		card.loadImage if card.respond_to? "loadImage"
		def card.play(board)
			callback = Proc.new do |list|
				if(list.any?)
					board.discardCards(list, :trash)
					maxCost = list[0].card.cost + 2
					board.buyMenu("Gain a card costing up to #{maxCost} coins.", true) { |cardSelected| cardSelected.cost <= maxCost }
				end
			end
			board.selectCards(callback, "Trash a card in your hand.", 1)
			
		end
		@kingdom<< card
	end

end


if __FILE__ == $0

end
