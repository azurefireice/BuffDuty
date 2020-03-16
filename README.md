Overview
========
This mod allows automatic assignment for buff/debuff duties for mages, priests, druids in [40]raid groups. By posting a message with assignments to chat.

Usage
-----
Mod functionality is available through a simple command

**/buffduty**

*By default* message will be posted to for `mages` class, as `whisper` for each buffing player.

It also supports command line arguments in the following format:

```/buffduty [class argument] [channel type arg] [channel name arg]```

* class argument(`case insensitive`) - Specifies class for which BuffDuty is executed.
    * "m" or "mage" - message will be generated for mages
    * "d" or "druid" - message will be generated for druids
    * "p" or "priest" - message will be generated for priests
* channel type argument(`case insensitive`) - Specifies the channel where the message will be posted.
    * "s" or "say" - message will be posted to common "say" chat
    * "r" or "raid" - message will posted to raid chat. If player is in Battleground, message will be posted to BG chat.
    * "w" or "whisper" - message will be posted to each player with group assigned as a private message.
    * "c" or "channel" - message will be posted to custom channel, with name specified in *channel name argument*
* channel name argument(`case insensitive`, `optional`) - Specifies the channel name for custom channel. Only applicable for *custom channel type*, for other channel types will be ignored.
    * *specify your channel name or number* - provide a channel where you want the message to be posted. E.g. "3", "pvp3", "ACMEGuidHeal"
* excluded players argument(`case insensitive`, `optional`) - Excluding players from buffduty.
    * *`e{<player1>,<player2>,..}`* - provide a list of players you want to exclude from BuffDuty. Please note that players are **comma separated**, no spaces in between. E.g. `e{putris,spaceBag}`.
* ordered players argument(`case insensitive`, `optional`) - additional responsibilities list, similar to exclude, to allow additional duties for priority players. Players specified in this list are likely to get additional buffing duties.
    * *`o{<player3>,<player5>,..}`* - provide a list of players you want to give priority during assignment. Please note that players are **comma separated**, no spaces in between. E.g. `o{putris,spaceBag}`.
  

_Hint_
The way we currently using it - is we create a custom macro with this command and put it in UI for convenience. For example:

`/buffduty priest custom sparksheal` - will send BuffDuty message for *priest* class in a *custom* channel named *sparksheal*  
`/buffduty m r` - will send BuffDuty message for *mage* class in a *raid* channel  
`/buffduty druid w` - will send BuffDuty message for *druid* class in private message for each druid  
`/buffduty priest w e{Putris,cassi}` - will send BuffDuty message for *druid* class in private message for each druid. It will exclude players "Putris" and "John" from BuffDuty.  
`/buffduty druid c 5 e{cuernoloco,Xako}` - will send BuffDuty message for *druid* class in a *custom* channel number *5* in player's chats. It will exclude players "Putris" and "John" from BuffDuty.
`/buffduty druid c 5 e{cuernoloco,Xako} o{Ryuken,Dimmi,Sentry}` - will send BuffDuty message for *druid* class in a *custom* channel number *5* in player's chats. It will exclude players "Putris" and "John" from BuffDuty. It will prioritise Ryuken, Dimmi, and Sentry for additional buffing duties(like receive 2nd group to look after).
![Example1](/docs/example1.png "Example for custom channel")  
![Example2](/docs/example2.png "Example usage for say channel")

How does it work?
-----------------
Buff Duty performs best when it works in a raid group of ~40 people with ~8 people that represent the class that buffs/dispells. 
Addon gathers information about the number of number of said people in the raid and, based on that, posts a message that informs which player is responsible for a specific raid group.

Some edge cases:

  * If the raid group does not have any player with specific class, it posts a message saying that no players are available for buffing.
  * If there is only 1 buffing player in a raid group, BuffDuty informs that only this player will do the buffing.
  * For cases when there are between 2 and 7 buffing players in a raid, groups are assigned in a consecutive fashion e.g. "Player1 - Groups 1,2,3"
  * When there are 8 and more buffing players in a raid - groups are properly assigned to first 8 players in a fashion "Player5 - Group 5"


Background
----------
The idea of an add-on came up when we noticed that it takes too much effort to manually track all mages in a raid and assign them to a specific group when de-cursing the raid members during our MC runs. It started out as a simple macro that needed to be edited every time raid composition changed. After maintaining it for a couple runs it became apparent to automate this process as well. This is how the Buff Duty was born.

Contributor info
------------------
#### Testing

    How to run tests?
1. In [BuffDuty.toc](BuffDuty.toc) uncomment line `# tests.lua`
1. ReloadUI in WoW client
1. Run command `/buffduty-test`

> :bulb: You may use `function dump(o)` in tests to turn tables to strings for printing them.



TODO list
------------------

  * Allow for customized message format output
  * Support more classes/roles
  * Message localisation
  * Persisting of state
  * Form-based UI
  
