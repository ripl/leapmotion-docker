#!/usr/bin/env python
import leap
import rospy
from geometry_msgs.msg import Point, Pose, Quaternion
from lmc_msgs.msg import Hand, Hands
from std_msgs.msg import Header


class LeapMotionController(leap.Listener):
    def __init__(self):
        super().__init__()
        rospy.init_node('leap_motion_controller')
        self.pub = rospy.Publisher('/lmc/hands', Hands, queue_size=10)
        rospy.loginfo('LeapMotionController Node is Up!')
        connection = leap.Connection()
        connection.add_listener(self)
        with connection.open():
            connection.set_tracking_mode(leap.TrackingMode.Desktop)
            rospy.spin()

    def on_connection_event(self, event):
        rospy.loginfo('Connected to a Leap Motion Controller.')

    def on_device_event(self, event):
        with event.device.open():
            rospy.loginfo(f'Serial: {event.device.get_info().serial}')

    def on_tracking_event(self, event):
        hands_lst = [Hand(pose=Pose(position=Point(x=hand.palm.position.x, y=hand.palm.position.y, z=hand.palm.position.z), orientation=Quaternion(x=hand.palm.orientation.x, y=hand.palm.orientation.y, z=hand.palm.orientation.z, w=hand.palm.orientation.w)), pinch_distance=hand.pinch_distance, confidence=hand.confidence, visible_time=hand.visible_time) for hand in event.hands]
        hands_msg = Hands(header=Header(seq=event.tracking_frame_id, stamp=rospy.Time.now(), frame_id='lmc'), hands=hands_lst)
        self.pub.publish(hands_msg)


if __name__ == '__main__':
    LeapMotionController()
