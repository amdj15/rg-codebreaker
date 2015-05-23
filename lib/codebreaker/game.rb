module Codebreaker
  class Game
    attr_accessor :secret, :attempts

    def initialize attempts = 5
      start attempts
    end

    def start attempts
      @secret = 4.times.map { Random.new.rand(1..6) }.join
      @attempts = attempts
      @allowed_hints = @secret.split("")
      @win = false;
      @turns = 0;
    end

    def guess assumption
      raise "Validation error" unless valid? assumption

      @turns += 1
      if assumption == @secret
        @win = true
        return "++++"
      end

      output = [];
      assumption.each_char.with_index { |char, i| output << "+" &&  assumption.tr!(char, "") if @secret[i] == char }
      assumption.each_char.with_index { |char, i| output << "-" if @secret.match char }

      @attempts -= 1
      return "Game over" if output.join != "++++" && @attempts < 1

      output.join
    end

    def hint
      indx = Random.new.rand(0..(@allowed_hints.size-1 < 0 ? 0 : @allowed_hints.size-1))
      hint = @allowed_hints[indx]
      @allowed_hints.delete_at(indx)

      return hint
    end

    def save name, path = ''
      path = path.gsub(/\/+$/, "") << (path.size > 0 ? "/" : "") << 'data'

      begin
        history = Marshal.load(File.open(path));
      rescue
        history = Hash.new
      end

      history[name] = {
        win: @win,
        name: name,
        turns: @turns
      }

      File.open(path, "w") { |file| Marshal.dump(history, file) }
    end

    private
    def valid? code
      code.match(/^[1-6]{4}$/) ? true : false
    end
  end
end