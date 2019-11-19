/**
 * Created by Ammolytics
 * License: MIT
 * Version: 2.2.0
 * URL: https://github.com/ammolytics/projects/
 * Inexpensive firearm accelerometer based on the Adafruit LIS3DH breakout board.
 */

#include <SPI.h>
#include <Adafruit_LIS3DH.h>
#include <Adafruit_Sensor.h>
#include "RTClib.h"
#include "SdFat.h"


// Used for hardware & software SPI
#define LIS3DH_CS 5

// change this to match your SD shield or module;
// Adafruit SD shields and modules: pin 10
#define SD_CS 10

// Battery pin
#define VBATPIN A7

// Set range to 2G, 4G, 8G, 16G
#define ACCEL_RANGE LIS3DH_RANGE_8_G
// 5khz data rate
#define ACCEL_DATARATE LIS3DH_DATARATE_LOWPOWER_5KHZ
// Decimal precision for acceleration
#define ACCEL_PRECISION 3
// Separator character
#define SEP ","

// Enable debug logger.
// Note: Comment out before running in real-world.
//#define DEBUG

#ifdef DEBUG
  #define DEBUG_PRINT(x)  Serial.print (x)
  #define DEBUG_PRINTLN(x)  Serial.println (x)
#else
  #define DEBUG_PRINT(x)
  #define DEBUG_PRINTLN(x)
#endif

RTC_PCF8523 rtc;


// Filename format:  YYYYMMDDHHmm.csv
char filename[17];


unsigned long begin_us;
unsigned long begin_epoch;
unsigned long start_us;
unsigned long stop_us;
unsigned long counter = 0;


// hardware SPI
Adafruit_LIS3DH lis = Adafruit_LIS3DH(LIS3DH_CS);


// set up variables using the SD utility library functions:
// File system object.
SdFat sd;
// Log file.
SdFile dataFile;


/**
 * Setup procedures.
 */
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
  #ifdef DEBUG
    // Set the RTC date/time when in debug mode.
    rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
  #endif
  DEBUG_PRINTLN("RTC initialized.");
  begin_us = micros();
  DateTime now = rtc.now();
  begin_epoch = now.unixtime();

  // Set filename based on timestamp.
  sprintf_P(filename, PSTR("%4d%02d%02d%02d%02d.csv"), now.year(), now.month(), now.day(), now.hour(), now.minute());
  DEBUG_PRINT("Filename: ");
  DEBUG_PRINTLN(filename);

  /**
   * Initialize the accelerometer.
   */
  DEBUG_PRINTLN("Initializing LIS3DH Sensor...");
  if (! lis.begin()) {
    DEBUG_PRINTLN("Couldnt start");
    while (1);
  }

  lis.setRange(ACCEL_RANGE);
  lis.setDataRate(ACCEL_DATARATE);
  /**
   * NOTE: For the following to work, the writeRegister8 function must be public in 
   * Adafruit_LIS3DH/Adafruit_LIS3DH.h
   *
   * Force Normal Mode, High Resolution. This sets speed to 1.25kHz.
   */
  lis.writeRegister8(LIS3DH_REG_CTRL1, 0b10010111);
  lis.writeRegister8(LIS3DH_REG_CTRL4, 0b10100000);
  DEBUG_PRINTLN("LIS3DH initialized.");

  /**
   * Initialize the SD card and log file.
   */
  DEBUG_PRINTLN("Initializing SD card...");
  if (!sd.begin(SD_CS, SD_SCK_MHZ(50))) {
    DEBUG_PRINTLN("Card failed, or not present");
    // don't do anything more:
    while (1);
  }
  DEBUG_PRINTLN("Card initialized.");

  if (! dataFile.open(filename, O_CREAT | O_APPEND | O_WRITE)) {
     DEBUG_PRINTLN("Could not open file...");
     while (1);
  }
  // Write header row to file.
  dataFile.println("timestamp (s), start (µs), accel x (G), accel y (G), accel z (G)");
  dataFile.flush();
  
  // Check to see if the file exists:
  if (! sd.exists(filename)) {
    DEBUG_PRINTLN("Log file doesn't exist.");
    while (1);
  }

  DEBUG_PRINTLN("Ready!");
  DEBUG_PRINTLN("timestamp (s), start (µs), delta (µs), accel x (G), accel y (G), accel z (G)");
}


/**
 * Main Loop
 */
void loop() {
  read_accel();
  log_timers();
  log_accel();
  counter++;

  if (counter >= 5000) {
    write_sd();
    counter = 0;
  }
}


/**
 * Read from the accelerometer sensor and measure how long the op takes.
 */
void read_accel() {
  start_us = micros();
  lis.read();
  stop_us = micros();
}


/**
 * Output the timing info.
 */
void log_timers() {
  DEBUG_PRINT(begin_epoch + ((stop_us - begin_us) / 1000000));
  DEBUG_PRINT(SEP);
  DEBUG_PRINT(stop_us);
  DEBUG_PRINT(SEP);
  // Include time delta in debug output.
  DEBUG_PRINT(stop_us - start_us);
  DEBUG_PRINT(SEP);

  // Write timestamp to file.
  // Roughly equivalent to calling rtc.now().unixtime(), without 1ms latency.
  dataFile.print(begin_epoch + ((stop_us - begin_us) / 1000000));
  dataFile.print(SEP);
  // Write timers to file.
  dataFile.print(stop_us);
  dataFile.print(SEP);
}


/**
 * Output the acceleration info.
 */
void log_accel() {
  #ifdef DEBUG
    Serial.print(lis.x_g, ACCEL_PRECISION);
    Serial.print(SEP);
    Serial.print(lis.y_g, ACCEL_PRECISION);
    Serial.print(SEP);
    Serial.println(lis.z_g, ACCEL_PRECISION);
  #endif
  // Write acceleration to file.
  dataFile.print(lis.x_g, ACCEL_PRECISION);
  dataFile.print(SEP);
  dataFile.print(lis.y_g, ACCEL_PRECISION);
  dataFile.print(SEP);
  dataFile.println(lis.z_g, ACCEL_PRECISION);
}


/**
 * Flush buffer, actually write to disk.
 * This can take between 9 and 26 milliseconds. Or ~10ms with SDfat.
 */
void write_sd() {
  DEBUG_PRINTLN("Writing to SD card");
  unsigned long pre_write = micros();
  dataFile.flush();
  DEBUG_PRINT("Write ops took: ");
  DEBUG_PRINTLN(micros() - pre_write);
}
