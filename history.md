## Edge

* `wti pull` downloads files in parallel, using up to 10 threads.
  This makes for much faster syncs for projects containing many files (up to 65 files/sec).

## Version 1.8.1.8 / 2011-07-29

* Revert previous commit, which didn’t work. Added an extra step to the Windows installation
  instructions: http://help.webtranslateit.com/kb/tips/how-to-install-wti-on-windows
* Fix broken `WebTranslateIt.fetch_translations`, #63.

## Version 1.8.1.7 / 2011-07-29

* Add dependancy on `win32console` for Microsoft Windows users.

## Version 1.8.1.6 / 2011-07-25

* Update multipart-post dependancy.
* Only include CA cert of WTI’s SSL certificate issuer. #61.

## Version 1.8.1.5 / 2011-07-19

* Update ansi dependancy.
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