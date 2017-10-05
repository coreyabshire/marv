#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BNO055.h>
#include <utility/imumaths.h>
#include <Servo.h>

volatile int steering_pwm_value = 0;
volatile int steering_prev_time = 0;
volatile int throttle_pwm_value = 0;
volatile int throttle_prev_time = 0;

volatile int encoder0a_state = 0;
volatile int encoder0b_state = 0;
volatile int encoder1a_state = 0;
volatile int encoder1b_state = 0;

volatile int encoder0_count = 0;
volatile int encoder1_count = 0;

int steering_pin;
int throttle_pin;
int encoder0a_pin;
int encoder0b_pin;
int encoder1a_pin;
int encoder1b_pin;
int steering_servo_voltage_pin;

Servo steering_servo;
Servo throttle_servo;

struct Control {
  int16_t steering_pwm;
  int16_t throttle_pwm;
};

int steering_center_pwm = 1391;
int throttle_center_pwm = 1490;

struct Vec3f {
  float x;
  float y;
  float z;
};

struct Vec4f {
  float w;
  float x;
  float y;
  float z;
};

struct State {
  int timestamp;
  float orientation_x;
  float orientation_y;
  float orientation_z;
  float acceleration_x;
  float acceleration_y;
  float acceleration_z;
  int radio_steering_pwm;
  int radio_throttle_pwm;
  int encoder0_count;
  int encoder1_count;
  int steering_servo_voltage;
};

/* Set the delay between fresh samples */
#define BNO055_SAMPLERATE_DELAY_MS (100)

Adafruit_BNO055 bno = Adafruit_BNO055();

Control control;
State state;

imu::Vector<3> euler_orientation;
imu::Vector<3> linear_acceleration;

void setup() {
  // put your setup code here, to run once:
  Serial1.begin(460800);
  Serial1.setTimeout(20);
  Serial1.println("Orientation Sensor Raw Data Test");

  steering_pin = digitalPinToInterrupt(4);
  throttle_pin = digitalPinToInterrupt(5);
  encoder0a_pin = digitalPinToInterrupt(13);
  encoder0b_pin = digitalPinToInterrupt(14);
  encoder1a_pin = digitalPinToInterrupt(15);
  encoder1b_pin = digitalPinToInterrupt(16);
  steering_servo_voltage_pin = 9;

  encoder0a_state = digitalRead(13);
  encoder0b_state = digitalRead(14);
  encoder1a_state = digitalRead(15);
  encoder1b_state = digitalRead(16);
  
  attachInterrupt(steering_pin, steering_rising, RISING);
  attachInterrupt(throttle_pin, throttle_rising, RISING);
  attachInterrupt(encoder0a_pin, encoder0a_state ? encoder0a_falling : encoder0a_rising, encoder0a_state ? FALLING : RISING);
  attachInterrupt(encoder0b_pin, encoder0b_state ? encoder0b_falling : encoder0b_rising, encoder0b_state ? FALLING : RISING);
  attachInterrupt(encoder1a_pin, encoder1a_state ? encoder1a_falling : encoder1a_rising, encoder1a_state ? FALLING : RISING);
  attachInterrupt(encoder1b_pin, encoder1b_state ? encoder1b_falling : encoder1b_rising, encoder1b_state ? FALLING : RISING);

  steering_servo.attach(2);
  throttle_servo.attach(3);

  /* Initialise the sensor */
  if(!bno.begin())
  {
    /* There was a problem detecting the BNO055 ... check your connections */
    Serial.print("Ooops, no BNO055 detected ... Check your wiring or I2C ADDR!");
    while(1);
  }

  delay(1000);

  bno.setExtCrystalUse(true);

  Serial.println("Calibration status values: 0=uncalibrated, 3=fully calibrated");
  Serial.println("BEGIN LOOP");
}

void updateState()
{
  state.timestamp = micros();
  euler_orientation = bno.getVector(Adafruit_BNO055::VECTOR_EULER);
  linear_acceleration = bno.getVector(Adafruit_BNO055::VECTOR_LINEARACCEL);
  state.orientation_x = (float) euler_orientation.x();
  state.orientation_y = (float) euler_orientation.y();
  state.orientation_z = (float) euler_orientation.z();
  state.acceleration_x = (float) linear_acceleration.x();
  state.acceleration_y = (float) linear_acceleration.y();
  state.acceleration_z = (float) linear_acceleration.z();
  state.steering_servo_voltage = analogRead(steering_servo_voltage_pin);
  noInterrupts();
  state.radio_steering_pwm = steering_pwm_value;
  state.radio_throttle_pwm = throttle_pwm_value;
  state.encoder0_count = encoder0_count;
  state.encoder1_count = encoder1_count;
  encoder0_count = 0;
  encoder1_count = 0;
  interrupts();
}

void readControl() {
  control.steering_pwm = 0;
  control.throttle_pwm = 0;
  Serial1.readBytes((byte*)&control, sizeof(control));
}

void printControl() {
  Serial.print(control.steering_pwm);
  Serial.print(" ");
  Serial.print(control.throttle_pwm);
  Serial.println();
}

void updateControl() {
  if (control.steering_pwm > 800 && control.steering_pwm < 2200) {
    steering_servo.writeMicroseconds(state.radio_steering_pwm);
  } else {
    steering_servo.writeMicroseconds(steering_center_pwm);
  }
  if (control.throttle_pwm > 1300 && control.throttle_pwm < 1700) {
    throttle_servo.writeMicroseconds(state.radio_throttle_pwm);
  } else {
    throttle_servo.writeMicroseconds(throttle_center_pwm);
  }
}


void loop() {
  readControl();
  printControl();
  updateControl();
  updateState();
  Serial1.write((byte*)&state, sizeof(state));
}

void enc0Arising() {
  
}

void steering_rising() {
  attachInterrupt(steering_pin, steering_falling, FALLING);
  steering_prev_time = micros();
}
 
void steering_falling() {
  attachInterrupt(steering_pin, steering_rising, RISING);
  steering_pwm_value = micros() - steering_prev_time;
}

void throttle_rising() {
  attachInterrupt(throttle_pin, throttle_falling, FALLING);
  throttle_prev_time = micros();
}
 
void throttle_falling() {
  attachInterrupt(throttle_pin, throttle_rising, RISING);
  throttle_pwm_value = micros() - throttle_prev_time;
}

void encoder0a_rising() {
  attachInterrupt(encoder0a_pin, encoder0a_falling, FALLING);
  encoder0a_state = 1;
  encoder0_count += (encoder0b_state ? -1 : 1);
}

void encoder0a_falling() {
  attachInterrupt(encoder0a_pin, encoder0a_rising, RISING);
  encoder0a_state = 0;
  encoder0_count += (encoder0b_state ? 1 : -1);
}

void encoder0b_rising() {
  attachInterrupt(encoder0b_pin, encoder0b_falling, FALLING);
  encoder0b_state = 1;
  encoder0_count += (encoder0a_state ? 1 : -1);
}

void encoder0b_falling() {
  attachInterrupt(encoder0b_pin, encoder0b_rising, RISING);
  encoder0b_state = 0;
  encoder0_count += (encoder0a_state ? -1 : 1);
}

void encoder1a_rising() {
  attachInterrupt(encoder1a_pin, encoder1a_falling, FALLING);
  encoder1a_state = 1;
  encoder1_count += (encoder1b_state ? 1 : -1);
}

void encoder1a_falling() {
  attachInterrupt(encoder1a_pin, encoder1a_rising, RISING);
  encoder1a_state = 0;
  encoder1_count += (encoder1b_state ? -1 : 1);
}

void encoder1b_rising() {
  attachInterrupt(encoder1b_pin, encoder1b_falling, FALLING);
  encoder1b_state = 1;
  encoder1_count += (encoder1a_state ? -1 : 1);
}

void encoder1b_falling() {
  attachInterrupt(encoder1b_pin, encoder1b_rising, RISING);
  encoder1b_state = 0;
  encoder1_count += (encoder1a_state ? 1 : -1);
}

