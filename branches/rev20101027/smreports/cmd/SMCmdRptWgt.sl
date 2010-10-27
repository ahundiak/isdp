/* $Id: SMCmdRptWgt.sl,v 1.1.1.1 2001/01/04 21:07:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smreports/cmd / SMCmdRptWgt.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdRptWgt.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:36  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1998/04/22  20:38:32  pinnacle
# Replaced: smreports/cmd/SMCmdRptWgt.sl for:  by mdong for vds
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
 *      04/22/98        Ming            TR179800994
 *
 * -------------------------------------------------------------------*/

/* 
  File           SMCmdRptWgt.sl 
  Creation Date  September 92
  Auteur         Ghassan Jahmi

  History:      Jean Jasinczuk
                November 92: -Modify way to retreive unit.
		             -Add compart report
		December 92: -Add frame system report
		April    93: -Compile for 2.2
		              Remove some gadgets if frame system reports
*/


command_string       SMC_M_Rep,0,SMCrWtRp
synonym              SMC_M_CmRep,1,SMCrCmRp
synonym              SMC_M_FrmRep,2,SMCrPlSyRp
command_table        "sman.cmd"
class                SMCmdRptWgt
super_class          CEO_LOCATE
product_name         "$VDS"

form "SMRpt",0,0,0,0

specification

#include <stdio.h>
#include <unistd.h>
#include "FI.h"
#include "SMdef.h"
#include "OMmacros.h"
#include "dpmacros.h"
#include "asmacros.h"
#include "ACrg_collect.h"
#include "SMmacros.h"
#include "SMmsg.h"
#include "growner.h"
#include "coparamac.h"


instance
{
  variable struct GRid listobj[1];
  struct GRmd_env      md_env;
  int nbobj;
}

implementation

#include "AS_status.h"
#define AS_DEBUG	1

#define WEIGHT_REP        0
#define COMPART_REP       1
#define FRAME_REP         2

#define G_TITLE         23
#define G_REPORT	21
#define G_REPORT_TXT    11
#define G_TYPE		17
#define G_TYPE_TXT      16
#define G_OUT_FILE	13
#define G_OVER		14
#define G_UNIT		20
#define G_CS		24
#define G_DESC_FILE	19
#define G_DESC_TXT	18
#define SAVE		509
#define MY_ERROR  	522


extern GRclassid OPP_SMreports_class_id;

from	SMmgr		import SMFillRpFile;
from	GRgraphics	import GRdisplay;
from	GRvg		import GRgetname;

/*************************************************************************/

state_table

#include "SMmsg.h"

#define SAVE		509
#define MY_ERROR  	522

#define WEIGHT_REP        0
#define COMPART_REP       1
#define FRAME_REP         2

state start
  on CMD_TYPE = WEIGHT_REP  do  message_key  SM_M_Rep state locate_rep
  on CMD_TYPE = COMPART_REP do  message_key  SM_M_CmRep state disp_form
  on CMD_TYPE = FRAME_REP   do  message_key  SM_M_FrmRep state disp_form

state locate_rep

   message_key	        SM_M_Rep
   prompt_key		SM_P_LocRpt
   accept_key           SM_P_PlAccRej
   locate_class         "SMreports"
   filter		locate_noauto
 
   on EX_DATA or EX_STRING or EX_OBJID 
                do control_obj
                   on RETURN_CODE = MY_ERROR            state .
                   on ERROR                             state terminate
                					state second_rep

state second_rep
   message_key	        SM_M_Rep
   prompt_key		SM_P_LocRptMo
   accept_key           SM_P_PlAccRej
   locate_class         "SMreports"
   filter		locate_noauto

   on EX_DATA or EX_STRING or EX_OBJID 
                do control_obj
                   on RETURN_CODE = MY_ERROR            state .
                   on ERROR                             state terminate
                					state .

   on EX_RJT_MOVEON					state disp_form

state disp_form

   display_form 0
   prompt_key	SM_P_SfChForm
   filter	get_event

	on GR_UNKNOWN_TYPE.SAVE
             on CMD_TYPE = WEIGHT_REP  do erase_form 0
	                               state start
             on CMD_TYPE = COMPART_REP state start
        state start

at wakeup do display_half_hilite
at sleep do erase_hilite
 
/* --------------------------------------------------------------------------- */

action init
{
  char           unit_str[80];
  int		 i, num_row = 0;
 
  status = om$send(targetid = my_id,
		   mode   = OM_e_wrt_message,
		   msg    = message CEO_LOCATE.init( type, str_ptr ) );
  if (!(status & 1))
   {
     printf("error at CEO_LOCATE.init\n");
     me->state = _terminate;
     return ( OM_I_STOP_SENDING );
   }

  me->nbobj = 0;
  FIg_erase(me->forms[0].form_ptr,G_DESC_FILE);
  FIg_erase(me->forms[0].form_ptr,G_DESC_TXT);

  /* Search the current EMS Unit */
  /* Retreives the name of unit and put it in the form */
  if(!SMRetExtDistUnit(unit_str,me->ModuleInfo.md_id.osnum))
   {
     ex$message(msgnumb = SM_E_BadDefUni);
     me->state = _terminate;
     return ( OM_I_STOP_SENDING );
   }
  FIfld_set_default_text(me->forms[0].form_ptr,G_UNIT,0,0,unit_str,0);
  FIg_set_text(me->forms[0].form_ptr,G_UNIT,unit_str);

  switch(me->mytype)
   {
   case WEIGHT_REP:
     SMVA_set_default_text(me->forms[0].form_ptr,2,
			   G_TITLE,"Weight Report",
			   G_OUT_FILE,"WeightRpt");
     break;
   case COMPART_REP:
     SMVA_set_default_text(me->forms[0].form_ptr,2,
			   G_TITLE,"Compartment Report",
			   G_OUT_FILE,"CompRpt");
     FIg_delete(me->forms[0].form_ptr,G_REPORT);
     FIg_delete(me->forms[0].form_ptr,G_REPORT_TXT);
     /* TR179800994 */
     FIg_set_text( me->forms[0].form_ptr, G_TYPE, "Regular" );
     FIfld_get_list_num_rows( me->forms[0].form_ptr, G_TYPE, 0, &num_row );
     for( i = 0 ; i < num_row ; ++ i )
     {
       FIfld_set_list_text( me->forms[0].form_ptr, 
			    G_TYPE,
			    i,
 			    0, 
			    "",
			    FALSE );
     }
     FIfld_set_list_text( me->forms[0].form_ptr,
                          G_TYPE,
                          0,
                          0,
                          "Regular",
                          FALSE );
     break; 
   case FRAME_REP:
     FIg_delete(me->forms[0].form_ptr,G_TYPE);
     FIg_delete(me->forms[0].form_ptr,G_TYPE_TXT);
     FIg_delete(me->forms[0].form_ptr,G_CS);
     SMVA_set_default_text(me->forms[0].form_ptr,2,
			   G_TITLE,"Plane System Report",
			   G_OUT_FILE,"FrameRpt");
     FIg_delete(me->forms[0].form_ptr,G_REPORT);
     FIg_delete(me->forms[0].form_ptr,G_REPORT_TXT);
     break;
   } 
} 

action display_half_hilite
{
long msg;
int i;

 me->DisplayMode = GRhhd;
 for (i=0; i<me->nbobj; i++)
 {
   status = om$send(msg = message GRgraphics.GRdisplay
                                         (
                                          &msg,
                                          &me->ModuleInfo.md_env.matrix_type,
                                          me->ModuleInfo.md_env.matrix,
                                          &me->DisplayMode,
                                          &me->ModuleInfo.md_id
                                         ),
                      targetid = me->listobj[i].objid,
                      targetos = me->listobj[i].osnum);


     if (!(status & msg & 1))
       ex$message( msgnumb = SM_E_ERGrDisp );
 }
}

action erase_hilite
{
  status = dp$erase_hilite(msg=&me->ret,
                           objid = me->ModuleInfo.md_id.objid,
                           osnum = me->ModuleInfo.md_id.osnum);
}


action form_notification ( int form_label ; int gadget_label ; double value ;
                           char * form_ptr )
{
long loc_msg;
int  msg;
char array[250];
int sel_flag;

  if( form_ptr == NULL ) return( OM_E_INVARG ); 
   
  FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");

  switch( gadget_label )
  {
    case FI_ACCEPT:
      status = om$send(msg = message SMCmdRptWgt.save_all(&loc_msg),
 		       targetid = my_id);
     
      if(!(status & loc_msg & 1))
      { 
	FIg_set_state_off(me->forms[0].form_ptr,FI_ACCEPT);
	switch(me->mytype)
	 {
	 case WEIGHT_REP:
	   ex$message( msgnumb = SM_E_BadOnLRpt);
	   goto quit;
	 case COMPART_REP: 
	   ex$message( msgnumb = SM_E_BadCmRpt);
	   goto quit;
	 case FRAME_REP:
	   ex$message( msgnumb = SM_E_BadFrmRpt);
	   goto quit;
	 }
        
	goto quit;
      }
      _put_response(resp = TERMINATE);
      break;
    
    case FI_EXECUTE: 
      status = om$send(msg = message SMCmdRptWgt.save_all(&loc_msg),
		       targetid = my_id);
     
      if(!(status & loc_msg & 1))
      { 
	FIg_set_state_off(me->forms[0].form_ptr,FI_EXECUTE);
	switch(me->mytype)
	 {
	 case WEIGHT_REP:
	   ex$message( msgnumb = SM_E_BadOnLRpt);
	   goto quit;
	 case COMPART_REP: 
	   ex$message( msgnumb = SM_E_BadCmRpt);
	   goto quit;
	 case FRAME_REP: 
	   ex$message( msgnumb = SM_E_BadFrmRpt);
	   goto quit;
	 }
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
      FIfld_get_default_text(me->forms[0].form_ptr,G_TYPE,
			     0,0,249,array,&sel_flag);
      if (!strcmp(array,"User")) {
        FIg_display(me->forms[0].form_ptr,G_DESC_TXT);
        FIg_display(me->forms[0].form_ptr,G_DESC_FILE);
      }
      else {
	FIg_erase(me->forms[0].form_ptr,G_DESC_TXT);
	FIg_erase(me->forms[0].form_ptr,G_DESC_FILE);
      }
      break;
      
    case G_TYPE:
       /* TR179800994 */
      if( me->mytype == COMPART_REP )
      {
        FIg_set_text( me->forms[0].form_ptr, G_TYPE, "Regular" );
        break;
      }

      FIg_get_text(me->forms[0].form_ptr,G_TYPE,array);
      if (!(strcmp(array,"User"))) {
        FIg_display(me->forms[0].form_ptr,G_DESC_TXT);
        FIg_display(me->forms[0].form_ptr,G_DESC_FILE);
      }
      else {
        FIg_erase(me->forms[0].form_ptr,G_DESC_TXT);
        FIg_erase(me->forms[0].form_ptr,G_DESC_FILE);
      }
      break;

     /* Other gadgets need no treatment yet */
    case G_OUT_FILE :
    case G_OVER:
    case G_DESC_FILE:
    case G_UNIT:
    case G_CS:
      break;
  }

}
 
action save_all ( long * sts )
{
  IGRlong 	loc_msg;
  int 		over=0,cs=0;
  IGRshort 	out_units=0;
  IGRshort	options = 0;
  char 		filename[80],unit_str[30];
  char          type_str[50];
  int 		i,sel_flag,r_pos;
  IGRchar	array[80];
  IGRchar       *descfile,desc_file[100];
  FILE		*p_file = NULL;

  /* Retrieve parameters in the form and control they are OK */

  *sts = MSFAIL;

  filename[0] = '\0';
  FIfld_get_text(me->forms[0].form_ptr,G_OUT_FILE,
		 0,0,79,filename,&sel_flag,&r_pos);
  filename[79] = '\0';
  if(filename[0] == '\0')
   {
     ex$message( msgnumb = SM_E_SfBadFiName, buff = array);
     FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,array);
     goto quit;
   }

  /* If no overide request and file exists ==> error message */    
  FIg_get_state(me->forms[0].form_ptr,G_OVER,&over);
  if (!over)
   {
     if(access(filename,F_OK) == 0)
      {
       ex$message( msgnumb = SM_E_NoPerm, buff = array);
       FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,array);
       goto quit;
     }
   }
  else
    /* Test Write access permission */
    if(access(filename,F_OK) == 0 && access(filename,W_OK) != 0)
     {
       ex$message( msgnumb = SM_E_NoPerm, buff = array);
       FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,array);
       goto quit;
     }

  options = SM_ASCII_FILE;

  FIg_get_text(me->forms[0].form_ptr,G_TYPE,type_str);
  if (strcmp(type_str,"User")) {
    descfile = NULL;
    if (!strcmp(type_str,"Regular"))
      options = options | SM_REG_RPT;
    else
      if (!strcmp(type_str,"Short"))
        options = options | SM_SHORT_RPT;
      else
        if (!strcmp(type_str,"Large"))
          options = options | SM_LONG_RPT;
  }
  else {
    descfile = desc_file;
    FIg_get_text(me->forms[0].form_ptr,G_DESC_FILE,descfile);
  }

  /* Retrieve unit as defined in SMdef.h */
  FIg_get_text(me->forms[0].form_ptr,G_UNIT,unit_str); 
  
  if(!SMDistUnitFlag(unit_str,&out_units))
   { printf("Unit not understood\n"); goto wrapup;}

  FIg_get_state(me->forms[0].form_ptr,G_CS,&cs);
 
  switch(me->mytype)
   {
   case WEIGHT_REP:
     if (!me->nbobj) {
       ex$message( msgnumb = SM_E_NoRptSel, buff = array);
       FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,array);
       goto wrapup;
     }
     p_file = fopen(filename,"w");
     if (!p_file) {
       ex$message( msgnumb = SM_E_NoOpFile, buff = array);
       FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,array);
       goto quit;
     }

     for (i=0; i< me->nbobj; i++) 
      { 
	status = om$send(msg = message SMmgr.SMFillRpFile
			 (&loc_msg, descfile, p_file, options,
			  FALSE, out_units, &me->md_env.md_env, NULL
			  /* the cs'matrix must be used in the future*/),
			 targetid = me->listobj[i].objid,
			 targetos = me->listobj[i].osnum );
	if(!(status & loc_msg & 1))
	 {
	   ex$message( msgnumb = SM_E_BadOnLRpt, buff = array);
	   FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,array);
	   goto wrapup;
	 }
      }
     break;

   case COMPART_REP:
     status = SM$Report( msg      = &loc_msg,
			filename  = filename,
			options   = options,
			out_units = out_units,
			state     = SM_NEW | SM_MOD | SM_UPD,
			type      = SM_COMPART);
     if(!(status & loc_msg & 1))
      {
	ex$message( msgnumb = SM_E_BadCmRpt, buff = array);
	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,array);
	goto wrapup;
      }
     break;

   case FRAME_REP:
     status = SM$Report( msg      = &loc_msg,
			filename  = filename,
			options   = options,
			out_units = out_units,
			state     = SM_NEW | SM_MOD | SM_UPD,
			type      = SM_FRM);
     if(!(status & loc_msg & 1))
      {
	ex$message( msgnumb = SM_E_BadFrmRpt, buff = array);
	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,array);
	goto wrapup;
      }
     break;
   }

  /* Put the default values for the reset */
  FIfld_set_default_text(me->forms[0].form_ptr,G_OUT_FILE,
			 0,0,filename,0,0);
  
  FIfld_set_default_text(me->forms[0].form_ptr,G_UNIT,
			 0,0,unit_str,0,0);
  FIfld_set_default_text(me->forms[0].form_ptr,G_TYPE,
			 0,0,type_str,0,0);

  FIg_set_default_value(me->forms[0].form_ptr,G_OVER,(double)over);
  FIg_set_default_value(me->forms[0].form_ptr,G_CS,(double)cs);

  if(p_file) fclose(p_file);
  *sts = MSSUCC;
  goto quit;

 wrapup:
  if(p_file) fclose(p_file);
  *sts = MSFAIL;
}

action control_obj(long *sts)
{
  IGRlong	    msg;
  struct GRobj_env *LocatedObjects;
  GRclassid	    class_id;
  int		    i,j;
  int		    nb_obj,nb_conserv=0;
  int		    find,bool,nb_supprim=0;
  char		    *pt_name,name[250];

  LocatedObjects = NULL;
  as$start_fence(set= &me->event1.located_object[0].located_obj,
                 set_env = &me->event1.located_object[0].module_info,
                 nb_obj = &nb_obj,
                 p_obj_env = &LocatedObjects,
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
    status = om$get_classid(osnum     = LocatedObjects[i].obj_id.osnum,
                            objid     = LocatedObjects[i].obj_id.objid,
                            p_classid = &class_id);
    as$status();
    status = om$is_ancestry_valid(subclassid   = class_id,
                                  superclassid = OPP_SMreports_class_id);
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
              targetid = LocatedObjects[i].obj_id.objid,
              targetos = LocatedObjects[i].obj_id.osnum );
      if (!(status & msg & 1))
        ex$message( msgnumb = SM_E_ERGrDisp );
      LocatedObjects[i].obj_id.objid = NULL_OBJID;
      nb_supprim++;
    }
  }
  if (nb_supprim == nb_obj) {
    *sts = MY_ERROR;
    ex$message( msgnumb = SM_E_InvObjSel );
    ASend_fence(); goto quit;
  }

/* Verify the located objects aren't already selected */
  find = FALSE;
  for (j=0; j<nb_obj; j++)
  {
    if (LocatedObjects[j].obj_id.objid != NULL_OBJID) {
      for (i=0;i<me->nbobj;i++)
      {
        if (
            (me->listobj[i].objid == LocatedObjects[j].obj_id.objid) &&
            (me->listobj[i].osnum == LocatedObjects[j].obj_id.osnum)
           )
          {
            LocatedObjects[j].obj_id.objid = NULL_OBJID;
          }
      }
      if (LocatedObjects[j].obj_id.objid != NULL_OBJID) {
        find = TRUE;
        nb_conserv++;
      }
    }
  }

  if(find)
  {
    if(nb_conserv + me->nbobj > om$dimension_of( varray = me->listobj))
      om$vla_set_dimension(varray = me->listobj,size = nb_conserv + me->nbobj);

    bool = 0;
    for (i=me->nbobj,j=0; j<nb_obj;j++)
    {
      if (LocatedObjects[j].obj_id.objid != NULL_OBJID) {
        me->listobj[i] = LocatedObjects[j].obj_id;
        if (!bool) {
          me->md_env = LocatedObjects[j].mod_env;
          bool = 1;
        }
        i++;
      }
    }
    me->nbobj += nb_conserv;
    if (me->nbobj > 1) {
      FIg_set_text( me->forms[0].form_ptr, G_REPORT, "Defined");
      FIfld_set_default_text(me->forms[0].form_ptr,G_REPORT,
			     0,0,"Defined",0,0);
    }
    else {
      status = om$send(msg = message GRvg.GRgetname(&msg,name),
                      targetid = me->listobj[0].objid,
		      targetos = me->listobj[0].osnum);
     if(!(status & msg & 1))
     {
       ex$message( msgnumb = SM_E_BadGetName );
       *sts = MY_ERROR;
       ASend_fence(); goto quit;
     }
     for(i = strlen(name)-1;name[i] != ':'; i--);
     pt_name=name+i+1;
     FIg_set_text( me->forms[0].form_ptr, G_REPORT, pt_name);
     FIfld_set_default_text(me->forms[0].form_ptr,G_REPORT,
		            0,0,pt_name,0,0);
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
}


