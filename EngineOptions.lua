-- $Id$
--  Custom Options Definition Table format

--  NOTES:
--  - using an enumerated table lets you specify the options order

--
--  These keywords must be lowercase for LuaParser to read them.
--
--  key:      the string used in the script.txt
--  name:     the displayed name
--  desc:     the description (could be used as a tooltip)
--  type:     the option type
--  def:      the default value
--  min:      minimum value for number options
--  max:      maximum value for number options
--  step:     quantization step, aligned to the def value
--  maxlen:   the maximum string length for string options
--  items:    array of item strings for list options
--  scope:    'all', 'player', 'team', 'allyteam'      <<< not supported yet >>>
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  Example EngineOptions.lua 
--

local options =
{
  {
    key    = 'startconds',
    name   = 'Starting Conditions',
    desc   = 'Set the starting conditions.',
    type   = 'section',
  },
  {
    key    = 'modifiers',
    name   = 'In-Game Conditions',
    desc   = 'Set up ingame conditions.',
    type   = 'section',
  },      
   
  {
    key    = 'GameMode',
    name   = 'Game end condition',
    desc   = 'Determines what condition triggers the defeat of a player',
    type   = 'list',
    section= 'modifiers',	
    def    = '0',
    items  = 
    {
      { 
        key  = '0',
        name = 'Kill everything',
        desc = 'The player will lose when all his units have died',
      },

   
    },
  },
 
  {
    key    = 'StartMetal',
    name   = 'Starting metal',
    desc   = 'Determines amount of metal and metal storage that each player will start with',
    type   = 'number',
    section= 'startconds',
    def    = 1000,
    min    = 0,
    max    = 10000,
    step   = 10,  -- quantization is aligned to the def value
                    -- (step <= 0) means that there is no quantization
  },

  {
    key    = 'StartEnergy',
    name   = 'Starting energy',
    desc   = 'Determines amount of metal and metal storage that each player will start with',
    type   = 'number',
    section= 'StartingResources',
    def    = 1000,
    min    = 0,
    max    = 10000,
    step   = 10,  -- quantization is aligned to the def value
                    -- (step <= 0) means that there is no quantization
  },
  --]]

  {
    key    = 'MaxUnits',
    name   = 'Max units',
    desc   = 'Determines the ceiling of how many units and buildings a player is allowed to own at the same time (limited by spring to 10000 / (#commanders + 1))',
    type   = 'number',
    section= 'modifiers',	
    def    = 1500,
    min    = 10,
    max    = 3000,
    step   = 10,  -- quantization is aligned to the def value
                    -- (step <= 0) means that there is no quantization
  },

  {
    key    = 'diplomacy',
    name   = 'Diplomacy Settings',
    desc   = 'Configure diplomacy settings.',
    type   = 'section',
  },
  {
    key    = 'FixedAllies',
    name   = 'Fixed ingame alliances',
    desc   = 'Disables the use of the /ally command for ingame ceasefires. \nkey: fixedallies',
    type   = 'bool',
	section = 'diplomacy',
    def    = false,
  },

  {
    key    = 'MinSpeed',
    name   = 'Minimum game speed',
    desc   = 'Sets the minimum speed that the players will be allowed to change to',
    type   = 'number',
    section= 'modifiers',
    def    = 0.5,
    min    = 0.1,
    max    = 10,
    step   = 0.1,  -- quantization is aligned to the def value
                    -- (step <= 0) means that there is no quantization
  },

  {
    key    = 'MaxSpeed',
    name   = 'Maximum game speed',
    desc   = 'Sets the maximum speed that the players will be allowed to change to',
    type   = 'number',
    section= 'modifiers',
    def    = 2,
    min    = 0.1,
    max    = 10,
    step   = 0.1,  -- quantization is aligned to the def value
                    -- (step <= 0) means that there is no quantization
  },  
 
  {
    key    = 'mapsettings',
    name   = 'Map Related Settings',
    desc   = 'Configure map related settings.',
    type   = 'section',
  }, 
  {
    key    = 'LuaRules',
    name   = 'Enable LuaRules',
    desc   = 'Enable mod usage of luarules',
    type   = 'bool',
    def    = true,
  }  


--[[   {
    key    = 'LuaGaia',
    name   = 'Enables gaia',
    desc   = 'Enables gaia player',
    type   = 'bool',
    def    = false,
  },
  
  {
    key    = 'NoHelperAIs',
    name   = 'Disable helper AIs',
    desc   = 'Disables luaui and group ai usage for all players',
    type   = 'bool',
    def    = false,
  },
 
]]

}
return options
