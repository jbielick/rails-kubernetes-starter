FROM phusion/passenger-ruby23

# set some rails env vars
ENV RAILS_ENV production
ENV BUNDLE_PATH /bundle

# set the app directory var
ENV APP_HOME /home/app
WORKDIR $APP_HOME

# Enable nginx/passenger
RUN rm -f /etc/service/nginx/down

# Disable SSH
# Some discussion on this: https://news.ycombinator.com/item?id=7950326
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

RUN apt-get update -qq

# Install apt dependencies
RUN apt-get install -y --no-install-recommends \
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
# Skipped if gemfile.lock hasn't changed
COPY Gemfile* ./

# Install gems to /bundle
RUN bundle install

# place the nginx / passenger config
RUN rm /etc/nginx/sites-enabled/default
ADD nginx/env.conf /etc/nginx/main.d/env.conf
ADD nginx/app.conf /etc/nginx/sites-enabled/app.conf

ADD . .

# compile assets!
RUN bundle exec rake assets:precompile

EXPOSE 3000

CMD ["/sbin/my_init"]
