/* #######################    APOGEE COMPILED   ######################## */


/*
Name
        GRareaptn

Description
            This class contains instance data and overrides methods necessary
        to implement area patterning of graphics objects.

History
        sdm     04/01/87    creation
        mrm     12/01/87    subclassing changes
        scw     06/28/92    ANSI conversion
*/

class specification GRareaptn (1:0) of GRpa;

/*
 *  instance data
 */

instance GRareaptn
{
    IGRdouble       dy;     /* pattern y-delta */
};

/*
 *  message overrides
 */

override GRgenerate, GRconstruct;

end specification GRareaptn;
