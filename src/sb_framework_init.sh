#!/usr/bin/env sh

# AUTHOR    : avimehenwal
# CREATED   : Wed 16 May 17:44:30 IST 2018
# FILENAME  : sb_framework_init.sh
# PROJECT   : springboard assessment
#
# startup script to control runtime variables

ROBOT="/home/avi/EXPERIMENT/PythonVirtualEmvironments/springboard/bin/robot"
TEST_SCRIPT="/home/avi/GITHUB/springboard_assignment/goibibo_test.robot"

echo "RUNNING  : Test Script"
`$ROBOT $TEST_SCRIPT`
echo "FINISHED : Opening Results"
`xdg-open /home/avi/GITHUB/springboard_assignment/report.html 2>/dev/null`

# END
