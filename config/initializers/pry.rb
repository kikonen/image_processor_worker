# frozen_string_literal: true

if defined? Pry
  Pry.config.color = false

  Pry::Commands.block_command "e!", "Continue from binding.pry" do |x, y, z|
    # @see https://stackoverflow.com/questions/8015531/how-do-i-step-out-of-a-loop-with-ruby-pry
    Pry::Commands.process_line String.new('disable-pry'), context
  end

  if defined?(PryByebug)
    # https://github.com/deivid-rodriguez/pry-byebug
    Pry.commands.alias_command 'c!', 'continue'
    Pry.commands.alias_command 'cc', 'continue'

    Pry.commands.alias_command 's!', 'step'
    Pry.commands.alias_command 'ss', 'step'

    Pry.commands.alias_command 'n!', 'next'
    Pry.commands.alias_command 'nn', 'next'

    # NOTE KI "f" conflicts with "form"
    Pry.commands.alias_command 'f!', 'finish'
    Pry.commands.alias_command 'ff', 'finish'
  end
end
