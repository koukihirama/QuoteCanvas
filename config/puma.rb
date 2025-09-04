require "active_record"

workers Integer(ENV.fetch("WEB_CONCURRENCY", 2))
threads_count = Integer(ENV.fetch("RAILS_MAX_THREADS", 5))
threads threads_count, threads_count
preload_app!

port        ENV.fetch("PORT", 3000)
environment ENV.fetch("RAILS_ENV", "production")
pidfile     ENV.fetch("PIDFILE", "tmp/pids/server.pid")

# 親プロセスで DB 切断
before_fork do
  ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord::Base)
end

# 各ワーカー起動ごとに DB へ張り直し
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
end