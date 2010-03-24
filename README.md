# Web Translate It

[Homepage](https://webtranslateit.com) | 
[RDocs](http://yardoc.org/docs/AtelierConvivialite-webtranslateit) | 
[Metrics](http://getcaliper.com/caliper/project?repo=git%3A%2F%2Fgithub.com%2FAtelierConvivialite%2Fwebtranslateit.git) | 
[Example app](http://github.com/AtelierConvivialite/rails_example_app) | 
[Report a bug](http://github.com/AtelierConvivialite/webtranslateit/issues) | 
[Support](http://help.webtranslateit.com)

This is a gem providing tools to sync your software’s language files with [Web Translate It](https://webtranslateit.com), a web-based computer-aided translation tool.

![Web Translate It](http://s3.amazonaws.com:80/edouard.baconfile.com/web_translate_it%2Fwti.png)

This gem provides your app with:

* an executable, `wti`, to upload and download language files from the command line (or in whatever else you want to execute it)
* a handful of rake task to fetch and upload your translations.
* a rack middleware to automatically fetch new translations from Web Translate It.

## Installation

    gem install web_translate_it
    
At this point you should have the `wti` executable working.
If your project if already set up on Web Translate It, open a terminal and type `wti autoconf` to generate the configuration file.

Run `wti --help` to see the usage:

    pull            Pull target language file(s) from Web Translate It.
    push            Push master language file(s) to Web Translate It.
    autoconf        Configure your project to sync with Web Translate It.
    stats           Fetch and display your project statistics.

    OPTIONAL PARAMETERS:
    --------------------
    -l --locale     The ISO code of a specific locale to pull or push.
    -c --config     Path to a translation.yml file. If this option
                    is absent, looks for config/translation.yml.
    --all           Respectively download or upload all files.
    --force         Force wti pull to re-download the language file,
                    regardless if local version is current.
    OTHER:
    ------
    -v --version    Show version.
    -h --help       This page.

## Specific tools for Ruby on Rails

This gem includes some rake tasks and a rack middleware to integrate Web Translate It with Ruby on Rails.

* Add to your config/environments.rb:

    `config.gem 'web_translate_it'`
    
* Then, run:

    `rake gems:install`

* Copy/paste your API key from Web Translate It and run:

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

* The executable’s commands are very much inspired from [Gemcutter](http://gemcutter.org/),
* The Rails generator was pinched from [Hoptoad Notifier](http://github.com/thoughtbot/hoptoad_notifier/).

# What is Web Translate It anyway?

Web Translate It is a web-based translation tool to collaboratively translate software.

To learn more about it, please visit our [tour page](https://webtranslateit.com/tour).

This gem is released under the MIT License.
