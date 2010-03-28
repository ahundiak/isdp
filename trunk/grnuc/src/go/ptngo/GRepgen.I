/* #######################    APOGEE COMPILED   ######################## */

/*
Name
        GRedgeptn.GRgenerate

Description
        This method generates a pattern along the edge of an element.  The
        pattern consists of symbols placed with their local x-axis tangent
        to the element at the symbol's origin and their local z-axis parallel
        to the view z-axis.

History
        sdm     04/01/87    creation
        mrm     11/02/87    subclassing changes
                05/24/88    clip symbols at start & stop points
        scw     06/28/92    ANSI conversion
*/

class implementation GRedgeptn;

#include "grimport.h"
#include "bsvalues.h"
#include "msdef.h"
#include "bs.h"
#include "igrdef.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "godef.h"
#include "OMminimum.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grsymmacros.h"

#define MAXPTS      100     /* max pts for symbol origins allocated here */
#define TOLERANCE   0.5     /* tolerance for projection */
#define LEFT        1
#define RIGHT       0

extern IGRboolean MAtrnmx();    /* function to transpose a matrix */


method GRgenerate (IGRlong *msg; struct GRmd_env *mod)
{
    IGRchar             classname[20];  /* of pattern components */
    IGRboolean          on_curve;       /* flag from BS routine */
    IGRboolean          pts_alloc;      /* flag from BS routine */
    IGRboolean          have_prism;     /* flag for stop pt clipping prism */
    IGRboolean          ascending_u;    /* is pattern direction increasing u */
    IGRshort            ii;             /* index */
    IGRint              i;              /* index */
    IGRint              symbols_needed; /* to completely pattern element */
    IGRint              symbols_placed; /* counter of total placed */
    IGRint              clips;          /* clips needed at start & stop pts */
    IGRlong             sts;            /* return code */
    IGRlong             clip_flags;     /* indicators for clipping */
    IGRlong             index;          /* to hook symbols to channel */
    IGRdouble           u;              /* B-spline u-parameter */
    IGRdouble           tol;            /* projection tolerance */
    IGRdouble           sdh_range[6];   /* extents of symbol */
    IGRdouble           dx;             /* delta for symbol placement */
    IGRdouble           clip_box[15];   /* sides of clipping box */
    IGRdouble           xlen, ylen;     /* lengths of symbol's range box */
    IGRdouble           len;            /* xlength of rotated symbol */
    IGRpoint            start_pt;       /* working start point*/
    IGRpoint            dir_pt;         /* working direction point*/
    IGRpoint            stop_pt;        /* last symbol origin */
    IGRpoint            pts[MAXPTS];    /* symbol origins */
    IGRpoint            nxtpt[3];       /* returned from math routine */
    IGRpoint            *bspts;         /* points may be allocated by BS */
    IGRpoint            *origin;        /* of a symbol */
    IGRmatrix           wtv;            /* world-to-view rotation matrix */
    IGRmatrix           rot_mx;         /* symbol placement rotation matrix */
    IGRmatrix           first_mx;       /* first symbol pl mx - for clipping */
    struct GRid         mygrid;         /* of me */
    struct GRid         sdh;            /* to pattern with */
    struct GRid         *symbol;        /* points to list of placed symbols */
    struct GRmd_env     comp_mod;       /* NULL id for Rtree restrictions */
    struct IGRrt_prism  prism;          /* for clipping symbols */
    struct IGRbsp_curve *curve;         /* abstract geometry of master obj */
    OM_S_CHANSELECT     comp_chan;      /* channel to pattern components */
    OM_S_CHANSELECT     sdh_chan;       /* to symbol definition header */

    /*
     *  initialization
     */

    sts = OM_S_SUCCESS;
    *msg = MSSUCC;

    tol = TOLERANCE;
    mygrid.objid = my_id;
    mygrid.osnum = OM_Gw_current_OS;
    comp_mod = *mod;
    comp_mod.md_id.objid = NULL_OBJID;
    have_prism = FALSE;
    pts_alloc = NULL;
    curve = NULL;
    symbol = NULL;

    sts = om$make_chanselect (channame = "GRcmpowner.to_components",
                              p_chanselect = &comp_chan);
    if (!(sts & 1)) goto finish;

    sts = om$make_chanselect (channame = "GRpa.to_sym",
                              p_chanselect = &sdh_chan);
    if (!(sts & 1)) goto finish;
        
    /*
     *  get the world-to-view rotation matrix
     */

    sts = GRpagetvwmx (msg, wtv, NULL, NULL, NULL);
    if (!(sts & *msg & 1)) goto finish;

    /*
     *  get the sdh id to construct from and classname to construct
     */

    sts = GRpagetsdh (msg, &my_id, &sdh_chan, mod, &sdh, sdh_range, classname);
    if (!(sts & *msg & 1)) goto finish;

    /*
     *  get the lengths of the symbol's range box (including the "length"
     *  of the rotated box; the box's rotated x-range)
     */

    xlen = fabs (sdh_range[3] - sdh_range[0]);
    ylen = fabs (sdh_range[4] - sdh_range[1]);
    len = (ylen * cos ((M_PI/2) - me->angle)) + (xlen * cos (me->angle));

    /*
     *  get the pattern delta
     */

    dx = (me->dx) ? me->dx : xlen;

    if (me->scale[0])
        dx *= me->scale[0];

#ifdef DEBUG
    printf ("GRepgen: dx = %g\n", dx);
#endif

    /*
     *  get a copy of the abstract geometry (B-spline curve)
     *  of the master object
     */

    sts = GRpagetcv (msg, &my_id, &comp_chan, mod, &curve);
    if (!(sts & *msg & 1)) goto finish;

    if (!me->update)
    {
        /*
         *  this is the first time the pattern has been generated, so
         *  calculate the start, stop & direction u-parameters on the curve
         *  from the points indicated by the user
         */

        sts = MAptbcproj (msg, me->origin, curve, &tol,
                          start_pt, &me->start_parm.u);
        if (!(sts & *msg & 1)) goto finish;

        sts = MAptbcproj (msg, me->dir_pt, curve, &tol,
                          dir_pt, &me->dir_parm.u);
        if (!(sts & *msg & 1)) goto finish;

        sts = MAptbcproj (msg, me->stop_pt, curve, &tol,
                          stop_pt, &me->stop_parm.u);
        if (!(sts & *msg & 1)) goto finish;
    }
    else
    {
        /*
         *  delete the old components
         */

        sts = GRpadelcomp (msg, &mygrid, &comp_chan, &comp_mod);

        if (!(sts & *msg & 1))
        {
#ifdef DEBUG
            printf ("GRepgen: GRpadelcomp failed\n");
#endif
            goto finish;
        }
 
        me->update = FALSE;
    }

#ifdef DEBUG
    printf ("GRepgen: me->start_parm.u = %g\n", me->start_parm.u);
    printf ("GRepgen: me->dir_parm.u   = %g\n", me->dir_parm.u);
    printf ("GRepgen: me->stop_parm.u  = %g\n", me->stop_parm.u);
#endif

    /*
     *  does the pattern run in increasing u?
     */

    sts = GRepudir (msg, curve, &me->start_parm, &me->dir_parm,
                    &me->stop_parm, &ascending_u);

    /*
     *  get the origins for the symbols at equally spaced intervals on the
     *  master curve; this BS routine will allocate the points if the
     *  array passed in is not big enough.
     */

    /*  check for boundary condition cases... */
    if(me->start_parm.u == me->stop_parm.u)	{
	    double add_tol=0.00001;

	    if(me->stop_parm.u+add_tol > 1.0)
		add_tol = -add_tol;

	    BSeqdptscv (curve, me->start_parm.u, me->dir_parm.u, 
		me->stop_parm.u+add_tol, dx, 1, pts, &pts_alloc, &symbols_needed, 
		&bspts, msg);
	    symbols_needed=1;

    }
    else

	    BSeqdptscv (curve, me->start_parm.u, me->dir_parm.u, me->stop_parm.u, dx,
                MAXPTS, pts, &pts_alloc, &symbols_needed, &bspts, msg);

    if (*msg != BSSUCC)
    {
#ifdef DEBUG
        printf ("GRepgen: BSeqdptscv failed\n");
#endif
        goto finish;
    }

#ifdef DEBUG
    printf ("GRepgen: symbols_needed = %d\n", symbols_needed);
#endif

    /*
     *  allocate for symbol list
     */

    symbol = (struct GRid *)om$malloc 
                            (size = (symbols_needed * sizeof (struct GRid)));
    if (!symbol)
    {
#ifdef DEBUG
        printf ("GRepgen: om$malloc for symbol list failed\n");
#endif
        *msg = MANOMEMORY;
        sts = OM_E_NODYNMEM;
        goto finish;
    }

    origin = (pts_alloc) ? bspts : pts;
    symbols_placed = 0;
    rot_mx[3]  = rot_mx[7]  = rot_mx[11] = 0.0;
    rot_mx[12] = rot_mx[13] = rot_mx[14] = 0.0;
    rot_mx[15] = 1.0;

    while (symbols_needed > symbols_placed)
    {
        /*
         *  build a placement matrix for the symbol; the x-axis
         *  of the matrix will be tangent to the curve at u, the
         *  y-axis will be normal, and the z-axis will be x cross y
         */

        /* get the u-parameter of the curve at origin */

        BSprptoncv (msg, curve, origin, &u, &on_curve);
        if (*msg != BSSUCC) goto finish;

        /* get unit vector tangent to curve at u */

        sts = MAuvctnbc (msg, curve, &u, nxtpt, rot_mx);
        if (!(sts & *msg & 1)) goto finish;

        /* get unit vector normal to curve at u */

        sts = MAuvcnrbc (msg, curve, &u, &wtv[8], &rot_mx[4]);
        if (!(sts & *msg & 1)) goto finish;

        /* cross x and y to get z, unitize z */

        sts = MAcrossvc (msg, rot_mx, &rot_mx[4], &rot_mx[8]);
        if (!(sts & *msg & 1)) goto finish;

        sts = MAunitvc (msg, &rot_mx[8], &rot_mx[8]);
        if (!(sts & *msg & 1)) goto finish;

        /*
         *  place the symbol
         */

        sts = gr$sym_sm_place (msg = msg,
                               num_symbols = 1,
                               origin = origin,
                               angle = &me->angle,
                               scale = me->scale,
                               rot_matrix = rot_mx,
                               properties = GRIS_NEW | GRIS_DISPLAYABLE,
                               level = 0, /* moved to proper level in chsym */
                               symbol_env = mod,
                               target_env = &comp_mod,
                               classname = classname,
                               sdh_id = &sdh,
                               sm_id = &symbol[symbols_placed]);

        if (!(sts & *msg & 1))
        {
#ifdef DEBUG
            printf ("GRepgen: gr$sym_sm_place failed\n");
#endif
            goto finish;
        }

#ifdef DEBUG
        printf ("%5d%20.10f%20.10f%20.10f%15.10f\n", symbols_placed,
                origin[0][0], origin[0][1], origin[0][2], u);
#endif

        if (symbols_placed == 0)
        {
            /* save first placement matrix for clip */

            for (i = 0; i < 16; i++) first_mx[i] = rot_mx[i];
        }

        /*
         *  increment counters
         */

        symbols_placed++;
        origin++;
    }

    /*
     *  clip at start point
     */

    clips = (IGRint) ceil (len / dx);

#ifdef DEBUG
    printf ("GRepgen: clips = %d\n", clips);
#endif

    ii = 4;
    sts = MAtrnmx (msg, &ii, first_mx, prism.matrix);
    if (!(sts & *msg & 1)) goto finish;

    sts = GRbuildbox (msg, (ascending_u) ? LEFT : RIGHT, xlen, ylen, clip_box);

    origin = (pts_alloc) ? bspts : pts;
    prism.matrix[3]  = origin[0][0];
    prism.matrix[7]  = origin[0][1];
    prism.matrix[11] = origin[0][2];
    prism.polygon.num_points = 5;
    prism.polygon.points = clip_box;
    prism.height = sdh_range[5] - sdh_range[2];
    clip_flags = GR_CLIP_RTPRISM | GR_CLIP_RIGID;
    index = OM_K_MAXINT;

    for (i = 0; i < clips; i++)
    {
#ifdef DEBUG
        printf ("GRepgen: calling clip #1 with symbol %d\n", i);
#endif
        sts = GRclip_connect (msg, &comp_mod, &comp_mod, &prism,
                              NULL, &mygrid, NULL, &clip_flags,
                              &index, &symbol[i]);
        if (!(sts & *msg & 1))
        {
#ifdef DEBUG
            printf ("GRepgen: GRclip_connect #1 (%d) failed\n", i);
#endif
/*            goto finish; */
        }
    }

    /*
     *  clip at stop point
     */

    u = me->stop_parm.u;

    sts = MAidmx (msg, prism.matrix);

    sts = MAuvctnbc (msg, curve, &u, nxtpt, prism.matrix);
    if (!(sts & *msg & 1)) goto finish;

    sts = MAuvcnrbc (msg, curve, &u, &wtv[8], &prism.matrix[4]);
    if (!(sts & *msg & 1)) goto finish;

    sts = MAcrossvc (msg, prism.matrix, &prism.matrix[4], &prism.matrix[8]);
    if (!(sts & *msg & 1)) goto finish;

    sts = MAunitvc (msg, &prism.matrix[8], &prism.matrix[8]);
    if (!(sts & *msg & 1)) goto finish;

    ii = 4;
    sts = MAtrnmx (msg, &ii, prism.matrix, prism.matrix);
    if (!(sts & *msg & 1)) goto finish;

    sts = GRbuildbox (msg, (ascending_u) ? RIGHT : LEFT, xlen, ylen, clip_box);

    prism.matrix[3]  = stop_pt[0];
    prism.matrix[7]  = stop_pt[1];
    prism.matrix[11] = stop_pt[2];

    /* NOTE -- 1 extra symbol is clipped at the stop point, to catch */
    /* symbols generated completely past the stop point.             */

    for (i = symbols_needed - clips - 1; i < symbols_needed; i++)
    {
#ifdef DEBUG
        printf ("GRepgen: calling clip #2 with symbol %d\n", i);
#endif
        sts = GRclip_connect (msg, &comp_mod, &comp_mod, &prism,
                              NULL, &mygrid, NULL, &clip_flags,
                              &index, &symbol[i]);
        if (!(sts & *msg & 1))
        {
#ifdef DEBUG
            printf ("GRepgen: GRclip_connect #2 (%d) failed\n", i);
#endif
/*          goto finish; */
        }
    }

    /*
     *  hook all other symbols rigidly on the to_components channel, along
     *  with the clipped symbols
     */

    index = OM_K_MAXINT;

    for (i = clips; i < symbols_needed - clips - 1; i++)
    {
        sts = om$send (msg = message GRconnector.GRrigidconn
                            (msg, &mygrid, &index),
                       targetid = symbol[i].objid,
                       targetos = symbol[i].osnum);

        if (!(sts & *msg & 1))
        {
#ifdef DEBUG
            printf ("GRepgen: GRconnector.GRrigidconn (%d) failed\n", i);
#endif
            goto finish;
        }
    }

    /*
     *  change the pattern's display symbology to that of the master element
     */

    sts = GRpachsym (msg, &my_id, &comp_chan);

    if (!(sts & *msg & 1))
    {
#ifdef DEBUG
        printf ("GRepgen: GRpachsym failed\n");
#endif
        goto finish;
    }

finish:

    if (pts_alloc) om$dealloc (ptr = bspts);
    if (curve) om$dealloc (ptr = curve);
    if (symbol) om$dealloc (ptr = symbol);

#ifdef DEBUG
    if (!(*msg & 1)) printf ("GRepgen: msg = 0x%x\n", *msg);
    if (!(sts & 1))  om$report_error (sts = sts);
#endif
            
    return (sts);
}

end implementation GRedgeptn;
