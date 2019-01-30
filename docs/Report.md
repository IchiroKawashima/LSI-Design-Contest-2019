# LSI-Design-Contest-2019 report

## 所属

チーム名：？  
学校名：九州工業大学 大学院 生命体工学研究科 田向研究室  
電話番号：093-695-6143（研究室）  
住所：〒808-0196 福岡県北九州市若松区ひびきの２−４  
メールアドレス：？（代表）

## メンバーリスト

|学年|氏名|Tシャツのサイズ|
|:---|:---|:---|
|D1|川島 一郎|？|
|D1|田中 悠一朗|L|
|M1|宮﨑 椋瑚|？|

## 設計のタスクレベル
？

---

## 回路ブロックもしくは、アーキテクチャ記述
<img src="images/Network.svg" width="100%">
<div style="text-align: center;">図．回路ブロック</div>

---

## 設計した回路の機能の説明など
### 積和演算回路
<img src="images/Maccum.svg" width="100%">
<div style="text-align: center;">図．積和演算回路</div>

### 活性化関数回路
<img src="images/Neuron.svg" width="100%">
<div style="text-align: center;">図．活性化関数回路</div>

### 誤差伝播回路
<img src="images/Delta.svg" width="100%">
<div style="text-align: center;">図．誤差逆伝播回路</div>

### 重み・バイアス回路
<img src="images/BiasWeight.svg" width="100%">
<div style="text-align: center;">図．重み・バイアス回路</div>

---

## アピールポイントと独創性
Combiner・Broadcasterを用いたStream形式でモジュール間の通信を行う．

---

## クリティカルパス速度、回路領域
論理合成ツールとしてXilinx Vivado 2018.2を使用した．
ターゲットデバイスはXilinx Virtex UltraScaleとした．

### クリティカルパス速度


### 回路領域
ニューラルネットワークのパラメータのうち，変数のビット幅，および中間層１のユニット数を可変にして，論理合成後の回路規模がどのようになるか確認した．

---

## HDLコード
GitHubにて公開．  
https://github.com/IchiroKawashima/LSI-Design-Contest-2019/

---

## デザインが操作しているシミュレーション波形の表示
