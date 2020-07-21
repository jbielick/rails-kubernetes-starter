FROM ruby:2.6 as base

# set some default ENV values for the image
ENV BUNDLE_PATH /bundle
ENV RAILS_LOG_TO_STDOUT 1
ENV RAILS_SERVE_STATIC_FILES 1
ENV EXECJS_RUNTIME Node

# set the app directory var
ENV APP_HOME /home/app
WORKDIR $APP_HOME

ARG NODE_MAJOR_VERSION=14
RUN curl -sL https://deb.nodesource.com/setup_${NODE_MAJOR_VERSION}.x | bash - \
  && apt-get update -qq \
  && apt-get install -y --no-install-recommends \
  build-essential \
  curl \
  default-libmysqlclient-dev \
  dumb-init \
  git \
  libssl-dev \
  libxslt-dev \
  nodejs \
  openssh-client \
  unzip \
  zlib1g-dev \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

# add and verify github host fingerprint
# (necessary if you're installing gems from github)
RUN ssh-keyscan -t rsa github.com \
  | tee /root/.ssh/known_hosts \
  | ssh-keygen -lf - \
  | grep 'SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8'

# install yarn, required by webpacker
ARG YARN_VERSION=1.22.4
RUN npm install -g yarn@${YARN_VERSION}

# install specific bundler version
ARG BUNDLER_VERSION=2.0.2
RUN gem install bundler -v "${BUNDLER_VERSION}"

# install gems
ARG BUNDLE_WITHOUT="development test"
COPY Gemfile* ./
RUN bundle install --without ${BUNDLE_WITHOUT}

# install node modules
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# copy code
COPY . .

ARG RAILS_ENV=production
ENV RAILS_ENV ${RAILS_ENV}

EXPOSE 3000

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD [ "bin/rails", "s", "-u", "Puma", "-b", "0.0.0.0", "-p", "3000" ]

FROM base as production

RUN bundle exec rake assets:precompile
