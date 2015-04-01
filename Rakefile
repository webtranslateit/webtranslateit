# encoding: utf-8
require "bundler/gem_tasks"

WEB_TRANSLATE_API_KEY = "a5WmeDxtA0oA9-Myyi32sw"

namespace :translate do

  desc "translate:pull - Pulls down latest iWebTranslate translations"
  task :pull do
    sh "wti init #{WEB_TRANSLATE_API_KEY}"
    sh "wti pull -t apple_strings -o Unii/Resources/Languages/%locale%.lproj/Localizable%extension%"
  end

end
