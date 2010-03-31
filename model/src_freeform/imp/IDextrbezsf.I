/*
  DESCRIPTION
    
    This function extracts the Bezier surface patch that contains the 
    pole or row of poles input.   (It returns that portion of the
    surface which would be affected by manipulating the given pole or
    row of poles.)  This routine currently ignores boundaries. 

  ARGUMENTS

    The input curve can be specified in two ways:
    1) mattyp, mat and incrv_id can be specified, if the curve is
       known as an object.
    2) If the geometry of the curve is already knownm, this may be
       specified.
    The irrelevant arguments in either case can be NULL.

    The space for the output curve can be input or be allowed to be malloced
    by the function. This is checked by this function by looking at *outcrv.
    If the contents are NULL then this function mallocs the memory using
    BSallocsf (to be freed by the caller via BSfreecv), else the curve
    output buffer is assumed to be pointing to correct memory.

    pole_flag: (INPUT)      This tells the routine what the input pole
                (modpole) represents.  There are several possibilities:
                  0)  Pole is one of the poles in a U-Row which is being
                        manipulated.
                  1)  Pole is one of the poles in a V-Row which is being
                        manipulated.
                  2)  Pole is at intersection of U-Row and a V-Row, both
                        of which are being manipulated.  ( in this case,
                        original geometry is returned, since whole surface
                        will be affected.)
                  3)  Single pole which is being manipulated.

    opts:   (INPUT)     This is not yet used.


  HISTORY:
            8/27/91         AHC -   Creation Date - Wrote this function
                                    using code from GRdynmod method
                                    for EMSsubbs (surfaces).

                                    Also added capability to handle rows.


*/

class implementation GRvg;

# include "OMerrordef.h"
# include "igrdp.h"
# include "dpstruct.h"
# include "dpmacros.h"
# include "msdef.h"
# include "bserr.h"
# include "emsdef.h"
# include "emserr.h"
# include "EMSmsgdef.h"
#include "alloca.h"

#include "bsallocsf.h"   /* prototypes */
#include "bsactsplsf.h"   /* prototypes */
#include "bsunwght_p.h"   /* prototypes */
#include "maptpspro.h"   /* prototypes */
#include "IDextrbezsf.h"   /* prototypes */

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;
#define U_ROW		0
#define V_ROW		1
#define BOTH_U_V_ROWS	2	/* returns original geometry copied	*/
#define SINGLE_POLE	3

#argsused
                                /* pole_flag options:           */
	                        /*  0: u-row,                   */
                                /*  1: v-row,                   */
                                /*  2: both directions,         */
                                /*  3: single pole only         */
#if defined(__STDC__) || defined(__cplusplus)
    IGRlong IDextrbezsf(IGRlong *msg, 
        IGRushort opts, 
	IGRshort *mattyp, 
        IGRmatrix mat, 
        IGRpoint modpole, 
	IGRushort pole_flag, 
        struct IGRbsp_surface *insurf, 
	struct GRid *insurf_id, 
        struct IGRbsp_surface **outsurf)
#else
    IGRlong IDextrbezsf (   msg,  opts,  mattyp,  mat, 
                        modpole,  pole_flag,  insurf,  insurf_id,
                        outsurf)
        IGRlong                     *msg;
        IGRushort           	opts;
        IGRshort                    *mattyp;
        IGRmatrix                   mat;
        IGRpoint                    modpole;
        IGRushort           	pole_flag; 
        struct IGRbsp_surface       *insurf;
        struct GRid                 *insurf_id;
        struct IGRbsp_surface       **outsurf;
#endif
{


    IGRboolean                  stat_func;
    IGRlong                     stat_OM, msg_loc;
    IGRlong                     ptnum;
    IGRlong                     u_poleinx, v_poleinx, u_start_pl, v_start_pl;
    IGRlong                     u_end_pl, v_end_pl, u_start_kt, v_start_kt;
    IGRlong                     u_end_kt, v_end_kt;
    IGRlong                     u_np, v_np, u_nk, v_nk;
    IGRdouble                   *unweighted_poles; 
    IGRpoint                    point;
    struct IGRbsp_surface       *srf;
    struct IGRpointset          pointset;
    IGRlong                     num_bytes, sts;
    IGRdouble                   u_range[2], v_range[2];


    *msg = EMS_S_Success;
    stat_OM = OM_S_SUCCESS;

    srf = NULL;

    EMerr_hndlr (!insurf && (!mattyp || !mat || !insurf_id), *msg,
    	EMS_E_InvalidArg, ret_end);

    /* --------------------------------------------------------
     * Get this curves abstract geometry, if not already passed
     * in.
     * ------------------------------------------------------ */
    if (!insurf)
    {
	/* ------------------------------------	*/
        /* Compute the number of bytes required */
        /* We go through all this work so we    */
        /* don't have to malloc this memory -   */
        /* we'll be discarding it later anyway. */
        /* ------------------------------------	*/
        sts = om$send(
                msg = message GRvg.GRgetsize(
                &msg_loc, 
                mattyp,
                mat,
                &num_bytes), 
                senderid = NULL, 
                targetid = insurf_id->objid, 
                targetos = insurf_id->osnum); 
        EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);

        /* ----------------------------------------------------	*/
        /* Alloc the required memory off the stack (no malloc)	*/
        /* ----------------------------------------------------	*/
        insurf = (struct IGRbsp_surface *) alloca(num_bytes);
        if (!insurf)
        {
    	        *msg = MSFAIL; 
    	        goto ret_end;
        }


        /* ------------------------------------	*/
        /* Get the geometry			*/
        /* ------------------------------------	*/
        sts = om$send(
                msg = message GRvg.GRgetgeom(
                &msg_loc, 
                mattyp,
                mat,
                (IGRchar * ) insurf),
                senderid = NULL, 
                targetid = insurf_id->objid, 
                targetos = insurf_id->osnum); 
        EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);


    }


    /* --------------------------------------
    * Get the pole index of the pole closest
    * to the point that has been input. This
    * is the pole that will be modified.
    * --------------------------------------    */
    pointset.num_points = insurf->u_num_poles * insurf->v_num_poles;
    unweighted_poles = NULL;
    if (insurf->rational)
    {
        /* ------------------------------------------------------- */
        /* Poles have weights multiplied into them,                */
        /* so divide them out.                                      */
        /* ------------------------------------------------------- */
        /* use alloc instead  unweighted_poles = (IGRdouble *) om$malloc (
                size = pointset.num_points * sizeof(IGRpoint));
	*/
        unweighted_poles = (IGRdouble *) alloca ( 
                pointset.num_points * sizeof(IGRpoint));
        EMerr_hndlr(unweighted_poles==NULL, *msg, 
                EMS_E_NoDynamicMemory, ret_end);
        stat_func = BSunwght_p (&msg_loc, insurf->poles, insurf->weights,
                             &pointset.num_points, unweighted_poles);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

        pointset.points = unweighted_poles;
    }
    else
    {
        pointset.points = insurf->poles;
    }

    /* ------------------------------------------------------------------ */
    /* pass our pointset of poles into this routine to find out which one */
    /* is closest to the input modpole.                                   */
    /* ------------------------------------------------------------------ */
    stat_func = MAptpsproj (&msg_loc, modpole, &pointset, point, &ptnum);
    EMerr_hndlr (! stat_func || EMis_error (msg_loc), *msg, EMS_E_MAerror,
            ret_end);

    /*   Now we use alloca instead of om alloc, so no need to dealloc
        if (unweighted_poles) 
        {
            / * ----------------------------------------------------------- * /
            / * we only wanted unweighted poles so that we could find the   * /
            / * closest pole to the modpole.  Thus, now we can delete them. * /
            / * ----------------------------------------------------------- * /
            om$dealloc (ptr = unweighted_poles);
            unweighted_poles = NULL;
        }
    */

    /* ----------------------------------------- */
    /*  get u,v coordinates of pole              */
    /* ----------------------------------------- */
    u_poleinx = (ptnum - 1) % insurf->u_num_poles;
    v_poleinx = (ptnum - 1) / insurf->u_num_poles;


    /* ------------------------------------------
     * Get the pole and the knot
     * extents for that portion of
     * the surface that is affected
     * by the pole to be modified.
     * ------------------------------------------    */

    if(pole_flag == SINGLE_POLE)
    {
        u_start_pl = u_poleinx - (insurf->u_order - 1);
        v_start_pl = v_poleinx - (insurf->v_order - 1);
        u_end_pl = u_poleinx + (insurf->u_order - 1);
        v_end_pl = v_poleinx + (insurf->v_order - 1);
    }
    else
    if(pole_flag == U_ROW)
    {
        u_start_pl = u_poleinx - (insurf->u_order - 1);
        v_start_pl = 0;    
        u_end_pl = u_poleinx + (insurf->u_order - 1);
        v_end_pl = insurf->v_num_poles - 1;
    }    
    else
    if(pole_flag == V_ROW)
    {
        u_start_pl = 0;
        v_start_pl = v_poleinx - (insurf->v_order - 1);
        u_end_pl = insurf->u_num_poles - 1;
        v_end_pl = v_poleinx + (insurf->v_order - 1);
    }    
    else
    {
	/* ---------------------------- */
	/* return original geometry	*/
	/* ---------------------------- */
        u_start_pl = 0;
        v_start_pl = 0;

        u_end_pl = insurf->u_num_poles - 1;
        v_end_pl = insurf->v_num_poles - 1;
    }    

    /* ------------------------------------ */
    /* Make sure we have valid pole ranges  */
    /* ------------------------------------ */
    if (u_start_pl < 0) u_start_pl = 0;
    if (v_start_pl < 0) v_start_pl = 0;
    if (v_end_pl > insurf->v_num_poles - 1) 
            v_end_pl = insurf->v_num_poles - 1;
    if (u_end_pl > insurf->u_num_poles - 1) 
            u_end_pl = insurf->u_num_poles - 1;

    u_start_kt = u_start_pl;
    u_end_kt = u_end_pl + insurf->u_order;
    v_start_kt = v_start_pl;
    v_end_kt = v_end_pl + insurf->v_order;


    u_np = u_end_pl - u_start_pl + 1;
    u_nk = u_np + insurf->u_order;
    v_np = v_end_pl - v_start_pl + 1;
    v_nk = v_np + insurf->v_order;

    /* ------------------------------------------------------
     * The resulting boundaries on this patch (clipped set of
     * the original) boundaries should be computed here.
     * ----------------------------------------------------- */

    /* ------------------------------------------------------
     * Allocate space for the surface-patch
     * that is the affected portion 
     * of this surface. Fill this patch
     * with relevant data.
     * ---------------------------------------------------   */
    if (!*outsurf)
    {
        BSallocsf (insurf->u_order, insurf->v_order, insurf->u_num_poles, 
            insurf->v_num_poles, 
            insurf->rational, insurf->num_boundaries, outsurf, &msg_loc);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_NoDynamicMemory, ret_end);
    }
    srf = *outsurf;

    u_range[0] =  insurf->u_knots[u_start_kt];
    u_range[1] =  insurf->u_knots[u_end_kt];
    v_range[0] =  insurf->v_knots[v_start_kt];
    v_range[1] =  insurf->v_knots[v_end_kt];

    /* ------------------------------------------------------------ */
    /* options for BSactsplsf:  0 means split in u direction,       */
    /*                          1 means split in v direction,       */
    /*                          2 means split in both directions.   */
    /* ------------------------------------------------------------ */
    BSactsplsf(insurf, u_range, v_range, 2, srf, &msg_loc);
    if(msg_loc != BSSUCC)
    {
    }


ret_end:
    EMWRAPUP (*msg, stat_OM, "EMsubbs.EMdynmod");
    return (stat_OM);
}

end implementation GRvg;
