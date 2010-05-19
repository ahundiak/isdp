/* $Id: SMbulkheadi.I,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsurf/imp / SMbulkheadi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMbulkheadi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:39  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1997/02/12  21:11:48  pinnacle
# Replaced: smsurf/imp/SMbulkheadi.I for:  by jwfrosch for vds.241
#
# Revision 1.1  1997/02/06  21:05:30  pinnacle
# Created: smsurf/imp/SMbulkheadi.I by jwfrosch for vds.241
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class implementation SMbulkhead;

#include "OMmacros.h"
#include "OMprimitives.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "asbox.h"
#include "emsmass.h"
#include "bserr.h"
#include "EC_I.h"
#include "EMSmsgdef.h"
#include "emssfintdef.h"

#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "VDSutil_def.h"
#include "vdsmacros.h"
#include "grerr.h"
#include "vds.h"
#include "VDmsg.h"
#include "SMmsg.h"

#include "AS_status.h"

#include "ACrg_collect.h"
#include "ACattrib.h"

#define AS_DEBUG

from ACrg_collect	import	ACget_named_attribute;

extern	GRclassid	OPP_EMSproject_class_id;
extern	GRclassid	OPP_EMSsfsolid_class_id;
extern	GRclassid	OPP_EMSslboolean_class_id;
extern	GRclassid	OPP_GR3dpoint_class_id;

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method ACmplace_from_def(
		int		*rc, prop;
		char		 rep;
		char		*macro_name;
	       	int		 num_temp;
	       	struct GRid	*temp_list;
		struct GRid	*def_occ;
		struct GRmd_env	*md_env )

{
 IGRlong status;

 /*
  * Put the properties to no protect:
  *	- Does not create source,
  *	- Does not verify the number (variable number of templates)
  *	- Does not verify the template types
  */
  prop = prop | AChdr_noprotect | ACcant_place_sym;

  status = om$send (	msg	 = message ACncpx.ACmplace_from_def(
							rc,
							prop,
							rep,
							macro_name,
							num_temp,
							temp_list,
							def_occ,
							md_env),
			mode	 = OM_e_wrt_message,
			targetid = my_id );
  as$status(action = RET_STATUS);

  return	OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method GRgetobjinfo( IGRlong *rc; struct GRobj_info *info )
{
  strcpy(info->type, "Bulkhead");

  *rc = MSSUCC;
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method VDgetObjDef( long *msg ; VDobjDef *myDef )
{
  long	sts ;

  /*
   * name.
   */
  myDef->info	= SM_I_ObjLgCrgtBk ;
  myDef->type	= 0 ;

  sts	= OM_S_SUCCESS ;
  *msg	= MSSUCC ;

  return sts ;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method	ACconstruct_feet(	IGRlong		*rc;
				IGRint		 cn_type;
				IGRint		 count;
				struct GRid	 list[];
				struct GRmd_env *md_env;
				IGRint		*fcount;
				struct GRid	*feet_list )
{
  IGRchar		dir_axis, x_axis;
  IGRshort              level, version = 1;
  IGRlong 		status, loc_msg, sizebuf, nret;
  IGRint		i, reverse, extension;
  IGRdouble		period, hight, ext_x1, ext_x2, ext_z1, ext_z2,
			len1, len2, rad1, rad2, point[3], depart[3];
  struct IGRdisplay     display;
  struct GRobj_env      coord;
  struct GRmd_env	my_env;
  struct GRvg_construct cst;
  struct ACrg_coll	attr;
  struct ret_struct	ret_st;

  feet_list[0].objid = NULL_OBJID;
  rad1 = rad2 = 0.0;

  my_env = *md_env;
  my_env.md_id.objid = NULL_OBJID; /* Computation out of RTREE */

  cst.msg        = &loc_msg;
  cst.newflag    = FALSE;
  cst.geometry   = NULL;
  cst.env_info   = &my_env;
  cst.class_attr = NULL;
  cst.name       = NULL;
  cst.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

  sizebuf = sizeof(struct IGRdisplay);
  gr$get_active_display(msg     = &loc_msg,
			sizbuf  = &sizebuf,
			buffer  = &display,
			nret    = &nret);

  /*| get the active level */
  sizebuf = sizeof(IGRshort);
  gr$get_active_level(msg     = &loc_msg,
		      sizbuf  = &sizebuf,
		      buffer  = &level,
		      nret    = &nret);

  cst.display    = &display;
  cst.level      = level;

  /* Get the coord syst */

  status = GetEnvFrObj(&list[0], &coord.mod_env, &coord.obj_id);
  if(!(status & 1))
  {
    printf("ERROR get coord syst\n");
    goto wrapup ;
  }

  /* Get the Point */

  status = om$send (	msg	 = message NDnode.NDgive_structure(
							&loc_msg,
							&ret_st,
							 md_env),
			targetid = list[2].objid,
			targetos = list[2].osnum ) ;
  if(!(status & 1)) goto wrapup ;

  for(i=0;i<3;i++) depart[i] = ret_st.var.point_st.pt[i];

  /* Get the dir_axis */

  strcpy(attr.name,"dir_axis");
  status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, &attr),
		   targetid= list[1].objid,
		   targetos= list[1].osnum);
  if(!(status & loc_msg & 1)) goto wrapup ;
  dir_axis = attr.desc.value.att_txt[0];

  /* Get the x_axis */

  strcpy(attr.name,"x_axis");
  status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, &attr),
		   targetid= list[1].objid,
		   targetos= list[1].osnum);
  if(!(status & loc_msg & 1)) goto wrapup ;
  x_axis = attr.desc.value.att_txt[0];

  /* Get the period */

  strcpy(attr.name,"period");
  status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, &attr),
		   targetid= list[1].objid,
		   targetos= list[1].osnum);
  if(!(status & loc_msg & 1)) goto wrapup ;
  period = attr.desc.value.att_exp;

  /* Get the hight */

  strcpy(attr.name,"hight");
  status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, &attr),
		   targetid= list[1].objid,
		   targetos= list[1].osnum);
  if(!(status & loc_msg & 1)) goto wrapup ;
  hight = attr.desc.value.att_exp;

  /* Get the len1 */

  strcpy(attr.name,"len1");
  status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, &attr),
		   targetid= list[1].objid,
		   targetos= list[1].osnum);
  if(!(status & loc_msg & 1)) goto wrapup ;
  len1 = attr.desc.value.att_exp;

  /* Get the len2 */

  strcpy(attr.name,"len2");
  status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, &attr),
		   targetid= list[1].objid,
		   targetos= list[1].osnum);
  if(!(status & loc_msg & 1)) goto wrapup ;
  len2 = attr.desc.value.att_exp;


  /* Get the extension */

  strcpy(attr.name,"extension");
  status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, &attr),
		   targetid= list[1].objid,
		   targetos= list[1].osnum);
  if(!(status & loc_msg & 1)) goto wrapup ;
  extension = (int)attr.desc.value.att_exp;

  /* Get the reverse */

  strcpy(attr.name,"reverse");
  status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, &attr),
		   targetid= list[1].objid,
		   targetos= list[1].osnum);
  if(!(status & loc_msg & 1)) goto wrapup ;
  reverse = (int)attr.desc.value.att_exp;

  /* Get the ext_x1 */

  strcpy(attr.name,"ext_x1");
  status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, &attr),
		   targetid= list[1].objid,
		   targetos= list[1].osnum);
  if(!(status & loc_msg & 1)) goto wrapup ;
  ext_x1 = attr.desc.value.att_exp;

  /* Get the ext_x2 */

  strcpy(attr.name,"ext_x2");
  status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, &attr),
		   targetid= list[1].objid,
		   targetos= list[1].osnum);
  if(!(status & loc_msg & 1)) goto wrapup ;
  ext_x2 = attr.desc.value.att_exp;

  /* Get the ext_z1 */
  strcpy(attr.name,"ext_z1");
  status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, &attr),
		   targetid= list[1].objid,
		   targetos= list[1].osnum);
  if(!(status & loc_msg & 1)) goto wrapup ;
  ext_z1 = attr.desc.value.att_exp;


  /* Get the ext_z2 */

  strcpy(attr.name,"ext_z2");
  status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, &attr),
		   targetid= list[1].objid,
		   targetos= list[1].osnum);
  if(!(status & loc_msg & 1)) goto wrapup ;
  ext_z2 = attr.desc.value.att_exp;


  /* Get the rad1 */
  strcpy(attr.name,"rad1");
  status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, &attr),
		   targetid= list[1].objid,
		   targetos= list[1].osnum);
  if(!(status & loc_msg & 1)) goto wrapup ;
  rad1 = attr.desc.value.att_exp;

  /* Get the rad2 */
  strcpy(attr.name,"rad2");
  status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, &attr),
		   targetid= list[1].objid,
		   targetos= list[1].osnum);
  if(!(status & loc_msg & 1)) goto wrapup ;
  rad2 = attr.desc.value.att_exp;

  point[0] = 0.;
  point[1] = 10000000.;
  point[2] = 0.;

  status = SMCrtBulkhead ( &loc_msg, &coord, md_env, dir_axis, x_axis, version,
				hight, len1, len2, period, depart, extension, reverse,
				ext_x1, ext_x2, ext_z1, ext_z2, rad1, rad2, point, &cst, &feet_list[0]);
  if(!(status&loc_msg&1))
  {
    printf("ERROR SMCrtBulkhead\n");
    goto wrapup;
  }

  *fcount = 1;
  *rc = MSSUCC;
  return	OM_S_SUCCESS;

wrapup:

  *fcount = 0;
  *rc = MSFAIL;
  return	OM_W_ABORT;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

end implementation SMbulkhead;
