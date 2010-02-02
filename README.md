# Web Translate It

[RDocs](http://yardoc.org/docs/AtelierConvivialite-webtranslateit) | [Metrics](http://getcaliper.com/caliper/project?repo=git%3A%2F%2Fgithub.com%2FAtelierConvivialite%2Fwebtranslateit.git) | [Tests](http://runcoderun.com/AtelierConvivialite/webtranslateit/builds/74a78c2b382cb1856fa0964ed4ad372b50872844/1/ruby_186) |
[Example app](http://github.com/AtelierConvivialite/rails_example_app)

This is a gem providing tools to integrate your app with [Web Translate It](https://webtranslateit.com).

This gem provides your app with:

* a handful of rake task to fetch your translations.
* a rack middleware to automatically fetch new translations from Web Translate It.

## First steps

* Add to your `config/environments.rb`:

    `config.gem 'web_translate_it'`
    
* Then, run:

    `rake gems:install`
    
  Web Translate It doesn’t to be unpacked.
    
* Copy/paste your api key from Web Translate It and run:

    `script/generate webtranslateit --api-key your_key_here`
    
  It will configure your project with the parameters you set in Web Translate It, using the API, and create a `config/translation.yml` file.
  
* TODO: require this automatically. Add to your `Rakefile`:
  
    `require 'web_translate_it/tasks' rescue LoadError`

### Rake tasks provided

The gem provides 4 rake tasks.

    rake trans:fetch:all
  
Fetch the latest translations for all your files for all languages defined in Web Translate It’s interface, except for the languages set in `ignore_locales`.

    rake trans:fetch[fr_FR]
  
Fetch the latest translations for all the languages defined in Web Translate It’s interface. It takes the locale name as a parameter

    rake trans:upload[fr_FR]
    
Upload to Web Translate It your files in a specific locale defined in Web Translate It’s interface.

    rake trans:config
    
Copy a `translation.yml` file to `config/translation.yml` if the file doesn’t exist.

### Automatically fetch new language files

This is useful for translators on development and staging environment: you get the strings as soon as they are translated on Web Translate It, but you probably don’t want this on production for performance and reliability reasons.

#### Rails 2.3 and newer

Use the rack middleware!

* Before starting up anything, you need to have a rack middleware setup to assign the value of the current locale to
  `I18n.locale`.
  This is very much specific to your app, this is left as an exercise to the reader. You can inspire yourself from 
  Ryan Tomakyo’s [locale.rb](http://github.com/rack/rack-contrib/blob/master/lib/rack/contrib/locale.rb).
  You can also find an example of a very simple middleware using the `locale` parameter in
  [examples/locale.rb](http://github.com/AtelierConvivialite/webtranslateit/blob/master/examples/locale.rb).

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
