class LibraryWithState:

    ROBOT_LIBRARY_SCOPE = 'TEST CASE'

    def __init__(self, state, **kwargs):
        self._state = state
        self._kwargs = kwargs

    # this method is a keyword in robot, refer to "(Test 2/3) Change the state in the current LibraryWithState Instance"
    # in built-in-library-test.robot
    def set_state(self, state):
        self._state = state

    def get_state(self):
        return self._state
