/* #######################    APOGEE COMPILED   ######################## */

/*
Name
        GRedgeptn

Description
            This class contains instance data and overrides methods necessary
        to implement edge patterning of graphics objects.

History
        sdm     04/01/87    creation
        mrm     11/11/87    moved points & parameters from GRpa
        scw     06/28/92    ANSI conversion
*/

class specification GRedgeptn (1:0) of GRpa;

instance GRedgeptn
{
    IGRpoint            dir_pt;         /* indicator for closed elements     */
    IGRpoint            stop_pt;        /* point to stop patterning element  */
    struct GRparms      start_parm;     /* geometric parameters for start_pt */
    struct GRparms      dir_parm;       /* geometric parameters for dir_pt   */
    struct GRparms      stop_parm;      /* geometric parameters for stop_pt  */
};

/*
 *  message overrides for GRedgeptn
 */

override GRgenerate, GRconstruct;

end specification GRedgeptn;
