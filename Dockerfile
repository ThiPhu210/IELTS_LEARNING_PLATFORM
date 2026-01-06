# syntax=docker/dockerfile:1
# check=error=true

# Production Dockerfile cho Rails app
ARG RUBY_VERSION=3.3.5
FROM ruby:${RUBY_VERSION}-slim AS base

WORKDIR /rails

# Cài đặt các gói cơ bản
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      libpq-dev \
      curl \
      git \
      nodejs \
      npm \
      postgresql-client \
      libjemalloc2 \
      libvips && \
    npm install --global yarn && \
    rm -rf /var/lib/apt/lists/*

# Thiết lập biến môi trường cho production
ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development

# Stage build để giảm kích thước image cuối
FROM base AS build

# Cài đặt gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Nếu có JS dependencies (Tailwind, v.v.), copy và cài đặt
# Nếu project chưa có package.json/yarn.lock thì bước này sẽ bị bỏ qua
COPY package.json* yarn.lock* ./
RUN [ -f package.json ] && yarn install --frozen-lockfile || echo "No JS dependencies"

# Copy toàn bộ code
COPY . .

# Precompile bootsnap
RUN bundle exec bootsnap precompile app/ lib/

# Precompile assets (Tailwind sẽ chạy ở đây nếu có)
ENV RAILS_MASTER_KEY=$RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile || echo "Skip assets precompile (no JS deps)"

# Stage cuối cho app image
FROM base

# Copy artifacts từ build stage
COPY --from=build ${BUNDLE_PATH} ${BUNDLE_PATH}
COPY --from=build /rails /rails

# Tạo user không phải root để chạy app
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
