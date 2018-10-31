#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <EEPROM.h> 
//https://khoinghiepiot.com/05-05-2018-WebClient-ESP8266/
ESP8266WebServer server(80);

const char* ssid = "khoitao";
const char* passphrase = "khoitao";
String st;
String content;
int statusCode;

void setup() {
  Serial.begin(115200);
  EEPROM.begin(512);
  delay(10);
  Serial.println();
  Serial.println();
  Serial.println("Bắt đầu");
  Serial.println("Đọc SSID từ EEPROM");
  String esid;
  for (int i = 0; i < 32; ++i)
    {
      esid += char(EEPROM.read(i));
    }
  Serial.print("SSID: ");
  Serial.println(esid);
  Serial.println("Đọc PASS từ EEPROM");
  String epass = "";
  for (int i = 32; i < 96; ++i)
    {
      epass += char(EEPROM.read(i));
    }
  Serial.print("PASS: ");
  Serial.println(epass);  
  if ( esid.length() > 1 ) {
      WiFi.begin(esid.c_str(), epass.c_str());
      if (testWifi()) {
        Serial.print("\nĐã kết nối wifi");
        return;
     } 
     else
     {
        setupAP();
        launchWeb();
        ESP.restart();
     }
  }
}

bool testWifi(void) {
  int c = 0;
  Serial.println("Chờ wifi kết nối");  
  while ( c < 20 ) {
    if (WiFi.status() == WL_CONNECTED) { return true; } 
    delay(500);
    Serial.print(WiFi.status());    
    c++;
  }
  Serial.println("");
  Serial.println("Kết nối không khả dụng, opening AP");
  return false;
} 

void launchWeb() {
  Serial.print("Khởi tạo SSID...");
  char ssid[64];
  sprintf(ssid, "AP-%06X", ESP.getChipId());
  WiFi.softAP(ssid, passphrase);
  IPAddress myIP = WiFi.softAPIP();
  Serial.print("AP IP address: ");
  Serial.println(myIP);
  createWebServer();
  // Start the server
  server.begin();
  Serial.println("Máy chủ sẵn sàng"); 
}

void setupAP(void) {
  WiFi.mode(WIFI_STA);
  WiFi.disconnect();
  delay(100);
  int n = WiFi.scanNetworks();
  Serial.println("Quét wifi xong");
  if (n == 0)
    Serial.println("Chưa tìm thấy wifi gần đây");
  else
  {
    Serial.print(n);
    Serial.println(" Đã tìm thấy các mạng:");
    for (int i = 0; i < n; ++i)
     {
      Serial.print(i + 1);
      Serial.print(": ");
      Serial.print(WiFi.SSID(i));
      Serial.print(" (");
      Serial.print(WiFi.RSSI(i));
      Serial.print(")");
      Serial.println((WiFi.encryptionType(i) == ENC_TYPE_NONE)?" ":"*");
      delay(10);
     }
  }
  Serial.println(""); 
  st = "<ol>";
  for (int i = 0; i < n; ++i)
    {
      st += "<li>";
      st += WiFi.SSID(i);
      st += " (";
      st += WiFi.RSSI(i);
      st += ")";
      st += (WiFi.encryptionType(i) == ENC_TYPE_NONE)?" ":"*";
      st += "</li>";
    }
  st += "</ol>";
  delay(100);
  WiFi.softAP(ssid, passphrase,6);
  Serial.println("softap");
  launchWeb();
  Serial.println("over");
}

void createWebServer()
{
    server.on("/", []() {
        IPAddress ip = WiFi.softAPIP();
        String ipStr = String(ip[0]) + '.' + String(ip[1]) + '.' + String(ip[2]) + '.' + String(ip[3]);
        content = "<!DOCTYPE HTML>\r\n<html>Hello from ESP8266 at ";
        content += ipStr;
        content += "<p>";
        content += st;
        content += "</p><form method='get' action='setting'><label>SSID: </label><input name='ssid' length=32><input name='pass' length=64><input type='submit'></form>";
        content += "</html>";
        server.send(200, "text/html", content);  
    });
    server.on("/setting", []() {
        String qsid = server.arg("ssid");
        String qpass = server.arg("pass");
        if (qsid.length() > 0 && qpass.length() > 0) {
          Serial.println("Đang xóa eeprom");
          for (int i = 0; i < 96; ++i) { EEPROM.write(i, 0); }
          Serial.println(qsid);
          Serial.println("");
          Serial.println(qpass);
          Serial.println("");
          Serial.println("Đang ghi SSID vào eeprom:");
          for (int i = 0; i < qsid.length(); ++i)
            {
              EEPROM.write(i, qsid[i]);
              Serial.print("Đã ghi: ");
              Serial.println(qsid[i]); 
            }
          Serial.println("Đang ghi PASS vào eeprom:"); 
          for (int i = 0; i < qpass.length(); ++i)
            {
              EEPROM.write(32+i, qpass[i]);
              Serial.print("Đã ghi: ");
              Serial.println(qpass[i]); 
            }    
          EEPROM.commit();
          content = "{\"Thành công\":\"đã lưu vào eeprom... khởi động với tên wifi mới\"}";
          statusCode = 200;
        } else {
          content = "{\"Lỗi\":\"404 không tìm thấy\"}";
          statusCode = 404;
          Serial.println("Gửi mã 404");
        }
        server.send(statusCode, "application/json", content);
    });
}

void loop() {
  server.handleClient();
}