# SINC-Logout
 Logout scripts for the Computer Labs (SINC Sites)

Author: Andrew W. Johnson
Date: 2022.01.05.
Version: 2.00
Organization: Stony Brook University/DoIT

In order to get a script to run on logout on macOS we have to run it as a user LaunchAgent. The script runs and goes to sleep until it detects one of the following: SIGINT, SIGHUP, SIGTERM, SIGQUIT, SIGABRT.

Our old Apple SE suggested this approach, beyond that I don't know who developed the original idea.

Once one of these interrupts is detected the script kicks in and gets the short name of the user logged in, their home directory path, and the computer name.

1. A touch of the home directory is done so the script that removes home directories and users after 3-4 days can better calculate the time.
2. It turns the volume down.
3. Finally the username and computer name is curled up to a server which proceses and tracks usage.

There is a possibility that this will not work when the computer is abruptly rebooted such as our script that kicks users off who hog lab computers.