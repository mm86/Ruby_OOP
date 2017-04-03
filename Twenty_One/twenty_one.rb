class TwentyOne
  include Display, System, Prompt, PlayAgain

  WINNING_SCORE = 5
  DEALER_CARDS_TOTAL_MAX = 17
  BUSTED_VALUE = 21
  DEAL_TWO_CARDS = 2
  DEAL_ONE_CARD = 1
  attr_accessor :current_player, :winner_this_round,
                :game_winner, :deck, :human, :dealer

  def initialize
    @deck = Deck.new
    @human = Human.new(@deck)
    @dealer = Dealer.new(@deck)
    @current_player = dealer
    reset_players_scores
    set_names
  end

  def play
    display_welcome_message_and_rules
    display_prompt_continue(:new)
    play_game
    display_goodbye_message
  end

  private

  def set_names
    human.set_name
    dealer.set_name
  end

  def play_game
    loop do
      clear_and_display_scores_board
      deal_and_display_initial_cards
      play_round
      detect_and_display_winner_for_this_round
      update_players_scores

      if someone_won?
        compute_and_display_game_winner
        break unless play_again?
        reset(:new)
      else
        reset(:old)
        display_prompt_continue(:old)
      end
    end
  end

  def clear_and_display_scores_board
    clear
    display_scores_board
  end

  def deal_cards
    DEAL_TWO_CARDS.times do
      human.cards << deck.deal_card
      dealer.cards << deck.deal_card
    end
  end

  def deal_and_display_initial_cards
    deal_cards
    show_initial_cards
  end

  def alternate_player(player)
    if player.equal?(dealer)
      human
    else
      dealer
    end
  end

  def current_player_turn
    human.turn if current_player.equal?(human)
    dealer.turn if current_player.equal?(dealer)
  end

  def both_players_stay?
    human.chose_stay? &&
      dealer.status == 'stay'
  end

  def play_round
    loop do
      self.current_player = alternate_player(current_player)
      current_player_turn
      break if current_player.busted? || both_players_stay?
    end
  end

  def compare_scores_return_winner
    if human.total > dealer.total
      human.name
    elsif dealer.total > human.total
      dealer.name
    else
      :tie
    end
  end

  def compute_winner_of_this_round
    self.winner_this_round = if human.busted?
                               dealer.name
                             elsif dealer.busted?
                               human.name
                             elsif both_players_stay?
                               compare_scores_return_winner
                             end
  end

  def detect_and_display_winner_for_this_round
    compute_winner_of_this_round
    display_winner_of_this_round
  end

  def update_players_scores
    if winner_this_round == human.name
      human.score += 1
    elsif winner_this_round == dealer.name
      dealer.score += 1
    end
  end

  def reset_players_scores
    human.reset_score
    dealer.reset_score
  end

  def reset(game)
    @deck = Deck.new
    human.reset(deck)
    dealer.reset(deck)
    self.current_player = dealer
    reset_players_scores if game == :new
  end

  def someone_won?
    human.score == WINNING_SCORE || dealer.score == WINNING_SCORE
  end

  def compute_game_winner
    if human.score == WINNING_SCORE && dealer.score == WINNING_SCORE
      self.game_winner = :both
    elsif human.score == WINNING_SCORE
      self.game_winner = human.name
    else
      self.game_winner = dealer.name
    end
  end

  def compute_and_display_game_winner
    display_prompt_continue(:near_end)
    compute_game_winner
    clear_and_display_scores_board
    display_game_winner
  end
end
