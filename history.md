## Version 1.7.0.7.pre (pre-release)

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