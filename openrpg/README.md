# OPENRPG

ゲームデザイン研究用の合成カードゲームです

## プレイヤー
* Lv
* HP
* 攻撃力

## クエスト

## カード

* レアリティ
* コスト
* HP
* 攻撃力
* (アビリティ)

###レアリティ
* 0.0: N
* 1.0: HN
* 2.0: R
* 3.0: HR
* 4.0: SR
* 5.0: SSR
* 6.0: UR
* 7.0: KR
* 8.0: LG

### 抽選アルゴリズム
1. レアリティ0.0よりスタート (Nガチャの場合)
1. 1/5の確率でレアリティ+1し、再抽選
1. 外れた場合、その時点のレアリティのカードが等確率で1枚手に入る

ガチャボックスのカードはゲームが進行するに応じてだんだんと増えていく

## ガチャ
