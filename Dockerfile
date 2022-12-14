# syntax=docker/dockerfile:1
FROM ruby:3.1.2
RUN apt-get update -qq && apt-get install -y nodejs sqlite3 libsqlite3-dev
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install

# Add a script to be executed every time the container starts.
EXPOSE 3009

# Configure the main process to run when running the image
CMD ["rails", "server", "-p", "3009", "-b", "0.0.0.0"]
