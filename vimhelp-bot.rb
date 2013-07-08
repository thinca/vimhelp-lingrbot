#!/usr/bin/env ruby

require 'sinatra'
require 'yaml'
require 'hashie'

CONFIG = Hashie::Mash.new(YAML.load(ARGF))
if CONFIG.port
  set :port, CONFIG.port
end

vimrc = CONFIG.vimrc || 'NONE'

get '/' do
  content_type :text
  "vimhelp bot for lingr."
end

post '/' do
  content_type :text

  request_data = Hashie::Mash.new YAML.load(request.body.read)

  request_data.events.select {|e| e.message }.each do |e|
    text = e.message.text
    if text =~ /^:h(?:e(?:lp?)?)?\s+(\||[^|\s]+)/
      keyword = $1
      result = `vim -Z -u #{vimrc} -N -e -s --cmd "source #{__dir__}/help.vim" -- "#{keyword.gsub('"', '\"')}"`
      res =
        if result == ''
          "残念ですが #{keyword} にはヘルプがありません"
        else
          result[0, 1000]
        end
      return res
    end
  end
  ''
end
