from robot.api import logger


class LibraryTwoHavingAConflictingKeyword:

    ROBOT_LIBRARY_SCOPE = 'TEST CASE'

    def __init__(self, state, **kwargs):
        self._state = state
        self._kwargs = kwargs

    # this method is a keyword in robot, refer to built-in-library-test.robot
    def conflicting_keyword(self):
        logger.debug('I am from LibraryTwoHavingAConflictingKeyword.py')
        return 'LibraryTwo'

    def third_conflicting_keyword(self):
        return 'LibraryTwoeHavingAConflictingKeyword.py'
