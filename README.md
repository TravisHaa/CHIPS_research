# CHIPS_research

This repository contains research and scripts related to TrueAdapt™ technology for fan-out wafer level packaging (FOWLP).

The edge detection script was the first script I developed, which used canny edge detection to isolate and obtain accurate measures of corner alignment marker edges to draw contours of the alignment markers. The centroids of each corner alignment marker contour are then used to calculate the center of each die in a given image. After developing and testing the second script, I realized that a more accurate version of template matching produced better results than using edge detection.

CHIPS-CV_v8-4 was the script that I developed to increase die center shift detection by over 90%. Basically, this method accounts for rotation in template matching the corner alignment markers of each die, which is then used to calculate the center of the die.

AStar_router is a A* router that is meant to route wires between the die components that were captured from the script CHIPS-CV_v8-4.ipynb. 

process_microled.ipynb is the current script I'm working on, aimed at accurately routing wires through our microLED chip for each microLED (two contacts make up a singular microLED), accounting for two types of defects:

1. The contact is missing, and a artificial contact must be added based off its neighbor contacts.
2. The contact exists, however it gets obstructed during imaging process.

---

**Notebook Summaries**

1. **CHIPS-CV_v8-4.ipynb** (53KB)

This notebook implements a comprehensive computer vision pipeline for semiconductor chip analysis. The main steps are:

- **Image Preprocessing:** Loads wafer scan images, converts to grayscale, and handles large image sizes through OpenCV configuration.
- **Alignment Marker Detection:** Uses template matching to identify global alignment markers with high accuracy (threshold > 0.9).
- **Scale Calculation:** Computes pixel-to-micron scale using known alignment marker distances and image dimensions.
- **Rotation Correction:** Detects and corrects wafer rotation using alignment markers, with iterative refinement to achieve sub-degree accuracy.
- **Die Identification:** Uses contour detection and area-based filtering to identify individual dies, excluding alignment markers.
- **Misalignment Analysis:** Calculates die offsets and rotations relative to ideal positions, accounting for assembly offsets.
- **Corner Marker Analysis:** Detects and analyzes corner alignment markers within each die using template matching.
- **Data Export:** Generates JSON and CSV files containing detailed shift measurements for each die.
- **Visualization:** Creates annotated images showing detected features, measurements, and alignment information.

This script achieves over 90% improvement in die center shift detection accuracy compared to previous methods.
---
2. **TrueAdapt_v3_AStar_Router_NoOverlap_v0.1.ipynb** (156KB)

This notebook implements an advanced A\* pathfinding algorithm for circuit routing in semiconductor design. The main components are:

- **GDSII Integration:** Handles GDSII file format for semiconductor layouts using gdspy library.
- **Multi-layer Support:** Implements routing across multiple metal layers (Metal1, Metal2) with via connections.
- **Obstacle Handling:**
  - Rasterizes polygons to grid for obstacle detection
  - Supports layer-specific obstacles
  - Implements obstacle avoidance in path planning
- **Grid-based Routing:**
  - Converts layout to searchable grid
  - Implements efficient path finding between points
  - Handles layer transitions through vias
- **Via Management:**
  - Creates and places vias between metal layers
  - Supports both square and circular via shapes
  - Maintains design rule compliance
- **Path Optimization:**
  - Minimizes path length and via count
  - Avoids path overlaps
  - Optimizes for manufacturing constraints
---
3. **edge_det.ipynb** (40KB)

This notebook focuses on edge detection and feature extraction for semiconductor images. The main features are:

- **Template Matching:**
  - Implements normalized cross-correlation for feature detection
  - Handles multiple template types (crosses, squares)
  - Supports threshold-based matching
- **Contour Analysis:**
  - Detects and processes image contours
  - Filters contours based on area and shape
  - Handles contour hierarchy
- **Feature Extraction:**
  - Calculates angles between points
  - Computes centroids of features
  - Measures distances and offsets
- **Image Processing:**
  - Implements Canny edge detection
  - Handles image rotation and scaling
  - Supports region of interest selection
- **Visualization:**
  - Draws detected features on images
  - Annotates measurements and angles
  - Generates debug visualizations
---
4. **process_microled.ipynb** (7.8MB)

This notebook automates the detection, pairing, and routing of microLED contacts from wafer images. The main steps are:

- **Image Preprocessing:** Loads a microLED wafer image, applies grayscale conversion and thresholding to isolate contact regions, and corrects for any image rotation.
- **Region of Interest (ROI) Selection:** Crops the image to a user-defined region containing the relevant contacts.
- **Contact Detection:** Uses contour detection to identify individual contact points within the ROI.
- **Row Grouping:** Groups detected contacts into rows based on their vertical positions, filtering out defects and sorting contacts within each row.
- **Contact Pairing:** Pairs contacts within each row to represent individual LEDs, inserting "fake" contacts if a contact is missing to maintain correct pairing.
- **Visualization:** Generates and saves images visualizing detected contacts, rows, and paired contacts, with annotations for distances and defects.
- **GDSII Layout Generation:** Uses the `gdspy` library to place contact shapes, route vertical and horizontal paths, and add vias in a GDSII layout, matching the detected and paired contacts.
- **Data Export:** Saves the paired contact data to both JSON and CSV formats for further analysis or record-keeping.

This process enables automated, robust extraction and layout of microLED contact information from wafer images, supporting both visualization and downstream fabrication steps.
---
5. **TrueAdapt_v3_AStar_Router_NoOverlap_v0.1 copy.ipynb** (34KB)

This is a backup version of the A\* router implementation with some key differences:

- **Experimental Features:**
  - May contain alternative routing strategies
  - Includes modified obstacle handling
  - Features different optimization parameters
- **Development History:**
  - Preserves earlier working versions of algorithms
  - Contains debugging and testing code
  - Maintains alternative implementations
- **Documentation:**
  - Includes additional comments and explanations
  - Contains test cases and examples
  - Features alternative parameter configurations
