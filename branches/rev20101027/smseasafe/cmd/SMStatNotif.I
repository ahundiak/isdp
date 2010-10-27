/* $Id: SMStatNotif.I,v 1.1.1.1 2001/01/04 21:07:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smseasafe/cmd / SMStatNotif.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMStatNotif.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:36  cvs
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
  File           SMStatNotif.I 
  Creation Date  August 92
  Auteur         Ghassan Jahmi - Jean Jasinczuk (ISDC)

  History
*/

class implementation SMCmdMdStat;

#include "AS_status.h"
#include "coparamac.h"
#include "VDmsg.h"

from GRgraphics import GRdisplay;
from SMmgr import SMGetState, SMChgState;

extern GRclassid OPP_SMmgr_class_id;

%safe
static int read_object();
%endsafe

static read_object(obj,form_ptr)
struct GRid *obj;
Form form_ptr;
{
IGRshort state;
IGRlong status;

  status = om$send(msg = message SMmgr.SMGetState(&state),
	        targetid = obj->objid,
	        targetos = obj->osnum,
	        senderid = NULL_OBJID);
  if (!(status & 1)) {    
    ex$message( msgnumb = SM_E_BadGetSt);
    return 0;
   }
  
  if (SM_NEW & state) {
    FIg_set_state_on(form_ptr,G_STATE);
  }
  else
    FIg_set_state_off(form_ptr,G_STATE);
  
  if (SM_MOD & state) {
      FIg_set_state_on(form_ptr,G_MODIFY);
  }
  else
    FIg_set_state_off(form_ptr,G_MODIFY);

  if (SM_UPD & state) {
    FIg_set_state_on(form_ptr,G_UPDATE);
  }
  else {
    FIg_set_state_off(form_ptr,G_UPDATE);
  }
  
  if (SM_SF_ERR & state)
    FIg_set_text(form_ptr,G_ERR_EXT,"yes");
  else
    FIg_set_text(form_ptr,G_ERR_EXT,"No");
  
  if (SM_CAL_ERR & state)
    FIg_set_text(form_ptr,G_ERR_COMP,"yes");
  else
    FIg_set_text(form_ptr,G_ERR_COMP,"No");
  
  return 1;
}
  
method control_obj (int *sts)
{
IGRlong status,msg;
struct GRid *LocatedObjects;
GRclassid class_id;
int i,j;
int nb_obj,nb_conserv=0;
int find,nb_supprim=0;
  
  LocatedObjects = NULL;
  as$start_fence(set= &me->event1.located_object[0].located_obj,
                 set_env = &me->event1.located_object[0].module_info,
                 nb_obj = &nb_obj,
                 p_obj = &LocatedObjects,
                 response = me->response,
                 response_data = me->response_data);

  if (nb_obj == 0) 
  {
    *sts = MY_ERROR;
    ex$message( msgnumb = SM_E_NoObjLoc);
    goto quit;
  }

/* Verify the located object classes are good to avoid errors caused by locating
   objects by name */

  for (i=0; i< nb_obj; i++)
  {
    status = om$get_classid(osnum     = LocatedObjects[i].osnum,
		  	    objid     = LocatedObjects[i].objid,
                            p_classid = &class_id);
    as$status();
    status = om$is_ancestry_valid(subclassid   = class_id,
			          superclassid = OPP_SMmgr_class_id); 
    if (status != OM_S_SUCCESS) {
      ex$message( msgnumb = SM_E_InvObjSel );
      me->DisplayMode = GRhe;
      status =
      om$send(msg = message GRgraphics.GRdisplay(
					&msg,
					&me->ModuleInfo.md_env.matrix_type,
					me->ModuleInfo.md_env.matrix,
					&me->DisplayMode,
					&me->ModuleInfo.md_id ),
	      targetid = LocatedObjects[i].objid,
	      targetos = LocatedObjects[i].osnum );
      if (!(status & msg & 1))
         ex$message( msgnumb = SM_E_ERGrDisp );
      LocatedObjects[i].objid = NULL_OBJID; 
      nb_supprim++;
    }
  }
  if (nb_supprim == nb_obj) {
    *sts = MY_ERROR;
    ex$message( msgnumb = SM_E_InvObjSel );
    goto quit;
  }

/* Verify the located objects aren't already selected */
  find = FALSE;
  for (j=0; j<nb_obj; j++) 
  {
    if (LocatedObjects[j].objid != NULL_OBJID) {
      for (i=0;i<me->nbobj;i++)
      {
        if (
            (me->listobj[i].objid == LocatedObjects[j].objid) &&
            (me->listobj[i].osnum == LocatedObjects[j].osnum) 
           )
          {
            LocatedObjects[j].objid = NULL_OBJID;
          } 
      }
      if (LocatedObjects[j].objid != NULL_OBJID) {
        find = TRUE;
        nb_conserv++;
      }
    }
  }

  if (find)
  {
    if(nb_conserv + me->nbobj > om$dimension_of( varray = me->listobj))
      om$vla_set_dimension(varray = me->listobj,size = nb_conserv + me->nbobj);
    
    for (i=me->nbobj,j=0; j<nb_obj;j++)
    {
      if (LocatedObjects[j].objid != NULL_OBJID) {
      me->listobj[i] = LocatedObjects[j]; 
      i++;
    }
  }
    me->nbobj += nb_conserv;
    if (!read_object(&me->listobj[0],me->forms[0].form_ptr)) {
      ex$message( msgnumb = SM_E_BadGetSt);
      goto quit;
    }
  }
  
  me->DisplayMode = GRhhd;
  for (i=0; i<me->nbobj; i++)
  {
    status = om$send(msg = message GRgraphics.GRdisplay
                      (&msg,
	               &me->ModuleInfo.md_env.matrix_type,
	               me->ModuleInfo.md_env.matrix,
	               &me->DisplayMode,
	               &me->ModuleInfo.md_id
		      ),
	             targetid = me->listobj[i].objid,
	             targetos = me->listobj[i].osnum
		    );
	      
	      
    if (!(status & msg & 1)) {
       ex$message( msgnumb = SM_E_ERGrDisp );
    }
  }
  quit :
    ASend_fence();
    return OM_S_SUCCESS;
}

method form_notification ( int form_label ; int gadget_label ; double value ;
                           char * form_ptr )
{
long loc_msg;
int  msg;
IGRlong status;

  if( form_ptr == NULL ) return( OM_E_INVARG ); 
   
  FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");

  switch( gadget_label )
  {
    case FI_ACCEPT:
      status = om$send(msg = message SMCmdMdStat.save_all(&loc_msg),
 		       targetid = my_id);
     
      FIg_set_state_off(me->forms[0].form_ptr,FI_ACCEPT);
      if(!(status & loc_msg & 1))
      { 
        ex$message( msgnumb = SM_E_BadChgSt );
	goto quit;
      }
     
      me->nbobj = 0;
      _put_response(resp = TERMINATE);
      break;
    
    case FI_EXECUTE : 
      status = om$send(msg = message SMCmdMdStat.save_all(&loc_msg),
 		       targetid = my_id);
     
      FIg_set_state_off(me->forms[0].form_ptr,FI_EXECUTE);
      if(!(status & loc_msg & 1))
      { 
        ex$message( msgnumb = SM_E_BadChgSt );
	goto quit;
      }
      me->nbobj = 0;
      status = dp$erase_hilite(msg=&msg,
                               objid = me->ModuleInfo.md_id.objid,
                               osnum = me->ModuleInfo.md_id.osnum\
			      );
      if (!(status & msg & 1)) {
         ex$message( msgnumb = SM_E_ERGrDisp );
      }
      _put_response(resp = SAVE);
      break;

    case FI_CANCEL: 
      _put_response(resp = TERMINATE);
      break;
     
    case FI_RESET: 
      if (me->nbobj)
        if (!read_object(&me->listobj[0],me->forms[0].form_ptr)) {
          ex$message( msgnumb = SM_E_BadGetSt);
          goto quit;
        }
      break;
     
    case G_STATE:
      FIg_set_state_off(form_ptr,G_UPDATE);
      FIg_set_state_off(form_ptr,G_MODIFY);
      break;
    case G_MODIFY :
      FIg_set_state_off(form_ptr,G_STATE);
      FIg_set_state_off(form_ptr,G_UPDATE);
      break;
    case G_UPDATE:
      FIg_set_state_off(form_ptr,G_STATE);
      FIg_set_state_off(form_ptr,G_MODIFY);
      break;
    default:
      break;
   }
  quit :
    return OM_S_SUCCESS;
}
 
method save_all ( int *msg )
{
IGRlong status;
int new,update,mod;
int i;
char my_msg[80];


  *msg = MSFAIL;
  /* Retrieve parameters in the form and control they are OK */

  FIg_get_state(me->forms[0].form_ptr,G_STATE,&new);
  FIg_get_state(me->forms[0].form_ptr, G_UPDATE,&update);
  FIg_get_state(me->forms[0].form_ptr, G_MODIFY,&mod);
  new    = new ? SM_NEW : 0;
  mod = mod ? SM_MOD : 0;
  update = update ? SM_UPD : 0;
  
  for (i=0; i<me->nbobj;i++) 
  {
    status = om$send(msg = message SMmgr.SMChgState(
				                    SM_NEW|SM_MOD|SM_UPD,
  				                    new|mod|update
						   ),
	             targetid = me->listobj[i].objid,
                     targetos = me->listobj[i].osnum);
   if(!(status & 1)) {
        ex$message( msgnumb = SM_E_BadChgSt, buff = my_msg);
        FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
        goto quit;
      }
  }
  *msg = MSSUCC;

  quit :
  return OM_S_SUCCESS;
}

end implementation SMCmdMdStat;
