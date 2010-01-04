=== Version 1.1.1 / 2010-01-04

* Fix: locales in exclude list are no longer autofetched when browsing the app in these locales.

=== Version 1.1 / 2010-01-04

* Support for multi-files projects.
* Deprecate `rake translation:*` in favour of the shorter form `rake trans`.
* Add task `rake trans:fetch[en_US]` to fetch files locale by locale.
* Add task `rake trans:fetch:all` to fetch all the files for all locales defined in Web Translate It’s web interface.

=== Version 1.0.0 / 2009-11-02

* Better support for exceptions.

=== Version 0.9.0 / 2009-10-26

* First version, plugin only support download of strings. Strings upload will be available in a later version.