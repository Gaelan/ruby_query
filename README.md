RubyQuery
=========

RubyQuery allows you to write MongoDB queries using normal ruby syntax. Instead of writing this:

```json
{
  "favorite_language": "Ruby",
  "projects": {"$elemMatch": {
    "$or": [
      {title: /poignant/},
      {type: "web framework"}
    ]
  }}
}
```

You can write this:

```ruby
RubyQuery.mongo do |person|
  person.favorite_language == 'Ruby' & person.projects.any? do |project|
    project.title =~ /poignant/ | project.type == 'web framework'
  end
end
```

See `spec/ruby_query_spec.rb` for more examples, including all supported operators.

Caveats
-------

 * Because the behavior of `&&` and `||` can't be over-riddden, you must use `&` and `|` instead.
 * Despite looking like normal Ruby methods, arbitrary methods on Array, etc. will not work unless they are explicitly supported.
 * Though the generated queries should work, they are currently way more verbose than what a human would write, and could be much simpler.
