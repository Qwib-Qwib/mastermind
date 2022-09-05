# frozen_string_literal: false

# Add colorization features to strings and their backgrounds in the terminal.
class String
  def stylize(option)
    case option
    when 'bold' then "\e[1m#{self}\e[0m"
    when 'dim' then "\e[2m#{self}\e[0m"
    when 'underlined' then "\e[4m#{self}\e[0m"
    when 'blinking' then "\e[5m#{self}\e[0m"
    when 'inverted_colors' then "\e[7m#{self}\e[0m"
    when 'hidden' then "\e[8m#{self}\e[0m"
    end
  end

  def colorize(color)
    case color
    when 'black' then "\e[30m#{self}\e[0m"
    when 'red' then "\e[31m#{self}\e[0m"
    when 'green' then "\e[32m#{self}\e[0m"
    when 'yellow' then "\e[33m#{self}\e[0m"
    when 'blue' then "\e[34m#{self}\e[0m"
    when 'magenta' then "\e[35m#{self}\e[0m"
    when 'cyan' then "\e[36m#{self}\e[0m"
    when 'light gray' then "\e[37m#{self}\e[0m"
    when 'dark gray' then "\e[90m#{self}\e[0m"
    when 'light red' then "\e[91m#{self}\e[0m"
    when 'light green' then "\e[92m#{self}\e[0m"
    when 'light yellow' then "\e[93m#{self}\e[0m"
    when 'light blue' then "\e[94m#{self}\e[0m"
    when 'light magenta' then "\e[95m#{self}\e[0m"
    when 'light cyan' then "\e[96m#{self}\e[0m"
    when 'white' then "\e[97m#{self}\e[0m"
    end
  end

  def colorize_background(color)
    case color
    when 'black' then "\e[40m#{self}\e[0m"
    when 'red' then "\e[41m#{self}\e[0m"
    when 'green' then "\e[42m#{self}\e[0m"
    when 'yellow' then "\e[43m#{self}\e[0m"
    when 'blue' then "\e[44m#{self}\e[0m"
    when 'magenta' then "\e[45m#{self}\e[0m"
    when 'cyan' then "\e[46m#{self}\e[0m"
    when 'light gray' then "\e[47m#{self}\e[0m"
    when 'dark gray' then "\e[100m#{self}\e[0m"
    when 'light red' then "\e[101m#{self}\e[0m"
    when 'light green' then "\e[102m#{self}\e[0m"
    when 'light yellow' then "\e[103m#{self}\e[0m"
    when 'light blue' then "\e[104m#{self}\e[0m"
    when 'light magenta' then "\e[105m#{self}\e[0m"
    when 'light cyan' then "\e[106m#{self}\e[0m"
    when 'white' then "\e[107m#{self}\e[0m"
    end
  end

  def colorize_custom(color_code)
    "\e[38;5;#{color_code}m#{self}\e[0m"
  end

  def colorize_background_custom(color_code)
    "\e[48;5;#{color_code}m#{self}\e[0m"
  end

  def self.string_colorizer_help
    puts ''
    puts 'Welcome to the help menu for the string-colorizer gem!'
    puts ''
    puts 'List of methods:'.stylize("underlined")
    puts 'stylize'.stylize("bold") + '(style)'.colorize("cyan")  + ':'.stylize("bold") + ' Affixes a style option to the string upon which the method is called.'
    puts 'stylize(style):'.stylize("hidden") + ' The option is passed as an argument. They are as follows:'
    puts 'stylize(style):'.stylize("hidden") + ' bold, dim, blinking, underlined, inverted_colors, hidden.'
    puts ''
    puts 'colorize'.stylize("bold") + '(color)'.colorize("cyan")  + ':'.stylize("bold") + ' Affixes a preset color option to the string upon which the method is called.'
    puts 'colorize(color):'.stylize("hidden") + ' The option is passed as an argument. They are as follows:'
    puts 'colorize(color):'.stylize("hidden") + ' black, red, green, yellow, blue, magenta, cyan, light gray, dark gray, light red, light green, light yellow, light blue, light magenta, light cyan, white.'
    puts ''
    puts 'colorize_background'.stylize("bold") + '(color)'.colorize("cyan") + ':'.stylize("bold") + ' Affixes a preset color option to the background of the string upon which the method is called.'
    puts 'colorize_background(color):'.stylize("hidden") + ' The option is passed as an argument. They are as follows:'
    puts 'colorize_background(color):'.stylize("hidden") + ' black, red, green, yellow, blue, magenta, cyan, light gray, dark gray, light red, light green, light yellow, light blue, light magenta, light cyan, white.'
    puts ''
    puts 'colorize_custom'.stylize("bold") + '(color_code)'.colorize("cyan") + ':'.stylize("bold") + ' Affixes a custom color option to the string upon which the method is called.'
    puts 'colorize_custom(color_code):'.stylize("hidden") + ' The custom option is passed as an argument. It is a numerical code between 0 and 256 (included).'
    puts ''
    puts 'colorize_background_custom'.stylize("bold") + '(color_code)'.colorize("cyan") + ':'.stylize("bold") + ' Affixes a custom color option to the background of the string upon which the method is called.'
    puts 'colorize_background_custom(color_code):'.stylize("hidden") + ' The custom option is passed as an argument. It is a numerical code between 0 and 256 (included).'
  end
end
