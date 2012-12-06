# はじめに

Apacheログに対して何かの処理を行いたい場合に使うためのテストツールです。
こんな場合に有用なんではないかなと。

* productionでもアクセスが足りない
* 手元でproductionレベルの流速を試したい
* apacheのログファイルを持ってくるのが面倒
などなど..


一応、流速がなだらかになるようになっています。
100msよりも割り込み精度が低いOSの場合はその限りではありません。

## 性能
私のへっぽこ開発PCで毎秒12,000レコードほど生成します。

    Fedora16(CPU:2Core, Mem:3GB) on VirtualBox on Windows7(Corei7 M640 2.8GB, Mem:8GB)
	Ruby 1.9.3p194

# インストール

    gem install apache-loggen

apache-loggenというコマンドがgems/binに作られます。

# 使い方

```
  apache-loggen [options] [file]

   --limit=COUNT           最大何件出力するか。デフォルトは0で無制限。
   --rate=RATE             毎秒何レコード生成するか。デフォルトは0秒で流量制限無し。
   --rotate=SECOND         ファイルローテーションをする間隔。デフォルトは0(行わない)。
                           ファイル名を指定した場合は無効。
   --progress              STDERRに生成速度の表示をする
   --json                  Json形式で出力

   file を指定した場合はそのファイルへ出力する
   file を省略した場合はSTDOUTへ出力する
```

# 例

## STDOUTにレコード出力
	apache-loggen

## JSONで出力
    apache-loggen --json

## 毎秒100レコードの速度でファイル「abc.log」に出力
    apache-loggen --rate=100 abc.log

## 10秒ごとにファイルのローテーションを行う
    apache-loggen --rotate=10 abc.og

## 生成状況を表示する
    apache-loggen --rotate=10 --progress abc.log
----
    file rotate. rename to ./abc.2012-10-17_113723.log
    file rotate. rename to ./abc.2012-10-17_113733.log
    220[rec] 9.90[rec/s]

## 5000件出力で打ちきる
    apache-loggen --limit=5000

# ローテーションルール
    abc.log -> abc.[yyyy-MM-dd_HHmmss].log


# 他のログを生成したい場合
再利用できるようにある程度クラス化してあるので、Apache以外のログも対応可能です。

以下のコードでログ生成を開始します。

    require 'apache-loggen/base'
    LogGenerator.generate(conf=nil, gen_obj=nil, &block)
----
    apache-loggen/base をrequireします。
    conf にnilを渡すとARGVをパースします。
    conf にHashを渡すと、デフォルトのオプションから、渡したものだけ上書きします。

実際にログを生成する部分は、LogGenerator::Baseを継承し、generate(context, config)というメソッドを定義する必要があります。
デフォルトではLogGenerator::Apacheというクラスが存在します。
Apacheログをベースに何かいじる場合は、これを利用すると良いと思います。

もっと気軽に生成したい場合は、以下のようにブロックを渡すことでGeneratorの代わりとなります。

    LogGenerator.generate() do | context, config, record |
	  # ログを1つ分生成する。
	  Time.now.to_s + "\n"
	end

上記のrecordは、第2引数のgen_objも指定した場合にその結果を受け取り、さらにblockで加工する場合に使います。

## Apacheのログの出力形式を変更したい

```ruby
require 'apache-loggen/base'
class MyGen < LogGenerator::Apache
  def format(record, config)
    # 今回はJSONを無視する
    return %[[#{Time.now.strftime('%d/%b/%Y:%H:%M:%S %z')}] #{record["path"]}\n]
  end 
end
LogGenerator.generate(nil, MyGen.new)
```

## Apacheのログに新しく情報を追加したい
```ruby
require 'apache-loggen/base'
class MyGen < LogGenerator::Apache
  # オリジナル実装はhashをJSONか1行の文字列にしているが
  # 今回はそれに情報を追加する
  def format(record, config)
    record["process_time"] = grand(1000000) + 1000
    if config[:json] then
      return record.to_json + "\n"
    else
      return %[#{record['host']} - #{record['user']} [#{Time.now.strftime('%d/%b/%Y:%H:%M:%S %z')}] "#{record['method']} #{record['path']} HTTP/1.1" #{record['code']} #{record['size']} "#{record['referer']}" "#{record['agent']}" #{record['process_time']}\n]
    end
  end
end
LogGenerator.generate(nil, MyGen.new)
```

## 完全に独自のログ形式を出力したい

```ruby
require 'apache-loggen/base'
class MyGen < LogGenerator::Base
  def generate(context, config)
    return "#{Time.now.to_s} #{context.inspect}\n"
  end
end
LogGenerator.generate(nil, MyGen.new)
```

もしくは、

```ruby
require 'apache-loggen/base'
LogGenerator.generate do | context, config, record |
  "#{Time.now.to_s} #{context.inspect}\n"
end
```


# 履歴
- 0.0.4 Ruby-1.8.7でも動くようにした。
- 0.0.3 Rate=1くらいの低速度の場合、Flushが走らないので明示的にFlushするようにした。 
- 0.0.2 RubyGemsに登録。コマンドを用意した。クラスの再利用ができるようにした。
- 0.0.1 はじめてのリリース

# ライセンス
Apache License, Version 2.0

# 謝辞

TreasureDataのスクリプトをパクりました。

オリジナルとの差異は、ログの日付を現在の日付で出力する点です。

* https://github.com/treasure-data/td
* https://github.com/treasure-data/td/blob/master/data/sample_apache_gen.rb


