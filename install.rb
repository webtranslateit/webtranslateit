require 'ftools'

# Pinched from http://github.com/ryanb/nifty-generators/tree/master
def insert_into(file, line)
  logger.insert "#{line} into #{file}"
  unless options[:pretend] || file_contains?(file, line)
    gsub_file file, /^(class|module) .+$/ do |match|
      "#{match}\n  #{line}"
    end
  end
end

File.cp File.join(File.dirname(__FILE__), 'tasks', 'translation_example.yml'),  File.join(RAILS_ROOT, 'config', 'translation.yml')
puts "Added ./config/translation.yml"

puts "To finish the installation, add the following in your ApplicationController:"
puts
puts "before_filter :update_locale"
puts
puts "def update_locale"
puts "  begin"
puts "    WebTranslateIt.fetch_translations"
puts "  rescue Exception => e"
puts "    puts \"** Web Translate It raised an exception: \" + e.message"
puts "  end"
puts "end"
