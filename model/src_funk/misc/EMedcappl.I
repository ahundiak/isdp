/* ###################   APOGEE COMPILED   ################## */
/* 
DESCRIPTION
===========
        
    This function caps the cappable areas ( closed paths formed by the
     unconnected edges ). The paths are checked for planarity ( because
     only planar caps are possible), the a plane encompassing the closed
     path is formed, the closed path is imposed as a boundary on the
     plane. If the caller needs a coincidency check ( check insures valid
     caps : capping hole and not area ). Then the edges on the closed 
     path are connected with edges on the surface (imposed boundary).
     The loop connection to the cap surface, orientation of loop plus
     orientation of normals for the cap surface is done. The 'face rule
     line table' is posted.

NOTES
=====
    

ARGUMENTS
=========
    
    VARIABLE                MODE    DESCRIPTION
    --------                ----    -----------
    EMmsg                   Output  Method return status.

    cap_eds                 Input   Refer to struct EMcap_ed_sf defined
                                     in file EMScap.h (dir old_include).
                                     The struct refers to the edge forming
                                     the cap, field ed: edge id.
                                     field sf: surf id of the ed.
                                     field geom: Geometry of the edge.

    num_caps                Input   Number of caps.
    
    num_edges_in_cap        Input   Number of edges in the cap.

    is_planar_cap           Output  Pointer to array of booleans, which
                                     describe the vaild cap.
                                    
    cap_sf                  Output  Pointer to array of stucts:
                                     EMcap_plane : refer to EMScap.h (dir
                                     old_include). The struct refers to 
                                     cap surface, field plane: cap geom.
                                     field plane_id: Id of cap surface.
                                     field loop_id: Id of loop imposed on 
                                      the cap surface.
                                        
    grmd_env                Input   Pointer to module info.
                                    
    construct_list          Input   Conctruct list for all constructions.
                                    
    care_coincidency        Input   Boolean to perform or skip check for
                                     coincidency.

    our_os                  Input   Pointer to object space number.

    

HISTORY
=======
    
    SAM     20-Oct-87   Creation.
    SAM     02-May-88   Modified such as, If imposing curves on capping 
                        plane fails because of number of loops > 1, impo-
                        sition is tried again by making the capping plane
                        a square. This is done to avoid mapping problems
                        due to a high aspect ratio(!=1) of the planar 
                        closed composite curve.
    PP      02-Nov-88   Made modifications to cause smaller caps to
                        be constructed.
    PP      26-Feb-89   Added additional check to detect the creation of
                        open loops.
    SM      28-Mar-89   Argument change in EMget_loops_for_imposition.
                        Function renamed as EMget_mapped_data().
    BL      28-Jun-89   Removed the free_poles() and modified the variable
                        in a for loop such that the program will become more
                        efficient.
    PP      28-May-90   Removed the capability for outputting status messaages
                        and added code to free memory in structure ed_ed
                        which was erstwhile not being freed.
    Jack    27-May-91   Modified numerous error statements to correctly
                        specify where the error occured.  Most were specifying
                        EMSplane:EMplane_of_cv.  Also moved GRconstruct so
                        it is done after the loopset is constructed and 
                        connected to its object.  2.0.1 Horizon Loops.
    PP      06/16/91    The orientation logic was messed up because of the
                        above change. I have now moved the same to be done
                        after GRconstruct. See comments. 
    DLB     02/20/92    Ensure that the plane created is always the same
                        relative to the first pole of the first edge.
    DLB     03/05/92    Handle correct pole location but reversed!
    SM      05/28/92    Moved DLB's plane orientation code into ./EMorntpl.I
                        so that it is reusable and introduced the 
                        corresponding function call here.
    AIC     06/04/93    If this is not a pre-2.4 object, use the closed
                        boundary curve to orient the plane.
    Sudha   07/08/93    Modified for BSprototypes ansification
   Sudhakar 08/18/93    Dealing specially with 'single closed curve' caps
                        in the 'POST220' part of the code.
    AIC     11/16/93    Replaced in-line logic with EFmerge_and_orient.
                        Since June, this code and EMsscvrtpl.I have
                        diverged, niether being quite right.
*/

class implementation EMSedge;

%safe
#include <math.h>
%endsafe
#include "emsmacros.h"
#include "emsdef.h"
#include "OMmacros.h"
#include "EMScap.h"
#include "bs.h"
#include "bsparameters.h"
#include "msdef.h"
#include "maerr.h"
#include "emsmapdef.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "EMSbnddef.h"
#include "emsplndef.h"

#define PLANE 3  /* Codes returned from BSptlnplan */
#define POINT 1
#define LINE 2

#define DEBUG 1
#if DEBUG
    #include <stdio.h>
#endif

#include "bsunwght_p.h"
#include "bssfarrevn.h"
#include "bsptlnplan.h"
#include "bspl_of_pts.h"
#include "bsmergarrcv.h"
#include "bsfreecv.h"
#include "bsdotp.h"
#include "bsdistptpt.h"

#define MAX_STATIC_POLES        250
#define U_SAMPLE_POINT          0.0
#define V_SAMPLE_POINT          0.0

from GRvg       import GRgetsize, GRgetgeom;
from EMSloop    import EMget_props, EMset_props;
from EMSloopset import EMset_props;
from EMSloop    import EMreverse;
from EMSgradata import EMinit;
from EMSsurface import EMrevorient;

extern OMuword  OPP_EMSplane_class_id, OPP_EMSloopset_class_id,
                OPP_EMSgradata_class_id;

extern IGRboolean   WANT_POST220_BEHAVIOR;

IGRlong EMedcapplane(EMmsg, cap_eds, num_caps, num_edges_in_cap,
                     is_planar_cap, cap_sf, grmd_env, construct_list,
                     care_coincidency, our_os)
IGRlong *EMmsg;
struct EMcap_ed_sf *cap_eds;
IGRint  num_caps, *num_edges_in_cap;
IGRboolean *is_planar_cap, care_coincidency;
struct EMcap_plane *cap_sf;
struct GRmd_env *grmd_env;
struct GRvg_construct *construct_list;
GRspacenum *our_os;
{
  IGRlong                   OM_stat, mthd_stat, surf_size, total_poles, 
                            new_total_poles, current_buffer_size,
                            EMtest_planar(), EFsspbtol_by_geom();
  IGRint                    i, j, k, l, old_from_ed_num, from_ed_num, 
                            to_ed_num, free_cntr, num_out_loops=0; 
  IGRpoint                  *poles=NULL, static_poles[MAX_STATIC_POLES],uf,vf;
  IGRdouble                 dotp, crosstol, upar, vpar, norm[4][3];

  IGRushort                 props, options = 0;
  IGRboolean                is_planar;
  IGRuchar                  *ed_type = NULL; /* , planar_options; */
  BSrc                      rc;
  struct IGRbsp_surface     *surf = NULL, **tst_plan_sf = NULL;
  struct IGRbsp_curve       **input_curves = NULL;
  struct IGRbsp_surface     dum_plane;
  IGRdouble                 dum_poles[4][3], dum_u_knots[4], dum_v_knots[4];

  GRobjid                   **input_edges = NULL, *loop_ptr = NULL;
  struct EMSgetlp_edgeinfo  **ed_ed = NULL;
  IGRint                    *edges_in_loop = NULL;
  IGRint                    ii,tryinx;

  IGRdouble                 bleed_factor;
  struct IGRbsp_curve       *curve = NULL;
  IGRvector                 nvec;
  IGRint                    code;

  IGRboolean                square_tried;


  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;
  dum_plane.poles = (IGRdouble *)dum_poles;
  dum_plane.u_knots = (IGRdouble *)dum_u_knots;
  dum_plane.v_knots = (IGRdouble *)dum_v_knots;
  dum_plane.weights = NULL;

  from_ed_num = 0;

  BSEXTRACTPAR (&rc, BSTOLBASIS, bleed_factor);
  bleed_factor *= 100;


  for(i = 0; i < num_caps; i++)
  {
    poles = (IGRpoint *) &static_poles[0][0];
    current_buffer_size = MAX_STATIC_POLES;

    input_curves = (struct IGRbsp_curve **) om$malloc (size = (unsigned)
                    (num_edges_in_cap[i]) *sizeof(struct IGRbsp_curve *));

    tst_plan_sf = (struct IGRbsp_surface **) om$malloc(size = (unsigned)
                (num_edges_in_cap[i]) *sizeof(struct IGRbsp_surface *));

    ed_type      = ( IGRuchar *) om$malloc (size = (unsigned) 
                    (num_edges_in_cap[i]) *sizeof(IGRuchar));

    input_edges  = (GRobjid **) om$malloc (size = (unsigned)
                    (num_edges_in_cap[i]) *sizeof(GRobjid *));

    EMerr_hndlr(!input_curves ||!tst_plan_sf || !ed_type || !input_edges,
                *EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);


    tryinx = 0;
    old_from_ed_num = from_ed_num;

try_capping_again:
    total_poles = 0;
    if(tryinx == 1) from_ed_num = old_from_ed_num;
    to_ed_num = from_ed_num + num_edges_in_cap[i] - 1;

    for (j = from_ed_num; j <= to_ed_num; j++)
    {

      if (tryinx == 0)
      {
        input_edges[j-from_ed_num] = &(cap_eds[j].ed);
        OM_stat = om$send (msg = message EMSedge.EMget_props_type(
                        &mthd_stat,
                        NULL,
                        (IGRuchar *)&ed_type[j-from_ed_num]),
                     senderid = NULL_OBJID,
                     targetos = *our_os,
                     targetid = cap_eds[j].ed);
        EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_EdgeError, wrapup);

        /* ********************* Not extracting the prop of edge.

        OM_stat = om$send (msg = message EMSedge.EMget_props(
                        &mthd_stat,
                        &props),
                     senderid = NULL_OBJID,
                     targetos = *our_os,
                     targetid = cap_eds[j].ed);
        EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_EdgeError, wrapup); 
        *********************** */

  
        OM_stat = om$send (msg = message GRvg.GRgetsize(
                        &mthd_stat,
                        &(grmd_env->md_env.matrix_type),
                        grmd_env->md_env.matrix,
                        &surf_size),
                     senderid = NULL_OBJID,
                     targetos = *our_os,
                     targetid = cap_eds[j].sf);
        EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_OMerror, wrapup);
  
        surf = NULL;
        surf = (struct IGRbsp_surface *) om$malloc(size = surf_size);
        EMerr_hndlr(!surf, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

        OM_stat = om$send (msg = message GRvg.GRgetgeom (
                        &mthd_stat,
                        &(grmd_env->md_env.matrix_type),
                        grmd_env->md_env.matrix,
                        (IGRchar *) surf),
                     senderid = NULL_OBJID,
                     targetos = *our_os,
                     targetid = cap_eds[j].sf);
        EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_OMerror, wrapup);

        tst_plan_sf[j-from_ed_num]  = surf;
        /* check up heeeeeeeeeeeeeeeeeeere */

        cap_eds[j].ed_geoms.poles   = NULL;
        cap_eds[j].ed_geoms.knots   = NULL;
        cap_eds[j].ed_geoms.weights = NULL;
        cap_eds[j].ed_geoms.bdrys   = NULL;


        /*  (props & EMED_REVERSED ? TRUE : FALSE) */
        OM_stat = om$send (msg = message EMSedge.EMget_bcxyz_geom(
                        &mthd_stat,
                        NULL,
                        NULL,
                        surf,
                        0, MAXINT,
                        FALSE,
                        NULL,
                        &(cap_eds[j].ed_geoms)),
                     senderid = NULL_OBJID,
                     targetos = *our_os,
                     targetid = cap_eds[j].ed);
        EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_OMerror, wrapup);
   
        input_curves[j-from_ed_num] = &(cap_eds[j].ed_geoms);
      }

   
      curve = &cap_eds[j].ed_geoms;

      /*
       * Points and lines need to be handled specially. Hence send only curves 
       * which are planar from a math sense to EFpl_of_cv.
       * pp (02/04/89)
       */
      BSptlnplan(curve->num_poles, curve->rational, (IGRpoint *)curve->poles, 
                 curve->weights, &code, nvec, &mthd_stat);
      EMerr_hndlr(BSERROR(mthd_stat), *EMmsg, EMS_E_BSerror, wrapup);

      if ((tryinx == 0) && (code == PLANE))
      {
        EFpl_of_cv(&mthd_stat, curve,ed_type[j-from_ed_num],
                     &dum_plane);
        EMerr_hndlr(!(1&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

        new_total_poles = 4 + total_poles;
      }
      else 
      {
        new_total_poles = curve->num_poles + total_poles;
      }

      if(new_total_poles > current_buffer_size)
      {
        if(poles != ((IGRpoint *) (&static_poles[0][0])))
        {
          poles = (IGRpoint *) realloc(poles,sizeof(IGRpoint)*new_total_poles);
          EMerr_hndlr(!poles, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
        }
        else
        {
          poles = (IGRpoint *) malloc(sizeof(IGRpoint)* new_total_poles);
          EMerr_hndlr(!poles, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
          OM_BLOCK_MOVE(static_poles, poles, sizeof(IGRpoint) * total_poles);
        }
        current_buffer_size = new_total_poles;
      }
 
      if ((code == PLANE) && (tryinx == 0))
      {
        OM_BLOCK_MOVE(&dum_plane.poles[0],&poles[total_poles][0],
          sizeof(IGRpoint) * 4);
      }
      else 
      {
        if(!curve->rational)
          OM_BLOCK_MOVE( curve->poles, 
                       &poles[total_poles][0],
                       sizeof(IGRpoint) * curve->num_poles);
        else
          OM_stat = BSunwght_p( &rc,
                          curve->poles,
                          curve->weights,
                          &curve->num_poles,
                          &poles[total_poles][0]);
      }
 

      total_poles = new_total_poles;
    }

    from_ed_num = to_ed_num + 1;

    cap_sf[i].plane.poles   = (IGRdouble *) om$malloc( size = 
                                (4 * sizeof (IGRpoint)));
    cap_sf[i].plane.weights = NULL;
    cap_sf[i].plane.u_knots = (IGRdouble *) om$malloc( size = 
                                (4 * sizeof (IGRdouble)));
    cap_sf[i].plane.v_knots = (IGRdouble *) om$malloc( size = 
                                (4 * sizeof (IGRdouble)));

    EMerr_hndlr( !cap_sf[i].plane.poles  ||
                 !cap_sf[i].plane.u_knots||
                 !cap_sf[i].plane.v_knots,
                *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
    if(care_coincidency)
    {
      /* planar_options = 0;
         planar_options = EMIndividual_Geoms; */

      struct EMStest_plan_group data;
 
      data.option        = EMIndividual_Geoms;
      data.data.sf_geoms = tst_plan_sf;
      data.num_sfs       = num_edges_in_cap[i];

      OM_stat = EMtest_planar(&mthd_stat, &data, grmd_env, &is_planar);
      EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_SurfaceError, wrapup);
 
      if(is_planar)
      {
        upar = U_SAMPLE_POINT;
        vpar = V_SAMPLE_POINT;

        BSsfarrevn( &rc, tst_plan_sf[0], 1, &upar, 1, &vpar, norm[0], norm[1]);
        if(BSERROR(rc))
        {
          #if DEBUG
            fprintf(stderr,"BSsfarrevn: normal at (0,0) 1st surf\n");
          #endif
          goto wrapup;
        }
      }
    }

    BSpl_of_pts( total_poles, (IGRdouble *)poles, NULL, &cap_sf[i].plane, &rc);
    if(BSERROR(rc))
    {
      is_planar_cap[i] = FALSE;
      if(cap_sf[i].plane.poles)   om$dealloc (ptr= cap_sf[i].plane.poles);
      if(cap_sf[i].plane.u_knots) om$dealloc (ptr= cap_sf[i].plane.u_knots);
      if(cap_sf[i].plane.v_knots) om$dealloc (ptr= cap_sf[i].plane.v_knots);
      cap_sf[i].plane.poles = cap_sf[i].plane.u_knots =
        cap_sf[i].plane.v_knots = NULL;

      *(&(cap_sf[i].plane_id)) = NULL_OBJID;
      /*cap_sf[i].plane = NULL; */
    
      if (tryinx == 0)
      {
        tryinx = 1;
        goto try_capping_again;
      }

      /*
      if (pp_output_igds_ems_log)
      {
        ex$message(msgnumb = EMS_I_CapIsNonPlanar, var = `i+1`, type = "%3d")
      }
      */
    
      #if DEBUG
        fprintf(stderr,"BSpl_of_pts: nonplanar poles of cap\n");
      #endif
    }
    else
    {
      IGRchar *dummy = NULL;
      IGRushort cnt_props, surf_pos, cap_pos;
      IGRdouble   par_tol_basis;
      IGRboolean  toggle_normal = FALSE;
      extern IGRint      EMget_mapped_data();
      GRobjid     loopset_id, frtobjid, *orig_ed, loop_ed;
      IGRpoint    rev_poles;
      struct GRid clip_ls;
      IGRshort    on_off = EMS_O_ON;
      OM_S_CHANSELECT     to_surface, to_loopset, to_loops, to_outter;

      if(WANT_POST220_BEHAVIOR)
      {
        int                 numed;
        struct IGRbsp_curve **cvptrs;

        numed = to_ed_num - old_from_ed_num + 1;

        cvptrs = (struct IGRbsp_curve **) alloca(numed * sizeof(*cvptrs));
        if(! cvptrs) { *EMmsg = EMS_E_Fail; goto wrapup; }

        for(ii = 0; ii < numed; ii ++)
        {
           cvptrs[ii] = &cap_eds[ii+old_from_ed_num].ed_geoms;
        }

        /*
         * Re-orient the plane so that the uv axes line up.
         */
        OM_stat = EFmerge_and_orient(EMmsg, cvptrs, numed, &cap_sf[i].plane);
      }
      else
      {
        /* Moved the plane orientation code into ./EMorntpl.I and introduced
           the following function call in its place. 
           SM 28-May-92.
        */
        (void) EMorient_plane(&mthd_stat, 
             cap_eds[old_from_ed_num].ed_geoms.poles, &cap_sf[i].plane, NULL);
      }

      /*
      options = EMMapBnd_WantStatMsg    |
      */
      options = EMMapBnd_StrokeIfNeeded |
                EMMapBnd_NoClip        | 
                EMMapBnd_SurfIsPlane   |
                EMMapBnd_WantBadCurves |
                EMMapBnd_NoValidate;

      /*
      if (!pp_output_igds_ems_log) options &= ~EMMapBnd_WantStatMsg;
      */

      is_planar_cap[i] = TRUE;


      for (k = 0; k < 3; k++)
      {
        uf[k]=(cap_sf[i].plane.poles[3+k]-cap_sf[i].plane.poles[k])*bleed_factor;
        vf[k]=(cap_sf[i].plane.poles[6+k]-cap_sf[i].plane.poles[k])*bleed_factor;
      }

      for (k = 0; k < 3; k++)
      {
        cap_sf[i].plane.poles[k]   =cap_sf[i].plane.poles[k]   -uf[k] -vf[k];
        cap_sf[i].plane.poles[3+k] =cap_sf[i].plane.poles[3+k] +uf[k] -vf[k];
        cap_sf[i].plane.poles[6+k] =cap_sf[i].plane.poles[6+k] -uf[k] +vf[k];
        cap_sf[i].plane.poles[9+k] =cap_sf[i].plane.poles[9+k] +uf[k] +vf[k];
      }

      if(care_coincidency)
      {
        if(is_planar)
        {
          BSsfarrevn(&rc, &cap_sf[i].plane, 1,&upar, 1,&vpar,norm[2], norm[3]);
          if(BSERROR(rc))
          {
            #if DEBUG
              fprintf(stderr,"BSsfarrevn: normal at (0,0) cap plane\n");
            #endif
            goto wrapup;
          }
    
          BSEXTRACTPAR(&rc, BSTOLCOLLINVEC, crosstol);
          dotp = BSdotp(&rc, norm[1], norm[3]); 
          if(BSERROR(rc))
          {
            #if DEBUG
              fprintf(stderr,"BSdotp: dotp of 2 normals\n");
            #endif
            goto wrapup;
          }
          if( dotp + 1.00000 <= crosstol)
          {
            OM_BLOCK_MOVE(&(cap_sf[i].plane.poles[3]), rev_poles,
                          sizeof(IGRpoint));
            OM_BLOCK_MOVE(&(cap_sf[i].plane.poles[6]),
                          &(cap_sf[i].plane.poles[3]),
                          sizeof(IGRpoint));
            OM_BLOCK_MOVE(rev_poles, &(cap_sf[i].plane.poles[6]), 
                          sizeof(IGRpoint));
          }
        } /* if not planar surfaces contributing edges */
      } /* if care_coincidency = TRUE */

      cap_sf[i].plane_id = NULL_OBJID;

      OM_stat = EFsspbtol_by_geom(&mthd_stat, &(cap_sf[i].plane), 
                                  &par_tol_basis);
      EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

      construct_list->geometry = NULL;
      clip_ls.objid = NULL_OBJID;

      square_tried = FALSE;

try_imposition_again_now_with_a_square_plane:
      {
        struct EMSgetlp_output              junk;
        struct EMSgetlp_planar_info planar_info;

        planar_info.edge_types = (IGRuchar *)ed_type;
        planar_info.curve_info = (IGRchar **) input_edges;
        planar_info.out_edges = &ed_ed;
        planar_info.num_out_edges = &edges_in_loop;

        junk.num_objs = 0;
        junk.objs = NULL;
        OM_stat = EMget_mapped_data(
                num_edges_in_cap[i],
                input_curves,
                NULL,
                construct_list,
                &(cap_sf[i].plane),
                &par_tol_basis,
                grmd_env,
                NULL,
                NULL,
                &junk,
                NULL,
                clip_ls,
                options,
                &planar_info, 
                &mthd_stat);
        loop_ptr = junk.objs;
        num_out_loops = junk.num_objs;
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
      }
      if(num_out_loops > 1)
      {
        if(square_tried)
        {
          *EMmsg =  EMS_E_IntersectClosure;
          goto wrapup;
        }
        else
        {
          IGRshort np;
          IGRshort iindex, icase;
          IGRdouble   side[2], diff, orig_len, *ptr1, *ptr2, damp_var;
          IGRshort next_index[2][2], pair_index_diff[2];

          pair_index_diff[0] = 6;
          pair_index_diff[1] = 3;
          next_index[0][0] = 0; next_index[0][1] = 3; next_index[1][0] = 0;
          next_index[1][1] = 6;

          if (ed_ed)
          {
            for (ii=0;ii<num_out_loops;ii++)
              if (ed_ed[ii]) om$dealloc(ptr = ed_ed[ii]);
          }

          if(ed_ed)        om$dealloc (ptr = ed_ed);
          ed_ed = NULL;

          if(loop_ptr)      om$dealloc (ptr = loop_ptr);
          loop_ptr = NULL;
          if(edges_in_loop) om$dealloc (ptr = edges_in_loop);
          edges_in_loop = NULL;

          side[0] = BSdistptpt(&rc, &(cap_sf[i].plane.poles[0]),
                               &(cap_sf[i].plane.poles[3]));
          EMerr_hndlr(rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
     
          side[1] = BSdistptpt(&rc, &(cap_sf[i].plane.poles[0]),
                               &(cap_sf[i].plane.poles[6]));
          EMerr_hndlr(rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
     

          diff = side[0] - side[1];
          EMerr_hndlr(!diff, *EMmsg, EMS_E_Fail, wrapup);
          icase = ( (diff > 0) ? 0 : 1 );
          orig_len = ( icase ? side[0]: side[1]);

          /*
           * BL : 06/28/89
           * add this variable for the loop can make the program more
           * efficient 
           */

          damp_var = (orig_len+fabs(diff)) / orig_len;
     
          for(iindex = 0; iindex <=1; iindex++)
          {
            ptr1 = &(cap_sf[i].plane.poles[ next_index[icase][iindex] ]);
            ptr2 = &(cap_sf[i].plane.poles[ next_index[icase][iindex] +
                                           pair_index_diff[icase] ]);
            for(np = 0; np <=2; np ++)
            {
              ptr1[np] = ptr2[np] + ((ptr1[np] - ptr2[np]) * damp_var);
            }
          }
          square_tried = TRUE;
          goto try_imposition_again_now_with_a_square_plane;
        } /* If (!square_tried) */
      } /* If num_out_loops > 1 */

      props = 0;
      OM_stat = om$send(msg = message EMSloop.EMget_props(
                        &mthd_stat,
                        &props),
                      senderid = NULL_OBJID,
                      targetos = *our_os,
                      targetid = loop_ptr[0]);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
    
      /*
       * Added additional check to detect the presence of open loops.
       * pp (02/26/89)
       */
      if (props & EMLP_OPEN) 
      {
        *EMmsg = EMS_E_IntersectClosure;
        goto wrapup;
      }

      /* delete objects , free and null ptrs: inside & outside */

      if( care_coincidency && is_planar && ( props & EMLP_PLOOP ) ) 
      {
        is_planar_cap[i]  = FALSE;
        OM_stat = om$send(msg = message Root.delete(
                            TRUE),
                          senderid = NULL_OBJID,
                          targetos = *our_os,
                          targetid = loop_ptr[0]);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

      }
      else
      {
        OM_stat = om$construct (classid = OPP_EMSplane_class_id,
                           p_objid = &(cap_sf[i].plane_id));
        EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
    
        /*
        construct_list->msg = &mthd_stat;
        */
        construct_list->newflag = FALSE;
        cap_sf[i].plane.pos_orient = TRUE;
        cap_pos = 0x1;
        construct_list->geometry = (IGRchar *) &(cap_sf[i].plane);
        construct_list->class_attr = NULL;

        for (l = 0; l < num_edges_in_cap[i]; l ++)
        {
          if(!(dummy = ed_ed[0][l].info)) continue;
          orig_ed = (GRobjid *) dummy;
          loop_ed = ed_ed[0][l].edgeid;

          OM_stat = om$send (msg = message EMSedge.EMget_props(
                                &mthd_stat,
                                &cnt_props),
                             senderid = NULL_OBJID,
                             targetos = *our_os,
                             targetid = loop_ed);
          EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

          OM_stat = om$send(msg = message EMSedge.EMconnect_edges(
                                &mthd_stat, 
                (cnt_props & EMED_REVERSED ? EMED_REVERSE_CONNECT : FALSE),
                                FALSE,
                                orig_ed[0],
                                NULL_OBJID, 
                                NULL_OBJID,
                                &(grmd_env->md_env)),
                            senderid = NULL_OBJID,
                            targetid = loop_ed,
                            targetos = *our_os);
          EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);
        }

        if(!(props & EMLP_PLOOP))
        {
          OM_stat = om$send(msg = message EMSloop.EMreverse(
                        &mthd_stat),
                       senderid = NULL_OBJID,
                       targetos = *our_os,
                       targetid = loop_ptr[0]);
          EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
        }

        props = 0;
        props = EMLP_EXTERNAL | EMLP_ACTIVE;

        OM_stat = om$send(msg = message EMSloop.EMset_props(
                        &mthd_stat,
                        props,
                        on_off),
                      senderid = NULL_OBJID,
                      targetos = *our_os,
                      targetid = loop_ptr[0]);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

        OM_stat = om$send (msg = message EMSedge.EMget_props(
                         &mthd_stat,
                         &cnt_props),
                       senderid = NULL_OBJID,
                       targetos = *our_os,
                       targetid = cap_eds[j-1].ed);
        EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_EdgeError, wrapup);

        OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
        EMomerr_hndlr_action(OM_stat,goto wrapup,"In EMSedge:EMedcapplane error"); 

        OM_stat = EMmake_chanselect (EMSloopset_to_surface, &to_surface);
        EMomerr_hndlr_action(OM_stat, goto wrapup,"In EMSedge:EMedcapplane error"); 

        OM_stat = om$construct (classid = OPP_EMSloopset_class_id,
                                  p_objid = &loopset_id);
        EMomerr_hndlr_action(OM_stat, goto wrapup,"In EMSedge:EMedcapplane error"); 

        OM_stat = EMmake_chanselect (EMSloop_to_outter, &to_outter);
        EMomerr_hndlr_action(OM_stat, goto wrapup,"In EMSedge:EMedcapplane error"); 

        OM_stat = EMmake_chanselect (EMSloopset_to_loops, &to_loops);
        EMomerr_hndlr_action(OM_stat, goto wrapup,"In EMSedge:EMedcapplane error"); 

        /* connect the loopset to the plane */
        OM_stat = om$send (msg = message Root.connect (to_surface, 0,
                            cap_sf[i].plane_id, 
                            *our_os,
                            to_loopset, 0),
                       senderid = cap_sf[i].plane_id,
                       targetos = *our_os,
                       targetid = loopset_id);
        EMomerr_hndlr_action(OM_stat, goto wrapup,"In EMSedge:EMedcapplane error"); 


        /* connect the loop to the loopset */
        OM_stat = om$send(msg = message Root.connect(
                to_outter, 0, loopset_id,
                *our_os, to_loops, 0), 
                senderid = loopset_id,
                targetos = *our_os,
                targetid = loop_ptr[0]);
        EMomerr_hndlr_action(OM_stat, goto wrapup,"In EMSedge:EMedcapplane error"); 

        props = 0;
        props = EMLS_NONMODIFIABLE;
        OM_stat = om$send(msg = message EMSloopset.EMset_props(
                        &mthd_stat,
                        props,
                        on_off),
                      senderid = NULL_OBJID,
                      targetos = *our_os,
                      targetid = loopset_id);
        EMerr_hndlr(!(1&mthd_stat&OM_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

        /*
         *  Fill the instance data and such
         */
        OM_stat = om$send (msg = message GRgraphics.GRconstruct 
                        (construct_list),
                      senderid = NULL_OBJID,
                      targetos = *our_os,
                      targetid = cap_sf[i].plane_id);
        EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_OMerror, wrapup);

        /*
         * Moved the orientation logic to be done after GRconstruct since the
         * same initialises the instance data.
         * pp 06/16/91
         */
        surf_pos = tst_plan_sf[num_edges_in_cap[i]-1]->pos_orient ? 0x1 :
                                                                0x0;
        if(cnt_props & EMED_REVERSE_CONNECT)
        {
          if(surf_pos ^ cap_pos)
            toggle_normal = TRUE;
          else
            toggle_normal = FALSE;
        }
        else
        {
          if(surf_pos ^ cap_pos)
            toggle_normal = FALSE;
          else
            toggle_normal = TRUE;
        }

        if(toggle_normal)
        {
          OM_stat = om$send(msg = message EMSsurface.EMrevorient(
                          &mthd_stat),
                        senderid = NULL_OBJID,
                        targetos = *our_os,
                        targetid = cap_sf[i].plane_id);
          EMerr_hndlr(!(1&mthd_stat&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
        }

        /* End pp */

        /*
         * Construct and initialise frt object 
         */
        OM_stat = om$construct (classid = OPP_EMSgradata_class_id,
                             p_objid = &frtobjid,
                             msg = message EMSgradata.EMinit (
                                &mthd_stat,
                                cap_sf[i].plane_id,
                                loop_ptr[0]));
        EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);
  
      } /* cap not coincident ie: not a PLOOP */

      if(tst_plan_sf)
      {
        for(free_cntr = 0; free_cntr < num_edges_in_cap[i]; free_cntr ++)
        {
          if(tst_plan_sf[free_cntr]) om$dealloc(ptr = tst_plan_sf[free_cntr]);
          tst_plan_sf[free_cntr] = NULL;
        }
        om$dealloc (ptr = tst_plan_sf);
        tst_plan_sf = NULL;
      }
      if(input_curves)  om$dealloc (ptr = input_curves);
        input_curves = NULL;
      if(ed_type)       om$dealloc (ptr = ed_type);
        ed_type = NULL;
      if(input_edges)   om$dealloc (ptr = input_edges);
        input_edges = NULL;

      if (ed_ed)
      {
        for (ii=0;ii<num_out_loops;ii++)
          if (ed_ed[ii]) om$dealloc(ptr = ed_ed[ii]);
      }

      if(ed_ed)        om$dealloc (ptr = ed_ed);
        ed_ed = NULL;
      if(loop_ptr)      om$dealloc (ptr = loop_ptr);
        loop_ptr = NULL;
      if(edges_in_loop) om$dealloc (ptr = edges_in_loop);
        edges_in_loop = NULL;

    }
    if(poles && (poles != static_poles)) free(poles);
  }
 
                          

wrapup:
  if(!(1&*EMmsg))
  {
    if(cap_sf[i].plane_id != NULL_OBJID)
    {
      OM_stat = om$send(msg = message GRgraphics.GRdelete(
                            &mthd_stat,
                            grmd_env),
                        senderid = NULL_OBJID,
                        targetos = *our_os,
                        targetid = cap_sf[i].plane_id);
    }

    if(loop_ptr)
    {
      for(free_cntr = 0; free_cntr < num_out_loops; free_cntr++)
      {
        OM_stat = om$send(msg = message Root.delete(TRUE),
                         senderid = NULL_OBJID,
                         targetos = *our_os,
                         targetid = loop_ptr[free_cntr]);
      }
    }

/* nomore: */
    if(tst_plan_sf)
    {
      for(free_cntr = 0; free_cntr < num_edges_in_cap[i]; free_cntr ++)
      {
        if(tst_plan_sf[free_cntr]) om$dealloc(ptr =tst_plan_sf[free_cntr]);
        tst_plan_sf[free_cntr] = NULL;
      }
      om$dealloc (ptr = tst_plan_sf);
      tst_plan_sf = NULL;
    }
    if(input_curves)  om$dealloc (ptr = input_curves);
    input_curves = NULL;
    if(ed_type)       om$dealloc (ptr = ed_type);
    ed_type = NULL;
    if(input_edges)   om$dealloc (ptr = input_edges);
    input_edges = NULL;
    if (ed_ed)
    {
      for (ii=0;ii<num_out_loops;ii++)
      if (ed_ed[ii]) om$dealloc(ptr = ed_ed[ii]);
    }

    if(ed_ed)        om$dealloc (ptr = ed_ed);
    ed_ed = NULL;

    if(loop_ptr)      om$dealloc (ptr = loop_ptr);
    loop_ptr = NULL;
    if(edges_in_loop) om$dealloc (ptr = edges_in_loop);
    edges_in_loop = NULL;
    
    if(poles && (poles != static_poles)) free(poles);
  }
  EMWRAPUP(*EMmsg, OM_stat, "EMedcapplane");
  return(OM_stat);
}

end implementation EMSedge;
