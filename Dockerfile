FROM ruby:3.3

# OS deps
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  npm

# yarn cho tailwind
RUN npm install -g yarn

WORKDIR /app

# gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# code
COPY . .

EXPOSE 3000

CMD ["bin/rails", "server", "-b", "0.0.0.0"]
