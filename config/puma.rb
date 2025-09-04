workers Integer(ENV.fetch("WEB_CONCURRENCY", 2))
threads_count = Integer(ENV.fetch("RAILS_MAX_THREADS", 5))
threads threads_count, threads_count
preload_app!

port        ENV.fetch("PORT", 3000)
environment ENV.fetch("RAILS_ENV", "production")
pidfile     ENV.fetch("PIDFILE", "tmp/pids/server.pid")

before_fork do
  # 親プロセスで掴んだ DB コネクションを必ず切る
  ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
end

on_worker_boot do
  # 子プロセス（各ワーカー）で DB に張り直す
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end