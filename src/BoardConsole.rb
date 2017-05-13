#!/usr/bin/env ruby

require_relative 'Board.rb'
require_relative 'PlayerConsole.rb'
require_relative 'Cardlist.rb'

class Board
	def startGame
		# Continue game until 3 piles have been emptied, or province pile is emptied
		while @emptyPiles < 3
			resetStatus
			playerTurn
			@active, @passive = @passive, @active
		end
		printWinner
	end
	
	
	##
	## Helper Methods
	##
	def printBoard
		Gem.win_platform? ? (system "cls") : (system "clear")
		puts "Debug mode enabled" if $DEBUG
		puts "#{@active.name}"
		print "Actions: #{@actions}"
		print "\tBuys: #{@buys}"
		print "\t\tCoins: #{@coins}"
		puts
		printShop
		puts
		if $DEBUG
			@active.debugPrintLibrary
			@active.debugPrintDiscard
		end
		puts
	end
	
	def printShop
		# Display the supply cards symbolically
		@cardlist.supply.each_with_index do |card, index|
			puts if index % 3 == 0
			print "#{card.icon} (#{card.cost})\t"
		end
		puts
		# Display the kingdom cards symbolically
		@cardlist.kingdom.each_with_index do |card, index|
			puts if index % 3 == 0
			print "#{card.icon} (#{card.cost})\t"
		end
		puts
	end
	
	def printShopMenu
		# Print the supply card list
		@cardlist.supply.each_with_index do |card, index|
			puts "(#{index + 1}) #{card.name} (#{card.cost} coins, #{card.count} remaining)"
		end
		size = @cardlist.supply.size
		# Print the kingdom card list
		@cardlist.kingdom.each_with_index do |card, index|
			puts "(#{index + size + 1}) #{card.name} (#{card.cost} coins, #{card.count} remaining)"
		end
		size += @cardlist.kingdom.size
			
		return size
	end
	
	def printWinner
		Gem.win_platform? ? (system "cls") : (system "clear")
		active = @active.victory
		passive = @passive.victory
		if(active > passive)
			puts "#{@active.name} wins with #{active} victory points!"
		elsif(passive < active)
			puts "#{@passive.name} wins with #{passive} victory points!"
		else
			puts "It's a tie with #{active} victory points!"
		end
		
		if $DEBUG
			puts 
			puts "{@active.name}"
			@active.debugPrintHand()
			@active.debugPrintLibrary()
			@active.debugPrintDiscard()
			puts "{@passive.name}"
			@active.debugPrintHand()
			@active.debugPrintLibrary()
			@active.debugPrintDiscard()
		end
		gets
	end
	
	def makeName
		print "Enter player name: "
		name = gets.chomp
		return name
	end
	
	
	##
	## Card Interface Methods
	##
	def selectCards(callback, text, max = nil, player = :active)
		# Select the correct player
		player = getPlayer(player)
			
		continue = true
		size = player.handSize
		list = Array.new
		count = 0
		while continue
			# Print board and hand
			printBoard
			player.printHand(list)
			puts text
			puts "(D) Done"
			print "Enter Selection: "
			input = gets.chomp.downcase
			numInput = input.to_i
	
			if(input == 'd')
				continue = false
			elsif(numInput > 0 and numInput <= size)
				cardw = player.getCard(numInput)
				# Validate card selection
				valid = block_given? ? yield(cardw.card) : true
						
				if(!valid)
					puts "Select a valid card."
					gets
				elsif(list.include?(cardw))
					# Remove card from the list if it is already selected
					list.delete(cardw)
					count -= 1
				elsif(!max or count < max)
					# Add card to the list if there is no max or max is not reached
					list<< cardw
					count += 1
				else
					puts "Can only select #{max} maximum cards."
					gets
				end
	
			else
				puts "Invalid input"
				gets
			end
			
			callback.call(list)
		end
	
		return list
	end		

	def buyMenu(text = nil, free = false, location = :discard)
		continue = true
		cardBought = false
		while continue
			printBoard
			puts text if text
			size = printShopMenu
			# Print default options
			puts "(C) Cancel"
			print "Enter Selection: "
			input = gets.chomp.downcase
			numInput = input.to_i
	
			if(input == 'c')
				continue = false
			elsif(numInput > 0 and numInput <= size)
				# Get the card from the appropriate list
				if(numInput <= @cardlist.supply.size)
					card = @cardlist.supply[numInput - 1]
				else
					card = @cardlist.kingdom[numInput - @cardlist.supply.size - 1]
				end
				# Validate card choice
				valid = block_given? ? yield(card) : true
				unless valid
					puts "Select a valid card"
					gets
				end
				cardBought = cardBuyMenu(card, free, location) if valid
				continue = (@buys > 0 and !free) if cardBought
			else
				puts "Invalid input"
				gets
			end
		end
		
		# Return whether a card was successfully bought
		return cardBought
	end
	
	
	##
	## Card Selected Methods
	##
	def cardBuyMenu(card, free, location)
		cardBought = false
		continue = true
		while continue
			# Print board and card
			printBoard
			card.printCard
			puts
			puts "#{card.count} remaining"
			puts "(B) Buy card" if card.remaining?
			puts "(C) Cancel"
			print "Enter Selection: "
			input = gets.chomp.downcase

			if(input == 'b' and card.remaining?)
				if(card.cost <= @coins or free or $DEBUG)
					# If the card is free, it costs no coins and does not use a buy point
					unless free or $DEBUG
						@coins -= card.cost
						@buys -= 1
					end
					addCard(card, location)
					puts "Bought #{card.name}!"
					continue = false
					cardBought = true
				else
					puts "Not enough coins."
				end
				gets
			elsif(input == 'c')
				continue = false
			end
		end

		# Return whether a card was successfully bought
		return cardBought
	end
	
	def cardPlayMenu(cardw)
		card = cardw.card
		continue = true
		while continue
			# Print board and card
			printBoard
			card.printCard
			puts
			puts "(P) Play card" if(card.respond_to? "play")
			puts "(C) Cancel"
			print "Enter Selection: "
			input = gets.chomp.downcase

			if(input == 'p')
				# Leave this menu if the card is successfully played
				continue = false if(playCard(cardw))
			elsif(input == 'c')
				continue = false
			else
				puts "Invalid input"
				gets
			end
		end
	end
	
	
	##
	## Main player turn control
	##
	def playerTurn
		Gem.win_platform? ? (system "cls") : (system "clear")
		puts "#{@active.name}'s turn"
		gets
		continue = true
		while continue
			# Print board and hand
			printBoard
			@active.printHand
			size = @active.handSize
			puts "(B) Buy a card"
			puts "(E) End turn"
			print "Enter Selection: "
			input = gets.chomp.downcase
			numInput = input.to_i

			if(input == 'b')
				# Automatically use treasure cards
				coins = @active.coins
				@coins += coins
				# End the player's turn if they bought at least one card
				continue = !buyMenu
				@coins -= coins
			elsif(input == 'e')
				continue = false
			elsif(numInput > 0 and numInput <= size)
				cardPlayMenu(@active.getCard(numInput))
			else
				puts "Invalid input"
				gets
			end
		end

		@active.endTurn
	end	
	
end

if __FILE__ == $0
	board = Board.new
	board.startGame
end