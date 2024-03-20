#!/bin/bash

# YOUR CODE BELOW THIS LINE
# ----------------------------------------------------------------------------


cpk-exec leapd
leapctl eula -y
export ROS_MASTER_URI=http://base1.local:11311
rosrun leap_motion_controller lmc.py


# ----------------------------------------------------------------------------
# YOUR CODE ABOVE THIS LINE
