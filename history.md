## Version 2.1.8 / 2013-09-03

* Bug fix on `wti pull`.

## Version 2.1.7 / 2013-08-28

* New: Ability to pull a specific file or directory.
  Examples: `wti pull path/to/file.json` to pull a file.
            `wti pull config/locales/javascript/*` to pull all the files in the `config/locales/javascript directory.
* Bug fixes to autofetch.

## Version 2.1.6 / 2013-08-02

* Commands now display more information, such as the current project’s name.
* Improvements to auto-fetch: reload I18n after fetch, and do not run auto-fetch for static requests.

## Version 2.1.5 / 2013-07-01

* Tweak `wti pull` to use up to 10 threads.

## Version 2.1.4 / 2013-07-01

* Update `WebTranslateIt.fetch_translations`.
* Limit amount of simultaneous HTTP requests to WTI.

## Version 2.1.3 / 2013-04-25

* Display more information about “unavail” error message. #97
* New: add ability to initialize project with a one-liner: `wti init api_token`. #94
* Catch errors when running commands in a directory not containing a .wti file. #98

## Version 2.1.2 / 2013-04-20

* Update my name so it doesn’t contain accentuated characters anymore (seems to make jruby/rubygems 2.0.3 fail to install the gem). #96

## Version 2.1.1 / 2013-04-15

* Upgrade dependency on multipart-post, which includes a few compatibility fixes to ruby 2.0.

## Version 2.0.8 / 2013-04-04

* Update CA cert of the WebTranslateit’s issuer (Rapid SSL). #95.

## Version 2.0.7 / 2013-04-04

* A new version of WebTranslateIt brings instant statistics generation. Statistics are never stale,
  so removed some code that was handling stale stats in `wti status`. #93

## Version 2.0.6 / 2013-03-11

* Remove dependency on JSON. We use `multi_json` instead so wti should now be easier to install.
  (it previously required a C compiler to install).

## Version 2.0.5 / 2013-02-22

* New: Add ability to pass a file path in `wti push`: `wti push path/to/file`. #90.
* Made it a bit clearer that wti push now takes an optional file path.
* Move version file to a string in the .gemspec file.
* Upgrade dependencies

## Version 2.0.4 / 2012-08-08

* New: Add a throbber to indicate the project information is loading.
* New: Display error message when pushing or pulling a language that doesn’t exist in a project.
* Fixed: Compatibility problem with ruby 1.8.6.

## Version 2.0.3 / 2012-06-07

* Fix: String#translation_for('xx') should not return an array of all translations. #88
* Fix: Term#translation_for('xx') should not return an array of all term translations.
* String#find and Term#find now return nil if no element was found with that ID.

## Version 2.0.2 / 2012-06-06

* String, Translation, Term and TermTranslation classes now raise exceptions and display useful error messages. #87
* Implemented pagination for `String#find_all` and `Term#find_all`. This should work seemlessly with no API change.

## Version 2.0.1 / 2012-05-11

* Fix: Issue with saving labels on a string.

## Version 2.0.0 / 2012-04-24

* Add more helpers to `wti init` a project
* Add ability to add a source locale to a project from the command line: the first `wti addlocale xx` sets the source locale.
* `wti add`: Display if there are no new files to add.

## Version 2.0.0.rc4 / 2012-04-23

* Allow instantiating `WebTranslateIt::String` and `WebTranslateIt::Term` using a Hash made of symbols or strings.

## Version 2.0.0.rc3 / 2012-04-19

* Remove deprecated `wti server`.
* Reword command help and output.
* Rework String, Translation, Term and TermTranslation refactoring. Now using a connection persisted as a class instance. See connection.rb. This makes for a nicer syntax.

## Version 2.0.0.rc2 / 2012-04-16

* Backport of compatibility fix for ruby 1.8.7 from 1.x serie.
* Fix issue with new version system, which broke the gem. #86

## Version 2.0.0.rc1 / 2012-04-16 (yanked)

**Important**: This release candidate introduce breaking changes in the String, Translation, Term and TermTranslation APIs. See [Extras](https://github.com/AtelierConvivialite/webtranslateit/wiki/Extras) if you use the String, Translation, Term and TermTranslation APIs to programmatically manage strings, translations and terms. 

* Remove undeclared dependency on ActiveSupport. ActiveSupport was required to use the `WebTranslateIt::String`, `Translation`, `Term` and `TermTranslation` classes. #84
* Refactor `WebTranslateIt::String` and `WebTranslateIt::Translation` classes and add specs. #85
* Refactor `WebTranslateIt::Term` and `WebTranslateIt::TermTranslation` classes and add specs.

## Version 1.10.2 / 2012-04-17

* Compatibility fix for ruby 1.8.7.

## Version 1.10.1 / 2012-04-10

* New: Prevent existing master files from being added again on `wti add`.
  This allows to run something like: `ls *.xml | grep -v "\.en" | xargs wti add` without worrying about adding files a second time. Patch submitted by Ivan Kolesnikov <ik@playtox.ru>.
* New: Better error messages. #82.
* New: Add process name to command line tool. #81.
* Fix: Prevents `wti status` from crashing, #83.

## Version 1.10.0 / 2012-03-07

* New: `wti push` only push local files having a different checksum than the ones on WTI server. Patch submitted by Ivan Kolesnikov <ik@playtox.ru>.
* New: `wti push --force` lets you force push files. Patch submitted by Ivan Kolesnikov <ik@playtox.ru>.

## Version 1.9.6 / 2012-03-01

* Support for new `minor_changes` flag on File API. Use with `wti push --minor`.

## Version 1.9.5 / 2012-02-06

* Include classes to connect to [TermBase](http://docs.webtranslateit.com/api/term_base/) and [TermBase Translation](http://docs.webtranslateit.com/api/term_base_translation/) APIs.

## Version 1.9.4 / 2012-01-10

* Bug fix: Prevent `wti` from crashing when pulling from a project having no files.

## Version 1.9.3 / 2011-12-21

* Bug fix: the round(1) used in performance statistics wasn’t compatible with ruby < 1.9.

## Version 1.9.2 / 2011-12-21

* Gem now includes library to connect to [String](http://docs.webtranslateit.com/api/string/) and [Translation](http://docs.webtranslateit.com/api/translation/) APIs, see #74 and #78. (@bray).
* Add `<filename>` placeholder.
* Bug fix: don’t crash when running `wti init` on an empty project.
* Bug fix: File API was returning `102 Continue` error status when fetching a file begin currently imported. It was making subsequent requests fail. The File API now returns `503 Service Unavailable`. Client was updated to handle this status.
* Fix `wti status` command.
* Improvement: truncate `wti pull` performance statistics (`Pulled 10 files in 0.7 seconds at 13.4 files/sec`).
* Fix: Configuration file lookup improvements. Configuration files can now be located in another directory, and `wti` commands don’t have to be executed in the root directory. It is now possible to execute:
  
  ```
  wti pull 
  wti pull -c /Users/edouard/code/test/.wti
  wti pull -c ../.wti
  wti pull -c ~/code/.wti
  ```

## Version 1.9.1 / 2011-12-08

* Add `wti rm` and `wti rmlocale` to CLI help.
* Sort files by name in `wti push`.
* Improve command-line interface. Executing `wti` should now give help.
* Bug fix: TranslationFile timeouts, #77. (@bray).

## Version 1.9.0 / 2011-11-23

* Deprecate `wti server`. This feature was introducing a hard dependency on Sinatra, which is not desirable when embedding `web_translate_it` on a Rails application. `wti server` now lives in a separate gem, `web_translate_it_server`, which depends on the `web_translate_it` gem. To keep using `wti server`, execute: `gem install web_translate_it_server` and run: `wti-server`. 

## Version 1.8.4 / 2011-11-14

* Add new command `wti rmlocale locale_code_1 locale_code_2 ...` to delete a locale from a project.
* Add new command `wti rm path_to_file1 path_to_file2 ...` to delete a master file from a project.
* `wti` sends client name and version in custom headers. #73.

## Version 1.8.3 / 2011-11-14

* Bring back `-c` option to specify a configuration file with a specific name. `wti pull -c config/translations.yml` for instance. See #67 and #71.
* `web_translate_it` rubygem now respects [semantic versioning](http://semver.org/). #72.

## Version 1.8.2.3 / 2011-11-09

* Remove `sanitize_locale`. This method was replacing locale codes like `en_US` by `en-US`.
  It is now up to the user to make sure they use the correct locale format.
* Fix minor display bug during wti pull. See #70.

## Version 1.8.2.2 / 2011-11-05

* Add `--low-priority` option to `wti add` command.

## Version 1.8.2.1 / 2011-10-14

* Fix frozen string bug on ruby 1.9.3 (thanks @mikian for the patch).
* Fix: arrays of symbols `ignore_locales: [:en, :fr]` are not being parsed by Psych.
  People should use an array of strings (`ignore_locales: ['en', 'fr']`) or the longer version instead:
  ``` yaml
  ignore_locales:
    - :en
    - :fr
  ```

## Version 1.8.2.0 / 2011-09-12

* `wti pull` downloads files in parallel, using up to 20 threads.
  This makes syncing much faster for projects containing many files (up to 65 files/sec). 
* Default configuration file was renamed `.wti`. #67.
  The upgrade process should be seamless. Config file will be renamed if a `config/translation.yml` file is detected.

## Version 1.8.1.9 / 2011-09-07

* Possible fix for encoding issue in .gemspec file, #66
* Removed dependency on `ansi` gem, so wti now installs smoothly on Windows machines.
  Prior to that Windows users had to manually install the `win32console` gem. #62.

## Version 1.8.1.8 / 2011-07-29

* Revert previous commit, which didn’t work. Added an extra step to the Windows installation
  instructions: http://help.webtranslateit.com/kb/tips/how-to-install-wti-on-windows
* Fix broken `WebTranslateIt.fetch_translations`, #63.

## Version 1.8.1.7 / 2011-07-29

* Add dependency on `win32console` for Microsoft Windows users.

## Version 1.8.1.6 / 2011-07-25

* Update multipart-post dependency.
* Only include CA cert of WTI’s SSL certificate issuer. #61.

## Version 1.8.1.5 / 2011-07-19

* Update ansi dependency.
* Bug fix: re-recreate http connection from scratch after SSL certificate verification failure.

## Version 1.8.1.4 / 2011-06-29

* Bug fix: don’t try to modify a frozen object during fall back to non-verified SSL. #60

## Version 1.8.1.3 / 2011-06-24

* `wti` now falls back to non-verified SSL connections if SSL verification cannot be done.

## Version 1.8.1.2 / 2011-06-20

* Bug fix: Disable colors when running under MS Windows. #58
* Bug fix: Don’t verify SSL certificate when running under MS Windows. #57

## Version 1.8.1.0 / 2011-06-08

* Upgrade `multipart-post` dependency.
* Replace `rainbow` dependency by `ansi`, which can also format columns. #55
* Bug fix: `translation.yml` file wasn’t created on new projects.
* New: Gracefully quit on interrupt.
* New command: `wti match`. Displays files matching with the File Manager.
* Improved help commands.

## Version 1.8.0.1 / 2011-06-01

* Fix: SSL certificate verification wasn’t working on some systems (at least Ubuntu).

## Version 1.8.0.0 / 2011-05-31

* New: Faster file transfers using KeepAlive’d connection.
* New: Verify SSL certificate on connection.
* Fix: Display more detailed error messages on unconfigured projects. Ticket #56
* Fix: `wti init` now checks if configuration file is writable. Ticket #35
* Remove rake tasks. Rake tasks are much slower than the `wti executable` and were removed.
  Should you want the rake tasks back, see how to add them in your project
  [on the wiki](https://github.com/AtelierConvivialite/webtranslateit/wiki/Rake-tasks).

## Version 1.7.3.1 / 2011-05-06

* Fix: Broken links on `wti server`.
* Fix: Avoid crashes on blank checksums. Ticket #53
  This bug could happen when the file checksum is not yet calculated by WTI server, typically by doing a wti push, then wti pull too quickly.
* Update Sinatra to 1.2.6.

## Version 1.7.3.0 / 2011-04-12

* New: Compare local file checksum with file checksum from WTI API to determine if file needs downloading.
  We were previously using the date of last modification which can be a little bit unreliable.
* Remove `wti autoconf` and `wti stats`.
  These commands were deprecated in favour of `wti init` and `wti status` (and its alias `wti st`).

## Version 1.7.2.1 / 2011-03-31

* Bug fix: `wti init` fails when configuration file doesn’t exist.
* Add Gemfile for using `web_translate_it` with Bundler.

## Version 1.7.2.0 / 2011-03-10

* Deprecate `wti autoconf` in favour of `wti init`.
* Deprecate `wti stats` in favour of `wti status` and its alias `wti st`.
* Better help and options. Replaced option parser from Choice to Trollop.
* `wti pull -l` can now take several locales separated by spaces.
  For instance: `wti pull -l "en fr ja"`
* `wti push -l` can now take several locales separated by spaces.
  For instance: `wti push -l "en fr"`
* New: Coloured terminal output.
* New: `before_pull` and `after_pull` hooks now work for all kind of `wti pull` (not only within `wti server`).
* New: Added 2 new hooks: `before_push` and `after_push`.

## Version 1.7.1.7 / 2011-03-07

* New: `wti unknow_command` explains how to get help.
* Upgrade Sinatra to 1.2.0.
* New: Increase timeout to 30 seconds to accommodate large projects.

## Version 1.7.1.6 / 2011-02-25

* Fix: Make sure `log` directory exists on `wti server` start up.
* New: Upgrade Sinatra to 1.1.3.

## Version 1.7.1.5 / 2011-02-10

* Fix an issue with `wti server` swallowing all `wti` outputs.

## Version 1.7.1.4 / 2011-02-10

* New: Add `--low_priority` option.
* Update Sinatra and multipart-post dependancies.
* New: Enable logging of `wti server`. Logs will be saved in `log/webtranslateit.log` in your project directory.

## Version 1.7.1.3 / 2011-01-13

* Fix: Bug in `wti add`.

## Version 1.7.1.2 / 2011-01-13

* Fix: server timeout handling on `wti addlocale`.

## Version 1.7.1.1 / 2011-01-13

* New: `wti addlocale locale1 locale2 ...` to create new locales for a project.

## Version 1.7.1.0 / 2010-12-27

* New: TranslationFile#fetch now use file timestamps served by the Project API.
  This makes `wti pull` much faster, especially for projects having a lot of files
* Fix: `wti server` now notice new languages.
  Each page request to `wti server` now reloads the project information from Web Translate It.

## Version 1.7.0.7 / 2010-11-15

* Fix connection problems through a proxy (1.7.0.7.pre)
* Fix eventual problems connecting through an authenticated proxy (1.7.0.7.pre2)

## Version 1.7.0.6 / 2010-09-23

* Makes `wti server` load much faster for projects having a lot of files.
* The web interface now displays before_pull and after_pull hooks to facilitate debugging.
* Ability to do `wti pull -l` from the web interface to update server faster.

## Version 1.7.0.5 / 2010-09-04

* Fixes to make wti compatible with Ruby 1.9.2.

## Version 1.7.0.4 / 2010-06-29

* New: Added support for labels. Only works for `wti push` for now.
  `wti push --label release_week_4` will tag new and changed strings as `release_week_4`.

## Version 1.7.0.3 / 2010-06-08

* New: ability to add several master files at once
  `wti add file1 file2 file3 …`
  `wti add *.yml`.

## Version 1.7.0.2 / 2010-05-31

* Fix bug with file permissions.

## Version 1.7.0.1 / 2010-05-31

* Handle server timeouts more gracefully, and retry request. Set timeout down to 20 secs.
* New: display warning if file is not writable.

## Version 1.7.0 /2010-05-12

* New: `wti server` launch a sinatra app allowing to sync files from a web interface.
  Pinched from Tom Lea’s awesome rack-webtranslate-it, but made less specific.
* Bug fix: `wti autoconf` now create directories correctly if they don’t already exist. #27

## Version 1.6.7 /2010-05-05

* New: `wti add file_path` to create a new master language file on Web Translate It.
  This is only for master language files. Target language files are created server-side,
  and can be updated using `wti push --all`.

## Version 1.6.6 /2010-04-26

* New: `--merge` option to force WTI to perform a merge of this file with its database.
* New: `--ignore_missing` option to force WTI to not obsolete missing strings.

## Version 1.6.5 /2010-04-19

* Enhancement: Remove new line on push/pull result. It now displays `Pulling config/locales/app/fr.yml… 200 OK`.
* Enhancement: `wti stats` now propose to refresh the stats if the stats displayed are stale.
* Bug fix: `wti push` used to crash on non-existent files. Close #24.

## Version 1.6.4 /2010-04-02

* Bug fix: Rake tasks not working

## Version 1.6.3 /2010-04-02

* Bug fix: Don’t rely on active_support only for .blank? Fix issue #23

## Version 1.6.2 /2010-04-01

* Bug fix: ability to run `rake` tasks if Web Translate It is installed as a plugin.
* Fix tests and 1 encoding bug for Ruby 1.9.
* Bug fix: prevents a few crashes when accessing non-configured projects.

## Version 1.6.1 /2010-03-26

* Bug fix: `wti push --all` was using an incorrect list of locales, thus not pushing all files.

## Version 1.6.0 /2010-03-22

* Bug fix: Encoding problem with Ruby 1.9 (Romain Sempé)
* Bug fix: Make rake task create locale directory if it doesn’t exist yet. (Romain Sempé)
* Bug fix: Make the list of ignore locales work for wti pull (it won’t pull the locales you ignore)

* **Breaking update**: The project configuration changed and doesn’t include a list of master language files any longer.
  This makes configuration much simpler. However you must configure the exact file path of your files in
  the File Manager. This allows much more flexibility for the choice of your language file names. Ref #22.

## Version 1.5.2 /2010-03-13

* Only added a man page.

## Version 1.5.1 /2010-03-09

* Add `wti stats`, to fetch the project stats from the stats API endpoint.

## Version 1.5.0 /2010-02-19

Warning, some deprecations in this version.

* Remove `wti fetch` and `wti upload`. It was deprecated in 1.4.7 in favour of `wti pull` and `wti push` respectively.
* `wti push` now only pushes the master language file. Use `wti push --all` to push all or `wti push -l [locale]` to push a specific locale.
* `wti pull` now only pulls the target language files. Use `wti pull --all` to pull all or `wti pull -l [locale]` to pull a specific locale.
* Increase read timeout to 40s — Required for very large projects.
* Bug fix: `wti autoconf` now create directory if it doesn't exist.
* Bug fix: `wti autoconf` now ask the user where are the locale files.

## Version 1.4.7 /2010-02-05

* Add deprecation warning for `wti --fetch`, `wti -f`. These commands will be deprecated in favour of `wti pull`.
* Add deprecation warning for `wti --upload`, `wti -u`. These commands will be deprecated in favour of `wti push`.
* Add -c parameter to specify a configuration file at a custom location.
* Add -l parameter to specify a specific language file to pull or push (only works with `wti pull` and `wti push`).
* Add --force parameter to force Web Translate It to send the language files again, regardless if the current 
  language file version is current (this makes `wti pull` very much slower).
* Add `wti autoconf` command to automatically configure your project for Web Translate It.

## Version 1.4.6 /2010-02-04

* Add feedback when using the `wti command`.
* Fix bug where fetch requests were not using the conditional get requests feature.

## Version 1.4.5 /2010-02-02

* Improved documentation
* Web Translate is now an executable: `wti`

## Version 1.4.4 / 2010-02-01

* Add generator to automatically configure your project, given a Web Translate It API key.
* Remove rake trans:config, as configuration is now handled by the generator.

## Version 1.4.3 / 2010-01-09

* Remove colour outputs as it increases code complexity and doesn't add any value.
* Rack middleware now write to the application’s log file instead of just puts-ing
* Better error messages for misconfigured projects

## Version 1.4.2 / 2010-01-07

* Bug fix for `rake trans:config` which was not installing the translation.yml file properly.

## Version 1.4.1 / 2010-01-07

* Rename `rake trans:send[fr_Fr]` to `rake trans:upload[fr_FR]`
* Remove `rake trans:version` task. Instead, version number is displayed in the welcome banner.
* Code refactoring
* More tests

## Version 1.4.0 / 2010-01-06

* The plugin is now a gem

## Version 1.3.0 / 2010-01-05

* Add rack middleware to automatically fetch your translations
* Remove `autofetch` parameter in configuration file as it is better off to leave it to the user to
  include the rack middleware in each environment file.
* Add example of rack middleware for setting up I18n.locale

## Version 1.2.1 / 2010-01-04

* Add some documentation
* More feedback on file upload

## Version 1.2 / 2010-01-04

* New: Ability to **update** language files via PUT requests. Upload brand new language files is not possible at the moment.

## Version 1.1.1 / 2010-01-04

* Fix: locales in exclude list are no longer autofetched when browsing the app in these locales.

## Version 1.1 / 2010-01-04

* Support for multi-files projects.
* Deprecate `rake translation:*` in favour of the shorter form `rake trans`.
* Add task `rake trans:fetch[en_US]` to fetch files locale by locale.
* Add task `rake trans:fetch:all` to fetch all the files for all locales defined in Web Translate It’s web interface.

## Version 1.0.0 / 2009-11-02

* Better support for exceptions.

## Version 0.9.0 / 2009-10-26

* First version, plugin only support download of strings. Strings upload will be available in a later version.
