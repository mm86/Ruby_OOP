

class Deck
  SUITS = ['H', 'D', 'S', 'C']
  VALUES = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  attr_reader :deck 

  def initialize
    @deck = SUITS.product(VALUES).shuffle
  end 

  def deal_two_cards
    cards = [] 
    2.times do
      cards << deck.pop 
    end
    cards 
  end

  def compute_total_score(cards)
    values = cards.map { |card| card[1] }

    sum = 0
    values.each do |value|
      if value == "A"
        sum += 11
      elsif value.to_i == 0 # J, Q, K
        sum += 10
      else
        sum += value.to_i
      end
    end

    # correct for Aces
    values.select { |value| value == "A" }.count.times do
      sum -= 10 if sum > 21
    end

    sum 

  end 
end 


class Player
  attr_accessor :cards, :score 
  def initialize
    @score = 0 
  end
 
end 

class Human < Player


end 

class Dealer < Player 

end 


class Game
  attr_reader :human, :dealer, :deck

  def initialize
    @human = Human.new 
    @dealer = Dealer.new
    @deck = Deck.new 
  end

  def play
    display_welcome_message
    deal_cards
    show_initial_cards
    compute_and_display_total_score_cards

  end 

  private 

  def prompt(message) 
    puts "=> #{message}"
  end

  def display_welcome_message
    prompt "Welcome to 21 game"
  end 

  def deal_cards
    human.cards = deck.deal_two_cards
    dealer.cards = deck.deal_two_cards 
  end 

  def show_initial_cards
    prompt "Human cards are #{human.cards}" 
    prompt "Dealer cards are #{dealer.cards}" 
  end

  def compute_and_display_total_score_cards
    compute_total_score_cards 
    display_total_score_cards
  end

  def compute_total_score_cards
    human.score = deck.compute_total_score(human.cards)
    dealer.score = deck.compute_total_score(dealer.cards)
  end 

  def display_total_score_cards
    prompt "Human score is #{human.score}"
    prompt "Dealer score is #{dealer.score}" 
  end

end 

Game.new.play