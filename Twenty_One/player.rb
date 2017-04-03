class Player
  include Display, SetName
  attr_accessor :cards, :total, :status, :name, :score, :deck

  def initialize(deck)
    reset_score
    reset(deck)
  end

  def busted?
    total > TwentyOne::BUSTED_VALUE
  end

  def reset_score
    self.score = 0
  end

  def reset(deck)
    self.deck = deck
    self.total = 0
    self.cards = []
    self.status = 'hit'
  end

  def cards_calc_total
    self.total = deck.compute_total(cards)
  end

  private

  def valid_hit_stay_response?(answer)
    %w[h s hit stay Hit Stay H S].include?(answer) &&
      answer !~ /\A\s*\z/ &&
      !answer.empty?
  end
end

class Human < Player
  def set_name
    ask_user_for_name
  end

  def turn
    prompt "#{name}'s turn .........."
    loop do
      ask_human_hit_or_stay
      if chose_hit?
        prompt "#{name} hits ........."
        cards << deck.deal_card
      else
        prompt "#{name} chooses to stay"
      end
      cards_calc_total
      display_player_cards_and_total_value
      break if busted? || chose_stay?
    end
  end

  def chose_hit?
    %w[h hit Hit H].include?(status)
  end

  def chose_stay?
    %w[s stay Stay S].include?(status)
  end

  private

  def ask_human_hit_or_stay
    answer = nil
    loop do
      prompt "Would you like to hit or stay?"
      answer = gets.chomp
      break if valid_hit_stay_response?(answer)
      prompt "Please enter a valid choice"
    end
    self.status = answer
  end
end

class Dealer < Player
  def set_name
    self.name = ['R2D2', 'AI', 'Echo', 'Siri'].sample
  end

  def turn
    prompt "#{name}'s turn .........."
    loop do
      cards_calc_total
      display_player_cards_and_total_value
      break if dealer_busts_or_stays?
      prompt "#{name} hits ........."
      cards << deck.deal_card
    end
  end

  private

  def dealer_busts_or_stays?
    return true if busted?
    if total >= TwentyOne::DEALER_CARDS_TOTAL_MAX
      prompt "#{name} chooses to stay"
      self.status = 'stay'
      true
    end
  end
end
