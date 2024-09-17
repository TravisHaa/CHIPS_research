# CHIPS_research
This repository contains research and scripts related to TrueAdapt™ technology for fan-out wafer level packaging (FOWLP).

The edge detection script was the first script I developed, which used canny edge detection to isolate and obtain accurate measures of corner alignment marker edges to draw contours of the alignment markers. The centroids of each corner alignment marker contour are then used to calculate the center of each die in a given image. After developing and testing the second script, I realized that a more accurate version of template matching produced better results than using edge detection.

CHIPS-CV_v8-4 was the script that I developed to increase die center shift detection by over 90%. Basically, this method accounts for rotation in template matching the corner alignment markers of each die, which is then used to calculate the center of the die. 

