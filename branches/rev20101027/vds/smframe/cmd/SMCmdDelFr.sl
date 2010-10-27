/* $Id: SMCmdDelFr.sl,v 1.1.1.1 2001/01/04 21:07:34 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smframe/cmd / SMCmdDelFr.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdDelFr.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:34  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/12/02  08:59:44  pinnacle
# Replaced: smframe/cmd/SMCmdDelFr.sl for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1996/04/30  23:28:06  pinnacle
# Replaced: smframe/cmd/SMCmdDelFr.sl for:  by azuurhou for vds.240
#
# Revision 1.4  1996/04/17  14:26:56  pinnacle
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
 *	12/02/97	Sundar		Changed instance & methods init_mem
 *					and delete_mem for the CR:179309743.
 *
 * -------------------------------------------------------------------*/

/**********************************************************************/
/*  CO for Add or Delete a frame or delete frame system               */
/*  Jean Jasinczuk                                                    */
/*  Creation Dates : 20-12-92                                         */ 
/**********************************************************************/

command_string		SMC_M_FrIns,0,SMInFr
synonym			SMC_M_FrDel,1,SMDlFr
synonym			SMC_M_FrDlPlSyst,2,SMDlPlSs
command_table		"sman.cmd"
class			SMCmdDelFr
super_class		VDS_LOCATE
product_name		"$VDS"

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
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "SMframe.h"

#include "SMmsg.h"

instance {
    struct GRid new_list[4];     /* List for the frame system */
    struct GRid old_list[4];

    struct frame_def frame_def_info;     
    struct sect_info sect_info[NB_MAX_SECTION];
    struct nm_sect_info nm_sect_info[NB_MAX_SECTION];

    IGRint lowest_frame,highest_frame; /* Number of lowest and highest frame */
     
    struct GRid *list_frame;  /* The list passed to the Delete  */
    IGRint nb_sel_frame;      /* The number of frame selected */

    struct GRid   owner; /* The ACdiowner which represent frame system */
    IGRint *list_num_frame;  /* The list of num frame passed to add */
}

/*************************************************************************/

implementation

#define AS_DEBUG	1
#define NB_ALLOC        100
#define EXTREME_FRAME   508
#define BEFORE   1
#define AFTER    0


#include "AS_status.h"
#include "VDmem.h"
#include "v_dbgmacros.h"
#include "coparadef.h"
#include "coparamac.h"


from GRvg       import GRgetname;
from expression import NDgive_value;
from NDnode     import NDget_objects,NDdisplay; 
from ACcpx      import find_macro;
from ACcpx_defn import ACgive_name;
from SMfrm_syst import GRdelete,SMdisplay_all_frame;

/*************************************************************************/

state_table

#include "SMmsg.h"
#include "VDSFilter.h"

#define MY_ERROR 507
#define EXTREME_FRAME 508
#define OLD_FRAME_SYSTEM 511
#define BEFORE   1
#define AFTER    0

state start
	on CMD_TYPE = 0 state ad_frame_locate

        on CMD_TYPE = 1 state del_frame_locate    

        on CMD_TYPE = 2 state del_plane_syst

state del_plane_syst
  message_key            SM_M_FrDelSys
  prompt_key             SM_P_FrLocate
  accept_key             SM_P_FrAccRej
  locate_class           "SMfrm_syst" 
  locate_owner           "LC_RIGID_COMP | LC_RIGID_OWNER |
                          LC_FLEX_COMP | LC_FLEX_OWNER"
  filter                 vds_locate 

  on EX_DATA or EX_STRING do del_frm_syst
                          state terminate

state ad_frame_locate
    message_key	       SM_M_FrAddFr
    prompt_key	       SM_P_FrLocOne
    accept_key         SM_P_FrAccRej
    locate_class       "SMframe"
    mask               "GRm_DATA | 
                        GRm_STRING | GRm_RESET | GRm_BACK_UP" 
    locate_display     "ALL_WINDOWS | ELEM_HILIGHT | LC_ERASE_LOC_ELEMENT" 
                      /* Erase only the last elem */ 
  locate_owner  "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP | LC_FLEX_OWNER"
    filter              vds_locate_noauto

      
    on  EX_DATA  or EX_STRING
                          do add_control_frame
                          on RETURN_CODE = MY_ERROR 
                              do status_key  SM_I_FrLocate
                              state .
                          on  RETURN_CODE = EXTREME_FRAME
                               state where_add 
			  on RETURN_CODE = OLD_FRAME_SYSTEM
         	            do status_key SM_I_UpdFrSyst
  			    state terminate 
                          on ERROR  state terminate
                       state .
                    
    on EX_RJT_MOVEON    do one_selected
                           on ERROR state terminate
                        do add_frame
                        state terminate
  
    on EX_BACK_UP      do remove_last 
                       state .  

state where_add
    prompt_key         SM_P_FrBefAft
    filter             get_event

    on EX_DATA or EX_STRING.GRst_DEFAULT or EX_STRING = "b"
                          do push_frame(&me->ret,BEFORE)
                          state ad_frame_locate
                       
     on EX_RJT_MOVEON or EX_STRING = "a" 
                          do push_frame(&me->ret,AFTER)
                          state ad_frame_locate    

    on EX_BACK_UP         do remove_last
                         state -

state del_frame_locate
    message_key	        SM_M_FrDelete
    prompt_key	        SM_P_FrDelOne
    accept_key          SM_P_FrAccNext 
    locate_class       "SMframe"
    mask               "GRm_DATA | GRm_OBJID |
                        GRm_STRING | GRm_RESET | GRm_BACK_UP" 
    locate_display     "ALL_WINDOWS | ELEM_HILIGHT | LC_ERASE_LOC_ELEMENT" 
                       /* Erase only the last elem */
    locate_owner  "LC_RIGID_COMP | LC_RIGID_OWNER |
                   LC_FLEX_COMP | LC_FLEX_OWNER "
    filter              vds_locate_noauto

  on  EX_DATA or EX_STRING  or EX_OBJID
                     do del_control_frame
                          on RETURN_CODE = MY_ERROR 
                              do status_key  SM_I_FrLocate
                              state .
                          on RETURN_CODE = OLD_FRAME_SYSTEM
         	            do status "Update this frame system with ci=UpdFrame"
  			    state terminate 
                         on ERROR  state terminate
                      do chain_locate   
                      state  .  

  on EX_RJT_MOVEON    do one_selected
                         on ERROR state terminate
                      do delete_frame
                      do dehilite 
                      state terminate

  on EX_BACK_UP      do remove_last 
                      state .  

at init		do init_mem
at wakeup	do hilite_half
at sleep	do dehilite
at delete	do delete_mem
 

/*************************************************************************/

/* Alloc memory for different list */
action init_mem
{
	SetProc( SMCmdDelFr_init_mem_MTD ); Begin

	me->nb_sel_frame = 0;
	me->frame_def_info.sect_info = NULL ;
	me->frame_def_info.sect_info = me->sect_info; 
	/* Added 2 lines for CR:179309734 by sundar */
	me->frame_def_info.nm_sect_info = NULL ;
	me->frame_def_info.nm_sect_info = me->nm_sect_info; 
	me->list_frame = NULL;
	me->list_num_frame = NULL;

  if(me->mytype == 0 || me->mytype == 1)  /* Del or Add frame command */
   {  
     me->list_frame = _MALLOC( NB_ALLOC, struct GRid );
     if(me->list_frame == NULL) 
     {
	printf("Can't alloc memory\n");
	me->state = _terminate;
	return OM_I_STOP_SENDING;
     }

     me->list_num_frame = _MALLOC( NB_ALLOC, IGRint );
     if(me->list_num_frame == NULL) 
     {
	printf("Can't alloc memory\n");
	me->state = _terminate;
	return OM_I_STOP_SENDING;
     }
   }   

	End
	goto quit ;
}             


/* Free the alloc memory */               
action delete_mem
{
	SetProc( SMCmdDelFr_delete_mem_MTD ); Begin

	dp$erase_hilite(msg = sts);
	_FREE(me->list_frame);
	_FREE(me->list_num_frame);

	me->frame_def_info.sect_info = NULL ; 
	me->frame_def_info.nm_sect_info = NULL ; 
	me->list_frame		= NULL ;
	me->list_num_frame	= NULL ;

	End
	goto quit ;
}

/* Place the response of the accept on the queue       */
/* So the accept event becomes the next located object */
action chain_locate
{
  long msg;
  long size = sizeof(struct GRevent ) - sizeof(long ) * 2;

	SetProc( SMCmdDelFr_chain_locate_MTD ); Begin
  
  if(me->event1.response == EX_DATA || me->event1.response == EX_STRING)
   {
     ex$putque( msg = &msg,
	       byte = &size, 
	       response = &me->event1.response,
	       buffer = (char *)&me->event1.event);
     
     as$status();
   }
}	

/* ****************************************************************** */
/* Method to control and retrieve information of the locateds objects */
/* Ignore object wich are not frame                                   */
/* Place objid of frame in me->list_frame and update me->nb_sel_frame */
/* Return MY_ERROR if no frame found, OM_E_ABORT if no memory         */
/* ****************************************************************** */

action del_control_frame
{
  struct GRid loc_obj;      
  int         i,j;
  int         find,nb_frame = 0; /* Nb_frame : number of frame now localised */
  IGRlong     msg;
  IGRint      nb_obj;
  struct GRid  *LocatedObjects;
  
	SetProc( SMCmdDelFr_del_control_frame_MTD ); Begin

	nb_obj	= 0 ;
  
	as$start_fence(	set	= &me->event1.located_object[0].located_obj,
			nb_obj		= &nb_obj,
			p_obj		= &LocatedObjects,
			response	= NULL,
			response_data	= NULL );

/***
	ASstart_fence(	me->event1.located_object[0].located_obj,
			me->ModuleInfo.md_id.osnum,
			&nb_obj,
			&LocatedObjects,
			me->response,
			me->response_data );
 ****/
  
  if(nb_obj == 0)
   {
     /*"No obj selected\n",nb_obj*/
     *sts = MY_ERROR;
     goto quit;
   }
  
  for(i = 0; i < nb_obj ; i++)
   {
     loc_obj = LocatedObjects[i];   
     /* verify the macro name  */
     status = om$send(msg = message SMCmdDelFr.control_frame(sts,&loc_obj),
		      targetid = my_id);
     as$status();
     
     switch(*sts)
      {
      case OM_E_ABORT : 
      case OLD_FRAME_SYSTEM : goto quit;
      case MY_ERROR :
	/* Surely a macro but perphaps not the good one, dehilight */ 
	status = om$send(msg = message NDnode.NDdisplay
			 (0,GRhe,&me->ModuleInfo),
			 targetid = loc_obj.objid,
			 targetos = loc_obj.osnum);
	as$status();
	continue; /* Probably not a frame */
      case OM_S_SUCCESS :
	break;
      }
     
     /* Verify the frame is not already select  */
     find = FALSE;
     for(j = 0; j < me->nb_sel_frame; j++) 
      {
	if(me->list_frame[j].objid == loc_obj.objid 
	   && me->list_frame[j].osnum == loc_obj.osnum )
	 {
	   find = TRUE;
	   break;    
	 }
      }
     
     if(!find)
      {
	me->list_frame[me->nb_sel_frame] = loc_obj;
	status = om$send(msg = message NDnode.NDdisplay
			 (0,GRhhd,&me->event1.located_object[0].module_info),
			 targetid = loc_obj.objid,
			 targetos = loc_obj.osnum);
	as$status();
	
	me->nb_sel_frame++;
	nb_frame++;
      }
   }
  
  ASend_fence();
  if(nb_frame == 0) *sts = MY_ERROR; else *sts = SUCC;

	End
	goto quit ;
}

/* **************************************************************************/
/* Method to control a frame to add after a locate                          */  
/* If the frame is not lowest and highest simply update the list_num_frame  */
/* else *sts = EXTREME_FRAME to question the user on the place he           */
/* want add a frame. In this case the located object and number is at       */
/* position me->nb_sel_frame                                                */
/* We ignore frame 0 unless it's the lowest frame then add frame -1         */
/* ************************************************************************ */  
  
action add_control_frame
{ 
  struct GRid	loc_obj;  
  double       	frame_numb;
  int          	nb_frame;
  IGRint       	bad_frame;
  struct frame 	*frame = NULL;
  
	SetProc( SMCmdDelFr_add_control_frame_MTD ); Begin

  loc_obj = me->event1.located_object[0].located_obj;
  
  status = om$send(msg = message SMCmdDelFr.control_frame
		   (sts,&loc_obj),
		   targetid = my_id);
  as$status();
  
  switch(*sts)
  {
   case OM_E_ABORT : 
   case OLD_FRAME_SYSTEM : goto quit;
   case MY_ERROR :
     /* Surely a macro but perphaps not the good one, dehilight */ 
     status = om$send(msg = message NDnode.NDdisplay
		      (0,GRhe,&me->ModuleInfo),
		      targetid = loc_obj.objid,
		      targetos = loc_obj.osnum);
     as$status();
     goto quit;

   case OM_S_SUCCESS :
     break;
  }   
  
  status = om$send(msg = message expression.NDgive_value(&frame_numb),
		   targetid = me->new_list[1].objid,
		   targetos = me->new_list[1].osnum);
  as$status();
  
  /* search lowest and highest frame num */
  if(me->nb_sel_frame == 0)
  {
     if(SMSetFrame(&me->frame_def_info, &nb_frame, &frame, &me->lowest_frame, 
		   &me->highest_frame, &bad_frame) != 1)
     {
	printf("Cannot retrieve the existing frame structure\n");
	printf("Problem with frame %d\n",bad_frame);
	_FREE( frame );
	return 0;
     }
     _FREE(frame); 
  }
  
  /* In any case can't add a frame 0 */
  if(frame_numb == 0)
  {
     /* If 0 is the lowest frame, we interpret the user want a -1 frame */
     if(me->lowest_frame == 0)
       frame_numb = -1;
     else 
     {
	ex$message( msgnumb = SM_E_FrAdZero);        
	status = om$send(msg = message NDnode.NDdisplay
			 (0,GRhe,&me->ModuleInfo),
			 targetid = loc_obj.objid,
			 targetos = loc_obj.osnum);
	as$status();
        *sts = MY_ERROR;
	goto quit;
      }
  } 
  
  /* If it is the highest or the lowest frame then question where to
     add a frame */   
  if(me->lowest_frame >= frame_numb || me->highest_frame <= frame_numb)
  {  
     me->list_frame[me->nb_sel_frame] = loc_obj;
     me->list_num_frame[me->nb_sel_frame] = (int)frame_numb;
     me->nb_sel_frame++;
     *sts = EXTREME_FRAME;
     goto quit;
  }
  
  me->list_frame[me->nb_sel_frame] = loc_obj;
  me->list_num_frame[me->nb_sel_frame] = (int)frame_numb;
  status = om$send(msg = message NDnode.NDdisplay
		   (0,GRhhd,&me->event1.located_object[0].module_info),
		   targetid = loc_obj.objid,
		   targetos = loc_obj.osnum);
  as$status();
  
  me->nb_sel_frame++;
  
	*sts = OM_S_SUCCESS;
	End
	goto quit ;
}

  
  /* ******************************************************************* */   
  /* Method to control the loc_obj is really a frame                     */
  /* Return MY_ERROR if not frame , OM_E_ABORT if big failure            */ 
  /* Reallocate memory for list of frame objid and frame num             */
  /* If it's the first frame selected, frame_def_info is assigned        */
  /* if it's not first frame, control it's in the same set as preceding  */
  /* ******************************************************************  */
  
action control_frame(long *sts; struct GRid *loc_obj)
{
  int         j;
  char        name_fr[DI_PATH_MAX];  
  struct GRid owner;

	SetProc( SMCmdDelFr_control_frame_MTD ); Begin

  /* Verify it's a frame */
  owner.objid = NULL_OBJID;
  switch(SMIsFrameObj(loc_obj,me->new_list,&owner,name_fr))
  {
   case 0:
     *sts = MY_ERROR;
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
	owner.osnum     != me->owner.osnum || 
	me->new_list[0].objid != me->old_list[0].objid || 
	me->new_list[2].objid != me->old_list[2].objid ||
	me->new_list[3].objid != me->old_list[3].objid )
      {
	ex$message(msgnumb = SM_W_FrSameSet);
	*sts = MY_ERROR; goto quit;
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
     
     for( j= 0; j < 4 ; j++)
       me->old_list[j] = me->new_list[j];
     me->owner.objid = owner.objid;
     me->owner.osnum = owner.osnum;
  }
    
  /* Verify the memory for the list */
  if(((me->nb_sel_frame + 1) % NB_ALLOC) == 0)
  {
     me->list_frame =_REALLOC
       (me->list_frame,(me->nb_sel_frame+1+NB_ALLOC),struct GRid);
  
     if(me->list_frame == NULL)
      { 
	printf("Not enough memory for allocation\n");
	*sts = OM_E_ABORT;
	goto quit;
      }
     
     me->list_num_frame = _REALLOC
       (me->list_num_frame,(me->nb_sel_frame+1+NB_ALLOC),IGRint);

     if(me->list_num_frame == NULL) 
      {
	printf("Can't realloc memory\n");
	*sts = OM_E_ABORT;
	goto quit;
      }   
   }

	*sts = OM_S_SUCCESS;
	End
	goto quit ;
}

/* Hilite in half bright the list of frame selected */
action hilite_half
{
  int i;
  IGRlong msg;
  
	SetProc( SMCmdDelFr_hilite_half_MTD ); Begin

  dp$erase_hilite(msg = &msg);
  for(i = 0; i < me->nb_sel_frame; i++)
   {
     status = om$send(msg = message NDnode.NDdisplay
		      (0,GRhhd,&me->ModuleInfo),
		      targetid = me->list_frame[i].objid,
		      targetos = me->list_frame[i].osnum);
     as$status();
   }

	End
	goto quit ;
}

action dehilite
{
  IGRlong msg;
  
  dp$erase_hilite(msg = &msg);
}

/* Remove last frame from the list (necessary for backup) */
/* It dehilight the element too                           */

action remove_last
{
  IGRlong msg;
  int i;
  int find;
  
	SetProc( SMCmdDelFr_remove_last_MTD ); Begin

  if(me->nb_sel_frame > 0)
   { 
     me->nb_sel_frame--;
     
     find = FALSE;
     /* If add command, search if the last element is not two times
	in the list */
     if(me->mytype == 0)  /* It's a add command */
       for(i = 0; i < me->nb_sel_frame ; i++)
	{
	  if(me->list_frame[me->nb_sel_frame].objid == me->list_frame[i].objid
	     && me->list_frame[me->nb_sel_frame].osnum == me->list_frame[i].osnum)
	   {
	     find = TRUE;
	     break;
	   }    
	}
     if(!find)
      {
	status = om$send(msg = message NDnode.NDdisplay
			 (0,GRhe,&me->ModuleInfo),
			 targetid = me->list_frame[me->nb_sel_frame].objid,
			 targetos = me->list_frame[me->nb_sel_frame].osnum);
	as$status();
      }
   }

	End
	goto quit ;
}  

/* Call adding a frame */
action add_frame
{
  IGRint bad_frame;
  int    i;
  
  /*  SMAdFrame always add a frame after if frame number is positive 
      and after if frame number is negative . Then we pass the next or the
      current frame */

	SetProc( SMCmdDelFr_add_frame_MTD ); Begin
  
  /*^     printf("List frame located\n");
    for(i = 0; i < me->nb_sel_frame; i++)
    printf("%d ",me->list_num_frame[i]);
    printf("\n");   */
  
  if(me->nb_sel_frame > 0)
   {
     if(SMAdFrame(&me->owner,&me->new_list[0],&me->new_list[2],&me->new_list[3],
		  &me->frame_def_info, me->nb_sel_frame,
		  me->list_num_frame,&bad_frame) == 0) 
      {
	ex$message( msgnumb = SM_E_FrAdEr, type = "%d", var = `bad_frame`);  
      } 
   }  

	End
	goto quit ;
  
}	

/* Add the frame in the two list of frame; this method must be called
   only if it's an extreme frame */
action push_frame(long *sts;int pos)
{
	SetProc( SMCmdDelFr_push_frame_MTD ); Begin

  status = om$send(msg = message NDnode.NDdisplay
		   (0,GRhhd,&me->ModuleInfo),
		   targetid = me->list_frame[me->nb_sel_frame -1].objid,
		   targetos = me->list_frame[me->nb_sel_frame -1].osnum);
  as$status();
  
  if(me->list_num_frame[me->nb_sel_frame -1] > 0)
   {
     if(pos == AFTER)
       me->list_num_frame[me->nb_sel_frame -1] += 1;
   }
  else /* me->list_num_frame  <= 0  (but 0 is treated in other action) */
   {
     if(pos == BEFORE)
       me->list_num_frame[me->nb_sel_frame -1] -= 1 ;
   }

	End
	goto quit ;
}

/* Call SMRemFrame */ 
action delete_frame
{
  IGRint  bad_frame;
  IGRlong test;
  
	SetProc( SMCmdDelFr_delete_frame_MTD ); Begin

  dp$erase_hilite(msg = &test);
  
  /*^ printf("Nb locate = %d\n",me->nb_sel_frame);
    printf("List objid locate\n");
    for(i = 0; i < me->nb_sel_frame; i++)
    printf("%d ",me->list_frame[i].objid);
    printf("\n"); */
  
  if(me->nb_sel_frame > 0)
   {
     if(SMRemFrame(&me->owner,&me->old_list[0],&me->old_list[2],&me->old_list[3],
		   &me->frame_def_info, me->nb_sel_frame,
		   me->list_frame,&bad_frame) == 0) 
      {   
	ex$message( msgnumb = SM_E_FrDelEr, type = "%d", var = `bad_frame`);
      } 
   }

	End
	goto quit ;
} 

/* *sts = OM_S_SUCCESS if one frame selected else OM_E_ABORT */
action one_selected
{
  if(me->nb_sel_frame > 0) *sts = OM_S_SUCCESS ; else *sts = OM_E_ABORT;
}

/* Delete globally the frame system */
action del_frm_syst
{
	IGRlong msg;

	SetProc( SMCmdDelFr_del_frm_syst_MTD ); Begin

	msg = MSSUCC ;

	me->owner = me->event1.located_object[0].located_obj;

	status =
	om$send(msg = message SMfrm_syst.SMdisplay_all_frame
		  (&msg,GRbe,&me->ModuleInfo),
		   targetid = me->owner.objid,
		   targetos = me->owner.osnum); 
	if(!(status & msg & 1))
	  { printf("ERROR erasing frame systrem\n"); return status;}

	status =
	om$send(msg = message SMfrm_syst.GRdelete(&msg,&me->ModuleInfo),
		   targetid = me->owner.objid,
		   targetos = me->owner.osnum);
  
	if(!(status & msg & 1))
	  {printf("ERROR delete frame system\n");return status;}

	End
	goto quit ;
}

