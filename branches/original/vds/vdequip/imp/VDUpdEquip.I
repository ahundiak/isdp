/* $Id: VDUpdEquip.I,v 1.1.1.1 2001/01/04 21:08:43 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        vdequip/imp/VDUpdEquip.I
 *
 * Description:
 *
 *      This file implements functions to update Equipment if change of
 *      attributes in database.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDUpdEquip.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:43  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/09/29  14:54:48  pinnacle
# Created: vdequip/imp/VDUpdEquip.I by jwfrosch for vds
#
 *
 * History:
 *
 *	09/27/97	Sundar		Creation date.
 *
 * -------------------------------------------------------------------------
 */

class implementation Root;

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "exmacros.h"
#include "msdef.h"
#include "msmacros.h"

#include "gr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpmacros.h"

#include "godef.h"
#include "nddef.h"
#include "ndmacros.h"

#include "ACrg_collect.h"
#include "ACattrib.h"
#include "VDSutil.h"
#include "v_dbgmacros.h"
#include "AS_status.h"
#include "VDmem.h"
#include "SMCompForm.h"
#include "SMdef.h"

from	ACrg_collect	import	ACadd_list_attribute;
from	ACrg_collect	import	ACset_list_attribute;
from	VDequipment	import	ACgive_db_structure;
from 	ACcpx		import  ACfind_temp_obj;
from    ACrg_collect    import  ACchg_prop_mgr;
from    ACrg_collect    import  ACget_prop_mgr;

extern OMuword  OPP_VDequipment_class_id;


/*--------------------------------------------------------------------------*/

static void copy_eq_attr(target,source)
struct ACrg_coll *target;   /* [O] ACrg to fill */
struct ACrg_coll *source;   /* [I] ACrg to copy */
/*
-fi */
{
  strcpy(target->name,source->name);
  target->desc.type = source->desc.type;

  switch(source->desc.type)
   {
   case AC_ATTRIB_TEXT:

     strcpy(target->desc.value.att_txt,source->desc.value.att_txt);

     break;
   case AC_ATTRIB_DOUBLE:
     target->desc.value.att_exp = source->desc.value.att_exp;
     break;
   }
}

/*--------------------------------------------------------------------------*/

IGRlong VDUpdEquip()
{
struct	ret_struct		str;
char				eq_family[80], 
				eq_partno[80], eq_partrev[80];
struct  GRmd_env 		module_info;
IGRint          		rc, i, j, count, siz, nb_dyn, nb_stat;
IGRlong         		msg, ret, sts;
struct ACrg_coll     		my_att, *stat_att=NULL;
struct VDSatt_family   		*stat_attr=NULL, *dyn_attr=NULL;
struct GRid 			*loc_obj=NULL, stat_box;
IGRshort          		prop_mgr, prop_mg;
char 				VDactive_macro[16];


	sts = OM_S_SUCCESS;

	sts =VDobjInActiveSpace( 	&msg, 
					&count, 
					&loc_obj, 
					OPP_VDequipment_class_id ) ;

	if( count == 0 ) { msg = MSFAIL; goto wrapup ; }
	
	siz = sizeof(struct GRmd_env);
	gr$get_module_env ( 	msg    = &msg,
				sizbuf = &siz,
				buffer = &module_info,
				nret   = &ret );
    	for (j=0; j < count; j++)
	{					
	IGRchar promptInfo[80];

	sprintf (promptInfo,"Processing of [%d/%d] Equipment\n", j+1, count);
	sts = ex$message(     in_buff = promptInfo,
                        field   = PROMPT_FIELD,
                        justification   = CENTER_JUS );

	sts = om$send ( msg   = message ACcpx.ACfind_temp_obj(
                                        &rc,
                                        "syspara",
                                        &stat_box ),
			senderid = NULL_OBJID,
			targetid = loc_obj[j].objid,
			targetos = loc_obj[j].osnum );
 	__CheckRC(sts,1,"ACcpx.ACfind_temp_obj",wrapup );

	sts = om$send(msg = message ACrg_collect.ACget_prop_mgr
                                        ( &prop_mgr ),
                                senderid = NULL_OBJID,
                                targetid = stat_box.objid,
                                targetos = stat_box.osnum );
 	__CheckRC(sts,1,"ACrg_collect.ACget_prop_mgr",wrapup );

	prop_mg = prop_mgr & ~(AC_BOX_LOCKED | AC_BOX_CACHE) ; 

	sts = om$send(msg = message ACrg_collect.ACchg_prop_mgr
					 (1, prop_mg ),
                                senderid = NULL_OBJID,
                                targetid = stat_box.objid,
                                targetos = stat_box.osnum );
 	__CheckRC(sts,1,"ACrg_collect.ACchg_prop_mgr",wrapup );
                
	/* GET STATIC INFORMATION */
	
	sts = om$send(	msg	= message VDequipment.ACgive_db_structure(
					&rc,
					NULL,
					"eqp_family",
					&str,
					&module_info  ),
			senderid = NULL_OBJID,
			targetid = loc_obj[j].objid,
			targetos = loc_obj[j].osnum );
	if(!(rc & 1)) { 
		printf("ERROR ACgive_db_structure for eq_family\n"); 
		goto wrapup;
	}
	strcpy(eq_family, str.var.text_st.text_string); 

	sts = om$send(	msg	= message VDequipment.ACgive_db_structure(
					&rc,
					NULL,
					"eqp_partno",
					&str,
					&module_info  ),
			senderid = NULL_OBJID,
			targetid = loc_obj[j].objid,
			targetos = loc_obj[j].osnum );
	if(!(rc & 1)) { 
		printf("ERROR ACgive_db_structure for eq_partno\n"); 
		goto wrapup;
	}
	strcpy(eq_partno, str.var.text_st.text_string); 
	sts = om$send(	msg	= message VDequipment.ACgive_db_structure(
					&rc,
					NULL,
					"eqp_partrev",
					&str,
					&module_info  ),
			senderid = NULL_OBJID,
			targetid = loc_obj[j].objid,
			targetos = loc_obj[j].osnum );
	if(!(rc & 1)) { 
		printf("ERROR ACgive_db_structure for eq_partrev\n"); 
		goto wrapup;
	}
	strcpy(eq_partrev, str.var.text_st.text_string); 
		
	sts = VDSget_attr( eq_family, eq_partno, 
			eq_partrev, "EQUIP", &nb_stat, &stat_attr,
			&nb_dyn, &dyn_attr);

	if(!(sts & 1))
	{
		UI_status("Bad connection with database");
		goto wrapup;
	} 

	stat_att = _MALLOC ( nb_stat, struct ACrg_coll );

	for(i=0; i< nb_stat; i++) {
		copy_eq_attr(&stat_att[i], &stat_attr[i].attr);
	}

	/* BEGIN PRINT 
	for(i=0; i< nb_stat; i++) {
		if ( stat_attr[i].attr.desc.type == AC_ATTRIB_TEXT ){
		    printf ("%s[%d]=%s\n", stat_attr[i].attr.name, i, 
			stat_attr[i].attr.desc.value.att_txt);
		}
		else{
		    printf ("%s[%d]=%f\n", stat_attr[i].attr.name, i, 
			stat_attr[i].attr.desc.value.att_exp);
		}

	}
	for(i=0; i< nb_dyn; i++) {
                if ( dyn_attr[i].attr.desc.type == AC_ATTRIB_TEXT ){
                    printf ("%s[%d]=%s\n", dyn_attr[i].attr.name, i, 
			dyn_attr[i].attr.desc.value.att_txt);
                }
                else{
                    printf ("%s[%d]=%f\n", dyn_attr[i].attr.name, i, 
			dyn_attr[i].attr.desc.value.att_exp);
                }
 
        }
	END PRINT */

	sts = om$send(msg = message ACrg_collect.ACset_list_attribute
                                       ( &msg, nb_stat, stat_att ),
                                senderid = NULL_OBJID,
                                targetid = stat_box.objid,
                                targetos = stat_box.osnum );
 	__CheckRC(sts,msg,"ACrg_collect.ACset_list_attribute",wrapup );

	strcpy(VDactive_macro,eq_family);
	for( i=0; i<nb_stat; i++)
	{
		if(!strcmp(stat_attr[i].attr.name,"p_macro"))
		{
			strcpy(VDactive_macro, stat_attr[i].attr.desc.value.att_txt );
			break;
		}
	}

	/*| store check in value in static box */
	strcpy( my_att.name, "mac_name" );
	my_att.desc.type	= AC_ATTRIB_TEXT;
	strcpy( my_att.desc.value.att_txt, VDactive_macro );
	sts = om$send(	msg	 = message ACrg_collect.ACadd_list_attribute(
						&msg, 
						1,
						&my_att ),
				senderid = NULL_OBJID,
				targetid = stat_box.objid,
				targetos = stat_box.osnum );
 	__CheckRC(sts,msg,"ACrg_collect.ACadd_list_attribute",wrapup );
	UI_status("");
	
	sts = om$send(msg = message ACrg_collect.ACchg_prop_mgr
					 (1, prop_mgr ),
                                senderid = NULL_OBJID,
                                targetid = stat_box.objid,
                                targetos = stat_box.osnum );
 	__CheckRC(sts,1,"ACrg_collect.ACchg_prop_mgr",wrapup );

	nd$wait_batch(  type            = GR_GEOM_POSTED,
			nb_obj          = 1,
                       	l_object        = &stat_box );

       	nd$exec_batch();	
	_FREE(stat_att);
        }

wrapup :

	_FREE(loc_obj);
	_FREE(dyn_attr);
	_FREE(stat_attr);
        return sts;
}

end implementation Root;
