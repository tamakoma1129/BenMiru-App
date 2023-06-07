# iOSアプリ「べんミル」の紹介

2023/06/06にバージョン1.0.0が完成し、7日にリリースできました。

カロリーを測るアプリ「カロミル」に影響されて作りました。

-----
## どんなアプリか３行で
- 勉強した記録を見える化するアプリです
- 好きな色で自分だけのページを作ることができます
- 1分から記録できるので、少ない勉強時間でもどんどん記録できます

## YouTubeに上げた1分40秒ほど操作動画です。
[![YouTube video link](https://img.youtube.com/vi/4sJPLM3w4zc/maxresdefault.jpg)](https://www.youtube.com/watch?v=4sJPLM3w4zc)

-----

## 開発環境
- SwiftUI
- Realm

## 修正/追加したいところ
- リリースを優先していたので、コードが汚いです。そのためリファクタリングを行いたいです。
- データの挿入や削除が行える仕様上、データの計算を毎回すべて行っています。そのため、データの量が多くなると動作が重たくなることが予想されます。その改善を行いたいです。
- ヘルプやチュートリアルの追加
- ロード画面の追加
- 他の統計の見方、絞り込みの追加
