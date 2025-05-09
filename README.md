# NOT FINISHED

## How to use (PC)
1. Download [BlueStacks](https://www.bluestacks.com/) and launch the emulator.

2. Once opened, download [Codex](https://codex.lol/android), create fresh account, and join the Roblox game that you wish to copy the GUI from.

3. Execute the code below using codex (advised to use only savetofile).
```lua
Configuration = {
    Savetofile = true,
    Copytoclipboard = false,
    Print = false
}

loadstring(game:HttpGet("https://raw.githubusercontent.com/notr3th/GUI-Stealer/main/loader.lua"))()
```

5. Exit Roblox once it has finished stealing the GUI, go to System Apps> Media Manager> Explore> Codex> Workspace, pick the stored file, and export to Windows.

6. To convert the output to GUI, download the [GUI Stealer plugin](https://github.com/notr3th/GUI-Stealer/blob/main/Plugin.lua) and place it in your Roblox Studio plugins folder.

7. Restart Roblox Studio so it will display in the toolbar.

8. Click on it, and it should prompt you to pick your file containing the output. Once chosen, it will convert the output to GUI.

## Video Tutorial
https://www.youtube.com/watch?v=examplevideo

> Please take note that this is strictly for educational purposes.
