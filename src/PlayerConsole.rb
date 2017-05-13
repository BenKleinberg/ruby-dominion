#!/usr/bin/env ruby

require_relative 'CardConsole.rb'

class Player
	
	def printHand(mark = nil)
		# Print hand in symbolic form
		print "Hand: "
		@hand.each do |cardw|
			print " #{cardw.card.icon}"
		end
		puts
		# Print hand in list form, with an * before each marked card
		@hand.each_with_index do |cardw, index|
			print "*" if mark and mark.include?(cardw)
			puts "(#{index + 1}) #{cardw.card.name}"
		end
	end

	def debugPrintHand
		# Print hand in symbolic form
		print "Hand: "
		@hand.each do |cardw|
			print " #{cardw.card.icon}"
		end
		puts
	end

	def debugPrintLibrary
		# Print library in symbolic form
		print "Library: "
		@library.each do |cardw|
			print " #{cardw.card.icon}"
		end
		puts
	end

	def debugPrintDiscard
		# Print discard in symbolic form
		print "Discard: "
		@discard.each do |cardw|
			print " #{cardw.card.icon}"
		end
		puts
	end

end