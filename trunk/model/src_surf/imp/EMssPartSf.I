/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  EMSsubbs
     METHOD NAME:  EMpartsf

     Abstract: 
      This method extracts a partial surface part_surf
      from an existing surface surf. This method can 
      return any of the following:

      1) Geometry of the partial surface.
      2) Objid of the partial surface.
      3) Geometry and the objid of the partial surface.

-----
%SC%    

     EMpartsf(*rc, *arglist, *parm1, *parm2, *parm3, split_ind,
              *par_surf_objid, **part_surf,
              window_loopset, want_status_messages)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------
     *arglist  struct GRvg_construct   construct list.
     *parm1    IGRdouble               start parameter
     *parm3    IGRdouble               end parameter
     *parm2    IGRdouble               parameter for selecting 
                                       the active section, in case
                                       the input surface is closed.
     split_ind IGRint                  indicator to split in u, v or
                                       both directions.(0, 1 or 2)
     window_loopset  IGRboolean         Flag indicating whether relevant
                                        surface boundaries should be
                                        extracted. 
     want_status_messages IGRboolean    Flag indicating whether staus
                                        messages 
                                        are desired when processing is in
                                        progress.
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
     *rc          IGRlong        completion code
                                 - EMS_S_SUccess if successful
                                 - EMS_E_InvalidArg if proper arguments 
                                   are not supplied for what is wanted.
                                 - EMS_E_Fail (severe) if failure due to
                                    allocation problems.
                                 - EMS_E_InHoleTrim - extracted part was
                                   completely in existing hole.
                                 - EMS_I_InAreaTrim - extracted part was
                                   completely in existing area. In this 
                                   case the partial surface will have no
                                   loopset attached to it.
                             
    *par_surf_objid  GRobjid      object id for parial surface,
                                  if NOT wanted can be passed as NULL.
                                  if wanted, it has to be non-NULL & has
                                  to be accompanied by *construct_list.

                                  If the extracted part of the surface is
                                  entirely in hole and if window_loopset
                                  is TRUE, then no surface is extracted &
                                  the return code is EMS_E_InHoleTrim. In
                                  that case NULL_OBJID is returned for the
                                  partial surface.

**part_surf     struct IGRbsp_surface Geometry of the partial surface,
                                  if wanted it has to be non-NULL.

%MD%

     MODULES AND METHODS INVOKED:

     Modules:  
               BSpartofsf
               BSallocsf
               BSfreesf

     Methods:  
               GRgetabsg
               GRconstruct
               EMwindow
               EMmakeFRT
-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

     NOTES:

-----
%CH%

     CHANGE HISTORY:
        
    gupta   09/25/86 : creation date
    RC      07/27/87 : Now the pos_orient bit of the
                       part_surface will also be set.
    SM      28-Aug-87: Made changes for extracting relevant
                       boundaries. Also changed return codes to
                       EMS codes.
    RC      12/10/87 : Changed GRclipto call to 
                       EFget_iso_patch_classid() such that the partial
                       can be constructed of an appropriate class.
    SM	    01-Mar-88: Send surf and part_surf to EMuv_transform.

    SAM     10-MAR-88: Added argument part_surf to return the geometry
                       of the partial surface.
    SAM     27-MAR-88: Changed such that seam edges are deleted, and
                       corresponding loops are merged.
    SAM	    04-JUL-88: Changed such that if there is any loopset on
                       the parent surface, the num_boundaries field
                       in partial surface geometry is set to 1 (This
                       is done so that in EMssConstruc.I the partial
                       surface is not reparametrized such that the 
                       interior knot vecs are at arc length distances
                       BSarclnpars().
     RC     11/03/88   Rewrote the code if the loops need to be merged
                       on extracted partial surface.    
     DLB    12/10/91   If EFgetRevolveFmt fails then delete sf and reset
                       part_sf_objid to NULL_OBJID.  Also, if I'm a planar
                       sf of revolution make partial surf be just a genbs.
     NP     08/25/92   Modified for ANSI compliance. Declared "count" as "IGRuint".
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
      
     This method gets the geometry of the existing surface and then
     allocates memory to partial surface using BSallocsf. The
     partial surface is then extracted using BSpartofsf and then an
     object is constructed using this geometry. If the object is not of
     free form type, then the object will be created in the class to which
     it clips. The object id of the partial surface is returned to the
     caller.

     The caller can get just the geometry or geometry and the objid of the
     partial surface. Memory will be allocated for the partial surface,
     the caller is expected to free the memory.

     If the caller wishes to extract the relevant boundaries and if
   the entire extracted part lies in a hole then no new surface is created
     and NULL_OBJID is returned to the caller along with a return code of
     EMS_E_InHoleTrim. If the extracted part lies completely in area then
     the new surface has no loopset.
----*/
/*EH*/


class implementation EMSsubbs;

#include "EMS.h"
# include "gocmacros.h"     /* GRgetabsg macro  */
# include "madef.h"
# include "godef.h"
# include "ex.h"
# include "igrdp.h"
# include "dp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
# include "griodef.h"
# include "grio.h"
# include "lcdef.h"
# include "lc.h"
# include "lcmacros.h"
# include "OMerrordef.h"
# include "msdef.h"
# include "bserr.h"
# include "emsdef.h"
# include "OMmacros.h"
# include "EMSsplitdef.h"
# include "EMSbnddef.h"
# include "bsparameters.h"
%safe
# include <math.h>
%endsafe
# include "EMSopt.h"
# include "EMSprop.h"
# include <stdio.h>
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

#define U     1
#define V     2

from EMSloopset  import EMwindow, EMmakeFRT, EMget_loops, EMgetrange,
                        EMbounded_uv_range;
from EMSboundary import EMuv_transform;
from EMSloop     import EMgetrange, EMset_props;
from EMSrevol    import EMputRevolvedFormat;

method EMpartsf (IGRlong *rc; struct GRvg_construct *arglist; 
                 IGRdouble *parm1, *parm2, *parm3; IGRint split_ind;
                 GRobjid *par_surf_objid;
                 struct IGRbsp_surface **part_surf;
                 IGRboolean window_loopset, want_status_messages)
{
  OM_S_CHANSELECT        to_loopset, to_surface;
  struct IGRbsp_surface  *surf, *part_surf_local;
  struct GRmd_env        *env;
  struct GRid            part_sf_GRid;
  struct EMSpartolbasis  partolbasis;
  IGRdouble              *lp_ranges = NULL, trans_matrix[16], 
                         old_range[4], new_range[4], ls_range[4];
  IGRlong                stat_OM, msg;
  IGRuint                count;
  IGRint                 i, depth = 1, num_lps = 0, 
                         buf_size = 0;
  extern IGRint          EMget_window();

  IGRshort               trans_across_seam;
  extern IGRshort        EFget_uv_trans_mat();
  IGRboolean             world;
  GRclassid              iso_patch_classid;
  GRobjid                *lp_ids = NULL, windowed_ls;
  IGRchar                *surf_ptr;
  extern   void          BSpartofsf(), EFmerge_lps_across_seam();
        
  /* ************************************************************* */

  *rc = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  part_surf_local = NULL;
  env = arglist->env_info;

  EMerr_hndlr((!par_surf_objid&&!part_surf),*rc,EMS_E_InvalidArg, wrapup);

  stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
  EMerr_hndlr(!(1&stat_OM), *rc, EMS_E_OMerror, wrapup);

  /*  
   * get the surface geometry in the abstract buffer  
   */

  GRgetabsg (rc, &env->md_env.matrix_type, env->md_env.matrix,
             &surf_ptr, i);
  EMerr_hndlr (!(1& *rc), *rc, EMS_E_Fail, wrapup);

  surf = (struct IGRbsp_surface *) surf_ptr;
  surf->num_boundaries = 0;
  
 if ((! surf->u_phy_closed) && (! surf->v_phy_closed))   parm2 = NULL;

 /* 
  * allocate local buffer for partial surface 
  */

  BSallocsf (2*(surf->u_order), 2*(surf->v_order), 2*(surf->u_num_poles),
             2*(surf->v_num_poles), 2*(surf->rational),
             2*(surf->num_boundaries), &part_surf_local, &msg);

  EMerr_hndlr (msg != BSSUCC, *rc, EMS_E_NoDynamicMemory, wrapup);
  
  part_surf_local->rational = surf->rational;
  part_surf_local->num_boundaries = surf->num_boundaries;

  /* 
   * call math function to return the partial surface 
   */ 

  BSpartofsf (surf, parm1, parm2, parm3, split_ind, part_surf_local, 
              &msg);
  EMerr_hndlr (msg != BSSUCC, *rc, EMS_E_BSerror, wrapup);

  /* 
   * since the knot vectors (u, v) of the partial surface 
   * returned by the math function are not normalized, they 
   * are normalized before constructing the object.
   */

   BSnrsfkntvc(part_surf_local);

   part_surf_local->pos_orient = surf->pos_orient;

   if (part_surf) *part_surf = part_surf_local;
   
   if(par_surf_objid)
   {
    /*
     * Get the appropriate classid of the partial
     * surface to be constructed
     */

    (void) EFget_iso_patch_classid (my_id, OM_Gw_current_OS, parm1, 
             parm3, split_ind, NULL, &iso_patch_classid, rc); 
    EMerr_hndlr (!(1& *rc), *rc, EMS_E_Fail, wrapup);

    /*DLB 12/11/91 - added check for planar revol case.*/
    if (iso_patch_classid == OPP_EMSrevol_class_id)
    {
      IGRvector  unused_vec;
      BSrc       bsrc=0;
      extern OMuword OPP_EMSgenbs_class_id;
      IGRboolean planar;
      
      (void) BStst_plan(surf->u_num_poles * surf->v_num_poles, 
                        surf->poles, surf->rational ? surf->weights : NULL,
                        &planar, unused_vec, &bsrc);
      if (bsrc) {*rc = EMS_E_BSerror; goto wrapup;}

      if (planar) iso_patch_classid = OPP_EMSgenbs_class_id;
    }

    /* 
     * construct object for partial surface 
     */

    stat_OM = om$construct(osnum = OM_Gw_current_OS, 
                           classid = iso_patch_classid,
                           p_objid = par_surf_objid,
                           neighbor = OM_GS_NULL_NEIGHBOR);
    EMerr_hndlr (!(1&stat_OM), *rc, EMS_E_OMerror, wrapup);

    arglist->newflag = FALSE;

    stat_OM = om$get_channel_count(object = me, 
                                   p_chanselect = &to_loopset, 
                                   count = &count);
    EMerr_hndlr(!(1&stat_OM), *rc, EMS_E_OMerror, wrapup);

    if(count)
      part_surf_local->num_boundaries = 1;
    else
      part_surf_local->num_boundaries = 0;

    arglist->geometry = (IGRchar *) part_surf_local;

    if( iso_patch_classid == OPP_EMSrevol_class_id)
    {
     IGRint EFgetRevolvedFormat();

     stat_OM = EFgetRevolvedFormat( &msg,env,*par_surf_objid,part_surf_local);
     if (! (1 & stat_OM & msg))
     {
       /*Added deletion of surface - DLB 12/10/91*/
       stat_OM = om$send(msg = message Root.delete(NULL),
                         targetid = *par_surf_objid);
       *par_surf_objid = NULL_OBJID;
       EMerr_hndlr(!(1&stat_OM), *rc, EMS_E_OMerror, wrapup);

       arglist->geometry = NULL;
       *rc = EMS_E_Fail;
       goto wrapup;
     }
    }

    stat_OM = om$send( msg = message GRgraphics.GRconstruct (arglist),
                       targetid = *par_surf_objid);
    EMerr_hndlr (!(1&stat_OM & *(arglist->msg)), *rc, EMS_E_Fail, wrapup);

    part_surf_local->num_boundaries = 0;

    if(window_loopset)
    {
      stat_OM = EMmake_chanselect (EMSloopset_to_surface, &to_surface);
      EMerr_hndlr(!(1&stat_OM), *rc, EMS_E_OMerror, wrapup);

      if(count)
      {
        world = TRUE;
        stat_OM = om$send(msg=message EMSsubbs.EMpartolbasis ( rc,
                           &env->md_env.matrix_type,
                           env->md_env.matrix,&world,FALSE,
                           &partolbasis.tol),
                           targetid = my_id);
        EMerr_hndlr(!(1&*rc&stat_OM),*rc,EMS_E_Fail,wrapup);

        partolbasis.in_world = TRUE;
        partolbasis.is_valid = TRUE;
        partolbasis.mattyp = &env->md_env.matrix_type;
        partolbasis.mat = env->md_env.matrix;

        if(want_status_messages) ex$message(msgnumb = EMS_I_ExtractingBdrys)

        stat_OM = om$send(msg = message EMSloopset.EMwindow (rc, 
                           parm1, parm2, parm3, &trans_across_seam, split_ind, 
                           &windowed_ls, surf, FALSE, NULL, NULL, 
                           &partolbasis, env, want_status_messages), 
                          p_chanselect = &to_loopset);
        EMerr_hndlr(!(1&*rc&stat_OM), *rc, EMS_E_LoopsetError, wrapup);

        /* 
         * If the entire window was lying in an existing hole then 
         * delete the newly constructed surface and return a relevant 
         * code to the command object 
         */

        if(*rc == EMS_I_InHoleTrim)
        {
          stat_OM = om$send(msg = message GRgraphics.GRdelete
                             (rc, env), targetid = *par_surf_objid);
          EMerr_hndlr(!(1&*rc&stat_OM), *rc, EMS_E_OMerror, wrapup);

          *par_surf_objid = NULL_OBJID;
          *rc = EMS_E_InHoleTrim;

        } /* if(*rc == EMS_I_InHoleTrim) */

        else if(*rc != EMS_I_InAreaTrim)
        {
          stat_OM = om$send(msg=message EMSsubbs.EMpartolbasis
                            (rc,&env->md_env.matrix_type,
                             env->md_env.matrix,&world,FALSE,
                             &partolbasis.tol),
                             targetid = *par_surf_objid);
          EMerr_hndlr(!(1&*rc&stat_OM),*rc,EMS_E_Fail,wrapup);

          stat_OM = om$send(msg = message Root.connect(to_surface, NULL, 
                             *par_surf_objid, OM_Gw_current_OS,
                             to_loopset, NULL), 
                            senderid = *par_surf_objid, 
                            targetid = windowed_ls);
          EMerr_hndlr(!(1&stat_OM), *rc, EMS_E_OMerror, wrapup);

          if(trans_across_seam)
          { 
           
            if (trans_across_seam & ACROSS_SEAM_U)
            {
              ls_range[0] = parm1[0] > parm3[0] ? parm1[0] : parm3[0];
              ls_range[2] = parm1[0] > parm3[0] ? parm3[0] : parm1[0];
            }
            else
            {
              ls_range[0] = parm1[0] > parm3[0] ? parm3[0] : parm1[0];
              ls_range[2] = parm1[0] > parm3[0] ? parm1[0] : parm3[0];
            }
  
            if (trans_across_seam & ACROSS_SEAM_V)
            {
              ls_range[1] = parm1[1] > parm3[1] ? parm1[1] : parm3[1];
              ls_range[3] = parm1[1] > parm3[1] ? parm3[1] : parm1[1];
            }
            else
            {
              ls_range[1] = parm1[1] > parm3[1] ? parm3[1] : parm1[1];
              ls_range[3] = parm1[1] > parm3[1] ? parm1[1] : parm3[1];
            }
  
            stat_OM = om$send (msg = message EMSloopset.EMget_loops (rc,
                                EMS_OPT_ALL, &depth, &lp_ids, NULL, 
                                &buf_size, &num_lps),
                               targetid = windowed_ls);
            EMerr_hndlr (!(1&stat_OM&*rc),*rc,EMS_E_LoopsetError,wrapup);
           
            lp_ranges = (IGRdouble *) om$malloc (size= num_lps * 4 *
                                                 sizeof(IGRdouble));
            EMerr_hndlr (!lp_ranges, *rc, EMS_E_NoDynamicMemory,wrapup);
            for (i = 0; i < num_lps; i++)
            {
              stat_OM = om$send (msg = message EMSloop.EMgetrange (rc, 
                                  &lp_ranges[4*i] ),
                                 targetid = lp_ids[i]);
             EMerr_hndlr (!(1&*rc&stat_OM),*rc,EMS_E_LoopError,wrapup);
                                  
            } /* for (i = 0; i < num_lps; i++) */

            part_sf_GRid.objid = *par_surf_objid;
            part_sf_GRid.osnum = OM_Gw_current_OS;
 
            EFmerge_lps_across_seam (rc, &part_sf_GRid, surf, env, 
                               &partolbasis, num_lps, lp_ranges, lp_ids, 
                               ls_range, trans_across_seam);
            EMerr_hndlr (!(1& *rc), *rc, EMS_E_Fail, wrapup);

         } /* if(trans_across_seam) */
        
          /* 
           * Scale the entire loopset into a space which goes from 0 to 1.
           * The old range for scaling is the window used for extraction.
           */
        
          new_range[0] = new_range[1] = 0.0;
          new_range[2] = new_range[3] = 1.0;

          if(trans_across_seam)
          {
            stat_OM = om$send(msg = message EMSloopset.EMgetrange (rc, 
                               old_range), 
                              targetid = windowed_ls);
            EMerr_hndlr(!(1&stat_OM&*rc), *rc, EMS_E_LoopsetError,wrapup);
 
          }
          else
          {
             stat_OM = EMget_window(rc, parm1, parm3, split_ind,
                                    old_range); 
             EMerr_hndlr(!(1&*rc&stat_OM), *rc, EMS_E_Fail, wrapup);
          }
        
          stat_OM = EFget_uv_trans_mat(rc, old_range, new_range, 
                                       trans_matrix);

          stat_OM = om$send(msg = message EMSboundary.EMuv_transform
                             (rc, trans_matrix, &partolbasis, FALSE, 
                              (IGRchar *)surf, NULL), 
                            targetid = windowed_ls);
          EMerr_hndlr(!(1&*rc&stat_OM), *rc, EMS_E_LoopsetError, wrapup);
        
          stat_OM = om$send(msg = message EMSloopset.EMmakeFRT
                             (rc, *par_surf_objid), 
                            targetid = windowed_ls);
                                
      }/* else if *rc != EMS_I_InAreaTrim */

     } /*  if(count) */

    } /* if(window_loopset) */
   
   } /* if(par_surf_objid) */

wrapup:

  if(surf) GRabsg_del(surf);  
  if(part_surf_local && !part_surf) BSfreesf (&msg, part_surf_local);
  if(lp_ids) om$dealloc(ptr = lp_ids);
  if(lp_ranges) om$dealloc(ptr = lp_ranges);

  EMWRAPUP(*rc, stat_OM, "In EMSsubbs.EMpartsf");
  return(stat_OM);
}

/*
   The following function would  generate a revolved format from  the B-spline
   format of PARTIAL surface of revolution and post it into the instace data

        1. part_surf - partial surface geometry.

        2. part_surf_id - partial surface id. 
   
   Out put: None
   
   Assumptions : It has been assumed that the iso curve in the diretion u
                 (ie v= constant) is the curve to be revolved. Start angle is
                 is taken as zero.

   (Advised not to use elsewhere)
*/

IGRint EFgetRevolvedFormat(rc,env,part_surf_id,part_surf)
IGRlong *rc;
struct GRmd_env *env;
GRobjid part_surf_id;
struct IGRbsp_surface *part_surf;
/*
   History :-

   Nov 26,90 : Inasu : Creation.
   Aug 25,92 : NP    : Modified for ANSI compliance. Changed "status" and
		       "msg" to "IGRlong".
*/
{
 IGRlong status,msg;
 IGRdouble axis[6],knots[4];
 IGRdouble parm[2],start_angle,sweep_angle;
 IGRshort  opt;
 IGRboolean tst,is_360;
 IGRpoint  start_pt,centre;
 IGRvector vec1,vec2;
 struct GRpost_info post_info;
 struct IGRbsp_curve line;
 struct IGRbsp_curve *u_curve,*v_curve;
 extern IGRboolean BSconstprcv();
 extern IGRboolean BSaxisrot();
 extern void 	   BSalloccv();
 extern IGRboolean BSfreecv();

 	status = OM_S_SUCCESS;
	msg    = EMS_S_Success;
	*rc = EMS_S_Success;
       
        u_curve = NULL;
	v_curve = NULL;

	is_360  = FALSE;


	/* Get the axis of revolution */
	
	line.poles = &axis[0];
	line.knots = &knots[0];


 	BSaxisrot(&msg,part_surf, &line);
        EMerr_hndlr((msg != BSSUCC) ,*rc, EMS_E_BSerror,wrapup);

	
	/* Extract the iso curves at u=0 */

        BSalloccv(part_surf->u_order,part_surf->u_num_poles,
				part_surf->rational,0,&u_curve,&msg);
        EMerr_hndlr (!u_curve, *rc, EMS_E_NoDynamicMemory,wrapup);
        parm[0] = parm[1] = 0.0; 
	opt = 2;
	tst = FALSE;

        BSconstprcv (&msg, part_surf , &opt , parm , &tst, u_curve);
        EMerr_hndlr((msg != BSSUCC) ,*rc, EMS_E_BSerror,wrapup);

	/* Extract the iso curves at u = 0.5 */

        BSalloccv(part_surf->v_order,part_surf->v_num_poles,
				part_surf->rational,0,&v_curve,&msg);
        EMerr_hndlr (!v_curve, *rc, EMS_E_NoDynamicMemory,wrapup);

        parm[0] = 0.5;
	parm[1] = 0.0; 
	opt = 1;
	tst = FALSE;

        BSconstprcv (&msg, part_surf , &opt , parm , &tst, v_curve);
        EMerr_hndlr((msg != BSSUCC) ,*rc, EMS_E_BSerror,wrapup);

	/* Calculate the sweep angle of the surface which would be the
	   sweep angle of the v_curve. The start angle is taken as zero.
	   If the v_curve is physically closed => sweep is 360 degrees. */

	if( ! v_curve->phy_closed )
	{
	 IGRdouble radius,arclen;
	 extern IGRboolean BSarclength();
	 extern IGRint  BSarccen();
	 extern IGRdouble BSdistptpt();

	 parm[0] = 0.0 ; parm[1] = 1.0;
	 BSarclength(&msg, v_curve,&parm[0],&parm[1],&arclen);
         EMerr_hndlr((msg != BSSUCC) ,*rc, EMS_E_BSerror,wrapup);

	 BSarccen ( &msg,v_curve,centre );
         EMerr_hndlr((msg != BSSUCC) ,*rc, EMS_E_BSerror,wrapup);
	
  	 start_pt[0] = v_curve->poles[0]/v_curve->weights[0];
  	 start_pt[1] = v_curve->poles[1]/v_curve->weights[0];
  	 start_pt[2] = v_curve->poles[2]/v_curve->weights[0];

	 radius      = BSdistptpt(&msg,centre,start_pt);

	 sweep_angle = (arclen / radius)* (180.0 / PI);
         
         if(sweep_angle >= 360.0)
         {
            is_360 = TRUE;
            sweep_angle = 360.0;
         }

	}
	else
	{
	 is_360 = TRUE;
	 sweep_angle = 360.0;
	}

       start_angle = 0.0;
	
        /* determine the direction of sweep */
       {
	IGRvector cross_prod,axis_vec;
	IGRdouble temp;
	IGRint i;
	extern IGRboolean BScrossp();
	extern IGRdouble BSdotp();

	vec1[0] = start_pt[0] - centre[0];
	vec1[1] = start_pt[1] - centre[1];
	vec1[2] = start_pt[2] - centre[2];
        
	vec2[0] = v_curve->poles[6] / v_curve->weights[2] - centre[0];
	vec2[1] = v_curve->poles[7] / v_curve->weights[2] - centre[1];
	vec2[2] = v_curve->poles[8] / v_curve->weights[2] - centre[2];
	
	/* Cross product would give the direction of revolution */

	BScrossp(&msg,vec1,vec2,cross_prod);

	axis_vec[0] = axis[3] - axis[0];
	axis_vec[1] = axis[4] - axis[1];
	axis_vec[2] = axis[5] - axis[2];
	
        /* If the direction of revolution and axis vector are not in the
	   same direction, reverse the axis */

	if( BSdotp(&msg,axis_vec,cross_prod) <= 0.0)
	{
	 for(i=0;i < 3;i++){  
			    temp = axis[i];
			    axis[i] = axis[i+3];
			    axis[i+3] = temp; 
			   }
	}
       }
    	
       status = om$send  (  msg = message EMSrevol.EMputRevolvedFormat(
				&msg,
				env,
				&post_info,
				u_curve,
				&axis[0],
				is_360,
				start_angle,
				sweep_angle,
				part_surf->pos_orient),
			   targetid = part_surf_id, 
			   senderid = NULL_OBJID
		          );
       EMerr_hndlr(!(1 & status & msg) , *rc , EMS_E_Fail, wrapup);

wrapup:
     
     if(u_curve) BSfreecv(&msg,u_curve);
     if(v_curve) BSfreecv(&msg,v_curve);

 return(status);

}

end implementation EMSsubbs;
