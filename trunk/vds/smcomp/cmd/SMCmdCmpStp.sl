/* $Id: SMCmdCmpStp.sl,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smcomp/cmd / SMCmdCmpStp.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdCmpStp.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
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
# Revision 1.5  1996/04/29  06:19:40  pinnacle
# Replaced: smcomp/cmd/SMCmdCmpStp.sl for:  by ksundar for vds.240
#
# Revision 1.4  1995/11/29  13:52:30  pinnacle
# Replaced: ./smcomp/cmd/SMCmdCmpStp.sl for:  by ksundar for vds.240
#
# Revision 1.3  1995/09/25  21:48:58  pinnacle
# Replaced: smcomp/cmd/SMCmdCmpStp.sl for:  by sundar for vds.240
#
# Revision 1.2  1995/07/24  20:40:18  pinnacle
# Replaced: smcomp/cmd/SMCmdCmpStp.sl for:  by hverstee for vds.240
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
   File     SMCmdCmpStp 
   Date     March 93
   Auteur   Jean Jasinczuk
  
   History: 15 July   93  Modify to load name of attributes only when needed.
            30 August 93  Modify to add save static attributes.
*/

   
command_string       SMC_M_CmStUp,0,SMStCm
command_table        "sman.cmd"
class                SMCmdCmpStp
super_class          VDS_LOCATE
product_name         "$VDS"
form "SMCompSetUp",0,0,0,0

/*************************************************************************/
specification
#include <stdio.h>
#include <string.h>

#include "FI.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"

#include "PDUerror.h"
#include "VDSutil.h"

#include "vdsmacros.h"		/* vd$openfile	*/
#include "VDmsg.h"
#include "SMmsg.h"
#include "SMCompForm.h"

/* Gadgets symbol */
 
#define G_SYMB        44
#define G_TRACK       12
#define G_DB_LIST     13
#define G_CALC_SECT   14
#define G_PPL_ATT     16
#define G_SAVE_STATIC 19

instance
{
  struct ACrg_coll *ACrg;         /* The ACrg_coll for the data */
  struct GRid      coll;          /* Id of collection */
  IGRint           nb_attr;       /* Number of attributes */
  IGRboolean       save_static;   /* Save or not save static attributes     */
  IGRboolean       load_att_name; /* Verify if attributes name have already */
				  /* been loaded from database              */
}

/******************************************************************/

implementation

#ifdef ENV5
%safe
#include "VX_FIproto.h"
%endsafe
#endif

#define AS_DEBUG	1
#include "VDmem.h"
#include "AS_status.h"

from ACrg_collect import AClist_attribute,ACadd_list_attribute,
                         ACset_list_attribute,ACget_named_attribute;
from GRgraphics import GRputname;            
     

extern GRclassid OPP_ACrg_collect_class_id;

/* Variable to manage list of already placed compart are here */
%safe
static int x_form = -1,y_form = -1;
%endsafe


/* When gadget ppl_att selected, put a default value if no previous value */
static void select_ppl_att(Form form)
{
  char            ppl_name[ATTR_TXT];
  IGRchar         my_msg[80];
  FILE		  *fptr;
  char            *pt,tmp[ATTR_TXT];
  IGRint          sel,pos;


  FIfld_get_text(form,G_PPL_ATT,0,0,ATTR_TXT,
		 (unsigned char *)ppl_name, &sel, &pos); 
  ppl_name[ATTR_TXT - 1] = '\0';

  if(ppl_name[0] == '\0') return; /* No default name to put */
  
  if(pt = strstr(ppl_name,".")) *pt = '\0'; /* Don't save extension */
  if(strlen(ppl_name) > 12)
   {
     ex$message(msgnumb = SM_E_CmBadPPL,buff = my_msg,
		type = "%s",var = `ppl_name`); 
     FIg_set_text(form,FI_MSG_FIELD,my_msg);
     return;
   }
  
  /* Verify that ppl file exists */
  fptr = NULL;
  strcpy(tmp,ppl_name);
  strcat(tmp,".e");
  vd$openfile(file_name	   = tmp,
	      product_name   = "Vds",
	      sub_path	   = "ppl/bin",
	      cur_dir	   = TRUE,
	      p_file	   = &fptr );
  if( fptr == NULL )
   {
     ex$message( msgnumb = SM_E_CmNoFile, buff = my_msg,
		type = "%s",var = `ppl_name`);
     FIg_set_text(form,FI_MSG_FIELD,my_msg);
     return;
   }
  else fclose(fptr);
}




/********************************************************************/
state_table

#include "SMmsg.h"
#include "VDSFilter.h"

state start
erase_form 0
  
  on CMD_TYPE = 0
    do form_position 
    do init_all
       on ERROR state terminate
    state form_modify

state form_modify
  display_form  0
  message_key  SM_M_CmStUp
  prompt_key   SM_P_CmFrMod 
  filter    get_event
  
  on EX_FORM_FINISHED   state terminate 

at delete do delete_all

/**********************************************************************/
action form_position
{
  if(x_form == -1 || y_form == -1)
   { x_form = 1; y_form = 100; }
  FIf_set_location(me->forms[0].form_ptr,x_form,y_form);
  *sts = OM_S_SUCCESS;
}

/* ----------------------- action delete_all ---------------------------- */

action  delete_all
{
  _FREE(me->ACrg);
  FIf_get_location(me->forms[0].form_ptr,&x_form,&y_form);
  *sts = OM_S_SUCCESS;
}


/* ----------------------- action form_notification ---------------------- */

action form_notification
{
  long     sts;
  int      state;
  IGRchar  my_msg[80];
  IGRint   save_static;
  
  if ( form_ptr == NULL ) return( OM_E_INVARG ); 
  
  FIg_set_text(form_ptr,FI_MSG_FIELD, "");
  
  switch ( gadget_label )
   {
  
   case FI_ACCEPT :
     om$send(msg = message SMCmdCmpStp.save_all(&sts),
	     targetid = my_id);
     
     FIg_set_state_off(form_ptr,FI_ACCEPT);
     if(sts == OM_S_SUCCESS)
       _put_response(resp = TERMINATE);
     goto quit;
     

   case FI_CANCEL :
     _put_response(resp = TERMINATE);
     goto quit;
     
   case FI_RESET :
     status = om$send(msg = message SMCmdCmpStp.reset_all(&sts),
		      targetid = my_id);
     if(!(status & sts & 1))
      {
	printf("Error reset\n");
	_put_response(resp = TERMINATE);
      }
     FIg_set_state_off(me->forms[0].form_ptr,FI_RESET);
     goto quit;

   case G_SYMB: 
     break;
     
   case G_TRACK:
     FIg_get_state(me->forms[0].form_ptr,G_TRACK,&state);
     if(state) FIg_enable(me->forms[0].form_ptr,G_DB_LIST);
     else      FIg_disable(me->forms[0].form_ptr,G_DB_LIST);
     
     break;
     
   case G_DB_LIST:  
     /* Code to add : recompute DB list of compart */
     status = om$send(msg = message SMCmdCmpStp.control_login(&sts),
		      targetid = my_id);
     if(!(status & sts & 1))
      {
	ex$message(msgnumb = SM_I_CmReqDbLog, buff = my_msg);
	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
	FIg_set_state_off(me->forms[0].form_ptr,G_DB_LIST);
      }
     else
      {
	SMRecomputeDbList();
	FIg_set_state_off(me->forms[0].form_ptr,G_DB_LIST);
      }
     break;

   case G_CALC_SECT: 
     break;
     
   case G_PPL_ATT: 
     select_ppl_att(me->forms[0].form_ptr);
     break;
    
   case G_SAVE_STATIC:
     FIg_get_state(me->forms[0].form_ptr,G_SAVE_STATIC,&save_static);
     /* Display a warning if option not save is choosen */
     if(!save_static)
      {
	status = om$send(msg = message SMCmdCmpStp.control_login(&sts),
			 targetid = my_id);
	if(!(status & sts & 1))
	 {
	   ex$message(msgnumb = SM_I_CmReqDbLog, buff = my_msg);
	   FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
	 }
      }
     break;
     
  } /* END switch ( gadget_label ) */

}

/* --------------- action initial_form_notification -------------------- */
/* Override to load the attributes from databse only when needed         */

action initial_form_notification
{
  long     sts;
  IGRchar  my_msg[80];
   
  if ( form_ptr == NULL ) return( OM_E_INVARG );
  if(gadget_label == G_SYMB)
   {
     status = om$send(msg = message SMCmdCmpStp.get_comp_att(&sts),
		      targetid = my_id);
     if(!(status & sts & 1))
      {
	ex$message( msgnumb = SM_E_CmNoDbAtt, buff = my_msg);
	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
      }
   }
}

/*----------------------- action init_all --------------------------------- */
/*                  Method call when state start                            */
/*------------------------------------------------------------------------- */
action init_all
{
  IGRlong           msg;
  IGRboolean	    CalFlg;
  
  me->coll.objid    = NULL_OBJID;
  me->ACrg          = NULL;
  me->load_att_name = FALSE; 
  me->save_static   = TRUE;

  /* Get Calculation On or Off */
  SMGetCalSctFlg(&CalFlg);
  FIg_set_state(me->forms[0].form_ptr,G_CALC_SECT,CalFlg);

  /* Get comp setup object */
  if(!SMGetSetupObj(&me->coll)) goto wrapup;

  /* If not found , create a setup reading setup file */
  if(me->coll.objid == NULL_OBJID)
    if(!SMReadCompSetup(SETUP_FILE_NAME,&me->coll))
      me->coll.objid = NULL_OBJID; /* No setup file, user will enter param */
  
  /* Read the flag save not save after having read setup */
  SMGetFlagCache("compartment",me->ModuleInfo.md_id.osnum,&me->save_static);

  /* Found , retrieve all attribute  */
  if(me->coll.objid != NULL_OBJID)
   { 
     status = om$send(msg = message ACrg_collect.AClist_attribute
		      (&msg, NULL, NULL, &me->nb_attr ),
		      targetid = me->coll.objid,
		      targetos = me->coll.osnum);
     as$status(sts = (status & msg),action = GOTO_VALUE,value = wrapup);

     me->ACrg = _CALLOC(me->nb_attr, struct ACrg_coll);
     if(!me->ACrg) {printf("Memory problem\n");goto wrapup;}

     status = om$send(msg = message ACrg_collect.AClist_attribute
		      (&msg, me->nb_attr, me->ACrg,&me->nb_attr ),
		      targetid = me->coll.objid,
		      targetos = me->coll.osnum);
     as$status(sts = (status & msg),action = GOTO_VALUE,value = wrapup);

     om$send(msg = message SMCmdCmpStp.put_attr_in_form(sts),
	     targetid = my_id);
   }
  else
   {
     FIg_set_state_off(me->forms[0].form_ptr,G_TRACK);
     FIg_disable(me->forms[0].form_ptr,G_DB_LIST);
   }

  *sts = OM_S_SUCCESS;
   return OM_S_SUCCESS;

 wrapup :
  _FREE(me->ACrg); 
  me->state = _terminate;
  *sts = OM_E_ABORT;
  return OM_I_STOP_SENDING;
}

/* ---------------------  action reset_all --------------------------- */

action reset_all
{
  if(me->ACrg)
    om$send(msg = message SMCmdCmpStp.put_attr_in_form(sts),
	    targetid = my_id);

  *sts = OM_S_SUCCESS;
}

/* ------------------------- action save_all ------------------------- */
/* Method use when FI_ACCEPT or FI_EXECUTE selected in the main_form   */

action save_all
{
  char             name_symb[ATTR_TXT],name[ATTR_TXT],ppl_name[ATTR_TXT];
  IGRint           track,calc_sect,sel,pos,save_att,nb_att = 0;
  struct ACrg_coll att;
  IGRchar          my_msg[80];
  FILE		   *fptr;
  IGRboolean	   CalFlg;
  IGRshort	   Type;
  char             *pt,tmp[ATTR_TXT];

  name_symb[0] = '\0';
  FIg_get_text(me->forms[0].form_ptr,G_SYMB,name_symb);

  /* Get compart tracking and calculation section flag */
  FIg_get_state(me->forms[0].form_ptr,G_TRACK,&track);
  FIg_get_state(me->forms[0].form_ptr,G_CALC_SECT,&calc_sect);
  FIg_get_state(me->forms[0].form_ptr,G_SAVE_STATIC,&save_att);

  /*   Set save or not save cache          */ 
  SMSetFlagCache("compartment",save_att);
  
  SMGetCalSctFlg(&CalFlg);
  if(CalFlg && !calc_sect  || !CalFlg && calc_sect )
   { Type = 2; SMSetCalSctFlg(Type); /* Switch */ }
  
  /* Retrieve PPL attributes  file */
  nb_att = 0;
  ppl_name[0] = '\0';
  FIfld_get_text(me->forms[0].form_ptr,G_PPL_ATT,0,0,ATTR_TXT,
		 (unsigned char*)ppl_name,&sel,&pos);
  if(ppl_name[0] != '\0')
   {
     if(pt = strstr(ppl_name,".")) *pt = '\0'; /* Don't save extension */
     if(strlen(ppl_name) > 12)
      {
	ex$message(msgnumb = SM_E_CmBadPPL,buff = my_msg,
		   type = "%s",var = `name`); 
	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
	   goto wrapup;
      }
  
     /* Verify that ppl file exists */
     fptr = NULL;
     strcpy(tmp,ppl_name);
     strcat(tmp,".e");
     vd$openfile(file_name	   = tmp,
		 product_name      = "Vds",
		 sub_path	   = "ppl/bin",
		 cur_dir	   = TRUE,
		 p_file	   = &fptr );
     if( fptr == NULL )
      {
	ex$message( msgnumb = SM_E_CmNoFile, buff = my_msg,
		   type = "%s",var = `ppl_name`);
	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
	goto wrapup;
      }
     else fclose(fptr);
	
     strcpy(att.name,"PPL_FILE");
     att.desc.type = AC_ATTRIB_TEXT;
     strcpy(att.desc.value.att_txt,ppl_name);
     nb_att++;
   }
 
  _FREE(me->ACrg);
  
  me->nb_attr = nb_att + 2; /* 2 = Symbology , tracking */
  me->ACrg = _CALLOC(me->nb_attr, struct ACrg_coll);
  if(!me->ACrg) { printf("Memory problem\n"); goto wrapup; }

  /* Fill ACrg with all attribute */
  strcpy(me->ACrg[0].name,SYMB_ATT_STR);
  me->ACrg[0].desc.type = AC_ATTRIB_TEXT;
  strcpy(me->ACrg[0].desc.value.att_txt,name_symb);
  
  strcpy(me->ACrg[1].name,TRACKING_STR);
  me->ACrg[1].desc.type = AC_ATTRIB_TEXT;
  strcpy(me->ACrg[1].desc.value.att_txt, track ? "yes" : "no");
  
  /* PPL attributes */
  if(nb_att)
   {
     strcpy(me->ACrg[2].name,att.name);
     me->ACrg[2].desc.type = AC_ATTRIB_TEXT; 
     strcpy(me->ACrg[2].desc.value.att_txt,att.desc.value.att_txt);
   }
  
  if(!SMSetSetupObj(&me->coll,me->ACrg,me->nb_attr))
   {printf("Error setting setup object\n"); goto wrapup;}
  
  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS; 
  
 wrapup :
  *sts = OM_W_ABORT;
}   
 

/* ------------------ action put_attr_in_form ------------------------- */
/* Put all attributes of the ACrg in the form                           */
/* -------------------------------------------------------------------- */

action put_attr_in_form
{
  int          i;
  char         val_txt[ATTR_TXT];
  Form         form;
  int          state;

  form = me->forms[0].form_ptr;

  if(me->ACrg != NULL)
   {
     val_txt[0] = '\0';
     SMGetAttr(SYMB_ATT_STR,me->ACrg,NULL,me->nb_attr,
	       (int *)NULL,(double *)NULL,val_txt,(IGRshort *)NULL);
     FIg_set_text(me->forms[0].form_ptr,G_SYMB,val_txt);

     val_txt[0] = '\0';
     SMGetAttr(TRACKING_STR,me->ACrg,NULL,me->nb_attr,
	       (int *)NULL,(double *)NULL,val_txt,(IGRshort *)NULL);
     state = strcmp(val_txt,"yes") ? 0 : 1 ;
     FIg_set_state(me->forms[0].form_ptr,G_TRACK, state);
     if(state)  
       FIg_enable(me->forms[0].form_ptr,G_DB_LIST);
     else
       FIg_disable(me->forms[0].form_ptr,G_DB_LIST);

     /* Retrieve the save/not save static attributes */
     
     
     FIg_set_state(me->forms[0].form_ptr,G_SAVE_STATIC,me->save_static);
     
     /* Look all attributes to find PPL attributes */
     for(i=0;i<me->nb_attr;i++)
      {
	if(strncmp(me->ACrg[i].name,"PPL_",4)) continue; /* Not PPL name */
	FIfld_set_text(form,G_PPL_ATT,0,0,me->ACrg[i].desc.value.att_txt,0);
      }
   }
     
  *sts = OM_S_SUCCESS;
}

/* -------------------- action control_login -------------------------- */
/* Control that user is logged into database.                           */
/* -------------------------------------------------------------------- */

action control_login
{
  if(VDSverify_login() != PDM_S_SUCCESS)
   {
     ex$message(msgnumb = SM_E_CmNoDbLog);
     *sts = OM_E_ABORT;
     return OM_I_STOP_SENDING;
   }

  if(VDSverify_project() != OM_S_SUCCESS)
   {
     ex$message(msgnumb = VD_E_PrUsNotSel);
     *sts = OM_E_ABORT;
     return OM_I_STOP_SENDING;
   }
 
  *sts = OM_S_SUCCESS;
}

/* ----------------------- action get_comp_att ------------------------ */
/* This action retrieve all attributes in database                      */ 
/* -------------------------------------------------------------------- */

action get_comp_att
{
  int               row,i; 
  struct temp_attr *name_att; /* Name of static attributes   */
  int               nb_stat;  /* Number of static attributes */
  IGRboolean        units_set_exists;
  struct part_attr  dyn_part;
  int	            part_units;
  int               attr_mask;
  IGRchar           my_msg[80];
  

  name_att = NULL;

  if(me->load_att_name) { *sts = OM_S_SUCCESS; return OM_S_SUCCESS; }

  status = om$send(msg = message SMCmdCmpStp.control_login(sts),
		   targetid = my_id);
  if(!(status & *sts & 1)) goto wrapup;

  ex$message(msgnumb = SM_I_CmLoadDb,buff = my_msg);
  FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
  
 /* Retrieve all static attributes name  */
  if(!VDquery_att_name("compartment",&nb_stat,&name_att,&units_set_exists))
    goto wrapup;
  for(row = 0; row < nb_stat - 1; row++)
   {
     VDfld_set_list_text(me->forms[0].form_ptr,G_SYMB,row,0,
			 name_att[row + 1].attr_name,0);
     FIfld_set_list_default_text(me->forms[0].form_ptr,G_SYMB,row,0,
				 name_att[row + 1].attr_name,0);
   }

  /* Retrieve dynamic attr */
  VdsGetProjectUnits( &part_units );
  if(!VDget_dynattr(part_units,"compartment",&dyn_part))
    goto wrapup;
  
  for(i=0; i < dyn_part.nb_att; i++)
   {
     VDfld_set_list_text(me->forms[0].form_ptr,G_SYMB,row,0,
			 dyn_part.att[i].attr.name,0);
     FIfld_set_list_default_text(me->forms[0].form_ptr,G_SYMB,row,0,
				 dyn_part.att[i].attr.name,0);
     row++;
   }
  VDfree_allocated_parts( 0,(struct part_attr *)NULL, &dyn_part);
  FIg_get_attr(me->forms[0].form_ptr,G_SYMB,&attr_mask);
  if(attr_mask & FI_INITIAL_NOTIFY) 
    FIg_set_attr(me->forms[0].form_ptr,G_SYMB,attr_mask ^ FI_INITIAL_NOTIFY);
  
  me->load_att_name = TRUE;

  _FREE(name_att) ;

  FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");
  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS; 

 wrapup:
  _FREE(name_att) ;
  
  *sts = OM_E_ABORT;
  return OM_S_SUCCESS;
}



