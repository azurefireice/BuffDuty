Overview
========
This mod allows automatic assignment for buff/debuff duties for mages in [40]raid groups. By posting a message with assignments to chat.

Usage
-----
Mod functionality is available through a simple command

**/buffduty**

It also supports command line argument:
* "s" or "say" - message will be posted to "say" channel
* "r" or "raid" - message will be posted to "raid" channel

_Hint_
The way we currently using it - is we create a custom macro with this command and put it to UI for convenience.

How does it work?
-----------------
Buff Duty performs best when it works in a raid group of ~40 people with ~8 mages. 
Addon gathers information about the number of number of mages in raid and based on that posts a message that informs which mage is responsible for a specific raid group.

![Example ](https://cdn.discordapp.com/attachments/637278196865433621/655145286045270027/unknown.png "Example usage")

Some edge cases:

* If the raid group does not have any mages, it posts a message saying that no mages are available for de-curse.
* If there is only 1 mage in a raid group, BuffDuty informs that only this mage will do the de-cursing.
* For cases when there are between 2 and 7 mages in a raid, groups are assigned in a round-robin fashion.
* When there are 8 and more mages in a raid - groups are properly assigned to first 8 mages in a fashion "1 mage - 1 group"


Background
----------
The idea of an add-on came up when we noticed that it takes too much effort to manually track all mages in a raid and assign them to a specific group when de-cursing the raid members during our MC runs. It started out as a simple macro that needed to be edited every time raid composition changed. After maintaining it for a couple runs it became apparent to automate this process as well. This is how the Buff Duty was born.

TODO list
------------------

* Allow for customized message format output
* Support more classes/roles

