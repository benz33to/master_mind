# Master Mind board module
module MasterMindBoard
  def draw
    puts 'Board!'
  end

  def generate_code
    4.times.map { rand(1..4) }
  end

  def cracked?(code, guess)
    indicators = []
    return true if code == guess

    guess.each_with_index do |number, index|
      indicators = number_check(indicators, code, number, index)
    end
    puts "#{guess.join(' ')} | #{indicators.shuffle.join(' ')}"
    false
  end

  def show_guess(guess)
    puts guess.size.positive? ? "Your selections are #{guess}, type 0 to delete" : 'You have no selections'
  end

  def show_scores(player_score, computer_score)
    puts "Player score: #{player_score} | Computer score: #{computer_score}"
  end

  private

  def number_check(indicators, code, number, index)
    if number == code[index]
      indicators.push('red')
    elsif code.include?(number)
      indicators.push('white')
    end
    indicators
  end
end

# Game class
class Game
  include MasterMindBoard
  LIMIT_ROUNDS = 12
  attr_accessor :code, :guess

  def initialize
    @over = false
    @round = 0
    @player = Player.new('breaker')
    @computer = Player.new('maker')
  end

  def play
    @code = generate_code
    puts "Code is #{@code}"
    start_round until @over == true
  end

  private

  def start_round
    @round += 1
    @guess = []
    while guess.size < 4
      show_guess(@guess)
      number = select_number
      number.zero? ? remove_guess : add_guess(number)
    end
    cracked?(@code, @guess) ? end_game : @computer.add_score
    show_scores(@player.score, @computer.score)
  end

  def select_number
    number = gets.chomp.to_i until valid_guess?(number)
    number
  end

  def valid_guess?(number)
    return false if number.nil?

    if (0..4).include?(number)
      true
    else
      puts 'Please select a number from 0 to 4'
      false
    end
  end

  def remove_guess
    @guess.pop
  end

  def add_guess(number)
    @guess.push(number)
  end

  def end_game
    @over = true
    score_to_add = LIMIT_ROUNDS - @round
    @player.add_score(score_to_add)
  end
end

# Player class
class Player
  attr_accessor :role, :score

  def initialize(role)
    @role = role
    @score = 0
  end

  def add_score(score = 1)
    @score += score
  end
end

master_mind = Game.new
master_mind.play
