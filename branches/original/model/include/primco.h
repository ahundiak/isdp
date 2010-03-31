#ifndef primco_include
#define primco_include

/* Dynamics */

#define EC_DY_EXTRUDE           0
#define EC_DY_CENTERLINE        1
#define EC_DY_START_ANGLE       2
#define EC_DY_END_ANGLE         3

/* Constructions */

#define EC_EXTRUDE              0
#define EC_TURN                 1

/* Construction Modes */

#define EC_EXTRUDE_ORTHO        0
#define EC_EXTRUDE_NON_ORTHO    1
#define EC_TURN_FULL            2
#define EC_TURN_END             3
#define EC_TURN_START_END       4

/* Construction Events */

#define EC_CURVE                0
#define EC_FROM_POINT           1
#define EC_TO_POINT             2
#define EC_AXIS_POINT1          1
#define EC_AXIS_POINT2          2
#define EC_START_ANGLE          3
#define EC_END_ANGLE_WITH_START 4
#define EC_END_ANGLE            3
#endif
