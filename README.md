# Friday Night Funkin' Pitstop DLC

A nice pack (Eventually) of one shot songs into one playable experience!

## Credits

- Maki (me!) - Artist, Animator, Main Programmer

- Requazar - Lead Composer

- Nikodeg - Artist

## Compiling

Step by Step to get Compiling once you have the repo downloaded:

1. Install [Haxe](https://haxe.org/download/) (4.3.7 recommended, I don't know about earlier or later versions having support)
2. Run `haxelib --global install hmm` in your terminal to get hmm
3. Run `haxelib --global run hmm install` in your terminal to install the libraries
4. Run `haxelib run lime setup` in your terminal to get the `lime` command!
5. Perform additional platform setup
   - For Windows, download the [Visual Studio Build Tools](https://aka.ms/vs/17/release/vs_BuildTools.exe)
     - When prompted, select "Individual Components" and make sure to download the following:
     - MSVC v143 VS 2022 C++ x64/x86 build tools
     - Windows 10/11 SDK
   - Mac: [`lime setup mac` Documentation](https://lime.openfl.org/docs/advanced-setup/macos/)
   - Linux: [`lime setup linux` Documentation](https://lime.openfl.org/docs/advanced-setup/linux/)
6. If you are targeting for native, you may need to run `lime rebuild <PLATFORM>` and `lime rebuild <PLATFORM> -debug`
7. `lime test <PLATFORM>` to build and launch the game for your platform (for example, `lime test windows`)

And then you should be good!