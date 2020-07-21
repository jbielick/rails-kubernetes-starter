FROM ruby:2.6

ARG NODE_MAJOR_VERSION=14
ARG BUNDLER_VERSION=2.0.2
ARG YARN_VERSION=1.22.4
ARG BUNDLE_WITHOUT="development test"

ENV LC_ALL=C.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

# set some default ENV values for the image
ENV RAILS_ENV production
ENV BUNDLE_PATH /bundle
ENV RAILS_LOG_TO_STDOUT 1
ENV RAILS_SERVE_STATIC_FILES 1
ENV EXECJS_RUNTIME Node

# set the app directory var
ENV APP_HOME /home/app
WORKDIR $APP_HOME

RUN curl -sL https://deb.nodesource.com/setup_${NODE_MAJOR_VERSION}.x | bash - \
  && apt-get update -qq && apt-get install -y --no-install-recommends \
  build-essential \
  curl \
  libssl-dev \
  git \
  nodejs \
  unzip \
  zlib1g-dev \
  libxslt-dev \
  default-libmysqlclient-dev

RUN npm install -g yarn@${YARN_VERSION}

# install bundler
RUN gem install bundler -v "${BUNDLER_VERSION}"

# Separate task from `add . .` as it will be
# cached if gemfile(.lock) hasn't changed
COPY Gemfile* ./

# Install gems to /bundle
# the production image shouldn't contain test or development gems
RUN bundle install --without ${BUNDLE_WITHOUT}

## Using node.js packages? Do the same install routine here
# COPY package*.json ./
## If you are building your code for production
RUN yarn install --frozen-lockfile

COPY . .

# compile assets! you'll want them in the container itself for production
# RUN bundle exec rake assets:precompile

EXPOSE 3000

CMD [ "bin/rails", "s", "Puma", "-b", "0.0.0.0", "-p", "3000" ]
