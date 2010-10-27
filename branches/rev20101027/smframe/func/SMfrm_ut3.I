/* $Id: SMfrm_ut3.I,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smframe/func / SMfrm_ut3.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMfrm_ut3.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:35  cvs
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
# Revision 1.3  1996/04/17  14:38:58  pinnacle
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
  
File SMfrm_ut3.I

Abstract : 
  

	Implemented functions used for the frame system.
        Implement the functions to modify the frame number in a section

	- Design date: 14-4-92

	- Jean Jasinczuk ISDC
*/

    
  
class implementation Root;

#include <stdio.h>
#include "OMmacros.h"
#include "exmacros.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "godef.h"
#include "igr.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h" 
#include "parametric.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "expression.h"
#include "expmacros.h"

#include "ACattrib.h"
#include "ACrg_collect.h" 
#include "SMframe.h"
#include "VDmem.h"

#include "AS_status.h"

/* prototypes */

/* #define DEBUG  */

#define EPSILON 0.00001

from NDnode 		import NDchg_state, NDs_compute_node, NDget_objects;
from NDnode		import  NDdisplay, NDchange_connect;
from GRvg		import GRputname, GRchglevel, GRchgname, GRgetname;
from ASnode             import ASpossible_parent;
from SMfrm_syst         import SMfind_frame_objid,SMfind_all_frame;


extern GRclassid OPP_SMfrm_syst_class_id;


/* Update the frames numbers */

static int SMChangeFrNumber(frame_obj,nb_frame,lowest_frame,highest_frame,
			    begin_sect,end_sect,nb_add_frame,bad_frame)
struct frame_obj  frame_obj[];  /* [I/O] frame obj to update */
IGRint nb_frame;               /* [I] Number of existing frame */
IGRint *lowest_frame,*highest_frame; /* [I/O] */
IGRint begin_sect;             /* [I] Begin frame for the section to modify*/
IGRint end_sect;               /* [I] End frame for the section to modify*/
IGRint nb_add_frame;           /* [I] The difference beetween old and new */
IGRint *bad_frame;             /* [O] If fail, frame where problem */
{
  IGRint fr_nb,fr_syst_index;
  IGRint i;

  if(begin_sect * end_sect < 0)
   {
     printf("Can't change frame number when sign of section are different\n");
     return 0;
   }

  for(i=0;i<nb_frame;i++)
    frame_obj[i].status = 0;

  /* We disting the case where the modified section is negative and the other*/
  
  /* If positive, translate the frame numbers which are higher */
  /* than the last frame in the section */
  if(begin_sect >= 0 && end_sect >= 0)
   {
     for(fr_nb = end_sect + 1; fr_nb <= *highest_frame; fr_nb++)
      {
	if(SMIsFrameSyst(frame_obj, nb_frame, fr_nb, &fr_syst_index) != 1)
	 {
	   *bad_frame = fr_nb;
	   return 0;
	 }
	frame_obj[fr_syst_index].new_frame_number =
	  frame_obj[fr_syst_index].old_frame_number + nb_add_frame;
	frame_obj[fr_syst_index].status = MOD_FRAME | NAME_FRAME | DISP_FRAME;
      }
   }

  /* If negative, translate the frame numbers which are lower */
  /* than the first frame in the section */
  if(begin_sect < 0 && end_sect <= 0)
   {
     for(fr_nb = begin_sect - 1; fr_nb >= *lowest_frame ; fr_nb--)
      {
	if(SMIsFrameSyst(frame_obj, nb_frame, fr_nb, &fr_syst_index) != 1)
	 {
	   *bad_frame = fr_nb;
	   return 0;
	 }
	frame_obj[fr_syst_index].new_frame_number =
	  frame_obj[fr_syst_index].old_frame_number - nb_add_frame;
	frame_obj[fr_syst_index].status = MOD_FRAME | NAME_FRAME | DISP_FRAME;
      }
   }

  /* Recompute all the frame in the section (spacing as change !) */
  for(fr_nb = begin_sect; fr_nb <= end_sect; fr_nb++)
   {
     if(SMIsFrameSyst(frame_obj, nb_frame, fr_nb, &fr_syst_index) != 1)
      {
	*bad_frame = fr_nb;
	return 0;
      }
     frame_obj[fr_syst_index].new_frame_number =
       frame_obj[fr_syst_index].old_frame_number;
     frame_obj[fr_syst_index].status = MOD_FRAME | COMP_FRAME ;
   }

  /* If we must add some frame in the section, we create the new frame(s) */
  /* at the end of the section if positive, at the begin if negative */

  if(nb_add_frame > 0)
   {
     IGRint new_fr_index = nb_frame - 1;

     for( i = 1; i <= nb_add_frame ; i++)
      {
	if(begin_sect >= 0 && end_sect >= 0)
	  frame_obj[new_fr_index + i].new_frame_number =
	    frame_obj[new_fr_index + i].old_frame_number = end_sect + i;
	else
	   frame_obj[new_fr_index + i].new_frame_number =
	     frame_obj[new_fr_index + i].old_frame_number = begin_sect - i;
	frame_obj[new_fr_index + i].status = CRT_FRAME;
      }
   }

  /* If we must delete some frame in the section, we delete */
  /* them from the end of the section if positive, from begin if negative */
   if(nb_add_frame < 0)
   {
     if(begin_sect >= 0 && end_sect >= 0)
       /* Remember nb_add_frame is negative ! */
       for( fr_nb = end_sect + nb_add_frame + 1; fr_nb <= end_sect; fr_nb++)
	{
	  if(SMIsFrameSyst(frame_obj, nb_frame, fr_nb, &fr_syst_index) != 1)
	   {
	     *bad_frame = fr_nb;
	     return 0;
	   }
	  frame_obj[fr_syst_index].status = DEL_FRAME;
	}
     else
       for( fr_nb = begin_sect - nb_add_frame - 1;
	   fr_nb >=  begin_sect ; fr_nb--)
	{
	  if(SMIsFrameSyst(frame_obj, nb_frame, fr_nb, &fr_syst_index) != 1)
	   {
	     *bad_frame = fr_nb;
	     return 0;
	   }
         frame_obj[fr_syst_index].status = DEL_FRAME;
	}
   }

 if(nb_add_frame > 0)
   *highest_frame = *highest_frame + nb_add_frame;   
 else
   *lowest_frame = *lowest_frame - nb_add_frame;

#ifdef DEBUG
  for(i = 0; i < nb_frame + ( nb_add_frame > 0 ? nb_add_frame : 0) ; i++)
   {
     printf("Frame_obj %d : old_number = %d new_number %d frame_status = %x\n",
	    i,frame_obj[i].old_frame_number,
	    frame_obj[i].new_frame_number,
	    frame_obj[i].status);
   }
#endif

  return 1;
}

/* Copy a sect_info to the other . It also increment the "fr" and "to" */
/* field of the new sect info with nb_trans */

static void copy_translate_sect(new_sect_info,sect_info,nb_trans)
struct sect_info *new_sect_info;       /* [O] Sect info to copy to */
struct sect_info *sect_info;           /* [I] Sect info to copy from */
int  nb_trans;                    /* [I] The number to add to fr and to */
{
  new_sect_info->fr = sect_info->fr + nb_trans;
  new_sect_info->to = sect_info->to + nb_trans;
  new_sect_info->spacing = sect_info->spacing ;
  new_sect_info->reinf = sect_info->reinf;
  new_sect_info->offset = sect_info->offset;
}

/* Given a section number, divide this section to have in the section */
/* between begin_sect and end_sect the new_nb_space number of frames */
/* Some sections can be add if necessary */

static int SMConsNewSect(sect_info,new_sect_info,
			 nb_sect,new_nb_sect,
			 num_sect,begin_sect,end_sect,new_nb_space)
struct sect_info sect_info[];  /* [I] the old definition of the sections */
struct sect_info new_sect_info[]; /* [O] the new definition of the sections */
IGRint nb_sect;                /* [I] the number of sections */
IGRint *new_nb_sect;           /* [O] the new number of sections */
IGRint num_sect;               /* [I] the section which contains the 2 frames */
IGRint begin_sect;             /* [I] the number of the begin frame */
IGRint end_sect;               /* [I] the number of the end_sect frame */
IGRint new_nb_space;           /* [I] New Number of space for the section */
{
  int old_nb_space,nb_add_frame;
  int translate_sup = 0,translate_inf = 0;
  double old_dist;
  int i;  
  
  if( nb_sect + 2 > NB_MAX_SECTION ||
     sect_info[num_sect].fr > begin_sect ||
     sect_info[num_sect].to < end_sect ||
     (begin_sect < 0 && end_sect > 0) ||
     (begin_sect == end_sect) ||
     new_nb_space <= 0)
    return 0;
  
  old_nb_space = end_sect - begin_sect;
  nb_add_frame = new_nb_space - old_nb_space ;/* Can be negative if deleted */
  
  /* First case , it is the global section */
  if(sect_info[num_sect].fr == begin_sect &&
     sect_info[num_sect].to == end_sect )
   {
     /* change spacing for this section */
     copy_translate_sect(&new_sect_info[num_sect],&sect_info[num_sect],0);
     old_dist  = old_nb_space * sect_info[num_sect].spacing; 
     new_sect_info[num_sect].spacing = old_dist / new_nb_space;
     
     /* If positive section, change number of frames after the section */
     if(begin_sect >= 0 &&  end_sect>=0)
      {
	translate_sup = nb_add_frame;
	translate_inf = 0;

	new_sect_info[num_sect].to = sect_info[num_sect].to + nb_add_frame;
      }
     
     /* If negative section, change number of frames before the section */
     if(begin_sect < 0 &&  end_sect <=0)
      {
	translate_sup = 0;
	translate_inf = -1 * nb_add_frame;

	new_sect_info[num_sect].fr = sect_info[num_sect].fr - nb_add_frame;
      }
     for(i = num_sect + 1; i <= nb_sect; i++)
       copy_translate_sect(&new_sect_info[i],&sect_info[i],translate_sup);
     for(i = 0 ; i <= num_sect - 1 ; i++)
       copy_translate_sect(&new_sect_info[i],&sect_info[i],translate_inf);

     *new_nb_sect = nb_sect;
     goto success;
   }
  
  /* The begin_sect is the first frame */
  if(sect_info[num_sect].fr == begin_sect)
   {
     /* spacing for the current section change */ 
     old_dist = old_nb_space * sect_info[num_sect].spacing;
     new_sect_info[num_sect].spacing = old_dist / new_nb_space;
     new_sect_info[num_sect].offset = sect_info[num_sect].offset;
     new_sect_info[num_sect].reinf  = NO_REINF;
     
     /* Etablish parameter for the new (num_sect + 1) section */
     new_sect_info[num_sect +1].spacing = sect_info[num_sect].spacing;
     new_sect_info[num_sect +1].offset = sect_info[num_sect].offset;
     new_sect_info[num_sect +1].reinf  = NO_REINF;
     
     if(begin_sect >= 0 && end_sect > 0)
      {
	/* Sections modifications : */
	/* num_sect       [fr --> begin] */
	/* (num_sect + 1) [begin --> to+nb_add_frame] */
	/* (num_sect + 2).. are translate of nb_add_frame */

	translate_sup = nb_add_frame;
	translate_inf = 0;

	/* From and to for new section */
	new_sect_info[num_sect +1].fr = end_sect + nb_add_frame;
	new_sect_info[num_sect +1].to = sect_info[num_sect].to + nb_add_frame;
	
	/* Change the num_sect */
	new_sect_info[num_sect].fr = sect_info[num_sect].fr;
	new_sect_info[num_sect].to = end_sect + nb_add_frame;
      }
     
     if(begin_sect < 0 && end_sect <= 0)
      {
	/* Sections modifications : */
	/* num_sect       [fr-nb_add_frame --> end_sect] */
	/* (num_sect + 1) [end_sect --> to] */
	/* .... (num_sect - 1) are translate of -nb_add_frame */
	
	translate_sup = 0;
	translate_inf = -1 * nb_add_frame;
	
	/* From and to for new section */
	new_sect_info[num_sect +1].fr = end_sect;
	new_sect_info[num_sect +1].to = sect_info[num_sect].to;
	
	/* Change the num_sect */
	new_sect_info[num_sect].fr = sect_info[num_sect].fr - nb_add_frame;
	new_sect_info[num_sect].to = end_sect;
      }
     for(i = num_sect+1; i <= nb_sect; i++)
       copy_translate_sect(&new_sect_info[i+1],&sect_info[i],translate_sup);
     for(i = 0; i <= num_sect - 1; i++)
       copy_translate_sect(&new_sect_info[i],&sect_info[i],translate_inf);
     *new_nb_sect = nb_sect + 1;
     goto success;
   }
  
  /* The end_sect is the last frame of the section */
  /* Symetrical problem of the preceding case      */
  if(sect_info[num_sect].to == end_sect)
   {
     old_dist = old_nb_space * sect_info[num_sect].spacing;
     new_sect_info[num_sect +1].spacing = old_dist / new_nb_space;
     new_sect_info[num_sect +1].offset = sect_info[num_sect].offset;
     new_sect_info[num_sect +1].reinf  = NO_REINF;
     
     new_sect_info[num_sect].spacing =  sect_info[num_sect].spacing;
     new_sect_info[num_sect].offset = sect_info[num_sect].offset;
     new_sect_info[num_sect].reinf  = NO_REINF;
     
     if(begin_sect >= 0 && end_sect > 0)
      {
	/* Translate of section num_sect + 1 .. */
	translate_sup = nb_add_frame;
	translate_inf = 0;

	/* create a new section */
	new_sect_info[num_sect +1].fr = begin_sect;
	new_sect_info[num_sect +1].to = sect_info[num_sect].to + nb_add_frame;
        
	/* Update "to" of the current section " */
	new_sect_info[num_sect].fr = sect_info[num_sect].fr;
	new_sect_info[num_sect].to = begin_sect;
      }
     
     if(begin_sect < 0 && end_sect <= 0)
      {
	translate_sup = 0;
	translate_inf = -1 * nb_add_frame;
	
	/* create a new section */
	new_sect_info[num_sect +1].fr = begin_sect - nb_add_frame;
	new_sect_info[num_sect +1].to = sect_info[num_sect].to;
	
	new_sect_info[num_sect].fr = sect_info[num_sect].fr - nb_add_frame;
	new_sect_info[num_sect].to = begin_sect - nb_add_frame;
      }

     for(i = num_sect+1; i <= nb_sect; i++)
       copy_translate_sect(&new_sect_info[i+1],&sect_info[i],translate_sup);
     for(i = 0; i <= num_sect - 1; i++)
       copy_translate_sect(&new_sect_info[i],&sect_info[i],translate_inf);
     *new_nb_sect = nb_sect + 1;
     goto success;
   }
  
  /* In general, create 2 new sections : */
  
  new_sect_info[num_sect + 2].spacing = sect_info[num_sect].spacing;
  new_sect_info[num_sect + 2].offset = sect_info[num_sect].offset;
  new_sect_info[num_sect + 2].reinf  = NO_REINF;
  
  old_dist = old_nb_space * sect_info[num_sect].spacing;
  new_sect_info[num_sect + 1].spacing = old_dist / new_nb_space ;
  new_sect_info[num_sect + 1].offset = sect_info[num_sect].offset;
  new_sect_info[num_sect + 1].reinf  = NO_REINF;
  
  new_sect_info[num_sect].spacing =  sect_info[num_sect].spacing;
  new_sect_info[num_sect].reinf   = NO_REINF;
  new_sect_info[num_sect].offset = sect_info[num_sect].offset;
  
  if(begin_sect >= 0 && end_sect > 0)
   {
     /* Sections modifications : */
     /* num_sect       [fr --> begin] */
     /* (num_sect + 1) [begin --> end + nb_add_frame] */ 
     /* (num_sect + 2) [end +nb_add_frame --> to + nb_add_frame] */
     /* (num_sect + 3) ....  are translate of nb_add_frame */

     translate_sup = nb_add_frame;
     translate_inf = 0;
   
     new_sect_info[num_sect + 2].to = sect_info[num_sect].to + nb_add_frame;
     new_sect_info[num_sect + 2].fr = end_sect + nb_add_frame;
     
     new_sect_info[num_sect + 1].to = end_sect + nb_add_frame;
     new_sect_info[num_sect + 1].fr = begin_sect;
     
     new_sect_info[num_sect].to = begin_sect;
     new_sect_info[num_sect].fr = sect_info[num_sect].fr;
   }
  
  if(begin_sect < 0 && end_sect <= 0)
   {
     /* Sections modifications : */
     /* num_sect       [fr-nb_add_frame --> begin - nb_add_frame] */
     /* (num_sect + 1) [begin - nb_add_frame --> end] */ 
     /* (num_sect + 2) [end --> to] */
     /* ... (num_sect -1) are translate of -nb_add_frame */

     translate_sup = 0;
     translate_inf = -1 * nb_add_frame;

     new_sect_info[num_sect + 2].to = sect_info[num_sect].to;
     new_sect_info[num_sect + 2].fr = end_sect;
     
     new_sect_info[num_sect + 1].to = end_sect;
     new_sect_info[num_sect + 1].fr = begin_sect - nb_add_frame;
     
     new_sect_info[num_sect].to = begin_sect - nb_add_frame;
     new_sect_info[num_sect].fr = sect_info[num_sect].fr- nb_add_frame ;
   }

  for(i = num_sect + 1; i <= nb_sect; i++)
    copy_translate_sect(&new_sect_info[i+2],&sect_info[i],translate_sup);
  for(i = 0; i <= num_sect - 1; i++)
    copy_translate_sect(&new_sect_info[i],&sect_info[i],translate_inf);
  *new_nb_sect = nb_sect + 2;

  
 success:
#ifdef DEBUG
  printf("New number of sections : %d \n",*new_nb_sect);
  for(i = 0; i < *new_nb_sect; i++)
    printf("Sect %d : fr = %d to = %d spac = %2.3f, offset = %d\n\n", 
	   i,new_sect_info[i].fr,new_sect_info[i].to, new_sect_info[i].spacing,
	   new_sect_info[i].offset);
#endif
  return 1;
}


/* Change the depandancy for the old frame to the new             */
/* A pointer to objects who depands from the old_fr must be given */
 
static int VDMoveFrDepandancy(new_fr,new_mod_env,old_fr,
			      obj_to_change,nb_to_change,cur_mod_env)
struct GRid     *new_fr;          /* [I] Frame to move depandancy to  */
struct GRmd_env *new_mod_env;     /* [I] Mod env of the frame  */  
struct GRid     *old_fr;          /* [I] Frame to move depandancy from  */
struct GRid    *obj_to_change;    /* [I] Depandancy on the old frame */  
IGRint nb_to_change;              /* [I] Number of object in depandancy */
struct GRmd_env *cur_mod_env;     /* [I] The current md_env */
{
  IGRlong        status;         /* routine return status */
  IGRint         i_to_change;
  IGRint         cn_type;
  struct GRid    *buffer;

#ifdef DEBUG
 printf("Depandancy of frame %d report to frame %d\n",
	old_fr->objid,new_fr->objid);
  for(i=0;i<nb_to_change;i++)
    printf("Objid = %d \n", obj_to_change[i].objid);
#endif 

  /*
    For the change root command change only connection on
    object that are dependent upon the swap root and parent
    of the object to change root.
    */
  
    /*| get if necessary source for the new roots */

    status = as$make_source(go_grid = *new_fr,
			    mod_env = new_mod_env,
			    as_os = cur_mod_env->md_id.osnum, 
			    as_grid = new_fr);
  as$status(action = RET_STATUS);
  
  /* 3 loops for batch purpose */
  
  for (i_to_change = 0; i_to_change < nb_to_change; i_to_change++)
   {
     IGRint i, nb_roots;
     char   flag;
     
     if(obj_to_change[i_to_change].objid == NULL_OBJID) continue;
     
     /*| Verify if there is a loop */
     if(nd$dep_exist(l_root = &obj_to_change[i_to_change], nb_root = 1,
		     l_tip  = new_fr, nb_tip = 1 )) continue;
     
     /*| Verify the new root is not already one and the located is */
     status=om$send(msg=message NDnode.NDget_objects
		    (ND_ROOT|ND_IN_BUF,
		     NULL,0,&buffer,0,OM_K_MAXINT,
		     &nb_roots),
		    senderid = NULL_OBJID,
		    targetid = obj_to_change[i_to_change].objid,
		    targetos = obj_to_change[i_to_change].osnum);
     
     flag = FALSE;
     for(i=0;i<nb_roots;i++) 
       if(IF_EQ_OBJID(buffer[i].objid,new_fr->objid)) flag = TRUE;
     if(flag) continue;
     
     flag = TRUE;
     for(i=0;i<nb_roots;i++) 
       if(IF_EQ_OBJID(buffer[i].objid,old_fr->objid)) flag = FALSE;
     if(flag) continue;
     
     /*| Swap the connections of the object */
     status = om$send(msg = message NDnode.NDchange_connect
		      ( 1, old_fr, new_fr),
		      senderid = NULL_OBJID, 
		      targetid = obj_to_change[i_to_change].objid,
		      targetos = obj_to_change[i_to_change].osnum);
     if(status != OM_S_SUCCESS) 
      {
	printf("Erreur NDchange connect\n");
	return 0;
      }
     
     cn_type = ND_COMP;
     nd$wait_batch(type = GR_GEOM_POSTED,
		   l_object = &obj_to_change[i_to_change],
		   l_obj_info = &cn_type,
		   nb_obj   = 1);
     
   }
  return 1;
}

static int SMModFrmSect(frame_def_info,nb_frame,frame,
		       lowest_frame, highest_frame,begin_sect,end_sect,
		       new_nb_space,bad_frame,glob_frame_obj)
struct frame_def *frame_def_info;
IGRint  	*nb_frame;
struct frame 	**frame;
IGRint		*lowest_frame, *highest_frame;
IGRint new_nb_space;    /* [I] New Number of space for the section */
IGRint	begin_sect,end_sect;
IGRint	*bad_frame;
struct glob_frame_obj	*glob_frame_obj;
{
  IGRint old_nb_space,nb_add_frame;
  IGRint num_sect;
  struct GRid   new_frame_info,new_frame_def;
  IGRlong	sts;
  IGRint new_nb_sect;
  struct sect_info new_sect_info[NB_MAX_SECTION];
  int i;
  int new_frame_number;
  struct GRid old_root[2],new_root[2];

  old_nb_space = end_sect - begin_sect;
  nb_add_frame = new_nb_space - old_nb_space ;/* Can be negative if deleted */

  if(nb_add_frame > 0)
   {
     glob_frame_obj->frame_obj = _REALLOC(
       glob_frame_obj->frame_obj,(*nb_frame + nb_add_frame),struct frame_obj);
     if(glob_frame_obj->frame_obj == NULL)
      {
	printf("Error, bad dynamic space allocation\n");
	return 0;
      }
   }

  /* Find section where belong the two frames */
  if(!SMFindSection(frame_def_info->sect_info,
		   frame_def_info->nb_sect,
		   begin_sect,end_sect,&num_sect))
   {
     printf("Bad section for the frames \n");
     goto wrapup ; /* return 0; */
   }

  /* Construct new sections */
  if(!SMConsNewSect(frame_def_info->sect_info,new_sect_info,
		    frame_def_info->nb_sect,&new_nb_sect,
		    num_sect,begin_sect,end_sect,new_nb_space))
   {
     printf("Can't update the frame sections\n");
     goto wrapup ; /* return 0; */
   }

  /* Update frames number and eventually create new */
  if(!SMChangeFrNumber(glob_frame_obj->frame_obj,
		       *nb_frame,lowest_frame,highest_frame,
		       begin_sect,end_sect,nb_add_frame,bad_frame))
   {
     printf("Can't update the frame number %d\n",bad_frame);
     goto wrapup ; /* return 0; */
   }
  
  for( i = 0; i <= NB_MAX_SECTION; i++)
    copy_translate_sect(&frame_def_info->sect_info[i],&new_sect_info[i],0);
  frame_def_info->nb_sect = new_nb_sect;
  
  /* From the frame def info structure, recreate the frame structure */
  /* Free the old frame info structure */
  if(*frame != NULL) {_FREE(*frame); *frame = NULL; }
  if(SMSetFrame(frame_def_info, &new_frame_number, frame,
		lowest_frame, highest_frame, bad_frame) != 1)
   {
     printf("Impossible to recreate the frame info structure");
     goto wrapup ; /* return 0; */
   }

  /* Create a new frame def collection */

  if(SMCrtFrmDefCol(frame_def_info, &new_frame_def, 0) != 1)
   {
     printf("Error, cannot update the frame def rg collection\n");
     goto wrapup ; /* return 0; */
   }

  /* create a new frame collection */
        
  if(SMCrtFrmCol(*frame, new_frame_number, *lowest_frame, *highest_frame,
		 &new_frame_info, 0) != 1)
   {
     printf("Error, cannot update the frame info rg collection\n");
     goto wrapup ; /* return 0; */
   }

  /* WARNING : we must add some frame or delete some */
  /* If we add, we return new_frame_number then we can update */
  /* Else we return old nb_frame because in update we must delete some old 
     frame */
  if(new_frame_number > *nb_frame)
    *nb_frame = new_frame_number; 

  /* Recompute frame name */
  for(i=0; i<*nb_frame; i++)
   {
     if(glob_frame_obj->frame_obj[i].status != SAME_FRAME)
       SMRecomputeFrName(&glob_frame_obj->frame_obj[i].frame,
			  frame_def_info->main_info.annot,
			  glob_frame_obj->frame_obj[i].new_frame_number,
			  glob_frame_obj->frame_obj[i].frame_name);
   }

  /* Change roots */
  old_root[0] = glob_frame_obj->frame_def;
  old_root[1] = glob_frame_obj->frame_info;

  new_root[0] = new_frame_def;
  new_root[1] = new_frame_info; 

  for(i=0; i<*nb_frame; i++)
   {
     if((glob_frame_obj->frame_obj[i].status & CRT_FRAME) ||
	(glob_frame_obj->frame_obj[i].status & DEL_FRAME))
       continue;
     
     sts = om$send(msg = message NDnode.NDchange_connect
		   (2,old_root, new_root),
		   senderid = NULL_OBJID,
		   targetid = glob_frame_obj->frame_obj[i].frame.objid,
		   targetos = glob_frame_obj->frame_obj[i].frame.osnum); 

     if(!(sts&1)) 
      {
	printf("Cannot change the frame for the frame: %d\n",
	       glob_frame_obj->frame_obj[i].new_frame_number);
	*bad_frame = glob_frame_obj->frame_obj[i].new_frame_number;
     	goto wrapup ; /* return 0; */
      }
   } 

  glob_frame_obj->frame_def = new_frame_def;
  glob_frame_obj->frame_info = new_frame_info;

  return 1;
	
  wrapup :

  if ( glob_frame_obj->frame_obj ) _FREE (glob_frame_obj->frame_obj);
  return 0;
}



/* Given 2 frame number, find the section number for this frames */
/* return 0 if the 2 frames doesn't belong to the same section else return 1 */

SMFindSection(sect_info,nb_sect,begin_sect,end_sect,num_sect)
struct sect_info sect_info[];  /* [I] the definition of the sections */
IGRint nb_sect;                /* [I] number of defined sections */
IGRint begin_sect;             /* [I] Number of begin frame for the section*/
IGRint end_sect;               /* [I] Number of end frame for the section */
IGRint *num_sect;              /* [O] the section which contains the 2 frames */
{
  int i;

  for(i = 0; i < nb_sect; i++)
   {
     if(sect_info[i].fr <= begin_sect && sect_info[i].to >= end_sect)
      {
	*num_sect = i;
	return 1;
      }
   }
  return 0;
}

/* Modify a section of the frame system */
/* This is the fonction called by the command object */
SMModFrSect(owner,cs, frame_def_obj, frame_obj, frame_def_info,
	    begin_sect,end_sect,new_nb_space,
	    old_dep_grid,new_dep_number,bad_frame)
struct GRid      *owner;                /* Owner of the frame system(I) */
struct GRid	 *cs;			/* Identified of the cs or plane (I)  */
struct GRid	 *frame_def_obj;	/* Identified of the frame def  (I/O) */
struct GRid	 *frame_obj;		/* Identified of the frame info (I/O) */
struct frame_def *frame_def_info;	/* Existing frame def info	(I)   */
IGRint begin_sect;             /* [I] Begin frame for the section to modify*/
IGRint end_sect;               /* [I] End frame for the section to modify*/
IGRint new_nb_space;           /* [I] New Number of space in the section */
struct GRid *old_dep_grid;     /* [I] Frame GRid where mve depandancy from  */
IGRint *new_dep_number;        /* [I] Frame number where move depandancy to */
IGRint *bad_frame;             /* [O] If fail, bad frame number */
{
  int 	lowest_frame, highest_frame;
  int	nb_frame;
  struct	glob_frame_obj glob_frame_obj;
  IGRint old_nb_frame,nb_add_frame;
  struct frame  *frame;
  int 	return_code;

 *bad_frame = 0;
 glob_frame_obj.frame_obj = NULL;
 frame = NULL;

 old_nb_frame = end_sect - begin_sect + 1;
 nb_add_frame = new_nb_space - old_nb_frame +1;/* Can be negative if deleted */

 if(SMSetFrame(frame_def_info, &nb_frame, &frame, &lowest_frame, 
 	       &highest_frame, bad_frame) != 1)
   {
    printf("Cannot retrieve the existing frame structure\n");
    goto wrapup;
   }

 if(SMGetFrmSyst(owner,cs, frame_def_obj, frame_obj,
		  nb_frame, &glob_frame_obj) != 1)
  {
   printf("Error, cannot retrieve the frame system objects\n");
   goto wrapup;
  }
 
 /* Add to the frame system structure */
 if(!SMModFrmSect(frame_def_info, &nb_frame, &frame, &lowest_frame, 
 	         &highest_frame, begin_sect,end_sect,new_nb_space,bad_frame, 
		 &glob_frame_obj))
   {
    printf("Cannot compute the frame objects\n");
    goto wrapup;
   }

 if(nb_add_frame < 0) /* Move depandancy before the delete of some frame */
   if(!SMMoveFrSystDepandancy(owner,old_dep_grid,new_dep_number,old_nb_frame))
    goto wrapup;

  /* Erase all the frame before updtaing parameters */
  SMEraseFrame(&glob_frame_obj,nb_frame); 

  if(!SMUpdFrame(owner,cs,nb_frame,frame,&glob_frame_obj,FALSE,bad_frame))
   {
     printf("Cannot update the frame system\n");
     goto wrapup;
   }
  
  if(nb_add_frame > 0)  /* Move depandancy after some frame have been add */
    if(!SMMoveFrSystDepandancy(owner,old_dep_grid,new_dep_number,old_nb_frame))
      goto wrapup;

  /* Exec batch and resdisplay the modified frame */
  SMFrExBatch(&glob_frame_obj,nb_frame);

  *frame_def_obj = glob_frame_obj.frame_def;
  *frame_obj     = glob_frame_obj.frame_info;

  return_code = 1; 
  goto cleanall;

 wrapup:
  return_code = 0;

 cleanall:
  /* Free the frame_obj structure */
  _FREE(glob_frame_obj.frame_obj);
  if(nb_frame != 0 && frame != NULL) _FREE(frame);
  
 return return_code;
}


/* Move the depancy of the old frame system to the new frame system */
/* Be careful to call this fonction when the two frame system exits */

int SMMoveFrSystDepandancy(owner,old_grid,new_number,nb_to_move)
struct GRid *owner;         /* [I] GRid of the frame system */
struct GRid *old_grid;      /* [I] Grid of the old frame system */
IGRint *new_number;         /* [I] Corresponding new number of frame */ 
IGRint nb_to_move;          /* [I] Number of frames to move depandancy */  
{
  IGRint i;
  struct GRid *new_grid = NULL;
  IGRlong status,msg;
  struct GRmd_env mod_env;
  IGRlong sizebuf, nret;
  IGRint *nb_to_change; /* For each frame number of object in depandance */ 
  struct GRid **obj_to_change; /* For each frame, objects in depandance */ 
  int return_code;

  nb_to_change = NULL;
  obj_to_change = NULL;

  obj_to_change =
    _CALLOC(nb_to_move,struct GRid *);
  nb_to_change = 
     _CALLOC(nb_to_move,IGRint);
  new_grid = 
     _MALLOC(nb_to_move,struct GRid);
  
  if(new_grid == NULL || obj_to_change == NULL || nb_to_change == NULL)
   { printf("Not enough memory\n"); goto wrapup;}

 
  /* Find objid of the new frame */
  for(i = 0; i < nb_to_move; i++)
   {
     if(IF_NULL_OBJID(old_grid[i].objid))
	continue;  /* No interest with depandancy of this obj */
     status = om$send(msg = message SMfrm_syst.SMfind_frame_objid
		   (&msg,new_number[i],&new_grid[i]),
		   senderid = NULL_OBJID,
		   targetid = owner->objid,
		   targetos = owner->osnum);
     if(!(status & msg & 1))
      {
	printf("Erreur finding frame objid for frame number %d\n",
	       new_number[i]);
	goto wrapup;
      }
   }

  sizebuf = sizeof(struct GRmd_env);
  status = gr$get_module_env(msg     = &msg,
			     sizbuf  = &sizebuf,
			     buffer  = &mod_env,
			     nret    = &nret);
  
  if(!(status & msg &1)) return 0;

  /* Retreive depandancy for all the frame */
  for(i = 0; i < nb_to_move; i++)
   {
     if(IF_NULL_OBJID(old_grid[i].objid) ||
	IF_EQ_OBJID(old_grid[i].objid,new_grid[i].objid))
       continue;
     if(!SMFindFrDepandancy(&old_grid[i],NULL,
			    &obj_to_change[i],&nb_to_change[i],&mod_env))
      {
	printf("Error find depandancy frame %d \n", old_grid[i].objid);
	goto wrapup;
      }
   }

  for(i = 0; i < nb_to_move; i++)
   {
     if(IF_NULL_OBJID(old_grid[i].objid) ||
	IF_EQ_OBJID(old_grid[i].objid,new_grid[i].objid))
       continue;
     if(!VDMoveFrDepandancy(&new_grid[i],(struct GRmd_env *)NULL,
			    &old_grid[i],obj_to_change[i],nb_to_change[i],
			    &mod_env))
      {
	printf("Error move depandancy from frame %d to frame %d\n",
	       old_grid[i].objid,new_grid[i].objid);
      }
   }
  return_code = 1;
  goto freeall;

 wrapup:
  return_code = 0;
  
 freeall:
  if(obj_to_change != NULL)
   {
     for(i = 0 ; i < nb_to_move; i++)
       if(obj_to_change[i] != NULL)
	   _FREE(obj_to_change[i]);
     _FREE(obj_to_change);
   }
  if(nb_to_change != NULL)
   _FREE(nb_to_change);
  return return_code;  
}
  
/* Find all the objects who depands from a frame */
/* The obj_to_change ptr is allocated by the function (if not NULL!) */
/* and must be deallocated by caller*/

int SMFindFrDepandancy(frame,fr_mod_env,obj_to_change,nb_to_change,cur_mod_env)  
struct GRid     *frame;          /* [I] The frame to retrieve depandancy */
struct GRmd_env *fr_mod_env;     /* [I] Mod env of the frame */
struct GRid     **obj_to_change; /* [O] Array who contains depandancy */
IGRint *nb_to_change;		 /* [O] Number of element find in depandance */
struct GRmd_env *cur_mod_env;    /* [I] Current md_env(to not always recompute)*/
{
 IGRint i_to_change;
 IGRlong        status;         /* routine return status */
 struct GRid    *buffer;

 if(IF_NULL_OBJID(frame->objid)) /* Nothing more to do */
   {
     printf("frame = NULL_OBJID\n");
     return 0;
   }

 if(obj_to_change != NULL) *obj_to_change = NULL;
 *nb_to_change  = 0;
  
 status = as$make_source(go_grid = *frame,
			 mod_env = fr_mod_env,
			 as_os = cur_mod_env->md_id.osnum, 
			 as_grid = frame );
 as$status(action = RET_STATUS); 
 
 if(IF_NULL_OBJID(frame->objid))
  {
    printf("Error retrieving frame \n");
    return 0;
  }

 status=om$send(msg=message NDnode.NDget_objects
		(ND_CHILDREN|ND_IN_BUF,
		 NULL,0,&buffer,0,OM_K_MAXINT,
		 nb_to_change),
		senderid = NULL_OBJID,
		targetid = frame->objid,
		targetos = frame->osnum);
 if(status != OM_S_SUCCESS) 
  {
    printf("Erreur NDget_objects frame %d\n",frame->objid);
    return 0;
  }

 if(*nb_to_change > 0)
  {
    if(obj_to_change != NULL)
     {
       *obj_to_change
	 = _MALLOC( *nb_to_change,struct GRid);
       if(*obj_to_change == NULL)
	{ printf("No more memory\n"); return(0);}
       for(i_to_change = 0; i_to_change < *nb_to_change; i_to_change++)
	 (*obj_to_change)[i_to_change] = buffer[i_to_change];
     }
  }
 else
  {
    *nb_to_change = 0;
    return 1;  /* No depandancy */
  }

#ifdef DEBUG
 printf("Number of depandancy of frame %d = %d\n",frame->objid,*nb_to_change);
 if(obj_to_change != NULL)
   for(i=0;i<*nb_to_change;i++)
     printf("Objid = %d \n", (*obj_to_change)[i].objid);
#endif

 return 1;
}


end implementation Root;
