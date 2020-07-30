# Bear SQLite To Markdown

**⚠️ NOTE: THIS IS STILL EXPERIMENTAL! ⚠**

This is a simple Ruby script to export Bear notes from SQLite database to markdown files.

## How to use this script

1. Copy the new Bear sqlite database to this local directory. 

    ```
    cp ~/Library/Group\ Containers/9K33E3U3T4.net.shinyfrog.bear/Application\ Data/database.sqlite database.sqlite
    ```

2. Run the ruby script to extract and generate markdown files.

    ```
    ruby sqlite_to_md.rb
    ```

3. Copy the markdown files wherever they need to be.

