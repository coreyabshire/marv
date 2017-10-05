#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BNO055.h>
#include <utility/imumaths.h>

/* Set the delay between fresh samples */
#define BNO055_SAMPLERATE_DELAY_MS (100)

Adafruit_BNO055 bno = Adafruit_BNO055();

void setup() {
  // put your setup code here, to run once:
  Serial1.begin(9600);
  Serial1.println("Orientation Sensor Raw Data Test"); Serial.println("");

  /* Initialise the sensor */
  if(!bno.begin())
  {
    /* There was a problem detecting the BNO055 ... check your connections */
    Serial1.print("Ooops, no BNO055 detected ... Check your wiring or I2C ADDR!");
    while(1);
  }

  delay(1000);

  /* Display the current temperature */
  int8_t temp = bno.getTemp();
  Serial1.print("Current Temperature: ");
  Serial1.print(temp);
  Serial1.println(" C");
  Serial1.println("");

  bno.setExtCrystalUse(true);

  Serial1.println("Calibration status values: 0=uncalibrated, 3=fully calibrated");
}

void loop() {
  // put your main code here, to run repeatedly:
  String command = Serial1.readStringUntil('\n');
  if (command.length() > 0) {
    Serial1.print("received command: ");
    Serial1.println(command);
  }
}
