# Codebreaker
Codebreaker homework

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'codebreaker', :git => "https://github.com/amdj15/rg-codebreaker"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install codebreaker

## Usage
Example of console game:

```ruby
require "bundler/setup"
require "codebreaker"

attempts = 5
game = Codebreaker::Game.new(attempts)

loop do
  puts "Enter code:"
  code = gets.chomp

  if code == "?"
    hint = game.hint
    puts hint ? hint : "You've already used all hints"
    next
  end

  begin
    result = game.guess(code)
  rescue Exception => e
    puts e
    next
  end

  puts result

  if result == "Game over"  || result == "++++"
    puts result == "++++" ? "You win!" : "Answer was #{game.secret}"
    puts "Save results? (y/n)"

    if gets.chomp == "y"
      puts "Enter your name:"
      game.save gets.chomp
    end

    puts "Again? (y/n)"
    if gets.chomp == "y"
      game.start attempts
      next
    end
    break
  end
end
```