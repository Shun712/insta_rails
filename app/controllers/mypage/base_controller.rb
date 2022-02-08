class Mypage::BaseController < ApplicationController
  before_action :require_login
  # layoutメソッドを使い、views/layoutsディレクトリのmypageを指定
  layout 'mypage'
end