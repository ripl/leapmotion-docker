#!/bin/bash

# YOUR CODE BELOW THIS LINE
# ----------------------------------------------------------------------------


# launching app
cpk-exec leapd
leapctl eula -y
rosrun leap_motion_controller lmc.py


# ----------------------------------------------------------------------------
# YOUR CODE ABOVE THIS LINE
