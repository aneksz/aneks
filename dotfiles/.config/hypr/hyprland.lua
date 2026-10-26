-- Force Hyprland's config dir in package path
local config_dir = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
package.path = config_dir .. "/hypr/?.lua;" .. config_dir .. "/hypr/?/init.lua;" .. package.path

-- hyprland.lua
_G.hl = hl -- Make Hyprland functions global
_G.colors = require("colors") -- Make your theme global

-- Now load everything else
require("envs")
require("monitors")
require("input")
require("looknfeel")
require("animations")
require("autostart")
require("bindings")
require("windows")
require("misc")
require("plugins")
