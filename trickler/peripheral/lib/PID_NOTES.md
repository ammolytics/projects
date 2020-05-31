Integrating process: process whose output variable (powder weight) can only "integrate" or increase over time.

Can't decrease weight with motor.


VS = Vibration speed (0 - 100%)
W = Weight (0 - 100% to target weight)

(Eric: Typos from PIDTuner? Motor should start fast and slow down)

- Start with VS=10% and wait until W=20%
- Set VS=50% and wait until W=50%
- Set VS=25% and wait until W=70%
- Set VS=70% and wait until W=100%

Output data in columns:

| Timestamp | Input (motor %) | Output (weight g) |

(Eric: Another typo? Should output be in % complete?)
