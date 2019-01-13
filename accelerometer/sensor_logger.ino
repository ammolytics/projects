/**
 * Created by Ammolytics
 * License: MIT
 * Version: 1.0.0
 * URL: https://github.com/ammolytics/projects/
 * Inexpensive firearm accelerometer based on the Adafruit LIS3DH breakout board.
 */

#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include <Adafruit_LIS3DH.h>
#include <Adafruit_Sensor.h>
#include "RTClib.h"

// Used for software SPI
#define LIS3DH_CLK 13
#define LIS3DH_MISO 12
#define LIS3DH_MOSI 11
// Used for hardware & software SPI
#define LIS3DH_CS 10

#define VBATPIN A7

// Enable debug logger.
// Note: Comment out before running in real-world.
#define DEBUG

#ifdef DEBUG
  #define DEBUG_PRINT(x)  Serial.print (x)
  #define DEBUG_PRINTLN(x)  Serial.println (x)
#else
  #define DEBUG_PRINT(x)
  #define DEBUG_PRINTLN(x)
#endif

RTC_PCF8523 rtc;

// change this to match your SD shield or module;
// Adafruit SD shields and modules: pin 10
const int chipSelect = 10;
// 19 digits plus the null char
char DateTimeString[20];

// Filename format:  20180710.csv
char filename[13];

char dataRow[10000];
String strRow;
int counter = 0;

int lastX;

File dataFile;

// software SPI
//Adafruit_LIS3DH lis = Adafruit_LIS3DH(LIS3DH_CS, LIS3DH_MOSI, LIS3DH_MISO, LIS3DH_CLK);
// hardware SPI
//Adafruit_LIS3DH lis = Adafruit_LIS3DH(LIS3DH_CS);
// I2C
Adafruit_LIS3DH lis = Adafruit_LIS3DH();


void setup() {
  #ifdef DEBUG
    Serial.begin(9600);
    while (!Serial);     // will pause Zero, Leonardo, etc until serial console opens
  #endif

  float measuredvbat = analogRead(VBATPIN);
  measuredvbat *= 2;    // we divided by 2, so multiply back
  measuredvbat *= 3.3;  // Multiply by 3.3V, our reference voltage
  measuredvbat /= 1024; // convert to voltage
  DEBUG_PRINT("VBat: " ); DEBUG_PRINTLN(measuredvbat);

  DEBUG_PRINTLN("Initializing SD card...");

  if (!SD.begin(chipSelect)) {
    DEBUG_PRINTLN("Card failed, or not present");
    // don't do anything more:
    while (1);
  }
  DEBUG_PRINTLN("Card initialized.");

  
  DEBUG_PRINTLN("Initializing RTC...");
  if (! rtc.begin()) {
    DEBUG_PRINTLN("Couldn't find RTC");
    while (1);
  }
  if (! rtc.initialized()) {
    DEBUG_PRINTLN("RTC is NOT running!");
  }
  DEBUG_PRINTLN("RTC initialized.");

  
  DEBUG_PRINTLN("Initializing LIS3DH Sensor...");
  if (! lis.begin(0x18)) {   // change this to 0x19 for alternative i2c address
    DEBUG_PRINTLN("Couldnt start");
    while (1);
  }
  lis.setRange(LIS3DH_RANGE_4_G);   // 2, 4, 8 or 16 G!
  DEBUG_PRINTLN("LIS3DH initialized.");


  DEBUG_PRINTLN("Ready!");

  DateTime now = rtc.now();
  sprintf_P(DateTimeString, PSTR("%4d-%02d-%02d %d:%02d:%02d"),
      now.year(), now.month(), now.day(), now.hour(), now.minute(), now.second());
  sprintf_P(filename, PSTR("%4d%02d%02d.csv"), now.year(), now.month(), now.day());

  DEBUG_PRINTLN(DateTimeString);
  DEBUG_PRINTLN(filename);

  dataFile = SD.open(filename, O_CREAT | O_WRITE);
  dataFile.println("timestamp, accel x, accel y, accel z, accel unit, sensor range, millis, micros, voltage");
  DEBUG_PRINTLN(dataFile);
  if (! dataFile) {
     DEBUG_PRINTLN("Could not open file...");
  }
  dataFile.close();

  // Check to see if the file exists:
  if (SD.exists(filename)) {
    DEBUG_PRINTLN("Log file exists.");
  } else {
    DEBUG_PRINTLN("Log file doesn't exist.");
  }

  // Leave the file open for writing.
  dataFile = SD.open(filename, O_CREAT | O_APPEND | O_WRITE);
}



// Main Loop
void loop() {
  float measuredvbat = analogRead(VBATPIN);
  measuredvbat *= 2;    // we divided by 2, so multiply back
  measuredvbat *= 3.3;  // Multiply by 3.3V, our reference voltage
  measuredvbat /= 1024; // convert to voltage
  //DEBUG_PRINT("VBat: " ); DEBUG_PRINTLN(measuredvbat);
  
  lis.read();      // get X Y and Z data at once
  // Then print out the raw data
  /*
  DEBUG_PRINT(lis.x); DEBUG_PRINT(", ");
  DEBUG_PRINT(lis.y); DEBUG_PRINT(", ");
  DEBUG_PRINT(lis.z); DEBUG_PRINT(", ");
  */

  /* Or....get a new sensor event, normalized */ 
  sensors_event_t event;
  lis.getEvent(&event);

  int rangeVal = 2 << lis.getRange();

  DateTime now = rtc.now();

  /*
  sprintf_P(dataRow, PSTR("%d, %d, %d, %d, %s, %s, %d"), 
      now.unixtime(), event.acceleration.x, event.acceleration.y, event.acceleration.z, "m/s^2", rangeVal, millis());

  DEBUG_PRINTLN(dataRow);
  */
  
  /* Display the results (acceleration is measured in m/s^2) */
  strRow = String(now.unixtime()) + ", ";
  strRow += String(event.acceleration.x) + ", ";
  strRow += String(event.acceleration.y) + ", ";
  strRow += String(event.acceleration.z) + ", ";
  strRow += "m/s^2, ";
  strRow += String(rangeVal) + ", ";
  strRow += String(millis()) + ", ";
  strRow += String(micros()) + ", ";
  strRow += String(measuredvbat);
  
  DEBUG_PRINTLN(strRow);  

  // Open the file if it's closed.
  if (!dataFile) {
    dataFile = SD.open(filename, O_CREAT | O_APPEND | O_WRITE);
  }
  // if the file is available, write to it:
  if (dataFile) {
    dataFile.println(strRow);
  } else {
    // if the file isn't open, pop up an error:
    DEBUG_PRINTLN("error opening file");
  }

  // Determine if the unit is actively recording important motion to prevent delays from writing ops.
  // X-Axis is inline with bore. Least likely to detect acceleration of gravity.
  bool inMotion = false;
  if (max(event.acceleration.x, lastX) > 1.0 || min(event.acceleration.x, lastX) < -1.0) {
    inMotion = true;
  }

  counter++;
  // write the data to prevent loss.
  if (counter >= 20 && !inMotion) {
    DEBUG_PRINTLN("Data file write/flush.");
    dataFile.flush();
    counter = 0;
  } else {
    DEBUG_PRINTLN(inMotion);
  }
  if (counter >= 100) {
    DEBUG_PRINTLN("Data file write/close.");
    dataFile.close();
    counter = 0;
  }

  lastX = event.acceleration.x;
 
  //delay(1);
}
