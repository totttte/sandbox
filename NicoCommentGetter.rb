#!/usr/bin/ruby
require 'rest_client'
require 'cgi'
require 'rexml/document'
require 'socket'

#= Usage 
# NicoNico.new('hoge@example.com', 'password').getComment('sm9')
# でコメントファイル(XML形式)が取得できます
# 
# NicoNico.new('hoge@example.com', 'password', \
# {:user_session=>'user_session_nnnnnn_nnnnnnn..'}.getComment('sm9')
# とすると以下のような動作となります
# 1. インスタンス生成時にはログイン動作を行いません
# 2. getCommentをすると、インスタンス生成時に指定したCookiesを元に
#    コメント取得を試みます
# 3. もし2でコメント取得失敗した場合は、ログインをしなおして、
#    コメント取得を再度試みます。(リトライは1度のみ)
#
# 動画IDがlv～やco～の場合は、生放送とみなしてコメントを取得します。
# それ以外の場合は動画とみなしてコメントを取得します。
# 生放送のときは getCommentは長時間returnされないので注意。
#
# このライブラリを使用するためには rest-client が必要です。
# sudo gem install rest-client
#
# ライセンスはとりあえずMIT Licenseで
class NicoNico
  def initialize(mail, pass, cookies=nil)
    @mail = mail
    @pass = pass
    cookies == nil ? login : @cookies = cookies
  end

  def login
    ret = RestClient.post \
    'https://secure.nicovideo.jp/secure/login?site=niconico', \
        { 'mail'=>@mail , 'password'=>@pass } { |res, &block|
        @cookies = res.cookies
    }
  end

  def getComment(id, retryflg=true)
    begin
      return id=~/^(lv|co)/ ? getLiveCom(id) : getVideoCom(id)
    rescue
      return "" if ! retryflg
      login
      return getComment(id,false)
    end
  end

  def getCookies()
    return @cookies
  end
  private
  def getVideoCom(id)
    $_ = RestClient.get \
           'http://flapi.nicovideo.jp/api/getflv/' + id, \
           {:cookies => @cookies }
    $_ = CGI.parse($_)
    $_ = $_['ms'][0]+'thread?version=20061206&thread='+$_['thread_id'][0]
    return RestClient.get $_, { :cookies => @cookies }
  end

  def getLiveCom(id)
    $_ = RestClient.get \
       'http://watch.live.nicovideo.jp/api/getplayerstatus?v=' + id, \
       { :cookies => @cookies }
    doc = REXML::Document.new $_
    sock = TCPSocket.open( \
       doc.elements['/getplayerstatus/ms/addr'].text, \
       doc.elements['/getplayerstatus/ms/port'].text.to_i \
    )
    th = doc.elements['/getplayerstatus/ms/thread'].text
    sock.write("<thread thread=\"#{th}\" " + \
       "version=\"20061206\" res_from=\"-1000\"/>\0")
    buf = ""
    while 1
      buf = buf + sock.gets("\0")
    end
    sock.close
    return buf
  end
end

nico = NicoNico.new('account@gmail.com','password')
p nico.getComment('sm9')
