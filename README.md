# Bookmarks

Simple bookmark list as a RESTful API in Ruby.

* Admin has access to everything
* User can read all, create all, but update and deleted only his records
* Guest has only read access

## First time setup

Copy the database config file:

```bash
cp config/database.yml.example config/database.yml
```

Install gems dependencies:

```bash
gem install bundler
bundle install
rake db:setup
```

## To Start the app

And start the server:

```bash
rackup config.ru
```

To find out more about different `rackup` options:

```bash
rackup --help
```

## To Start a console

```bash
rake console
```


## Exec tests

```bash
RACK_ENV=test rake db:setup
rake spec
```

## Contributing

1. [Fork](https://help.github.com/articles/fork-a-repo) this repo
2. Create a topic branch - `git checkout -b my_branch`
3. Push to your branch - `git push origin my_branch`
4. Create a [Pull Request](http://help.github.com/pull-requests/) from your
   branch
5. That's it!

## Copyright and license

Copyright (c) 2015 Duilio Ruggiero. Code released under [the MIT license](LICENSE).
