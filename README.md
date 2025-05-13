# Token System for FiveM

## Installation

### Requirements
- **OxMySQL**


### Steps
1. Download the script and place it in your `resources` folder.
2. Add `start token_system` to your `server.cfg` file.
3. Make sure you have `oxmysql` installed on your server.

## Configuration
You can customize the token amount by editing the `tokenAmount` variable in the script:

```lua
local tokenAmount = 2.5  -- The amount of tokens to give to the player
local waitTime = 30 * 60 * 1000  

