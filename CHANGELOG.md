# Changelog

## 2.2.0
* Add option to resolve MX records (#50) - thanks @peaceful-james

## 2.1.0
* Validate subdomains (#46) - thanks @peaceful-james
* Update dependencies
* Updadte domains

## 2.0.0
* Improve performances by using a MapSet (#37) - thanks @tomciopp! This is a breaking change if you rely on Burnex.providers as it now returns a MapSet insteady of a list.

## 1.2.1
* Fix build issue (missing VERSION in release) - https://github.com/Betree/burnex/issues/33

## 1.2.0
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
