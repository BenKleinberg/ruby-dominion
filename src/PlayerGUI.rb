#!/usr/bin/env jruby

include Java
import javax.swing.JPanel
import javax.swing.JFrame
import javax.swing.ImageIcon

require_relative 'Player.rb'
require_relative 'CardGUI.rb'



class Player
	
	def renewPanel
		@panel = JPanel.new unless @panel
		
		# Clear panel and fill with cards in hand
		@panel.removeAll
		@hand.each do |cardw|
			@panel.add cardw
		end
		@panel.validate
		
		return @panel
	end
	
	def panel
		if @panel
			return @panel
		else
			return renewPanel
		end
	end
end


if __FILE__ == $0
	frame = JFrame.new "Card Test"
	player = Player.new("Test Player")
	frame.getContentPane.add player.renewPanel
		
	list = Cardlist.new
	player.addCard(list.getCard("Copper"), :hand)
	panel = player.renewPanel
	listener = CardClicked.new do |event| 
		panel = event.getSource
		component = panel.getComponentAt(event.getPoint)
		puts component.is_a?(Cardw)
	end
	panel.addMouseListener( listener )
		
	frame.setSize 300, 174
	frame.setDefaultCloseOperation JFrame::EXIT_ON_CLOSE
	frame.setLocationRelativeTo nil
	frame.setVisible true
	
	#player.addCard(list.getCard("Copper"), :hand)
	#player.panel
	#frame.validate
	
end