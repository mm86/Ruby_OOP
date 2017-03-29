

class Deck
  # responsible for creating the deck of cards
  # responsible for dealing unique cards from it's deck every time the method deal_two_cards is called.
  def initialize 
  end 

  def deal_two_cards 
  end 
end 


class Player

 
end 

class Human < Player


end 

class Dealer < Player 

end 


class Game

  def initialize
    @human = Human.new 
    @dealer = Dealer.new 
  end

  def play
    display_welcome_message
    deal_cards
    show_initial_cards

  end 

  private 

  def display_welcome_message
    puts "Welcome to 21 game"
  end 

  def deal_cards 
  end 

  def show_initial_cards 
  end 

 
end 

Game.new.play