Web Translate It plugin for Ruby on Rails
=========================================

This is a plugin to integrate your app with [Web Translate It](https://webtranslateit.com).

This plugin adds a handy rake task to fetch your translations. If you want, you can also setup the plugin to “autofetch” your translations on page load. This feature allows a team of translators to work on Web Translate It’s web interface and test their translations on your server by just reloading a page.

Installation
------------

From your project's RAILS_ROOT, run:

    ruby script/plugin install git://github.com/AtelierConvivialite/webtranslateit.git

The installation script will create a default translation.yml in RAILS_ROOT/config. The file should look like so:

<pre>api_key: SECRET
ignore_locales: :en
wti_id1: config/locales/file1_[locale].yml
wti_id2: config/locales/file2_[locale].yml
development:
  autofetch: true</pre>

`api_key`
  
This is the API key provided per project by Web Translate It.

`ignore_locales`
  
Pass an array of symbols, an array of strings, a symbol or a string of locales not to sync with Web Translate It. You usually don’t want to sync your master language files.

`wti_id1: config/locales/file1_[locale].yml`
    
`wti_id1` is the id of your *master* language file on Web Translate It. If you only have one language file, then only put this one in the configuration file.

`config/locales/file1_[locale].yml` is the name of your language file on your project. To keep things simple, the plugin makes the reasonable assumption that you differentiate your language files using the locale name. For example, you will have `file1_en.yml` for English, and `file1_fr.yml` for French. Replace `en` or `fr` by `[locale]` and the plugin will update the files `file1_en.yml` and `file1_fr.yml`.

The plugin also assume that you use the same locale name on your project and on Web Translate It. For example if you use the locale `fr_FR` on Web Translate It, then you should use `fr_FR` on your project.

`autofetch:true`
  
If set to true, the plugin will check the Web Translate It API on every page loaded and check for updated language files. The plugin use conditional requests using the date of last modification of your language file. It means that if your language file is up to date, Web Translate It’s API will return nothing, so querying on every page loaded is not too slow.

This is useful for translators on development and staging environment: you get the strings as soon as they are translated on Web Translate It, but you probably don’t want this on production for performance and reliability reasons.

Add the following lines in your `ApplicationController` if you want to use the “autofetch” feature:

<pre>before_filter :update_locale

def update_locale
  begin
    WebTranslateIt.fetch_translations
  rescue Exception => e
    puts "** Web Translate It raised an exception: " + e.message
  end
end</pre>

Restart your application for the changes to take effect. You should see something like this in the logs:

<pre>Looking for fr translations...
Done. Response code: 304</pre>

Note that Web Translate It’s API doesn’t yet support projects with more than one file per language. We are working on fixing this limitation. 

That’s it!


Rake tasks
------------

The plugin provides 3 rake tasks.

    rake trans:fetch:all
  
Fetch the latest translations for all your files for all languages defined in Web Translate It’s interface, except for the languages set in `ignore_locales`.

    rake trans:fetch[fr_FR]
  
Fetch the latest translations for all the languages defined in Web Translate It’s interface. It takes the locale name as a parameter
  
    rake trans:version
  
Display the plugin version.

Supported Rails Versions
------------------------

The plugin currently has been tested against the following version of Rails:

* 2.3.4
* 2.3.5

Please open a discussion on [the support forum](https://webtranslateit.com/forum) if you're using a version of Rails that is not listed above and the plugin is not working properly.

What is Web Translate It anyway?
--------------------------------

Web Translate It is a web-based software for translating websites and applications. Its API it affords you to translate on Web Translate It’s web interface and test your translations on your development or staging environment. This is really useful for translations to translate on a stable environment, while being able to test their work directly.

Take a look at the [tour page](https://webtranslateit.com/tour) and at our [plans](https://webtranslateit.com/plans). We have a 10-day free trial, so you can give it a try for free.
