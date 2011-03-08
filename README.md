# Web Translate It

[Homepage](https://webtranslateit.com) | 
[RDocs](http://yardoc.org/docs/AtelierConvivialite-webtranslateit) | 
[Example app](http://github.com/AtelierConvivialite/rails_example_app) | 
[Report a bug](http://github.com/AtelierConvivialite/webtranslateit/issues) | 
[Support](http://help.webtranslateit.com)

`web_translate_it` is a rubygem providing tools to sync your language files with [Web Translate It](https://webtranslateit.com), a web-based computer-aided translation tool.

![Web Translate It](http://s3.amazonaws.com:80/edouard.baconfile.com/web_translate_it%2Fwti2.png)

This gem provides:

* a command-line executable `wti`, to sync your files between your computer/server and WebTranslateIt.com,
* a synchronisation server to help your translation team update your language files from a web interface,
* a rack middleware you can use within your Rails app to automatically fetch new translations from Web Translate It.

## Installation

These instructions are for Linux and Mac OS X system. Follow [these instructions](http://help.webtranslateit.com/kb/tips/how-to-install-wti-on-windows) if you’re using Microsoft Windows.

    gem install web_translate_it
    
At this point you should have the `wti` executable working.

## Configuration

Now that the tool is installed, you’ll have to configure your project:

    wti init

The tool will prompt for:

* your Web Translate It API key (you can find it in your project settings),
* where to save the configuration file (by default in `config/translations.yml`).

## Usage

Execute `wti --help` to see the usage:

    wti is a command line tool to sync your local translation files
    with the WebTranslateIt.com service.

    Usage:
           wti <command> [options]+
  
    <command> is one of: pull push add addlocale server stats status st autoconf init
    [options] are:
    --config, -c <s>:   Path to a translation.yml file (default:
                        config/translation.yml)
       --version, -v:   Print version and exit
          --help, -h:   Show this message

Here’s more explanation about the commands.

    pull          Pull target language file(s)
    push          Push master language file(s)
    add           Create and push a new master language file
    addlocale     Add a new locale to the project
    server        Start a synchronisation server
    status        Fetch and display project statistics
    init          Configure your project to sync

You can get more information by appending `--help` after each command. For instance:

    $ wti push --help
    Options:
          --locale, -l <s>:   ISO code of a locale to push
                 --all, -a:   Upload all files
        --low-priority, -o:   WTI will process this file with a low priority
               --merge, -m:   Force WTI to merge this file
      --ignore-missing, -i:   Force WTI to not obsolete missing strings
           --label, -b <s>:   Apply a label to the changes
                --help, -h:   Show this message

## Web Translate It Synchronisation Console

![Web Translate It](http://s3.amazonaws.com:80/edouard.baconfile.com/web_translate_it%2Fadmin_console2.png)

The `wti` gem integrates since its version 1.7.0 a sinatra app that provides you with a friendly web interface to sync your translations. It allows a translation team to refresh the language files on a staging server without asking the developers to manually `wti pull`.

To get started, go to the directory of the application you want to sync and do:

    wti server

By default, it starts an application on localhost on the port 4000. You will find the tool on `http://localhost:4000`.

Should you need to use another host or port, you can use the `-h` and `-p` options. For example: `wti server -p 1234`.

You may want to run some commands before or after syncing translations. To do so, add in the `translation.yml` file the following:

    before_pull: "echo 'some unix command'"
    after_pull:  "touch tmp/restart.txt"

`before_pull` and `after_pull` are respectively executed before and after pulling language files.

## Use Cases

Here are some example commands for the most common scenarios.

### Upload a new master language file

    wti add path/to/master/file.po

Create several master language files at once:

    wti add file1.po file2.po file3.xml

Or:

    wti add *.po

After receiving your master language files, Web Translate It will automatically create the corresponding target files. If you have already some translations for these files, use `wti push --all` to synchronise them to Web Translate It.

### Update a master language file

    wti push

### Update a target language file

Update the french language file:

    wti push -l fr
    
Or several languages at once:

    wti push -l "fr en da sv"
   
### Update all language files at once

    wti push --all

### Download target language files

    wti pull
    
### Download a specific language file

    wti pull -l fr
    
### Download all language files, including source

    wti pull --all
    
### Force pull (to bypass Web Translate It’s HTTP caching)

    wti pull --force

### Add a new locale to the project

    wti addlocale fr
    
Or add several locales at once:

    wti addlocale fr da sv

### View project stats

    wti status

# License

Copyright (c) 2009-2011 Atelier Convivialité, released under the MIT License.
