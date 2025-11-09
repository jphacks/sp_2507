# Nemulert（ネムラート）

[![CI](https://github.com/jphacks/sp_2507/actions/workflows/ci.yml/badge.svg)](https://github.com/jphacks/sp_2507/actions/workflows/ci.yml)

[![IMAGE ALT TEXT HERE](https://jphacks.com/wp-content/uploads/2025/05/JPHACKS2025_ogp.jpg)](https://www.youtube.com/watch?v=lA9EluZugD8)

## 製品概要

うとうと x Tech：もう、うとうとで後悔しない！うとうとで鳴るアラームアプリ

### デモ動画

[![thumbnail]()](https://youtu.be/i4O_GeJBzXE)

### 背景 (製品開発のきっかけ、課題等)

誰しもが、作業中に寝落ちしてしまい、後悔した経験があるのではないでしょうか。
私たちは、この問題に着目しました。さらに、寝落ちは主に次の二つに分けられると考えました。

1. 寝ようと思って寝落ちする場合: ベッドに寝転びながらスマホをいじって眠ってしまう
2. うとうとして寝落ちしてしまう場合: 夜にデスクで作業をしているときに眠ってしまう

このうち、私たちは 2. うとうとして寝落ちしてしまう場合 が特に問題であると考えました。

### 製品説明（具体的な製品の説明）

“Nemulert”は、AirPods で頭の傾きや動作から、作業中のユーザーのうとうとを検知して起こすアプリです。

### 特長 (独自機能)

iOS に溶け込む UI/UX を追求し、普段のルーティーンを邪魔せずにうとうとを検知します。

#### 1. ショートカット経由で起動

Nemulert の起動を普段のルーティーンに組み込むことが出来ます。ショートカットの他、　 Control Widget から起動することも可能です。

#### 2. AirPods でうとうとを検知

AirPods を装着し、音楽を聴きながら作業をすることが多いはずです。その AirPods を使って頭の動きを計測し、うとうとを検知します。

#### 3. 自動でアラームセット

うとうとが検知されると、1 分後に鳴るアラームがセットされます。うとうとが検知されてから 1 分後までにアラームが解除されなかった場合、時計アプリ内アラームと同様のアラームが作動します。

### 解決出来ること

うとうとをリアルタイムに検知し、ユーザーに通知することで、ユーザーが深い眠りにつく前にうとうとを自覚し、作業を続けるか熟睡するかを自分で選択し、生産的な時間を過ごすことが出来ます。

### 注力したこと（こだわり等）

- Core Motion を使用して AirPods のモーションデータを取得し、頭の動きを計測
  - これを用いてうとうとを検知している
- Create ML アプリで Core ML モデルの構築
  - 合計 300 件のデータを収集し、機械学習をモデルを構築
  - 構築したモデルをプロダクトに取り込む
- UX 追求のための Apple が提供する API の複数利用
  - iOS 26 から使える AlarmKit を使用して、時計アプリと同様のアラームをセットしている
  - ユーザーの日々のワークフローに組み込めるように、App Intent を実装し、ショートカットや Control Widget から起動できる

## 開発技術

### フレームワーク・ライブラリ・モジュール

- ActivityKit
- AlarmKit
- App Intents
- Core ML
- Core Motion
- Lottie for iOS
- SwiftUI
- WidgetKit

### デバイス

- AirPods
- iPhone

## 発表資料

![slide_01]()

![slide_02]()

![slide_03]()

![slide_04]()

![slide_05]()

![slide_06]()

![slide_07]()

![slide_08]()

![slide_09]()

![slide_10]()

![slide_11]()

![slide_12]()
