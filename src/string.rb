class String
  alias replace initialize_copy
  alias slice []

  def %(args)
    positional_args = Array(args)
    args = Array(args).dup
    index = 0
    format = chars
    result = []
    positional_args_used = false

    append = ->(format, arg: nil) {
      case format
      when 'd'
        result << (arg || args.shift).to_s
      when 'b'
        result << (arg || args.shift).to_s(2)
      when 'x'
        result << (arg || args.shift).to_s(16)
      when 's'
        result << (arg || args.shift).to_s
      when '%'
        result << '%'
      when "\n"
        result << "%\n"
      when "\0"
        result << "%\0"
      when ' '
        raise ArgumentError, 'invalid format character - %'
      when nil
        raise ArgumentError, 'incomplete format specifier; use %% (double %) instead'
      else
        raise ArgumentError, "malformed format string - %#{format}"
      end
    }

    while index < format.size
      c = format[index]
      case c
      when '%'
        index += 1
        f = format[index]
        case f
        when '0'..'9'
          d = f
          position = 0
          begin
            position = position * 10 + d.to_i
            index += 1
            d = format[index]
          end while ('0'..'9').cover?(d)
          case d
          when '$' # position
            index += 1
            positional_args_used = true
            if (f = format[index])
              append.(f, arg: positional_args[position - 1])
            else
              result << '%'
            end
          else
            raise 'todo'
          end
        else
          append.(f)
        end
      else
        result << c
      end
      index += 1
    end

    if $DEBUG && args.any? && !positional_args_used
      raise ArgumentError, 'too many arguments for format string'
    end

    result.join
  end
end
