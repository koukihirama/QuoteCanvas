set -e

echo "==> Running db:migrate..."
bundle exec rails db:migrate

echo "==> Starting Puma..."
exec bundle exec puma -C config/puma.rb