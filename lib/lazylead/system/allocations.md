## Enable profiler
https://ruby-prof.github.io
```ruby
require 'ruby-prof'
alloc = RubyProf.profile(:track_allocations => true) do
  # code  
end
printer = RubyProf::MultiPrinter.new(alloc)
printer.print(:path => ".", :profile => "alloc")
```

## Jira allocation memory
Fields: `assignee,summary,priority,duedate,reporter`

| Tickets       | Bytes     | KB        | MB        |
| ------------- | :-------: | :-------: | :-------: |
| 1             | 40        | 0.03      | 0,00003   |
| 157           | 6280	    | 6.13      | 0.59      |
| 4315          | 172600	| 168.55    | 0.16      |
| 10379         | 415160    | 405.42    | 0.39      |
|~10000         | ~400000	| ~390.625  | ~0.38     |

## GitHub allocation memory		 			
TBD