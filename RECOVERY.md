# ForeverBuffFrames settings recovery

Earlier WoW Forever beta builds sometimes forgot addon settings after a reload or restart. That issue currently appears resolved. The **Backup / Recovery** tab remains available so you can keep a copy of your setup outside the game and restore it if the problem returns. You do not need to run a program or find a WoW settings folder.

## Save your setup

1. Open ForeverBuffFrames settings and select **Backup / Recovery**.
2. Click **Copy backup code**, then press **Ctrl+C**.
3. Paste the code into Notepad and save the file somewhere you can find it.

Repeat these steps after changing your setup. The saved code contains every named profile and remembers which profile was active.

## Restore your setup

1. Open **Backup / Recovery**.
2. Copy the code from your saved file and paste it into the box on that tab.
3. Click **Restore pasted code**. A current backup replaces the saved profile collection and selects the profile that was active when the code was created.

Older `FBF1`, `FBF2`, and earlier `FBF3` backup layouts remain supported. Because `FBF1` codes contain only one setup, restoring one replaces the settings in the currently active profile without deleting the other named profiles. `FBF2` and `FBF3` codes restore their complete profile collection. New codes include Personal Debuff Trackers and omit the retired expiry-debug setting; codes created before either change remain valid.

The code is a manual backup. WoW addons cannot create a separate recovery file from inside the game, so keep the code outside WoW if you want it available should the earlier settings problem return.
