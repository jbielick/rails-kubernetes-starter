FROM ruby:2.6

# set some rails env vars
ENV RAILS_ENV production
ENV BUNDLE_PATH /bundle

# set the app directory var
ENV APP_HOME /home/app
WORKDIR $APP_HOME

# Install apt dependencies
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  build-essential \
  curl libssl-dev \
  git \
  unzip \
  zlib1g-dev \
  libxslt-dev \
  mysql-client \
  sqlite3

# install bundler
RUN gem install bundler

# Separate task from `add . .` as it will be
# cached if gemfile(.lock) hasn't changed
COPY Gemfile* ./

# Install gems to /bundle
RUN bundle install

ADD . .

# compile assets! you'll want them in the container itself
RUN bundle exec rake assets:precompile

EXPOSE 3000
