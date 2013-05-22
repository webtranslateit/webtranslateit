# WebTranslateIt Synchronization Tool : wti

[RubyDoc](http://rubydoc.info/github/AtelierConvivialite/webtranslateit/) | 
[Report a bug](http://github.com/AtelierConvivialite/webtranslateit/issues) | 
[Support](https://webtranslateit.com/support) |
[WebTranslateIt.com Homepage](https://webtranslateit.com)

wti lets you easily sync your language files with [WebTranslateIt.com](https://webtranslateit.com), a web-based tool to translation software.

![WebTranslateIt Synchronization Tool](http://f.cl.ly/items/2X3m0h0g0I1O1U07163o/wti_example.jpg)

### wti...

* wti is a **command-line tool**. It works on all operating systems: Windows, Linux, MacOS X...
* wti is really easy to use. It was inspired by git. Use `wti push` and `wti pull` to sync your language files with WebTranslateIt.com.

### Optionally, wti does...

* include a rack middleware you can use in your Rails app to automatically fetch new translations from WebTranslateIt.com.
* include libraries you can use to programmatically fetch your segments from WebTranslateIt.com. See [Extras](https://github.com/AtelierConvivialite/webtranslateit/wiki/Extras)
* include a web interface for your translation team to update your language files. [Learn more on the web_translate_it_server project page](https://github.com/AtelierConvivialite/web_translate_it_server).

---

## Installation

You will also need ruby to run `wti`. On Linux or a Mac, it’s already installed. Install [RubyInstaller](http://rubyinstaller.org/) if you’re using Windows. [See detailed installation instructions for Windows users](https://github.com/AtelierConvivialite/webtranslateit/wiki/Install-wti-on-Windows).

``` bash
$ gem install web_translate_it
Fetching: web_translate_it-2.1.3.gem (100%)
Successfully installed web_translate_it-2.1.3
1 gem installed
```
    
At this point you should have the `wti` executable working:

``` bash
$ wti -v
wti version 2.1.3
```

## Configuration

Now that the tool is installed, you’ll have to configure your project. Basically, `wti` is to be run on a project root directory, and looks for a `.wti` file containing your project information. The command `wti init` lets your create your `.wti` file.

``` bash
$ wti init 55555abc1235555
# Initializing project

 Your project was successfully initialized.
You can now use `wti` to push and pull your language files.
Check `wti --help` for help.
```

`55555abc1235555` is the API token, which you can find in your project settings.

If you’d like to specify another path for your configuration file, you can use `wti init`. This command will ask you to enter your project API token and where to save the configuration file (by default it will create a `.wti` in your project root directory).

Now you’re all set and you can use the `wti` commands on your project.

## Usage

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

## Sample Commands

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
    <td>Force pull (to bypass WebTranslateIt’s HTTP caching)</td>
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
    <td>Show matching between files on local computer and the ones in WebTranslateIt’s File Manager</td>
  </tr>
</table>

## Hooks

It is sometimes useful to hook a command or a script before or after a push or a pull. One use-case would be to launch a build after pulling language files. You can do that by implementing hooks in your `.wti` file.

There are 4 hooks:

* `before_pull`
* `after_pull`
* `before_push`
* `after_push`

Check the [sample `.wti`](https://github.com/AtelierConvivialite/webtranslateit/blob/master/examples/.wti#L9..L13) file for implementation.

# License

Copyright (c) 2009-2013 Atelier Convivialité, released under the MIT License.
