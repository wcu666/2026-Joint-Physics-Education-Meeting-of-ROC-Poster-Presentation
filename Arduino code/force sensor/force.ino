double t=0, Vi=10, Voo=0, N, val=0;
unsigned long i=0;
bool running = true;
void setup()
{
Serial.begin(9600);
pinMode(A2, INPUT); 
}
void loop()
{
if (Serial.available() > 0) {
char ch = Serial.read(); 
if (ch == ' ' || ch == 32) {
running = !running; 
}
}
if (!running) {
delay(10); 
return;
}
if(i >= 1000){
t = micros();
t = t / 1000000.0;
val = val / 1000.0; 
val = val * 4.0 - 12.0;
N = val * 6.25;
Serial.print(t, 4);
Serial.print(",");
Serial.println(N, 4);
val = 0;
i = 0;
}
Voo = analogRead(A2);
Voo = (Voo / 1023.0 ) * 5.0;
val = val + Voo;
delayMicroseconds(5);
i++;
}
