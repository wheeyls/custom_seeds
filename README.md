# CustomSeeds

Seed file helpers for Rails applications.

## Installation

Add this line to your application's Gemfile:

```ruby
    gem 'custom_seeds'
```

And then execute:

    $ bundle

## Usage

Create a seedfile under `db/seeds`:

```ruby
# db/seeds/users/followed_products.rb

CustomSeeds.define do
  title 'Followed Products'
  description 'Add followed products to user accounts'

  let(:products) { Product.validated.sample }

  before do
    FollowedProduct.destroy_all
  end

  records do
    User.all
  end

  each_record do |user|
    products.each do { |product| user.followed_products.create!(product: product) }
  end

  log_each do |user|
    "User #{user.email} followed #{user.followed_products.count} products"
  end
end
```

### CLI

Run seeds using the `rseed` command:

    $ rseed
    $ rseed db/seeds/users/
    $ rseed db/seeds/users/followed_products.rb
    $ rseed db/seeds/users/followed_products.rb --dry-run
    $ rseed db/seeds/users/followed_products.rb --verbose

Run all seeds:

### Rake

Run the file using the rake task:

```bash
$ rake db:seed:users:followed_products
```

Run all seeds using the rake task:

```bash
$ rake db:seed:all
```
