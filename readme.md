# WebTranslateIt Synchronization Tool : wti

[RubyDoc](https://www.rubydoc.info/gems/web_translate_it/) |
[Report a bug](https://github.com/webtranslateit/webtranslateit/issues) |
[Support](https://webtranslateit.com/support) |
[WebTranslateIt.com Homepage](https://webtranslateit.com) |
[Docker Package](https://github.com/webtranslateit/wti-docker/pkgs/container/wti-docker)

wti lets you easily sync your language files with [WebTranslateIt.com](https://webtranslateit.com), a web-based tool to translation software.

<img src="http://edouard.baconfile.com.s3.us-east-1.amazonaws.com/web_translate_it/wti4.png" alt="WebTranslateIt Synchronization Tool" width="500px">

### wti...

* wti is a **command-line tool**. It works on all operating systems: Windows, Linux, MacOS X, ... It is also available as a [Docker package](https://github.com/webtranslateit/wti-docker/pkgs/container/wti-docker).
* wti is really easy to use. It was inspired by git. Use `wti push` and `wti pull` to sync your language files with WebTranslateIt.com.

### Optionally, wti does...

* include a rack middleware you can use in your Rails app to automatically fetch new translations from WebTranslateIt.com.
* include libraries you can use to programmatically fetch your segments from WebTranslateIt.com. See [Extras](https://github.com/webtranslateit/webtranslateit/wiki/Extras)
* include a web interface for your translation team to update your language files. [Learn more on the web_translate_it_server project page](https://github.com/webtranslateit/web_translate_it_server).

---

## Installation

You will also need ruby to run `wti`. We require ruby version 2.6 or newer. On Linux or a Mac, it’s already installed. Install [RubyInstaller](http://rubyinstaller.org/) if you’re using Windows. [See detailed installation instructions for Windows users](https://github.com/webtranslateit/webtranslateit/wiki/Install-wti-on-Windows).

``` bash
$ gem install web_translate_it
Fetching: web_translate_it-2.6.4.gem (100%)
Successfully installed web_translate_it-2.6.4
1 gem installed
```

At this point you should have the `wti` executable working:

``` bash
$ wti -v
wti version 2.6.4
```

We also provide `wti` as a Docker packages. [See our packages and instructions to install](https://github.com/webtranslateit/wti-docker/pkgs/container/wti-docker).

## Configuration

Now that `wti` is installed, you’ll have to configure your project. Basically, `wti` is to be run on a project root directory, and looks for a `.wti` file containing your project information. The command `wti init` lets your create your `.wti` file.

``` bash
$ wti init proj_pvt_V8skdjsdDDA4
# Initializing project

 The project Frontend was successfully initialized.

You can now use `wti` to push and pull your language files.
Check `wti --help` for help.
```

`proj_pvt_V8skdjsdDDA4` is the API token, which you can find in your project settings.

If you’d like to specify another path for your configuration file, you can use `wti init`. This command will ask you to enter your project API token and where to save the configuration file (by default it will create a `.wti` in your project root directory).

Now you’re all set and you can use the `wti` commands on your project.

## Using on multiple projects

Please refer to [our documentation about syncing multiple projects](https://github.com/webtranslateit/webtranslateit/wiki/Using-wti-with-multiple-projects).

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
    wti push [filename] - Push master language file(s)
    [options] are:
      -l, --locale=<s>        ISO code of locale(s) to push
      -t, --target            Upload all target files
      -f, --force             Force push (bypass conditional requests to WTI)
      -m, --merge             Force WTI to merge this file
      -i, --ignore-missing    Force WTI to not obsolete missing strings
      -n, --minor             Minor Changes. When pushing a master file, prevents
                              target translations to be flagged as `to_verify`.
      -a, --label=<s>         Apply a label to the changes
      -c, --config=<s>        Path to a configuration file (default: .wti)
      --all                   DEPRECATED -- See `wti push --target` instead
      -d, --debug             Display debug information
      -h, --help              Show this message

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
    <td>find . -name "*en.yml" | xargs wti add</td>
    <td>Find all the en.yml files and add them to the project</td>
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
    <td>wti push path/to/file.yml</td>
    <td>Pushes the path/to/file.yml file</td>
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
    <td>wti pull path/to/files/*</td>
    <td>Download all files in path/to/files</td>
  </tr>
  <tr>
    <td>wti pull path/to/files/* -l fr</td>
    <td>Download all fr files in path/to/files</td>
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
    <td>View project translation statistics</td>
  </tr>
  <tr>
    <td>wti status config/locales/app/en.yml</td>
    <td>View translation statistics on file config/locales/app/en.yml</td>
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

Check the [sample `.wti`](https://github.com/webtranslateit/webtranslateit/blob/main/examples/.wti#L21-L28) file for implementation.

## Exit codes

`wti` returns exit codes on failure. The exit code is `0` if the command executed successfully and `1` if the command executed but encountered at least one error. This is useful to act upon errors if you use `wti` to pull files in an automated build process.

``` zsh
~/code/webtranslateit.com[master]% wti pull
# Pulling files on WebTranslateIt
 config/locales/translation_validator/en.yml        | e82e044..e82e044  Skipped
 config/locales/app/en.yml                          | f2ca86c..f2ca86c  Skipped
 config/locales/defaults/en.yml                     | 2fcb61f..2fcb61f  Skipped
 config/locales/js/en.yml                           | ee6589d..ee6589d  Skipped
 config/locales/js/fr.yml                           | 2f8bb0e..2f8bb0e  Skipped
 config/locales/translation_validator/fr.yml        | 534af2c..534af2c  Skipped
 config/locales/app/fr.yml                          | 29f8c9d..da39a3e  OK
 config/locales/defaults/fr.yml                     | aca123e..aca123e  Skipped
Pulled 8 files at 7 files/sec, using 3 threads.

~/code/webtranslateit.com[master]% echo $?
0

~/code/webtranslateit.com[master]% wti pull
# Pulling files on WebTranslateIt
 config/locales/translation_validator/en.yml        | e82e044..e82e044  Error
 config/locales/app/en.yml                          | f2ca86c..f2ca86c  Skipped
 config/locales/defaults/fr.yml                     | aca123e..aca123e  Skipped
Pulled 3 files at 3 files/sec, using 3 threads.

~/code/webtranslateit.com[master]% echo $?
1
```

`wti status` command also returns meaningful codes. It will exit with `0` if the project is 100% translated and proofread, `100` if the project is not 100% translated and `101` if the project is not 100% proofread. This could allow you to check if a project is 100% translated or completed before deploying a project.

``` zsh
~/Desktop/test% wti status
# Gathering information on test ts
fr: 40% translated, 40% completed.
en: 90% translated, 0% completed.

~/Desktop/test% echo $?
100

~/Desktop/test% wti status
# Gathering information on test ts
en: 100% translated, 0% completed.
fr: 100% translated, 100% completed.

~/Desktop/test% echo $?
101

~/Desktop/test% wti status
# Gathering information on test ts
en: 100% translated, 100% completed.
fr: 100% translated, 100% completed.

~/Desktop/test% echo $?   
0
```

# License

Copyright (c) 2009-2022 [WebTranslateIt Software S.L](https://webtranslateit.com), released under the MIT License.
