#!/usr/bin/env jruby

include Java
import javax.swing.ImageIcon
import javax.swing.JLabel
import javax.swing.JFrame
import javax.swing.JPanel
import java.awt.event.MouseAdapter
import java.awt.event.MouseEvent

require_relative 'Card.rb'


##
## Wrapper for card class to make each card in game a unique instance
##
class Cardw < JLabel
	attr_accessor :card
	
	def initialize(card, free = false)
		super("")
		@card = card
		@card.take unless free
		
		setIcon @card.image
		setBounds(20, 20, @card.image.getIconWidth + 10, @card.image.getIconHeight + 10)
	end
end


##
## Card class to represent each available card
##
class Card
	attr_reader :image
	attr_reader :imageLarge
	@@path = "images/"
	
	def loadImage
		path = @@path + @name.downcase
		path.gsub!(/\s+/, "")
		@image = ImageIcon.new(path + ".jpg")
		@imageLarge = ImageIcon.new(path + "_large.jpg")
	end
end


if __FILE__ == $0
	frame = JFrame.new "Card Test"
	panel = JPanel.new
	frame.getContentPane.add panel
	
	#list = Cardlist.new
	
	copperlabel = JLabel.new("")
	copperlabel.setIcon ImageIcon.new("images/copper_small.jpg")
	panel.add copperlabel
	copper = Treasure.new("Copper", 0, 60, 1)
	copper.loadImage("/images/copper_small.jpg")
	copper1 = Cardw.new copper
	panel.add copper1
	panel.validate
	
	frame.setSize 300, 174
	frame.setDefaultCloseOperation JFrame::EXIT_ON_CLOSE
	frame.setLocationRelativeTo nil
	frame.setVisible true
		
end