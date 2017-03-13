class Win
  def initialize(player_type)
    @winner = player_type
  end

  def person
    @winner
  end
end

class Move
  VALUES = ['rock', 'paper', 'scissors', 'lizard', 'spock']
  WINNING_COMBOS = {
    'rock' => %w(scissors lizard),
    'paper' => %w(rock spock),
    'scissors' => %w(paper lizard),
    'spock' => %w(rock scissors),
    'lizard' => %w(spock paper)
  }

  attr_accessor :value

  def initialize(value)
    @value = value
  end

  def >(other_move)
    WINNING_COMBOS[value].include?(other_move.value)
  end

  def <(other_move)
    WINNING_COMBOS[other_move.value].include?(value)
  end

  def to_s
    @value
  end
end

class Player
  attr_accessor :move, :name, :score, :history_of_moves,
                :weights, :results, :opponent, :win_counts

  def initialize
    set_name
    @score = 0
    @history_of_moves = []
    @results = []
    @weights = { 'spock' => 0.0, 'lizard' => 0.0, 'rock' => 0.0,
                 'scissors' => 0.0, 'paper' => 0.0 }
  end
end

class Human < Player
  def set_name
    n = ""
    loop do
      puts "What's your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must enter a value"
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "=> Please choose rock, paper, scissors, lizard or spock"
      choice = gets.chomp
      break if Move::VALUES.include?(choice)
      puts "Sorry, invalid choice."
    end
    self.move = Move.new(choice)
  end

  def reset_game
    self.score = 0
    self.history_of_moves = []
  end
end

class Computer < Player
  def reset_game
    self.score = 0
    self.history_of_moves = []
    self.weights = { 'spock' => 0.0, 'lizard' => 0.0, 'rock' => 0.0,
                     'scissors' => 0.0, 'paper' => 0.0 }
  end
end

class R2D2 < Computer
  def set_name
    self.name = 'R2D2'
  end

  def choose
    self.move = Move.new(['rock', 'paper', 'scissors'].sample)
  end
end

class Hal < Computer
  def set_name
    self.name = 'Hal'
  end

  def choose
    self.move = Move.new(['spock', 'lizard'].sample)
  end
end

class Charlie < Computer
  def set_name
    self.name = 'Charlie'
  end

  def choose
    self.move = Move.new('rock')
  end
end

class Tom < Computer
  def set_name
    self.name = 'Tom'
  end

  def choose
    self.move = Move.new('paper')
  end
end

class Sun < Computer
  def set_name
    self.name = 'Sun'
  end

  def all_weights_greater_than_50?
    @weights.each do |_, val|
      return false if val < 50.0
    end
    true
  end

  def human_win_percent(win_counts, key)
    computer_hand_count = @history_of_moves.count(key).to_f
    win_counts / computer_hand_count
  end

  def human_win_count
    @opponent.win_counts = { 'spock' => 0, 'lizard' => 0, 'rock' => 0,
                             'scissors' => 0, 'paper' => 0 }
    count = 0
    # for each move of the computer, calculate the number of times human has won
    @history_of_moves.each_with_object(@opponent.win_counts) do |val, hsh|
      if @opponent.results[count] == 'win'
        hsh[val] += 1
      end
      count += 1
    end
    @opponent.win_counts
  end

  def compute_weights_percentage
    # computes the human win percentage for each hand chosen by the computer
    human_win = human_win_count
    human_win.each do |key, win_counts|
      if win_counts == 0.0
        @weights[key] = 0.0
      else
        human_win_val = human_win_percent(win_counts, key)
        @weights[key] = (human_win_val * 100).round(2)
      end
    end
    puts "Computer Weights:"
    p @weights
  end

  def choose
    choice = nil
    loop do
      choice = Move::VALUES.sample
      compute_weights_percentage
      if @weights[choice] >= 50.0
        puts "#{choice} weight is >= 50%"
        choice = Move::VALUES.sample
      end
      break if @weights[choice] < 50.0 || all_weights_greater_than_50?
    end
    self.move = Move.new(choice)
  end
end

class RPSGame
  attr_accessor :human, :computer, :winner
  WINNING_SCORE = 10
  def initialize
    @human = Human.new
    computer_set_personalities
    computer_set_opponent
  end

  def computer_set_personalities
    computer_type = [R2D2, Charlie, Tom, Sun, Hal].sample
    @computer = computer_type.new
  end

  def computer_set_opponent
    @computer.opponent = @human
  end

  def display_welcome_message
    puts "Welcome to RPS Game"
  end

  def display_move_this_round
    puts "------ PLAYERS CHOSE ------------"
    puts "#{human.name} chose #{human.move}"
    puts "#{computer.name} chose #{computer.move}"
  end

  def display_history_of_moves
    puts "-----HISTORY-OF-MOVES-------------"
    puts "#{human.name}'s history: #{human.history_of_moves}"
    puts "#{computer.name}'s history: #{computer.history_of_moves}"
  end

  def display_moves
    display_move_this_round
    display_history_of_moves
  end

  def update_history_of_moves
    human.history_of_moves << human.move.value
    computer.history_of_moves << computer.move.value
  end

  def display_and_update_history_of_moves
    update_history_of_moves
    display_moves
  end

  def update_human_results
    human.results << if @winner.person == :human
                       'win'
                     elsif @winner.person == :computer
                       'lose'
                     else
                       'tie'
                     end
  end

  def display_round_winner
    puts "-------WINNER IS --------"
    if @winner.person == :human
      puts "The winner for this round is #{human.name}"
    elsif @winner.person == :computer
      puts "The winner for this round is #{computer.name}"
    else
      puts "It's a tie this round"
    end
  end

  def compute_round_winner
    @winner = if human.move > computer.move
                Win.new(:human)
              elsif human.move < computer.move
                Win.new(:computer)
              else
                Win.new(:both)
              end
  end

  def increment_score
    if @winner.person == :human
      human.score += 1
    elsif @winner.person == :computer
      computer.score += 1
    else
      human.score += 1
      computer.score += 1
    end
  end

  def display_score
    puts "-----------SCORES-------------------"
    puts "#{human.name} score is #{human.score}"
    puts "#{computer.name} score is #{computer.score}"
  end

  def compute_and_display_round_winner
    compute_round_winner
    display_round_winner
  end

  def increment_and_display_score
    increment_score
    display_score
  end

  def player_won?
    human.score == WINNING_SCORE || computer.score == WINNING_SCORE
  end

  def display_game_winner
    puts "----------GAME WINNER IS -------------"
    if human.score == WINNING_SCORE && computer.score == WINNING_SCORE
      puts "It's a tie. Both won the game"
    elsif human.score == WINNING_SCORE
      puts "#{human.name} won the game"
    else
      puts "#{computer.name} won the game"
    end
  end

  def reset_game
    human.reset_game
    computer.reset_game
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if ['y', 'n'].include?(answer)
      puts "Sorry, must be y or n."
    end

    answer == 'y'
  end

  def display_goodbye_message
    puts "Thanks for playing RPS Game"
  end

  def play
    display_welcome_message
    loop do
      human.choose
      computer.choose
      display_and_update_history_of_moves
      compute_and_display_round_winner
      update_human_results
      increment_and_display_score
      if player_won?
        display_game_winner
        break unless play_again?
        reset_game
      end
    end
    display_goodbye_message
  end
end

RPSGame.new.play
