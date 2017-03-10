class Move
  attr_accessor :value
  VALUES = ['rock', 'paper', 'scissors', 'lizard', 'spock']
  WINNING_COMBOS = {
    'rock' => %w(scissors lizard),
    'paper' => %w(rock spock),
    'scissors' => %w(paper lizard),
    'spock' => %w(rock scissors),
    'lizard' => %w(spock paper)
  }
  def initialize(value)
    @value = value
  end

  def win?(other_val)
    WINNING_COMBOS[@value].include?(other_val.value)
  end

  def to_s
    @value
  end
end

class Player
  attr_accessor :move, :name, :score, :list_moves, :win_lose, :weights

  def initialize
    @score = 0
    @list_moves = []
    @win_lose = []
    @weights = { 'spock' => 0.0, 'lizard' => 0.0, 'rock' => 0.0, 
                'scissors' => 0.0, 'paper' => 0.0 }
    set_name
  end
end

class Human < Player
  def set_name
    n = ""
    loop do
      puts " Whats your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must enter a value"
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Please choose rock, paper, scissors, lizard or spock"
      choice = gets.chomp
      break if Move::VALUES.include?(choice)
      puts "Sorry, invalid choice"
    end
    self.move = Move.new(choice)
    @list_moves << choice
  end
end

class Computer < Player
  def set_name
    self.name = ['Tom', 'Harry', 'Charlie', 'Ra', 'Sun'].sample
  end
  
  case self.name 
  when 'Tom'
    choose_tom 
  when 'Harry'
    choose_harry
  when 'Charlie'
    choose_charlie
  when 'Ra'
    choose_ra
  when 'Sun'
    choose_sun
  end

  def choose_tom 
    choice = nil
    loop do
      choice = Move::VALUES.sample
      puts "computer chooses #{choice}"
      if @weights[choice] >= 50.0
        puts "#{choice} weight is >= 50%"
        choice = Move::VALUES.sample
      end
      break if @weights[choice] < 50.0
    end
    puts "computer finally chooses #{choice}"
    self.move = Move.new(choice)
    @list_moves << choice
  end

  def choose_ra 
    choice = 'rock'
    self.move = Move.new(choice)
    @list_moves << choice
  end

  def choose_harry 
    choice = ['spock', 'lizard'].sample
    self.move = Move.new(choice)
    @list_moves << choice
  end

  def choose_charlie
    choice = ['rock', 'paper', 'scissors'].sample
    self.move = Move.new(choice)
    @list_moves << choice
  end

  def choose_sun
    choice = if @list_moves.count('rock') > 1
               ['paper', 'scissors', 'lizard', 'spock'].sample
             else
               Move::VALUES.sample
             end
    self.move = Move.new(choice)
    @list_moves << choice
  end
end

# Game Orchestration Engine
class RPSGame
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors, Lizard and Spock"
  end

  def display_goodbye_message
    puts "Thanks for playing RPS"
  end

  def display_moves
    puts "#{human.name} chose #{human.move}"
    puts "#{computer.name} chose #{computer.move}"
  end

  def increment_score(winner)
    if winner == :human
      human.score += 1
    elsif winner == :computer
      computer.score += 1
    else
      human.score += 1
      computer.score += 1
    end
    update_human_win_lose(winner)
  end

  def update_human_win_lose(winner)
    human.win_lose << if winner == :human
                       'win'
                     elsif winner == :computer
                       'lose'
                     else
                       'tie'
                     end
  end

  def display_round_winner
    winner = nil
    if human.move.win?(computer.move)
      winner = :human
      puts "#{human.name} won this round"
    elsif computer.move.win?(human.move)
      winner = :computer
      puts "#{computer.name} won this round"
    else
      puts "It's a tie!"
    end
    winner
  end

  def display_scores
    puts "#{human.name} score is #{human.score}"
    puts "#{computer.name} score is #{computer.score}"
  end

  def display_game_winner
    if human.score == 10 && computer.score == 10
      puts "It's a tie, both won the game"
    elsif human.score == 10
      puts "#{human.name} won the game"
    else
      puts "#{computer.name} won the game"
    end
  end

  def reset_scores
    human.score = 0
    computer.score = 0
    human.list_moves = []
    computer.list_moves = []
    human.win_lose = []
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if ['y', 'n'].include?(answer)
      puts "Sorry, must be y or n"
    end
    return false if answer == 'n'
    reset_scores
    return true if answer == 'y'
  end

  def check_winning_scores
    result = false
    if human.score == 10 || computer.score == 10
      display_game_winner
      result = true
    end
    result
  end

  def display_history_moves
    puts "Human moves: #{human.list_moves}"
    puts "Computer moves: #{computer.list_moves}"
    puts "Human win&lose: #{human.win_lose}"
  end

  def compute_player_win_results
    count = 0
    win_count_hsh = Hash.new(0)
    hand_count_hsh = Hash.new(0)
    computer.list_moves.each_with_object(hand_count_hsh) do |val, hand_count_hsh|
      hand_count_hsh[val] += 1
      if human.win_lose[count] == 'win'
        win_count_hsh[val] += 1
      end
      count += 1
    end
    [hand_count_hsh, win_count_hsh]
  end

  def compute_player_win_percentage(result)
    hand_count_hsh = result[0]
    win_count_hsh = result[1]
    hand_count_hsh.each do |key, _|
      if win_count_hsh[key] != nil
        num = (win_count_hsh[key] / hand_count_hsh[key].to_f)
        computer.weights[key] = (num * 100).round(2)
      else
        computer.weights[key] = 0
      end
    end
  end

  def calculate_moves
    result = compute_player_win_results
    compute_player_win_percentage(result)
    p computer.weights
  end

  def play
    display_welcome_message
    loop do
      human.choose
      computer.choose_personalities
      display_moves
      increment_score(display_round_winner)
      display_scores
      display_history_moves
      calculate_moves
      if check_winning_scores
        display_history_moves
        break unless play_again?
      end
    end
    display_goodbye_message
  end
end

RPSGame.new.play
