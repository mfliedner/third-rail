# ThirdRail

ThirdRail is a light-weight MVC implementation inspired by ActiveRecord and ActionController in Rails and is built on ActiveSupport.  It provides a router, exception handling, and a static asset server.  Rack middleware is used for HTML requests and responses.  `Rack::Builder` and `Rack::Server` are used in the demo tests to run simple apps built with ThirdRail through a WEBrick HTTP server on `localhost`.

The `SQLObject` class represents "M" (Model) in MVC.  It implements the Object Relational Mapping pattern that allows the user to perform database operations without writing SQL queries.

The `ControllerBase` provides basic Rails ActionController functionalities (the "C" in MVC) handling HTML requests and responses.  It exchanges data with the database through the Model and creates output through Views (the "V" in MVC) rendering ERB templates.

## Set up

* `bundle install`
* `rm demo/db_file.db`
* `cat demo/seed.sql | sqlite3 demo/db_file.db`

`SQLObject` can connect to any type of Ruby database object as long as it responds to `::execute`, `::execute2` and `::last_insert_row_id`.  To connect to a SQLite3 database, you would run:

```ruby
SQLObject.db = SQLite3::Database.new('db_file.db')
```

`DBConnection` provides the connection to a demo SQLite3 database (it is used with the source file versions in lib/dbconnect).

To initialize the `DBConnection` run:
```ruby
DBConnection.reset
```

With the small demo seed database, you can run `ruby demo/sql_test.rb` to test `SQLObject`.

## SQLObject Functionality

The `SQLObject` class defines the following methods:

* `#save` executes the private `#insert` or `#update` methods depending on the existence of the record in the database
* `::find(id)` returns record with the primary key id
* `::all` returns all records from the database table
* `::columns` returns the database table column names as symbols

it uses the table, class, and association naming conventions of ActiveSupport.  Tables can be named explicitly in the class declaration:

```ruby
class Human < SQLObjectBase
  self.table_name = 'humans'
end
```

Implementation of the SQL WHERE clause is supplied through module extensions `Searchable`:

* `#where` takes parameters as a hash of key (column name), value pairs and logically joins them with "AND"

```ruby
Author.where(first_name: 'Moritz', last_name: 'Fliedner')
```

Associations are defined in the `Associatable` module:

* `#belongs_to`
* `#has_many`
* `#has_one_through`

Implied association names can be overridden just as in Rails ActiveRecord:

```ruby
class Reservation
  #inferred
  belongs_to :restaurant

  #explicit
  belongs_to :guest,
    foreign_key: :guest_id,
    primary_key: :id,
    class_name: 'User'
end
```

## ControllerBase Functionality

The `ControllerBase` class provides the following features:

* `#already_built_response?` prevents double render errors
* `#redirect_to` handles redirection to an URL
* `#render` renders ERB template content
* `#form_authenticity_token` provides an authenticity token to protect forms against cross-site request forgery (CSRF)
* `::protect_from_forgery` enforces CSRF protection

`Session` and `Flash` use cookies to persist data between request and response cycles on the client side.

* `#store_session` stores the session_token
* `#store_flash` is used to store error messages over the current cycle (`flash.now`) or current and next cycle, it does not persist over later cycles.

## Router Functionality

The `Router` class uses metaprogramming (`define_method`) to implement RESTful routing:

```ruby
[:get, :post, :put, :delete].each do |http_method|
  define_method(http_method) do |pattern, controller_class, action_name|
    add_route(pattern, http_method, controller_class, action_name)
  end
end
```

The regex pattern matches the URI in an array of `Route`s to request paths.  Each `Route` invokes an action that corresponds to methods on the controller.  Test this by running `ruby demo/app_test.rb`: the static root page of
my BuffonNeedle app (see it live at https://mfliedner.github.io/) will be rendered as `Content-type` "text/html" on `http://localhost:3000/` in response to a controller `#index` method:

```ruby
class Controller < ControllerBase
  def index
  end
end
```

## Exception Handling

The `ShowExceptions` class displays backtrace and message of a rescued exception as well as a snippet of source code that threw the exception in a readable format through an ERB template, `rescue.html.erb`.

The source soce snippet is extracted from the source file around the line number returned in the first line of the exception backtrace:

```ruby
def source_view
  file = File.readlines(source_file_name)
  start_idx = [0, exception_line_number - 3].max
  end_idx = [file.length-1, exception_line_number + 3].min
  file[start_idx..end_idx].map.with_index do |line, i|
    "#{start_idx+i+1}: #{line}"
  end
end
```

Test the exception log display by running `ruby demo/error_test.rb`.

## Static Assets Server Functionality

The `Static` class serves assets like text or images according to their MIME type from a given root path like `/public`.
