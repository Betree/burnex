# Changelog

## 3.0.0
* Separate MX Record check from core functionality #52 - @peaceful-james
* Misc doc changes (#47) - @kianmeng
* Fixed doctests

## 2.2.0

* Add option to resolve MX records (#50) - thanks @peaceful-james

## 2.1.0 (2020-11-08)

* Validate subdomains (#46) - thanks @peaceful-james
* Update dependencies
* Update domains

## 2.0.0 (2020-09-28)

* Breaking changes
  - Improve performances by using a MapSet (#37) - thanks @tomciopp!
  - `Burnex.provider/0` returns a MapSet instead of a list.

## 1.2.1 (2020-08-03)

* Fix build issue, missing VERSION in release (#33).

## 1.2.0 (2020-07-30)

* Update dependencies
* Update providers list
* Update docs

## 1.1.0 (2018-08-29)

* Breaking changes
  - Change `is_burner_domain/1` to `is_burner_domain?/1`

## 1.0.5 (2018-08-29)

* Enhancements
  - Add `is_burner_domain/1` function to check the domain directly
  - Update providers list
