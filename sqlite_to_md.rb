require 'sqlite3'
require 'date'

def cocoa_timestamp_to_datetime(timestamp)
  # unix and coredata timestamps differ by 978307200 seconds 
  cocoa_unix_timestamp_diff = 978307200
  unix_timestamp = timestamp + cocoa_unix_timestamp_diff
  DateTime.strptime(unix_timestamp.to_s,'%s')
end

def datetime_to_cocoa_timestamp(date_time)
  # unix and coredata timestamps differ by 978307200 seconds 
  cocoa_unix_timestamp_diff = 978307200
  date_time.to_i - cocoa_unix_timestamp_diff
end

# Open the database
SQLite3::Database.new 'database.sqlite' do |db|
  db.results_as_hash = true

  # Find the ID for the '#publish' tag
  publish_tag_id = db.get_first_value <<-SQL
  SELECT ZSFNOTETAG.Z_PK FROM ZSFNOTETAG
  WHERE ZSFNOTETAG.ZTITLE = "publish";
  SQL

  # Get notes from the database that...
  # - are tagged with `#publish`
  # - TODO: get only notes that were updated after the last time this ran
  #         OR get every note every time
  query = <<-SQL
  SELECT ZSFNOTE.Z_PK, 
         ZSFNOTE.ZTITLE as NoteTitle,
         ZSFNOTE.ZTEXT as NoteText,
         ZSFNOTE.ZUNIQUEIDENTIFIER as NoteUUID,
         ZSFNOTE.ZMODIFICATIONDATE as LastUpdated
  FROM ZSFNOTE
  LEFT OUTER JOIN Z_7TAGS ON ZSFNOTE.Z_PK = Z_7TAGS.Z_7NOTES AND Z_7TAGS.Z_14TAGS = #{publish_tag_id}
  INNER JOIN ZSFNOTETAG ON Z_7TAGS.Z_14TAGS = ZSFNOTETAG.Z_PK;
  SQL

  # For each result, create a text file with a .md ending
  db.execute(query) do |note|
    # Extract info from the note
    title = note["NoteTitle"]
    note_text = note["NoteText"]
    last_updated = cocoa_timestamp_to_datetime(note["LastUpdated"])
    title_slug = note["NoteUUID"]

    # Prep the file =================================================
    # 1. Strip the last line (that's where the tag is from Bear)
    note_text = note_text.split("\n")[0...-1].join("\n")

    # 2. Write out the front-matter
    front_matter = <<~FMTR
      ---
      slug: "notes/#{title_slug}"
      date: #{last_updated.strftime("%F")}
      title: "#{title}"
      pageType: research-note
      ---
    FMTR
    note_text = front_matter + note_text

    File.write("./markdown-files/#{title_slug}.md", note_text)
  end
end
