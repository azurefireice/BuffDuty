## [1.0.1] - 2019-12-15 ##
### Release  ###

  * Bump a version for release version
---

## [0.3.3] - 2019-12-15 ##
### Visual and UX rework ###

  * Improved UX of BuffDuty name on addon selection screen
  * Added BuffDuty name for chat output to promote addon
---

## [0.3.2] - 2019-12-15 ##
### Added Battlegrounds support ###

  * "raid" profile also extends to Battlegrounds
  
### Added ###

  * Battleground channel support

### Changed ###

   * disabled no-lib file creation
---

## [0.3.1] - 2019-12-15 ##
### Bumped version  ###
    see 0.3.0 for changes 
---

## [0.3.0] - 2019-12-15 ##
### Added tests  ###
  * added command line arguments
    * "s", "say" - message will be posted to "say" channel
    * "r", "raid" - message will be posted to "raid" channel
    * "raid" channel is selected by default.
  * Added tests that can be run manually
  * added error handling
  * Improved duty message
  
### Added ###

  * error handling
  * manual tests

### Changed ###

   * Made group assignment message more appealing

### Fixed ###

   * Library imports
   * Global variables usage in addon
---

## [0.2.1] - 2019-12-14 ##
### Addon execution checks ###

    Buff Duty will not post to chat anything if
    * Group is less than 10 people
    * No mages in group 
    A neat info messages will be shown instead
    
### Added ###

  * checks for small group/not enough mages

### Changed ###

   * Addon chat posting conditions
   * Instead of "say", "raid" is used
   * Changed wording of a custom message when only 1 mage in a group

### Fixed ###

   * Library imports
   * Global variables usage in addon
---


## [0.1.4] - 2019-12-13 ##
### Packaging and CICD ###

  * Implemented packaging and CICD deployment to CurseForge

### Added ###

  * packaging
  * deployment
---

## [0.1.3] - 2019-12-13 ##
### Libs fix ###

### Fixed ###

   * Fixed absent libs
---


## [0.1.2] - 2019-12-13 ##
### Packaging and CICD ###

  * Implemented packaging and CICD deployment to CurseForge

### Added ###

  * packaging
  * deployment
---


## [0.1.1] - 2019-12-13 ##
### Initial commit ###

  * Initial commit

### Added ###

  * Added fresh project

### Changed ###

   * N/A

### Fixed ###

   * N/A
---