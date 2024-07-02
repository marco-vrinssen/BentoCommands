# Bento Commands

## Addon for World of Warcraft Classic with simple communication-enhancing chat commands.

## Commands

#### Chat Filterings
- `/f KEYWORD`: Filters all active channels for KEYWORD and reposts matching messages.
- `/f KEYWORD1+KEYWORD2`: Filters all active channels for the combination of KEYWORD1 and KEYWORD2 and reposts matching messages.
- `/f`: Clears and stops the filtering.

#### Broadcasting
- `/bc MESSAGE`: Broadcasts the MESSAGE across all joined channels.
- `/bc N1-N2 MESSAGE`: Broadcasts the MESSAGE across all specified channels, where N1 and N2 are indicating the inclusive range of channels to be targeted.

#### Multi-Whispering
- `/ww MESSAGE`: Sends the MESSAGE to all players in a currently open /who instance.
- `/ww N MESSAGE`: Sends the MESSAGE to the first N count of players in a currently open /who instance.
- `/ww -CLASS MESSAGE`: Sends the MESSAGE to all players who are not of the specified CLASS in a currently open /who instance.
- `/ww N -CLASS MESSAGE`: Sends the MESSAGE to the first N count of players who are not of the specified CLASS in a currently open /who instance.
- `/wl N MESSAGE`: Sends the MESSAGE to the last N players who whispered you.

#### Utility
- `/rc`: Perform a ready check.
- `/q`: Leaves the current party or raid.
- `/ui`: Reloads the user interface.
- `/gx`: Restarts the graphics engine.
- `/lua`: Toggles the display of LUA errors.