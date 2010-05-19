/* $Id: SMTransBki.I,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsurf/imp / SMTransBki.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMTransBki.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:39  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
/*  History :
/*	PL  : Nov 9 92	  creation date.
/*
/* */

class implementation SMTransBk;

#include <stdio.h>
#include <math.h>

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
#define MAX_TEMP	4
#define MAX_PT		50

from ACrg_collect	import	ACget_named_attribute;
from SMframe		import	SMfind_frm_syst, SMgive_rel_position;
from SMfrm_syst		import	SMcvt_frm_to_wld;
from SMglob		import SMGetConnected;
from GRcontext		import GRgetmodule_env ;


extern	GRclassid	OPP_EMSproject_class_id;
extern	GRclassid	OPP_EMSsfsolid_class_id;
extern	GRclassid	OPP_EMSslboolean_class_id;
extern	GRclassid	OPP_GR3dpoint_class_id;

/* ****************** MSG ACmplace_from_def () ************************	*/

method ACmplace_from_def(int *rc, prop; 	char rep;char *macro_name;
	       	int num_temp;	struct GRid *temp_list;
		struct GRid *def_occ;
		struct GRmd_env *md_env )

{
 IGRlong status;

 /* Put the properties to no proptect:
 /*	- Does not create source,
 /*	- Does not verify the number (variable number of templates) 
 /*	- Does not verify the template types
 /* */
 prop = prop | AChdr_noprotect | ACcant_place_sym;
 status = om$send(msg = message ACncpx.ACmplace_from_def(rc, prop, rep, 
		         macro_name, num_temp, temp_list, def_occ, md_env),
                  mode     = OM_e_wrt_message,
                  targetid = my_id );
 as$status(action = RET_STATUS);

 return	OM_S_SUCCESS;
}


/* *********************** MSG GRgetobjinfo () ************************	*/

method GRgetobjinfo( IGRlong *rc; struct GRobj_info *info )

{
 strcpy(info->type, "Transversal Bulkhead");
  
 *rc = MSSUCC;
 return	OM_S_SUCCESS;
}


/* ******************* MSG ACconstruct_feet () ************************	*/

method	ACconstruct_feet( IGRlong *rc; IGRint cn_type; 
				IGRint count; struct GRid list[];
				struct GRmd_env *md_env;
				IGRint *fcount; struct GRid *feet_list )
{
 IGRlong 		status, loc_msg;
 IGRlong                sizebuf, nret;
 struct IGRdisplay      display;
 IGRshort               level, matrix_type;
 IGRdouble		fr_dx, to_dx, y_pos1, y_pos2, ext_y1, ext_y2, xpts[6],
			*x_pts, *y_pts, ypts[6],xpos1, xpos2,ext_z1, ext_z2,
			point[3], rate,
			my_y1, my_y2, my_z1,my_z2, matrix[16];
 IGRdouble		range[6];			
 IGRchar		dir_axis, y_axis;
 struct GRid       	hull, go_hull, fr_frame, 
			to_frame;
 struct GRobj_env	coord;
 struct GRmd_env	hull_env, my_env;
 struct	GRvg_construct  cst;
 IGRint			nb_pts, reverse, extension;
 struct ACrg_coll	attr;
 IGRboolean		symetry;


 feet_list[0].objid = NULL_OBJID;


 my_env = *md_env;
 my_env.md_id.objid = NULL_OBJID; /* Computation out of RTREE */

 cst.msg        = &loc_msg;
 cst.newflag    = FALSE;
 cst.geometry   = NULL;
 cst.env_info   = &my_env;
 cst.class_attr = NULL;
 cst.name       = NULL;
 cst.properties	= GRIS_LOCATABLE | GRIS_DISPLAYABLE;


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
 if(!(status & 1)) {
 	printf("ERROR get_coord syst\n");
 	goto wrapup ;
 }

 /* Get the dir_axis */

 strcpy(attr.name,"dir_axis");
 status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
							&attr),
                        targetid= list[1].objid,
                        targetos= list[1].osnum);
 if(!(status & loc_msg & 1)) goto wrapup ;
 dir_axis = attr.desc.value.att_txt[0];

 /* Get the y_axis */

 strcpy(attr.name,"y_axis");
 status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
							&attr),
                        targetid= list[1].objid,
                        targetos= list[1].osnum);
 if(!(status & loc_msg & 1)) goto wrapup ;
 y_axis = attr.desc.value.att_txt[0];

 /* Get the y_pos1 */

 strcpy(attr.name,"y_pos1");
 status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
							&attr),
                        targetid= list[1].objid,
                        targetos= list[1].osnum);
 if(!(status & loc_msg & 1)) goto wrapup ;
 y_pos1 = attr.desc.value.att_exp;

 /* Get the y_pos2 */

 strcpy(attr.name,"y_pos2");
 status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
							&attr),
                        targetid= list[1].objid,
                        targetos= list[1].osnum);
 if(!(status & loc_msg & 1)) goto wrapup ;
 y_pos2 = attr.desc.value.att_exp;

 /* Get the fr_dx */

 strcpy(attr.name,"fr_dx");
 status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
							&attr),
                        targetid= list[1].objid,
                        targetos= list[1].osnum);
 if(!(status & loc_msg & 1)) goto wrapup ;
 fr_dx = attr.desc.value.att_exp;

 /* Get the to_dx */

 strcpy(attr.name,"to_dx");
 status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
							&attr),
                        targetid= list[1].objid,
                        targetos= list[1].osnum);
 if(!(status & loc_msg & 1)) goto wrapup ;
 to_dx = attr.desc.value.att_exp;


 /* Get the reverse */

 strcpy(attr.name,"reverse");
 status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
							&attr),
                        targetid= list[1].objid,
                        targetos= list[1].osnum);
 if(!(status & loc_msg & 1)) goto wrapup ;
 reverse = (int)attr.desc.value.att_exp;

 /* Get the extension */

 strcpy(attr.name,"extension");
 status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
							&attr),
                        targetid= list[1].objid,
                        targetos= list[1].osnum);
 if(!(status & loc_msg & 1)) goto wrapup ;
 extension = (int)attr.desc.value.att_exp;

 /* Get the ext_y1 */

 strcpy(attr.name,"ext_y1");
 status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
							&attr),
                        targetid= list[1].objid,
                        targetos= list[1].osnum);
 if(!(status & loc_msg & 1)) goto wrapup ;
 ext_y1 = attr.desc.value.att_exp;


 /* Get the ext_y2 */

 strcpy(attr.name,"ext_y2");
 status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
							&attr),
                        targetid= list[1].objid,
                        targetos= list[1].osnum);
 if(!(status & loc_msg & 1)) goto wrapup ;
 ext_y2 = attr.desc.value.att_exp;

 /* Get the ext_z1 */

 strcpy(attr.name,"ext_z1");
 status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
							&attr),
                        targetid= list[1].objid,
                        targetos= list[1].osnum);
 if(!(status & loc_msg & 1)) goto wrapup ;
 ext_z1 = attr.desc.value.att_exp;


 /* Get the ext_z2 */

 strcpy(attr.name,"ext_z2");
 status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
							&attr),
                        targetid= list[1].objid,
                        targetos= list[1].osnum);
 if(!(status & loc_msg & 1)) goto wrapup ;
 ext_z2 = attr.desc.value.att_exp;



 /* Get the fr_frame */

 status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg, "",&fr_frame,
				&matrix_type, 
				matrix),
			targetid= list[2].objid,
			targetos= list[2].osnum ) ;
 if(!(status & loc_msg & 1)) goto wrapup ;


 status = om$send(msg = message SMframe.SMgive_rel_position(&loc_msg,
                                                  &xpos1),
		       senderid = NULL_OBJID,
           	       targetid = fr_frame.objid,
           	       targetos = fr_frame.osnum );
 as$status();
 if(!(status&loc_msg&1) ) {
	printf("ERROR SMframe.SMgive_rel_position\n");
	goto wrapup;
 }

 xpos1 = xpos1 + fr_dx;


 /* Get the to_frame */

 status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg, "", &to_frame,
				&matrix_type, 
				matrix),
		        senderid = NULL_OBJID,
			targetid= list[3].objid,
			targetos= list[3].osnum ) ;
 if(!(status & 1)) goto wrapup ;


 status = om$send(msg = message SMframe.SMgive_rel_position(&loc_msg,
                                                  &xpos2),
		       senderid = NULL_OBJID,
           	       targetid = to_frame.objid,
           	       targetos = to_frame.osnum );
 as$status();
 if(!(status&loc_msg&1) ) {
	printf("ERROR SMframe.SMgive_rel_position\n");
	goto wrapup;
 }
 xpos2 = xpos2 + to_dx;

/* must convert the data into the given cs ???? et ypos ??*/

 my_y1 = fabs(ext_y1);   
 my_y2 = fabs(ext_y2);   
 my_z1 = fabs(ext_z1);   
 my_z2 = fabs(ext_z2);   

 

 if(extension !=2){

 	/* retrieve the active hull */

   	if(!SMGetActHull(&hull,NULL, &hull_env,&go_hull)){
  		printf("ERROR SMGetActHull\n");
  		goto wrapup;
   	}
  
	rate = 0.1;
  	status = SMExtToRng(&go_hull, &hull_env, NULL, &rate, range);
 	if(!(status&1)) {
 		printf("ERROR SMGetExtFrmRg\n ");
 		goto wrapup;
 	}

 	my_y1 = fabs(range[1]);   
 	my_y2 = fabs(range[4]);   
 	my_z1 = fabs(range[2]);   
 	my_z2 = fabs(range[5]);   
 }	

  nb_pts = 6;
  x_pts = &xpts[0];
  y_pts = &ypts[0];

  if( (-my_y1) >= y_pos1) {
		nb_pts --;
		x_pts = &xpts[1];
		y_pts = &ypts[1];
  }
  if( my_y2 <= y_pos2) nb_pts --;
  
  xpts[0] = xpos1;		xpts[1] = xpos1;
  ypts[0] = -my_y1;		ypts[1] = y_pos1;


  xpts[2] = xpos2;		xpts[3] = xpos2;
  ypts[2] = y_pos1;		ypts[3] = y_pos2;

  xpts[4] = xpos1;		xpts[5] = xpos1;
  ypts[4] = y_pos2;		ypts[5] = my_y2;

  symetry = FALSE; 

  status = SMCrtLnStrgPtsCamber(&loc_msg, &coord, md_env, dir_axis, y_axis, 
			nb_pts, y_pts, x_pts, symetry,  extension, 
			my_z1, my_z2, &cst, &feet_list[0]);
  if(!(status&loc_msg&1)){
	printf("ERROR  SMCrtLnStrgPtsCamber\n");
	goto wrapup;
  }
 
 point[0] = 10000000.;
 point[1] = 0.;
 point[2] = 0.;

 status = SMSetSurfOrient(&loc_msg, &feet_list[0], &my_env, point, reverse );

 if(!(status&loc_msg&1)){
	printf("ERROR  SMSetSurfOrient\n");
	goto wrapup;
 }

 if(md_env->md_id.objid != NULL_OBJID  )
  {
   /* Add the feet in the rtree */
   
   status = om$send(msg = message GRgraphics.GRaddwrng(&loc_msg, md_env),
                                targetid = feet_list[0].objid,
                                targetos = feet_list[0].osnum);
   if(!(status & loc_msg & 1)) 
    {
     printf("Failed adding the resulting boolean solid to the rtree\n");
    }
  }

 *fcount = 1;
 *rc = MSSUCC;
 return	OM_S_SUCCESS;

 wrapup:

 *fcount = 0;
 *rc = MSFAIL;
 return	OM_W_ABORT;
}


/*----------------------------------------------------------------------------*/
method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

	long		sts ;	/* OM return code	*/

	/*
	 * name.
	 */
	myDef->info		= SM_I_ObjTransBk ;
	myDef->type		= 0 ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/


end implementation SMTransBk;
 

