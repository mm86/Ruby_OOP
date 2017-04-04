module Display
  def prompt(message)
    puts "=> #{message}"
  end

  def display_welcome_message_and_rules
    prompt "Hi #{human.name}, Welcome to Twenty-One Game"
    prompt "To win the game, player must reach a score of " \
           "#{TwentyOne::WINNING_SCORE}"
    prompt "Hit or Stay valid responses - [h s hit stay Hit Stay H S]"
  end

  def display_goodbye_message
    prompt "Thanks for playing Twenty-One game"
  end

  def display_scores_board
    puts "--------------------SCORES BOARD--------------------"
    puts "                 HUMAN SCORE: #{human.score}        "
    puts "                 DEALER SCORE: #{dealer.score}      "
    puts "----------------------------------------------------"
  end

  def display_player_cards_and_total_value
    prompt "#{name} cards are #{cards}"
    prompt "#{name} total is #{total}"
  end

  def display_game_winner
    prompt "GAME WINNER: #{game_winner}"
  end

  def display_human_cards
    prompt "#{human.name} cards are #{human.cards[0]} & #{human.cards[1]}. " \
           "#{human.name} total is #{human.cards_calc_total}"
  end

  def display_dealer_cards
    prompt "#{dealer.name} cards are #{dealer.cards[0]} and ?"
  end

  def show_initial_cards
    display_human_cards
    display_dealer_cards
  end

  def display_winner_details
    if human.busted?
      "#{human.name} busted, #{dealer.name} wins"
    elsif dealer.busted?
      "#{dealer.name} busted, #{human.name} wins"
    elsif both_players_stay?
      "Both players stay"
    end
  end

  def display_winner_of_this_round
    prompt "----------------------------------"
    prompt display_winner_details
    prompt "WINNER THIS ROUND: #{winner_this_round}"
  end
end

module Prompt
  def display_prompt_continue(game_status)
    loop do
      if game_status == :new
        prompt "Press enter to start playing the game"
      elsif game_status == :near_end
        prompt "Press enter to view game results"
      else
        prompt "Press enter to play next round"
      end
      answer = gets.chomp
      break if answer.empty?
      prompt "Invalid entry. Press enter to continue"
    end
  end
end

module System
  def clear
    system 'clear'
  end
end

module SetName
  def ask_user_for_name
    answer = nil
    loop do
      prompt "What is your name?"
      answer = gets.chomp
      break if !answer.empty? && answer !~ /\A\s*\z/
      prompt "Please enter a valid name"
    end
    self.name = answer.capitalize
  end
end

module PlayAgain
  def valid_response?(answer)
    %w[yes no y n Y N Yes No].include?(answer) &&
      answer !~ /\A\s*\z/ &&
      !answer.empty?
  end

  def play_again?
    answer = nil
    loop do
      prompt "Do you want to play again? (y/n)"
      answer = gets.chomp
      break if valid_response?(answer)
      prompt "Please enter a valid response"
    end
    %w[y yes Y Yes].include?(answer)
  end
end
