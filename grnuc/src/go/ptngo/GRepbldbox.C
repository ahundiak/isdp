/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        GRbuildbox

Description
        This function builds the polygon used to clip the symbols at the
        start and stop points of an edge pattern.  The polygon will be a
        cube with x-y dimensions 4x the larger dimension of the symbol (just
        to be sure).

Synopsis
        int GRbuildbox (msg, left, xrange, yrange, box)

        long     *msg;              o  return code
        int       left;             i  extend box to the left (1) or right (0)
        double    xrange, yrange;   i  of symbol defining pattern
        double   *box;              o  returned polygon (5 points)


Return Values

History
        mrm     05/25/88    creation
        scw     06/28/92    ANSI conversion
*/

#include "grimport.h"
#include "msdef.h"

int GRbuildbox (msg, left, xrange, yrange, box)

long     *msg;               /* return code */
int       left;              /* extend box to the left (1) or right (0) */
double    xrange, yrange;    /* of symbol defining pattern */
double   *box;               /* returned polygon */

{
    double   direction;      /* left or right */
    double   length;         /* box dimensions */

    length = (xrange > yrange) ? xrange : yrange;
    direction = (left) ? (-1.0) : 1.0;

    box[0] = box[12] = 0.0;                 /* lower right (left) corner */
    box[1] = box[13] = length * (-2.0);
    box[2] = box[14] = 0.0;

    box[3] = length * direction * 4.0;      /* lower left (right) corner */
    box[4] = box[1];
    box[5] = box[2];

    box[6] = box[3];                        /* upper left (right) corner */
    box[7] = length * 2.0;
    box[8] = box[2];

    box[9] = box[0];                        /* upper right (left) corner */
    box[10] = box[7];
    box[11] = box[2];

    return (*msg = MSSUCC);
}
