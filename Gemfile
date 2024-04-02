# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1.3', '>= 6.1.3.1'
# Use mysql as the database for Active Record
gem 'mysql2', '~> 0.5'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'

gem 'rexml', '~> 3.2', '>= 3.2.4'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.9.3', require: false

gem 'activeadmin'
gem 'activeadmin_addons'
gem 'devise'
gem 'devise-bootstrap-views', '~> 1.0'
gem 'devise-i18n'
gem 'rails-i18n', '~> 6.0'

# 招待機能
gem 'devise_invitable'

gem 'dotenv-rails'

# 画像追加関連
gem 'carrierwave', '~> 2.0'
gem 'fog-aws'
gem 'rmagick'

# enum日本語化
gem 'enum_help'

# seedデータ分割
gem 'seed-fu'

# エラー通知用
gem 'exception_notification'

# slack通知用
gem 'slack-notifier'

gem 'faker'

# ツリー構造の実装
gem 'closure_tree'

# 動的フォーム
gem 'cocoon'

# 住所自動入力
gem 'jp_prefecture'

# 権限分け
gem 'cancancan'

# pdf変換
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

gem 'prawn'

# aws_for_rails
gem 'aws-sdk-rails'

# ページネーション
gem 'kaminari'

# form object
gem 'dry-validation'
gem 'reform'

# wareki - ruby 和暦ライブラリ
gem 'wareki'

# 国選択
gem 'country_select', '~> 8.0'

# 一括更新
gem 'activerecord-import'

group :development, :test do
  # ERD生成
  gem 'rails-erd'
  # コードフォーマッター
  gem 'rubocop'
  gem 'rubocop-rspec'
  # コンソールツール
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'letter_opener_web', '~> 1.0'
  gem 'pry-rails'
  gem 'rspec-rails'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'listen', '~> 3.3'
  gem 'rack-mini-profiler', '~> 2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
  # Coverage
  gem 'simplecov', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'ffi', '~> 1.15'
