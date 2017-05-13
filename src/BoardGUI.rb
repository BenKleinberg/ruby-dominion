#!/usr/bin/env jruby

include Java
import javax.swing.ImageIcon
import javax.swing.JLabel
import javax.swing.JFrame
import javax.swing.JPanel
import java.awt.event.MouseAdapter
import java.awt.event.MouseEvent
import java.awt.BorderLayout
import java.awt.GridLayout
import javax.swing.JButton
import java.awt.Dimension
import java.awt.GridBagLayout
import java.awt.FlowLayout
import javax.swing.BoxLayout
import java.awt.Font
import javax.swing.JOptionPane
import java.awt.Color
import javax.swing.BorderFactory
import javax.swing.Box

require_relative 'Board.rb'
require_relative 'PlayerGUI.rb'
require_relative 'Cardlist.rb'


##
## Event Handler for Card Clicked
##
class Adapter < MouseAdapter
	def initialize(&block)
		@block = block
	end
	def setBlock(&block)
		@block = block
	end
	def mouseClicked(event)
		@block.call(event) if @block
	end
end


##
## Board Class
##
class Board
	
	def initialize
		resetStatus
		setup
		@phase = :main
		@selected = Array.new
		@active = createPlayer "Player 1"
		@passive = createPlayer "Player 2"
		setupGUI
	end
	
	def setInfoCard cardw
		# Highlight or unhighlight selected card
		if cardw.getBorder
			cardw.setBorder nil
			@infoCard.setIcon @cardlist.back.imageLarge
			@cardSelected = nil
		else
			cardw.setBorder @border
			@infoCard.setIcon cardw.card.imageLarge
			@cardSelected.setBorder nil if @cardSelected
			@cardSelected = cardw
		end
	end
	
	def shopClicked(cardw)
		if @phase == :main or @phase == :buy
			setInfoCard cardw
			resetInfo
			@infoPanel.add @buyButton if @cardSelected
			@buyButton.setText "Buy - (#{cardw.card.count} remaining)" if @cardSelected
		elsif @phase == :selectShop
			valid = @validcheck ? @validcheck.call(cardw.card) : true
			if valid
				setInfoCard cardw
				resetInfo
				@infoPanel.add @selectButton if @cardSelected
			else
				setMessage("Select a valid card.")
			end
		end
	end
	
	def handClicked(cardw)
		if @phase == :main
			setInfoCard cardw
			resetInfo
			@infoPanel.add @playButton if cardw.card.respond_to? "play" and @cardSelected
		elsif @phase == :selectHand
			resetInfo
			@infoPanel.add @selectButton
			if @selected.include? cardw
				@selected.delete cardw
				cardw.setBorder nil
			elsif !@selectMax or @selected.size < @selectMax
				valid = @validcheck ? @validcheck.call(cardw.card) : true
				if valid
					@selected<< cardw
					cardw.setBorder @border
				else
					setMessage("Select a valid card.")
				end
			else
				setMessage "Maximum of #{@selectMax} cards."
			end
		end
	end
	
	def renewStatus
		components = @statusPanel.getComponents
		components[0].setText @phase == :buy ?"Buy Phase" : "Main Phase"
		components[1].setText "Actions: #{@actions}"
		components[2].setText "Buys: #{@buys}"
		components[3].setText "Coins: #{@coins + @active.coins}"
	end
	
	def swapPlayers
		if @emptyPiles >= 3
			winner = @active
			loser = @passive
			if @passive.victory >= @active.victory
				winner = @passive
				loser = @active
			end
			
			showMessage("#{winner.name} wins with #{winner.victory} points to #{loser.victory}")
			@phase = :gameover
		else
			@active.endTurn
			@active, @passive = @passive, @active
			resetStatus
			@frame.remove @passive.panel
			@frame.add @active.panel, BorderLayout::SOUTH
			@frame.setTitle "Dominion in JRuby - #{@active.name}"
			@phase = :main
			resetInfo
			@infoCard.setIcon @cardlist.back.imageLarge
			setMessage("")
			@cardSelected.setBorder nil if @cardSelected
			@cardSelected = nil
			@selected.each do |cardw|
				cardw.setBorder nil
			end
			@selected.clear
			renewGUI
			showMessage "#{@active.name}'s turn!"
		end
	end
	
	def renewGUI
		@active.renewPanel
		renewStatus
		resetInstructions
		@frame.repaint
	end
	
	def renewShop
		components = @shopPanel.getComponents
		
		supply = components[0].getComponents
		components[0].removeAll
		supply.each do |cardw|
			components[0].add cardw if cardw.card.remaining?
		end
			
		kingdom = components[1].getComponents
		components[1].removeAll
		kingdom.each do |cardw|
			components[1].add cardw if cardw.card.remaining?
		end
	end
	
	def resetInfo
		@infoPanel.removeAll
		@infoPanel.add @infoCard
	end
	
	def resetInstructions
		if @phase == :main
			setInstructions("Play or Buy Cards")
		elsif @phase == :buy
			setInstructions("Buy Cards")
		end
	end
	
	def showMessage(text)
		JOptionPane.showMessageDialog(@frame, text)
	end
	
	def setMessage(text)
		@output.setText text
	end
	
	def setInstructions(text)
		@instructions.setText text
	end
	
	def buyCard(card)
		return if card.name == "Back"
			
		coins = @coins + @active.coins
		if coins < card.cost
			setMessage("Not enough coins.")
		else
			addCard(card)
			@coins -= card.cost
			@buys -= 1
			setMessage("#{card.name} bought!")
			@phase = :buy
		end

	end
	
	
	##
	## GUI Setup Methods
	##
	def setupInfo
		# Set up right panel
		@infoPanel = JPanel.new
		@infoPanel.setLayout(BoxLayout.new(@infoPanel, BoxLayout::Y_AXIS))
		@frame.add @infoPanel, BorderLayout::EAST
		
		# Set up large card to display card information
		@infoCard = Cardw.new(@cardlist.back, true)
		image = @infoCard.card.imageLarge
		@infoCard.setIcon image
		@infoCard.setBounds(20, 20, image.getIconWidth, image.getIconHeight)
		@infoPanel.add @infoCard
		@cardSelected = @infoCard
		
		# Buy button
		@buyButton = JButton.new("Buy")
		buyAdapter = Adapter.new do |event|
			buyCard @cardSelected.card
			renewShop if @cardSelected.card.count == 0
			@buyButton.setText "Buy - (#{@cardSelected.card.count} remaining"
			if @buys < 1
				swapPlayers
			end
			renewGUI
		end
		@buyButton.addMouseListener buyAdapter
		
		# Done selecting button
		@selectButton = JButton.new("Done Selecting")
		selectAdapter = Adapter.new do |event|
			if @phase == :selectHand
				@phase = :main
				@callback.call(@selected)
				@selected.each do |cardw|
					cardw.setBorder nil
				end
				resetInfo
			elsif @phase == :selectShop
				@phase = :main
				if @cardSelected
					valid = @validcheck ? @validcheck.call(@cardSelected.card) : true
					addCard(@cardSelected.card, @buyLocation) if valid
					renewShop if @cardSelected.card.count == 0
					setInfoCard @cardSelected
				end
				resetInfo
			end
			renewGUI
		end
		@selectButton.addMouseListener selectAdapter
		
		# Play card button
		@playButton = JButton.new("Play")
		playAdapter = Adapter.new do |event|
			result = playCard(@cardSelected) if @cardSelected.card.respond_to? "play"
			if(result)
				setMessage "#{result.name} played."
				@cardSelected.setBorder nil
				@infoCard.setIcon @cardlist.back.imageLarge
				resetInfo
			else
				setMessage "Not enough actions."
			end
			renewGUI
		end
		@playButton.addMouseListener playAdapter
	end
	
	def setupStatus
		# Set up left panel
		@statusPanel = JPanel.new
		@statusPanel.setLayout(BoxLayout.new(@statusPanel, BoxLayout::Y_AXIS))
		@frame.add @statusPanel, BorderLayout::WEST
		
		# Set up panel to show status
		label = JLabel.new("Main Phase")
		label.setFont @font
		@statusPanel.add label
		label = JLabel.new("Actions:")
		label.setFont @font
		@statusPanel.add label
		label = JLabel.new("Buys:")
		label.setFont @font
		@statusPanel.add label
		label = JLabel.new("Coins:")
		label.setFont @font
		@statusPanel.add label
		
		# Set up label to show output
		@output = JLabel.new("")
		@statusPanel.add @output
		
		# Push button to bottom of the panel
		@statusPanel.add Box.createVerticalGlue
		# Set up button to end turn
		button = JButton.new("End Turn")
		button.setFont @font
		buttonAdapter = Adapter.new do |event|
			swapPlayers
			renewGUI 
		end
		button.addMouseListener buttonAdapter
		@statusPanel.add button
	end
	
	def setupShop
		# Set up shop panel
		@shopPanel = JPanel.new
		@shopPanel.setLayout FlowLayout.new(FlowLayout::CENTER, 20, 5)
		@frame.add(@shopPanel, BorderLayout::CENTER)
		
		# Set up supply panel
		supply = JPanel.new GridLayout.new(3, 3, 2, 2)
		supply.setMaximumSize Dimension.new(80*3, 128*3)
		@cardlist.supply.each do |card|
			supply.add Cardw.new(card, true)
		end
		supply.validate
		@shopPanel.add supply
		
		# Set up kingdom panel
		kingdom = JPanel.new GridLayout.new(3, 3, 2, 2)
		kingdom.setMaximumSize Dimension.new(80*3, 128*3)
		@cardlist.kingdom.each do |card|
			kingdom.add Cardw.new(card, true)
		end
		kingdom.validate
		@shopPanel.add kingdom
		
		# If a card in shop is clicked, zoom on it and react
		shopAdapter = Adapter.new do |event|
			cardw = event.getSource.findComponentAt(event.getPoint)
			shopClicked cardw if cardw.is_a? Cardw
			renewGUI
		end
		@shopPanel.addMouseListener(shopAdapter)
	end
	
	def setupHand
		# Set up mouse event handlers for the player's hand
		handAdapter = Adapter.new do |event|
			cardw = event.getSource.findComponentAt(event.getPoint)
			handClicked cardw if cardw.is_a? Cardw
			renewGUI
		end
		@active.panel.addMouseListener(handAdapter)
		@passive.panel.addMouseListener(handAdapter)
		@frame.add(@active.panel, BorderLayout::SOUTH)
	end
	
	def setupGUI
		@frame = JFrame.new "Dominion in JRuby"
		
		@font = Font.new(nil, Font::BOLD, 20)
		@border = BorderFactory.createLineBorder(Color::RED,3)
		
		setupHand
		setupShop
		setupInfo
		setupStatus
		renewStatus
		
		instructions = JPanel.new
		@instructions = JLabel.new("Instructions")
		resetInstructions
		instructions.add @instructions
		@frame.add(instructions, BorderLayout::NORTH)

		@frame.setTitle "Dominion in JRuby - #{@active.name}"
		@frame.setSize 1000, 700
		@frame.setDefaultCloseOperation JFrame::EXIT_ON_CLOSE
		@frame.setLocationRelativeTo nil
		@frame.setVisible true
		@frame.validate
		end
		
		##
		## Card Interface Methods
		##
		def selectCards(callback, text, max = nil, player = :active, &validCheck)
			@phase = :selectHand
			@selectMax = max
			@selected.clear
			setInstructions(text)
			@callback = callback
			@validcheck = validCheck
			@infoPanel.add @selectButton
		end
		
		def buyMenu(text, free = true, location = :discard, &validCheck)
			@phase = :selectShop
			setInstructions(text)
			@validcheck = validCheck
			@buyLocation = location
			@infoPanel.add @selectButton
		end
end

if __FILE__ == $0
	Board.new
end