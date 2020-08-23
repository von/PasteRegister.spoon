--- === PasteRegister ===
---
--- Allow the saving of the pastebuffer to registers identified by
--- letters of the alphabet, and sequently loading it from those
--- registers.

local PasteRegister = {}

-- Metadata {{{ --
PasteRegister.name="PasteRegister"
PasteRegister.version="0.4"
PasteRegister.author="Von Welch"
PasteRegister.license="Creative Commons Zero v1.0 Universal"
PasteRegister.homepage="https://github.com/von/PasteRegister.spoon"
-- }}} Metadata --

-- Constants {{{ --
local NoMod = {}
local Unbound = nil
local NoMsg = nil
local NoFunc = nil
local Indefinite = "indefinite"  -- For alerts
-- }}} Constants --

-- Class variables {{{ --
-- The following are used by internal functions

-- Prefix for register key to create pasteboard name
PasteRegister.registerPrefix = "Hammerspoon-register-"

-- List of legal registers
PasteRegister.legalRegisters = "0123456789abcdefghijklmnopqrstuvwxyz"

-- }}} Class variables --

-- PasteRegister:init() {{{ --
--- PasteRegister:init()
--- Method
--- Initializes a PasteRegister
--- When a user calls hs.loadSpoon(), Hammerspoon will load and execute init.lua
--- from the relevant s.
--- Do generally not perform any work, map any hotkeys, start any timers/watchers/etc.
--- in the main scope of your init.lua. Instead, it should simply prepare an object
--- with methods to be used later, then return the object.
---
--- Parameters:
---  * None
---
--- Returns:
---  * PasteRegister object
function PasteRegister:init()
  self.log = hs.logger.new("PasteRegister")

  return self
end
-- }}} PasteRegister:init() --

-- PasteRegister:debug() {{{ --
--- PasteRegister:debug()
--- Method
--- Enable or disable debugging
---
--- Parameters:
---  * enable - Boolean indicating whether debugging should be on
---
--- Returns:
---  * Nothing
function PasteRegister:debug()
  if enable then
    self.log.setLogLevel('debug')
    self.log.d("Debugging enabled")
  else
    self.log.d("Disabling debugging")
    self.log.setLogLevel('info')
  end
end
-- }}} PasteRegister:debug() --

-- PasteRegister:bindHotKeys() {{{ --
--- PasteRegister:bindHotKeys(table)
--- Method
--- Accepts a table of key bindings, e.g.:
---   {
---     save = {{"cmd", "alt"}, "s"},
---     load = {{"cmd", "alt"}, "l"},
---     paste = {{"cmd", "alt"}, "p"},
---     paste = {{"cmd", "alt"}, "c"}
---   }
---
--- Parameters:
---  * table - Table of action to key mappings
---
--- Returns:
---  * PasteRegister object

function PasteRegister:bindHotKeys(table)
  for feature,mapping in pairs(table) do
    if feature == "load" then
       hs.hotkey.bind(mapping[1], mapping[2], function() self:queryAndLoadPasteBuffer() end)
     elseif feature == "save" then
       hs.hotkey.bind(mapping[1], mapping[2], function() self:queryAndSavePasteBuffer() end)
     elseif feature == "paste" then
       hs.hotkey.bind(mapping[1], mapping[2], function() self:queryAndPasteRegister() end)
     elseif feature == "chooser" then
       hs.hotkey.bind(mapping[1], mapping[2], function() self:chooser() end)
     else
       log.wf("Unrecognized key binding feature '%s'", feature)
     end
   end
  return s
end
-- }}} PasteRegister:bindHotKeys() --

-- wrapRegisterFunction() {{{ --
-- wrapRegisterFunction()
-- Internal function
-- Given a callback that manipulates a register, create a modal that
-- allows selection of a register and passes it to the callback.
--
-- Parameters:
-- * callback - function to call when hotkey pressed
-- * msg -  String displayed when callback is activated.
--
-- Returns:
-- *  A function to activate the modal.
local function wrapRegisterFunction(callback, msg)
  local modal = hs.hotkey.modal.new(NoMod, Unbound, NoMsg)

  -- Create bindings for all legal registers
  -- Since hs.hotkey doesn't pass character to callback, we create a separate
  -- call back function for each key.
  -- TODO: Find a way to throw an error for non-legal registers
  -- Kudos for string iterator: https://stackoverflow.com/a/832414/197789
  for c in PasteRegister.legalRegisters:gmatch(".") do
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

-- pasteboardCopy() {{{ --
-- pasteboardCopy()
-- Internal Function
-- Copy one pasteboard to another
-- If either from or to is nil, the system pasteboard is used.
-- By not going through StyledText this is a more accurate copy
--
-- Parameters:
-- * from: Name of source pasteboard
-- * to: Name of destination pasteboard
--
-- Returns:
-- * True on success, false on failure
local function pasteboardCopy(from, to)
  local data = hs.pasteboard.readAllData(from)
  if not data then
    return false
  end
  return hs.pasteboard.writeAllData(to, data)
end
-- }}} pasteboardCopy() --

-- savePasterBuffer() {{{ --
-- savePasterBuffer()
-- Internal Function
-- Save PasteBuffer to register
--
-- Parameters:
-- * register: Character identifying register to which to save
--
-- Returns:
-- * True if the operation succeeded, otherwise false
local function savePasteBuffer(register)
  hs.alert.show("Saving paste buffer to register " .. register)
  return pasteboardCopy(nil, PasteRegister.registerPrefix .. register)
end
-- }}} savePasterBuffer() --

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

local queryAndSavePasteBuffer =
  wrapRegisterFunction(savePasteBuffer, "Press key for register to save to")

function PasteRegister:queryAndSavePasteBuffer()
  return queryAndSavePasteBuffer()
end

-- }}} PasteRegister:queryAndSavePasteBuffer() --

-- loadPasteBuffer() {{{ --
-- loadPasteBuffer()
-- Internal Function
-- Load PasteBuffer from register
--
-- Parameters:
-- * register: Character identifying register from which to load
--
-- Returns:
-- * True if the operation succeeded, otherwise false
local function loadPasteBuffer(register)
  local contents = hs.pasteboard.getContents(PasteRegister.registerPrefix .. register)
  if contents then
    hs.alert.show("Loading paste buffer from register " .. register)
    return pasteboardCopy(PasteRegister.registerPrefix .. register, nil)
  else
    hs.alert.show("Register " .. register .. " empty.")
    return false
  end
end
-- }}} loadPasteBuffer() --

-- PasteRegister:queryAndLoadPasteBuffer() {{{ --
--- PasteRegister:queryAndLoadPasteBuffer()
--- Function
--- Ask the user to select a register and load the paste buffer
--- from that register.
---
--- Parameters:
--- * None
---
--- Returns:
--- * True if the operation succeeded, otherwise false
local queryAndLoadPasteBuffer =
  wrapRegisterFunction(loadPasteBuffer, "Press key for register to load")

function PasteRegister:queryAndLoadPasteBuffer()
  return queryAndLoadPasteBuffer()
end
-- }}} PasteRegister:queryAndLoadPasteBuffer() --

-- pasteRegister() {{{ --
-- PasteRegister.pasteRegister()
-- Internal Function
-- Paster directly from register without changing default pastebuffer
--
-- Parameters:
-- * register: Character identifying register from which to load
--
-- Returns:
-- * Nothing
local function pasteRegister(register)
  -- hs.eventtap.keyStrokes() cannot handle styledtext
  local contents = hs.pasteboard.readString(PasteRegister.registerPrefix .. register)
  if contents then
    hs.alert.show("Pasting from register " .. register)
    hs.eventtap.keyStrokes(contents)
  else
    hs.alert.show("Register " .. register .. " empty.")
  end
end
-- }}} pasteRegister() --

-- PasteRegister.queryAndPasteRegister() {{{ --
--- PasteRegister.queryAndPasteRegister()
--- Method
--- Ask the user to select a register and then paste that register's
--- contents directly (via keyStrokes())
---
--- Parameters:
--- * None
---
--- Returns:
--- * Nothing
local queryAndPasteRegister =
  wrapRegisterFunction(pasteRegister, "Press key for register to paste")

function PasteRegister:queryAndPasteRegister()
  queryAndPasteRegister()
end
-- }}} PasteRegister:queryAndPasteRegister() --

-- PasteRegister:chooser() {{{ --
--- PasteRegister:chooser()
--- Method
--- Open a hs.chooser instance with registers that have content.
---
--- Parameters:
--- * None
---
--- Returns:
--- * Nothing
function PasteRegister:chooser()
  local function chooserCallback(choice)
    if choice == nil then
      return
    end
    loadPasteBuffer(choice.register)
  end

  local choices = {}
  for register in PasteRegister.legalRegisters:gmatch(".") do
    local contents = hs.pasteboard.getContents(PasteRegister.registerPrefix .. register)
    if contents then
      table.insert(choices, {
          text = string.format("[%s] %.40s", register, contents),
          register = register
        })
    end
  end

  local chooser = hs.chooser.new(chooserCallback)
  chooser:choices(choices)
  chooser:show()
end
-- }}} PasteRegister:chooser() --

return PasteRegister
-- vim: foldmethod=marker:
