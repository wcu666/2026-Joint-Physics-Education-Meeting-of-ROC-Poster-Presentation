double t=0, Vi=10, Voo=0, N, val=0;
unsigned long i=0;
// 預設 true 一開始就直接執行，按空白鍵後會切換成 false 暫停
bool running = true;
void setup()
{
// 初始化序列埠
Serial.begin(9600);
pinMode(A2, INPUT); // 只保留力量感測器的 A2 腳位
}
void loop()
{
// 檢查電腦端是否有輸入資料
if (Serial.available() > 0) {
char ch = Serial.read(); // 讀取輸入的字元
// 檢查是否按下空白鍵 (ASCII 碼為 32 或用 ' ' 表示)
if (ch == ' ' || ch == 32) {
running = !running; // 狀態反轉：原本動就暫停，原本暫停就繼續
}
}
// 如果目前是暫停狀態 (running == false)，就直接跳過後面的讀取與計算
if (!running) {
delay(10); // 稍微延遲，避免讓 CPU 空轉太快
return; // 跳出本次 loop，重新檢查是否有按空白鍵
}
// ---------------- 後續為您原本的計算邏輯 ----------------
// 當累積滿 1000 次數據時才進行計算與顯示
if(i >= 1000){
// 1. 時間計算
t = micros();
t = t / 1000000.0;
// 2. 力量計算
val = val / 1000.0; 
val = val * 4.0 - 12.0;
N = val * 6.25;
// 3. 符合 Serial Plotter 的輸出格式 (只留時間與力量)
Serial.print(t, 4);
Serial.print(",");
Serial.println(N, 4);
// 將所有計數與累加數值歸零，迎接下一個 1000 次循環
val = 0;
i = 0;
}
// 每次 loop 持續讀取 A2 力量訊號並累加
Voo = analogRead(A2);
Voo = (Voo / 1023.0 ) * 5.0;
val = val + Voo;
// 使用微秒級延遲，維持您原本的採樣頻率
delayMicroseconds(5);
i++;
}