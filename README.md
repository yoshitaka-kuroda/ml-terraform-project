# ML-Terraform-Project

このリポジトリでは、Terraform と SageMaker を組み合わせて、インフラ構築からモデル学習、エンドポイントデプロイまでを行っています

---

## 目次

1. [プロジェクト概要](#プロジェクト概要)  
2. [リポジトリ構成](#リポジトリ構成)  
3. [事前準備](#事前準備)  
4. [Terraform によるインフラ構築](#terraform-によるインフラ構築)  
5. [SageMaker でモデル学習＆エンドポイントデプロイ](#sagemaker-でモデル学習エンドポイントデプロイ)  
6. [README に書ききれなかった「学習メモ」](#readme-に書ききれなかった学習メモ)  
7. [GitHub へのアップ方法（VSCode から）](#github-へのアップ方法vscode-から)  
8. [謝辞・学習プロセスの振り返り](#謝辞学習プロセスの振り返り)  

---

## プロジェクト概要

- **ゴール**  
  - Terraform で以下のリソースを定義・作成  
    - VPC  
    - IAM ロール  
    - S3 バケット（学習データ/モデル格納用）  
    - SageMaker Notebook インスタンス  
  - SageMaker 上で scikit-learn を使った簡易サンプルモデルをトレーニングし、  
    - モデルを S3 に保存  
    - そのモデルを `SKLearnModel` 経由でエンドポイントとしてデプロイ  
    - デプロイ済みエンドポイントに対して CSV データを投げると JSON で予測結果が返る

- **背景・モチベーション**  
  - 自分自身は Terraform も SageMaker もまだ初心者だが、「まず完成させる」ことに価値を置き、  
    ChatGPT（o4-mini-high モデル）なども活用しつつ、修正しながら最終的に動くものを作り切った。

---

## リポジトリ構成
```````
ml-terraform-project/ ← このリポジトリのルート
├── .gitignore
├── README.md ← いま見ているファイル
│
├── environments
│ └── dev
│ ├── backend.tf ← S3 バックエンド設定（リモート state 用）
│ ├── main.tf ← provider 設定＆モジュール呼び出し
│ ├── variables.tf ← dev 環境向けの変数定義
│ └── outputs.tf ← dev 環境向けの出力項目定義
│
├── modules
│ ├── vpc
│ │ ├── main.tf ← VPC/サブネット/ルートテーブルなど
│ │ ├── variables.tf ← VPC モジュールの入力変数定義
│ │ └── outputs.tf ← VPC モジュールの出力（例: public_subnet_id）
│ │
│ ├── iam
│ │ ├── main.tf ← SageMaker 実行用 IAM ロール + ポリシー
│ │ ├── variables.tf ← IAM モジュールの入力変数定義
│ │ └── outputs.tf ← IAM モジュールの出力（例: role ARN）
│ │
│ ├── s3
│ │ ├── main.tf ← データ格納用 S3 バケットの構築（バージョニング有効など）
│ │ ├── variables.tf ← S3 モジュールの入力変数定義
│ │ └── outputs.tf ← S3 モジュールの出力（例: bucket_name）
│ │
│ └── sagemaker
│ ├── main.tf ← SageMaker ノートブックインスタンスの構築
│ ├── variables.tf ← SageMaker モジュールの入力変数定義
│ └── outputs.tf ← SageMaker モジュールの出力（例: notebook URL）
│
├── inference ← SageMaker 学習＆推論用スクリプト一式
│ ├── training_script.py ← Notebook で実行する学習スクリプト
│ └── inference_script.py ← エンドポイント推論用スクリプト
│
└── notebooks ← Jupyter Notebook（.ipynb）
└── demo_notebook.ipynb ← 学習→デプロイ→推論まで一通りまとめた実験ノート
```````
yaml
コピーする
編集する

---

## 事前準備

1. AWS アカウント＆認証情報  
   - `~/.aws/credentials` にプロファイルを設定済みであること  
   - このリポジトリでは Terraform provider で `profile = var.aws_profile` を想定しています。  
     デフォルトでは `aws_profile = "default"` なので、もし別名プロファイルを使う場合は `environments/dev/variables.tf` を編集してください。  

2. Terraform CLI (v1.1.0 以上推奨)  
   ```bash
   terraform -v
   # もし古いバージョンなら https://developer.hashicorp.com/terraform/install から更新してください
Python 3.10 + pip + AWS CLI v2

Jupyter Notebook またはローカル Python で学習→デプロイ→推論を行う場合

requirements.txt（任意）を用意しているわけではないですが、最低限以下をインストール済み推奨：

bash
コピーする
編集する
pip3 install boto3 pandas scikit-learn sagemaker joblib
VSCode（GitHub にアップするときに使います）

拡張機能として「Terraform」「Python」「YAML」などを入れておくと便利

Terraform によるインフラ構築
S3 バケット（Terraform state 用）を先に作成

（リポジトリとは別で）backend-bucket などのフォルダを用意し、

hcl
コピーする
編集する
# backend-bucket/main.tf
provider "aws" {
  region  = "ap-northeast-1"
  profile = "default"
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "your-unique-terraform-state-bucket-name"
  acl    = "private"
  versioning {
    enabled = true
  }
}
terraform init && terraform apply で S3 バケットを先に作っておく

これは Terraform state をリモートで安全に保管するための前提

リポジトリの environments/dev/backend.tf を確認・編集

hcl
コピーする
編集する
terraform {
  backend "s3" {
    bucket = "your-unique-terraform-state-bucket-name"     # ← 先ほど作ったバケット名
    key    = "ml-terraform-project/dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
上記を environments/dev/backend.tf に貼り付けて保存

Terraform 初期化 → プラン → 適用

bash
コピーする
編集する
cd environments/dev
terraform init          # ここで S3 backend に接続される
terraform plan -out tfplan
terraform apply tfplan  # AWS に VPC/IAM/S3/SageMaker が作られる
正常にリソースができると、最後に notebook_url や vpc_id が表示される

途中でエラーが出た場合は、エラーメッセージに従って variables.tf（リージョン・プロファイル・バケット名など）を調整してください

作成されたリソースの確認

AWS マネジメントコンソールの各サービス（VPC, IAM, S3, SageMaker) を開いて、

VPC: vpc-xxxxxxx が存在する

IAM: ml-portfolio-sagemaker-exec-role などができている

S3: yoshitaka-ml-portfolio-data-bucket-apne1 などができている

SageMaker: ノートブックインスタンスも起動中（InService）

不要になったら破棄

bash
コピーする
編集する
terraform destroy -auto-approve
すべての Terraform 管理下リソースが削除される

SageMaker でモデル学習＆エンドポイントデプロイ
1) training_script.py を使ってローカル or Notebook 上で学習
inference/training_script.py の中身（一例）：

python
コピーする
編集する
import argparse
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
import joblib
import os

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data-path", type=str, default="/opt/ml/input/data/training")
    args, _ = parser.parse_known_args()

    # (A) サンプルデータを読み込む
    df = pd.read_csv(os.path.join(args.data_path, "sample_data.csv"))
    X = df[["feature1", "feature2"]]
    y = df["label"]

    # (B) モデル学習
    model = RandomForestClassifier(n_estimators=10)
    model.fit(X, y)

    # (C) /opt/ml/model にモデル保存
    os.makedirs("/opt/ml/model", exist_ok=True)
    joblib.dump(model, "/opt/ml/model/model.joblib")
    print("MODEL SAVED!")

if __name__ == "__main__":
    main()
ローカルで動かす場合

学習用データを inference/training/sample_data.csv のように配置

コマンド例：

bash
コピーする
編集する
# カレントディレクトリを inference/ にして実行
cd inference
python3 training_script.py --data-path ./sample_data.csv
正常終了すると ./model.joblib が生成される

SageMaker 上で動かす場合

Notebook (例: demo_notebook.ipynb) を開き、以下のように実行

python
コピーする
編集する
from sagemaker.sklearn.estimator import SKLearn
import boto3

bucket_name = "yoshitaka-ml-portfolio-data-bucket-apne1"
role = "arn:aws:iam::782397533297:role/ml-portfolio-sagemaker-exec-role"

sklearn_estimator = SKLearn(
    entry_point="training_script.py",
    source_dir=".",
    role=role,
    instance_type="ml.m5.large",
    instance_count=1,
    framework_version="0.23-1",  # またはサポート済みバージョン
    py_version="py3",
    output_path=f"s3://{bucket_name}/output",
    base_job_name="ml-portfolio-sklearn",
)

sklearn_estimator.fit({"training": f"s3://{bucket_name}/training/sample_data.csv"})
学習が完了すると、S3 の output/ml-portfolio-sklearn-<timestamp>/output/model.tar.gz にアーティファクトが作成される。

2) 学習済みモデルをエンドポイント化（推論 API）
(A) 学習ジョブ名からモデルデータの S3 URI を取得

python
コピーする
編集する
import boto3

sm = boto3.client("sagemaker", region_name="ap-northeast-1")
training_job_name = sklearn_estimator.latest_training_job.name
resp = sm.describe_training_job(TrainingJobName=training_job_name)
model_data = resp["ModelArtifacts"]["S3ModelArtifacts"]
print("ModelArtifacts (S3 URI):", model_data)
(B) inference_script.py の準備

python
コピーする
編集する
import joblib
import pandas as pd
import os
import json

def model_fn(model_dir):
    """
    SageMaker が起動時に呼び出す関数。
    S3 からダウンロードされた model.tar.gz を展開すると model.joblib が出てくる前提。
    """
    model_path = os.path.join(model_dir, "model.joblib")
    model = joblib.load(model_path)
    return model

def input_fn(request_body, request_content_type):
    """
    リクエストボディ（CSV）が渡ってくる想定。
    """
    if request_content_type == "text/csv":
        df = pd.read_csv(
            filepath_or_buffer=pd.compat.StringIO(request_body), 
            header=None, 
            names=["feature1", "feature2"]
        )
        return df
    else:
        raise ValueError("Unsupported content type: {}".format(request_content_type))

def predict_fn(input_data, model):
    """
    Pandas DataFrame を受け取り、予測結果の NumPy 配列を返す。
    """
    preds = model.predict(input_data)
    return preds

def output_fn(prediction, response_content_type):
    """
    JSON レスポンスとして返す。
    """
    if response_content_type == "application/json":
        return json.dumps({"predictions": prediction.tolist()})
    else:
        raise ValueError("Unsupported response content type: {}".format(response_content_type))
(C) モデルとエンドポイントのデプロイ

python
コピーする
編集する
from sagemaker.sklearn.model import SKLearnModel

sklearn_model = SKLearnModel(
    model_data=model_data,
    role=role,
    entry_point="inference_script.py",   # カレントディレクトリに配置済み
    framework_version="0.23-1",
    py_version="py3"
)

predictor = sklearn_model.deploy(
    initial_instance_count=1,
    instance_type="ml.m5.large",                  # t3.medium などは非推奨の場合があるので注意
    endpoint_name="ml-portfolio-sklearn-endpoint"
)
注意

すでに同じ名前の endpoint-config が残っているとエラーになります。
その場合は

python
コピーする
編集する
sm.delete_endpoint(EndpointName="ml-portfolio-sklearn-endpoint")
sm.delete_endpoint_config(EndpointConfigName="ml-portfolio-sklearn-endpoint")
を実行してから再度 deploy() してください。

(D) 推論リクエストを投げる（CSV → JSON）

python
コピーする
編集する
import pandas as pd
import boto3
import json

df_input = pd.DataFrame({
    "feature1": [0.5, 1.7, 2.9],
    "feature2": [1.2, 0.4, 3.1]
})
csv_payload = df_input.to_csv(header=False, index=False)

sm_runtime = boto3.client("sagemaker-runtime", region_name="ap-northeast-1")
response = sm_runtime.invoke_endpoint(
    EndpointName="ml-portfolio-sklearn-endpoint",
    ContentType="text/csv",
    Accept="application/json",
    Body=csv_payload
)
result = response["Body"].read().decode("utf-8")

学習メモ
ChatGPT (o4-mini-high) でのコード検索・修正

Terraform の aws_sagemaker_training_job リソースが v5.99.1 の AWS Provider ではサポート外だったため、
Consultant:

「aws_sagemaker_training_job は最新バージョンの provider だと非推奨なので、代わりに SKLearn SDK で学習ジョブを走らせる方法に切り替えた。」

Python SDK の SKLearn で指定できる framework_version の選択肢を ChatGPT に聞いて、
古いバージョン（例: 0.23-1, 1.2-1）→ Python 環境に合わせてインストール → 1.6-1 はサポート外、といった対応を行った。

バグ修正の例

scikit-learn バージョンの不整合で model.joblib がローカルで読み込めない → Notebook 環境を scikit-learn==1.2.2 に合わせる

ml.t3.medium のインスタンスタイプが SageMaker エンドポイントでは非推奨 → ml.m5.large や ml.t2.medium に変更

inference_script.py のパス指定ミス → Notebook 環境ではカレントディレクトリが /home/ec2-user/SageMaker なので、VSCode からアップロードするときに src/ を指定せず直接置く
