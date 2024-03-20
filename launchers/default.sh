#!/bin/bash

# YOUR CODE BELOW THIS LINE
# ----------------------------------------------------------------------------


# launching app
cpk-exec leapd
leapctl eula -y
roslaunch leap_motion_controller lmc.launch


# ----------------------------------------------------------------------------
# YOUR CODE ABOVE THIS LINE
