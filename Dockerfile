FROM ruby:2.6

# set some rails env vars
ENV RAILS_ENV production
ENV BUNDLE_PATH /bundle

ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_SERVE_STATIC_FILES true
## if you're using Node.js, install it in this container and uncomment this line
# ENV EXECJS_RUNTIME Node

# set the app directory var
ENV APP_HOME /home/app
WORKDIR $APP_HOME

# install apt dependencies
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
# the production image shouldn't contain test or development gems
RUN bundle install --without test development

## Using node.js packages? Do the same install routine here
# COPY package*.json ./
## If you are building your code for production
# RUN npm ci --only=production

ADD . .

# compile assets! you'll want them in the container itself for production
RUN bundle exec rake assets:precompile

EXPOSE 3000
