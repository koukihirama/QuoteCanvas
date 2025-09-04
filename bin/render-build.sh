set -o errexit

# 依存入れる
bundle config set without 'development test'
bundle install -j4 --retry 3

# （使っていれば）フロントのビルド
yarn install --frozen-lockfile || true
yarn build || true

# Rails アセット
bundle exec rails assets:precompile
bundle exec rails assets:clean