/* $Id: SMSplNotif.I,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/cmd / SMSplNotif.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMSplNotif.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1998/03/23  15:04:32  pinnacle
# Replaced: smspace/cmd/SMSplNotif.I for:  by impd for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1997/01/30  18:58:52  pinnacle
# Replaced: smspace/cmd/SMSplNotif.I for:  by jwfrosch for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1996/04/29  09:08:40  pinnacle
# Replaced: smspace/cmd/SMSplNotif.I for:  by ksundar for vds.240
#
# Revision 1.4  1996/03/22  14:19:02  pinnacle
# Replaced: vdlocate/cmd/VDS_LOCATE.sl for:  by ksundar for vds.240
#
# Revision 1.3  1996/01/02  10:19:42  pinnacle
# Replaced: smspace/cmd/SMSplNotif.I for:  by rgade for vds.240
#
# Revision 1.2  1995/09/26  20:29:58  pinnacle
# Replaced: smspace/cmd/SMSplNotif.I for:  by sundar for vds.240
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

 /*               SMBndNotif.I                    */
 /*   Methods  and functions for SMSpltSrf        */
 /*   Methods for the CO                          */
 /*   Pascale Lacroix  (ISDC)			  */
 /*   Creation date July-92                       */

class implementation SMCmdSpltSf;


#include <string.h>
#include "expression.h"
#include "expmacros.h"
#include "macro.h"
#include "acmacros.h"
#include "AS_status.h"
#include "parametric.h"

#include "FI.h"

#include "SMmsg.h"
#include "SMspacecom.h"
#include "vdsmacros.h"
#include "VDmem.h"

#define VD_DEBUG

#include "VDdebug.h"

#define MAX_SURF        14
#define MAX_TEMP        17      /* number of templates */

extern GRclassid 	OPP_SMSpltSrf_class_id, OPP_EMSsurface_class_id,
			OPP_ACpretend_class_id;
extern			SMspace_getTempDefString();

from GRgraphics		import GRdelete, GRdisplay;
from ACmacro_defn 	import ACgive_upscan;
from NDnode		import NDgive_structure, NDconnect, NDdisconnect,
				NDchg_state,NDget_objects;
from NDmacro		import ACreturn_foot;
from ASnode		import ASreturn_go;
from GRvg		import GRputsymb, GRputname, GRgetname;
from SMmgr		import SMGetAttDbl,SMGetAttTxt;
from EMSsurface		import EMshow_normals ;
from ACncpx		import ACmplace,ACchg_STATE,ACget_STATE;
from VDSroot		import VDcompute;

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*		- Also used in method "SMSpltSrf.ACconstruct_feet"		*/
/*		- Controls "Intersect->Offset" / "Offset->Intersect"		*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

static int	VD_offset_before_intersect;

#define	OFFSET_MASK	0x1000

/*************************************************************************/

#define	_start		0
#define	_restart	1
#define	_loc_macro	2
#define	_reloc_macro	3
#define	_modif_form	4
#define	_load_support	5
#define	_del_elt	6
#define	_get_normal	7
#define	_load_from_occ	8

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

void	VD_offset_intersect
(
  struct GRid	macro_id,
  int		mytype
)
{
  int	sts, ACstate = 0, ACold_state = 0, ACmask = OFFSET_MASK, tp = ND_COMP;
  long	msg;

  __enterFunction ( name = "VD_offset_intersect" );

  /* Control VD_offset_before_intersect */

  sts =
  om$send (	msg	 = message ACncpx.ACget_STATE( &ACold_state ),
		senderid = NULL_OBJID,
		targetid = macro_id.objid,
		targetos = macro_id.osnum);

  if ( VD_offset_before_intersect )
  {
    ACstate = ACmask;		// Set ACmask bit
  }
  else
  {
    ACstate = ~ACmask;		// Clear ACmask bit
  }
  sts =
  om$send (	msg	 = message ACncpx.ACchg_STATE( ACmask, ACstate ),
		senderid = NULL_OBJID,
		targetid = macro_id.objid,
		targetos = macro_id.osnum);

  sts =
  om$send (	msg	 = message ACncpx.ACget_STATE( &ACstate ),
		senderid = NULL_OBJID,
		targetid = macro_id.objid,
		targetos = macro_id.osnum);

  if ( ACstate != ACold_state && mytype == MODIFY )
  {
    sts =
    om$send (	msg	 = message VDSroot.VDcompute ( &msg, &tp ),
		senderid = NULL_OBJID,
		targetid = macro_id.objid,
		targetos = macro_id.osnum);
  }

  __printf ( "macro_id = [%d,%d], ACold_state = %#x, ACstate = %#x, VD_offset_before_intersect = %d",
		`macro_id.osnum, macro_id.objid, ACold_state, ACstate, VD_offset_before_intersect` );

  __exitFunction ( name = "VD_offset_intersect" );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method init_all ( long * sts )
{
  int		  status = OM_S_SUCCESS;

 *sts = OM_S_SUCCESS;

 status = om$send(msg = message SMCmdVol.init_all(sts),
			mode = OM_e_wrt_message,
		      	targetid = my_id);

 me->start_index = 2;
 strcpy(me->macro_name,"SMSpltSrf");
 strcpy(me->auto_name,"SMSpltSrf_0");

 me->select_row = 0;
 me->nb_col_limits = 3;
 me->offset = 0.;
 me->old_offset = 0.;
 VD_offset_before_intersect = FALSE;

 if(me->mytype == MODIFY)
 {
     FIg_set_text(me->forms[0].form_ptr,F_TITLE, "Modify Split Surface");
     FIg_erase   (me->forms[0].form_ptr, DISCONNECT );
 }
 else
 {
     FIg_display (me->forms[0].form_ptr, DISCONNECT );
 }

status = OM_S_SUCCESS;
goto quit;

quit:
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method form_notification (int form_label; int gadget_label ; double value ;
			    char * form_ptr)
{
  int		  status = OM_S_SUCCESS;

 int 			i, stat = OM_S_SUCCESS;
 int  			sel_flag, num_rows;
 int  			pos, col, row, toggl = 0;
 long			test;

  if ( form_ptr == NULL ){
 	/*| no form_ptr set */
     	return( OM_E_INVARG );
 }

 FIg_set_text(form_ptr,FI_MSG_FIELD,"");
 UI_message("");

 switch( gadget_label ){
	case FI_ACCEPT:
	case FI_EXECUTE:
   	case FI_CANCEL:
   	case FI_RESET:
   	case OCC_NAME:
   	case INFINITE:

		status = om$send(msg = message SMCmdVol.form_notification(
				form_label, gadget_label,value, form_ptr),
                        mode = OM_e_wrt_message,
                        targetid = my_id);
 		if(!(status & 1)){
			printf("ERROR form_notification \n");
 			return status;
 		}

     		break;

	case OFFSET_INTERSCT:
		stat = FIg_get_state ( form_ptr, OFFSET_INTERSCT, &toggl );
		if ( ! toggl )
		{
		  VD_offset_before_intersect = FALSE;
		}
		else
		{
		  VD_offset_before_intersect = TRUE;
		}

     		break;

	case DISCONNECT:
		if(me->mytype == PLACE){
			UI_prompt("");
                	stat = om$send(msg = message SMCmdSpltSf.delete_elt(&test),
                                targetid = my_id);

        		if(!(stat & test & 1)){
 				ex$message(msgnumb = SM_S_ErrDel);
 				goto quit;
        		}
                	_put_response(resp = DEL_ELT);
			break;
		}

    		break;

	case LOAD:
		if(me->mytype == MODIFY){
			UI_prompt("");
                	stat = om$send(msg = message SMCmdSpltSf.delete_elt(&test),
                                targetid = my_id);

        		if(!(stat & test & 1)){
 				ex$message(msgnumb = SM_S_ErrDel);
 				goto quit;
        		}
                	_put_response(resp = DEL_ELT);
			break;
		}
     		else _put_response(resp = LOAD_OCC);

    		break;

	case LIMITS:
                if(me->state == _get_normal ) {
			for(i=0;i<3;i++)
                        FIfld_set_select(form_ptr,LIMITS, me->select_row, i, TRUE);
                        ex$message(msgnumb = SM_S_AreaNeed);
                        break;
                }

     		FImcf_get_active_col(  form_ptr,LIMITS, &col, &pos);
     		FIfld_get_active_row(form_ptr,LIMITS, &row, &pos);
     		FIfld_get_select(form_ptr,LIMITS,row, 0,&sel_flag);

		if ( row > 0 ) {
                      ex$message(field = PROMPT_FIELD,msgnumb = SM_P_IdHltTmp );
		      if(me->limits[row-1].surf.located_obj.objid == NULL_OBJID)
			{
	                        me->select_row = me->nb_limits;
 				FIfld_set_active_row(	me->forms[0].form_ptr,
							LIMITS,me->select_row,
  							me->pos);
				if(row == 0) _put_response(resp = LOAD_SUPPORT);
				break;
			}
		}
                else {
                      ex$message( field = PROMPT_FIELD,msgnumb = SM_P_IdSup );
		}

      		if(me->delete_elt ){
			/* get the row to be deleted */

			me->delete_row = (sel_flag == TRUE) ? row : -1;
     			if(row == 0 && sel_flag == TRUE){
     				/* support cannot be disconnect */
 				FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
 					"The support cannot be disconnected");
     				FIfld_set_select(me->forms[0].form_ptr, LIMITS, row, 0, FALSE);
  				FIfld_set_select(me->forms[0].form_ptr, LIMITS,	row, 1, FALSE);
  				FIfld_set_select(me->forms[0].form_ptr, LIMITS,	row, 2, FALSE);
				me->delete_row = -1;
  				break;
  			}
     			if(sel_flag == TRUE){
				me->select_row = row;
        			stat = om$send(msg = message SMCmdSpltSf.DispAll
        						(&test),
 		      			targetid = my_id);
        			if(!(stat & test & 1)){
 					ex$message(msgnumb = SM_S_ErrDsp);
 					goto quit;
        			}
				me->select_row = 0;
 				FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
					"Validate with Disconnect button");
				break;

     			}
 			FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
				"Select the Element to be disconnected");
			break;
		}
     		stat = FIfld_get_num_rows(form_ptr,LIMITS, &num_rows);
     		if(stat != FI_SUCCESS) {
			printf("error FIfld_get_num_rows\n");
			goto quit;
     		}
     		FImcf_get_active_col(  form_ptr,LIMITS, &col, &pos);
     		FIfld_get_active_row(form_ptr,LIMITS, &row, &pos);

        	me->select_row = row;
		me->pos = pos;
     		FIfld_get_select(form_ptr,LIMITS,me->select_row,
     						0,&sel_flag);
     		if(sel_flag == TRUE){
        		stat = om$send(msg = message SMCmdSpltSf.display_normal(&test),
 		      		targetid = my_id);
        		stat = om$send(msg = message SMCmdSpltSf.DispAll
        						(&test),
 		      			targetid = my_id);
        		if(!(stat & test & 1)){
 					ex$message(msgnumb = SM_S_ErrDsp);
 					goto quit;
        		}
        		break;
     		}
     		break;

 } /* END switch ( gadget_label ) */

  return OM_S_SUCCESS;
quit:
  return OM_S_SUCCESS;
}

/* ----------------------------------------------------------------- */
/*
/* store the located object in instance
/*
/**/

method store_obj(long	*sts; int	max_obj)
{
 *sts = OM_S_SUCCESS;

 if(me->select_row == 0){
        /* store support */

        om$send(msg = message SMCmdSpltSf.store_support(sts),
                                targetid = my_id);
        return OM_S_SUCCESS;
 }

 om$send(msg = message SMCmdVol.store_obj(sts, MAX_SURF),
                        mode = OM_e_wrt_message,
                        targetid = my_id);

return OM_S_SUCCESS;

}

/* ----------------------------------------------------------------- */
/*
/* verify about the deleted object
/*
/**/

method verify_obj(long *sts)
{
 int	i, stat;

 *sts = OM_S_SUCCESS;

  /*
   * Set State of Toggle "OFFSET_INTERSCT" at wake_up
   */
  if ( VD_offset_before_intersect )
  {
    stat = FIg_set_state ( me->forms[0].form_ptr, OFFSET_INTERSCT, 1 );
  }
  else
  {
    stat = FIg_set_state ( me->forms[0].form_ptr, OFFSET_INTERSCT, 0 );
  }

 om$send(msg = message SMCmdVol.verify_obj(sts),
			mode = OM_e_wrt_message,
		      	targetid = my_id);

 if(me->Fence == FALSE && me->limits[0].surf.located_obj.objid != NULL_OBJID &&
	! ( om$is_objid_valid( osnum = me->limits[0].surf.located_obj.osnum,
			       objid = me->limits[0].surf.located_obj.objid) &1) ){
   	ex$message(msgnumb = SM_S_ElDel);
   	me->state = _terminate;
   	return OM_S_SUCCESS;
 }

 for(i=0;i<me->nb_FenceObjects;i++){
 	if(me->FenceObjects[i].obj_id.objid != NULL_OBJID &&
	! ( om$is_objid_valid( osnum = me->FenceObjects[i].obj_id.osnum,
			       objid = me->FenceObjects[i].obj_id.objid)&1) ){
   	 	ex$message(msgnumb = SM_S_ElDel);
   	 	me->state = _terminate;
   	 	return OM_S_SUCCESS;
	}
 }

 return OM_S_SUCCESS;

}

/* ----------------------------------------------------------------- */
/*
/* store the element that must be the support element
/*
/**/

method store_support(long *sts)
{
 enum GRdpmode		mode;
 int			i,nb_obj, stat;
 long			test;
 char			name[MY_MAX_CHAR];
 struct GRobj_env  	*LocatedObjects;

 *sts = OM_S_SUCCESS;

 FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");

 LocatedObjects = NULL;
 as$start_fence(set= &me->event1.located_object[0].located_obj,
                 set_env = &me->event1.located_object[0].module_info,
                 nb_obj = &nb_obj,
                 p_obj_env = &LocatedObjects,
                 response = me->response,
                 response_data = me->response_data);

 if(nb_obj == 0)
   {
     	/*No obj selected*/
     	*sts = NO_OBJ;
	goto wrapup;
   }
  if(nb_obj > 1 && me->mytype == MODIFY ){
   	/* no fence locate is allowed for modify*/
 	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"No fence is allowed for modify");
     	*sts = MD_FENCE;
     	goto wrapup;
  }
  if(me->limits[0].surf.located_obj.objid != NULL_OBJID){
	mode = GRhe;
     	stat = om$send(msg = message SMCmdSpltSf.DispLoc(
     						0, mode),
                        		targetid= my_id ) ;

     	if (!(stat & 1)){
                ex$message(msgnumb = SM_S_ErrDsp);
 		*sts = OM_E_ABORT;
		goto wrapup;
        }
  }
  if(nb_obj <= 1 ){

   	me->Fence = FALSE;
    	me->IndexFcObj = 0;
   	me->nb_FenceObjects = 0;
   	_FREE(me->FenceObjects ) ;

  }
  if(nb_obj > 1) {
   	me->Fence = TRUE;
    	me->IndexFcObj = 0;
  	me->nb_FenceObjects = nb_obj;
   	_FREE(me->FenceObjects ) ;
   	me->FenceObjects = _MALLOC(nb_obj, struct GRobj_env);
   	if(me->FenceObjects == NULL){
   		printf("ERROR, Bad Allocation\n");
   		*sts = OM_E_ABORT;
   		goto wrapup;
   	}
	for(i = 0; i< nb_obj; i++) {
     			stat = as$make_source(
     					go_grid = LocatedObjects[i].obj_id,
			     		mod_env = &LocatedObjects[i].mod_env,
			     		as_os   = me->act_env.md_id.osnum,
			     		as_grid = &me->FenceObjects[i].obj_id);
     			as$status(sts = stat);
        		if(!(stat & 1))
          		{
 				printf("ERROR as$make_source\n");
 				*sts = OM_E_ABORT;
 				goto wrapup;
          		}
          		me->FenceObjects[i].mod_env = LocatedObjects[i].mod_env;
	}
	/* for normal display */

	me->limits[0].surf.located_obj = me->FenceObjects[0].obj_id;
	me->limits[0].surf.module_info = LocatedObjects[0].mod_env;

  }
  if(nb_obj <= 1){
  	stat = as$make_source(
     			     go_grid = me->event1.located_object[0].located_obj,
			     mod_env = &me->event1.located_object[0].module_info,
			     as_os   = me->act_env.md_id.osnum,
			     as_grid = &me->limits[0].surf.located_obj);
  	as$status(sts = stat);
  	if(!(stat & 1))
    	{
 		printf("ERROR as$make_source\n");
 		*sts = OM_E_ABORT;
 		goto wrapup;
    	}
	me->limits[0].surf.module_info = me->event1.located_object[0].module_info;
  }

  me->nb_limits ++;

  stat = om$send(msg = message SMCmdSpltSf.DispAll(&test),
 		      targetid = my_id);
  if(!(stat & test & 1))
  {
 	ex$message(msgnumb = SM_S_ErrDsp);
 	*sts = OM_E_ABORT;
 	goto wrapup;
  }

 name[0] = '\0';
 vd$get_name(name = name, obj = &(me->limits[0].surf.located_obj));
 if(name[0] == '\0') {
        /* try get name on the graphic object */
        vd$get_name(name = name, obj = &(me->event1.located_object[0].located_obj ));
        if(name[0] == '\0') strcpy(name, "defined");
 }
 FIfld_set_text(me->forms[0].form_ptr, LIMITS,0, 1, name, TRUE);

wrapup:

ASend_fence();
return OM_S_SUCCESS;
}

/* ----------------------------------------------------------------- */

method store_orient(long *sts)
{
 *sts = OM_S_SUCCESS;

 if(me->event1.event.keyin[0] == 'n' || me->event1.event.keyin[0] == 'N')
 	me->limits[me->select_row].rev = 1;
 else 	me->limits[me->select_row].rev = 0;

 if(me->limits[me->select_row].rev)
   	FIfld_set_text(me->forms[0].form_ptr, LIMITS,me->select_row, 2,
   			"R", FALSE);
 else
   	FIfld_set_text(me->forms[0].form_ptr, LIMITS,me->select_row, 2,
   			"", FALSE);
 return OM_S_SUCCESS;

}

/* ----------------------------------------------------------------- */

method reverse_orient(long *sts)
{
 *sts = OM_S_SUCCESS;

 me->limits[me->select_row].rev = 1;
 FIfld_set_text(me->forms[0].form_ptr, LIMITS,me->select_row, 2,
   			"R", FALSE);
 return OM_S_SUCCESS;

}
/* ----------------------------------------------------------------- */

method accept_orient(long *sts)
{
 *sts = OM_S_SUCCESS;

 me->limits[me->select_row].rev = 0;
 FIfld_set_text(me->forms[0].form_ptr, LIMITS,me->select_row, 2,
   			"", FALSE);

 return OM_S_SUCCESS;

}
/* ----------------------------------------------------------------- */

method GadgOn(long *sts)
{
 *sts = OM_S_SUCCESS;

 FIg_enable(me->forms[0].form_ptr,FI_EXECUTE);
 FIg_enable(me->forms[0].form_ptr,FI_RESET);
 FIg_enable(me->forms[0].form_ptr,FI_ACCEPT);

 return OM_S_SUCCESS;

}
/* ----------------------------------------------------------------- */

method GadgOf(long *sts)
{
 *sts = OM_S_SUCCESS;

 FIg_disable(me->forms[0].form_ptr,FI_EXECUTE);
 FIg_disable(me->forms[0].form_ptr,FI_RESET);
 FIg_disable(me->forms[0].form_ptr,FI_ACCEPT);

 return OM_S_SUCCESS;

}

/* ----------------------------------------------------------------- */
/*
/* set the active row, and display of the objects
/*
/**/

method next_row(long *sts)
{
 int			i, num_rows, stat;

 *sts = OM_S_SUCCESS;

////////// HF 10/01/96 : Copied from "SMCmdVol.next_row" (that is where this FIX really belongs)

  	FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"");

	stat = FIfld_get_num_rows(me->forms[0].form_ptr, LIMITS, &num_rows);
	if(stat != FI_SUCCESS) {
 		printf("error FIfld_get_num_rows: %d\n",stat);
 		*sts = OM_E_ABORT;
 		return OM_S_SUCCESS;
	}
	for(i=0;i<num_rows;i++){
   		FIfld_set_select(me->forms[0].form_ptr, LIMITS,i, 0, FALSE);
   		FIfld_set_select(me->forms[0].form_ptr, LIMITS,i, 1, FALSE);
   		FIfld_set_select(me->forms[0].form_ptr, LIMITS,i, 2, FALSE);	// Move-on did not unselect
	}
//////////
 	om$send(msg = message SMCmdVol.next_row(sts),
			mode = OM_e_wrt_message,
		      	targetid = my_id);

 	if( (*sts) == END_TEMP && me->limits[0].surf.located_obj.objid == NULL_OBJID){
		FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
 				"A Support must be defined");
		return OM_S_SUCCESS;
 	}

return OM_S_SUCCESS;

}

/* ----------------------------------------------------------------- */
/*
/* display the object at the given index (all objects if it is
/* the index of a fence).
/*
/**/

method DispLoc(int index; enum GRdpmode mode)
{
 int			 stat;
 struct  GRid            currentModule ;
 long                    sts ;
 struct GRlc_info	 obj;

 ex$get_cur_mod( id      = &currentModule.objid,
                 osnum   = &currentModule.osnum ) ;

 om$send(msg = message SMCmdVol.DispLoc(index, mode),
			mode = OM_e_wrt_message,
		      	targetid = my_id);

 if (index == 0 && me->Fence == FALSE){
	if(me->limits[0].surf.located_obj.objid == NULL_OBJID) return OM_S_SUCCESS;

	stat = om$send( msg = message ASnode.ASreturn_go(
                                          &obj.located_obj,
                                          &obj.module_info.md_env.matrix_type,
                                          obj.module_info.md_env.matrix),
                        targetid = me->limits[0].surf.located_obj.objid,
                        targetos = me->limits[0].surf.located_obj.osnum );
	if(stat & 1)  /* Jean :Not found : one sourcein not connected */{

		stat = om$send(msg     = message GRgraphics.GRdisplay(
				&sts,
                                &obj.module_info.md_env.matrix_type,
                                obj.module_info.md_env.matrix,
                                &mode,
                                &currentModule ),
         	  targetid= obj.located_obj.objid,
         	  targetos= obj.located_obj.osnum ) ;
 		as$status(sts = stat);
	}

 }

return OM_S_SUCCESS ;

}

/* ----------------------------------------------------------------- */
/*
/* store the located occurence of the macro (for modify or locate from
/* occurence) and fill the info in the form
/*
/**/

method store_occ(long *sts)
{
 int			i, k, MyProps, stat, count = 0,
 			num_rows, Nb_Max_Temp ;
 long			attr ;
 char			*c, name[MY_MAX_CHAR], text[MY_MAX_CHAR];
 long			test,msg;
 struct GRid		go, *roots, mac;
 int			def_properties;
 struct ret_struct      str;
 int			ACstate = 0;

 *sts = OM_S_SUCCESS;

 FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");
 dp$erase_hilite(msg = &msg);
 me->select_row = 0;
 me->pos = 0;
 roots = NULL;

 me->macro_id = me->event1.located_object[0].located_obj;

 stat = om$send(msg = message NDnode.NDget_objects
                   (ND_ROOT | ND_IN_BUF,NULL,0,&roots,0,OM_K_MAXINT,&count),
                   senderid = NULL_OBJID,
                   targetid = me->macro_id.objid,
                   targetos = me->macro_id.osnum );
 as$status(sts = stat);
 if(stat != OM_S_SUCCESS || count > MAX_TEMP)
  {printf("ERROR retrieve roots of the macro \n"); goto wrapup;}

 if(count > 0)  /* Common case : macro is OK */
  {
    me->old_nb_limits = me->nb_limits = count - 2;

    /* Get the expression mask */
    stat = om$send(msg = message NDnode.NDgive_structure(&msg, &str, NULL),
		   targetid= roots[0].objid,
		   targetos= roots[0].osnum);
    as$status(sts = (stat & msg),action = GOTO_VALUE,value = wrapup);
    MyProps = (IGRint) str.var.root_pm_st.value;

    /* Get the offset */
    stat = om$send(msg = message NDnode.NDgive_structure(&msg, &str, NULL),
		   targetid= roots[1].objid,
		   targetos= roots[1].osnum);
    as$status(sts = (stat & msg),action = GOTO_VALUE,value = wrapup);
    me->offset = str.var.root_pm_st.value;

 }
 else     /* Jean : 5/4/93  Macro is broken : user  will relocate parents*/
  {
    ex$message(msgnumb =  SM_I_NoParMac);

    me->old_nb_limits = me->nb_limits = 0;

     /* Recreate an expression with default parameter */
    MyProps    = 0x18000;
    me->offset = 0.0;
  }

 if(MyProps & 0x8000) me->infinite = 1;
 else                 me->infinite = 0;

 if(MyProps & 0x10000) me->extend = 1;
 else                  me->extend = 0;

 SMConvDistIntExt(me->offset, &me->offset, me->act_env.md_id.osnum);

 if( MyProps & 0x4000) me->limits[0].rev = 1;
 else me->limits[0].rev = 0;

 k = 0;
 for(i=0;i< me->nb_limits;i++)  {
 		stat = GetEnvFrObj(	&roots[i+2],
 		 			&me->limits[i].surf.module_info,
 		 			NULL);
 		if(!(stat & 1))
		  {  /* Jean: if error macro has probably lost one parent */
                     ex$message(msgnumb = SM_I_LostPar);
		  }
 		me->limits[i].surf.located_obj =  roots[i+2];

   if(i==0) continue;
   if((1<<k) & MyProps) me->limits[i].rev = 1;
   else	                me->limits[i].rev = 0;
   k++;
 }
 if(me->mytype == MODIFY) {
 	me->old_macro_id = me->macro_id ;
 	for(i=0;i< me->old_nb_limits;i++) {
 		me->old_limits[i] = me->limits[i];
 	}
 }
 FImcf_get_attr(me->forms[0].form_ptr,LIMITS, &attr);
 attr = attr | FI_ROW_SELECT;
 FImcf_set_attr(me->forms[0].form_ptr,LIMITS, attr);

 vd$get_name(name = me->def_name, obj = &me->macro_id);

 if(me->mytype == MODIFY) {
        strcpy(me->old_def_name,me->def_name);
 	me->old_infinite = me->infinite;
 	me->old_extend = me->extend;
 	me->old_offset = me->offset;
 }
 else GetDefName("SMSpltSrf_0",me->def_name);

 FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
 FIfld_set_value(me->forms[0].form_ptr, OFFSET, 0, 0, me->offset, FALSE);

 if(me->infinite) FIg_set_state_off(me->forms[0].form_ptr, INFINITE);
 else FIg_set_state_on(me->forms[0].form_ptr, INFINITE);

 if(me->extend) FIg_set_state_off(me->forms[0].form_ptr, EXTEND);
 else FIg_set_state_on(me->forms[0].form_ptr, EXTEND);

 stat = ac$find_macro_defn( action      = ACfind_load,
                            macro_name  = "SMSpltSrf",
                            p_macro_defn_id     = &mac );

 if (!(stat & 1) || IF_NULL_OBJID(mac.objid))
  {printf("error macro not found\n"); goto wrapup;}

 Nb_Max_Temp = 0;
 stat = om$send(msg = message ACmacro_defn.ACgive_upscan
                             (&Nb_Max_Temp,&def_properties,&me->dup),
                           targetid = mac.objid,
                           targetos = mac.osnum );

 as$status(sts = stat);
 if(!(stat & 1)){printf("error  ACmacro_defn.ACgive_upscan\n"); goto wrapup;}

 k=0;
 for(i=2;i<Nb_Max_Temp;i=i+1){
	SMspace_getTempDefString( &msg, me->dup[i].type, text );

	FIfld_set_text(me->forms[0].form_ptr, LIMITS, k, 0,
				me->dup[i].prompt, FALSE);
	if(k < me->nb_limits){
		strcpy(name, "defined");
		if(me->Fence == FALSE && me->limits[k].surf.located_obj.objid != NULL_OBJID){
		   vd$get_name(name = name, obj = &(me->limits[k].surf.located_obj));
		   if(name[0] == '\0') {
        		/* try get name on the graphic object */
        		stat = om$send( msg = message ASnode.ASreturn_go(
                                          &go,
                                          NULL,
                                          NULL),
			     targetid = me->limits[k].surf.located_obj.objid,
                             targetos = me->limits[k].surf.located_obj.osnum );
        		if(!(stat&1))  strcpy(name, "missing"); /* Jean */
        		else           vd$get_name(name = name, obj = &go);
  			if(name[0] == '\0') strcpy(name, "defined");
		   }
		}
		FIfld_set_text(me->forms[0].form_ptr, LIMITS, k, 1,name, FALSE);
	}
 	else
		FIfld_set_text(me->forms[0].form_ptr, LIMITS, k, 1,
					text, FALSE);
	if(me->limits[k].rev == 0)
			FIfld_set_text(me->forms[0].form_ptr, LIMITS, k, 2,
					"", FALSE);
	else FIfld_set_text(me->forms[0].form_ptr, LIMITS, k, 2,
					"R", FALSE);
	k++;
 }

 /* Control VD_offset_before_intersect */

 stat =
 om$send(msg	 = message ACncpx.ACget_STATE( &ACstate ),
	 senderid = NULL_OBJID,
	 targetid = me->macro_id.objid,
	 targetos = me->macro_id.osnum);

 if ( ACstate & OFFSET_MASK )
 {
   VD_offset_before_intersect = TRUE;
 }
 else
 {
   VD_offset_before_intersect = FALSE;
 }
 stat = FIg_set_state ( me->forms[0].form_ptr, OFFSET_INTERSCT, VD_offset_before_intersect );

 stat = FIfld_get_num_rows(me->forms[0].form_ptr,LIMITS, &num_rows);
 if(stat != FI_SUCCESS) {
	printf("error FIfld_get_num_rows: %d\n",stat);
	goto wrapup;
 }

 FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 0, TRUE);
 FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 1, TRUE);
 FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 2, TRUE);
 FIfld_set_active_row(me->forms[0].form_ptr, LIMITS,me->select_row,
  				me->pos);
 stat = om$send(msg = message SMCmdSpltSf.DispAll(&test),
 		      targetid = my_id);
 if(!(stat & test & 1)){
 		ex$message(msgnumb = SM_S_ErrDsp);
 		goto wrapup;
 }

 return OM_S_SUCCESS;

wrapup:
 *sts = OM_E_ABORT;
 return OM_S_SUCCESS;
}

/* ----------------------------------------------------------------- */
/*
/* reinit all instances, reinit form, set all default prompts and
/* template types of the macro
/*
/**/

method reset_form(long *sts)
{
 int		i;

 *sts = OM_S_SUCCESS;

 om$send(msg = message SMCmdVol.reset_form(sts),
			mode = OM_e_wrt_message,
		      	targetid = my_id);

 me->offset = 0;

 me->select_row = 0;

 for(i=0;i< 3;i++)
 	FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, i, TRUE);

 FIfld_set_active_row(me->forms[0].form_ptr, LIMITS,0,
  				me->pos);

 if(me->mytype != MODIFY)
 {
	FIfld_set_value(me->forms[0].form_ptr, OFFSET, 0, 0,
 				me->offset, FALSE);
	FIg_set_state_off(me->forms[0].form_ptr, ORIENT);
	FIg_set_state_off(me->forms[0].form_ptr, INFINITE);
	FIg_set_state_off(me->forms[0].form_ptr, EXTEND);

	FIg_display (me->forms[0].form_ptr, DISCONNECT );
 }
 else {
	me->offset = me->old_offset;

 	FIfld_set_value(me->forms[0].form_ptr, OFFSET, 0, 0,
 				me->old_offset, FALSE);
	if(me->old_infinite)
		FIg_set_state_off(me->forms[0].form_ptr, INFINITE);
	else 	FIg_set_state_on(me->forms[0].form_ptr, INFINITE);

	if(me->old_extend)
		FIg_set_state_off(me->forms[0].form_ptr, EXTEND);
	else 	FIg_set_state_on(me->forms[0].form_ptr, EXTEND);

	FIg_erase   (me->forms[0].form_ptr, DISCONNECT );
 }

return OM_S_SUCCESS;

}

/* ----------------------------------------------------------------- */
/*
/* Reset the Gadgets of the form and init instances
/*
/**/

method clear_form(long *sts )
{

 *sts = OM_S_SUCCESS;

 om$send(msg = message SMCmdVol.clear_form(sts),
			mode = OM_e_wrt_message,
		      	targetid = my_id);

 FIg_set_text(me->forms[0].form_ptr,OFFSET,"");

 me->offset = 0.;

 FIg_set_state_off(me->forms[0].form_ptr, ORIENT);
 if(me->mytype == MODIFY)
 {
	FIg_set_text(me->forms[0].form_ptr, LOAD,"Disconnect");
	FIg_erase   (me->forms[0].form_ptr, DISCONNECT );
 }
 else
 {
	FIg_display (me->forms[0].form_ptr, DISCONNECT );
 }

return OM_S_SUCCESS;
}

/* ----------------------------------------------------------------- */
/*
/* Get the info from the form to place or modify the macro
/*
/**/

method save_all(long *sts )
{
  int 			i, k,fc, nb_obj, nb_roots, num_char = MY_MAX_CHAR,
			sel_flag, r_pos, stat, nb_fail, state;
  char 			text[MY_MAX_CHAR];
  long			test,sizebuf, nret, msg;
  struct GRid 		mac, *roots, *old_roots;
  unsigned int		VMask;
  struct GRsymbology	symb;
  IGRdouble		offset;

  __enterMethod ( name = "save_all" );

  	*sts = OM_S_SUCCESS;

  	roots = NULL;
  	old_roots = NULL;
  	mac.objid = NULL_OBJID;
  	mac.osnum = me->act_env.md_id.osnum;
        dp$erase_hilite(msg = &msg);

  	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");

	if(me->limits[0].surf.located_obj.objid == NULL_OBJID){
     		ex$message(msgnumb = SM_S_SupNoDef);
  		FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
			"ERROR, support not defined");
		*sts =  OM_E_ABORT;
		goto quit;
  	}

	if(me->nb_limits == 0){
		ex$message(msgnumb = SM_E_NoObjLoc);
  		FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
			"ERROR, No objects located");
		*sts =  OM_E_ABORT;
		goto quit;
	}

 	/* delete duplicated objects */

	for(i=0;i<me->nb_limits;i++){
		if(me->Fence == TRUE){
			for(k=0;k<me->nb_FenceObjects;k++){
				if(me->limits[i].surf.located_obj.objid == me->FenceObjects[k].obj_id.objid &&
				me->limits[i].surf.located_obj.osnum == me->FenceObjects[k].obj_id.osnum)
					me->limits[i].surf.located_obj.objid = NULL_OBJID;
			}
		}
		for(k=0;k<i;k++){
			if(me->limits[i].surf.located_obj.objid == me->limits[k].surf.located_obj.objid &&
			me->limits[i].surf.located_obj.osnum == me->limits[k].surf.located_obj.osnum)
				me->limits[i].surf.located_obj.objid = NULL_OBJID;
		}
	}

	sizebuf = sizeof(struct IGRdisplay);
   	gr$get_active_display(	msg    = &msg,
				sizbuf = &sizebuf,
                        	buffer = &symb.display_attr,
				nret   = &nret);

   	sizebuf = sizeof(IGRshort);
   	gr$get_active_level(	msg     = &msg,
				sizbuf  = &sizebuf,
                      		buffer  = &symb.level,
				nret    = &nret);

	/* verif macro name */

   	FIfld_get_text(me->forms[0].form_ptr,OCC_NAME,0, 0,
                       			num_char, text,&sel_flag,&r_pos);
	if(text[0] == '\0'){
		if(me->mytype == MODIFY){
			me->def_name[0] = '\0';
			mac = me->macro_id;
		}
		else{
			ex$message(msgnumb = SM_S_ErNoMacNm);
  			FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
				"ERROR, No macro name");
			*sts =  OM_E_ABORT;
			goto quit;
		}
	}
	else {
		if(me->mytype == MODIFY) mac = me->macro_id;
		strcpy(me->def_name, text);
		if(!SMCanChgElemName(&mac, text)){
			ex$message(msgnumb = SM_S_ErInvMacNm);
  			FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
				"ERROR, Invalid macro name");
			*sts =  OM_E_ABORT;
			goto quit;
		}
	}
  	/* store value in instances */

  	FIfld_get_value(me->forms[0].form_ptr, OFFSET, 0, 0, &me->offset,
  			&sel_flag, &r_pos);

	SMConvDistExtInt(me->offset, &offset, me->act_env.md_id.osnum);

  	FIg_get_state(me->forms[0].form_ptr,INFINITE,&state);
  	if(state ) me->infinite = 0;
  	else       me->infinite = 1;

  	FIg_get_state(me->forms[0].form_ptr,EXTEND,&state);
  	if(state ) me->extend = 0;
  	else       me->extend = 1;

	VMask = 0x0000;
	if(me->infinite) VMask = VMask | 0x8000;
	if(me->extend) VMask = VMask | 0x10000;

	if(me->Fence == TRUE) nb_obj = me->nb_FenceObjects ;
	else nb_obj = 1;
	nb_fail = 0;
	for(fc = 0; fc < nb_obj; fc++){
		nb_roots = me->nb_limits+2;

  		/* place the macro */

  		if(me->mytype == PLACE){
  			mac.objid = NULL_OBJID;
  			mac.osnum = me->act_env.md_id.osnum;

  			stat = om$construct(classid = OPP_SMSpltSrf_class_id,
                           	osnum   = mac.osnum,
                           	p_objid = &mac.objid );
  			if(!(stat & 1)){
     				printf("erreur creating macro\n");
				*sts =  OM_E_ABORT;
				goto quit;
  			}

		}

  		roots = _MALLOC(nb_roots, struct GRid);
  		if(roots == NULL){
			printf("ERROR Bad allocation\n");
			*sts =  OM_E_ABORT;
			goto quit;
  		}

  		/* support is roots[2] */

  		if(me->Fence == TRUE) {
     				stat = as$make_source(
     					go_grid = me->FenceObjects[fc].obj_id,
			     		mod_env = &me->FenceObjects[fc].mod_env,
			     		as_os   = me->act_env.md_id.osnum,
			     		as_grid = &roots[2]);
     				as$status(sts = stat);
        			if(!(stat & 1))
          			{
 					printf("ERROR as$make_source\n");
 					*sts = OM_E_ABORT;
 					goto quit;
          			}
          	}
		else{
     			stat = as$make_source(
     					go_grid = me->limits[0].surf.located_obj,
			     		mod_env = &me->limits[0].surf.module_info,
			     		as_os   = me->act_env.md_id.osnum,
			     		as_grid = &roots[2]);
     			as$status(sts = stat);
        		if(!(stat & 1))
          		{
 				printf("ERROR as$make_source\n");
 				*sts = OM_E_ABORT;
 				goto quit;
          		}
          	}
		if(me->limits[0].rev == 1) VMask = VMask | 0x4000;

		k=0;
  		for(i=1;i<me->nb_limits;i++) {
			if(me->limits[i].surf.located_obj.objid == NULL_OBJID) {
				nb_roots --;
				continue;
			}
			if(me->limits[i].rev == 1) VMask = VMask | (1<<k);
     			stat = as$make_source(
     					go_grid = me->limits[i].surf.located_obj,
			     		mod_env = &me->limits[i].surf.module_info,
			     		as_os   = me->act_env.md_id.osnum,
			     		as_grid = &roots[k+3]);
     			as$status(sts = stat);
        		if(!(stat & 1))
          			{
 					printf("ERROR as$make_source\n");
 					*sts = OM_E_ABORT;
 					goto quit;
          			}
			k++;
  		}

  		if(me->mytype == PLACE){

  			/* mask is roots[0] */

  			roots[0].osnum = me->act_env.md_id.osnum;
  			stat = exp$create( exp_name  = NULL,
  					   exp_value = (IGRdouble) VMask,
  					   p_exp_id  = &roots[0].objid,
  					   osnum     = roots[0].osnum);
  			if(stat != EXP_S_SUCCESS){
  				printf("ERROR creating expression for VMask\n");
  				*sts =  OM_E_ABORT;
  				goto quit;
  			}

        		stat = om$send(msg = message NDnode.NDchg_state(
                                                ND_DEL_NO_CH | ND_WAIT_DEL,
                                                ND_DEL_NO_CH | ND_WAIT_DEL),

                   	targetid = roots[0].objid,
                   	targetos = roots[0].osnum);

        		as$status(sts = stat);
        		if(!(stat & 1)){
                		printf("ERROR NDnode.NDchg_state\n");
                		*sts =  OM_E_ABORT;
                		goto quit;
        		}

  			/* offset is roots[1] */

  			roots[1].osnum = me->act_env.md_id.osnum;
  			stat = exp$create( 	exp_name  = NULL,
  					exp_value = (IGRdouble) offset,
  					p_exp_id  = &roots[1].objid,
  					osnum     = roots[1].osnum);
  			if(stat != EXP_S_SUCCESS){
  				printf("ERROR creating expression for offset\n");
  				*sts =  OM_E_ABORT;
  				goto quit;
  			}

        		stat = om$send(msg = message NDnode.NDchg_state(
                                                ND_DEL_NO_CH | ND_WAIT_DEL,
                                                ND_DEL_NO_CH | ND_WAIT_DEL),

                   	targetid = roots[1].objid,
                   	targetos = roots[1].osnum);

        		as$status(sts = stat);
        		if(!(stat & 1)){
                		printf("ERROR NDnode.NDchg_state\n");
                		*sts =  OM_E_ABORT;
                		goto quit;
        		}

			/* Control VD_offset_before_intersect */

			VD_offset_intersect ( mac, me->mytype );

			/* place macro */

			stat = om$send(msg = message ACncpx.ACmplace
                   			((IGRint *)&msg,ACcant_place_sym,0,
                    			"SMSpltSrf",nb_roots, roots,&me->act_env),
				senderid = NULL_OBJID,
                   		targetid = mac.objid,
		      		targetos = mac.osnum);

 			as$status(sts = stat);
  			if(!(stat & msg & 1)){
        			printf("erreur place macro\n");
        			nb_fail ++;
        			_FREE(roots) ;
        			continue;
  			}
                        (void)GetDefName(text, me->def_name);

			stat = om$send(msg = message GRvg.GRputname
                   			(&msg, me->def_name),
				senderid = NULL_OBJID,
                   		targetid = mac.objid,
		      		targetos = mac.osnum);

 			as$status(sts = stat);
  			if(!(stat & msg & 1)){
        			printf("erreur GRvg.GRputname\n");
        			nb_fail ++;
        			_FREE(roots) ;
        			continue;
  			}

			/* put active symbology */

			stat = om$send(msg = message GRvg.GRputsymb
                   			(&msg, &symb),
				senderid = NULL_OBJID,
                   		targetid = mac.objid,
		      		targetos = mac.osnum);

 			as$status(sts = stat);
  			if(!(stat & msg & 1)){
        			printf("erreur GRvg.GRputsymb\n");
        			nb_fail ++;
        			_FREE(roots);
        			continue;
  			}

  		}
  		else{

			/* Control VD_offset_before_intersect */

			VD_offset_intersect ( me->macro_id, me->mytype );

			/* modify macro */

			stat = om$send(msg = message SMCmdSpltSf.SMmodif_mac
						(VMask, offset, nb_roots, roots),
			 		targetid = my_id);
 			if(!(stat & 1)){
 				printf("ERROR  SMCmdSpltSf.SMmodif_mac\n");
        			nb_fail ++;
        			_FREE(roots) ;
        			continue;
 			}
  		}

  		_FREE(roots ) ;
  	}

 if(nb_fail == nb_obj) {*sts = OM_E_ABORT; goto quit;}

 if(me->mytype == MODIFY){
/* 	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"Modify Successfull");
	ex$message(msgnumb = SM_S_ModSucc); if fails SMModify success*/
 }
 else 	{
 	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"Place Successfull");
	ex$message(msgnumb = SM_S_PlSucc);
 }

quit:
 if(!(*sts&1)){
 	if(me->mytype == MODIFY)
		{ex$message(msgnumb = SM_S_ModFail);}

 	else if (mac.objid != NULL_OBJID &&
 		 om$is_objid_valid(osnum = mac.osnum, objid = mac.objid)){
                stat = om$send(msg = message GRgraphics.GRdelete(&msg, &me->act_env),
                             targetid = mac.objid,targetos = mac.osnum);
                as$status(sts = stat);
                if(!(stat&msg&1))printf("ERROR delete macro\n");
                mac.objid = NULL_OBJID;
		ex$message(msgnumb = SM_S_PlFail);
 	}
  }
  else{
  	me->select_row = 0;
  	me->pos = 0;
  	if(me->mytype == MODIFY) {
 		me->old_macro_id = me->macro_id ;
 		me->old_infinite = me->infinite;
 		me->old_extend = me->extend;
 		me->old_offset = me->offset;
 		me->old_nb_limits = me->nb_limits;

        	strcpy(me->old_def_name,me->def_name);
 		for(i=0;i< me->old_nb_limits;i++){
			me->old_limits[i] = me->limits[i];
		}
		for(i=me->old_nb_limits;i<MAX_SURF;i++) {
				me->old_limits[i].rev = 0;
				me->old_limits[i].surf.located_obj.objid = NULL_OBJID;
		}

  	}
  	else {
  		FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 0, TRUE);
  		FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 1, TRUE);
  		FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 2, TRUE);
  		FIfld_set_active_row(me->forms[0].form_ptr, LIMITS,
   					me->select_row, me->pos);
  		stat = om$send(msg = message SMCmdSpltSf.DispAll(&test),
 		      			targetid = my_id);
  		if(!(stat & test & 1)){
 			ex$message(msgnumb = SM_S_ErrDsp);
 			*sts = OM_E_ABORT;
  		}
   		FIfld_get_text(me->forms[0].form_ptr,OCC_NAME,0, 0,
                       			num_char, text,&sel_flag,&r_pos);
  		(void)GetDefName(text,me->def_name);
  		FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
  	}
  }

  _FREE(roots ) ;

  __exitMethod ( name = "save_all" );

  return OM_S_SUCCESS;
}

/* ----------------------------------------------------------------- */
/*
/* delete an element (Modify)
/*
/**/

method delete_elt(long *sts )
{
 int		i, k, stat, Nb_Max_Temp ,num_rows;
 int		def_properties;
 long		test,msg;
 struct GRid	go, mac;
 char		*c, name[MY_MAX_CHAR],text[MY_MAX_CHAR];

 *sts = OM_S_SUCCESS;

 stat = FIfld_get_num_rows(me->forms[0].form_ptr,LIMITS, &num_rows);
 if(stat != FI_SUCCESS) {
	printf("error FIfld_get_num_rows: %d\n",stat);
	*sts = OM_E_ABORT;
	return OM_S_SUCCESS;
 }
 if(me->delete_elt){

	if(me->delete_row != -1){
  		/* delete the element and redisplay the form */

     		stat = om$send(msg = message SMCmdSpltSf.DispLoc(
     						me->delete_row, GRhe),
                        		targetid= my_id ) ;

     		if (!(stat & 1)){
                	ex$message(msgnumb = SM_S_ErrDsp);
 			*sts = OM_E_ABORT;
                	return  OM_S_SUCCESS;
        	}

		for(i=0;i<me->nb_limits -1;i++){
			if(i < me->delete_row) k = i;
			else k = i+1;

			me->limits[i] = me->limits[k];
		}
		me->limits[me->nb_limits -1].surf.located_obj.objid = NULL_OBJID;
		me->limits[me->nb_limits -1].rev = 0;
		me->nb_limits --;

 		if(num_rows){
 			stat = FIfld_delete_rows(me->forms[0].form_ptr,LIMITS,
 						0,num_rows);
			if(stat != FI_SUCCESS){
				printf("error FIfld_delete_rows: %d\n",stat);
				*sts = OM_E_ABORT;
				return OM_S_SUCCESS;
			}
 		}
 		stat = ac$find_macro_defn( action      = ACfind_load,
                            macro_name  = "SMSpltSrf",
                            p_macro_defn_id     = &mac );

 		if (!(stat & 1) || IF_NULL_OBJID(mac.objid)){
			printf("error macro not found\n");
			*sts = OM_E_ABORT;
			return OM_S_SUCCESS;
 		}
 		Nb_Max_Temp = 0;
 		stat = om$send(msg = message ACmacro_defn.ACgive_upscan
                             (&Nb_Max_Temp,&def_properties,&me->dup),
                           targetid = mac.objid,
                           targetos = mac.osnum );

 		as$status(sts = stat);
 		if(!(stat & 1)){
			printf("error  ACmacro_defn.ACgive_upscan\n");
			*sts = OM_E_ABORT;
			return OM_S_SUCCESS;
 		}
 		/* mettre les prompts et default values dans la forme */

 		k=0;
 		for(i=2;i<Nb_Max_Temp;i=i+1){
			SMspace_getTempDefString( &msg, me->dup[i].type, text );

			FIfld_set_text(me->forms[0].form_ptr, LIMITS, k, 0,
					me->dup[i].prompt, FALSE);
			if( /*me->mytype == MODIFY && */ k < me->nb_limits){		///// HF 10/01/96 /////
				 vd$get_name(name = name, obj = &(me->limits[k].surf.located_obj));
				 if(name[0] == '\0') {
        				/* try get name on the graphic object */
        				stat = om$send( msg = message ASnode.ASreturn_go(
                                          &go,
                                          NULL,
                                          NULL),
                        			senderid = NULL_OBJID,
                        			targetid = me->limits[k].surf.located_obj.objid,
                        			targetos = me->limits[k].surf.located_obj.osnum );
        				if(!(stat&1)) go =  me->limits[k].surf.located_obj;
        				vd$get_name(name = name, obj = &go);
  					if(name[0] == '\0') strcpy(name, "defined");
				}
  				if(name[0] == '\0') strcpy(name, "defined");
 				FIfld_set_text(me->forms[0].form_ptr, LIMITS, k, 1,
  				 name, FALSE);
			}
			else
				FIfld_set_text(me->forms[0].form_ptr, LIMITS, k, 1,
					text, FALSE);
			if(me->limits[k].rev == 0)
				FIfld_set_text(me->forms[0].form_ptr, LIMITS, k, 2,
					"", FALSE);
			else FIfld_set_text(me->forms[0].form_ptr, LIMITS, k, 2,
					"R", FALSE);
			k++;
 		}
	}
  	FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 0, TRUE);
  	FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 1, TRUE);
  	FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 2, TRUE);
  	me->select_row = 0;
  	me->pos = 0;
  	FIfld_set_active_row(me->forms[0].form_ptr, LIMITS,
   					me->select_row, me->pos);
  	stat = om$send(msg = message SMCmdSpltSf.DispAll(&test),
 		      			targetid = my_id);
  	if(!(stat & test & 1)){
 			ex$message(msgnumb = SM_S_ErrDsp);
 			*sts = OM_E_ABORT;
  	}

  	me->delete_elt = 0;
  }
  else{
  	/* set the rows unselected */
  	me->delete_row = -1;
 	for(i=0;i<num_rows;i++){
  		FIfld_set_select(me->forms[0].form_ptr, LIMITS,i, 0, FALSE);
  		FIfld_set_select(me->forms[0].form_ptr, LIMITS,i, 1, FALSE);
  		FIfld_set_select(me->forms[0].form_ptr, LIMITS,i, 2, FALSE);
	}
 	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
 			"Select the Element to be disconnected");
  	me->delete_elt = 1;
  }
  return OM_S_SUCCESS;
}

/* ----------------------------------------------------------------- */
/*
/* modify the macro
/*
/**/

method SMmodif_mac(unsigned int	VMask; IGRdouble offset;
			int nb_new; struct GRid  *new)
{
 long			msg;
 int			i, oldnb_roots, nb_temp, stat;
 struct GRid 		original, *old_roots;
 char			tmp[10];
 IGRboolean		discon, put_batch;
 unsigned int		old_Mask;
 IGRdouble		old_offset;
 struct ret_struct	str;

 old_roots = NULL;
 oldnb_roots = 0;
 put_batch = FALSE;

 stat = om$send(msg = message NDnode.NDget_objects
                   (ND_ROOT | ND_IN_BUF,NULL,0,&old_roots,0,OM_K_MAXINT,
					&oldnb_roots),
	senderid = NULL_OBJID,
	targetid = me->macro_id.objid,
	targetos = me->macro_id.osnum );

 as$status(sts = stat);
 if(stat != OM_S_SUCCESS || oldnb_roots > MAX_TEMP)
  {printf("ERROR retrieve roots of the macro \n"); return OM_E_ABORT;}

  /* Jean : 5/4/93  Modify if macro is broken (has lost his parents) */
 /* If macro has been move to root due to delete of one of the roots */
 /* Creation of two dummy expression to allow to recreate a depandancy */
 if(oldnb_roots == 0)
  {
    struct GRid exp[2];
    struct GRid original;
    int         state;
    int         MyProps = 0x18000;
    IGRdouble   offset  = 0.0;

    put_batch = TRUE;
    /* Recreate an expression with default parameter */
    exp[0].osnum = me->ModuleInfo.md_id.osnum;
    stat = exp$create(exp_name  = NULL,
		      exp_value = (IGRdouble)MyProps,
		      p_exp_id  = &exp[0].objid,
		      osnum     = exp[0].osnum);
    as$status(sts = stat, action = GOTO_VALUE, value = wrapup);

    stat = om$send(msg = message NDnode.NDchg_state
		   (ND_DEL_NO_CH | ND_WAIT_DEL,
		    ND_DEL_NO_CH | ND_WAIT_DEL),
		   targetid = exp[0].objid,
		   targetos = exp[0].osnum);
    as$status(sts = stat);

    /* Recreate default offset */
    exp[1].osnum = me->ModuleInfo.md_id.osnum;
    stat = exp$create(exp_name  = NULL,
		      exp_value = offset,
		      p_exp_id  = &exp[1].objid,
		      osnum     = exp[1].osnum);
    as$status(sts = stat, action = GOTO_VALUE, value = wrapup);

    stat = om$send(msg = message NDnode.NDchg_state
		   (ND_DEL_NO_CH | ND_WAIT_DEL,
		    ND_DEL_NO_CH | ND_WAIT_DEL),
		   targetid = exp[1].objid,
		   targetos = exp[1].osnum);
    as$status(sts = stat);

    original.objid = NULL_OBJID;
    stat = om$send(msg = message NDnode.NDconnect
		   (2, exp, original, ND_ADD),
		   targetid = me->macro_id.objid,
		   targetos = me->macro_id.osnum);
    as$status(sts = stat,action = GOTO_VALUE, value = wrapup);

    /* Refound all parents so we can execute normal instruction */
    stat = om$send(msg = message NDnode.NDget_objects
		   (ND_ROOT | ND_IN_BUF,NULL,0,&old_roots,0,OM_K_MAXINT,
		    &oldnb_roots),
		   targetid = me->macro_id.objid,
		   targetos = me->macro_id.osnum );

    as$status(sts = stat);
    if(stat != OM_S_SUCCESS || oldnb_roots > MAX_TEMP)
     {printf("ERROR retrieve roots of the macro \n"); return OM_E_ABORT;}

    /* Macro have probably been move to root .Change it state and
       so it will be recompute when in batch                     */
    stat =  om$send(msg = message ACncpx.ACget_STATE(&state),
		    targetid = me->macro_id.objid ,
		    targetos = me->macro_id.osnum);
    as$status(sts = stat,action = GOTO_VALUE, value = wrapup);

    if(state & ncpx_root) /* Move to root */
     {
       stat = om$send(msg = message ACncpx.ACchg_STATE(ncpx_root,~ncpx_root),
		      targetid = me->macro_id.objid ,
		      targetos = me->macro_id.osnum);
       as$status (sts = stat,action = GOTO_VALUE, value = wrapup);
     }
  }

 stat = om$send(msg = message NDnode.NDgive_structure(&msg, &str, NULL),
	senderid = NULL_OBJID,
        targetid= old_roots[0].objid,
        targetos= old_roots[0].osnum);
 as$status(sts = stat);
 if(!(stat & msg & 1)) {printf("ERROR retrieve VMask \n"); return OM_E_ABORT;}

 old_Mask = (unsigned int) str.var.root_pm_st.value;

 stat = om$send(msg = message NDnode.NDgive_structure(&msg, &str, NULL),
	senderid = NULL_OBJID,
        targetid= old_roots[1].objid,
        targetos= old_roots[1].osnum);
 as$status(sts = stat);
 if(!(stat & msg & 1))
  {printf("ERROR retrieve offset \n"); return OM_E_ABORT;}

 old_offset =  str.var.root_pm_st.value;

 if(strcmp(me->def_name,me->old_def_name)){
	if(!SMChgElemName(&me->macro_id, me->def_name, &me->act_env)){
		printf("Warning: can't change macro name\n");
	}

 }

 if(VMask != old_Mask){
 	sprintf(tmp,"%lf", (IGRdouble)VMask);
  	stat = exp$modify( 	exp_id  	= old_roots[0].objid,
  				exp_syntax 	= tmp,
  				osnum     	= old_roots[0].osnum);
  	if(stat != EXP_S_SUCCESS){
  		printf("ERROR modify expression for consume\n");
		return OM_E_ABORT;
  	}
 }
 if(offset != old_offset){
 	sprintf(tmp,"%lf", offset);
  	stat = exp$modify( 	exp_id  	= old_roots[1].objid,
  				exp_syntax 	= tmp,
  				osnum     	= old_roots[1].osnum);
  	if(stat != EXP_S_SUCCESS)
	 {printf("ERROR modify expression\n"); return OM_E_ABORT;}
 }
 discon = FALSE;

 if( oldnb_roots != nb_new) discon = TRUE;
 i = 2;
 while(discon == FALSE && i<oldnb_roots && i< nb_new ){
  		if(old_roots[i].objid != new[i].objid ||
  		   old_roots[i].osnum != new[i].osnum)
  		   	discon = TRUE;
  		i++;
 }

 if(discon){
        nb_temp = oldnb_roots - 2;
	put_batch = TRUE;
	if(nb_temp)
	 {
	   stat = om$send(msg = message NDnode.NDdisconnect
			  (nb_temp, &old_roots[2]),
			  targetid = me->macro_id.objid,
			  targetos = me->macro_id.osnum );
	   as$status(sts = stat);
	   if(!(stat & 1))
	    {printf("Erreur NDnode.NDdisconnect\n"); return OM_E_ABORT;}
	 }

	nb_temp = nb_new -2;
  	NDduplicate_root(nb_temp, &new[1]);
  	original.objid = NULL_OBJID;
  	stat = om$send(msg = message NDnode.NDconnect
		      (nb_temp, &new[2], original, ND_ADD),
                   		senderid = NULL_OBJID,
                   		targetid = me->macro_id.objid,
                   		targetos = me->macro_id.osnum );

  	as$status(sts = stat);
  	if(!(stat & 1))
	 {printf("Erreur NDnode.NDconnect\n"); return OM_E_ABORT;}
}

 if(put_batch){
     		IGRint  cn_type,wait_batch;

     		cn_type    = 1; /* recompute the object */
     		stat = nd$wait_batch(
     						type  = GR_GEOM_POSTED,
                            			l_object   = & me->macro_id,
                            			l_obj_info = &cn_type,
                            			nb_obj     = 1);

     		nd$mod_batch(request = ND_INQ,
     			     p_ret_mode = &wait_batch);

     		if(wait_batch == ND_DEFER) {
     				/* Nothing to do */
				return OM_S_SUCCESS;
		}
     		nd$exec_batch(mode = ND_DISP_ROOT|ND_DISP_BODY);

 }
return OM_S_SUCCESS ;

 wrapup:
 return OM_E_ABORT;
}

end implementation SMCmdSpltSf;
