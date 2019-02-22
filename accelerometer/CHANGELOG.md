# Changelog

## 2019-02-22 (v 2.1.0)
- Code cleanups (use functions, better comments)
- Use more config variables
- Drop `delta` from data output, but leave it in debug logging
- Increase acceleration precision to 3 digits (configurable)
- Use `stop_us` output to better coincide with acceleration timing (I think)

## 2019-02-19 (v 2.0.0)
- Changed accelerometer from 4G to 8G range.
- Changed acceleration output from `m/s²` to `G` since it's metric/imperial agnostic.
- Called `lis.read()` directly instead of `lis.getEvent()` for a very small speed boost (but mostly to avoid conversion from `G` to `m/s²`.
- Set accelerometer to faster data rate (unsure this has an effect [due to issues in the library](https://github.com/adafruit/Adafruit_LIS3DH/issues/14)).
- Use [SDFat library](https://github.com/greiman/SdFat) to support long filenames.
- Uses a full timestamp for the output filename (e.g. `201902171830.csv`).
- Set I2C speed to [fast mode](https://www.i2c-bus.org/fastmode/).
- Define the column units (e.g. `µs`, `G`) in the header row to reduce disk usage.
- Dropped `millis()` from output (same info provided by `micros()`).
- Dropped battery voltage from output.
- Dropped acceleration range from output (inconsequential).
- Use `unsigned long` variables to reduce overhead.
- Call the `unixtime()` just once at start up and use `micros()` to estimate time afterward (shaved off 30ms per loop).
 - Dropped the motion-detection aspect of data writing and simply write the data to the SD card every 800 loops.

## 2019-01-04 (v 1.0.0)
- Initial check-in
