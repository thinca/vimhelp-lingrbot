require 'sinatra'
require 'yaml'
require 'hashie'

CONFIG = Hashie::Mash.new(YAML.load(ARGF))
if CONFIG.port
  set :port, CONFIG.port
end

pre_script = CONFIG.vimrc ? ('--cmd "source %s"' % CONFIG.vimrc) : ''

get '/' do
  content_type :text
  "vimhelp bot for lingr."
end

post '/' do
  content_type :text

  request_data = Hashie::Mash.new YAML.load(request.body.read)

  request_data.events.select {|e| e.message }.each do |e|
    text = e.message.text
    if text =~ /^:h(?:e(?:lp?)?)?(!)?\s*(\||[^|\s]*)/
      bang = $1
      keyword = $2
      result =
        if bang
          'E478: 慌てないでください'
        else
          `vim -Z -u NONE -N -e -s #{pre_script} --cmd "source #{__dir__}/help.vim" -- "#{keyword.gsub('"', '\"')}"`
        end
      res =
        if result == ''
          "E149: 残念ですが #{keyword} にはヘルプがありません"
        else
          result.gsub(/[ \t]+$/, '').rstrip.gsub(/^$|  /, "　")[0, 1000]
        end
      return res
    end
  end
  ''
end
