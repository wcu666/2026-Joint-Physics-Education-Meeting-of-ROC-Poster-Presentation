
const int dirPin = 2;   
const int stepPin = 3;  
const int enPin = 4;    
void setup() {
  pinMode(dirPin, OUTPUT);
  pinMode(stepPin, OUTPUT);
  pinMode(enPin, OUTPUT);
  digitalWrite(enPin, HIGH);
  digitalWrite(dirPin,LOW);
  Serial.begin(9600);
  Serial.println("==========================================");
  Serial.println("【慢速除錯模式】程式已成功啟動！");
  Serial.println("轉動膠帶中...");
  Serial.println("==========================================");
}
void loop() {
  digitalWrite(stepPin, HIGH);
  delay(100); // ms
  digitalWrite(stepPin, LOW);
  delay(100); // ms
}
