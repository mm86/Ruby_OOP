class Win
  def initialize(player_type)
    @winner = player_type
  end

  def to_s
    @winner
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
  attr_accessor :move, :name, :score, :history_of_moves

  def initialize
    set_name
    @score = 0
    @history_of_moves = []
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
      puts "Please choose rock, paper, scissors, lizard or spock"
      choice = gets.chomp
      break if Move::VALUES.include?(choice)
      puts "Sorry, invalid choice."
    end
    self.move = Move.new(choice)
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Charlie', 'Tom', 'Sun'].sample
  end

  def choose
    self.move = Move.new(Move::VALUES.sample)
  end
end

class RPSGame
  attr_accessor :human, :computer, :winner

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "Welcome to RPS Game"
  end

  def display_goodbye_message
    puts "Thanks for playing RPS Game"
  end

  def display_moves
    puts "#{human.name} chose #{human.move}"
    puts "#{computer.name} chose #{computer.move}"
    puts "#{human.name}'s history: {human.history_of_moves}"
    puts "#{computer.name}'s history: #{computer.history_of_moves}"
  end

  def update_history_of_moves
    human.history_of_moves << human.move 
    computer.history_of_moves << computer.move  
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

  def display_round_winner
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

  def display_score
    puts "#{human.name} score is #{human.score}"
    puts "#{computer.name} score is #{computer.score}"
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
    reset_scores
    return true if answer == 'y'
  end

  def reset_scores
    human.score = 0
    computer.score = 0
    human.winner = nil
    computer.winner = nil
  end

  def check_score_ten?
    human.score == 10 || computer.score == 10
  end

  def display_game_winner
    if human.score == 10 && computer.score == 10
      puts "It's a tie. Both won the game"
    elsif human.score == 10
      puts "#{human.name} won the game"
    else
      puts "#{computer.name} won the game"
    end
  end

  def play
    display_welcome_message

    loop do
      human.choose
      computer.choose
      update_history_of_moves
      display_moves
      compute_round_winner
      display_round_winner
      increment_score
      display_score
      if check_score_ten?
        display_game_winner
        break unless play_again?
      end
    end
    display_goodbye_message
  end
end

RPSGame.new.play
