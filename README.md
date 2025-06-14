## How to use (PC)
1. Download [**BlueStacks**](https://www.bluestacks.com/) and launch the emulator.

2. Once opened, download [**CodeX**](https://codex.lol/android), create fresh account, and join the Roblox game that you wish to copy the GUI from.

3. Execute the code below using codex (advised to use defualt).
```lua
Configuration = {
    Threads = 100,
    Savetofile = true,
    AllServices = false
}

loadstring(game:HttpGet("https://raw.githubusercontent.com/notr3th/Game-Downloader/main/loader.lua"))()
```

5. Exit Roblox once it has finished stealing the game, go to System Apps> Media Manager> Explore> Codex> Workspace, pick the stored file, and export to Windows.

6. To convert the output to studio, download the [**importer plugin**](https://github.com/notr3th/GUI-Stealer/blob/main/Plugin.lua) and place it in your Roblox Studio plugins folder.

7. Restart Roblox Studio so it will display in the toolbar.

8. Click on it, and it should prompt you to pick your file containing the output. Once chosen, it will convert the output to your game.

9. Still unsure? Check out the [**video tutorial**](https://www.youtube.com/watch?v=examplevideo) for a more detailed guide.

# Features
| Feature | Description |
| :--- | :--- |
| Threads | This sets how many instances are saved at once — higher number means faster but uses more performance, lower number is slower but easier on your system. |
| Savetofile | Turning this off means the game file won't be saved at all. Only disable it if you're testing things out. |
| AllServices | If set to true, it will save instances from all services. It's usually best to leave this false, since most of the extra services aren't useful—unless you specifically need them for your own purposes. |

##
> Please take note that this is strictly for educational purposes.
