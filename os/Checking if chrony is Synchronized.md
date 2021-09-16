Checking if chrony is Synchronized

4.3.4.45 sources

This command displays information about the current time sources that chronyd is accessing.
The optional argument -v can be specified, meaning verbose. In this case, extra caption lines are shown as a reminder of the meanings of the columns.

210 Number of sources = 3
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
#* GPS0                          0   4   377    11   -479ns[ -621ns] +/-  134ns
^? foo.example.net               2   6   377    23   -923us[ -924us] +/-   43ms
^+ bar.example.net               1   6   377    21  -2629us[-2619us] +/-   86ms
The columns are as follows:
M
This indicates the mode of the source. ^ means a server, = means a peer and # indicates a locally connected reference clock.
S
This column indicates the state of the sources. * indicates the source to which chronyd is currently synchronised. + indicates acceptable sources which are combined with the selected source. - indicates acceptable sources which are excluded by the combining algorithm. ? indicates sources to which connectivity has been lost or whose packets don’t pass all tests. x indicates a clock which chronyd thinks is is a falseticker (i.e. its time is inconsistent with a majority of other sources). ~ indicates a source whose time appears to have too much variability. The ? condition is also shown at start-up, until at least 3 samples have been gathered from it.
Name/IP address
This shows the name or the IP address of the source, or refid for reference clocks.
Stratum
This shows the stratum of the source, as reported in its most recently received sample. Stratum 1 indicates a computer with a locally attached reference clock. A computer that is synchronised to a stratum 1 computer is at stratum 2. A computer that is synchronised to a stratum 2 computer is at stratum 3, and so on.
Poll
This shows the rate at which the source is being polled, as a base-2 logarithm of the interval in seconds. Thus, a value of 6 would indicate that a measurement is being made every 64 seconds.
chronyd automatically varies the polling rate in response to prevailing conditions.
Reach
This shows the source’s reachability register printed as octal number. The register has 8 bits and is updated on every received or missed packet from the source. A value of 377 indicates that a valid reply was received for all from the last eight transmissions.
LastRx
This column shows how long ago the last sample was received from the source. This is normally in seconds. The letters m, h, d or y indicate minutes, hours, days or years. A value of 10 years indicates there were no samples received from this source yet.
Last sample
This column shows the offset between the local clock and the source at the last measurement. The number in the square brackets shows the actual measured offset. This may be suffixed by ns (indicating nanoseconds), us (indicating microseconds), ms (indicating milliseconds), or s (indicating seconds). The number to the left of the square brackets shows the original measurement, adjusted to allow for any slews applied to the local clock since. The number following the +/- indicator shows the margin of error in the measurement.
Positive offsets indicate that the local clock is fast of the source.
 


[ << ]
[ < ]
[ Up ]
[ > ]
[ >> ]
[Top]
[Contents]
[Index]
[ ? ]

4.3.4.46 sourcestats
The sourcestats command displays information about the drift rate and offset estimatation process for each of the sources currently being examined by chronyd.
The optional argument -v can be specified, meaning verbose. In this case, extra caption lines are shown as a reminder of the meanings of the columns.
An example report is

210 Number of sources = 1
Name/IP Address            NP  NR  Span  Frequency  Freq Skew  Offset  Std Dev
===============================================================================
abc.def.ghi                11   5   46m     -0.001      0.045      1us    25us
The columns are as follows
Name/IP Address
This is the name or IP address of the NTP server (or peer) or refid of the refclock to which the rest of the line relates.
NP
This is the number of sample points currently being retained for the server. The drift rate and current offset are estimated by performing a linear regression through these points.
NR
This is the number of runs of residuals having the same sign following the last regression. If this number starts to become too small relative to the number of samples, it indicates that a straight line is no longer a good fit to the data. If the number of runs is too low, chronyd discards older samples and re-runs the regression until the number of runs becomes acceptable.
Span
This is the interval between the oldest and newest samples. If no unit is shown the value is in seconds. In the example, the interval is 46 minutes.
Frequency
This is the estimated residual frequency for the server, in parts per million. In this case, the computer’s clock is estimated to be running 1 part in 10**9 slow relative to the server.
Freq Skew
This is the estimated error bounds on Freq (again in parts per million).
Offset
This is the estimated offset of the source.
Std Dev
This is the estimated sample standard deviation.
 
From <https://chrony.tuxfamily.org/doc/2.1/manual.html#sources-command>

