Download: <https://github.com/rohgar/quick-text-copy/releases/latest>

Quick Text Copy lets you quickly copy text snippets that you frequently use. Just create a simple file which contains your text, and load it. Selecting an item will automatically copy it to clipboard and paste it to the cursor location.

### Basic Usage
 
1. Create a simple text file with no extension or with an extension .txt, .log or .properties.
    * Each **line** in the file corresponds to the snippet that you want to copy.
    * Each **empty line** in the file corresponds to a **separator**.
2. Open the app. It shows up in the menubar (somewhere near the "wifi" icon). 
3. Load the file you created.
4. Click on any item to automatically copy it to clipboard.

### Giving titles to snippets
 
Sometimes some snippets may be too similar to each other, or too long, etc. In these cases, you can give titles to the snippets. The title and the snippet must be separated by an `=`. Thus each line will be of the form `title=snippet`. This file **must** be given an extension `.properties`. When this file is loaded, only the **title** is shown in the menu, and clicking on the title copies the **snippet** for that title to clipboard. If there is no snippet for that title then the title itself will be copied to the clipboard.

 Example `<filename>.properties`:
 ```
System IP=127.0.0.3/
Meeting Response=In meeting, will call you back later.
name@domain.com
Youtube=https://www.youtube.com/
Apple Deals=https://www.apple.com/shop/browse/home/specialdeals
 ```
