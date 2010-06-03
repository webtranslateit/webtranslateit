# Web Translate It

[Homepage](https://webtranslateit.com) | 
[RDocs](http://yardoc.org/docs/AtelierConvivialite-webtranslateit) | 
[Example app](http://github.com/AtelierConvivialite/rails_example_app) | 
[Report a bug](http://github.com/AtelierConvivialite/webtranslateit/issues) | 
[Support](http://help.webtranslateit.com)
[Documentation](http://docs.webtranslateit.com/web_translate_it_client/)

This is a gem providing tools to sync your software’s language files with [Web Translate It](https://webtranslateit.com), a web-based computer-aided translation tool.

![Web Translate It](http://s3.amazonaws.com:80/edouard.baconfile.com/web_translate_it%2Fwti.png)

This gem provides your app with:

* an executable, `wti`, that will help you to upload and download language files from the command line (or in whatever else you want to execute it),
* a handful of rake task to fetch and upload your translations,
* a Sinatra app to help you download your translations from a web-based interface,
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

## Generalities

The first time, you’ll have to configure your project:

    wti autoconf
    
It will ask for your Web Translate It API key, and where to save its configuration file. Letting it put in `config/translations.yml` makes everything easier.

### Uploading your first language file

If you have no file on Web Translate It yet, you need to send us your master language files. You can do it from the web interface, or from the command line:

    wti add path/to/master/file.po

That’s it! Web Translate It will automatically create the corresponding target files.

### Updating a master language file

    wti push

### Updating a target language file

    wti push -l fr
   
where fr should be replaced by the locale code of your file.

### Download target language files

    wti pull
    
### Download a specific language file

    wti pull -l fr
    
### Download all the language files

    wti pull --all
    
### Force pull (bypasses Web Translate It’s HTTP caching)

    wti pull --force

### View project stats

    wti stats
    
## Web Translate It Synchronisation Console

![Web Translate It](http://s3.amazonaws.com:80/edouard.baconfile.com/web_translate_it%2Fadmin_console.png)

The `wti` gem integrates since its version 1.7.0 a sinatra back-end that allow you to sync your translations directly from a friendly web interface. It allows a translation team to refresh the language files on a staging server without having to ask the developers to manually `wti pull`.

To get started, go to the directory of the application you want to sync and do:

    wti server
    
By default, it starts an application on localhost on the port 4000. You will find the tool on `http://localhost:4000`.

Should you need to use another host or port, you can use the -h and -p options. For example: `wti server -p 1234`.

You may want to run some commands before or after synching translations. To do so, add in the `translation.yml` file the following:

    before_pull: "echo 'some unix command'"
    after_pull:  "touch tmp/restart.txt"
    
`before_pull` and `after_pull` will respectively be executed before and after pulling your language files.

## Rake tasks

This gem includes some rake tasks and a rack middleware you could use to integrate Web Translate It with Ruby on Rails. The rake tasks are significantly slower than the executable, since it has to load the whole rails stack.

* Add to your config/environments.rb:

    `config.gem 'web_translate_it'`
    
* Then, run:

    `rake gems:install`

* If you did not already did `wti autoconf`, copy your API key from Web Translate It and run:

    `script/generate webtranslateit --api-key your_key_here`
    
  The generator does two things:
  
  - It adds a auto-configured `config/translation.yml` file using Web Translate It’s API.
  - It adds `require 'web_translate_it/tasks' rescue LoadError` to your `Rakefile`
  
There are 3 rake tasks.

    rake trans:fetch:all
  
Fetch the latest translations for all your files for all languages defined in Web Translate It’s interface, except for the languages set in `ignore_locales`.

    rake trans:fetch[fr_FR]
  
Fetch the latest translations for all the languages defined in Web Translate It’s interface. It takes the locale name as a parameter

    rake trans:upload[fr_FR]
    
Upload to Web Translate It your files in a specific locale defined in Web Translate It’s interface.

Read more about [Rails integration in the wiki](http://wiki.github.com/AtelierConvivialite/webtranslateit/).

### Supported Rails Versions

The gem currently has been tested against the following versions of Rails:

* 2.3.4
* 2.3.5

Please open a discussion on [our support site](http://help.webtranslateit.com) if you're using a version of Rails that is not listed above and the gem is not working properly.

# Acknowledgement

* The executable’s commands are very much inspired from [Gemcutter](http://gemcutter.org),
* The Rails generator was pinched from [Hoptoad Notifier](http://github.com/thoughtbot/hoptoad_notifier),
* The idea of a web-app to sync translations with Web Translate It come from Tom Lea’s awesome [rack-webtranslateit](http://github.com/cwninja/rack-webtranslateit),
* The Sinatra app is much inspired from Chris Wanstrath’s [CI Joe](http://github.com/defunkt/cijoe).

# What is Web Translate It anyway?

Web Translate It is a web-based translation tool to collaboratively translate software.

To learn more about it, please visit our [tour page](https://webtranslateit.com/tour).

This gem is released under the MIT License.
