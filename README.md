# CHIPS_research

This repository contains research and scripts related to TrueAdapt™ technology for fan-out wafer level packaging (FOWLP).

The edge detection script was the first script I developed, which used canny edge detection to isolate and obtain accurate measures of corner alignment marker edges to draw contours of the alignment markers. The centroids of each corner alignment marker contour are then used to calculate the center of each die in a given image. After developing and testing the second script, I realized that a more accurate version of template matching produced better results than using edge detection.

### CHIPS-CV_v8-4  was the script that I developed to increase die center shift detection by over 90%. Basically, this method accounts for rotation in template matching the corner alignment markers of each die, which is then used to calculate the center of the die.

## Before:
<img width="673" height="642" alt="image" src="https://github.com/user-attachments/assets/06eb4f11-539c-4a57-b9d6-1eb30cc3b755" />

## After:
<img width="673" height="642" alt="image" src="https://github.com/user-attachments/assets/b01366d4-2756-4e80-8713-c42d015c3bb5" />


### AStar_router is a 3D A* router that is meant to route wires between the die components that were captured from the script CHIPS-CV_v8-4.ipynb. The die components consist of 3 layers of wiring that my router has to account for.

**Here are some Routing visualizations:**

The purple is the spacing that is supposed to be maintained between wires on the same layer. The blue and green colors indicate different layers.

<img width="400" height="400" alt="IMG_1272" src="https://github.com/user-attachments/assets/b3d9e812-48cf-45a0-9f17-3cc89b99ac9e" />
<img width="400" height="400" alt="IMG_4268" src="https://github.com/user-attachments/assets/948a6dce-5ba3-4d8b-9c2a-b403d0d6fb89" />


### process_microled.ipynb is aimed at accurately routing wires through our microLED chip for each microLED (two contacts make up a singular microLED), accounting for two types of defects:

1. The contact is missing, and a artificial contact must be added based off its neighbor contacts.
2. The contact exists, however it gets obstructed during imaging process.

**Here are some visualizations of this:**

**MicroLED contacts at micron scale:**

<img width="400" height="400" alt="image" src="https://github.com/user-attachments/assets/ef9651c3-5855-40d5-b1a1-91fb22bc9dc3" />

**Entire microLED chip (zoomed out):**

<img width="400" height="400" alt="image" src="https://github.com/user-attachments/assets/1d43473e-cb94-49e1-b040-d553d634c7fd" />

***As you can see, there are billions of contacts that must be processed, so every operation per line of code contributes heavily to the runtime of this script.***

**MicroLED contacts after edge detection:**

<img width="400" height="400" alt="image" src="https://github.com/user-attachments/assets/c5433e00-e0ce-40e2-ac85-21fb412b1458" />

**After running the script with GDSPY, accounting for contact errors:**

<img width="400" height="400" alt="IMG_0004" src="https://github.com/user-attachments/assets/f2de0a27-1a2a-468f-b439-8c337bbc8644" />

**Script output on a portion of the entire MicroLED chip:**

<img width="400" height="400" alt="image" src="https://github.com/user-attachments/assets/fa4a56ed-24a2-40d9-a21b-77882846e96c" />

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

**Some various improvements Made over v8 (old script):**

- **Large-image reliability:** Sets `OPENCV_IO_MAX_IMAGE_PIXELS` before importing cv2 to avoid pixel-limit issues on very large scans. Adds runtime tracking with `datetime` (Start Time, End Time, Run Time) so long runs are measurable.

- **Better rotation estimation:** v8 used a single-edge angle (`get_angle_simple`). v8-4 adds `get_angle_simple_vert(...)` and `get_angle_averaged(...)`, which averages 4 edge-based angle estimates. This reduces sensitivity to one noisy marker pair and gives a more stable wafer rotation estimate.

- **Iterative rotation correction:** v8 applies one rotation pass if enabled. v8-4 iterates correction until `abs(theta) <= target_rotation` or a maximum number of iterations (`number_of_rotation_correction`) is reached — a meaningful improvement for scans with nontrivial residual skew after the first correction.

- **More explicit pipeline controls:** Introduces configurable `number_of_rotation_correction`, `target_rotation`, and a separate misalignments image path, making the notebook more controllable across different scan quality/use cases.

- **Adaptive template-threshold tuning for corner markers:** v8 uses fixed thresholds (cross: 0.63, squares: 0.58). v8-4 starts from tighter thresholds and adjusts dynamically to target expected marker counts (50 cross + 50 square) — a practical improvement when image contrast varies between runs.

- **Additional geometry/alignment stage:** New `calculate_offset(...)` estimates assembly offset using alignment marker vs die geometry. Though currently overridden with hardcoded values in analysis, the function provides a route toward data-driven offset calibration.

- **Expanded second-stage localization (`method_2`):** v8 has mostly placeholder behavior in `method_2`. v8-4 makes it operational: rotates templates by per-die theta, crops per-die ROI, rematches corner templates in each die, computes marker centers and die centers, and writes `method2_shifts_final.csv`. This is a major step toward per-die refined measurement.

- **New overlay/model fitting layer:** Adds `model(...)` and `residuals(...)` with `scipy.optimize.leastsq`, and `overlay(...)` to compare measured vs ideal corner geometry. This introduces a more analytical fit (translation/rotation/magnification style terms) beyond simple direct offsets.

- **More intermediate artifacts for debugging:** Writes extra files such as `threshold.png`, `identifymisalign.jpg`, and `overlay.jpg`, improving observability and troubleshooting at each stage.

- **Parameterization recalibration:** Key parameters updated to reflect an updated physical layout model:
  - `die_width`/`die_height`: 1900 → 2000 µm
  - `pitch`: 2575 → 2800 µm
  - `alignment_mark_dist`: 23000 → 25000 µm
  - Contour thresholding now uses a higher base threshold with an OTSU path, with fixed contour-area defaults earlier in flow.

**Summary:** v8-4 most improves rotation robustness, adaptive marker detection, second-pass per-die refinement, and debug visibility — making it closer to a production analysis pipeline.

---
2. **TrueAdapt_v3_AStar_Router_NoOverlap_v0.1.ipynb** (156KB)

This notebook is my implementation of an advanced A\* pathfinding algorithm for circuit routing in semiconductor design. The main components are:

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
