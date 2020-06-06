# Overview
This mod allows automatic assignment for buff/debuff duties for mages, priests, druids in [40]raid groups. By posting a message with assignments to chat.

# How does it work?
Buff Duty performs best when it works in a raid group of ~40 people with ~8 people that represent the class that buffs/dispells. 
Addon gathers information about the number of said people in the raid and, based on that, posts a message that informs which player is responsible for a specific raid group.
The duties are saved between UI reload(WOW relog, exit, etc).
They are persisted based on cache: `N:player1,player2,player3`, where *N* - number of groups in current raid, 
*player1,player2...* - resulting buffing player's(appropriate class, not excluded) names sorted in alphabetic order.
You might be interested in that if assignments are not being updated for a long time. If that is the case, please do not 
hesitate to reach BuffDuty creators.

Some edge cases:
  * If there are *less then 10 players* in raid, it posts a message that it makes no sense to do buff assignments.
  * If the raid group *does not have any buffing player* of specific class, it posts a message saying that no players are available for buffing.
  * If there is *only 1 buffing player* in a raid group, BuffDuty informs that only this player will do the buffing.
  * For cases when there are *between 2 and 7 buffing players* in a raid, groups are assigned in a consecutive fashion e.g. "Player1 - Groups 1,2,3".
  * When there are *8 and more buffing players* in a raid - groups are properly assigned to first 8 players in a fashion "Player5 - Group 5".

## Usage

*  `/buffduty` - will print info message with example of BuffDuty help command

* :bulb: Help. Use `/buffduty ?` or  `/buffduty help` or  `/buffduty -h` to get extended command options list.

* Version. type `/buffduty version` or  `/buffduty -v` to get the currently installed version.

```/buffduty [class argument] [channel type] [(optional)channel name] [(optional)excluded players] [(optional)ordered players] ```

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
    * *`e{player1,player2,..}`* - provide a list of players you want to exclude from BuffDuty. Please note that players are **comma separated**, no spaces in between. E.g. `e{putris,spaceBag}`.
* ordered players argument(`case insensitive`, `optional`) - additional responsibilities list, similar to exclude, to allow additional duties for priority players. Players specified in this list are likely to get additional buffing duties.
    * *`o{player3,player5,..}`* - provide a list of players you want to give priority during assignment. Please note that players are **comma separated**, no spaces in between. E.g. `o{putris,spaceBag}`.
* :bulb: additional assignment options available. Refer to `/buffduty help` for more info.
* 'no-cache' argument to /buffduty command, disables *caching* of results.

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

## Message Customisation
Message customisation is available via the `/buffduty-msg` command in the following format:

```/buffduty-msg [message type] "[custom message]"```

* message type (`case insensitive`) - Specifies the message type:
    * "public-title" or "-pt" - The title message displayed in a public or custom channel.
    * "duty-line" or "-dl" - The duty line format displayed in a public or custom channel. Requires `$name` and `$groups`.
    * "duty-whisper" or "-dw" - The whisper message sent to each player in the duty list. Requires `$groups`.
    * "single-message" or "-sm" - The message displayed in a public or custom channel when only one buffing player is present. Requires `$name`.
    * "single-whisper" or "-sw" - The whisper message sent when only one buffing player is present.
* custom message - Specifies the custom message format, which must be enclosed in `" "` or use `_` (underscore) in place
 of spaces. *For example:* `/buffduty-msg -pt "Hello friends, please buff the following groups:"` or `/buffduty-msg -dl $name_-_Group$s_$groups`

### Variables in messages
Custom message formats can contain special variables starting with a `$` symbol. Each $variable is then dynamically replaced by a generated value when printed. _For example:_ `$name` will be replaced by the assigned players name.

*Available variables and the message types that support, or **require**, them are:*
* `$class` - The specified class, e.g. Priest. _Supported by:_ public-title, single-message, single-whisper
* `$name` - The assigned players name, e.g. Xako. _Supported by:_ **duty-line**, duty-whisper, **single-message**, single-whisper
* `$groups` - The groups the player is assigned to, e.g. 1,2,3. _Supported by:_ **duty-line**, **duty-whisper**, single-whisper
* `$s` - Pural modifier for the number of buffing players, e.g. Priest vs. Priest**s**. _Supported by:_ public-title, single-message
* `$s` - Pural modifier for the number of assigned groups, e.g. Group vs. Group**s**. _Supported by:_ duty-line, duty-whisper, single-whisper
* `$i` - Index value between 1 and 8 useful for displaying raid target icons, e.g. {rt$i}. _Supported by:_ duty-line, duty-whisper, single-whisper

### Resetting / Default values
Resetting message types to their default value can be done by specifying `reset` as the message type followed
by a **comma seperated** list - with no spaces - of message types to reset.
*For example:* `/buffduty-msg reset public-title,single-message,duty-line` would reset the public-title, single-message and duty-line message types.

The keyword `all` can also be used with `reset` to reset all message types. *For example:* `/buffduty-msg reset all`

*Note:* Short names for message types are not supported by `reset`; i.e. you must use `public-title` as `-pt` is not supported.



# Background
The idea of an add-on came up when we noticed that it takes too much effort to manually track all mages in a raid and
assign them to a specific group when de-cursing the raid members during our MC runs. It started out as a simple macro
that needed to be edited every time raid composition changed. After maintaining it for a couple runs it became
apparent to automate this process as well. This is how the Buff Duty was born.

# Contributor info
## Testing
    How to run tests?
1. In [BuffDuty.toc](BuffDuty.toc) uncomment line `# tests.lua`
1. Start WoW client
1. In tests.lua change `mock_party_size` and `mock_players_num`
1. Run desired /buffduty command
1. Look for input in chat

> :bulb: You may use `function dump(o)` in tests to turn tables to strings for printing them.

# TODO list
  * Support more classes/roles
  * Message localisation
  * UI
  
