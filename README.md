# Time Trackingアプリ

## インストール手順
1.git clone
```
git clone https://github.com/inoue0124/time-tracking-app.git
```


2.firebaseでプロジェクト作成

作成後GoogleService-Info.plistをtime-tracking-app/TimeTracking/以下に配置。


3.podのインストール
```
cd time-tracking-app/
pod install
```

インストール完了後、TimeTracking.xcworkspaceをxcodeで開いて開発を開始。


## ディレクトリ構造
```
time-tracking/TimeTracking
├── AppConst.swift・・・アプリ全体の定数定義
├── AppDelegate.swift
├── Assets.xcassets
├── Base.lproj
├── Database・・・repositoryプロトコルの実装
├── Domain
│   ├── Entities・・・モデル定義
│   └── Repositories・・・repositoryのプロトコル定義
├── Info.plist
├── Presentation・・・viewやcellの実装
└── Utilities・・・アプリ全体で使うutilityの実装
```


## 参考URL
[XDデザイン](https://xd.adobe.com/view/76a758e3-03b9-45df-b866-65af20ffb4c8-23f4/screen/f7b8c183-e8e8-4bb3-aca2-f46d5c5619d1/)
[SpreadSheetView](https://github.com/kishikawakatsumi/SpreadsheetView)
