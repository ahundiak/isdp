/* $Id: SMSlCamberi.I,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */
 
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/smsurf/imp / SMSlCamberi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SMSlCamberi.I,v $
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
# Revision 1.2  1996/04/17  15:05:34  pinnacle
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

class implementation SMSlCamber;

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
#define MAX_TEMP	2
#define MAX_PT		50

from ACrg_collect	import	ACget_named_attribute;

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
 strcpy(info->type, "Slope Camber Deck");
  
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
 IGRshort               level;
 IGRdouble		y_pos, z_pos, ext_x1, ext_x2, ext_y1, ext_y2, *slope, *y_dist,
			point[3];
 struct GRobj_env      	coord;
 struct GRmd_env	my_env;
 struct	GRvg_construct  cst;
 IGRint			i, nb_sl, symetry, reverse, extension;
 struct ACrg_coll	attr;

 feet_list[0].objid = NULL_OBJID;

 slope = NULL;
 y_dist = NULL;

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

 /* Get the z_pos */

 strcpy(attr.name,"z_pos");
 status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
							&attr),
                        targetid= list[1].objid,
                        targetos= list[1].osnum);
 if(!(status & loc_msg & 1)) goto wrapup ;
 z_pos = attr.desc.value.att_exp;

 /* Get the symetry */

 strcpy(attr.name,"symetry");
 status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
							&attr),
                        targetid= list[1].objid,
                        targetos= list[1].osnum);
 if(!(status & loc_msg & 1)) goto wrapup ;
 symetry = (int)attr.desc.value.att_exp;


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

 /* Get the ext_x1 */

 strcpy(attr.name,"ext_x1");
 status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
							&attr),
                        targetid= list[1].objid,
                        targetos= list[1].osnum);
 if(!(status & loc_msg & 1)) goto wrapup ;
 ext_x1 = attr.desc.value.att_exp;


 /* Get the ext_x2 */

 strcpy(attr.name,"ext_x2");
 status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
							&attr),
                        targetid= list[1].objid,
                        targetos= list[1].osnum);
 if(!(status & loc_msg & 1)) goto wrapup ;
 ext_x2 = attr.desc.value.att_exp;

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

 /* Get the nb_sl */

 strcpy(attr.name,"nb_sl");
 status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
							&attr),
                        targetid= list[1].objid,
                        targetos= list[1].osnum);
 if(!(status & loc_msg & 1)) goto wrapup ;
 nb_sl = (int)attr.desc.value.att_exp;

 if(nb_sl == 0) {
	printf("ERROR No slope Defined\n");
	goto wrapup;
 }
 slope = _MALLOC(nb_sl,IGRdouble);
 if(slope == NULL){
	printf("ERROR Bad Allocation\n");
	goto wrapup;
 }
 y_dist = _MALLOC(nb_sl,IGRdouble);
 if(y_dist == NULL){
	printf("ERROR Bad Allocation\n");
	goto wrapup;
 }

 /* Get the slope and y_dist*/
 for(i=0;i<nb_sl;i++){
	sprintf(attr.name,"%s%d","slope",i);
 	status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
							&attr),
                        targetid= list[1].objid,
                        targetos= list[1].osnum);
 	if(!(status & loc_msg & 1)) goto wrapup ;
 	slope[i] = attr.desc.value.att_exp;

	sprintf(attr.name,"%s%d","y_dist",i);
 	status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
							&attr),
                        targetid= list[1].objid,
                        targetos= list[1].osnum);
 	if(!(status & loc_msg & 1)) goto wrapup ;
 	y_dist[i] = attr.desc.value.att_exp;

 }
 
 y_pos = 0.;
 status = SMCrtLnStrgSlCamber(&loc_msg, &coord, md_env,  
			z_pos, y_pos, nb_sl, slope, y_dist, symetry, extension,
			ext_x1, ext_x2, ext_y1, ext_y2, &cst, &feet_list[0]);
 if(!(status&loc_msg&1)){
	printf("ERROR  SMCrtLnStrgSlCamber\n");
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

 _FREE(slope);
 _FREE(y_dist);
 *fcount = 1;
 *rc = MSSUCC;
 return	OM_S_SUCCESS;

 wrapup:

 _FREE(slope);
 _FREE(y_dist);
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
	myDef->info		= SM_I_ObjSlCamber ;
	myDef->type		= 0 ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/

end implementation SMSlCamber;
 

