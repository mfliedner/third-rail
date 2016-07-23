# ThirdRail

ThirdRail is a light-weight MVC implementation inspired by ActiveRecord and ActionController in Rails and is built on ActiveSupport.

The `SQLObject` class represents "M" (Model) in MVC.  It implements the Object Relational Mapping pattern that allows the user to perform database operations without writing SQL queries.

The `ControllerBase` provides basic Rails ActionController functionalities (the "C" in MVC) handling HTML requests and responses.  It exchanges data with the database through the Model and creates output through Views (the "V" in MVC) rendering ERB templates.

## Set up

* `cat demo/seed.sql | sqlite3 demo/db_file.db`

`SQLObject` can connect to any type of Ruby database object as long as it responds to `::execute`, `::execute2` and `::last_insert_row_id`.  To connect to a SQLite3 database, you would run:

```ruby
SQLObjectBase.db = SQLite3::Database.new('db_file.db')
```

`DBConnection` provides the connection to a demo SQLite3 database (it is used with the source file versions in lib/dbconnect).

To initialize the `DBConnection` run:
```ruby
DBConnection.reset
```
