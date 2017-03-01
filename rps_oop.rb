class Spock
  WINS_OVER = %w(rock scissors)
end

class Rock 
  WINS_OVER = %w(scissors lizard)
end

class Lizard
  WINS_OVER = %w(spock paper)
end

class Scissors
  WINS_OVER = %w(paper lizard)
end

class Paper
  WINS_OVER = %w(rock spock)
end

class Move
  attr_accessor :value 
  VALUES = ['rock', 'paper', 'scissors', 'lizard', 'spock']
  WINNING_COMBOS = {
    'rock' => Rock::WINS_OVER,
    'paper' => Paper::WINS_OVER,
    'scissors' => Scissors::WINS_OVER,
    'spock' => Spock::WINS_OVER,
    'lizard' => Lizard::WINS_OVER
  }
  def initialize(value)
    @value = value
  end

  def win?(other_val)
    WINNING_COMBOS[@value].include?(other_val.value)
  end

  def to_s
    self.value
  end
end

class Player
  attr_accessor :move, :name, :score, :list_moves

  def initialize
    @score = 0
    @list_moves = []
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
    self.list_moves << choice
  end

end

class Computer < Player
  def set_name
    self.name = ['tom', 'harry', 'charlie', 'Ra'].sample
  end

  choice = nil
  def choose
    choice = Move::VALUES.sample
    self.move = Move.new(choice)
    self.list_moves << choice
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
    reset_scores
    human.score = 0
    computer.score = 0
    human.list_moves = []
    computer.list_moves = []
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
  end

  def play
    display_welcome_message
    loop do
      human.choose
      computer.choose
      display_moves
      increment_score(display_round_winner)
      display_scores
      if check_winning_scores
        display_history_moves
        break unless play_again?
      end
    end
    display_goodbye_message
  end
end

RPSGame.new.play
