-- PasteRegister spoon
spoon = {}

-- Metadata {{{ --
spoon.name="PasteRegister"
spoon.version="0.1"
spoon.author="Von Welch"
spoon.license="Creative Commons Zero v1.0 Universal"
spoon.homepage="ihttps://github.com/von/PasteRegister.spoon"
-- }}} Metadata --

-- Prefix for register key to create pasteboard name
local registerPrefix = "Hammerspoon-register-"

-- List of legal registers
local legalRegisters = "0123456789abcdefghijklmnopqrstuvwxyz"

-- Constants {{{ --
local NoMod = {}
local Unbound = nil
local NoMsg = nil
local NoFunc = nil
local Indefinite = "indefinite"  -- For alerts
-- }}} Constants --

-- Set up logger {{{ --
local log = hs.logger.new("PasteRegister")
spoon.log = log
-- }}} Set up logger --

-- debug() {{{ --
-- Enable or disable debugging
--
--- Parameters:
---  * enable - Boolean indicating whether debugging should be on
---
--- Returns:
---  * Nothing
spoon.debug = function(enable)
  if enable then
    log.setLogLevel('debug')
    log.d("Debugging enabled")
  else
    log.d("Disabling debugging")
    log.setLogLevel('info')
  end
end
-- }}}  debug() --

-- PasteRegister:bindHotKey() {{{ --
--- PasteRegister:bindHotKey(self, table)
--- Method
--- Accepts a table of key bindings, e.g.:
---   {
---     save = {{"cmd", "alt"}, "s"},
---     load = {{"cmd", "alt"}, "l"},
---     paste = {{"cmd", "alt"}, "p"},
---   }
---
--- Parameters:
---  * table - Table of action to key mappings
---
--- Returns:
---  * PasteRegister object

spoon.bindHotKeys = function(self, table)
  for feature,mapping in pairs(table) do
    if feature == "load" then
       self.hotkey = hs.hotkey.bind(mapping[1], mapping[2],
         function() self:queryAndLoadPasteBuffer() end)
     elseif feature == "save" then
       self.hotkey = hs.hotkey.bind(mapping[1], mapping[2],
         function() self:queryAndSavePasteBuffer() end)
     elseif feature == "paste" then
       self.hotkey = hs.hotkey.bind(mapping[1], mapping[2],
         function() self:queryAndPasteRegister() end)
     else
       log.wf("Unrecognized key binding feature '%s'", feature)
     end
   end
  return self
end
-- }}} PasteRegister:bindHotKey() --

-- wrapRegisterFunction() {{{ --
--- wrapRegisterFunction()
--- Internal function
--- Given a callback that manipulates a register, create a modal that
--- allows selection of a register and passes it to the callback.
---
--- Parameters:
--- * msg -  String displayed when callback is activated.
---
--- Returns:
--- *  A function to activate the modal.

local function wrapRegisterFunction(callback, msg)
  local modal = hs.hotkey.modal.new(NoMod, Unbound, NoMsg)

  -- Create bindings for all legal registers
  -- Since hs.hotkey doesn't pass character to callback, we create a separate
  -- call back function for each key.
  -- TODO: Find a way to throw an error for non-legal registers
  -- Kudos for string iterator: https://stackoverflow.com/a/832414/197789
  for c in legalRegisters:gmatch(".") do
    local wrappedCallback = function()
      -- Need to exit modal before callback. If callback is pasting text,
      -- modal will eat it if still active.
      modal:exit()
      callback(c)
    end
    modal:bind(NoMod, c, NoMsg, wrappedCallback, NoFunc, NoFunc)
  end
  modal:bind(NoMod, "escape", "Canceled", function() modal:exit() end)

  -- Display message while in modal
  modal.entered = function()
    local uuid = hs.alert(msg, Indefinite)
    modal.exited = function() hs.alert.closeSpecific(uuid) end
  end

  return function() modal:enter() end
end
-- }}} wrapRegisterFunction() --

--- pasteboardCopy() {{{ --
--- pasteboardCopy()
--- Internal Function
--- Copy one pasteboard to another
--- If either from or to is nil, the system pasteboard is used.
--- By not going through StyledText this is a more accurate copy
---
--- Parameters:
--- * from: Name of source pasteboard
--- * to: Name of destination pasteboard
---
--- Returns:
--- * True on success, false on failure
function pasteboardCopy(from, to)
  local data = hs.pasteboard.readAllData(from)
  if not data then
    return false
  end
  return hs.pasteboard.writeAllData(to, data)
end
-- }}} pasteboardCopy() --


-- PasteRegister:savePasterBuffer() {{{ --
--- PasteRegister:savePasterBuffer()
--- Method
--- Save PasteBuffer to register
---
--- Parameters:
--- * register: Character identifying register to which to save
---
--- Returns:
--- * True if the operation succeeded, otherwise false
local function savePasteBuffer(register)
  hs.alert.show("Saving paste buffer to register " .. register)
  return pasteboardCopy(nil, registerPrefix .. register)
end

spoon.savePasteBuffer = savePasteBuffer
-- }}} PasteRegister:savePasterBuffer() --

-- PasteRegister:queryAndSavePasteBuffer() {{{ --
--- PasteRegister:queryAndSavePasteBuffer()
--- Method
--- Ask the user to select a register and save the paste buffer
--- to that register.
---
--- Parameters:
--- * None
---
--- Returns:
--- * True if the operation succeeded, otherwise false
spoon.queryAndSavePasteBuffer =
  wrapRegisterFunction(savePasteBuffer, "Press key for register to save to")
-- }}} PasteRegister:queryAndSavePasteBuffer() --

-- PasteRegister:loadPasteBuffer() {{{ --
--- PasteRegister:loadPasteBuffer()
--- Method
--- Load PasteBuffer from register
---
--- Parameters:
--- * register: Character identifying register from which to load
---
--- Returns:
--- * True if the operation succeeded, otherwise false
local function loadPasteBuffer(register)
  local contents = hs.pasteboard.getObject(registerPrefix .. register)
  if contents then
    hs.alert.show("Loading paste buffer from register " .. register)
    return pasteboardCopy(registerPrefix .. register, nil)
  else
    hs.alert.show("Register " .. register .. " empty.")
    return false
  end
end

spoon.loadPasteBuffer = loadPasteBuffer
-- }}} PasteRegister:loadPasteBuffer() --

-- PasteRegister:queryAndLoadPasteBuffer() {{{ --
--- PasteRegister:queryAndLoadPasteBuffer()
--- Method
--- Ask the user to select a register and load the paste buffer
--- from that register.
---
--- Parameters:
--- * None
---
--- Returns:
--- * True if the operation succeeded, otherwise false
spoon.queryAndLoadPasteBuffer =
  wrapRegisterFunction(loadPasteBuffer, "Press key for register to load")
-- }}} PasteRegister:queryAndLoadPasteBuffer() --

-- PasteRegister:pasteRegister() {{{ --
--- PasteRegister:pasteRegister()
--- Method
--- Paster directly from register without changing default pastebuffer
---
--- Parameters:
--- * register: Character identifying register from which to load
---
--- Returns:
--- * Nothing
local function pasteRegister(register)
  -- hs.eventtap.keyStrokes() cannot handle styledtext
  local contents = hs.pasteboard.readString(registerPrefix .. register)
  if contents then
    hs.alert.show("Pasting from register " .. register)
    hs.eventtap.keyStrokes(contents)
  else
    hs.alert.show("Register " .. register .. " empty.")
  end
end

spoon.pasteRegister = pasteRegister
-- }}} PasteRegister:pasteRegister() --

-- PasteRegister:queryAndPasteRegister() {{{ --
--- PasteRegister:queryAndPasteRegister()
--- Method
--- Ask the user to select a register and then paste that register's
--- contents directly (via keyStrokes())
---
--- Parameters:
--- * None
---
--- Returns:
--- * Nothing
spoon.queryAndPasteRegister =
  wrapRegisterFunction(pasteRegister, "Press key for register to paste")
-- }}} PasteRegister:queryAndPasteRegister() --

return spoon
-- vim: foldmethod=marker:
