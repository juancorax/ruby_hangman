class Game
  def initialize
    @word = ''

    @word_array = []
    @underscore_array = []

    @incorrect_guesses = 7
    @incorrect_letters = []
  end

  private

  attr_accessor :word, :word_array, :underscore_array, :incorrect_guesses, :incorrect_letters

  def select_word
    dictionary = File.read('google-10000-english-no-swears.txt').split("\n")

    self.word = dictionary.sample until word.length >= 5 && word.length <= 12

    self.word_array = word.split('')
    self.underscore_array = Array.new(word.length, '_')
  end

  def display_word_and_guesses(incorrect_guesses, incorrect_letters, underscore_array)
    puts "-----------------------\n\n"

    puts "Incorrect guesses left:\n#{incorrect_guesses}"
    puts "Incorrect letters:\n#{incorrect_letters.join(' ')}" unless incorrect_letters.empty?

    puts "\n#{underscore_array.join(' ')}\n\n"
  end

  def check_guess(guess)
    if word.include?(guess) && !underscore_array.include?(guess)
      word_array.each_with_index do |value, index|
        underscore_array[index] = guess if value == guess
      end
    elsif !incorrect_letters.include?(guess) && !underscore_array.include?(guess)
      incorrect_letters << guess

      self.incorrect_guesses -= 1
    else
      self.incorrect_guesses -= 1
    end
  end

  def check_game_over
    if incorrect_guesses.zero?
      display_word_and_guesses(incorrect_guesses, incorrect_letters, underscore_array)

      puts 'You lose!'
      true
    elsif underscore_array.join('') == word
      display_word_and_guesses(incorrect_guesses, incorrect_letters, underscore_array)

      puts 'You win!'
      true
    end
  end

  public

  def start_game
    select_word

    game_over = false

    until game_over
      display_word_and_guesses(incorrect_guesses, incorrect_letters, underscore_array)

      guess = ''
      until ('a'..'z').include?(guess)
        print 'Please, make a guess: '
        guess = gets.chomp.downcase
        puts "\n"
      end

      check_guess(guess)

      game_over = true if check_game_over
    end
  end
end
