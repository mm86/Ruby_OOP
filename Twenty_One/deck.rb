class Deck
  ACE_VALUE = 11
  CARDS_JQK_VALUE = 10
  ACE_ADJUSTMENT_VALUE = 10
  SUITS = ['H', 'D', 'S', 'C']
  VALUES = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  attr_reader :deck

  def initialize
    @deck = SUITS.product(VALUES).shuffle
  end

  def deal_card
    deck.pop
  end

  def compute_total(cards)
    values = cards.map { |card| card[1] }
    sum = 0
    values.each do |value|
      sum += if value == "A"
               ACE_VALUE
             elsif value.to_i == 0
               CARDS_JQK_VALUE
             else
               value.to_i
             end
    end

    values.select { |value| value == "A" }.count.times do
      sum -= ACE_ADJUSTMENT_VALUE if sum > TwentyOne::BUSTED_VALUE
    end
    sum
  end
end
