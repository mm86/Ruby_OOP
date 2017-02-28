class Move
  VALUES = ['rock', 'paper', 'scissors']

  def initialize(value)
    @value = value
  end

  def scissors?
    @value == 'scissors'
  end

  def rock?
    @value == 'rock'
  end

  def paper?
    @value == 'paper'
  end

  def >(other_move)
    (rock? && other_move.scissors?) ||
      (paper? && other_move.rock?) ||
      (scissors? && other_move.paper?)
  end

  def <(other_move)
    (rock? && other_move.paper?) ||
      (paper? && other_move.scissors?) ||
      (scissors? && other_move.rock?)
  end

  def to_s
    @value
  end
end

class Player
  attr_accessor :move, :name, :score

  def initialize
    @score = 0
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
      puts "Please choose rock, paper or scissors"
      choice = gets.chomp
      break if Move::VALUES.include?(choice)
      puts "Sorry, invalid choice"
    end
    self.move = Move.new(choice)
  end
end

class Computer < Player
  def set_name
    self.name = ['tom', 'harry', 'charlie', 'Ra'].sample
  end

  def choose
    self.move = Move.new(Move::VALUES.sample)
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
    puts "Welcome to Rock, Paper, Scissors"
  end

  def display_goodbye_message
    puts "Thanks for playing RPS"
  end

  def display_moves
    puts "#{human.name} chose #{human.move}"
    puts "#{computer.name} chose #{computer.move}"
  end

  def display_round_winner
    if human.move > computer.move
      human.score += 1
      puts "#{human.name} won this round"
      puts "#{human.name} score is #{human.score}, #{computer.name} score is #{computer.score}"
    elsif human.move < computer.move
      computer.score += 1
      puts "#{computer.name} won"
      puts "#{human.name} score is #{human.score}, #{computer.name} score is #{computer.score}"
    else
      human.score += 1
      computer.score += 1
      puts "It's a tie!"
      puts "#{human.name} score is #{human.score}, #{computer.name} score is #{computer.score}"
    end
  end

  def display_game_winner
    if human.score == 10 && computer.score == 10
      puts "It's a tie, both won the game"
    elsif human.score == 10 
      puts "#{human.name} won the game"
    elsif computer.score == 10 
      puts "#{computer.name} won the game"
    end
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
    if answer == 'y'
      human.score = 0
      computer.score = 0
      return true 
    end
  end

  def play
    display_welcome_message
    loop do
      human.choose
      computer.choose
      display_moves
      display_round_winner
      if human.score == 10 || computer.score == 10
        display_game_winner
        break unless play_again?
      end
    end
    display_goodbye_message
  end
end

RPSGame.new.play
