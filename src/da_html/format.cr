
module DA_HTML

  module Format

    SPACE = ' '.hash
    NL    = '\n'.hash

    struct Stream

      getter codes : Array(Int32)
      @last_i : Int32

      def initialize(raw : String)
        @i      = 0
        @codes  = raw.codepoints
        @last_i = @codes.size - 1
      end # === def initialize

      def current
        @codes[@i]
      end # === def current

      def new_line?
        return false if fin?
        current == NL
      end # === def new_line?

      def skip_whitespace
        return self if fin?
        if current != SPACE && current != NL
          raise Exception.new("Current char is not a space: #{current.chr.inspect}")
        end
        @i += 1
        return self
      end

      def grab_until_eol
        word = IO::Memory.new
        while !fin?
          ichar = codes[@i]
          break if ichar == NL
          word << ichar.chr
          @i += 1
        end
        word.to_s
      end # === def grab_until_eol

      def grab_word
        word = IO::Memory.new
        while !fin?
          ichar = codes[@i]
          break if ichar == SPACE || ichar == NL
          word << ichar.chr
          @i += 1
        end

        raise Exception.new("Empty word.") if word.empty?
        word.to_s
      end # === def grab_word

      def fin?
        @i > @last_i
      end # === def fin?

    end # === struct Stream

    extend self

    def to_doc(raw : String)
      codes  = Stream.new(raw)
      doc    = Doc.new

      while !codes.fin?
        instruct = codes.grab_word
        codes.skip_whitespace

        case instruct
        when "open-tag", "close-tag"
          doc << {instruct, codes.grab_word}

        when "attr"
          name = codes.grab_word
          codes.skip_whitespace
          val  = codes.grab_word

          doc << {"attr", name, val}

        when "text"
          doc << {"text", codes.grab_until_eol}

        else
          raise Exception.new("Unknown instruction: #{instruct.inspect}")

        end # === case

        next if codes.fin?
        if codes.new_line?
          codes.skip_whitespace
        else
          raise Exception.new("Unknown character: #{codes.current.chr.inspect}")
        end
      end # === loop

      doc
    end # === def initialize


  end # === module Format

end # === module DA_HTML
