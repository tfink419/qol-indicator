FROM ruby:2.6.5

RUN apt-get update -qq && apt-get install -y \
  libvips \
  libvips-dev \
  nodejs \
  postgresql-client

# Add Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && apt-get install -y yarn

# App
WORKDIR /usr/src/app
COPY Gemfile* ./
RUN gem install bundler -v 2.1.4
RUN bundle config set without 'development test' &&\
  bundle install
COPY . .
RUN yarn install --frozen-lockfile
RUN ASSETS_PRECOMPILE=true SECRET_KEY_BASE=doesntmatterrightnow RAILS_ENV=production bundle exec rails assets:precompile

# Start the main process.
# CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "$PORT"]