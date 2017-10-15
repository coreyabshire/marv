#include "Module.h"
#include <Adafruit_Sensor.h>
#include <Adafruit_BNO055.h>
#include <utility/imumaths.h>
#include <Servo.h>
#include <t3spi.h>

//Initialize T3SPI class as SPI_SLAVE
T3SPI SPI_SLAVE;

//The number of integers per data packet
//MUST be the same as defined on the MASTER device
//#define dataLength  256
#define dataLength  56
int safety = 2;

//Initialize the arrays for incoming data
volatile uint8_t data[dataLength] = {};
//volatile uint16_t data[dataLength] = {};

//Initialize the arrays for outgoing data
volatile uint8_t returnData[dataLength] = {};
//volatile uint16_t returnData[dataLength] = {};

int count = 42;

Module module;

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
  uint8_t filler_front[2];
  unsigned long timestamp;
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
  uint8_t filler_back[2];
};

/* Set the delay between fresh samples */
#define BNO055_SAMPLERATE_DELAY_MS (100)

Adafruit_BNO055 bno = Adafruit_BNO055();

Control control;
State state;

imu::Vector<3> euler_orientation;
imu::Vector<3> linear_acceleration;


void setup(){
  
  Serial.begin(115200);
  
  //Begin SPI in SLAVE (SCK pin, MOSI pin, MISO pin, CS pin)
  SPI_SLAVE.begin_SLAVE(SCK, MOSI, MISO, CS0);
  //SPI_SLAVE.begin_SLAVE();
  
  //Set the CTAR0_SLAVE0 (Frame Size, SPI Mode)
  SPI_SLAVE.setCTAR_SLAVE(8, SPI_MODE0);
  //SPI_SLAVE.setCTAR_SLAVE(16, SPI_MODE0);
  
  //Enable the SPI0 Interrupt
  NVIC_ENABLE_IRQ(IRQ_SPI0);

  
  //Poputlate the array of outgoing data
  for (int i=0; i<dataLength; i++){
    returnData[i]=31+i;
  }
  for (int i=safety; i<dataLength-safety; i++){
    returnData[i]=i;
  }
  returnData[safety] = count;

  module.sayHello();

  steering_pin = digitalPinToInterrupt(4);
  throttle_pin = digitalPinToInterrupt(5);
  encoder0a_pin = digitalPinToInterrupt(14);
  encoder0b_pin = digitalPinToInterrupt(15);
  encoder1a_pin = digitalPinToInterrupt(16);
  encoder1b_pin = digitalPinToInterrupt(17);
  steering_servo_voltage_pin = 9;

  encoder0a_state = digitalRead(14);
  encoder0b_state = digitalRead(15);
  encoder1a_state = digitalRead(16);
  encoder1b_state = digitalRead(17);
  
  attachInterrupt(steering_pin, steering_rising, RISING);
  attachInterrupt(throttle_pin, throttle_rising, RISING);
  attachInterrupt(encoder0a_pin, encoder0a_state ? encoder0a_falling : encoder0a_rising, encoder0a_state ? FALLING : RISING);
  attachInterrupt(encoder0b_pin, encoder0b_state ? encoder0b_falling : encoder0b_rising, encoder0b_state ? FALLING : RISING);
  attachInterrupt(encoder1a_pin, encoder1a_state ? encoder1a_falling : encoder1a_rising, encoder1a_state ? FALLING : RISING);
  attachInterrupt(encoder1b_pin, encoder1b_state ? encoder1b_falling : encoder1b_rising, encoder1b_state ? FALLING : RISING);

  steering_servo.attach(2);
  throttle_servo.attach(3);

  steering_servo.writeMicroseconds(steering_center_pwm);
  throttle_servo.writeMicroseconds(throttle_center_pwm);

  /* Initialise the sensor */
  while(!bno.begin())
  {
    /* There was a problem detecting the BNO055 ... check your connections */
    Serial.print("Ooops, no BNO055 detected ... Check your wiring or I2C ADDR!\n");
    delay(200);
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
    steering_servo.writeMicroseconds(control.steering_pwm);
  } else {
    steering_servo.writeMicroseconds(steering_center_pwm);
  }
  if (control.throttle_pwm > 800 && control.throttle_pwm < 2200) {
    throttle_servo.writeMicroseconds(control.throttle_pwm);
  } else {
    throttle_servo.writeMicroseconds(throttle_center_pwm);
  }
}

void printDebugInfo() {
  Serial.print("count: ");
  Serial.println(count);
  Serial.print("struct size: ");
  Serial.println(sizeof(state));
  Serial.print("dataLength: ");
  Serial.println(dataLength);
  Serial.print("timestamp: ");
  Serial.println(state.timestamp);
  Serial.print("dataPointer: ");
  Serial.println(SPI_SLAVE.dataPointer);
  Serial.flush();
}

void printDebugData() {
  //Print data received & data sent
  for (int i=0; i<dataLength; i++){
    Serial.print("data[");
    Serial.print(i);
    Serial.print("]: ");
    Serial.print(data[i]);
    Serial.print("   returnData[");
    Serial.print(i);
    Serial.print("]: ");
    Serial.println(((uint8_t*)&state)[i]);
    Serial.flush();
  }
}

void updateTestData() {
  for (int i=0; i<dataLength; i++){
    returnData[i]=31+i;
  }
  for (int i=safety; i<dataLength-safety; i++){
    returnData[i]=i;
  }
  returnData[safety] = count;
  ++count;
}

void resetIncomingData() {
  for (int i=0; i<dataLength; i++) {
    data[i] = 0;
  }
}

void updateControlSpi() {
  control = *((Control*)&data);
  Serial.print("steering: ");
  Serial.println(control.steering_pwm);
  Serial.print("throttle: ");
  Serial.println(control.throttle_pwm);
}

void loop() {
  updateState();
  //steering_servo.writeMicroseconds(steering_center_pwm);

  //Capture the time before receiving data
  if (SPI_SLAVE.dataPointer==0 && SPI_SLAVE.packetCT==0) {
    SPI_SLAVE.timeStamp1=micros();
  }  
 
  //Capture the time when transfer is done
  if (SPI_SLAVE.packetCT==1) {
    SPI_SLAVE.timeStamp2=micros();

    module.sayHello();
    updateControlSpi();
    updateControl();
    printDebugInfo();
    //printDebugData();

    //Print statistics for the previous transfer
    SPI_SLAVE.printStatistics(dataLength); 

    updateTestData();
    resetIncomingData();

    //Reset the packet count   
    SPI_SLAVE.packetCT=0;
  }
}

//Interrupt Service Routine to handle incoming data
void spi0_isr(void) {
  
  //Function to handle data
  SPI_SLAVE.rxtx8 (data, (uint8_t*)&state, (int)sizeof(state));
  //SPI_SLAVE.rxtx16(data, returnData, dataLength);
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

