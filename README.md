# はじめに

Apacheログに対して何かの処理を行いたい場合に使うためのテストツールです。
こんな場合に有用なんではないかなと。

* productionでもアクセスが足りない
* 手元でproductionレベルの流速を試したい
* apacheのログファイルを持ってくるのが面倒
などなど..


一応、流速がなだらかになるようになっています。
100msよりも割り込み精度が低いOSの場合はその限りではありません。

# 使い方

```
 ruby sample_apache_gen.rb [options] [file]

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
    ruby sample_apache_gen.rb

## JSONで出力
    ruby sample_apache_gen.rb --json

## 毎秒100レコードの速度でファイル「abc.log」に出力
    ruby sample_apache_gen.rb --rate=100 abc.log

## 10秒ごとにファイルのローテーションを行う
    ruby sample_apache_gen.rb --rotate=10 abc.og

## 生成状況を表示する
    ruby sample_apache_gen.rb --rotate=10 --progress abc.log
----
    file rotate. rename to ./abc.2012-10-17_113723.log
    file rotate. rename to ./abc.2012-10-17_113733.log
    220[rec] 9.90[rec/s]

## 5000件出力で打ちきる
    ruby sample_apache_gen.rb --limit=5000

# ローテーションルール
    abc.log -> abc.[yyyy-MM-dd_HHmmss].log


# ライセンス
Apache License, Version 2.0

# 謝辞

TreasureDataのスクリプトをパクりました。

オリジナルとの差異は、ログの日付を現在の日付で出力する点です。

* https://github.com/treasure-data/td
* https://github.com/treasure-data/td/blob/master/data/sample_apache_gen.rb



