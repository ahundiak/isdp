/* $Id: SMCpTxti.I,v 1.1.1.1 2001/01/04 21:07:34 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smdrwtxt/imp / SMCpTxti.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCpTxti.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:34  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1998/06/03  22:25:58  pinnacle
# Replaced: smdrwtxt/imp/SMCpTxti.I for:  by mdong for vds
#
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
 *      06/03/98        Ming            TR179801100
 * -------------------------------------------------------------------*/

class implementation SMCpTxt;

#include "string.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "asmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VDSutil_def.h"

#include "grerr.h"
#include "vds.h"
#include "VDmsg.h"
#include "SMmsg.h"
#include "SMcomp_def.h"

#include "AS_status.h"

#define AS_DEBUG
#define SM_MAX_CPCSM_ATTR	80


from	VDSpt	import	VDsettext, VDsetprops;


extern GRclassid	OPP_SMcoll_class_id;


/* ---------------------------------------------------------- */

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
 

 strcpy(info->type,"Drawing copied text");

 *msg = MSSUCC;
 return(OM_S_SUCCESS);
}


/* ---------------------------------------------------------- */

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



/* ---------------------------------------------------------- */

method SMcreate( IGRlong *msg;IGRint nb_att; struct  ACrg_coll *ACrg;
		 IGRshort *att_type; struct GRid *text)
{
IGRlong 		sizebuf, nret;
struct GRmd_env 	act_env;
struct GRid 		my_grid, roots[2];
IGRlong 		status;
IGRint			cn_type, nb_roots;
struct GRsymbology	symb;


 *msg = MSSUCC;
 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 sizebuf = sizeof(struct IGRdisplay);
 gr$get_active_display(		msg    = msg, 
				sizbuf = &sizebuf,
                        	buffer = &symb.display_attr, 
				nret   = &nret);

 sizebuf = sizeof(IGRshort);
 gr$get_active_level(		msg     = msg, 
				sizbuf  = &sizebuf,
                      		buffer  = &symb.level,   
				nret    = &nret);

 sizebuf = sizeof(struct GRmd_env);
 gr$get_module_env(	msg     = msg,
                      	sizbuf  = &sizebuf,
                      	buffer  = &act_env,
                      	nret    = &nret);


 nb_roots = 2;


 roots[1] = *text;

 roots[0].osnum = act_env.md_id.osnum;

 status = om$construct(classid = OPP_SMcoll_class_id,
			osnum   = roots[0].osnum,
			p_objid = &roots[0].objid);
 as$status();
 if(!(status & 1)){
	printf("can't create ACrg\n");   
	goto wrapup;
 }

 status = om$send(msg = message NDnode.NDchg_state(ND_DEL_NO_CH | ND_WAIT_DEL,
  						ND_DEL_NO_CH | ND_WAIT_DEL),

		   targetid = roots[0].objid,
		   targetos = roots[0].osnum);

 as$status();
 if(!(status & 1)){
	printf("ERROR NDnode.NDchg_state\n"); 
	goto wrapup;
 }
  
 status = om$send(msg = message SMmgr.SMSetState(SM_NEW),
		   targetid = my_id);
 as$status();

 status = om$send(msg = message ACncpx.ACmplace
		   ((IGRint *)msg,AChdr_nodisplay | AChdr_nocompute,0,
		    "SMCpTxt",nb_roots, roots,&act_env),
		   targetid = my_id);

 as$status();
 if(!(status & *msg & 1)){
	printf("erreur place macro\n"); 
	goto wrapup;
 }


  /* Put the attributes of the text */

  status = om$send(msg = message SMmgr.SMSetAtt
		   (msg, nb_att,ACrg, att_type),
		   targetid = my_id);
  as$status(sts = (status & *msg),action = GOTO_VALUE, value = wrapup);

 
  cn_type  = ND_COMP;     /* recompute the object */
  nd$wait_batch(type       = GR_GEOM_POSTED,
		l_object   = &my_grid,
		l_obj_info = &cn_type,
		nb_obj     = 1); 

  nd$exec_batch(mode = 0);

/* Commented by Ming on TR179801100
 status = om$send(msg = message GRvg.GRputsymb(msg,&symb),
		   targetid = my_id);
 as$status();
 if(!(status & *msg & 1)){
	printf("Erreur putsymb objid = %d\n",my_id); 
	goto wrapup;
 }
*/
		
 /* delete macro if one of the parent is deleted */


 status = om$send(msg = message NDnode.NDchg_state(ND_DONT_MVRT,ND_DONT_MVRT),
		   targetid = my_id);
 as$status();
 if(!(status & *msg & 1)){
	printf("Erreur NDnode.NDchg_state = %d\n",my_id); 
	goto wrapup;
 }
		

*msg = MSSUCC;
 return OM_S_SUCCESS;
wrapup:

*msg = MSFAIL;
 return OM_E_ABORT;
}




/* ---------------------------------------------------------- */

method SMModify( IGRlong *msg;IGRint nb_att; struct  ACrg_coll *ACrg;
			IGRshort *att_type;struct GRid *text)
{
IGRint			old_nbatt,wait_batch,cn_type;
IGRlong 		status, sizebuf, nret;
IGRshort		is_consume, is_display, type;
IGRboolean		put_batch = FALSE;
struct ACrg_coll	old_ACrg[SM_MAX_CPCSM_ATTR];
struct GRid		old_text;
struct GRid 		my_grid;
struct GRmd_env 	act_env;
struct GRsymbology	symb;

*msg = MSSUCC;


my_grid.objid = my_id;
my_grid.osnum = OM_Gw_current_OS;
 
type = SM_SYST_ATT | SM_DYNAMIC_ATT;

*msg = MSSUCC;
sizebuf = sizeof(struct GRmd_env);
gr$get_module_env(	msg    	= msg, 
			sizbuf	= &sizebuf,
		    	buffer 	= &act_env,
			nret 	= &nret);



sizebuf = sizeof(struct IGRdisplay);
gr$get_active_display(		msg    = msg, 
				sizbuf = &sizebuf,
                        	buffer = &symb.display_attr, 
				nret   = &nret);

sizebuf = sizeof(IGRshort);
gr$get_active_level(		msg     = msg, 
				sizbuf  = &sizebuf,
                      		buffer  = &symb.level,   
				nret    = &nret);


status = om$send(msg = message SMCpTxt.SMGetParameters
		   (msg, &old_nbatt, old_ACrg, NULL, &old_text),
		   targetid = my_id);
if(!(status & *msg & 1)){
    	printf("Erreur retrieving parameter of perpendicular\n");
	goto wrapup;
}


if(!(SMIsACrgEqual(ACrg, nb_att, old_ACrg, old_nbatt))){
	status = om$send(msg = message SMmgr.SMResetAtt
		      (msg,nb_att,ACrg,att_type),
		      targetid = my_id);
	as$status();
	if(!(status & 1)){
                printf("Erreur SMmgr.SMResetAtt\n");
		goto wrapup;
	}

	put_batch = TRUE;
}


if(put_batch){
    
	/* must unconsume the old_text */

  	is_consume = 0;
  	is_display = 0;
  	status = VDconsume_and_display( old_text, is_consume, 
						is_display, 
						&act_env );
  	as$status( );

     	my_grid.objid = my_id;
     	my_grid.osnum = OM_Gw_current_OS;

     	cn_type    = ND_COMP; /* recompute the object */
     	status = nd$wait_batch(type       = GR_GEOM_POSTED,
			    l_object   = &my_grid,
			    l_obj_info = &cn_type,
			    nb_obj     = 1);

     	nd$mod_batch(request    = ND_INQ,p_ret_mode = &wait_batch);
     
     	if(wait_batch != ND_DEFER) /* else nothing to do */
     	nd$exec_batch(mode = ND_DISP_ROOT|ND_DISP_BODY);

}


*msg = MSSUCC;
return OM_S_SUCCESS;

wrapup:
*msg = MSFAIL;
return OM_E_ABORT;

}

/* ---------------------------------------------------------- */

method SMGetParameters( IGRlong *msg;IGRint *nb_att; struct  ACrg_coll *ACrg;
			IGRshort *att_type; struct GRid *text; )
{
IGRlong 		status;
IGRint  		count;

 *msg = MSSUCC;

 if(text != NULL){
 	status = om$send(msg = message NDnode.NDget_objects
		  (ND_ROOT , text, 1 ,NULL, 1, 1,&count),
		      targetid = my_id);
 	if(status != OM_S_SUCCESS){
		printf("ERROR NDnode.NDget_objects\n"); 
		goto wrapup;
 	}
 }

 /* Get attributes  */

 if(nb_att && ACrg){
 	status = om$send( msg = message SMmgr.SMListAtt
		    (msg, SM_MAX_CPCSM_ATTR ,
		     nb_att,ACrg,att_type),
		      targetid = my_id);
 	as$status(action = RET_STATUS);
 	if(!(status & (*msg) &1 ) ){
		printf("ERROR retrieving the attributes of the main text\n"); 
		goto wrapup;
 	}
 }

*msg = MSSUCC;
return OM_S_SUCCESS;

wrapup:

*msg = MSFAIL; 	
return OM_W_ABORT;

}



/*----------------------------------------------------------------------------*/
method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

	long		sts ;	/* OM return code	*/

	/*
	 * name.
	 */
	myDef->info		= SM_I_ObjCpTxt ;
	myDef->type		= 0 ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/


end implementation SMCpTxt;


