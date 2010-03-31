/* ###################   APOGEE COMPILED   ################## */
/*
Description
    

Return values 

    EMS_S_Success is returned if all is well.

Change history:

    RV			   Creation
    SM	    23-Jun-89	   argument additions.
    NP      26-Aug-92     Modified for ANSI compliance. Added typecasts.
    SM      12/8/92       Added checks for the following -
                           1) Rigid relationship bit
                           2) Check active properties of DPR owners.
    WBC     22-Nov-93     Ignoring the return code OM_W_REJECTED_METHOD when
                           EMvalidate is sent to the owner since the owner could
                           be subclassed from GRgraphics but has not overridden
                           EMvalidate (e.g. GRsvset).  Fix for TR#119311382.
    Sanjay  06/10/94       CR#: 119419609 :
                           ---------------- 
                           Added code for surface's geometry validation. This 
                           will do the following validations :   
                              a. Validates the surface's geometry such that it
                                 adheres to the B-Spline requirements.
                              b. Detects self-intersection and errors out.
                              c. For cubic surfaces (u-order and v_order = 4),
                                 checks for the poles multiplicity and as corr-
                                 ective action it will be changed into knot mu-
                                 ltiplicity without changing the spacial posit-
                                 ion of the surface.
    Sanjay  05/09/95       Initialized the variable done also added default to
                           switch statement, so that it will not enter into in-
                           finite loops. (TR# 119423725).
*/

class implementation EMSsubbs;

#include "EMSmsgdef.h"
#include "EMSopt.h"
#include "emsmacros.h"
#include "emserr.h"
#include "emsdef.h"
#include "EMSprop.h"
#include "dpmacros.h"
#include "OMmacros.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsallocsf.h"
#include "bschkfxsf.h"
#include "bschkfxsf2.h"
#include "bsdistptpt.h"


from OMObjSpace import pass;
from EMSloop    import EMget_loops;

method EMvalidate(IGRlong *EMmsg; struct GRmd_env *mod_info; IGRchar *geom;
		  GRobjid *cancer; IGRushort *option;
		  IGRchar *objinfo, *ioptr)
{
 IGRint                 ii, cnt = 0, depth = MAXINT, buf_size = 0;
 IGRlong	 	sts, total_poles;
 IGRlong		surf_size;
 OM_S_CHANSELECT     	to_loopset, to_owners;
 struct IGRbsp_surface	*surf_geom = NULL,  *out_surf_geom = NULL; 
 extern IGRlong		EMmake_chanselect();
 IGRuint		count = 0;
 IGRchar		obj_info[256];
 GRobjid                new_objid = NULL_OBJID, *loop_ids = NULL;
 struct GRid		my_GRid, activeid;
 IGRboolean		continu = TRUE, correct = FALSE, defective = FALSE, 
                        from_own = FALSE, fix = TRUE, has_boundary = TRUE, 
                        is_modified = FALSE, ok = FALSE, mult_poles = FALSE,
                        on_off;
 struct GRpost_info     post_info;
 extern IGRboolean	IGEstop();
 struct GRsymbology	mysymb;
 IGRdouble              basis_tol, pole_dist;
 IGRushort	        locopt = NULL, *loop_props = NULL;
 IGRshort               in_code, out_code, done=FALSE;
 BSrc                   rc;
 
 sts = OM_S_SUCCESS; 
 *EMmsg = EMS_S_Success;
 my_GRid.objid = my_id; 
 my_GRid.osnum = OM_Gw_current_OS;
 if(!option) option = &locopt;

 if(!(continu = !(IGEstop()))) goto wrapup;

 if(!objinfo)
  sprintf(obj_info, "Surface (id=%d) (grprops=0x%x)\n", my_id, 
		ME.GRgraphics->properties);
 else
  strcpy(obj_info, objinfo);

 BSEXTRACTPAR(&rc, BSTOLBASIS, basis_tol);
 EMerr_hndlr(BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);
    
 sts = EMmake_chanselect(EMSsubbs_to_loopset, &to_loopset);
 sts = EMmake_chanselect(GRconnector_to_owners, &to_owners);
 sts = om$is_objid_on_channel(object_c = me, p_chanselect = &to_owners, 
           objid = sender_id);
 if(sts == OM_S_SUCCESS) from_own = TRUE;
 else sts = OM_S_SUCCESS;

 sts = om$get_channel_count(object = me, p_chanselect = &to_owners, 
				  count = &count);
 
 if(!count && (ME.GRgraphics->properties & GR_RIGID_RELATIONSHIP))
  {
   enum GRdpmode dismode = GRhd;
   sts = om$send (msg = message GRgraphics.GRdisplay(EMmsg,
 	    	               &mod_info->md_env.matrix_type,
  	    	               mod_info->md_env.matrix,
   	     	               &dismode, &mod_info->md_id),
 	             targetid = my_id);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_SurfaceError,wrapup);
   sts = EMvalidate_io(EMmsg, mod_info, NULL, obj_info,
		"Incorrect ownership flag","Turn the bit off", 
		 &continu, &correct, NULL, option, ioptr, NULL);
   sts = dp$erase_hilite(msg = EMmsg);  
   EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);    
   if (correct)
    ME.GRgraphics->properties &= ~GR_RIGID_RELATIONSHIP;
   else defective = TRUE;
   if (!continu) goto wrapup;
  }

  activeid.objid = NULL_OBJID;
  sts = om$send(msg = message EMSsurface.EMgetactiveid(EMmsg, &activeid, NULL),
        targetid = my_id);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_SurfaceError,wrapup);

  /* If I did not get back the correct activeid from the above message and 
     I do have a surface type owner, this indicates a problem. Send the 
     message to it.
  */
  if(count && IF_EQ_OBJID(my_id, activeid.objid))
   activeid.objid = NULL_OBJID;

  if(IF_NULL_OBJID(activeid.objid) && count &&
     (ME.GRgraphics->properties & GR_RIGID_RELATIONSHIP) && !from_own)
   {
    OM_S_OBJID ownid;
    GRspacenum junk;

    sts = om$get_objid_at_index(object = me, p_chanselect = &to_owners, 
          index = 0, objidaddr = &ownid, osnumaddr = &junk);
    if(!(1&sts)) goto wrapup;
    if(EFisAncestryValid(EMmsg, ownid, OM_Gw_current_OS, 
       OPP_EMSsurface_class_id, TRUE))
     {
      sts = om$send(msg = OPPmargs, targetid = ownid);
      if (sts == OM_W_REJECTED_METHOD)
       sts = OM_S_SUCCESS;
      if( (*EMmsg == EMS_I_Interrupt) || (sts == OM_I_STOP_SENDING))
       goto wrapup;
     }    
   }

  sts = om$send (msg = message GRvg.GRgetsize(EMmsg,
 	    	               &mod_info->md_env.matrix_type,
  	    	               mod_info->md_env.matrix,
   	     	               &surf_size),
 	             targetid = my_id);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_SurfaceError,wrapup);

  if ((surf_geom=(struct IGRbsp_surface *)om$malloc(size=(OMuint)surf_size))==NULL)
    {*EMmsg = EMS_E_DynamicMemoryAllocated; goto wrapup;}

  sts = om$send(msg = message GRvg.GRgetgeom (EMmsg,
 	                   &mod_info->md_env.matrix_type,
  	                   mod_info->md_env.matrix,
    	          	   (IGRchar *)surf_geom),
    	             targetid = my_id);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_SurfaceError,wrapup);

  on_off = surf_geom->on_off;

  /*
   * Get the loops of the my_id to see whether they are natural or not
   */
  cnt = 0;
  sts = om$send( msg = message EMSloop.EMget_loops( EMmsg, EMS_OPT_ALL,
                               &depth, &loop_ids, &loop_props, &buf_size,&cnt),                 targetid = my_id );
  if( cnt )
      EMerr_hndlr( !(1&sts&*EMmsg), *EMmsg, EMS_E_LoopError, wrapup);

  if( cnt )
  {
     for(ii=0; ii<cnt; ii++)
     {
         if(!(loop_props[ii] & EMLP_NATURAL))
         { 
             has_boundary = TRUE;  
             break;
         }
     }
     free( loop_ids );
     free( loop_props );
  }

  if( surf_geom->num_boundaries ) has_boundary = TRUE;

  /*
   * If the surface has non-natural boundaries or it is owned by any object
   * then the geometry should not be changed. That's why set fix as FALSE
   */
  if( has_boundary || count )  fix = FALSE;

  /*
   * Check for the pole multiplicities
   */
  if( (surf_geom->u_order == 4) && (surf_geom->v_order == 4) )
  {
      (void) BSchkfxsf2( surf_geom, &out_surf_geom, &rc );
      EMerr_hndlr(BSERROR(rc), *EMmsg, EMS_E_SurfaceError, wrapup);

      total_poles = (surf_geom->u_num_poles * surf_geom->v_num_poles);
      for( cnt=0; cnt<total_poles; cnt++ ) 
      {
          pole_dist = BSdistptpt( &rc, &surf_geom->poles[3 * cnt],
                                   &out_surf_geom->poles[3 * cnt] ); 
          EMerr_hndlr( BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup );

          if( pole_dist > basis_tol )
          {
             mult_poles = TRUE;
             break;
          }
      }

      if( mult_poles )
      { 
          sts = EMvalidate_io( EMmsg, mod_info, NULL, obj_info,
                "Surface has multiple Poles",
                (fix) ? NULL : "Replace multiple poles by multiple knots",
                &continu, &correct, NULL, option, ioptr, NULL );
          EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_OMerror, wrapup);
          if( !continu ) goto wrapup;

          if( correct )
          {
              ok = BSsf_copy( &rc, out_surf_geom, surf_geom );
              EMerr_hndlr( !ok || BSERROR(rc), *EMmsg, EMS_E_SurfaceError,
                           wrapup );

              BSfreesf( &rc, out_surf_geom);
              out_surf_geom = NULL;

              is_modified = TRUE;
         }
      }
  }

  /*
   * First check whether there are any problems with the existing surface
   */
  in_code = FALSE;
  BSallocsf( surf_geom->u_order, surf_geom->v_order,
             surf_geom->u_num_poles, surf_geom->v_num_poles,
             surf_geom->rational, surf_geom->num_boundaries,
             &out_surf_geom, &rc );
  EMerr_hndlr(BSERROR(rc), *EMmsg, EMS_E_SurfaceError, wrapup);

  BSchkfxsf( (struct IGRbsp_surface *) surf_geom,
             in_code,
             (struct IGRbsp_surface *) out_surf_geom,
             &out_code,
             &rc );
  EMerr_hndlr(BSERROR(rc), *EMmsg, EMS_E_SurfaceError, wrapup);

  if( out_code == 0 ) done = TRUE;
     
  while( !done )
  {
     switch( out_code )
     {
        case -3 : /* 
                   * Invalid number of knots
                   */
                  sts = EMvalidate_io( EMmsg, mod_info, NULL, obj_info, 
                          "Invalid number of knots",
                          NULL, /* No action known to mankind */
                          &continu, &correct, NULL, option, ioptr, NULL );
                  EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

                  if( !continu ) goto wrapup;
                  done = TRUE; 

                  break; 

        case -2 : /* 
                   * Invalid number of poles
                   */
                  sts = EMvalidate_io( EMmsg, mod_info, NULL, obj_info, 
                          "Invalid number of poles",
                          NULL, /* No action known to mankind */
                          &continu, &correct, NULL, option, ioptr, NULL );
                  EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

                  if( !continu ) goto wrapup;
                  done = TRUE; 
                   
                  break;

        case -1 : /* 
                   * Invalid u_order and/or v_order
                   */
                  sts = EMvalidate_io( EMmsg, mod_info, NULL, obj_info, 
                          "Invalid u/v order",
                          NULL, /* No action known to mankind */
                          &continu, &correct, NULL, option, ioptr, NULL );
                  EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

                  if( !continu ) goto wrapup;
                  done = TRUE; 

                  break;

        case 0 : /*
                  * No problems
                  */
                 done = TRUE;
	         break;

        case 2 : /*
                  * Problem with the knot vector(s)
                  */
                 sts = EMvalidate_io( EMmsg, mod_info, NULL, obj_info, 
                          "Invalid u/v/u&v knot vector(s)",
                          (fix) ? NULL : "Correct the Knot vector(s)", 
                          &continu, &correct, NULL, option, ioptr, NULL );
                 EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

                 if( !continu ) goto wrapup;

                 if( correct )
                 {
                     in_code = 2; /* Fix the knots */
                     BSchkfxsf( surf_geom, in_code, out_surf_geom, &out_code, 
                                &rc );
                     EMerr_hndlr( BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);
                     if( correct )
                     {
                        OM_BLOCK_MOVE( out_surf_geom->u_knots, 
                               surf_geom->u_knots, 
                               surf_geom->u_num_knots * sizeof(IGRdouble) );

                        OM_BLOCK_MOVE( out_surf_geom->v_knots,
                               surf_geom->v_knots,
                               surf_geom->v_num_knots * sizeof(IGRdouble) );

                        is_modified = TRUE;
                     }
                  }
               
                  done = FALSE; 
 
                  break;

        case 4 : /*
                  * Illeagal weight
                  */
                 sts = EMvalidate_io( EMmsg, mod_info, NULL, obj_info, 
                          "Illeagal weight",
                          NULL, /* No action known to mankind */ 
                          &continu, &correct, NULL, option, ioptr, NULL );
                 EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

                 if( !continu ) goto wrapup;
	         done = TRUE;
   
                 break;

        case 5 : /*
                  * Problems exists but cannot be fixed
                  */
                 sts = EMvalidate_io( EMmsg, mod_info, NULL, obj_info, 
                          "Problems exists with the surface.",
                          NULL, /* No action known to mankind */ 
                          &continu, &correct, NULL, option, ioptr, NULL );
                 EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

                 if( !continu ) goto wrapup;
	         done = TRUE;
                 
                 break;
       
        case 6 : /*
                  * Problem with the poles cannot be fixed
                  */
                 sts = EMvalidate_io( EMmsg, mod_info, NULL, obj_info, 
                          "Problem with poles",
                          NULL, /* No action known to mankind */ 
                          &continu, &correct, NULL, option, ioptr, NULL );
                 EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

                 if( !continu ) goto wrapup;
	         done = TRUE;

                 break;

        case 8 : /*
                  * Problem with poles and knots but neither is fixed
                  */
                 sts = EMvalidate_io( EMmsg, mod_info, NULL, obj_info, 
                          "Problem with poles and knots",
                          NULL, /* No action known to mankind */ 
                          &continu, &correct, NULL, option, ioptr, NULL );
                 EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

                 if( !continu ) goto wrapup;
	         done = TRUE;

                 break;

        case 9 : /* 
                  * Problem with the knot vector and is fixed
                  */
		 done = TRUE;
                 break;

        case 10 : /* 
                   * Problem with both and both are fixed
                   */
		  done = TRUE;
                  break;

        case 11 : /*
                   * Problem with both and knots are fixed
                   */
		  done = TRUE;
                  break;

        case 16 : /*
                   * Self intersecting surface
                   */
                 sts = EMvalidate_io( EMmsg, mod_info, NULL, obj_info, 
                          "Surface is Self Intersecting",
                          NULL, /* No action required*/ 
                          &continu, &correct, NULL, option, ioptr, NULL );
                 EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

                 if( !continu ) goto wrapup;
	         done = TRUE;

                 break;

        default :
                 done = TRUE;
                 break;
      }

      if( !continu ) goto wrapup;
      if( !done )
      {
          in_code = 0;
          BSchkfxsf( surf_geom, in_code, out_surf_geom, &out_code, &rc);
          EMerr_hndlr( BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);
      }
  }

  if( is_modified )
  {
      post_info.construct_flag = FALSE;
      sts = om$send( msg = message GRvg.GRpostabsg( EMmsg, mod_info,
                                   &post_info,
                                   (IGRchar *) surf_geom,
                                   &new_objid ),
                     targetid = my_id );
      EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_OMerror, wrapup);
  }


  sts = om$send(msg = message GRgraphics.EMvalidate(EMmsg,
					mod_info,
                                        (IGRchar *)surf_geom,
					cancer,
					option, 
					objinfo, 
					ioptr),
			 p_chanselect = &to_loopset);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_SurfaceError,wrapup);	

 wrapup:

 if (surf_geom) om$dealloc(ptr = surf_geom);
 if (out_surf_geom) BSfreesf(&rc, out_surf_geom);
 if(defective)
  {
   *cancer = my_id;
   *EMmsg = EMS_I_SurfaceError;
  }
 else if (*cancer != NULL_OBJID)
  {
   if( (*option & EMSvalidateWeightBadSurfs) ||
       (*option & EMSvalidateChangeBadSurfLevel))
   {
     sts = om$send(msg = message GRvg.GRgetsymb(EMmsg, &mysymb), 
			targetid = my_id);
     if(1&*EMmsg&sts)
     {
       if(*option & EMSvalidateWeightBadSurfs) 
         mysymb.display_attr.weight = EMSvalidateBadSurfWeight;
       if(*option & EMSvalidateChangeBadSurfLevel)
         mysymb.level = EMSvalidateBadSurfLevel;
       sts = om$send(msg = message GRvg.GRputsymb(EMmsg, &mysymb), 
			targetid = my_id);
     }
   }
  }

  EMWRAPUP(*EMmsg, sts, "In EMSsubbs.EMvalidate")
  if(!continu || (*EMmsg == EMS_I_Interrupt))
   {*EMmsg = EMS_I_Interrupt; return (OM_I_STOP_SENDING);}
  else return (sts);
}
end  implementation EMSsubbs;
