import processing.serial.*;
import cc.arduino.*;
import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.effects.*;

Arduino arduino;

Minim minim;
AudioOutput out;
SquareWave square;
LowPassSP   lowpass;

int photocellPin = 0;     // the cell and 10K pulldown are connected to a0
int photocellReading;     // the analog reading from the sensor divider
int LEDpin = 11;          // connect Red LED to pin 11 (PWM pin)
int LEDbrightness;        //
int pitch;

void setup() {
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  arduino.pinMode(photocellPin, Arduino.INPUT);
  arduino.pinMode(LEDpin, Arduino.OUTPUT);
  
  minim = new Minim(this);
  // get a stereo line out with a sample buffer of 512 samples
  out = minim.getLineOut(Minim.STEREO, 512);
 
  // create a SquareWave with a frequency of 440 Hz, 
  // an amplitude of 1 and the same sample rate as out
  square = new SquareWave(400, 1, 44100);
 
  // create a LowPassSP filter with a cutoff frequency of 200 Hz 
  // that expects audio with the same sample rate as out
  lowpass = new LowPassSP(200, 44100);
 
  // now we can attach the square wave and the filter to our output
  out.addSignal(square);
  out.addEffect(lowpass);
}

void draw() {
  photocellReading = arduino.analogRead(photocellPin);  
  
  print("Analog reading = ");
  println(photocellReading);     // the raw analog reading
  
  // LED gets brighter the darker it is at the sensor
  // that means we have to -invert- the reading from 0-1023 back to 1023-0
  photocellReading = 1023 - photocellReading;
  //now we have to map 0-1023 to 0-255 since thats the range analogWrite uses
  LEDbrightness = round(map(photocellReading, 0, 1023, 0, 255));
  pitch = round(map(photocellReading, 0, 1023, 0, 440));
  print("Signal Hz = ");
  println(pitch);     // the raw analog reading
  arduino.analogWrite(LEDpin, LEDbrightness);
  println(square);
  //out.removeSignal(square);
  square.setFreq(pitch);
  //out.addSignal(square);
}

void stop()
{
  out.close();
  minim.stop();
 
  super.stop();
}
