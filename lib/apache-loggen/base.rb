# -*- encoding: utf-8 -*-

require 'rubygems'
require 'time'
require 'fileutils'
require 'optparse'
require 'json'

module LogGenerator

  class Base
    def generate(context, config)
      # must override
      exit 1
    end
  end

  class Apache < Base

    RECORDS = 5000
    HOSTS = RECORDS/4
    PAGES = RECORDS/4

    AGENT_LIST_STRING = <<-END
    Mozilla/5.0 (iPhone; CPU iPhone OS 5_0_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A405 Safari/7534.48.3
    Mozilla/5.0 (iPad; CPU OS 5_0_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A405 Safari/7534.48.3
    Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)
    Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)
    Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)
    Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)
    Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)
    Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)
    Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)
    Mozilla/5.0 (Windows NT 6.1; WOW64; rv:10.0.1) Gecko/20100101 Firefox/10.0.1
    Mozilla/5.0 (Windows NT 6.1; WOW64; rv:10.0.1) Gecko/20100101 Firefox/10.0.1
    Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.77 Safari/535.7
    Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.77 Safari/535.7
    Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.56 Safari/535.11
    Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.56 Safari/535.11
    Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.56 Safari/535.11
    Mozilla/5.0 (Windows NT 6.0; rv:10.0.1) Gecko/20100101 Firefox/10.0.1
    Mozilla/5.0 (Windows NT 6.0; rv:10.0.1) Gecko/20100101 Firefox/10.0.1
    Mozilla/5.0 (Windows NT 6.0; rv:10.0.1) Gecko/20100101 Firefox/10.0.1
    Mozilla/5.0 (Windows NT 6.0; rv:10.0.1) Gecko/20100101 Firefox/10.0.1
    Mozilla/5.0 (Windows NT 6.0) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.56 Safari/535.11
    Mozilla/5.0 (Windows NT 6.0) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.56 Safari/535.11
    Mozilla/5.0 (Windows NT 5.1) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.46 Safari/535.11
    Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:9.0.1) Gecko/20100101 Firefox/9.0.1
    Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:9.0.1) Gecko/20100101 Firefox/9.0.1
    Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:9.0.1) Gecko/20100101 Firefox/9.0.1
    Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; WOW64; Trident/4.0; YTB730; GTB7.2; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; .NET4.0C; .NET4.0E; Media Center PC 6.0)
    Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; WOW64; Trident/4.0; YTB730; GTB7.2; EasyBits GO v1.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C)
    Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; WOW64; Trident/4.0; GTB7.2; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C)
    Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; YTB730; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C)
    Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; WOW64; Trident/4.0; GTB6; SLCC1; .NET CLR 2.0.50727; Media Center PC 5.0; .NET CLR 3.5.30729; .NET CLR 3.0.30618; .NET4.0C)
    Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; YTB720; GTB7.2; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)
    Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; BTRS122159; GTB7.2; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; BRI/2)
    END
    AGENT_LIST = AGENT_LIST_STRING.split("\n").map{|a|a.lstrip}

    PAGE_CATEGORIES = %w[
    books
    books
    books
    electronics
    electronics
    electronics
    electronics
    electronics
    electronics
    software
    software
    software
    software
    games
    games
    games
    office
    office
    cameras
    computers
    finance
    giftcards
    garden
    health
    music
    sports
    toys
    networking
    jewelry
    ]

    # インナークラスから使うためにmodule化
    # 使う場合はinclude RANDする
    module RAND
      if RUBY_VERSION >= '1.9.1'
        RANDOM = Random.new
        def grand(n)
          RANDOM.rand(n)
        end
      else
        def grand(n)
          rand(n)
        end
      end
    end
    include RAND

    def initialize()

      @pages = []
      PAGES.times do
        @pages << Page.new
      end

      @hosts = []
      HOSTS.times do
        @hosts << Host.new
      end

    end

    def generate(context, config)

      page = @pages[grand(@pages.size)]
      host = @hosts[grand(@hosts.size)]
      record = {
        'host' => host.ip,
        'user' => '-',
        'method' => page.method,
        'path' => page.path,
        'code' => grand(10000) == 0 ? 500 : page.code,
        'referer' => (grand(2) == 0 ? @pages[grand(@pages.size)].path : page.referer) || '-',
        'size' => page.size,
        'agent' => host.agent,
      }
    
      return format(record, config)

    end

    def format(record, config)
      if config[:json] then
        return record.to_json + "\n"
      else
        return %[#{record['host']} - #{record['user']} [#{Time.now.strftime('%d/%b/%Y:%H:%M:%S %z')}] "#{record['method']} #{record['path']} HTTP/1.1" #{record['code']} #{record['size']} "#{record['referer']}" "#{record['agent']}"\n] 
      end
    end

    class Host
      include RAND
      def initialize
        @ip = "#{(grand(210)+20)/4*4}.#{(grand(210)+20)/3*3}.#{grand(210)+20}.#{grand(210)+20}"
        @agents = []
      end

      attr_reader :ip

      def agent
        if @agents.size == 4
          @agents[grand(4)]
        else
          agent = AGENT_LIST[grand(AGENT_LIST.size)]
          @agents << agent
          agent
        end
      end
    end

    class Page
      include RAND
      def initialize
        cate = PAGE_CATEGORIES[grand(PAGE_CATEGORIES.size)]
        item = grand(RECORDS)

        if grand(2) == 0
          w = [cate, PAGE_CATEGORIES[grand(PAGE_CATEGORIES.size)]]
        else
          w = [cate]
        end
        q = w.map {|k| k[0..0].upcase + k[1..-1] }.join('+')
        search_path = "/search/?c=#{q}"
        google_ref = "http://www.google.com/search?ie=UTF-8&q=google&sclient=psy-ab&q=#{q}&oq=#{q}&aq=f&aqi=g-vL1&aql=&pbx=1&bav=on.2,or.r_gc.r_pw.r_qf.,cf.osb&biw=#{grand(5000)}&bih=#{grand(600)}"

        case grand(12)
        when 0,1,2,3,4,5
          @path = "/category/#{cate}"
          @referers = [nil, nil, nil, nil, nil, nil, nil, google_ref]
          @method = 'GET'
          @code = 200

        when 6
          @path = "/category/#{cate}?from=#{grand(3)*10}"
          @referers = [search_path, "/category/#{cate}"]
          @method = 'GET'
          @code = 200

        when 7,8,9,10
          @path = "/item/#{cate}/#{item}"
          @referers = [search_path, search_path, google_ref, "/category/#{cate}"]
          @method = 'GET'
          if grand(100) == 0
            @code = 404
          else
            @code = 200
          end

        when 11
          @path = search_path
          @referers = [nil]
          @method = 'POST'
          @code = 200
        end

        @size = grand(100) + 40
      end

      attr_reader :path, :size, :method, :code

      def referer
        if grand(2) == 0
          @referers[grand(@referers.size)]
        end
      end

    end

  end


  # Windowsだと割り込みが55msや10msだったりとするので100msごとに処理するように。
  # 汚いソースになっちゃった・・。
  # MultimediaTimer使えばいいんだけど、めんどくさ。
  class Executors
    FIXED_RATE = 100
    def self.exec(config)

      rate_per_sec = config[:rate]
      display = config[:progress]

      limited = rate_per_sec > 0
      if limited then
        mspr = 1000.0 / rate_per_sec # ms per rec.
        rate = rate_per_sec.to_f / (1000 / FIXED_RATE) # rec per 100ms
      end
      start_time = Time.now

      time = last_display = Time.now
      count = 0
      total_count = 0
      while true do

        break unless yield({
          :start_time => start_time,
          :total_count => total_count,
          :elapsed_time => (Time.now - start_time).round,
        })

        total_count += 1
        count += 1

        if limited && count >= rate then
          spent = ((Time.now - time) * 1000).round
          sleep_ms = mspr - spent
          sleep(sleep_ms / 1000.0) if sleep_ms > 0
          time = Time.now
          count = 0
        end

        if display then
          if Time.now - last_display >= 1.0 then
            $stderr.printf("\r%d[rec] %.2f[rec/s]", total_count, total_count / (Time.now - start_time + 0.001))
            last_display = Time.now
          end
        end

      end
    end
  end

  class MyWriter
    def initialize(filename)
      @filename = filename
      @io = nil
      rotate()
    end
    def rotate()
      if @filename == nil then
        @io = $stdout
        return nil
      else
        dir = File.dirname(@filename)
        name = File.basename(@filename, '.*') + '.' + Time.now.strftime('%Y-%m-%d_%H%M%S') + File.extname(@filename)
        FileUtils.mkdir_p(dir) unless File.exists?(dir)
        if @io != nil then
          File.rename(@filename, name)
          @io.close
        end
        @io = open(@filename, "a")
        return File.join(dir, name)
      end
    end
    def write(str)
      return @io.write(str)
    end
    def flush()
      @io.flush()
    end
    def close()
      if @filename != nil && @io != nil && !@io.closed? then
        @io.close
      end
    end
  end

  class Generator
    DEFAULT_CONFIG = {
      :limit => 0,
      :rate => 0,
      :rotate => 0,
      :progress => false,
      :json => false,
      :filename => nil,
    }
    def self.execute(conf={}, gen_obj=nil, &block)
      
      config = DEFAULT_CONFIG.merge(conf)
      writer = MyWriter.new(config[:filename])
      gen_kick = gen_obj && gen_obj.is_a?(Base)

      # 実行
      last_rotate = Time.now.to_i
      Executors.exec(config) do | context |

        if config[:rotate] > 0 && (last_rotate + config[:rotate]) <= Time.now.to_i then
          rotated_file = writer.rotate()
          if config[:progress] then
            $stderr.write "\rfile rotate. rename to #{rotated_file}\n"
          end
          last_rotate = Time.now.to_i
        end
        
        # レコード生成
        record = gen_obj.generate(context, config) if gen_kick
        record = block.call(context, config, record) if block

        # 出力
        writer.write(record)
        writer.flush()

        not (config[:limit] > 0 && config[:limit] <= context[:total_count])

      end
      writer.close

    end
  end

  def parse_config()
    config = {}
    op = OptionParser.new
    op.on('--limit=COUNT', '最大何件出力するか。デフォルトは0で無制限。'){|v| config[:limit] = v.to_i }
    op.on('--rate=RATE', '毎秒何レコード生成するか。デフォルトは0で流量制限無し。'){|v| config[:rate] = v.to_i }
    op.on('--rotate=SECOND', 'ローテーションする間隔。デフォルトは0。'){|v| config[:rotate] = v.to_i }
    op.on('--progress', 'レートの表示をする。'){|v| config[:progress] = true }
    op.on('--json', 'json形式の出力'){|v| config[:json] = true }
    op.parse!(ARGV)
    # ファイルかSTDOUTか
    config[:filename] = ARGV[0] if not ARGV.empty?
    return config
  end
  def generate(conf=nil, gen_obj=nil, &block)
    conf = parse_config() if conf == nil
    Generator.execute(conf, gen_obj, &block)
  end
  module_function :parse_config
  module_function :generate

end

