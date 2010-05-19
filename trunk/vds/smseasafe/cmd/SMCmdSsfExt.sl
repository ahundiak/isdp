/* $Id: SMCmdSsfExt.sl,v 1.1.1.1 2001/01/04 21:07:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smseasafe/cmd / SMCmdSsfExt.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdSsfExt.sl,v $
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
  File           SMCmdSsfExt.sl 
  Creation Date  August 92
  Auteur         Ghassan Jahmi - Jean Jasinczuk (ISDC)

  This file implement the command object for a seasafe extraction report

  History:
*/


command_string       SMC_M_SfRep,0,SMCnAsFrSs
command_table        "sman.cmd"
class                SMCmdSsfExt
super_class          CEO_LOCATE
product_name         "$VDS"

form "SMSeasafe",0,1,0,0

specification

#include <stdio.h>
#include <unistd.h>
#include "igrtypedef.h"
#include "igetypedef.h"
#include "ACrg_collect.h"

#include "FI.h"

#include "SMdef.h"
#include "SMmacros.h"
#include "SMCmdSeasafe.h"

#include "SMmsg.h"

implementation

#include "AS_status.h"
#define AS_DEBUG	1

/* Get the number of extraction in the extraction field */
static int SfGetExtNb(form,nb_ext)
Form form ;              /* [I] pointer to the form */
int *nb_ext;            /* [I/O] The value return    */
{
  char value[40];
  char my_msg[80];
  int sel_flag,r_pos;
  int new_nb_ext;
  
  value[0] = '\0';
  FIfld_get_text(form,G_EXT_NB,0,0,39,value,&sel_flag,&r_pos);
  value[39] = '\0';
  if((value[0] == '\0') || (sscanf(value,"%d",&new_nb_ext) != 1) ||
     new_nb_ext < 0)
   {
     ex$message( msgnumb = SM_E_SfBadNbExt, buff = my_msg);
     FIg_set_text(form,FI_MSG_FIELD,my_msg);
     FIg_set_text(form, G_EXT_NB,"");
     return 0;
   }
  
  *nb_ext = new_nb_ext;
  return 1;
}

/*************************************************************************/

state_table

#include "SMmsg.h"
state form_modify


   message_key  SM_M_SfRep
   prompt_key	SM_P_SfChForm
   filter	get_event

	on ERROR state terminate

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action init
{
  char            unit_str[80];
  char 		  tmp[50];
  
  status =
  om$send(targetid = my_id,
          mode = OM_e_wrt_message,
          msg = message CEO_LOCATE.init (type,str_ptr));
  if (!(status & 1))
    {
      printf("error at CEO_LOCATE.init\n");
      ex$message( msgnumb = SM_E_SfBadExtract);
      me->state = _terminate;
      return ( OM_I_STOP_SENDING );
    }
 
  /* Retreives the name of unit and put it in the form */
  if(!SMRetExtDistUnit(unit_str,me->ModuleInfo.md_id.osnum))
   {
     ex$message(msgnumb = SM_E_BadDefUni);
     me->state = _terminate;
     return ( OM_I_STOP_SENDING );
   }
  FIfld_set_default_text(me->forms[0].form_ptr,G_UNIT,0,0,unit_str,0);
  FIg_set_text(me->forms[0].form_ptr,G_UNIT,unit_str);
  
  sprintf(tmp,"%d",1);
  FIfld_set_default_text(me->forms[0].form_ptr,G_EXT_NB,0,0,tmp,0,0);
  FIg_set_value(me->forms[0].form_ptr,G_EXT_NB,(double) 1.);
}


action form_notification
{
int loc_msg;
int nb_ext;
int inc_upd;

  if( form_ptr == NULL ) return( OM_E_INVARG ); 
   
  FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");

  switch( gadget_label )
  {
    case FI_ACCEPT:
      status = om$send(msg = message SMCmdSsfExt.save_all(&loc_msg),
 		       targetid = my_id);
     
      if(!(status & loc_msg & 1))
      { 
	FIg_set_state_off(me->forms[0].form_ptr,FI_ACCEPT);
        printf("Extract Failed\n");
	goto quit;
      }
     
      _put_response(resp = TERMINATE);
      break;
    
    case FI_EXECUTE : 
      status = om$send(msg = message SMCmdSsfExt.save_all(&loc_msg),
		       targetid = my_id);
     
      if(!(status & loc_msg & 1))
      { 
	FIg_set_state_off(me->forms[0].form_ptr,FI_EXECUTE);
	goto quit;
      }
      break;

    case FI_CANCEL: 
      _put_response(resp = TERMINATE);
      break;
     
    case FI_RESET: 
      break;
     
    case G_EXT_NB:
      SfGetExtNb(me->forms[0].form_ptr,&nb_ext);
      break;

     /* Other gadgets need no treatment yet */
    case G_FILE_NAME :
    case G_OVER:
    case G_INCREMENTAL:
      /* If full update, number of extraction is 0 */
      FIg_get_state(me->forms[0].form_ptr,G_INCREMENTAL,&inc_upd);
      if(!inc_upd)
	FIg_set_value(me->forms[0].form_ptr,G_EXT_NB,0.0);
      break;
    case G_UNIT:
    case G_PRINT:
      break;
  }
}
 
action save_all ( int *sts )
{
  IGRlong       msg;
  int 		over=0;
  IGRshort 	state=0;
  IGRshort 	out_units=0;
  IGRshort	options = 0;
  IGRshort 	type=0;
  char 		filename[80],unit_str[30];
  int 		sel_flag,r_pos;
  char 		my_msg[80];
  int 		print=0;
  int 		incr=0;
  int 		ascii=0;
  int 		nb_ext=0;

  /* Retrieve parameters in the form and control they are OK */

  *sts = MSFAIL;

  filename[0] = '\0';
  FIfld_get_text(me->forms[0].form_ptr,G_FILE_NAME,
		 0,0,79,filename,&sel_flag,&r_pos);
  filename[79] = '\0';
  if(filename[0] == '\0')
   {
     ex$message( msgnumb = SM_E_SfBadFiName, buff = my_msg);
     FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
     goto quit;
   }

  if(!SfGetExtNb(me->forms[0].form_ptr,&nb_ext)) {
    goto quit; 
  }

  /* If no overide request and file exists ==> error message */    
  FIg_get_state(me->forms[0].form_ptr,G_OVER,&over);
  if (!over)
   {
     if(access(filename,F_OK) == 0)
      {
       ex$message( msgnumb = SM_E_NoPerm, buff = my_msg);
       FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
       goto quit;
     }
   }
  else
    /* Test Write access permission */
    if(access(filename,F_OK) == 0 && access(filename,W_OK) != 0)
     {
       ex$message( msgnumb = SM_E_NoPerm, buff = my_msg);
       FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
       goto quit;
     }

  FIg_get_state(me->forms[0].form_ptr, G_INCREMENTAL,&incr);
  if(incr)
    state = SM_NEW | SM_MOD;
  else
    state = SM_NEW | SM_MOD | SM_UPD;
 
  FIg_get_text(me->forms[0].form_ptr,G_UNIT,unit_str); 
  
  /* Retrieve unit as defined in SMdef.h */
  if(!SMDistUnitFlag(unit_str,&out_units))
   {
     printf("Unit not understood\n");
     goto quit;
   }

  FIg_get_state(me->forms[0].form_ptr, G_PRINT,&print); /* Dummy now */
  if (print)
    options = options | SM_SF_RPT_ON;

  FIg_get_state(me->forms[0].form_ptr, G_TYPE,&ascii); /* Dummy now */
  if (ascii) 
    options = options | SM_ASCII_FILE;
  else
    options = options | SM_BIN_FILE;

  /* Now call macro for creating reports */

  type  = SM_SUB_GRP | SM_GRP | SM_FRM | SM_COMPART | SM_DW | SM_CS | SM_PP
    | SM_SHIP_ATT | SM_WND_AREA;

  status = SM$Seasafe( msg     = &msg,
		     filename = filename,
  		     state   = state,
		     options = options,
		     type    = type,
		     out_units = out_units,
		     rel_numb = nb_ext);
   if(!(status & msg & 1))
   {
     ex$message( msgnumb = SM_E_SfBadExtract, buff = my_msg);
     FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
     *sts = MSFAIL;
     goto quit;
   }

  /* Put the default values for the reset */
  FIfld_set_default_text(me->forms[0].form_ptr,G_FILE_NAME,
			 0,0,filename,0,0);
  
  FIfld_set_default_text(me->forms[0].form_ptr,G_UNIT,
			 0,0,unit_str,0,0);

  FIg_set_default_value(me->forms[0].form_ptr,G_OVER,(double)over);
  FIg_set_default_value(me->forms[0].form_ptr,G_INCREMENTAL,(double)incr);
  FIg_set_default_value(me->forms[0].form_ptr,G_PRINT,(double)print);

  FIg_set_value(me->forms[0].form_ptr,G_EXT_NB,(double)nb_ext+1);
  FIg_set_default_value(me->forms[0].form_ptr,G_EXT_NB,(double)nb_ext+1);

  *sts = OM_S_SUCCESS;
}

  





