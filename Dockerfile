FROM ruby:2.6.5

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
# lib vips
RUN apt-get -y install libvips libvips-dev
RUN apt-get -q clean

# App
WORKDIR /usr/src/app
COPY Gemfile* ./
RUN gem install bundler -v 2.1.4
RUN bundle config set without 'development test' &&\
  bundle install
RUN bundle exec rails assets:precompile
COPY . .

# Start the main process.
# CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "$PORT"]