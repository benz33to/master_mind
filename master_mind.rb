# Master Mind board module
module MasterMindBoard
  PEGS = %w[white red].freeze
  LIMIT_ROUNDS = 12

  def start_round_as_breaker
    @round += 1
    @guess = @player.code
    @player.cracked?(@code, @guess) ? end_game_as_breaker : @computer.add_score
    show_scores(@player.score, @computer.score)
  end

  def start_round_as_maker
    @round += 1
    @guess = @computer.code(@round, @pegs)
    if @code == @guess
      end_game_as_maker
    else
      @player.add_score
      @pegs = @computer.cracked?(@code, @guess)
    end
    show_scores(@player.score, @computer.score)
  end

  def show_scores(player_score, computer_score)
    puts "Player score: #{player_score} | Computer score: #{computer_score}"
  end
end

# Game class
class Game
  include MasterMindBoard
  attr_accessor :code, :guess

  BREAKER_TEXT = 'Time to break the code, write a combination of 4 numbers from 1 to 4, '\
                 'type a number and then press enter, to delete type 0 and enter'.freeze

  MAKER_TEXT = 'You are now the code maker! Write a code with numbers between 1 to 4, '\
               'type a number and then press enter, to delete type 0 and enter'.freeze

  def initialize
    @over = false
    @round = 0
    @pegs = []
    @player = Human.new
    @computer = Computer.new
  end

  def define_roles
    puts "Select your role, 'breaker' if you want to break the code, 'maker' if you want to create it"
    role = @player.role
    role == 'breaker' ? play_as_breaker : play_as_maker
  end

  def play_as_breaker
    puts BREAKER_TEXT
    @code = @computer.code
    start_round_as_breaker until @over == true
  end

  def play_as_maker
    puts MAKER_TEXT
    @code = @player.code
    start_round_as_maker until @over == true
  end

  private

  def end_game_as_breaker
    puts "Code was #{@code}"
    @over = true
    score_to_add = LIMIT_ROUNDS - @round
    @player.add_score(score_to_add)
  end

  def end_game_as_maker
    puts "Code was #{@code}"
    @over = true
    score_to_add = LIMIT_ROUNDS - @round
    @computer.add_score(score_to_add)
  end
end

# Player class
class Player
  attr_accessor :score

  def initialize
    @score = 0
  end

  def add_score(score = 1)
    @score += score
  end

  def cracked?(code, guess)
    indicators = []
    return true if code == guess

    guess.each_with_index do |number, index|
      indicators = compare_codes(indicators, code, number, index)
    end
    puts "#{guess.join(' ')} | #{indicators.shuffle.join(' ')}"
    false
  end

  def compare_codes(indicators, code, number, index)
    if number == code[index]
      indicators.push('red')
    elsif code.include?(number)
      indicators.push('white')
    else
      indicators.push('x')
    end
    indicators
  end
end

# Human player class
class Human < Player
  ROLES = %w[breaker maker].freeze
  INVALID_CODE = 'Please select a number from 0 to 4'.freeze
  INVALID_ROLE = "Please type the correct role 'breaker' or 'maker'".freeze
  INVALID_PEG = "Please type the peg value, 'red' or 'white'".freeze

  def role
    role = gets.chomp.downcase until valid?(role, ROLES, INVALID_ROLE)
    role
  end

  def code
    guess = []
    while guess.size < 4
      show_code(guess)
      number = select_number
      number.zero? ? guess.pop : guess.push(number)
    end
    guess
  end

  def select_number
    number = gets.chomp.to_i until valid?(number, (0..4), INVALID_CODE)
    number
  end

  private

  def valid?(input, array, message)
    return false if input.nil?

    if array.include?(input)
      true
    else
      puts message
      false
    end
  end

  def show_code(guess)
    puts guess.size.positive? ? "Your selections are #{guess}, type 0 to delete" : 'You have no selections'
  end
end

# Computer player class
class Computer < Player
  attr_accessor :guess, :possible_guesses

  def initialize
    super
    @possible_guesses = Array.new(4) { 4.times.map { |i| i + 1 } }
  end

  def code(round = 1, pegs = [])
    @guess = round == 1 ? 4.times.map { rand(1..4) } : next_guess(pegs)
    @guess
  end

  def cracked?(code, guess)
    pegs = []
    guess.each_with_index do |number, index|
      pegs = compare_codes(pegs, code, number, index)
    end
    puts "#{guess.join(' ')} | #{pegs.join(' ')}"
    pegs
  end

  private

  def next_guess(pegs)
    next_guess = []
    pegs.each_with_index do |peg, index|
      update_possible_guesses!(peg, index)
    end
    @possible_guesses.each do |guess_options|
      next_guess.push(guess_options.sample)
    end
    next_guess
  end

  def update_possible_guesses!(peg, index)
    guess_number = @guess[index]
    return if @possible_guesses.size == 1

    if peg == 'red'
      @possible_guesses[index].select! { |num| num == guess_number }
    elsif peg == 'white'
      @possible_guesses[index].reject! { |num| num == guess_number }
    else
      remove_non_existant!(guess_number)
    end
  end

  def remove_non_existant!(guess_number)
    @possible_guesses.map! do |items|
      items.include?(guess_number) ? items.reject! { |num| num == guess_number } : items
    end
  end
end

master_mind = Game.new
master_mind.define_roles
