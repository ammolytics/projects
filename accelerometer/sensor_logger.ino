/**
 * Created by Ammolytics
 * License: MIT
 * Version: 2.0.0
 * URL: https://github.com/ammolytics/projects/
 * Inexpensive firearm accelerometer based on the Adafruit LIS3DH breakout board.
 */

#include <Wire.h>
#include <SPI.h>
#include <Adafruit_LIS3DH.h>
#include <Adafruit_Sensor.h>
#include "RTClib.h"
#include "SdFat.h"


// Battery pin
#define VBATPIN A7

// I2C clock speed
#define I2C_SPEED 1000000

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


// Filename format:  YYYYMMDDHHmm.csv
char filename[17];


unsigned long begin_us;
unsigned long begin_epoch;
unsigned long start_us;
unsigned long stop_us;
unsigned long counter = 0;


// software SPI
//Adafruit_LIS3DH lis = Adafruit_LIS3DH(LIS3DH_CS, LIS3DH_MOSI, LIS3DH_MISO, LIS3DH_CLK);
// hardware SPI
//Adafruit_LIS3DH lis = Adafruit_LIS3DH(LIS3DH_CS);
// I2C
Adafruit_LIS3DH lis = Adafruit_LIS3DH();

// set up variables using the SD utility library functions:
// File system object.
SdFat sd;
// Log file.
SdFile dataFile;


void setup() {
  #ifdef DEBUG
    Serial.begin(115200);
    while (!Serial);     // will pause Zero, Leonardo, etc until serial console opens
  #endif

  #ifdef DEBUG
    float measuredvbat = analogRead(VBATPIN);
    measuredvbat *= 2;    // we divided by 2, so multiply back
    measuredvbat *= 3.3;  // Multiply by 3.3V, our reference voltage
    measuredvbat /= 1024; // convert to voltage
    DEBUG_PRINT("VBat: " ); DEBUG_PRINTLN(measuredvbat);
  #endif

  /**
   * Initialize the Real Time Clock.
   */
  DEBUG_PRINTLN("Initializing RTC...");
  if (! rtc.begin()) {
    DEBUG_PRINTLN("Couldn't find RTC");
    while (1);
  }
  if (! rtc.initialized()) {
    DEBUG_PRINTLN("RTC is NOT running!");
  }
  DEBUG_PRINTLN("RTC initialized.");
  begin_us = micros();
  DateTime now = rtc.now();
  begin_epoch = now.unixtime();

  /**
   * Initialize the SD card and log file.
   */
  DEBUG_PRINTLN("Initializing SD card...");
  if (!sd.begin(chipSelect, SD_SCK_MHZ(50))) {
    DEBUG_PRINTLN("Card failed, or not present");
    // don't do anything more:
    while (1);
  }
  DEBUG_PRINTLN("Card initialized.");
  
  // Set filename based on timestamp.
  sprintf_P(filename, PSTR("%4d%02d%02d%02d%02d.csv"), now.year(), now.month(), now.day(), now.hour(), now.minute());
  DEBUG_PRINT("Filename: ");
  DEBUG_PRINTLN(filename);

  if (! dataFile.open(filename, O_CREAT | O_APPEND | O_WRITE)) {
     DEBUG_PRINTLN("Could not open file...");
     while (1);
  }
  DEBUG_PRINTLN("timestamp (s), start (µs), delta (µs), accel x (G), accel y (G), accel z (G)");
  // Write header row to file.
  dataFile.println("timestamp (s), start (µs), delta (µs), accel x (G), accel y (G), accel z (G)");
  dataFile.flush();
  
  // Check to see if the file exists:
  if (! sd.exists(filename)) {
    DEBUG_PRINTLN("Log file doesn't exist.");
    while (1);
  }
  
  /**
   * Initialize the accelerometer.
   */
  DEBUG_PRINTLN("Initializing LIS3DH Sensor...");
  if (! lis.begin(LIS3DH_DEFAULT_ADDRESS)) {   // change this to 0x19 for alternative i2c address
    DEBUG_PRINTLN("Couldnt start");
    while (1);
  }
  // Set I2C high speedmode
  Wire.setClock(I2C_SPEED);
  // Set range to 8G
  lis.setRange(LIS3DH_RANGE_8_G);
  // 5khz data rate
  lis.setDataRate(LIS3DH_DATARATE_LOWPOWER_5KHZ);
  DEBUG_PRINTLN("LIS3DH initialized.");

  DEBUG_PRINTLN("Ready!");
}


// Main Loop
void loop() {
  // Read from the accelerometer sensor and measure how long the op takes.
  start_us = micros();
  lis.read();
  stop_us = micros();

  // Roughly equivalent to calling rtc.now().unixtime(), without 1ms latency.
  DEBUG_PRINT(begin_epoch + ((stop_us - begin_us) / 1000000));
  DEBUG_PRINT(',');
  // Write timestamp to file.
  dataFile.print(begin_epoch + ((stop_us - begin_us) / 1000000));
  dataFile.print(',');

  DEBUG_PRINT(start_us);
  DEBUG_PRINT(',');
  DEBUG_PRINT(stop_us - start_us);
  DEBUG_PRINT(',');
  // Write timers to file.
  dataFile.print(start_us);
  dataFile.print(',');
  dataFile.print(stop_us - start_us);
  dataFile.print(',');
  
  DEBUG_PRINT(lis.x_g);
  DEBUG_PRINT(',');
  DEBUG_PRINT(lis.y_g);
  DEBUG_PRINT(',');
  DEBUG_PRINT(lis.z_g);
  // Write acceleration to file.
  dataFile.print(lis.x_g);
  dataFile.print(',');
  dataFile.print(lis.y_g);
  dataFile.print(',');
  dataFile.print(lis.z_g);

  DEBUG_PRINTLN();
  // Write newline.
  dataFile.println();
  counter++;

  /**
   * Flush buffer, actually write to disk.
   * This can take between 9 and 26 milliseconds. Or ~10ms with SDfat.
   */
  if (counter >= 800) {
    DEBUG_PRINTLN("Writing to SD card");
    unsigned long pre_write = micros();
    dataFile.flush();
    unsigned long post_write = micros();
    DEBUG_PRINT("Write ops took: "); DEBUG_PRINTLN(post_write - pre_write);
    counter = 0;
  }
}
