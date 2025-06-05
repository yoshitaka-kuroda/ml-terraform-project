# inference_script.py
import os
import joblib
import pandas as pd
import json
from io import StringIO

# --------------------------------------------------------------------------------
#  モデルのロード ※エンドポイント起動時に一度だけ呼び出される
# --------------------------------------------------------------------------------
def model_fn(model_dir):
    # /opt/ml/model 以下に model.joblib が置かれている想定
    model_path = os.path.join(model_dir, "model.joblib")
    return joblib.load(model_path)

# --------------------------------------------------------------------------------
#  リクエストボディを “pandas.DataFrame” に変換
#  - content_type="text/csv" のときのみ受け付ける（今回は CSV で送信するので）
#  - もし JSON で送りたいなら elif に “application/json” を追加してパースする
# --------------------------------------------------------------------------------
def input_fn(request_body, content_type):
    if content_type == "text/csv":
        # CSV の文字列を pandas.DataFrame に変換
        # "header=None" としているので、1行目が列名ではなくデータとして読み込まれる
        df = pd.read_csv(StringIO(request_body), header=None, names=["feature1", "feature2"])
        return df
    else:
        raise ValueError(f"Unsupported content_type: {content_type}. Only 'text/csv' is supported.")

# --------------------------------------------------------------------------------
#  実際にモデルを使って予測する
#  - input_fn で返した DataFrame と model_fn で返したモデルを使う
# --------------------------------------------------------------------------------
def predict_fn(input_data, model):
    # input_data は pandas.DataFrame、model は RandomForestClassifier など
    preds = model.predict(input_data)
    return preds

# --------------------------------------------------------------------------------
#  予測結果を “application/json” または “text/csv” で返す
#  - invoke_endpoint(..., Accept="application/json") されたら JSON を返す
#  - invoke_endpoint(..., Accept="text/csv") されたら CSV を返す
# --------------------------------------------------------------------------------
def output_fn(prediction, accept):
    """
    prediction: numpy.ndarray もしくは list の予測結果
    accept: リクエストで渡された Accept ヘッダーの値
    """
    if accept == "application/json":
        # JSON にして返す例:
        result_dict = {"predictions": prediction.tolist()}
        return json.dumps(result_dict), "application/json"

    if accept == "text/csv":
        # CSV のみ返す例:
        # ヘッダー行を付けず、1行に1つずつ数字を置く（あるいは好みのフォーマットで）
        csv_result = "\n".join([str(p) for p in prediction])
        return csv_result, "text/csv"

    raise ValueError(f"Unsupported Accept type: {accept}. Choose 'application/json' or 'text/csv'.")