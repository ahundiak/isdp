
/*

Name
  EMgeomhandle

Abstract
  Creates a geometric handle for 3d constraints 
  
Synopsis
  IGRlong           *msg          o   return code(OUT)
  IGRushort         opts          i   options
  struct GRmd_env   *md_env       i   module environment 
  GRobjid           *geom_handle  o   geometric handle

Description
    This method is the means of creating  geometric handle (COINC.PERP) for 
    the 3d constraints like coincidence,perpendicular etc.

Return Value
  EMS_S_Success		- all went well.
  EMS_E_Fail		- failed.
  EMS_E_InvalidArg	- invalid Argument specified 
  
Index

Keywords
  
History
	created ???

	Satya	11/3/93	  added this standard header and modified the
			  code for changing the layer of the constraint text 
			  to that of the associative object 
			  TR # 119220828
	Satya	22/5/95	  changed the layer of the constraint text 
			  to that of the current ref plane object 
			  TR # 119419643
 */

class implementation EMSimpcnstr;
#include "OMmacros.h"
#include "EMSasopts.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "EMdtmacros.h"

#define X 0
#define Y 1
#define Z 2

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSparameter import EMgetdimgeom;

extern GRclassid OPP_EMSasptcnstr_class_id, OPP_EMSparvcnstr_class_id;
extern GRclassid OPP_EMSptelcnstr_class_id, OPP_EMSpervcnstr_class_id;

method EMgeomhandle (IGRlong *msg; IGRushort opts;
                     struct GRmd_env *md_env; GRobjid *geom_handle)
{
  IGRboolean 		found;
  char 			textstr[10];
  short 		mattyp;
  OMuint 		num_children;
  int 			i;
  long 			msg_loc, stat_OM;
  double 		*mat, *pt, *pt1, *pt2;
  IGRpoint 		plnpt, ptmem;
  IGRvector 		zaxis, xaxis;
  GRclassid 		classid;
  struct IGRplane 	txtpln;
  struct GRid 		my_grid, param_id, assoc_id;
  struct EMSgeomdata 	gmdata;
  struct GRid 		textid;
  OM_S_CHANSELECT 	chan_to_children;
  enum GRdpmode 	dpmode = GRbd;
  struct GRsymbology	symb,symbtxt;
  extern void 		EMcnstrtext();
  struct GRid           dat_pln_id;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * If the property indicates that this is a self-constraint, that is
   * inherently defining the object that it governs, then do not
   * construct the geom-handle
   */

  if (ME.EMScnstr->cnstr_props & EMScnstr_self_constraint)
    goto ret_end;

  /*
   * Construct the handle
   */

  EMmake_chanselect (NDchildren_children, &chan_to_children);
  num_children = 0;
  om$get_channel_count (object = me, p_chanselect = &chan_to_children,
   count = &num_children);

  mattyp = md_env->md_env.matrix_type;
  mat = md_env->md_env.matrix;
  txtpln.normal = zaxis;
  txtpln.point = plnpt;
  found = FALSE;
  for (i=0; i<num_children; i++)
    {
    msg_loc = EMS_E_Fail;
    stat_OM = om$send (msg = message EMSparameter.EMgetdimgeom (&msg_loc,
               NULL, &mattyp, mat, &txtpln, xaxis, &gmdata, NULL),
               p_chanselect = &chan_to_children, from = i, to = i);
    if (!EMSerror (stat_OM & msg_loc))
      {
      found = TRUE;
      break;
      }
    }
  EMerr_hndlr (!found, *msg, EMS_E_Fail, ret_end);

  /*
   * Determine which parameter is being constrained.
   */
  stat_OM = om$get_objid_at_index ( object = me,
                                    p_chanselect = &chan_to_children,
                                    index = i,
                                    objidaddr = &param_id.objid,
                                    osnumaddr = &param_id.osnum );

  EMerr_hndlr (!(stat_OM & 1), *msg, EMS_E_Fail, ret_end);

  /*
   * Now determine which associative object the parameter object 
   * belongs to.
   */
  stat_OM = om$get_objid_at_index ( osnum = param_id.osnum,
                                    objid = param_id.objid,
                                    p_chanselect = &chan_to_children,
                                    index = 0,
                                    objidaddr = &assoc_id.objid,
                                    osnumaddr = &assoc_id.osnum );
                          
  EMerr_hndlr (!(stat_OM & 1), *msg, EMS_E_Fail, ret_end);

  if (gmdata.geomtype == GEOMDATA_POINT)
    pt = gmdata.point;
  else if (gmdata.geomtype == GEOMDATA_LINE)
    {
    pt1 = gmdata.line.line_pt1;
    pt2 = gmdata.line.line_pt2;
    pt = ptmem;
    for (i=X; i<=Z; i++)
      pt[i] = pt1[i] + (pt2[i] - pt1[i]) / 2.0;
    }
  else
    {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}

  om$get_classid (object = me, p_classid = &classid);
  if (om$is_ancestry_valid (subclassid = classid,
       superclassid = OPP_EMSasptcnstr_class_id) == OM_S_SUCCESS)
  {
    ex$message (msgnumb = EMS_I_COINC, buff = textstr);
  }
  else if (om$is_ancestry_valid (subclassid = classid,
            superclassid = OPP_EMSparvcnstr_class_id) == OM_S_SUCCESS)
  {
    ex$message (msgnumb = EMS_I_PARAL, buff = textstr);
  }
  else if (om$is_ancestry_valid (subclassid = classid,
            superclassid = OPP_EMSptelcnstr_class_id) == OM_S_SUCCESS)
  {
    ex$message (msgnumb = EMS_I_PTELEM, buff = textstr);
  }
  else if (om$is_ancestry_valid (subclassid = classid,
            superclassid = OPP_EMSpervcnstr_class_id) == OM_S_SUCCESS)
  {
    ex$message (msgnumb = EMS_I_PERP, buff = textstr);
  }
  else
  {
    ex$message (msgnumb = EMS_I_CNSTR, buff = textstr);
  }

  EMcnstrtext (&msg_loc, opts, md_env, textstr, pt, zaxis, xaxis, 0,
               &textid);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  i = 0;
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  stat_OM = om$send (msg = message GRconnector.GRrigidconn (&msg_loc,
             &my_grid, (IGRlong *)&i), targetid = textid.objid);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Connect the constraint text as a child of the associative object.
   */
  stat_OM = om$send (msg = message NDnode.NDconnect ( 1,
                                                      &assoc_id,
                                                      NULL_GRID,
                                                      ND_ADD ),
                     targetid = textid.objid,
                     targetos = textid.osnum );

  /*
   * Change the layer of the constraint text to that of the associative object 
   *  			--- Satya 11/3/93
   */
  /* Change the layer of the constraint text to that of the active 
   * reference plane layer and not to that of associative object.
   * TR# 119419643 -- Satya 22/5/95 
   */ 
      /*
       * get the active datum plane
       */
      dat_pln_id.objid = NULL_OBJID;
      ems$get_active_datum_plane (msg = &msg_loc, datpln = &dat_pln_id);
      EMerr_hndlr (EMSerror (msg_loc) || IF_NULL_OBJID (dat_pln_id.objid),
                   stat_OM, OM_E_ABORT, ret_end);
    
  stat_OM = om$send(msg = message GRvg.GRgetsymb (&msg_loc, &symb),
  			  targetid = dat_pln_id.objid,
  			  targetos = dat_pln_id.osnum,
  			  senderid = NULL_OBJID);
  stat_OM = om$send(msg = message GRvg.GRgetsymb (&msg_loc, &symbtxt),
  			  targetid = textid.objid,
  			  targetos = textid.osnum,
  			  senderid = NULL_OBJID);
  symbtxt.level = symb.level;
  stat_OM = om$send(msg = message GRvg.GRputsymb (&msg_loc, &symbtxt),
  			  targetid = textid.objid,
  			  targetos = textid.osnum,
  			  senderid = NULL_OBJID);

  /*
   * Display the constraint text handle - Rajiv 4/15/93
   */
  stat_OM = om$send ( msg = message GRgraphics.GRdisplay 
                            (&msg_loc, &md_env->md_env.matrix_type, 
                             md_env->md_env.matrix, &dpmode, &md_env->md_id),
                      targetid = textid.objid,
                      targetos = textid.osnum);
      
ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSimpcnstr.EMgeomhandle");
  return (stat_OM);
}

end implementation EMSimpcnstr;
