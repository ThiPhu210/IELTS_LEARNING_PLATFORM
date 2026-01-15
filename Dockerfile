ARG RUBY_VERSION=3.3.5

########################
# BUILD STAGE
########################
FROM ruby:${RUBY_VERSION}-slim AS build
WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    curl \
    libpq-dev \
    postgresql-client \
    libjemalloc2 \
    libvips \
    ffmpeg \
    imagemagick \
    nodejs \
    npm && \
    npm install --global yarn && \
    rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    bundle exec bootsnap precompile --gemfile

COPY package.json* yarn.lock* ./
RUN [ -f package.json ] && yarn install --frozen-lockfile || true

COPY . .
RUN bundle exec bootsnap precompile app/ lib/
RUN SECRET_KEY_BASE=1 RAILS_ENV=production bin/rails assets:precompile

########################
# RUNTIME STAGE
########################
FROM ruby:${RUBY_VERSION}-slim AS runtime
WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    libpq-dev \
    postgresql-client \
    libjemalloc2 \
    libvips \
    ffmpeg \
    imagemagick && \
    rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails /rails

USER rails
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
