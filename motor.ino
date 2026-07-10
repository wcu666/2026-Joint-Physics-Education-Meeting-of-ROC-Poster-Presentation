// ========================================================
// 膠帶黏滑效應實驗 - 步進馬達慢速測試程式碼
// ========================================================

// 定義 A4988 與 Arduino 連接的控制腳位
const int dirPin = 2;   // 方向控制腳位 (DIR) 接 Arduino Pin 2
const int stepPin = 3;  // 步進控制腳位 (STEP) 接 Arduino Pin 3
const int enPin = 4;    // 致能控制腳位 (ENABLE) 接 Arduino Pin 4 (可不接)

void setup() {
  // 設定腳位為輸出模式
  pinMode(dirPin, OUTPUT);
  pinMode(stepPin, OUTPUT);
  pinMode(enPin, OUTPUT);

  // 啟用馬達驅動器 (A4988 的 ENABLE 腳位是低電位觸發)
  digitalWrite(enPin, HIGH);

  // 設定馬達旋轉方向 (HIGH 或 LOW 代表正反轉)
  // 實驗時如果發現捲動方向相反，把這裡改成 LOW 即可
  digitalWrite(dirPin,LOW);
  
  // 開啟序列埠通訊，方便在電腦畫面上確認程式有在跑
  Serial.begin(9600);
  Serial.println("==========================================");
  Serial.println("【慢速除錯模式】程式已成功啟動！");
  Serial.println("轉動膠帶中...");
  Serial.println("==========================================");
}

void loop() {
  // 產生一個極慢速的高低電位脈衝，強迫馬達轉動
  digitalWrite(stepPin, HIGH);
  delay(100); // 延時 500 毫秒 (0.5 秒)
  
  digitalWrite(stepPin, LOW);
  delay(100); // 延時 500 毫秒 (0.5 秒)
}