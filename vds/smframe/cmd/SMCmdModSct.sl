/* $Id: SMCmdModSct.sl,v 1.1.1.1 2001/01/04 21:07:34 cvs Exp $  */
 
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/smframe/cmd / SMCmdModSct.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SMCmdModSct.sl,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:34  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/12/02  09:05:48  pinnacle
# Replaced: smframe/cmd/SMCmdModSct.sl for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/08/09  09:58:58  pinnacle
# Replaced: smframe/cmd/SMCmdModSct.sl for:  by rgade for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/04/17  14:28:22  pinnacle
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
 *	08/09/96	Sundar		Deleted LC_REF_OBJECTS from locate_owner
 *      12/02/97        Sundar          Changed instance & methods init_all 
 *					and control_frame for the CR:179309743.
 *
 * -------------------------------------------------------------------*/

/**********************************************************************/
/*  CO for Adding or deleteing a frame in a section                   */
/*  Jean Jasinczuk                                                    */
/*  Creation Dates : 20-12-92                                         */ 
/**********************************************************************/

command_string      SMC_M_FrMdFrSect,0,SMMdScPlSs
command_table        "sman.cmd"
class                SMCmdModSct
super_class          VDS_LOCATE
product_name         "$VDS"

form "SMFrmModSect",0,0,0,0

specification

#include <stdio.h>
#include "igrtypedef.h"
#include "igetypedef.h"

#include "exdef.h"
#include "exmacros.h" 

#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"

/* #include "tools.h" * Not Required  --  AA */
#include "dp.h"
#include "dpmacros.h"
#include "asmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "griodef.h" 
#include "grgsmacros.h"
#include "grdpbmacros.h"
#include "FI.h"
#include "ACrg_collect.h"
#include "SMframe.h"


#include "SMmsg.h" 

instance {
    struct GRid new_list[4];     /* List for parent of a frame  */
 
    struct frame_def frame_def_info;     
    struct frame_def new_frame_def_info;     
    struct sect_info sect_info[NB_MAX_SECTION];
    struct sect_info new_sect_info[NB_MAX_SECTION];
    struct nm_sect_info nm_sect_info[NB_MAX_SECTION];
    struct nm_sect_info new_nm_sect_info[NB_MAX_SECTION];

    IGRint lowest_frame,highest_frame; /* Number of lowest and highest frame */
 
    IGRint num_sect;          /* Number of the section where the 2 frame are*/
    IGRint fr_number1;        /* The number of the first frame */
    IGRint fr_number2;        /* The number of the second frame */
    IGRint old_nb_frame;      /* Number of frame in the section */
    IGRint nb_sel_frame;      /* Is it first or second frame */
    IGRint nb_new_spacing;      /* The number of frame user want in the section */
    struct GRid first_frame;  /* The first frame in the section */
    struct GRid second_frame; /* The second frame in the section */
    IGRchar name_fr[DI_PATH_MAX]; /* The name of the frame system */
    IGRchar name_tmp_fr[DI_PATH_MAX]; /* name of the tmp frame system */

    struct GRid *old_dep_grid; /* Array of intermediate frame in the section */
    IGRint *new_dep_number; /* Array of number of new frame to report depandancy */
    IGRshort *depandance; /* Array of true or false if exist depandance */
    struct GRid   owner; /* The ACdiowner which represent frame system */
}

/*************************************************************************/

implementation

#define AS_DEBUG 1 


#include "AS_status.h"
#include "v_dbgmacros.h"
#include "VDmem.h"

/* #define DEBUG 1 */

from NDnode     import NDget_objects,NDdisplay; 
from SMfrm_syst import SMfind_inter_frame;
from SMframe    import SMfind_frame_num;
from SMfrm_syst import GRdelete;
/*************************************************************************/

state_table

#include "SMmsg.h"
#include "VDSFilter.h"

#define BAD_ELEMENT_LOCATED   507
#define OLD_FRAME_SYSTEM 511
#define NOT_SAME_SECTION 512
#define NEED_NO_CHANGE   513
#define NOT_SAME_SYSTEM  514
#define NO_MORE_FRAME    515
#define MOD_SECT         516
#define NO_DEPANDANCE    517
#define POS_NEG_SECTION  518
#define EGAL_BOTH_FRAME  519

state first_frame
  erase_form  0
  message_key	     SM_M_FrModSect
  prompt_key         SM_P_FrFirstSect
  accept_key         SM_P_FrAccRej
  locate_class       "SMframe"
  mask               "GRm_DATA | 
                        GRm_STRING | GRm_RESET | GRm_BACK_UP" 
  locate_owner  "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP | LC_FLEX_OWNER"
  filter               vds_locate

      
  on  EX_DATA or EX_STRING
                     do control_first_frame
                     on RETURN_CODE = BAD_ELEMENT_LOCATED 
                              do status_key  SM_I_FrLocate
                              state .
                     on RETURN_CODE = OLD_FRAME_SYSTEM
         	            do status "Update this frame system with ci=UpdFrame"
  			    state terminate 
                          on ERROR  state terminate
                     state second_frame
  
 on  EX_RJT_MOVEON state .
  
                    
state second_frame
  erase_form 0
  message_key        SM_M_FrModSect	    
  prompt_key         SM_P_FrEndSect            
  accept_key         SM_P_FrAccRej
  locate_class       "SMframe"
  mask               "GRm_DATA | GRm_STRING | GRm_RESET | GRm_BACK_UP"
  locate_owner  "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP | LC_FLEX_OWNER"
  filter              vds_locate_noauto

      
  on  EX_DATA or EX_STRING
   		do control_second_frame
                on RETURN_CODE = BAD_ELEMENT_LOCATED 
                     do status_key  SM_I_FrLocate
                     state .
                on RETURN_CODE = NOT_SAME_SECTION
                     do status_key SM_W_FrSameSect
                     state .
                on RETURN_CODE = POS_NEG_SECTION
                     do status_key SM_W_FrPosNeg
                     state .
                on RETURN_CODE = EGAL_BOTH_FRAME
                    do status_key SM_W_FrNeedDiff
  	       	    state .
                on ERROR state terminate
                state create_inter

  on EX_BACK_UP
               do deselect_fr_one
               state - 
                 
  on  EX_RJT_MOVEON state .

state create_inter
erase_form 0
message_key        SM_M_FrModSect
prompt_key         SM_P_FrHowMany
filter             get_event

  on EX_STRING
                 do control_nb_in_sect
                   on RETURN_CODE = BAD_ELEMENT_LOCATED 
                       do status_key SM_I_FrNeedPos
                       state .
                    on RETURN_CODE = NEED_NO_CHANGE
                      do status_key SM_I_FrNoChange
 		      state terminate
                 do init_form_dep
                    on RETURN_CODE = NO_DEPANDANCE 
                       do mod_frm_syst
                       state terminate
                    on ERROR state terminate
                state locate_depandancy 

state  locate_depandancy
display_form 0
message_key SM_M_FrModSect
prompt_key  SM_P_FrPlMd
filter  get_event 
   
  on GR_UNKNOWN_TYPE.MOD_SECT
  do dehilite
  do mod_frm_syst
  state terminate       

at init do init_all
at wakeup do wakeup_all
at sleep do dehilite
at delete do delete_all

 
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
action form_notification ( int form_label ; int gadget_label ; double value ;
                           char * form_ptr ) extern

action init_form_dep extern
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

/* Alloc memory for different list */
action init_all
{
  SetProc ( SMCmdModSct.init_all ); Begin

  me->nb_new_spacing = 0;
  me->frame_def_info.sect_info = me->sect_info; 
  me->frame_def_info.nm_sect_info = me->nm_sect_info; 
  me->nb_sel_frame = 0;  
  me->fr_number1 = me->fr_number2 = -1;
  me->first_frame.objid = NULL_OBJID;
  me->second_frame.objid = NULL_OBJID;
  me->old_dep_grid = NULL;
  me->new_dep_number = NULL;
  
  End
}             

action wakeup_all
{
  SetProc ( SMCmdModSct.wakeup_all ); Begin

  if(me->first_frame.objid != NULL_OBJID)
   {
     status = om$send(msg = message NDnode.NDdisplay(1, GRhd, NULL),
		      targetid = me->first_frame.objid,
		      targetos = me->first_frame.osnum);
     as$status(action = CONTINUE);
   }
  if(me->second_frame.objid != NULL_OBJID)
   {
     status = om$send(msg = message NDnode.NDdisplay(1, GRhd, NULL),
		      targetid = me->second_frame.objid,
		      targetos = me->second_frame.osnum);
     as$status(action = CONTINUE);
   }

   End
}

/* Free the alloc memory */               
action delete_all
{
  SetProc ( SMCmdModSct.delete_all ); Begin

  dp$erase_hilite(msg = sts);
  if(me->old_dep_grid != NULL) _FREE(me->old_dep_grid);
  if(me->new_dep_number != NULL) _FREE(me->new_dep_number);

  End
}

action control_first_frame
{
  struct GRid loc_obj;
  
  SetProc ( SMCmdModSct.control_first_frame ); Begin

  loc_obj.objid = me->event1.located_object[0].located_obj.objid;
  loc_obj.osnum = me->event1.located_object[0].located_obj.osnum;

  status =  om$send(msg = message SMCmdModSct.control_frame
		    (sts,&loc_obj),
		    targetid = my_id);
  if(!(status & *sts & 1))
    goto quit;

  me->first_frame.objid = loc_obj.objid;
  me->first_frame.osnum = loc_obj.osnum;
  me->nb_sel_frame = 1;

  *sts = OM_S_SUCCESS;
  End
}

action control_second_frame
{
  struct GRid loc_obj;
  IGRint temp,old_nb_frame;
  IGRint i;
  IGRint nb_to_change;
  IGRlong msg;

  SetProc ( SMCmdModSct.control_second_frame ); Begin

  loc_obj.objid = me->event1.located_object[0].located_obj.objid;
  loc_obj.osnum = me->event1.located_object[0].located_obj.osnum;

  if(loc_obj.objid == me->first_frame.objid &&
     loc_obj.osnum == me->first_frame.osnum)
   { *sts = EGAL_BOTH_FRAME; goto quit; } 

  status =  om$send(msg = message SMCmdModSct.control_frame
		    (sts,&loc_obj),
		    targetid = my_id);
  if(!(status & *sts & 1))
    goto quit;

  status =  om$send(msg = message SMframe.SMfind_frame_num
		    (&msg,&me->fr_number1),
		    targetid = me->first_frame.objid,
		    targetos = me->first_frame.osnum);
  if(!(status & msg &1))
   { *sts = BAD_ELEMENT_LOCATED; goto quit; }

  me->second_frame.objid = loc_obj.objid;
  me->second_frame.osnum = loc_obj.osnum;

  status =  om$send(msg = message SMframe.SMfind_frame_num
		    (&msg,&me->fr_number2),
		    targetid = me->second_frame.objid,
		    targetos = me->second_frame.osnum);
  if(!(status & msg &1))
   { *sts = BAD_ELEMENT_LOCATED; goto quit; }

  if(me->fr_number1 > me->fr_number2)
   {
     temp = me->fr_number1;
     me->fr_number1 = me->fr_number2;
     me->fr_number2 = temp;
   }

  if(me->fr_number1 < 0 && me->fr_number2 > 0)
   { status = om$send(msg = message NDnode.NDdisplay(1, GRhe, NULL),
		       targetid = me->second_frame.objid,
		       targetos = me->second_frame.osnum);
      as$status(action = CONTINUE);
      *sts = POS_NEG_SECTION; me->second_frame.objid = NULL_OBJID;goto quit;
    }  		


  if(!SMFindSection(me->sect_info,
		    me->frame_def_info.nb_sect,
	      	    me->fr_number1,me->fr_number2,&me->num_sect))
   {
     status = om$send(msg = message NDnode.NDdisplay(1, GRhe, NULL),
		      targetid = me->second_frame.objid,
		      targetos = me->second_frame.osnum);
     as$status(action = CONTINUE);
     *sts = NOT_SAME_SECTION; me->second_frame.objid = NULL_OBJID; goto quit;
   }

 /* if(me->frame_def_info.sect_info[me->num_sect].fr < 0 &&
     me->frame_def_info.sect_info[me->num_sect].to > 0)
    { *sts = POS_NEG_SECTION; goto quit; }  */

  me->nb_sel_frame = 2;
  me->old_nb_frame =  me->fr_number2 -  me->fr_number1 + 1;
  me->old_dep_grid =_MALLOC(me->old_nb_frame,struct GRid);
  me->new_dep_number =_MALLOC(me->old_nb_frame,IGRint);
  me->depandance = _MALLOC(me->old_nb_frame,IGRshort); 
  if(me->old_dep_grid== NULL || me->new_dep_number == NULL ||
      me->depandance == NULL)
   { printf("Not enough memory\n"); *sts = OM_E_ABORT; goto quit; }

  status =  om$send(msg = message SMfrm_syst.SMfind_inter_frame
		    ((IGRlong *)sts,&me->fr_number1,&me->fr_number2,
		     me->old_dep_grid,&old_nb_frame),
		     targetid = me->owner.objid,
		     targetos = me->owner.osnum);
  if(!(status & *sts & 1) || (old_nb_frame != me->old_nb_frame))
    goto quit;

  for(i = 0; i < me->old_nb_frame; i++)
   {
      if(!SMFindFrDepandancy(&me->old_dep_grid[i],NULL,NULL,&nb_to_change,
			     &me->ModuleInfo))
       {*sts = OM_E_ABORT; goto quit;}
      if(nb_to_change == 0) me->depandance[i] = FALSE;
      else me->depandance[i] = TRUE;
    }

  ex$message( msgnumb = SM_I_FrSectSpNb,type = "%d",var = `me->old_nb_frame-1`);
  
#ifdef DEBUG
  printf("Frame between %d and %d \n", me->fr_number1, me->fr_number2);
  for(i=0; i<me->old_nb_frame; i++)
    {
      printf("Frame %d id = %d osnum = %d\n",me->fr_number1 + i,
	     me->old_dep_grid[i].objid,me->old_dep_grid[i].osnum);
    }
#endif

  End
}


  /* ******************************************************************* */   
  /* Method to control the loc_obj is really a frame                     */
  /* Return BAD_ELEMENT_LOCATED if not frame , OM_E_ABORT if big failure            */ 
  /* If it's the first frame selected, frame_def_info is assigned        */
  /* if it's not first frame, control it's in the same set as preceding  */
  /* ******************************************************************  */
  
action control_frame(long *sts ; struct GRid *loc_obj)
{
  struct GRid owner;

  SetProc ( SMCmdModSct.control_frame ); Begin

  /* Verify it's a frame */
  owner.objid = NULL_OBJID;
  switch(SMIsFrameObj(loc_obj,me->new_list,&owner,me->name_fr))
   {
   case 0:
     *sts = BAD_ELEMENT_LOCATED;
     goto quit;
   case 1:
     break;
   case 2:
     *sts = OLD_FRAME_SYSTEM;
     goto quit;
   }
     
  
  /* If some frame already select, check the new frame is in the same set*/
  if(me->nb_sel_frame > 0)
   {
     if(owner.objid     != me->owner.objid ||
	owner.osnum     != me->owner.osnum)
      {
	ex$message(msgnumb = SM_W_FrSameSet);
	*sts = BAD_ELEMENT_LOCATED; goto quit;
      }
   }
  
  /* Save the set of frame we are working on if it's the first frame*/
  if(me->nb_sel_frame == 0)
   {   
     /* Retrieve the information for the frame structure */
     if(!SMFillFrmDefInfo(&me->new_list[2],NB_MAX_SECTION,&me->frame_def_info))
      {
	*sts = OM_E_ABORT;
	goto quit;
      }

     me->new_frame_def_info.main_info = me->frame_def_info.main_info;
     me->new_frame_def_info.sect_info = me->new_sect_info;
     me->new_frame_def_info.nm_sect_info = me->new_nm_sect_info;

     me->owner.objid = owner.objid;
     me->owner.osnum = owner.osnum;
   }
    
  *sts = OM_S_SUCCESS;
  End
}

/* Control the string for the nb_frame */
action control_nb_in_sect
{
  int value;

  SetProc ( SMCmdModSct.control_nb_in_sect ); Begin

  if (me->event1.response != EX_STRING)
   { *sts = BAD_ELEMENT_LOCATED; goto quit; }
  
  if(sscanf(me->event1.event.keyin,"%d",&value) != 1)
   { *sts = BAD_ELEMENT_LOCATED; goto quit; }
  
  if(value == me->fr_number2 - me->fr_number1)
    { *sts = NEED_NO_CHANGE; goto quit; }

  if(value > 0)
    me->nb_new_spacing = value;
   else
    { *sts = BAD_ELEMENT_LOCATED; goto quit; }

#ifdef DEBUG
  printf("Number of new spacing in the section %d \n",me->nb_new_spacing);
#endif
End
}

action deselect_fr_one
{
  SetProc ( SMCmdModSct.deselect_fr_one ); Begin

  if(me->first_frame.objid != NULL_OBJID)
   {
     status = om$send(msg = message NDnode.NDdisplay(1, GRhe, NULL),
		      targetid = me->first_frame.objid,
		      targetos = me->first_frame.osnum);
     as$status(action = CONTINUE);
     me->first_frame.objid = NULL_OBJID;
   } 

  End
}

/* Call the fonction for modifying the sections */
action mod_frm_syst
{
 IGRint bad_frame;
 
 SetProc ( SMCmdModSct.mod_frm_syst ); Begin

 if(!SMModFrSect(&me->owner,&me->new_list[0],&me->new_list[2],&me->new_list[3],
		  &me->frame_def_info,
		  me->fr_number1,me->fr_number2,me->nb_new_spacing,
		  me->old_dep_grid,me->new_dep_number,&bad_frame))
  {
     ex$message( msgnumb = SM_E_FrBadDefFr,type = "%d",var = `bad_frame`);
     *sts = BAD_ELEMENT_LOCATED; 
     goto quit;
   }
 End
}

action dehilite
{
  IGRlong msg;
  
  SetProc ( SMCmdModSct.dehilite ); Begin

  dp$erase_hilite(msg = &msg);

  End
}


	




