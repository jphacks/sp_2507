# ファイル管理

## Nemulert

### Component

- View コンポーネント
- 命名規則: XXXView.swift

### Entity

- ドメインエンティティ
- 命名規則: XXX.swift

### Model

- Observable なモデル
  - https://developer.apple.com/documentation/Observation
- 1 スクリーン 1 モデル
- 命名規則: XXXModel.swift

### Screen

- 画面
- モデルを State として管理する
- View コンポーネントを組み合わせて実装
- 命名規則: XXXScreen.swift

### Service

- Dependency で提供されるサービス
  - https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies
- 命名規則: XXXService.swift

## NemulertTests

- ユニットテスト

## NemulertUITests

- UI テスト
