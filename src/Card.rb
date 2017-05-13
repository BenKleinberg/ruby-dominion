#!/usr/bin/env ruby


##
## Card class to represent each available card
##
class Card
	attr_reader :name
	attr_reader :cost
	attr_reader :location
	attr_reader :count
	
	def initialize(name, cost, count, location)
		@name = name
		@cost = cost
		@count = count
		@location = location
	end
	
	def <=>(other)
		# Sort by cost first, name second
		result = @cost <=> other.cost
		result = @name <=> other.name if result == 0
		return result
	end
	
	def remaining?
		return @count > 0
	end
	
	def take
		@count -= 1
	end
end


##
## Subclasses
##
class Treasure < Card
	# Treasure cards are worth coins and can be played but don't need to be
	attr_reader :coins
	def initialize(name, cost, count, coins, location = :played)
		super(name, cost, count, location)
		@coins = coins
	end

	def play(board)
		board.addCoins(@coins)
	end
end

class Victory < Card
	# Victory cards are worth victory points and cannot be played
	attr_reader :victory
	def initialize(name, cost, victory, location = :played)
		super(name, cost, 8, location)
		@victory = victory
	end
end

class Curse < Card
	# Curse cards are worth negative victory points and cannot be played
	attr_reader :victory
	def initialize(name, cost, count, victory, location = :played)
		super(name, cost, count, location)
		@victory = -victory
	end
end

class Action < Card
	# Action cards can be played
	def initialize(name, cost, location = :played)
		super(name, cost, 10, location)
	end
end

class Attack < Action
	# Attack actions affect the other players
	def initialize(name, cost, location = :played)
		super(name, cost, location)
	end
end

class Reaction < Action
	# Reaction cards react to other actions
	def initialize(name, cost, location = :played)
		super(name, cost, location)
	end
end


if __FILE__ == $0

end
