# Web Translate It for Ruby on Rails

This is a gem to integrate your app with [Web Translate It](https://webtranslateit.com).

This gem provides your app with:

* a set of 4 handy rake task to fetch your translations.
* a rack middleware to automatically fetch new translations from Web Translate It.

## First steps

* For each environment you want to use the gem, add to your config/environment/development.rb:

    `config.gem 'web_translate_it', :version => '~> 1.4.0', :source => 'http://gemcutter.org'`
    
* Then, run:

    `rake gems:install`
    
  Web Translate It doesn’t to be unpacked.
    
* Add in your `Rakefile` to add Web Translate It’s rake tasks:

      `require 'web_translate_it/tasks' rescue LoadError`

* Run:

      `rake trans:config`
    
  If it doesn’t exist already, it will create a `config/translation.yml` file that contains:
  
      api_key: SECRET
      ignore_locales: :en
      wti_id1: config/locales/file1_[locale].yml
      wti_id2: config/locales/file2_[locale].yml</pre>

`api_key` is the API key (or token) provided per project by Web Translate It.

`ignore_locales` is an array of symbols, an array of strings, a symbol or a string of locales not to sync with Web Translate It. You usually don’t want to sync your master language files.

`wti_id1` is the id of your *master* language file on Web Translate It. If you only have one language file, then only put this one in the configuration file.

`config/locales/file1_[locale].yml` is the name of your language file on your project. To keep things simple, the gem makes the reasonable assumption that you differentiate your language files using the locale name. For example, you will have `file1_en.yml` for English, and `file1_fr.yml` for French. Replace `en` or `fr` by `[locale]` and the gem will update the files `file1_en.yml` and `file1_fr.yml`.

The gem also assume that you use the same locale name on your project and on Web Translate It. For example if you use the locale `fr_FR` on Web Translate It, then you should use `fr_FR` on your project.

### Rake tasks provided

The gem provides 4 rake tasks.

    rake trans:fetch:all
  
Fetch the latest translations for all your files for all languages defined in Web Translate It’s interface, except for the languages set in `ignore_locales`.

    rake trans:fetch[fr_FR]
  
Fetch the latest translations for all the languages defined in Web Translate It’s interface. It takes the locale name as a parameter

    rake trans:send[fr_FR]
    
Updates the latest translations for all your files in a specific locale defined in Web Translate It’s interface.

    rake trans:version
  
Display the gem version.

### Automatically fetch new language files

This is useful for translators on development and staging environment: you get the strings as soon as they are translated on Web Translate It, but you probably don’t want this on production for performance and reliability reasons.

#### Rails 2.3 and newer

Use the rack middleware!

* Before starting up anything, you need to have a rack middleware setup to assign the value of the current locale to
  `I18n.locale`.
  This is very much specific to your app, this is left as an exercise to the reader. You can inspire yourself from 
  Ryan Tomakyo’s [locale.rb](http://github.com/rack/rack-contrib/blob/master/lib/rack/contrib/locale.rb).
  You can also find an example of a very simple middleware using the `locale` parameter in
  `[examples/locale.rb](http://github.com/AtelierConvivialite/webtranslateit/blob/master/examples/locale.rb)`.

* The next step is to setup the `autofetch` middleware. Add in `config/environments/development.rb` and any other 
  environments you want to autofetch this line:

      config.middleware.use "WebTranslateIt::AutoFetch"
    
* Restart your application, load a page. You should see this in the logs:

      Looking for fr_FR translations...
      Done. Response code: 200
    
* That’s it!

#### Rails older than 2.3 (works also for 2.3 and newer)

* Add the following lines in your `ApplicationController`:

<pre>before_filter :update_locale

def update_locale
  begin
    WebTranslateIt.fetch_translations
  rescue Exception => e
    puts "** Web Translate It raised an exception: " + e.message
  end
end</pre>

* Restart your application for the changes to take effect. You should see something like this in the logs:

      Looking for fr translations...
      Done. Response code: 304

* That’s it!

## Supported Rails Versions

The gem currently has been tested against the following version of Rails:

* 2.3.4
* 2.3.5

Please open a discussion on [the support forum](https://webtranslateit.com/forum) if you're using a version of Rails that is not listed above and the gem is not working properly.

## What is Web Translate It anyway?

Web Translate It is a web-based software for translating websites and applications. Its API it affords you to translate on Web Translate It’s web interface and test your translations on your development or staging environment. This is really useful for translations to translate on a stable environment, while being able to test their work directly.

Take a look at the [tour page](https://webtranslateit.com/tour) and at our [plans](https://webtranslateit.com/plans). We have a 10-day free trial, so you can give it a try for free.

Released under the MIT License.
