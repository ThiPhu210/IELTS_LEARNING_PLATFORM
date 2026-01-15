ARG RUBY_VERSION=3.3.5
ARG NODE_VERSION=20

########################
# BUILD STAGE
########################
FROM ruby:${RUBY_VERSION}-slim AS build
WORKDIR /rails

# System deps
RUN apt-get update -qq && apt-get install --no-install-recommends -y \
    build-essential \
    git \
    curl \
    libpq-dev \
    postgresql-client \
    libjemalloc2 \
    libvips \
    imagemagick \
    ffmpeg \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Node + Yarn (Flowbite cần)
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn && \
    rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV=production \
    NODE_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_PATH=/usr/local/bundle

# Ruby gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    bundle exec bootsnap precompile --gemfile

# JS deps (Tailwind + Flowbite)
COPY package.json* yarn.lock* ./
RUN [ -f package.json ] && yarn install --frozen-lockfile || true


# App code
COPY . .

# Bootsnap + Assets
RUN bundle exec bootsnap precompile app/ lib/
RUN SECRET_KEY_BASE=dummy \
    RAILS_ENV=production \
    NODE_ENV=production \
    bin/rails assets:precompile

########################
# RUNTIME STAGE
########################
FROM ruby:${RUBY_VERSION}-slim AS runtime
WORKDIR /rails

RUN apt-get update -qq && apt-get install --no-install-recommends -y \
    libpq-dev \
    postgresql-client \
    libjemalloc2 \
    libvips \
    imagemagick \
    ffmpeg && \
    rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_PATH=/usr/local/bundle

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Non-root user
RUN groupadd --system rails && \
    useradd rails --system --gid rails --create-home

RUN chown -R rails:rails /rails
USER rails

EXPOSE 3000
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
