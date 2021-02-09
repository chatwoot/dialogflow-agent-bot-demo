# Use the official lightweight Ruby image.
# https://hub.docker.com/_/ruby
FROM ruby:2.7.1

## ENV
ENV RAILS_ENV=production
ENV PORT=8080
ENV RAILS_LOG_TO_STDOUT=1

## YARN
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    nodejs \
    yarn \
 && rm -rf /var/lib/apt/lists/*

# Install production dependencies.
WORKDIR /usr/src/app
COPY Gemfile Gemfile.lock ./
ENV BUNDLE_FROZEN=true
RUN gem install bundler && bundle install

# Copy local code to the container image.
COPY . ./
RUN yarn install --check-files


RUN bundle install

# bundle exec rake db:setup_or_migrate



# Run the web service on container startup.
CMD bundle exec rails server -p ${PORT} -b 0.0.0.0
