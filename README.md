# Kickoff Bootstrap – Rails Template
Kickoff is a rapid Rails template using [Bootstrap](https://getbootstrap.com/), so you pass it in as an option when creating a new app.

Heavily by [Jumpstart](https://github.com/excid3/jumpstart) from [Chris Oliver](https://twitter.com/excid3/) and [Kickoff Tailwind](https://github.com/justalever/kickoff_tailwind) from [Andy Leverenz](http://www.justalever.com/).

#### Requirements

You'll need the following installed to run the template successfully:

* Ruby 3 or higher (3.0.1 is recommended) - `rvm install 3.0.1` and then `rvm use 3.0.1`
* Bundler - `gem install bundler`
* Rails 6 or higher - `gem install rails -v 6.0.4.1`
* Database - Postgres is recommended, but you can use MySQL, SQLite3, etc
* Yarn - `brew install yarn` or [Install Yarn](https://yarnpkg.com/en/docs/install)
* Foreman (optional) - `gem install foreman` - helps run all your processes in development

#### Creating a new app

```bash
rails _6.0.4.1_ new myapp -d <postgresql, mysql, sqlite3> -T -m https://raw.githubusercontent.com/andreaflether/kickoff_bootstrap/main/template.rb
```

Or if you have downloaded this repo, you can reference template.rb locally:

```bash
rails _6.0.4.1_ new myapp -d <postgresql, mysql, sqlite3> -T -m template.rb
```
### Included libraries

#### Gems
- Devise
- Name of Person
- Simple Form

#### Test
RSpec setup including: FactoryBot, Faker, Database Cleaner and SimpleCov.

#### Javascript
Webpacker with Bootstrap, Toastr and Font Awesome.
