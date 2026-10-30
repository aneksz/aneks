-- Force Hyprland's config dir in package path
local config_dir = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
package.path = config_dir .. "/hypr/?.lua;" .. config_dir .. "/hypr/?/init.lua;" .. package.path

-- hyprland.lua
_G.hl = hl -- Make Hyprland functions global
_G.colors = require("modules/colors") -- Make your theme global

-- Now load everything else
require("modules/envs")
require("modules/monitors")
require("modules/input")
require("modules/looknfeel")
require("modules/animations")
require("modules/autostart")
require("modules/bindings")
require("modules/windows")
require("modules/misc")
require("modules/plugins")
