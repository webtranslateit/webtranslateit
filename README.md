# Web Translate It

[Homepage](https://webtranslateit.com) | 
[RDocs](http://yardoc.org/docs/AtelierConvivialite-webtranslateit) | 
[Example app](http://github.com/AtelierConvivialite/rails_example_app) | 
[Report a bug](http://github.com/AtelierConvivialite/webtranslateit/issues) | 
[Support](http://help.webtranslateit.com) | 
[Documentation](http://docs.webtranslateit.com/web_translate_it_client/)

`web_translate_it` is a rubygem providing tools to sync your language files with [Web Translate It](https://webtranslateit.com), a web-based computer-aided translation tool.

![Web Translate It](http://s3.amazonaws.com:80/edouard.baconfile.com/web_translate_it%2Fwti2.png)

This gem provides 4 tools:

* an executable, `wti`, that will help you to upload and download language files from the command line,
* a synchronisation server to help your translation team update your language files from a web-based interface,
* a handful of rake task you can use with your Ruby on Rails application,
* a rack middleware to automatically fetch new translations from Web Translate It.

## Installation

(Using [Microsoft Windows](http://help.webtranslateit.com/kb/tips/how-to-install-wti-on-windows)?)

    gem install web_translate_it
    
At this point you should have the `wti` executable working.
If your project if already set up on Web Translate It, open a terminal and type `wti autoconf` to generate the configuration file.

Execute `wti --help` to see the usage:

    Usage: wti [-lcphhv]
            pull                         Pull target language file(s)
            push                         Push master language file(s)
            add                          Create and push a new master language file
            addlocale                    Add a new locale to the project
            server                       Start a synchronisation server
            stats                        Fetch and display project statistics
            autoconf                     Configure your project to sync

    Synchronization options: 
        -l, --locale                     ISO code of a locale to pull or push
        -c, --config                     Path to a translation.yml file
                                         (default: config/translation.yml)
            --all                        Download or upload all files
            --force                      Force wti pull to download files
            --merge                      Force WTI to merge this file
            --ignore_missing             Force WTI to not obsolete missing strings
            --low_priority               Tells WTI to process this command with a low priority
            --label                      Apply a label to the changes

    Server options: 
        -p, --port                       Run server on a specific port
                                         (default: 4000)
        -h, --host                       Run server on a specific host
                                         (default: localhost)

    Other options: 
        -h, --help                       Show this message
        -v, --version                    Show version

## Configuration

Now that the tool is installed, you’ll have to configure your project:

    wti autoconf

It will ask for your Web Translate It API key, and where to save its configuration file. Letting it put in `config/translations.yml` makes everything easier.

## Usage

### Uploading your first language file

If you have no file on Web Translate It yet, you need to send us your master language files. You can do it from the web interface, or from the command line:

    wti add path/to/master/file.po

You can also add several files at once:

    wti add file1.po file2.po file3.xml

Or

    wti add *.po

After receiving your master language files, Web Translate It will automatically create the corresponding, empty target files. If you have already some translations for these files, use `wti push --all` to synchronise them to Web Translate It.

### Updating a master language file

    wti push

### Updating a target language file

    wti push -l fr
   
where `fr` should be replaced by the locale code of your file.

### Updating all language files

    wti push --all

### Download target language files

    wti pull
    
### Download a specific language file

    wti pull -l fr
    
### Download all the language files

    wti pull --all
    
### Force pull (bypass Web Translate It’s HTTP caching)

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
* 2.3.10

Please open a discussion on [our support site](http://help.webtranslateit.com) if you're using a version of Rails that is not listed above and the gem is not working properly.

# License

Copyright (c) 2009-2011 Atelier Convivialité, and released under the MIT License.
