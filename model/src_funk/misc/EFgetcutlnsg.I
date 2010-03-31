/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

/*
  ABSTRACT:  This function finds all the line segments defined by the input
             cutting plane line element.

  HISTORY
         
    WBC      09/21/91      Creation date.
    Sudha    07/08/93      Modified for BSprototypes ansification

*/

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfintdef.h"
#include "bsparameters.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "bserr.h"
#include "EMSprop.h"
#include "EMSxsection.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"    /* needed for gocmacros.h */
#include "EMSopt.h"
#include "bs.h"
#include "EMSobjmgr.h"
#include "EMSobjmgrdef.h"
#include "madef.h"
#include "maunitvc.h"
#include "bsdotp.h"

struct seg_struct
{
    IGRint    num_segments;
    IGRdouble *segments;
};

extern OMuword  OPP_GRcompcurve_class_id,
                OPP_GRlinear_class_id;


IGRlong EFget_cut_line_segs(EMmsg, line_grid, md_env, num_segments, segments)

IGRlong                *EMmsg;         /* Output:  function return message */
struct GRid            *line_grid;     /* Input:  cutting plane line object
                                          (can be a composite curve) */
struct GRmd_env        *md_env;        /* Input:  module environment of the
                                          line object */
IGRint                 *num_segments;  /* Output:  the number of line segments
                                          returned in segments; there will be
                                          two points for each segment */
IGRpoint               **segments;     /* Output:  memory for these points
                                          will be allocated within this
                                          function using om$malloc; it is the
                                          caller's responsibility to deallocate
                                          the memory using om$dealloc */
{
    OM_S_CHANSELECT	        to_cmpnt_chan;
    struct     IGRbsp_curve     *cmpnt_gm = NULL;
    struct     GRid             cmpnt_GRid;
    struct     seg_struct       *line_segs;
    IGRlong                     OM_stat, mthd_stat, cmpnt_size;
    IGRint                      cmpnt_inx, cmpnt_buf_size = 0, sg_inx, i,
                                current_segment;
    OMuword                     line_classid;
    OMuint                      num_cmpnts;
    IGRboolean                  xs_pf_cm_cv;
    IGRchar                     *char_ptr = NULL;

    OM_stat = OM_S_SUCCESS;
    *EMmsg = EMS_S_Success;

    /* Determine if the cutting plane line is a composite curve */

    OM_stat = om$get_classid (osnum = line_grid->osnum,
                              objid = line_grid->objid,
                              p_classid = &line_classid);
    EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

    OM_stat = om$is_ancestry_valid(subclassid = line_classid,
                                   superclassid = OPP_GRcompcurve_class_id);
    EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

    if (OM_stat == OM_S_SUCCESS)
    {
        OM_stat = EMmake_chanselect (GRcmpowner_to_components, &to_cmpnt_chan);
        EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

        OM_stat = om$get_channel_count(osnum = line_grid->osnum,
                                       objid = line_grid->objid,
                                       p_chanselect = &to_cmpnt_chan,
                                       count = &num_cmpnts);
        EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

        xs_pf_cm_cv = TRUE;

    } /* if (OM_stat == OM_S_SUCCESS) */
    else
    {
        OM_stat = om$is_ancestry_valid(subclassid = line_classid,
                                       superclassid = OPP_GRlinear_class_id);
        EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

        if (OM_stat == OM_S_SUCCESS)
        {
            num_cmpnts = 1;
            xs_pf_cm_cv = FALSE;
        }
        else
        {
            *EMmsg = EMS_E_InvalidArg;
            goto wrapup;
        }
    }

    /* allocate space to hold an array of pointers to points for each component
     */

    line_segs = NULL;
    line_segs = (struct seg_struct *) alloca(num_cmpnts *
                                                  sizeof(struct seg_struct));

    if (! line_segs)
    {
        *EMmsg = EMS_E_NoStackMemory;
        goto wrapup;
    }

    *num_segments = 0;
    *segments = NULL;

    for (cmpnt_inx = 0; cmpnt_inx < num_cmpnts; cmpnt_inx++)
    {
        line_segs[cmpnt_inx].num_segments = 0;

        if (xs_pf_cm_cv)
        {
            OM_stat = om$get_objid_at_index(osnum = line_grid->osnum,
                                            objid = line_grid->objid,
                                            p_chanselect = &to_cmpnt_chan,
                                            index = cmpnt_inx,
                                            objidaddr = &cmpnt_GRid.objid,
                                            osnumaddr = &cmpnt_GRid.osnum);
            EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

            OM_stat = om$get_classid (osnum = cmpnt_GRid.osnum,
                                      objid = cmpnt_GRid.objid,
                                      p_classid = &line_classid);
            EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

            OM_stat = om$is_ancestry_valid(subclassid = line_classid,
                                           superclassid = OPP_GRlinear_class_id);
            EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

            if (OM_stat != OM_S_SUCCESS)
            {
                *EMmsg = EMS_E_InvalidArg;
                goto wrapup;
            }
        } /* if (xs_pf_cm_cv) */
        else
            cmpnt_GRid = *line_grid;

        OM_stat = om$send (msg = message GRvg.GRgetsize (&mthd_stat,
                                                &md_env->md_env.matrix_type,
                                                md_env->md_env.matrix,
                                                &cmpnt_size),
                         senderid = NULL_OBJID,
                         targetid = cmpnt_GRid.objid,
                         targetos = cmpnt_GRid.osnum);
        EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

        if (!cmpnt_buf_size)
            char_ptr = (IGRchar *) alloca(cmpnt_size);
        else if (cmpnt_size > cmpnt_buf_size)
            char_ptr = (IGRchar *) alloca(cmpnt_size);

        if (cmpnt_size > cmpnt_buf_size)
            cmpnt_buf_size = cmpnt_size;
        cmpnt_gm = (struct IGRbsp_curve *) char_ptr;

        OM_stat = om$send (msg = message GRvg.GRgetgeom (&mthd_stat,
                                                &md_env->md_env.matrix_type,
                                                md_env->md_env.matrix,
                                                char_ptr),
                         senderid = NULL_OBJID,
                         targetid = cmpnt_GRid.objid, 
                         targetos = cmpnt_GRid.osnum);
        EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

        /*
         * The component will be used for cross_section plane only
         * if it is of order 2 and is not rational.
         */

        if (cmpnt_gm->order == 2 && !cmpnt_gm->rational)
        {
            /* allocate memory for the maximum number of line segments */

            line_segs[cmpnt_inx].segments = NULL;
            line_segs[cmpnt_inx].segments = (IGRdouble *) alloca((cmpnt_gm->num_poles - 1) *
                                                       sizeof(IGRdouble) * 6);

            if (! line_segs[cmpnt_inx].segments)
            {
                *EMmsg = EMS_E_NoStackMemory;
                goto wrapup;
            }

            for (sg_inx = 0; sg_inx < cmpnt_gm->num_poles-1; sg_inx++)
            {
                OM_BLOCK_MOVE(&cmpnt_gm->poles[3 * sg_inx],
                    &(line_segs[cmpnt_inx].segments[line_segs[cmpnt_inx].num_segments * 6]),
                    sizeof(IGRdouble) * 6);
                (line_segs[cmpnt_inx].num_segments)++;
                (*num_segments)++;
            }
        } /* if (cmpnt_gm->order == 2 && !cmpnt_gm->rational) */

    } /* for (cmpnt_inx = 0; cmpnt_inx < num_cmpnts; cmpnt_inx++) */

    if (*num_segments)
    {
        /* allocate memory for the line segments to be returned and copy
         * the accumulated line segments into the memory
         */

        *segments = (IGRpoint *) om$malloc(size = (*num_segments *
                                                   sizeof(IGRpoint) * 2));

        if (*segments)
        {
            for (i = 0, current_segment = 0; i < num_cmpnts; i++)
            {
                if (line_segs[i].num_segments)
                {
                    OM_BLOCK_MOVE(line_segs[i].segments,
                                  (*segments)[current_segment],
                                  line_segs[i].num_segments *
                                  sizeof(IGRpoint) * 2);
                    current_segment += line_segs[i].num_segments * 2;
                }
            }
        }
        else  /* if (*segments) */
        {
            *EMmsg = EMS_E_DynamicMemoryAllocated;
            goto wrapup;
        }
    }

wrapup:

    return(OM_stat);
}

/* This function returns an array of flags indicating whether each segment
 * is orthogonal (0) or non-orthogonal (1).  EMmsg is set to EMS_E_Fail if an
 * invalid segment is found, and the index of the invalid segment is returned
 * in invalid_segment.  If all the segments returned are not parallel, EMmsg
 * is set to EMS_I_Success.
 */

IGRlong  EFfind_non_orthogonal_segments(EMmsg, num_segments, segments,
                                        num_non_orth_segs, seg_type_array,
                                        invalid_seg_index)

IGRlong                *EMmsg;         /* Output:  function return message */
IGRint                 num_segments;   /* Input:  the number of line segments */
IGRpoint               *segments;      /* Input:  array of points that
                                          define line segments */
IGRint                 *num_non_orth_segs; /* Output:  number of segments
                                              which are not orthogonal to the
                                              first segment */
IGRboolean              seg_type_array[]; /* Output:  array containing flags
                                             indicating whether a segments
                                             is orthogonal (0) or
                                             non-orthogonal (1);
                                             the caller is responsible for
                                             providing memory for this array
                                             of size num_segments */
IGRint                 *invalid_seg_index; /* Output:  index of the first
                                              point of the invalid segment */
{
extern IGRdouble fabs() ;
    IGRdouble          dotp,
                       dotp_tol,
                       first_sg_vec[3],
                       cur_sg_vec[3];
    IGRlong            OM_stat,
                       rc;
    IGRint             index,
                       seg_pt_index,
                       num_seg_pts,
                       cur_num_segments;
    IGRboolean         status;

    OM_stat = OM_S_SUCCESS;
    *EMmsg = EMS_S_Success;
    cur_num_segments = 1;

    if (num_segments > 0)
    {
        *num_non_orth_segs = 1;
        seg_type_array[0] = TRUE;

        if (num_segments > 1)
        {
            for (index = 0; index < 3; index++)
                first_sg_vec[index] = segments[1][index] - segments[0][index];

            status = MAunitvc(&rc, first_sg_vec, first_sg_vec);

            if (! (1 & status & rc))
            {
                *EMmsg = EMS_E_Fail;
                *invalid_seg_index = 0;
                goto wrapup;
            }
        }
    }
    else
        *num_non_orth_segs = 0;

    BSEXTRACTPAR(&rc, BSTOLORTHOVEC, dotp_tol);
    num_seg_pts = num_segments * 2;

    for (seg_pt_index = 2; seg_pt_index < num_seg_pts; seg_pt_index += 2)
    {
        /*
         * Check if the current segment is normal to the first segment and
         * if it is add the index of its first point to the array of indices.
         */

        for (index = 0; index < 3; index++)
            cur_sg_vec[index] = segments[seg_pt_index + 1][index] -
                                      segments[seg_pt_index][index];

        status = MAunitvc(&rc, cur_sg_vec, cur_sg_vec);

        if (! (1 & status & rc))
        {
            *EMmsg = EMS_E_Fail;
            *invalid_seg_index = seg_pt_index;
            goto wrapup;
        }

        dotp = BSdotp (&rc, first_sg_vec, cur_sg_vec);
        EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

        if (dotp < -dotp_tol)
        {
            *EMmsg = EMS_E_Fail;
            *invalid_seg_index = seg_pt_index;
            goto wrapup;
        }
        else if (dotp <= dotp_tol)
        {
            seg_type_array[seg_pt_index/2] = FALSE;
        }
        else
        {
            seg_type_array[seg_pt_index/2] = TRUE;
            (*num_non_orth_segs)++;

            if (fabs(1.0 - dotp) > dotp_tol)
                *EMmsg = EMS_I_Success;
        }
    }

wrapup:

    return(OM_stat);
}

end implementation EMSsurface;
