module Codebreaker
  class Game
    attr_accessor :secret, :attempts_left

    SIZE = 4

    def initialize attempts = 5
      start attempts
    end

    def start attempts
      @secret = SIZE.times.map { Random.new.rand(1..6) }.join
      @attempts_left = attempts
      @max_attempts = attempts
      @allowed_hints = @secret.split("")
      @win = false;
    end

    def guess assumption
      raise "Validation error" unless valid? assumption

      if assumption == @secret
        @win = true
        return "++++"
      end

      output = []
      secret = @secret.clone

      assumption.each_char.with_index do |char, i|
        if secret[i] == char
          output << "+"
          secret[i] = "_"
          assumption[i] = "_"
        end
      end

      secret.tr!("_", "")
      assumption.tr!("_", "")

      assumption.split("").each.with_index do |char, i|
        if secret.match char
          secret[secret.index(char)] = '_'
          output << "-"
        end
      end

      @attempts_left -= 1
      return "Game over" if @attempts_left < 1

      output.join
    end

    def hint
      indx = Random.new.rand(0..(@allowed_hints.size-1 < 0 ? 0 : @allowed_hints.size-1))
      hint = @allowed_hints[indx]
      @allowed_hints.delete_at(indx)

      return hint
    end

    def hints?
      @allowed_hints.size > 0
    end

    def save name, path = ''
      path = path.gsub(/\/+$/, "") << (path.size > 0 ? "/" : "") << 'data'

      history = self.class.load path

      history << {
        win: @win,
        name: name,
        attempts: @max_attempts - @attempts_left,
        hints_used: SIZE - @allowed_hints.size
      }

      write_to_file history, path
    end

    def self.load path
      begin
        Marshal.load(File.open(path));
      rescue
        Array.new
      end
    end

    def won?
      @win
    end

    def lost?
      @win ||  @attempts_left <= 0
    end

    private
    def valid? code
      code.match(/^[1-6]{4}$/) ? true : false
    end

    def write_to_file history, path
      f = File.open(path, "w")
      Marshal.dump(history, f)
      f.close
    end
  end
end