/* #######################    APOGEE COMPILED   ######################## */

/*
Name
        GRareaptn.GRgenerate

Description
        This method generates a pattern of symbols on the closed element
        assumed to be at position zero of the inherited to_components channel,
        using the symbol assumed to be at position one of the same channel.
        The pattern is clipped at the edge of the closed element.

History
        sdm     04/01/87    creation
        mrm     12/01/87    subclassing changes & upgrades
                09/22/88    call GRangle_grid for nonzero patterning angles
                10/05/88    change for 1.2 clipping format
        scw     06/30/92    ANSI conversion
*/

class implementation GRareaptn;


#include "grimport.h"
#ifdef DEBUG
#include <stdio.h>
#endif
#include "msdef.h"
#include "bs.h"
#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "godef.h"
#include "gocmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grsymmacros.h"
#include "grerr.h"

#define MAXPTS      100

extern IGRint   GRapgrid();         /* function to get symbol origins */
extern IGRint   GRangle_grid();     /* function to get symbol origins */
extern double   fabs();             /* returns absolute value */

method GRgenerate (IGRlong *msg; struct GRmd_env *mod)
{
    IGRchar             classname[30];  /* of the symbol to construct */
    IGRchar            *pts_ptr;
    IGRchar            *symbol_ptr;
    IGRboolean          more;           /* flag from GRapgrid() */
    IGRboolean          first;          /* flag to GRapgrid() */
    IGRboolean          world;          /* get range in local coords */
    IGRboolean          bsts;           /* return code */
    IGRshort            wtv_mxtype;     /* world-to-view matrix type */
    IGRshort            vtw_mxtype;     /* view-to-world matrix type */
    IGRint              i;              /* index */
    IGRint              symbols_placed; /* counter for symbol plecement */
    IGRint              maxpts;         /* origins to generate at one time */
    IGRlong             npts;           /* counter for points */
    IGRlong             sts;            /* return code */
    IGRlong             clip_flags;     /* indicators for clip method */
    IGRlong             index;          /* to connect clipped symbols */
    IGRdouble           master_range[6];/* master range */
    IGRdouble           sdh_range[6];   /* sdh range */
    IGRdouble           wtv[16];        /* world-to-view rotation matrix */
    IGRdouble           vtw[16];        /* world-to-view rotation matrix */
    IGRdouble           dx, dy;         /* pattern deltas */
    IGRpoint            *pts;           /* symbol origins */
    struct GRmd_env     comp_mod;       /* in which to construct the symbols */
    struct GRid         *symbol;        /* latest symbols constructed */
    struct GRid         mygrid;         /* my id & os */
    struct GRid         sdh;            /* to use in constructing symbols */
    struct IGRcv_prism  prism;          /* to clip the pattern */
    struct IGRbsp_curve *curve;         /* local copy of master's curve */
    struct IGRbsp_curve *prism_curve;   /* master's curve in prism coords */
    OM_S_CHANSELECT     comp_chan;      /* to master & components */
    OM_S_CHANSELECT     sdh_chan;       /* to symbol definition header */


#ifdef DEBUG
    int                 clip_the_symbols = 1;
    long                curr, prev;
    FILE                *cf;

    prev = clock();
    if (cf = fopen ("clipsym", "r"))
    {
        fscanf (cf, "%d", &clip_the_symbols);
        fclose (cf);
    }
#endif


    /*
     *  initialization
     */

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;
    curve = NULL;
    prism_curve = NULL;
    pts = NULL;
    pts_ptr = (IGRchar *)NULL;
    symbol = NULL;
    symbol_ptr = (IGRchar *)NULL;
    index = OM_K_MAXINT;
    mygrid.objid = my_id;
    mygrid.osnum = OM_Gw_current_OS;
    comp_mod = *mod;
    comp_mod.md_id.objid = NULL_OBJID;

    sts = om$make_chanselect (channame = "GRcmpowner.to_components",
                              p_chanselect = &comp_chan);

    if (!(sts & 1)) goto finish;
        
    sts = om$make_chanselect (channame = "GRpa.to_sym",
                              p_chanselect = &sdh_chan);

    if (!(sts & 1)) goto finish;
        
    /*
     *  check the update flag
     */

    if (me->update)
    {
        /*
         *  delete the old pattern components
         */

        sts = GRpadelcomp (msg, &mygrid, &comp_chan, &comp_mod);

        if (!(sts & *msg & 1))
        {
#ifdef DEBUG
            printf ("GRapgen: GRpadelcomp failed\n");
#endif
            goto finish;
        }

        me->update = FALSE;
    }

    /*
     *  get the id of the symbol definition to construct from, its range,
     *  and the classname to construct
     */

    sts = GRpagetsdh (msg, &my_id, &sdh_chan, mod, &sdh, sdh_range, classname);

    if (!(sts & *msg & 1)) goto finish;

#ifdef DEBUG
    printf ("GRapgen: sdh extents = %g, %g, %g; %g, %g, %g\n",
             sdh_range[0], sdh_range[1], sdh_range[2],
             sdh_range[3], sdh_range[4], sdh_range[5]);
#endif

    /*
     *  set the pattern deltas -- if either delta is zero, use the sdh's
     *  extent in that direction; then multiply by the scale in that direction
     */

    dx = (me->dx) ? me->dx : fabs (sdh_range[3] - sdh_range[0]);
    dy = (me->dy) ? me->dy : fabs (sdh_range[4] - sdh_range[1]);

    dx *= (me->scale[0]) ? me->scale[0] : 1.0;
    dy *= (me->scale[1]) ? me->scale[1] : 1.0;

#ifdef DEBUG
    printf ("GRapgen: dx = %g, dy = %g\n", dx, dy);
#endif

    /*
     *  get the world-to-view rotation matrix
     */

    sts = GRpagetvwmx (msg, wtv, &wtv_mxtype, vtw, &vtw_mxtype);
    if (!(sts & *msg & 1)) goto finish;



    /*
     *  get the range of the master element in the view coordinate system;
     *  GRgetrang thinks that the input matrix is the environment matrix, but
     *  combining the env matrix with the world-to-view actually converts
     *  database coordinates to view
     *
     *  NOTE: combine env with wtv when patterning in reference files is
     *  implemented
     */

    world = TRUE;

    sts = om$send (msg = message GRvg.GRgetrang
                        (msg, &wtv_mxtype, wtv, &world, master_range),
                   p_chanselect = &comp_chan,
                   from = 0,
                   to = 0);

    if (!(sts & *msg & 1)) goto finish;

    if (me->angle)
    {
        /*
         *  get a copy of the curve for GRangle_grid
         */

        sts = GRpagetcv (msg, &my_id, &comp_chan, mod, &curve);
        if (!(sts & *msg & 1)) goto finish;
    }

    /*
     *  get a copy of the abstract geometry (B-spline curve)
     *  of the master object to use in the clipping prism
     */

    sts = GRpagetcv (msg, &my_id, &comp_chan, mod, &prism_curve);
    if (!(sts & *msg & 1)) goto finish;

    /*
     *  construct the prism used to clip the pattern
     */

    sts = GRbuild_cvprism (msg, wtv, vtw, me->origin, sdh_range, prism_curve,
                           &prism);

    if (!(sts & *msg & 1)) goto finish;

    /*
     *  allocate for the symbol origins and ids
     */

    i = ((master_range[3] - master_range[0]) / dx) + 3;
    maxpts = (i > MAXPTS) ? i : MAXPTS;

    pts_ptr = om$malloc (size = (maxpts * sizeof (IGRpoint)));
    symbol_ptr = om$malloc (size = (maxpts * sizeof (struct GRid)));

    pts = (IGRpoint *)pts_ptr;
    symbol = (struct GRid *)symbol_ptr;

    if (!pts || !symbol)
    {
#ifdef DEBUG
        printf ("GRapgen: om$malloc failed; maxpts = %d\n", maxpts);
#endif
        *msg = MANOMEMORY;
        goto finish;
    }

    more = TRUE;
    first = TRUE;
    symbols_placed = 0;
    clip_flags = GR_CLIP_OVL_IN | GR_CLIP_RIGID;



    while (more)    
    {
        if (me->angle)
        {
            bsts = GRangle_grid (msg, curve, me->angle, &wtv_mxtype, wtv,
                                 &vtw_mxtype, vtw, me->origin, master_range,
                                 dx, dy, first, maxpts, &more, &npts, pts);
            if (!(bsts & *msg & 1)) goto finish;
        }
        else
        {
            bsts = GRapgrid (msg, &wtv_mxtype, wtv, &vtw_mxtype, vtw,
                             me->origin, master_range, dx, dy, first, maxpts,
                             &more, &npts, pts);

           if (!(bsts & *msg & 1)) goto finish;

            /*
             * transform the points back to world coordinates.  this used
             * to be done in GRapgrid.
             */
            if (!(MAoptsxform (msg, &npts, &vtw_mxtype, vtw, pts, pts)))
              {
           #ifdef DEBUG
               printf ("GRangle_grid: MAoptsxform failed\n");
           #endif   
               goto finish;
              }


        }



#ifdef DEBUG
        printf ("GRapgen: GR__grid returned %d points\n", npts);
        curr = clock();
        printf ("GRapgen: setup time =     %10d\n", curr - prev);
        prev = curr;
#endif

        first = FALSE;

        sts = gr$sym_sm_place (msg = msg,
                               num_symbols = npts,
                               origin = pts,
                               angle = &me->angle,
                               scale = me->scale,
                               rot_matrix = wtv,
                               properties = GRIS_NEW | GRIS_DISPLAYABLE,
                               level = 0, /* moved to proper level in chsym */
                               symbol_env = mod,
                               target_env = &comp_mod,
                               classname = classname,
                               sdh_id = &sdh,
                               sm_id = symbol);

        if (!(sts & *msg & 1))
        {
#ifdef DEBUG
            printf ("GRapgen: gr$sym_sm_place failed\n");
#endif
            goto finish;
        }

#ifdef DEBUG
        curr = clock();
        printf ("GRapgen: placement time = %10d\n", curr - prev);
        prev = curr;
#endif

        for (i = 0; i < npts; i++)
        {
#ifdef DEBUG
            if (clip_the_symbols)
            {
#endif
                /*
                 *  clip the symbols
                 */

                sts = GRclip_connect (msg, &comp_mod, &comp_mod, &prism,
                                      &mygrid, NULL, NULL, &clip_flags,
                                      &index, &symbol[i]);
#ifdef DEBUG
            }
            else
            {
                /*
                 *  debug - just attach the unclipped symbols to the channel
                 */
                sts = om$send (msg = message GRconnector.GRrigidconn
                                    (msg, &mygrid, &index),
                               targetid = symbol[i].objid,
                               targetos = symbol[i].osnum);
            }
#endif
            if (!(sts & *msg & 1))
            {
#ifdef DEBUG
                printf ("GRapgen: GRclip_connect failed\n");
#endif
                goto finish;
            }
        }

#ifdef DEBUG
        curr = clock();
        printf ("GRapgen: clipping time =  %10d\n", curr - prev);
        prev = curr;
#endif
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

    /*
     *  deallocate storage
     */

    if (curve) om$dealloc (ptr = curve);
    if (prism_curve) om$dealloc (ptr = prism_curve);
    if (pts) om$dealloc (ptr = pts); 
    if (symbol) om$dealloc (ptr = symbol); 

#ifdef DEBUG
    if (!(*msg & 1)) printf ("GRapgen: msg = 0x%x\n", *msg);
    if (!(sts & 1))  om$report_error (sts = sts);
#endif
            
    return (sts);
}

end implementation GRareaptn;
