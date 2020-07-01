require 'sqlite3'

# Open the database
db = SQLite3::Database.open 'database.sqlite'

# Get notes from the database that...
# - are tagged with `#publish`
# - were updated after last night at midnight
results = db.get_first_value "SELECT COUNT(*) FROM ZSFNOTE;"

# Get the text from the note
# (front-matter should already be in Bear)

# For each result, create a text file with a .md ending

# first_result = results.next

puts results