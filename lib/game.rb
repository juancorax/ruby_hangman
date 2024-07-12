require 'yaml'

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

  def check_saves
    if Dir.exist?('saves') && !Dir.entries('saves').empty?
      load_save = ''
      until %w[y n].include?(load_save)
        puts "Do you want to load a save? [y/n]\n"

        load_save = gets.chomp
        puts "\n"
      end

      if load_save == 'y'
        load_game
        return
      end
    end

    select_word
  end

  def select_word
    dictionary = File.read('google-10000-english-no-swears.txt').split("\n")

    self.word = dictionary.sample until word.length >= 5 && word.length <= 12

    self.word_array = word.split('')
    self.underscore_array = Array.new(word.length, '_')
  end

  def display_word_and_guesses(incorrect_guesses, incorrect_letters, underscore_array)
    puts "-----------------------------------\n\n"

    puts "Incorrect guesses left:\n#{incorrect_guesses}"
    puts "Incorrect letters:\n#{incorrect_letters.join(' ')}" unless incorrect_letters.empty?

    puts "\n#{underscore_array.join(' ')}\n\n"
  end

  def check_guess(guess)
    if guess == 'save'
      save_game
    elsif word.include?(guess) && !underscore_array.include?(guess)
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

  def save_game
    Dir.mkdir('saves') unless Dir.exist?('saves')

    puts "Please, choose your save file name:\n\n"
    print '> '
    filename = gets.chomp

    File.open("saves/#{filename}.yaml", 'w') do |file|
      file.puts YAML.dump({
                            word: word,
                            word_array: word_array,
                            underscore_array: underscore_array,
                            incorrect_guesses: incorrect_guesses,
                            incorrect_letters: incorrect_letters
                          })
    end
  end

  def load_game
    saves = Dir.entries('saves').reject { |entry| ['.', '..'].include?(entry) }
    saves.map! { |save| save.gsub('.yaml', '') }

    puts "Please, choose a save file to load:\n\n"
    saves.each_with_index do |save, index|
      puts "#{index + 1}: #{save}"
    end

    selection = ''
    until (0..(saves.length - 1)).include?(selection)
      print "\n> "

      selection = gets.chomp.to_i - 1
    end

    data = YAML.load File.read("saves/#{saves[selection]}.yaml")

    self.word = data[:word]
    self.word_array = data[:word_array]
    self.underscore_array = data[:underscore_array]
    self.incorrect_guesses = data[:incorrect_guesses]
    self.incorrect_letters = data[:incorrect_letters]
  end

  def start_game
    check_saves
    game_over = false

    until game_over
      display_word_and_guesses(incorrect_guesses, incorrect_letters, underscore_array)

      guess = ''
      until guess == 'save' || ('a'..'z').include?(guess)
        print "Please, make a guess or type 'save'\nto save the game: "
        guess = gets.chomp.downcase
        puts "\n"
      end

      check_guess(guess)

      game_over = true if check_game_over
    end
  end
end
