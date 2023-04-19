# frozen_string_literal: true

# Mostly pinched from http://github.com/ryanb/nifty-generators/tree/master

Rails::Generator::Commands::Base.class_eval do
  def file_contains?(relative_destination, line)
    File.read(destination_path(relative_destination)).include?(line)
  end
end

Rails::Generator::Commands::Create.class_eval do
  def append_to(file, line)
    logger.insert "#{line} appended to #{file}"
    return if options[:pretend] || file_contains?(file, line)

    File.open(file, 'a') do |f|
      f.puts
      f.puts line
    end
  end
end

Rails::Generator::Commands::Destroy.class_eval do
  def append_to(file, line)
    logger.remove "#{line} removed from #{file}"
    gsub_file file, "\n#{line}", '' unless options[:pretend]
  end
end

Rails::Generator::Commands::List.class_eval do
  def append_to(file, line)
    logger.insert "#{line} appended to #{file}"
  end
end
