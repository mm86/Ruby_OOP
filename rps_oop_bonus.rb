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
  attr_accessor :move, :name, :score, :history_of_moves, :weights, :results

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
  attr_accessor :win_counts

  def initialize
    @win_counts = { 'spock' => 0, 'lizard' => 0, 'rock' => 0,
                    'scissors' => 0, 'paper' => 0 }
  end

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
    self.win_counts = { 'spock' => 0, 'lizard' => 0, 'rock' => 0,
                        'scissors' => 0, 'paper' => 0 }
  end
end

class R2D2 < Player
  def set_name
    self.name = 'R2D2'
  end

  def choose
    self.move = Move.new(['rock', 'paper', 'scissors'].sample)
  end

  def reset_game 
    self.score = 0
    self.history_of_moves = []
    self.weights = { 'spock' => 0.0, 'lizard' => 0.0, 'rock' => 0.0,
                         'scissors' => 0.0, 'paper' => 0.0 } 
  end
end

class Hal < Player
  def set_name
    self.name = 'Hal'
  end

  def choose
    self.move = Move.new(['spock', 'lizard'].sample)
  end

  def reset_game 
    self.score = 0
    self.history_of_moves = []
    self.weights = { 'spock' => 0.0, 'lizard' => 0.0, 'rock' => 0.0,
                         'scissors' => 0.0, 'paper' => 0.0 } 
  end
end

class Charlie < Player
  def set_name
    self.name = 'Charlie'
  end

  def choose
    self.move = Move.new('rock')
  end
  
  def reset_game 
    self.score = 0
    self.history_of_moves = []
    self.weights = { 'spock' => 0.0, 'lizard' => 0.0, 'rock' => 0.0,
                         'scissors' => 0.0, 'paper' => 0.0 } 
  end
end

class Tom < Player
  def set_name
    self.name = 'Tom'
  end

  def choose
    self.move = Move.new('paper')
  end
  
  def reset_game 
    self.score = 0
    self.history_of_moves = []
    self.weights = { 'spock' => 0.0, 'lizard' => 0.0, 'rock' => 0.0,
                         'scissors' => 0.0, 'paper' => 0.0 } 
  end
end

class Sun < Player
  def set_name
    self.name = 'Sun'
  end

  def all_weights_greater_than_50?
    @weights.each do |_, val|
      return false if val < 50.0
    end
    true
  end

  def choose
    choice = nil
    loop do
      choice = Move::VALUES.sample
      puts "computer chooses #{choice}"
      if @weights[choice] >= 50.0
        puts "#{choice} weight is >= 50%"
        choice = Move::VALUES.sample
      end
      break if @weights[choice] < 50.0 || all_weights_greater_than_50?
    end
    puts "computer finally chooses #{choice}"
    self.move = Move.new(choice)
  end

  def reset_game 
    self.score = 0
    self.history_of_moves = []
    self.weights = { 'spock' => 0.0, 'lizard' => 0.0, 'rock' => 0.0,
                         'scissors' => 0.0, 'paper' => 0.0 } 
  end
end

class RPSGame
  attr_accessor :human, :computer, :winner

  def initialize
    @human = Human.new
    computer_set_personalities
  end

  def computer_set_personalities
    computer_type = [R2D2, Tom, Charlie, Sun, Hal].sample
    @computer = computer_type.new
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

  def display_round_winner
    puts "-------WINNER IS --------"
    result = nil
    if @winner.person == :human
      puts "The winner for this round is #{human.name}"
      result = 'win'
    elsif @winner.person == :computer
      puts "The winner for this round is #{computer.name}"
      result = 'lose'
    else
      puts "It's a tie this round"
      result = 'tie'
    end
    human.results << result
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

  def human_win_percent(human_hand_key, key)
    computer_hand_count = computer.history_of_moves.count(key).to_f
    human_hand_key / computer_hand_count
  end

  def human_win_count
    human_hands_win = { 'spock' => 0, 'lizard' => 0, 'rock' => 0,
                        'scissors' => 0, 'paper' => 0 }
    count = 0
    # for each move of the computer, calculate the number of times human has won
    computer.history_of_moves.each_with_object(human_hands_win) do |val, hsh|
      if human.results[count] == 'win'
        hsh[val] += 1
      end
      count += 1
    end
    human_hands_win
  end

  def compute_weights_percentage
    # computes the human win percentage for each hand chosen by the computer
    human_win = human_win_count
    human_win.each do |key, _|
      if human_win[key] == 0.0
        computer.weights[key] = 0.0
      else
        human_win_val = human_win_percent(human_win[key], key)
        computer.weights[key] = (human_win_val * 100).round(2)
      end
    end
    puts "Computer Weights:"
    p computer.weights
  end

  def increment_and_display_score
    increment_score
    display_score
  end

  def update_human_win_count
    if @winner.person == :human
      #update the win_count hash, but how to find which hand human won 
    end
  end

  def player_won?
    human.score == 10 || computer.score == 10
  end

  def display_game_winner
    puts "----------GAME WINNER IS -------------"
    if human.score == 10 && computer.score == 10
      puts "It's a tie. Both won the game"
    elsif human.score == 10
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

    return false if answer == 'n'
    reset_game
    return true if answer == 'y'
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
      increment_and_display_score
      update_human_win_count
      compute_weights_percentage
      if player_won?
        display_game_winner
        break unless play_again?
      end
    end
    display_goodbye_message
  end
end

RPSGame.new.play
