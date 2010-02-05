# Web Translate It

[Homepage](https://webtranslateit.com) | 
[RDocs](http://yardoc.org/docs/AtelierConvivialite-webtranslateit) | 
[Metrics](http://getcaliper.com/caliper/project?repo=git%3A%2F%2Fgithub.com%2FAtelierConvivialite%2Fwebtranslateit.git) | 
[Tests](http://runcoderun.com/AtelierConvivialite/webtranslateit/builds/74a78c2b382cb1856fa0964ed4ad372b50872844/1/ruby_186) | 
[Example app](http://github.com/AtelierConvivialite/rails_example_app)

This is a gem providing tools to integrate your software to translate with [Web Translate It](https://webtranslateit.com), a web-based translation hub.

This gem provides your app with:

* an executable, `wti`, to upload and download language files from the command line (or in whatever else you want to execute it)
* a handful of rake task to fetch and upload your translations.
* a rack middleware to automatically fetch new translations from Web Translate It.

## Installation

    gem install web_translate_it
    
That’s it! At this point you have the Web Translate It executable. Run `wti --help` to see the usage:

    Web Translate It Help:
    **********************
    pull            Pull language file(s) from Web Translate It.
    push            Push language file(s) to Web Translate It.

    OPTIONAL PARAMETERS:
    --------------------
    -l --locale     The ISO code of a specific locale to pull or push.
    -c --config     Path to a translation.yml file. If this option
                    is absent, looks for config/translation.yml.
    --force         Force `wti pull` to re-download the language file,
                    regardless if local version is current.
    OTHER:
    ------
    -v --version    Show version.
    -h --help       This page.

### Assumptions

We assume you have a `config/translation.yml` file in your project containing the configuration to sync with Web Translate It. [Read about the configuration file in the wiki](http://wiki.github.com/AtelierConvivialite/webtranslateit/).

## Specific tools for Ruby on Rails

This gem includes some rake tasks and a rack middleware to integrate Web Translate It with Ruby on Rails.

* Add to your config/environments.rb:

    `config.gem 'web_translate_it'`
    
* Then, run:

    `rake gems:install`

* Copy/paste your api key from Web Translate It and run:

    `script/generate webtranslateit --api-key your_key_here`
    
  The generator does two things:
  
  - It adds a auto-configured `config/translation.yml` file using Web Translate It’s API.
  - It adds `require 'web_translate_it/tasks' rescue LoadError` to your `Rakefile`
  
### Rake tasks provided

There are 3 rake tasks.

    rake trans:fetch:all
  
Fetch the latest translations for all your files for all languages defined in Web Translate It’s interface, except for the languages set in `ignore_locales`.

    rake trans:fetch[fr_FR]
  
Fetch the latest translations for all the languages defined in Web Translate It’s interface. It takes the locale name as a parameter

    rake trans:upload[fr_FR]
    
Upload to Web Translate It your files in a specific locale defined in Web Translate It’s interface.

Read more about [Rails integration in the wiki](http://wiki.github.com/AtelierConvivialite/webtranslateit/).


## Supported Rails Versions

The gem currently has been tested against the following versions of Rails:

* 2.3.4
* 2.3.5

Please open a discussion on [our support site](http://help.webtranslateit.com) if you're using a version of Rails that is not listed above and the gem is not working properly.

# Acknowledgement

* The executable is very much inspired from the awesome [Gemcutter](http://gemcutter.org/) commands,
* The Rails generator has been pinched from [Hoptoad Notifier](http://github.com/thoughtbot/hoptoad_notifier/).

# What is Web Translate It anyway?

Web Translate It is a web-based translation hub to collaboratively translate software.

To learn more about it, please visit our [tour page](https://webtranslateit.com/tour).

This gem is released under the MIT License.
