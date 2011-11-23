Web Translate It
================

[Homepage](https://webtranslateit.com) | 
[RDoc](http://yardoc.org/docs/AtelierConvivialite-webtranslateit) | 
[Example app](http://github.com/AtelierConvivialite/rails_example_app) | 
[Report a bug](http://github.com/AtelierConvivialite/webtranslateit/issues) | 
[Support](http://help.webtranslateit.com)

`web_translate_it` is a rubygem providing tools to sync your language files with [Web Translate It](https://webtranslateit.com), a web-based translation software.

![Web Translate It](http://f.cl.ly/items/2X3m0h0g0I1O1U07163o/wti_example.jpg)

This gem provides:

* a command-line executable `wti`, to sync your files between your computer/server and WebTranslateIt.com,
* a synchronisation server to help your translation team update your language files from a web interface,
* a rack middleware you can use within your Rails app to automatically fetch new translations from Web Translate It.

Installation
------------

You will need ruby to run wti. On Linux or a Mac, it’s already installed. Install [RubyInstaller](http://rubyinstaller.org/) if you’re using Windows.

    gem install web_translate_it
    
At this point you should have the `wti` executable working.

Configuration
-------------

Now that the tool is installed, you’ll have to configure your project:

    wti init

The tool will prompt for:

* your Web Translate It API key. You can find it in your project settings ([where are the project settings?](http://help.webtranslateit.com/kb/troubleshooting/where-are-my-project-settings)),
* where to save the configuration file (by default in `config/translations.yml`).

Usage
-----

Execute `wti --help` to see the usage:

    Usage: wti <command> [options]+
  
    The most commonly used wti commands are:
  
      pull        Pull target language file(s)
      push        Push master language file(s)
      match       Display matching of local files with File Manager
      add         Create and push a new master language file
      addlocale   Add a new locale to the project
      server      Start a synchronisation server
      status      Fetch and display project statistics
      init        Configure your project to sync      

    See `wti <command> --help` for more information on a specific command.
  
    [options] are:
      --config, -c <s>:   Path to a translation.yml file (default: .wti)
         --version, -v:   Print version and exit
            --help, -h:   Show this message

Append `--help` for each command for more information. For instance:

    $ wti push --help
    Push master language file(s)
    [options] are:
          --locale, -l <s>:   ISO code of locale(s) to push
                 --all, -a:   Upload all files
        --low-priority, -o:   WTI will process this file with a low priority
               --merge, -m:   Force WTI to merge this file
      --ignore-missing, -i:   Force WTI to not obsolete missing strings
           --label, -b <s>:   Apply a label to the changes
                --help, -h:   Show this message

Sample Commands
---------------

<table>
  <tr>
    <th>Command</th>
    <th>Action</th>
  </tr>
  <tr>
    <td>wti add path/to/master/file.po</td>
    <td>Upload a new master language file</td>
  </tr>
  <tr>
    <td>wti add file1.po file2.po file3.xml</td>
    <td>Create several master language files at once, by specifying each file</td>
  </tr>
  <tr>
    <td>wti add *.po</td>
    <td>Create several master language files at once, by specifying an extension</td>
  </tr>
  <tr>
    <td>wti push</td>
    <td>Update a master language file</td>
  </tr>
  <tr>
    <td>wti push -l fr</td>
    <td>Update a target (French) language file</td>
  </tr>
  <tr>
    <td>wti push -l "fr en da sv"</td>
    <td>Update several target language files at once (French, English, Danish, Swedish)</td>
  </tr>
  <tr>
    <td>wti push --all</td>
    <td>Update all language files at once</td>
  </tr>
  <tr>
    <td>wti pull</td>
    <td>Download target language files</td>
  </tr>
  <tr>
    <td>wti pull -l fr</td>
    <td>Download a specific language file (French)</td>
  </tr>
  <tr>
    <td>wti pull --all</td>
    <td>Download all language files, including source</td>
  </tr>
  <tr>
    <td>wti pull --force</td>
    <td>Force pull (to bypass Web Translate It’s HTTP caching)</td>
  </tr>
  <tr>
    <td>wti addlocale fr</td>
    <td>Add a new locale to the project</td>
  </tr>
  <tr>
    <td>wti addlocale fr da sv</td>
    <td>Add several locales at once</td>
  </tr>
  <tr>
    <td>wti status</td>
    <td>View project statistics</td>
  </tr>
  <tr>
    <td>wti match</td>
    <td>Show matching between files on local computer and the ones in Web Translate It’s File Manager</td>
  </tr>
</table>

Hooks
-----

It is sometimes useful to hook a command or a script before or after a push or a pull. One use-case would be to launch a build after pulling language files. You can do that by implementing hooks in your `.wti` file.

There are 4 hooks:

* `before_pull`
* `after_pull`
* `before_push`
* `after_push`

Check the [sample `.wti`](https://github.com/AtelierConvivialite/webtranslateit/blob/master/examples/.wti#L9..L13) file for implementation.

Web Translate It Synchronisation Console
----------------------------------------

This feature was extracted out to a separate gem. See [web_translate_it_server](https://github.com/AtelierConvivialite/web_translate_it_server).

# License

Copyright (c) 2009-2011 Atelier Convivialité, released under the MIT License.
