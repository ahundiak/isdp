/* #######################    APOGEE COMPILED   ######################## */


/*
Name
        GRpa

Description
        This is the root class for pattern attribute objects

History
        sdm     03/01/87    creation
        mrm     09/18/87    reject GRgenabsg, GRgeomprops, GRgetexgeom,
                            GRgetexsize, GRgetgeom, GRgetsize, GRpostabsg,
                            GRlocaldp and delete stub file
                11/02/87    change subclassing from GRcurve to GRowner
                            move pt1, pt2, pt3, p1, p2, p3 to GRedgeptn
                08/26/88    deleted unused module information instance fields
	jhw	08/18/88    added GRdrop method
        mrm     02/17/89    removed GRdisplay override
                04/25/90    override GRclip
        scw     06/28/92    ANSI conversion
*/

class specification GRpa (2:0) of GRowner;

instance GRpa
{
    IGRboolean          update;         /* regenerate flag                   */
    IGRboolean          translation;    /* was xform simple translation?     */
    IGRdouble           dx;             /* pattern delta                     */
    IGRdouble           angle;          /* to apply to components            */
    IGRdouble           scale[3];       /* to apply to components            */
    IGRpoint            origin;         /* pattern origin                    */
    channel                             /* channel to LCcmd_iso which is     */
    {                                   /* linked to the pattern symbol      */
        (rel_ordered,                   /* definition header                 */
         initial = 1,
         increment = 1)
    }                   to_sym;
};

/*
 *  message declarations for GRpa
 */

/*
Name
        GRgenerate

Description
        This method generates the pattern, using whatever algorithm
        the subclasser sees fit, attatching the pattern components to
        the to_components inherited from GRcmpowner.

Return Values
        IGRlong msg == MSSUCC if successful
*/

message GRgenerate (IGRlong *msg; struct GRmd_env *mod);

/*
Name
        remove

Description
        This method is old and forgotten.

Return Values
        IGRlong msg == MSSUCC if successful
*/

/*
message remove (IGRlong *msg);
*/

/*
 *  message overrides for GRpa
 */

override    GRconstruct,                /* initialize instance data */
            GRdisyourself,              /* regenerate & pass to components */
            GRplotyourself,             /* regenerate & pass to components */
            GRxform,                    /* transform components w/o rtree */
                                        /* manipulations */
            GRcopy,                     /* keep components out of rtree */
            GRdelete,                   /* delete self and components */
            GRaddwrng,                  /* pass to master element */
            GRremwrng,                  /* pass to master element */
            GRlocate,                   /* disallow locate except through */
                                        /* master element's GRlocate_owner */
            GRlnproject,                /* pass to master element */
            GRapprojpt,                 /* pass to master element */
            GRptproject,                /* pass to master element */
            GRgetobjinfo,               /* pass to master element */
            GRmodify,                   /* pass to master element */
            GRgetrang,                  /* pass to master element */
            GRclipto,                   /* pass to master element */
            GRcoplanar,                 /* pass to master element */
            GRdetplane,                 /* pass to master element */
            GRinplane,                  /* pass to master element */
            GRkeypoint,                 /* pass to master element */
            GRprojpt,                   /* pass to master element */
            GRptdis,                    /* pass to master element */
            GRget_locate_properties,    /* disallow component location */
            GRclip,                     /* allow only for plotting */
            GRdrop;                     /* create gg of pattern elements */
/*
 *  message rejects for GRpa
 */

reject      GRgenerate;     /* not implemented at this level */
                                
end specification GRpa;
