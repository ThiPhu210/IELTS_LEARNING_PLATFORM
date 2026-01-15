ARG RUBY_VERSION=3.3.5

############################
# Base
############################
FROM ruby:${RUBY_VERSION}-slim AS base

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      libpq-dev \
      curl \
      postgresql-client \
      libjemalloc2 \
      libvips \
      imagemagick && \
    rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test

############################
# Build
############################
FROM base AS build

# Build deps
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      nodejs \
      npm && \
    npm install --global yarn && \
    rm -rf /var/lib/apt/lists/*
    
COPY Gemfile Gemfile.lock ./

RUN bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle config set --local frozen 'false' && \
    bundle install && \
    bundle exec bootsnap precompile --gemfile && \
    rm -rf ~/.bundle "${BUNDLE_PATH}"/ruby/*/cache

COPY package.json ./
COPY yarn.lock* ./
RUN yarn install


COPY . .

# 🔥 Quan trọng: tạo thư mục cho Tailwind build
RUN mkdir -p app/assets/builds

RUN bundle exec bootsnap precompile app/ lib/
RUN SECRET_KEY_BASE=dummy \
    RAILS_ENV=production \
    NODE_ENV=production \
    DATABASE_URL=postgresql://dummy:dummy@localhost/dummy \
    bin/rails assets:precompile


############################
# Final
############################
FROM base

# Copy runtime artifacts only
COPY --from=build ${BUNDLE_PATH} ${BUNDLE_PATH}
COPY --from=build /rails /rails

# Copy precompiled assets
COPY --from=build /rails/public/assets /rails/public/assets


# Create non-root user
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails /rails

USER rails

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
