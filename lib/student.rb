require 'pry'

class Student

  attr_accessor :id, :name, :tagline, :github, :twitter, :blog_url, :image_url, :biography
  #all methods have def id @id end and def id=(id) @id = id end

  def self.create_table
     DB[:conn].execute("""CREATE TABLE students (
     id INTEGER PRIMARY KEY AUTOINCREMENT,
     name TEXT,
     tagline TEXT,
     github TEXT,
     twitter TEXT,
     blog_url TEXT,
     image_url TEXT,
     biography TEXT);""")
  end
  #create table : execute SQL to the database

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS students;")
  end
  #drop table : execute SQL to the database

  def insert
    array = [[@name, @tagline, @github, @twitter, @blog_url, @image_url, @biography]]
    ins = DB[:conn].prepare("INSERT INTO students (name, tagline, github, twitter, blog_url, image_url, biography) VALUES (?, ?, ?, ?, ?, ?, ?);")
    array.each { |s| ins.execute(s)}
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM students;")[0][0]
    #ask steven re. index figures
    #inserting data into an instance
  end

  def self.new_from_db(row)
    # student = Student.new
    # student.id = row[0]
    # student.name = row[1]
    # student.tagline = row[2]
    # student.github = row[3]
    # student.twitter = row[4]
    # student.blog_url = row[5]
    # student.image_url = row[6]
    # student.biography = row[7]
    # student
    #LONG WAY
    self.new.tap do |student|
      student.id = row[0]
      student.name = row[1]
      student.tagline = row[2]
      student.github = row[3]
      student.twitter = row[4]
      student.blog_url = row[5]
      student.image_url = row[6]
      student.biography = row[7]
    end
    #USING TAP WHICH CALLS TO A BLOCK
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
	  FROM students
  	WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name)
    # binding.pry
    row.map { |row| self.new_from_db(row)}.first
    #finding data within the database based on a single value 
  end

  def update
    	sql = <<-SQL
	    UPDATE students
	    SET name=?, tagline=?, github=?, twitter=?, blog_url=?, image_url=?, biography=?
	    WHERE id=?
	    SQL
	    DB[:conn].execute(sql, name, tagline, github, twitter, blog_url, image_url, biography, id)
      #updating existing instances
  end

  def persisted?
     !!id
  end
  #if id returns true the row has been persisted

  def save
    #you're looking to see if theres been anything inserted or updated and
    #based on that you decide how to store the instance
    if persisted?
      update
      #if instance exists ... data inserted will need to 'update'
    else
      insert
      #if instance does not already exist data inserted will have be 'insert'
    end
  end


end
