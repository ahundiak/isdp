/*

Name
  EFconvert_to_profile

Abstract
  Convert a wireframe type of element into a profile.
  
Synopsis
  long 			*msg		Return code (OUT) 
  IGRushort 		opts		options (IN)  (see SKdef.h)
                        SK_CONVERT_NO_AUTO_CONSTRAIN - do not constrain.
                        SK_CONVERT_VERBOSE	- display error messages.
  struct GRid 		eleid		element to be converted (IN)
  struct GRmd_env 	*md_env		module	(IN)
  GRobjid 		*skmgr		output profile (OUT).	
  int			automask	auto-constraint mask defined in comisc.h (IN)
  
Description
 Convert a wireframe type of element into a profile.
 This code assumes that the input element is a wireframe element.

Return Value
  SK_CONVERT_OK - if everything goes well.
  SK_CONVERT_ELEMENT_NOT_SUPPORTED - some of the composite curve element cannot be converted.
  SK_CONVERT_OUT_MEMORY - ran out of memory
  SK_CONVERT_CYCLE_FOUND - associative cycle detected.
  SK_CONVERT_CURVE_MUST_BE_ON_REF_PLANE - element not on the reference plane
  SK_CONVERT_CURVE_MUST_BE_PLANAR - element is not planar.

Notes
  Please access this function thru the macro sk$convert_to_profile
  defined in SKmacros.h

Index

Keywords
 wireframe, convert, profile
 
History
  07/22/93 : Carlos M. Diaz : created (extracted code out of ECskmgri.I). 
  07/22/93 : Rajiv Agrawal  : some standardization and cleanup.

 */
class implementation SKmgr;

#include <math.h>
#include "ems_m_inc.h"
#include "asbox.h"
#include "values.h"
#include "bsvalues.h"
#include "EMSdpb.h"
#include "EMdtmacros.h"
#include "EMSdatumdef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ECmsg.h"
#include "ma.h"
#include "maptpldis.h"
#include "bslenvec.h"
#include "bsdotp.h"
#include "bscrossp.h"

extern GRclassid OPP_EMSparamgm_class_id;
extern GRclassid OPP_GRcurve_class_id, OPP_GRbcsubbc_class_id;
extern GRclassid OPP_SKmgr_class_id, OPP_SKgeometry_class_id,
                 OPP_GR3dpoint_class_id, OPP_GR3dlineseg_class_id,
                 OPP_GR3dcircle_class_id, OPP_GR3dcirarc_class_id,
                 OPP_GA3dpoint_class_id, OPP_GA3dlineseg_class_id,
                 OPP_GA3dcircle_class_id, OPP_GA3dcirarc_class_id,
                 OPP_GRcompcurve_class_id;

from EMSdatpln  import EMget_pln_info;

IGRlong EFconvert_to_profile (IGRlong *msg, IGRushort opts, 
                              struct GRid eleid,
                              struct GRmd_env *md_env,
                              GRobjid *skmgr,
                              int automask)
{
  char 		  text_buffer[2*MS_MAX_MSG_LENGTH]; /* I'll concatenate 2 messages */
  IGRboolean      is_planar, verbose, plane_lock_was_off = FALSE;
  short 	  grprops, action;
  int             stat_OM, ok = 0, cycle = 1, ref_lock_state, position = 0;
  long            alt_msg_loc, msg_loc;
  double     	  dist, lentol, dotprod, dottol, crossprod, crosstol;
  struct GRid     planid, mgr_id;
  IGRvector       x_axis, z_axis, normal, tangent, crossvec;
  IGRpoint        point, origpt;
  struct IGRplane plane;
  GRclassid       classid;
  OM_S_CHANSELECT chan_to_comps;
  extern int 	  EMcheck_cycle();
    
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Do we have a valid object?
   */  
  if (om$is_objid_valid ( osnum = eleid.osnum, 
        objid = eleid.objid ) != OM_S_SUCCESS)
  {
    *msg = EMS_E_InvalidArg;
    return stat_OM = OM_E_ABORT;
  }
  
  verbose = opts & SK_CONVERT_VERBOSE;
  
  if (verbose) 
  {
    ex$message (msgnumb = EMS_I_ProfileNotCreated, 
                buff = &text_buffer[0],
                buffer_size = 20);
    strcat (text_buffer,":");
    /*
     * length of first segment and colon will be at most 20 characters
     */
    position = strlen (text_buffer);
  }

  ems$ref_plane_lock ( msg = &msg_loc, 
      options = EMS_REF_PLANE_LOCK_INQ, mode = &ref_lock_state );
  if (!(ref_lock_state & EMS_REF_PLANE_LOCK_ON))
    plane_lock_was_off = TRUE;
  ems$ref_plane_lock(msg = &msg_loc, 
      options = EMS_REF_PLANE_LOCK_ON | EMS_REF_PLANE_LOCK_SET,
      mode = &ref_lock_state );
  /*
   * get the active datum plane
   */
  planid.objid = NULL_OBJID;
  ems$get_active_datum_plane (msg = &msg_loc, datpln = &planid);
  EMerr_hndlr (EMSerror (msg_loc) || IF_NULL_OBJID (planid.objid),
      stat_OM, OM_E_ABORT, ret_end);

  classid = OM_K_NOTUSING_CLASSID;
  om$get_classid ( osnum = eleid.osnum,
                   objid = eleid.objid,
                   p_classid = &classid );
  if (classid == OPP_GRcompcurve_class_id)
  {
    OM_S_OBJECT_LINKAGE *list;
    int                 i, count = -1;
    struct GRid         grid;

    /* we must make sure that each component can be converted */
    EMmake_chanselect ( GRcmpowner_to_components, &chan_to_comps );
    om$get_channel_count ( osnum = eleid.osnum, objid = eleid.objid,
        p_chanselect = &chan_to_comps, count = (OMuint *)&count );
    if (count > 0)
    {
      list = (OM_S_OBJECT_LINKAGE *)alloca ( count * sizeof ( OM_S_OBJECT_LINKAGE ) );
      if (list)
      {
        if (om$get_channel_objects ( p_chanselect = &chan_to_comps,
            size = count, count = (OMuint *)&count, list = list, osnum = eleid.osnum, 
            objid = eleid.objid ) & 1)
        {
          for (i = 0, ok = 1, cycle = 0; (i < count) && ok && !cycle; i++)
          {
            classid = OM_K_NOTUSING_CLASSID;
            om$get_classid ( osnum = list [i].osnum, objid = list [i].S_objid, 
                p_classid = &classid );

            /* should we check for sub-classes ? */
            ok = (classid == OPP_GR3dcirarc_class_id) ||
                (classid == OPP_GR3dcircle_class_id) ||
                (classid == OPP_GR3dpoint_class_id) ||
                (classid == OPP_GR3dlineseg_class_id) ||
                (classid == OPP_GRbcsubbc_class_id);
            grid.osnum = list [i].osnum;
            grid.objid = list [i].S_objid;
            cycle = EMcheck_cycle ( &planid, &grid ) == EMS_S_Success;
          }
        }
        else
        {
          if (verbose) ex$message ( msgnumb = EMS_S_ElementCannotBeConverted);
          *msg = SK_CONVERT_CANT_ELEMENT;
          goto ret_end;
        }
      }
      else
      {
        if (verbose) ex$message ( msgnumb = EMS_S_OutOfMemory);
        *msg = SK_CONVERT_OUT_MEMORY;
        goto ret_end;
      }
    }
  }
  else
  {
    ok = (classid == OPP_GR3dcirarc_class_id) ||
         (classid == OPP_GR3dcircle_class_id) ||
         (classid == OPP_GR3dpoint_class_id) ||
         (classid == OPP_GR3dlineseg_class_id) ||
         (classid == OPP_GRbcsubbc_class_id);
    cycle = EMcheck_cycle ( &planid, &eleid ) == EMS_S_Success;
  }

  if (cycle)
  {
    if (verbose) 
      ex$message ( msgnumb = EMS_S_CyclicDependency);
    *msg = SK_CONVERT_CYCLE_FOUND;
    goto ret_end;
  }

  if (ok)
  {   
    stat_OM = om$send (msg = message EMSdatpln.EMget_pln_info (&msg_loc,
                             NULL, md_env, x_axis, NULL, z_axis, origpt, NULL),
                       targetid = planid.objid, targetos = planid.osnum,
                       senderid = NULL_OBJID);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

    is_planar = EMis_planar (&msg_loc, NULL, &eleid, point, normal, tangent);
    EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

    plane.point = origpt;
    plane.normal = z_axis;
    MAptpldis (&alt_msg_loc, point, &plane, &dist);
    EMerr_hndlr (EMSerror (alt_msg_loc), stat_OM, OM_E_ABORT, ret_end);

    BSEXTRACTPAR (&alt_msg_loc, BSTOLLENVEC, lentol);
    if (dist > lentol)
    {
      if (verbose) 
      {
        ex$message (msgnumb = EMS_S_CurveMustLieOnRefPlane, 
                    buff = &text_buffer[position],
                    buffer_size = 35);
        UI_status (text_buffer);
      }
      *msg = SK_CONVERT_CURVE_MUST_BE_ON_REF_PLANE;
      goto ret_end;
    }

    if (msg_loc == EMS_I_Ambiguous)
    {
      dotprod = BSdotp (&msg_loc, tangent, z_axis);
      EMerr_hndlr (msg_loc != BSSUCC, stat_OM, OM_E_ABORT, ret_end);

      dottol = cos ((90.0 - EMS_ZEROANGLE_DEG) * (M_PI/180.0));
      if (fabs (dotprod) > dottol)
      {
        if (verbose) 
        {
          ex$message (msgnumb = EMS_S_LineMustLieOnRefPlane, 
                      buff = &text_buffer[position],
                      buffer_size = 35);
          UI_status (text_buffer);
        }
        *msg = SK_CONVERT_LINE_MUST_BE_ON_REF_PLANE;
        goto ret_end;
      }
    }
    else if (msg_loc == EMS_S_Success && is_planar)
    {
      BScrossp (&msg_loc, normal, z_axis, crossvec);
      EMerr_hndlr (msg_loc != BSSUCC, stat_OM, OM_E_ABORT, ret_end);

      crossprod = BSlenvec (&msg_loc, crossvec);
      EMerr_hndlr (msg_loc != BSSUCC, stat_OM, OM_E_ABORT, ret_end);

      crosstol = sin (EMS_ZEROANGLE_DEG * (M_PI/180.0));
      if (crossprod > crosstol)
      {
        if (verbose) 
        {
          ex$message (msgnumb = EMS_S_CurveMustLieOnRefPlane, 
                      buff = &text_buffer[position],
                      buffer_size = 35);
          UI_status (text_buffer);
        }
        *msg = SK_CONVERT_CURVE_MUST_BE_ON_REF_PLANE;
        goto ret_end;
      }
    }
    else if (msg_loc == EMS_S_Success && !is_planar)
    {
      if (verbose) 
      {
        ex$message (msgnumb = EMS_S_CurveMustBePlanar, 
            buff = &text_buffer[position],
            buffer_size = 35);
        UI_status (text_buffer);
      }
      *msg = SK_CONVERT_CURVE_MUST_BE_PLANAR;
      goto ret_end;
    }

    /*
     * Create a profile out of the wireframe element.
     */
    mgr_id.objid = NULL_OBJID;
    stat_OM = EFcreate_profile (&msg_loc, NULL, &eleid, md_env,
                                origpt, x_axis, z_axis, 
                                &mgr_id, &eleid);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    grprops = GRHAS_EXTERNAL_CONSTRAINT | GRIS_ASSOCIATIVE;
    action = 1;
    om$send (msg = message GRgraphics.GRchgprops 
                   (&msg_loc, &action, &grprops), 
             targetid = mgr_id.objid, targetos = mgr_id.osnum,
             senderid = NULL_OBJID);
    
    /*
     * Make the reference plane parent of the profile.
     */
    stat_OM = om$send (msg = message NDnode.NDconnect 
                             (1, &planid, NULL_GRID, ND_ADD), 
                       targetid = mgr_id.objid, 
                       targetos = mgr_id.osnum,
                       senderid = NULL_OBJID);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    
    /*
     * Unless inhibited, auto-constrain the profile.
     */
    if (!(opts & SK_CONVERT_NO_AUTO_CONSTRAIN))
    {
      stat_OM = SKauto_constrain (&msg_loc, NULL, md_env, mgr_id, automask);
      EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
    }

    if (skmgr)
      *skmgr = mgr_id.objid;

    *msg = SK_CONVERT_OK;
  }
  else
  {
    if (verbose) 
    {
      ex$message (msgnumb = EMS_S_ElementNotSupported, 
                  buff = &text_buffer[position],
                  buffer_size = 35);
      UI_status (text_buffer);
    }
    *msg = SK_CONVERT_ELEMENT_NOT_SUPPORTED;
  }

ret_end:
  if (plane_lock_was_off)
    ems$ref_plane_lock ( msg = &msg_loc, 
        options = EMS_REF_PLANE_LOCK_OFF | EMS_REF_PLANE_LOCK_SET );

  return stat_OM;
}

/*
 * This function checks if there is a cycle between p_grid1 and p_grid2
 * the associative graph.
 */
int EMcheck_cycle ( p_grid1, p_grid2 )
struct GRid *p_grid1, *p_grid2	/* The objects to be checked		IN  */;
{
  struct GRid         grid1, grid2;
  OM_S_CHANSELECT     notification;
  OM_S_OBJECT_LINKAGE list [1];
  OMuint              count;

  EMmake_chanselect ( GRnotify_notification, &notification );
  count = 0;
  om$get_channel_objects ( p_chanselect = &notification,
     size = 1, count = &count, list = list, osnum = p_grid1->osnum, 
     objid = p_grid1->objid );

  if (count)
  {
    struct GRid tmp;
    tmp.objid = list[0].S_objid;
    tmp.osnum = list[0].osnum;
    if (!(EFis_ndnode(tmp))) return FALSE;
    grid1 = tmp;
  }
  else
    grid1 = *p_grid1;

  count = 0;
  om$get_channel_objects ( p_chanselect = &notification,
     size = 1, count = &count, list = list, osnum = p_grid2->osnum, 
     objid = p_grid2->objid );

  if (count)
  {
    struct GRid tmp;
    tmp.objid = list[0].S_objid;
    tmp.osnum = list[0].osnum;
    if (!(EFis_ndnode(tmp))) return FALSE;
    grid2 = tmp;
  }
  else
    grid2 = *p_grid2;

  return (nd$dep_exist ( l_root = &grid1, nb_root = 1, l_tip = &grid2, nb_tip = 1) ||
     nd$dep_exist ( l_root = &grid2, nb_root = 1, l_tip = &grid1, nb_tip = 1))
     ? EMS_S_Success : EMS_I_Fail;
}

int EFis_ndnode (struct GRid grid) {
  GRclassid classid;
  long status;
  
  status = om$get_classid ( osnum = grid.osnum,
                   objid = grid.objid,
                   p_classid = &classid );
                   
  if (!(1&status))
    EFprintcode (0,status);
  
   if (om$is_ancestry_valid (superclassid = OPP_NDnode_class_id, 
			 subclassid = classid) != (OM_S_SUCCESS)) 
	return 0;
   else return 1;

}

end implementation SKmgr;
