# BtcProfits

Bybit用確定申告向け計算機

## 使い方

Bybitからは履歴のダウンロード。10000件を超える場合はメールで問い合わせが必要。（タイムゾーンに気をつけて前後1日確保しておくほうが安全）
BTC価格は[ここ](http://nipper.work/btc/index.php?market=bitFlyer&coin=BTCJPY)から日足で取ってきて計算。

```
$ iex -S mix

iex(1)> BtcProfits.process("/path/to/profit_sheet", "/path/to/btc_price")
```
