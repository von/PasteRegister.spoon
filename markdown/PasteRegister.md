# [docs](index.md) » PasteRegister
---

Allow the saving of the pastebuffer to registers identified by
letters of the alphabet, and sequently loading it from those
registers.

## API Overview
* Functions - API calls offered directly by the extension
 * [bindHotKeys](#bindHotKeys)
 * [chooser](#chooser)
 * [debug](#debug)
 * [init](#init)
 * [queryAndLoadPasteBuffer](#queryAndLoadPasteBuffer)
 * [queryAndPasteRegister](#queryAndPasteRegister)
 * [queryAndSavePasteBuffer](#queryAndSavePasteBuffer)

## API Documentation

### Functions

| [bindHotKeys](#bindHotKeys)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `PasteRegister:bindHotKeys(table)`                                                                    |
| **Type**                                    | Function                                                                     |
| **Description**                             | Accepts a table of key bindings, e.g.:                                                                     |
| **Parameters**                              | <ul><li>table - Table of action to key mappings</li></ul> |
| **Returns**                                 | <ul><li>PasteRegister object</li></ul>          |

| [chooser](#chooser)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `PasteRegister:chooser()`                                                                    |
| **Type**                                    | Function                                                                     |
| **Description**                             | Open a hs.chooser instance with registers that have content.                                                                     |
| **Parameters**                              | <ul><li>* None</li></ul> |
| **Returns**                                 | <ul><li>* Nothing</li></ul>          |

| [debug](#debug)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `PasteRegister:debug()`                                                                    |
| **Type**                                    | Function                                                                     |
| **Description**                             | Enable or disable debugging                                                                     |
| **Parameters**                              | <ul><li>enable - Boolean indicating whether debugging should be on</li></ul> |
| **Returns**                                 | <ul><li>Nothing</li></ul>          |

| [init](#init)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `PasteRegister:init()`                                                                    |
| **Type**                                    | Function                                                                     |
| **Description**                             | Initializes a PasteRegister                                                                     |
| **Parameters**                              | <ul><li>None</li></ul> |
| **Returns**                                 | <ul><li>PasteRegister object</li></ul>          |

| [queryAndLoadPasteBuffer](#queryAndLoadPasteBuffer)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `PasteRegister:queryAndLoadPasteBuffer()`                                                                    |
| **Type**                                    | Function                                                                     |
| **Description**                             | Ask the user to select a register and load the paste buffer                                                                     |
| **Parameters**                              | <ul><li>* None</li></ul> |
| **Returns**                                 | <ul><li>* True if the operation succeeded, otherwise false</li></ul>          |

| [queryAndPasteRegister](#queryAndPasteRegister)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `PasteRegister.queryAndPasteRegister()`                                                                    |
| **Type**                                    | Function                                                                     |
| **Description**                             | Ask the user to select a register and then paste that register's                                                                     |
| **Parameters**                              | <ul><li>* None</li></ul> |
| **Returns**                                 | <ul><li>* Nothing</li></ul>          |

| [queryAndSavePasteBuffer](#queryAndSavePasteBuffer)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `PasteRegister:queryAndSavePasteBuffer()`                                                                    |
| **Type**                                    | Function                                                                     |
| **Description**                             | Ask the user to select a register and save the paste buffer                                                                     |
| **Parameters**                              | <ul><li>* None</li></ul> |
| **Returns**                                 | <ul><li>* True if the operation succeeded, otherwise false</li></ul>          |

