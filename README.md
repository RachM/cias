cias
====

Fitness landscape analysis of circle packing into a square problems.

To use:

lengthScale.m 
  - Calculates the length scales from the samples and measure various statistics.
  - Requirements:
    - The kernel density estimation uses the solve-the-equation plug-in method for bandwidth estimation (line 43).  To do this, I have used the code available at http://www.umiacs.umd.edu/labs/cvl/pirl/vikas/Software/optimal_bw/optimal_bw_code.htm. You will need to compile it and have the fast_univariate_bandwidth_estimate_STEPI.m file and mex file sitting in the same directory as these files.

runGetMetrics.m
  - Calculates all metrics from the samples.
- Requirements:
    - Run after running runGetSamples.m
    - Needs the optimal solutions for the packings. You can download these from the Packomania website (http://www.packomania.com/). The direct download link (current as of September 2014) is available at http://hydra.nat.uni-magdeburg.de/packing/csq/txt/csq_coords.tar.gz.