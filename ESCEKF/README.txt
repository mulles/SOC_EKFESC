This archive includes files necessary to execute an extended-Kalman filter using
the enhanced self-correcting cell model. It contains several utility functions from
the ESCtoolbox as well as the main simulation codes.  In particular,

- runEKF.m:  Runs the extended-Kalman filter on the data provided
- initEKF.m: Called by runEKF to initialize the EKF variables
- iterEKF.m: Called by runEKF every iteration to update the EKF estimate

- E2model.mat:       The ESC model for an “E2” cell
- E2_DYN_15_P05.mat: Measured cell data for 5 degrees C
- E2_DYN_35_P25.mat: Measured cell data for 25 degrees C
For a description of the ESCtoolbox files, see comments in ESCtoolbox.zip.

---

All files in this archive are copyright (c) 2016 by Gregory L. Plett of the 
University of Colorado Colorado Springs (UCCS). This work is licensed under 
a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 Intl. License, 
v. 1.0. It is provided "as is", without express or implied warranty, for 
educational and informational purposes only.

These files are provided as a supplement to: Plett, Gregory L., "Battery
Management Systems, Volume II, Equivalent-Circuit Methods,” Artech House, 2015.
