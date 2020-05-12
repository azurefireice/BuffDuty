## [1.5.0] - 2020-05-12 ##
### Implemented message customisation

### Added ###
  * Implemented message customisation for printed duty messages
  * New `/buffduty-msg` command, and command parsing logic
  * Persistence of custom messages at the faction-realm level
  * Support for variables in messages to allow for dynamic generation

### Changed ###
  * Restructured duty list, message handling and output to allow for customisation
  * Changed duty whisper message format and made it a single message
  * The user will no longer whisper themselves, a print message is displayed to them instead
  * Updated Readme to include message customisation

## [1.4.0] - 2020-04-01 ##
### Implemented preserving player assignments

### Added ###
  * Implemented persisting player assignments between calls.
   If the buffing players remain the same(regardless of their order in groups),
   group assignments would not change.
  * Added caching of assignments for same calls.
  
### Changed ###
  * Changed the BuffDuty message output format. It is now `Group x - {symbol}PlayerName{symbol}`.
  * Updated Readme to reflect the latest changes of addon logic.

## [1.3.2] - 2020-03-16 ##
### Fix title for addon that prevents it from showing properly.

### Fixed ###
  * Addon title was formatted incorrectly. Fixed that.

## [1.3.1] - 2020-03-16 ##
### Bug fixes from 1.3.0

### Fixed ###
  * Fixed losing 'order' list if a non-custom channel was specified
  * Fixed incorrect parameter order, compared to usage, in covertPlayersList
  * Added order argument description to README.md

## [1.3.0] - 2020-03-14 ##
### Assignment order improvements, authored by Byron-Miles

### Added ###
  * Support for an order list, similar to exclude, to allow priority for who will be assigned a 2nd/etc. group first.
  * Logic to assign players to their own group first, with priority give to non-ordered players.
  * Logic to assign remaining groups in sequential order; e.g. if there are only 2 Druids and 6 groups then by default Druid1 will be assigned groups 1,2,3 and Druid2 will be assigned groups 4,5,6.

### Changed ###
  * Logic to check max group number, rather than being fixed at 8; i.e. in a 20 man raid only groups 1-4 would be assigned.
  * Slight changes to chat messages produced by BuffDuty

### KUDOS ###
  * All of the improvements/changes in this version are authored by Byron-Miles. 
  Thank you, @Byron-Miles for all these wonderful improvements! You rock my world!

## [1.2.1] - 2020-02-11 ##
### Updated BuffDuty to support wow 1.13.4 classic client.

## [1.2.0] - 2020-02-11 ##
### Allowing to exclude players from BuffDuty ###
  * It is now possible to exclude people from BuffDuty
  
### Added ###
  * Added support for excluding players from BuffDuty. It was done by request from Desaytis
   to address case of shadow priests in raid, who can't buff.
  * Added a new argument to /buffduty command to exclude players.
  * Added Readme section and examples describing how to exclude players.
  * Added screenshots with examples to repository section `docs`.

### Fixed ###
  * Fixed title message when posting to channel to be universal and applicable not only to mages.

## [1.1.0] - 2019-12-15 ##
### Added Druid and Priest support ###

  * Now supporting Druid and Priest
  * Now supporting additional channel types: custom channel and whisper
  
### Added ###

  * Priest buffs/dispel support
  * Druid buffs/dispel support
  * Ability to send messages to a custom channel specified by channel name
  * Ability to send messages privately to people who will do buffs/dispel

### Changed ###

   * Changed output messages. Now messages are grouped by players. E.g. if player is assigned to group 1,4,5 he will receive 1 message.
   * Changed command line commands. Now format is ```buffduty [class argument] [channel type arg] [channel name arg]```
   * Changed default no argument behavior: if ```buffduty``` invoked without arguments, "
   Mage" class on "Whisper" would be selected.
---

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
