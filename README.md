Download: <https://github.com/rohgar/quick-text-copy/releases/latest>

Quick Text Copy lets you quickly copy text snippets that you frequently use. Just create a simple file (properties file or a JSON file) which contains your text, and load it. Selecting an item will automatically copy it to clipboard and paste it to the cursor location.

### Basic Usage
 
1. Properties file: 
Create a simple text file with no extension or with an extension .txt, .log or .properties.
    ```
    localhost=127.0.0.3/
    Meeting Response=In meeting, will call you back later.
    name@domain.com
    Youtube=https://www.youtube.com
    ```
    * Each **line** in the file corresponds to the snippet that you want to copy.
    * Each **empty line** in the file corresponds to a **separator**.
1. JSON file: 
Create a simple json file as such:
    ````
    {
      "submenus": [
        {
          "name": "custom-submenu",
          "elements": [
            {
              "key": "key1",
              "value": "value1"
            },
            {
              "key": "key2",
              "value": "value2"
            }
          ]
        }
      ],
      "elements": [
        {
          "key": "key1",
          "value": "value1"
        },
        {
          "key": "key2",
          "value": "value2"
        }
      ]
    }
    ````
2. Open the app. It shows up in the menubar (somewhere near the "wifi" icon). 
3. Load the file you created.
4. Click on any item to automatically copy it to clipboard, and paste it where the cursor is.
