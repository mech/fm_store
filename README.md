# FmStore

Based on Mongoid implementation, FmStore behaves in a way very similar to how
you might expect ActiveRecord to behave. With callback and validation and ActiveModel
adherence.

## Database setup

Place a `fm_store.yml` file inside the config directory.

```
development:
  host: 127.0.0.1
  account_name:
  password:
  ssl: false
  log_actions: true
```
  
## Model setup

You can setup a model using the following generator:
  
`rails generate fm_model <file_name> <layout_name> <database_name>`

This is using the Job example:

```ruby
class Job
  include FmStore::Layout

  set_layout "jobs"
  set_database "jobs "

  field :modify_date, DateTime, :fm_name => "modify date"
  field :company,     String
  field :location,    String
  field :jdid,        String
  ... # more fields

  has_many :job_applications, :reference_key => "jdid"

  validates_presence_of :job_title

  # put your class methods here
  class << self
    def published
      where("status" => "open")
    end
  end
end
```

## format_with option

There will be times when FileMaker give us String or Numeric ID. For example, `caid` can become "52383.0".
What we really want is a String like "52383". You can force it by using the `format_with` option and provide
your own implementation of the ID.

```ruby
has_many :employments, :reference_key => "candidate_id", :format_with => :formatted_candidate_id

def formatted_candidate_id
  candidate_id.to_s.split(".").first
end
```

## Finders

All finder methods such as `where`, `limit`, `order`, `in` return a criteria object
which contain the params and options. No database call will be made until a kicker
method has been called such as `each`, `first`, etc.

```ruby
# Find single job with ID. There is no #find method. Not to be confused with
# the instance method Job#id like @job.id which return you "JDID1" for example.
# ID will default to -recid. If you wish to change that, use the :identity option
class Job
  include FmStore::Layout
  
  field :job_id, String, :fm_name => "jdid", :identity => true
end

@job = Job.id("JDID1") #=> You do not need to append "=" sign to it, like "=JDID1"

You still can get the original internal FileMaker id by:

@job = Job.fm_id("18") # Using the -recid

# Find 10 records
@jobs = Job.limit(10)

# Find 10 records sorted. By default is ASC
@jobs = Job.limit(10).order("status") # same as @jobs = Job.limit(10).order("status asc")
@jobs = Job.limit(10).order("status desc, jdid")

# Find based on condition (single value per field). Please use the field name
# rather than the FileMaker field name like "modify date"
@jobs = Job.where("status" => "open")
@jobs = Job.where("category" => "Account", "status" => "open")

# Find with operator
@jobs = Job.where("salary.gt" => 2500)

# Find all payroll details whose gross salary is between $1.00 to $10.00 in order
PayrollDetail.where("gross_salary.bw" => "1...10").order("gross salary")

# Excluding
# WARNING - exclude cannot chain to search for now
@jobs = Job.where("status.neq" => "open")
@jobs = Job.exclude("status" => "open") # this is preferred

# Logical OR
# By default, conditions are ANDed together. Pass in false to make it ORed together
# Remember to supply curly braces for the first parameter which is a hash
@jobs = Job.where({"status" => "open", :category => "Account"}, false)

# Total count
@total = Job.where("status" => "closed").total
@total = Job.total

# Find based on multiple values in a single field
@jobs = Job.in(:status => ["pending", "closed"])
@jobs = Job.in(:status => ["pending", "closed"]).order("status").limit(10)

# You can also pass in single String instead of an array
@jobs = Job.in(:status => "open", :job_id => ["=JD123", "=JD456"]) #=> the value "open" will automatically be ["open"]
```

## Search

Every model will be exposed the `search` class method. Based on the `searchable`
field option, this `search` method will know which fields to search for.
  
```ruby
# In your model
field :name, String, :fm_name => "company", :searchable => true

# Search for it in your controller
@company = Company.search(params)

@companies = Company.where(:category => "REGULAR").search(params)
@jobs = Job.in(:status => ["open", "pending"]).search(:q => "engineer, programmer")
```

`search` will always look for params[:q] as the query keyword and params[:page] as the page number.

WARNING - Please note that `exclude` cannot use `search` for now.

Some search examples:

```ruby
Job.where(:status => "open").search(:q => "engineer")           #=> (q0,q1)
Job.in(:status => ["open"]).search(:q => "engineer")            #=> (q0,q1)
Job.in(:status => ["open", "pending"]).search(:q => "engineer") #=> (q0,q2);(q1,q2)
```  
  
## Pagination

Paging is supported via WillPaginate rails3 branch. Any `limit` criteria will be
ignore when you call `paginate`, but you can override `per_page` as usual.

```ruby
@jobs = Job.where("status" => "open").paginate(:page => params[:page] || 1)
@jobs = Job.where("status" => "open").paginate(:per_page => 10, :page => params[:page] || 1)
```

`paginate` is a kicker method in itself so database connection will be made and
result being retrieved.

## Custom query

If any of the `where`, `in`, `exclude` do not meet your need, you can build the query yourself using FileMaker's `findquery` command.

For example:

```ruby
JobApplication.custom_query(
  "-query" => "(q0,q1);!(q2);!(q3);!(q4)",
  "-q0" => "caid",
  "-q0.value" => "123",
  "-q1" => "status2",
  "-q1.value" => "DeclineOffer",
  "-q2" => "status1",
  "-q2.value" => "Apply",
  "-q3" => "status1",
  "-q3.value" => "Select",
  "-q4" => "status1",
  "-q4.value" => "SMS"
).order("date2 DESC")
```

The query is

`(q0,q1);!(q2);!(q3);!(q4)`
  
which means find
  
`q0 and q1 and omit q2, q3, and q4`
  
## Available operators

* eq    =word
* cn    *word*
* bw    word*
* ew    *word
* gt    > word
* gte   >= word
* lt    < word
* lte   <= word
* neq   omit,word

## Persistence

In order to save data to FileMaker, check you have the necessary permission.

```ruby
@leave = Leave.new
@leave.contract_code = "S1234.01"
@leave.fm_attributes #=> {"contract code" => "S1234.01"}
@leave.from_date = Date.today
@leave.fm_attributes #=> {"from"=>"08/19/2010", "contract code" => "S1234.01"}

@leave.valid?   # test if model is valid or not
@leave.errors   # get all the errors if there are any
@leave.save     # this will automatically called valid? and return false if failed
```  

As you can see, the real work of converting Ruby object to the one suitable for FileMaker is the `fm_attributes` value method.
