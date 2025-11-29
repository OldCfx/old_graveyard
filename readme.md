# 🪦 old_graveyard  
A FiveM script using **ox_lib** that allows staff to create and interact with grave markers, perfect for roleplay servers that want to honor the fallen.

---

## 📖 Features

✅ Create grave markers directly in-game  
✅ Store grave data in a `JSON` file (persistent between restarts)  
✅ View detailed information when interacting with a grave  
✅ Real-time updates — no need to restart the resource  
✅ Fully integrated **ox_lib** interface  
✅ Support for photos  
✅ Permission-based commands (set in `shared/config.lua`)

---

## ⚙️ Installation

1. **Dependencies**
   - Ensure you have [ox_lib](https://overextended.github.io/docs/ox_lib) installed and properly loaded before this resource.

2. **Folder Setup**
   Place the resource inside your server’s `resources/` folder:

   ```
   resources/[custom]/old_graveyard
   ```

3. **Add to `server.cfg`:**
   ```bash
   ensure ox_lib
   ensure old_graveyard
   ```

---

## ⚰️ Commands

### `/addgrave`
Creates a new grave marker at your player’s current location.

- **Opens a dialog** with the following fields:
  - Full Name  
  - Date of Birth *(date picker)*  
  - Date of Death *(date picker)*  
  - Cause of Death  
  - Photo (URL)

The data is saved to `shared/data.json`.

---

### `/delgrave [id]`
Deletes a grave by its unique **ID**.

- Removes the marker in real-time from all clients.
- Accessible only to players/groups defined in `Config.restrictedCommand`.

---

## 🧠 Configuration

All editable options are in `shared/config.lua`.

---

## 🪶 Interactions

When approaching a grave:
- A floating **Text UI** appears with an icon and key hint:
  > 🪦  [E] – Read the headstone  
- Press **E** to open a detailed **alert dialog** showing:
  - Name  
  - Birth / Death dates  
  - Cause of death  
  - Optional photo displayed inline  

You can even implement custom actions (e.g., placing flowers) through the dialog’s buttons.

---