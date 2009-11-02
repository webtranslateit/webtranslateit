Web Translate It plugin for Ruby on Rails
=========================================

This is a plugin to integrate your app with [Web Translate It](https://webtranslateit.com).

When you load a page on your app, the plugin check and fetch your latest translations from Web Translate It.
It allows a team of translators to work on Web Translate It’s web interface and test their translations on your server by just reloading a page.

Please note that this plugin is not finished yet. More improvements are coming shortly.

Installation
------------

From your project's RAILS_ROOT, run:

    ruby script/plugin install git://github.com/AtelierConvivialite/web_translate_it.git

The installation script will create a default translation.yml in RAILS_ROOT/config, it will look like so:

<pre>development:
  api_key: something_secret
  autofetch: true
  locales:
    en: path/to/en/file.yml
    fr: path/to/fr/file.yml</pre>
      
Edit your configuration file to point Web Translate It’s locale. Note that the locales you use in Web Translate It should match the locale used by Rails. If you use en_US in your Rails app, you should use the en_US locale in Web Translate It.

    api_key
  
This is the API key provided per project by Web Translate It.

    autofetch
  
If set to true, the plugin will poll Web Translate It for updating the language files. This is useful on development and staging environment, so your app fetch your strings as soon as they are translated on Web Translate It, but you probably don’t want this on production.

Once this is done, add the following lines in your `ApplicationController`:

<pre>before_filter :update_locale

def update_locale
  begin
    WebTranslateIt.fetch_translations_for(I18n.locale)
  rescue(Error)
    puts "ERROR Web Translate It"
  end
end</pre>

Note that Web Translate It’s API doesn’t yet support projects with more than one file per language. We are working on fixing this limitation. 

That’s it!


`Rake` tasks
------------

The plugin provides 2 rake tasks.

    rake translations:fetch
  
Or its alias:

    rake trans:fetch
  
To fetch the latest translations for all the languages defined in translation.yml.
  
    rake translations:version
  
Or its alias:

    rake trans:version
  
Display the plugin version.

Supported Rails Versions
------------------------

The plugin currently has been tested against the following version of Rails:

* 2.3.4

Please open a discussion on [Get Satisfaction](http://getsatisfaction.com/atelier_convivialite/products/atelier_convivialite_web_translate_it) if you're using a version of Rails that is not listed above and the notifier is not working properly.

What is Web Translate It anyway?
--------------------------------

Web Translate It is a web-based software for translating websites and applications. Its API it affords you to translate on Web Translate It’s web interface and test your translations on your development or staging environment. This is really useful for translations to translate on a stable environment, while being able to test their work directly.

Take a look at the [tour page](https://webtranslateit.com/tour) and at our [plans](https://webtranslateit.com/plans). We have a 30-day free trial, so you can give it a try for free.
