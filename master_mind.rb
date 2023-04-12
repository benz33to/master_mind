# Master Mind board module
module MasterMindBoard
  def draw
    puts 'Board!'
  end

  def generate_code
    4.times.map { rand(1..4) }
  end

  def compare_code(code, guess)
    indicators = []
    guess.each_with_index do |number, index|
      if number == code[index]
        indicators.push('red')
      elsif code.include?(number)
        indicators.push('white')
      end
    end
    indicators.shuffle
  end
end

# Game class
class Game
  include MasterMindBoard

  attr_accessor :code, :guess

  def initialize
    @over = false
    @guess = []
  end

  def play
    @code = generate_code
    puts "Code is #{@code}"
    make_guesses until @over == true
  end

  private

  def make_guesses
    while guess.size < 4
      puts guess.size.positive? ? "Your selections are #{@guess}, type 0 to delete" : 'You have no selections'
      number = select_number
      number.zero? ? remove_guess : add_guess(number)
    end
    comparison = compare_code(@code, @guess)
    puts "#{guess.join(' ')} | #{comparison.join(' ')}"
    @guess = []
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
      puts 'Please elect a number from 0 to 4'
    end
  end

  def remove_guess
    @guess.pop
  end

  def add_guess(number)
    @guess.push(number)
  end
end

# Player class
class Player
  def initialize
    @role = 'breaker'
  end
end

# Computer class
class Computer
  def initialize
    @role = 'maker'
  end
end

master_mind = Game.new
master_mind.play
