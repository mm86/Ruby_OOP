require 'pry'

module ArrayModifications
  def joinor(arr, delimiter=', ', word='or')
    case arr.size
    when 0 then ''
    when 1 then arr.first
    when 2 then arr.join(" #{word} ")
    else
      arr[-1] = "#{word} #{arr.last}"
      arr.join(delimiter)
    end
  end
end

class Board
  attr_accessor :squares
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals

  def initialize
    @squares = {}
    reset
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
  end
  # rubocop:enable Metrics/AbcSize

  private

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end
end

class Square
  INITIAL_MARKER = " "

  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end
end

class Player
  include ArrayModifications
  attr_accessor :marker, :name, :score

  def reset_scores
    @score = 0
  end
end

class Human < Player
  attr_reader :board

  def initialize(board)
    @board = board
    @score = 0
    set_name
  end

  def set_name
    answer = nil
    loop do
      puts "What is your name?"
      answer = gets.chomp
      break unless answer.empty? || answer.match(/^\s*$/)
      puts "Please enter a name"
    end
    @name = answer
  end

  def move
    puts "Choose a square (#{joinor(board.unmarked_keys)}): "
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end

    board[square] = @marker
  end
end

class Computer < Player
  include ArrayModifications
  SQUARE_NO_5 = 5
  attr_accessor :empty_square, :board

  def initialize(board)
    @board = board
    @score = 0
    set_name
  end

  def set_name
    @name = 'R2D2'
  end

  def opponent_marker
    @marker == 'O' ? 'X' : 'O'
  end

  def find_at_risk_squares(marker, line)
    count = 0
    empty_index = nil
    line.each do |element|
      count += 1 if board.squares[element].marker == marker
      empty_index = element if board.squares[element].marker == ' '
      return empty_index if count == 2 && line.last == element
    end
    nil
  end

  def set_empty_square
    result = false
    if @empty_square
      board[@empty_square] = @marker
      result = true
    end
    result
  end

  def detect_risk_squares(marker)
    Board::WINNING_LINES.each do |line|
      @empty_square = find_at_risk_squares(marker, line)
      break if set_empty_square
    end
  end

  def pick_empty_square_5
    if board.unmarked_keys.include?(SQUARE_NO_5)
      @empty_square = SQUARE_NO_5
      board[SQUARE_NO_5] = @marker
    end
  end

  def pick_random_square
    board[board.unmarked_keys.sample] = @marker
  end

  def move
    detect_risk_squares(marker)
    detect_risk_squares(opponent_marker) if @empty_square.nil?
    pick_empty_square_5 if @empty_square.nil?
    pick_random_square if @empty_square.nil?
  end
end

class TTTGame
  WINNING_SCORE = 3
  FIRST_TO_MOVE = 'choose' # can be changed to 'human' or 'computer'

  attr_reader :board, :human, :computer
  attr_accessor :current_marker, :first_player_to_move

  def initialize
    @board = Board.new
    @human = Human.new(@board)
    @computer = Computer.new(@board)
  end

  def play
    set_game_options
    display_welcome_message
    loop do
      display_board

      loop do
        current_player_moves
        break if board.someone_won? || board.full?
        clear_screen_and_display_board
      end

      display_result
      update_player_scores
      someone_won_game? ? (break unless !play_new_game) : move_to_next_round
    end
    display_goodbye_message
  end

  private

  def ask_human_to_choose
    puts "Please choose who goes first - human/computer"
    answer = nil
    loop do
      answer = gets.chomp
      break if %w(human computer).include? answer
      puts "Invalid choice."
    end
    assign_current_marker(answer)
  end

  def ask_human_who_moves_first
    if FIRST_TO_MOVE == 'choose'
      ask_human_to_choose
    elsif FIRST_TO_MOVE == 'human'
      @current_marker = @human.marker
    else
      @current_marker = @computer.marker
    end
    @first_player_to_move = @current_marker
  end

  def ask_human_to_choose_marker
    puts "Hi #{human.name}, Please choose a marker: (X/O)"
    choice = nil
    loop do
      choice = gets.chomp.downcase
      break if !choice.empty? && %(X O x o).include?(choice) && choice !~ /^\s*$/
      puts "Please choose a valid marker."
    end
    choice == 'X' ? @computer.marker = 'O' : @computer.marker = 'X'
    @human.marker = choice
  end

  def set_game_options
    ask_human_to_choose_marker
    ask_human_who_moves_first
  end

  def display_welcome_message
    clear
    puts "Hi #{human.name}, Welcome to Tic Tac Toe!"
    puts ""
  end

  def display_players_scores_and_markers
    puts "#{human.name} is a #{human.marker}. " \
         "#{computer.name} is a #{computer.marker}."
    puts "#{human.name} score is #{human.score}. " \
         "#{computer.name} score is #{computer.score}."
  end

  def display_board
    display_players_scores_and_markers
    puts ""
    board.draw
    puts ""
  end

  def play_new_game
    display_game_winner
    return true unless play_again?
    reset(:new)
    display_play_again_message
    false
  end

  def move_to_next_round
    start_next_round
    @current_marker = @first_player_to_move
    reset(:old)
  end

  def clear
    system "clear"
  end

  def assign_current_marker(answer)
    @current_marker = if answer == 'human'
                        @human.marker
                      else
                        @computer.marker
                      end
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def human_turn?
    @current_marker == human.marker
  end

  def computer_moves
    computer.move(board)
  end

  def current_player_moves
    if human_turn?
      human.move
      @current_marker = computer.marker
    else
      computer.move
      @current_marker = human.marker
    end
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      puts "#{human.name} won this round!"
    when computer.marker
      puts "#{computer.name} won this round!"
    else
      puts "It's a tie this round!"
    end
  end

  def start_next_round
    puts "Press enter to start next round"

    loop do
      answer = gets.chomp
      break unless !answer.empty?
      puts "Invalid entry. Press enter"
    end
  end

  def update_player_scores
    case board.winning_marker
    when human.marker
      human.score += 1
    when computer.marker
      computer.score += 1
    else
      human.score += 1
      computer.score += 1
    end
  end

  def reset(game)
    board.reset
    if game == :new
      reset_player_scores
      set_game_options
    end
    clear
  end

  def someone_won_game?
    human.score == WINNING_SCORE || computer.score == WINNING_SCORE
  end

  def display_game_winner
    if human.score == WINNING_SCORE && computer.score == WINNING_SCORE
      puts "Its a tie"
    elsif human.score == WINNING_SCORE
      puts "Human won the game"
    else
      puts "Computer won the game"
    end
  end

  def reset_player_scores
    human.reset_scores
    computer.reset_scores
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n"
    end
    answer == 'y'
  end

  def same_game_playing?
    human.score != 0 || computer.score != 0
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end
end

game = TTTGame.new
game.play
