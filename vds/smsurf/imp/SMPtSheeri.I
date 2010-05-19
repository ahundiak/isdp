/* $Id: SMPtSheeri.I,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */
 
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/smsurf/imp / SMPtSheeri.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SMPtSheeri.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:38  cvs
 *      Initial import to CVS
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
# Revision 1.2  1996/04/17  15:04:08  pinnacle
# Replaced: smframe/cmd/SMModNotif.I for:  by ksundar for vds.240
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

class implementation SMPtSheer;

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
#include "VDmem.h"

#include "AS_status.h"

#include "ACrg_collect.h"
#include "ACattrib.h"

#define AS_DEBUG
#define MAX_TEMP	53
#define MAX_PT		50

from ACrg_collect	import	ACget_named_attribute;
from SMframe		import	SMfind_frm_syst,SMgive_rel_position;
from SMfrm_syst		import	SMcvt_frm_to_wld;

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
 strcpy(info->type, "Sheer Surface Deck By Points");
  
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
 IGRdouble		dep_dx, x_depart, z_dep, ext_y1, ext_y2, *z_pos, *dx,
			x_pos, len, point[3], matrix[16];
 IGRchar		dir_axis, z_axis;
 struct GRid       	dep_frame, *frame;
 struct GRobj_env	coord;
 struct GRmd_env	my_env;
 struct	GRvg_construct  cst;
 IGRint			i, nb_pt, reverse, extension;
 struct ACrg_coll	attr;
 IGRboolean 		symetry;
 feet_list[0].objid = NULL_OBJID;

 z_pos = NULL;
 dx = NULL;
 frame = NULL;

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
 	printf("ERROR get coord syst\n");
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

 /* Get the z_axis */

 strcpy(attr.name,"z_axis");
 status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
							&attr),
                        targetid= list[1].objid,
                        targetos= list[1].osnum);
 if(!(status & loc_msg & 1)) goto wrapup ;
 z_axis = attr.desc.value.att_txt[0];

 /* Get the z_dep */

 strcpy(attr.name,"z_dep");
 status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
							&attr),
                        targetid= list[1].objid,
                        targetos= list[1].osnum);
 if(!(status & loc_msg & 1)) goto wrapup ;
 z_dep = attr.desc.value.att_exp;

 /* Get the dep_dx */

 strcpy(attr.name,"dep_dx");
 status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
							&attr),
                        targetid= list[1].objid,
                        targetos= list[1].osnum);
 if(!(status & loc_msg & 1)) goto wrapup ;
 dep_dx = attr.desc.value.att_exp;


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

 /* Get the nb_pt */

 strcpy(attr.name,"nb_pt");
 status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
							&attr),
                        targetid= list[1].objid,
                        targetos= list[1].osnum);
 if(!(status & loc_msg & 1)) goto wrapup ;
 nb_pt = (int)attr.desc.value.att_exp;

 if(nb_pt == 0) {
	printf("ERROR No pts Defined\n");
	goto wrapup;
 }
 nb_pt = nb_pt + 1; /* contains depart point */

 /* Get the dep_frame */

 status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg, "",&dep_frame,
				&matrix_type, 
				matrix),
			targetid= list[2].objid,
			targetos= list[2].osnum ) ;
 if(!(status & loc_msg & 1)) goto wrapup ;

 status = om$send(msg = message SMframe.SMgive_rel_position(&loc_msg,
                                                  &x_depart),
		       senderid = NULL_OBJID,
           	       targetid = dep_frame.objid,
           	       targetos = dep_frame.osnum );
 as$status();
 if(!(status&loc_msg&1) ) {
	printf("ERROR SMframe.SMgive_rel_position\n");
	goto wrapup;
 }

 x_depart = x_depart + dep_dx;

 len = x_depart;

 z_pos = _MALLOC(nb_pt,IGRdouble);
 if(z_pos == NULL){
	printf("ERROR Bad Allocation\n");
	goto wrapup; 
 }
 dx = _MALLOC(nb_pt,IGRdouble);
 if(dx == NULL){
	printf("ERROR Bad Allocation\n");
	goto wrapup; 
 }
 frame = _MALLOC(nb_pt,struct GRid);
 if(frame == NULL){
	printf("ERROR Bad Allocation\n");
	goto wrapup; 
 }

 z_pos[0] = z_dep;
 dx[0] = len;

 /* Get the z_pos and dx*/

 for(i=1;i<nb_pt;i++){
	sprintf(attr.name,"%s%d","z_pos",i-1);
 	status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
							&attr),
                        targetid= list[1].objid,
                        targetos= list[1].osnum);
 	if(!(status & loc_msg & 1)) goto wrapup ;
 	z_pos[i] = attr.desc.value.att_exp;

	sprintf(attr.name,"%s%d","dx",i-1);
 	status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
							&attr),
                        targetid= list[1].objid,
                        targetos= list[1].osnum);
 	if(!(status & loc_msg & 1)) goto wrapup ;
 	dx[i] = attr.desc.value.att_exp;

 }
 

 for(i=0;i<nb_pt-1;i++){
	/* Get all the frames */

 	status = om$send(msg = message NDmacro.ACreturn_foot(
				&loc_msg, 
				"",
				&frame[i],
				&matrix_type, 
				matrix),
			targetid= list[3+i].objid,
			targetos= list[3+i].osnum ) ;
  	if(!(status & loc_msg & 1)) goto wrapup ;


  	status = om$send(msg = message SMframe.SMgive_rel_position(&loc_msg,
                                                  &x_pos),
		       senderid = NULL_OBJID,
           	       targetid = frame[i].objid,
           	       targetos = frame[i].osnum );
  	as$status();
  	if(!(status&loc_msg&1) ) {
	 	printf("ERROR SMframe.SMgive_rel_position\n");
	 	goto wrapup;
  	}

  	x_pos = x_pos + dx[i+1];

  	dx[i+1] = x_pos;
 }


 symetry = FALSE;

 status = SMCrtLnStrgPtsCamber(&loc_msg, &coord, md_env, dir_axis, z_axis, 
			nb_pt, z_pos, dx, symetry,  extension,
			ext_y1, ext_y2, &cst, &feet_list[0]);
 if(!(status&loc_msg&1)){
	printf("ERROR  SMCrtLnStrgPtslCamber\n");
	goto wrapup;
 }

 

 point[0] = 0.;
 point[1] = 0.;
 point[2] = 10000000.;

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

 _FREE(z_pos);
 _FREE(frame);
 _FREE(dx);
 *fcount = 1;
 *rc = MSSUCC;
 return	OM_S_SUCCESS;

 wrapup:

 _FREE(z_pos);
 _FREE(frame);
 _FREE(dx);
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
	myDef->info		= SM_I_ObjPtSheer ;
	myDef->type		= 0 ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/


end implementation SMPtSheer;
 

