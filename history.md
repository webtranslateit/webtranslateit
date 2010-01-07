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