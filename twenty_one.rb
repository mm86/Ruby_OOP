require 'pry'

module Message
  def prompt(message)
    puts "=> #{message}"
  end
end

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

  def deal_one_card
    deck.pop
  end

  def compute_score(cards)
    values = cards.map { |card| card[1] }

    sum = 0
    values.each do |value|
      sum += if value == "A"
               11
             elsif value.to_i == 0 # J, Q, K
               10
             else
               value.to_i
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
  include Message
  attr_accessor :cards, :score, :status, :name
  def initialize
    @score = 0
    @cards = []
  end

  def busted?
    score > 21
  end

  def set_name
    answer = nil
    loop do
      prompt "What is your name?"
      answer = gets.chomp 
      break if !answer.empty? && answer !~ /\A\s*\z/
      prompt "Please enter a valid name"
    end 
    self.name = answer
  end
end

class Game
  include Message
  DEALER_MAX_SCORE_LIMIT = 17
  attr_reader :human, :dealer, :deck
  attr_accessor :current_player

  def initialize
    @human = Player.new
    @dealer = Player.new
    @deck = Deck.new
    @current_player = @dealer
    set_names
  end

  def set_names
    human.set_name
    @dealer.name = "Dealer"
  end

  def play
    display_welcome_message
    deal_cards
    show_initial_cards
    loop do
      self.current_player = alternate_player(current_player)
      current_player_turn
      break if current_player.busted? || both_players_stay?
    end
    display_winner
    display_goodbye_message
  end

  private

  def display_welcome_message
    prompt "Welcome to 21 Game"
  end

  def deal_cards
    human.cards = deck.deal_two_cards
    dealer.cards = deck.deal_two_cards
  end

  def show_initial_cards
    prompt "#{human.name} cards are #{human.cards[0]} and #{human.cards[1]}. " \
           "#{human.name} score is #{deck.compute_score(human.cards)}"
    prompt "Dealer cards are #{dealer.cards[0]} and ?"
  end

  def alternate_player(player)
    if player.equal?(dealer)
      human
    else
      dealer
    end
  end

  def current_player_turn
    human_turn if current_player.equal?(human)
    dealer_turn if current_player.equal?(dealer)
  end

  def update_current_player_score
    self.current_player.score = deck.compute_score(current_player.cards)
  end

  def display_cards_and_scores
    prompt "#{current_player.name} cards are #{current_player.cards}"
    prompt "#{current_player.name} score is #{current_player.score}"
  end

  def display_cards_update_score
    update_current_player_score
    display_cards_and_scores
  end

  def valid_response?(answer)
    %w[h s hit stay Hit Stay H S].include?(answer) &&
      answer !~ /\A\s*\z/ &&
      !answer.empty?
  end

  def ask_human_hit_or_stay
    answer = nil
    loop do
      prompt "Would you like to hit or stay?"
      answer = gets.chomp
      break if valid_response?(answer)
      prompt "Please enter a valid choice"
    end
    human.status = answer
  end

  def human_chose_hit?
    %w[h hit Hit H].include?(human.status)
  end

  def human_chose_stay?
    %w[s stay Stay S].include?(human.status)
  end

  def human_turn
    prompt "#{human.name}'s turn .........."
    loop do
      ask_human_hit_or_stay
      if human_chose_hit?
        prompt "Human chooses to hit ........."
        human.cards << deck.deal_one_card
        display_cards_update_score
        break if human.busted?
      else
        prompt "#{human.name} chooses to stay"
        break
      end
    end
  end

  def dealer_busts_or_stays?
    return true if dealer.busted?
    if dealer.score >= DEALER_MAX_SCORE_LIMIT
      prompt "Dealer chooses to stay"
      current_player.status = 'stay'
      true
    end
  end

  def dealer_turn
    prompt "Dealer's turn .........."
    display_cards_update_score
    loop do
      prompt "Dealer hits .........."
      dealer.cards << deck.deal_one_card
      display_cards_update_score
      break if dealer_busts_or_stays?
    end
  end

  def both_players_stay?
    %w[s stay Stay S].include?(human.status) &&
      %w[s stay Stay S].include?(dealer.status)
  end

  def display_winner_details1
    if human.score > dealer.score
      prompt "#{human.name} won. Dealer lost."
    elsif dealer.score > human.score
      prompt "Dealer won. #{human.name} lost."
    else
      prompt "Its a tie."
    end
  end

  def display_winner_details2
    if human.busted?
      prompt "#{human.name} busted. Dealer won"
    else
      prompt "Dealer busted. #{human.name} won"
    end
  end

  def display_winner
    prompt "-------------WINNER IS-----------------"
    display_winner_details1 if both_players_stay?
    display_winner_details2 if current_player.busted?
    prompt "-------------THE END-------------------"
  end

  def display_goodbye_message
    prompt "Thanks for playing Twenty-One game"
  end
end

Game.new.play
