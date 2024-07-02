# Biorobotic Arm for DMD Patients

This repository contains code for controlling a biorobotic arm designed for patients with Duchenne Muscular Dystrophy (DMD). The code is written in Python and MATLAB, and it includes classes for signal processing, pin definitions, potentiometer readings, state management, and EMG signal processing.

## Table of Contents

- [Python Code](#python-code)
  - [Biquad Filter](#biquad-filter)
  - [Pin Definitions](#pin-definitions)
  - [Potentiometer](#potentiometer)
  - [State Object](#state-object)
  - [Timer Definitions](#timer-definitions)
- [MATLAB Code](#matlab-code)
  - [EMG Plots](#emg-plots)
- [Usage](#usage)

## Python Code

### Biquad Filter

`biquad.py` contains the `Biquad` class for implementing a biquad filter.

```python
class Biquad(object):
    def __init__(self, a_param, b_param):
        self.inputsamples = [0, 0, 0]
        self.outputsamples = [0, 0, 0]
        self.b = [b_param[0], b_param[1], b_param[2]]
        self.a = [a_param[0], a_param[1], a_param[2]]
        return

    def step(self, sample):
        self.inputsamples = [sample, self.inputsamples[0], self.inputsamples[1]]
        output = self.b[0]*self.inputsamples[0] + self.b[1]*self.inputsamples[1] + self.b[2]*self.inputsamples[2] - self.a[1]*self.outputsamples[1] - self.a[2]*self.outputsamples[2]
        self.outputsamples = [output, self.outputsamples[0], self.outputsamples[1]]
        return output
```

### Pin Definitions

`pin_definitions.py` provides a centralized place to declare pin assignments for the robot.

```python
class Pins(object):
    NUCLEO_BLUE_BUTTON = 'C13'
    BR_BUTTON1 = ''
    POTMETER1 = 'A5'
    POTMETER2 = ''
    MOTOR1_DIRECTION = 'D4'
    MOTOR1_PWM = 'D5'
    MOTOR1_ENC_A = 'D0'
    MOTOR1_ENC_B = 'D1'
    MOTOR2_DIRECTION = 'D7'
    MOTOR2_PWM = 'D6'
    MOTOR2_ENC_A = 'D11'
    MOTOR2_ENC_B = 'D12'
    EMG1 = 'A0'
    EMG2 = 'A1'
    EMG3 = 'A2'
    EMG4 = 'A3'
```

### Potentiometer

`potmeter.py` contains the `Potmeter` class for reading values from potentiometers.

```python
from pin_definitions import Pins
from machine import Pin, ADC

class Potmeter(object):
    def __init__(self, meter=1):
        if meter == 1:
            self.pin = Pin(Pins.POTMETER1, Pin.IN)
            self.adc = ADC(self.pin)
        else:
            self.pin = Pin(Pins.POTMETER2, Pin.IN)
            self.adc = ADC(self.pin)
        return

    def read(self):
        return self.adc.read_u16()
```

### State Object

`state_object.py` contains the `StateObject` class for managing the state of the robot.

```python
from states import States

class StateObject(object):
    def __init__(self):
        self.last_state = None
        self.state = States.CALIBRATION1
        return

    def set_state(self, state):
        self.last_state = self.state
        self.state = state
        return

    def is_new_state(self):
        is_new = self.last_state is not self.state
        if is_new:
            self.last_state = self.state
        return is_new
```

### Timer Definitions

`timer_definitions.py` is another file related to state management.

```python
from states import States

class StateObject(object):
    def __init__(self):
        self.last_state = None
        self.state = States.CALIBRATION1
        return

    def set_state(self, state):
        self.last_state = self.state
        self.state = state
        return

    def is_new_state(self):
        is_new = self.last_state is not self.state
        if is_new:
            self.last_state = the state
        return is_new
```

## MATLAB Code

### EMG Plots

`EMGPlots.m` is a MATLAB script for processing and visualizing EMG data.

```matlab
% EMG processing script
clear, clc
A = importdata('raw.csv')

t1 = A.data(:,1);
y1 = A.data(:,2);
t1 = t1 - t1(1);

% High-pass filter
b = [0.9655939685724159, -1.562363860482067, 0.9655939685724159];
a = [1, -1.562363860482067, 0.9311879371448318];
ugh = filter(b,a,y1);

% Low-pass filter
b = [0.9911536, -1.98230719, 0.9911536];
a = [1, -1.98222893, 0.98238545];
y2 = filter(b,a,ugh);
y3 = abs(y2);

% Another low-pass filter
a0 = 0.07606843425477747;
a1 = 0.15213686850955493;
a2 = 0.07606843425477747;
b1 = -1.2889242337808442;
b2 = 0.5931979707999537;
b = [a0,a1,a2];
a = [1,b1,b2];

y4 = filter(b,a,y3);

% Integrating the signal
M = 20;
A = [];
SUM = [];
counter = 1;
for i = 1:length(y4)/M
    for j = 1:M
        A(i,j) = y4(counter);
        counter = counter+1;
    end
end
SUM = sum(A,2);
SUM = SUM/M;
for i = 1:length(y4)/M
    integrated(i*M:i*M+M) = SUM(i);
end
y5 = integrated(M+1:end);
y6 = y5/max(y5);

% Plotting the results
figure(1), clf(1)
subplot(2,2,1), hold on, grid on
plot(t1, y1)
plot(t1, y2)
xlim([t1(1), t1(end)])
legend('Raw signal / 2^{16} (bits)', 'High passed signal')
title('A: Raw vs High passed signal (with 50 Hz Notchfilter)')
xlabel('time [s]')
ylabel('magnitude [-]')
hold off

subplot(2,2,2), hold on, grid on
plot(t1, y3)
plot(t1, y4)
xlim([t1(1), t1(end)])
legend('Rectified signal', 'Low passed signal')
title('B: Rectified vs Low-passed signal')
xlabel('time [s]')
ylabel('magnitude [-]')
hold off

subplot(2,2,3), hold on, grid on
plot(t1, y5)
xlim([t1(1), t1(end)])
legend('Integrated signal')
title('C: Integrated signal')
xlabel('time [s]')
ylabel('magnitude [-]')
hold off

subplot(2,2,4), hold on, grid on
plot(t1, y6)
xlim([t1(1), t1(end)])
legend('Normalized integrated signal')
title('D: Normalized integrated signal')
xlabel('time [s]')
ylabel('magnitude [%] (w.r.t. max flex)')
hold off

figure(2), clf(2), hold on, grid on
plot(t1, y3)
plot(t1, y4)
xlim([t1(1), t1(end)])
legend('Rectified signal', 'Low passed signal')
title('Rectified vs Low-passed signal')
xlabel('time [s]')
ylabel('magnitude [-]')
hold off
axes('position',[.65 .175 .25 .25])
box on, hold on
indexOfInterest = ( t1>1.7 & t1<2 );
plot(t1(indexOfInterest), y3(indexOfInterest))
plot(t1(indexOfInterest), y4(indexOfInterest))
axis tight
hold off
```

## Usage

1. Clone the repository:

   ```bash
   git clone https://github.com/HAJEKEL/biorobotic_arm_dmd_patients.git
   cd biorobotic_arm_dmd_patients
   ```

2. Run the Python scripts as needed for the robot's functionality.

3. Use the MATLAB script `EMGPlots.m` to process and visualize EMG data.

Feel free to contribute by opening issues or submitting pull requests.
