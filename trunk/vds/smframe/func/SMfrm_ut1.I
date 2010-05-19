/* $Id: SMfrm_ut1.I,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */
 
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/smframe/func / SMfrm_ut1.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SMfrm_ut1.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:35  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1998/02/09  16:01:52  pinnacle
# Replaced: smframe/func/SMfrm_ut1.I for:  by azuurhou for vds
#
# Revision 1.3  1997/12/02  09:33:52  pinnacle
# Replaced: smframe/func/SMfrm_ut1.I for:  by ksundar for vds
#
# Revision 1.2  1997/06/23  06:15:14  pinnacle
# Replaced: smframe/func/SMfrm_ut1.I for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1996/05/13  16:05:28  pinnacle
# Replaced: smframe/func/SMfrm_ut[12].I for:  by jwfrosch for vds.240
#
# Revision 1.4  1996/05/10  18:58:38  pinnacle
# Replaced: ./smframe/func/SMfrm_ut1.I for:  by azuurhou for vds.240
#
# Revision 1.3  1996/04/17  14:32:44  pinnacle
# Replaced: smframe/cmd/SMModNotif.I for:  by ksundar for vds.240
#
# Revision 1.2  1995/11/21  22:28:08  pinnacle
# Replaced: smframe/func/SMfrm_ut1.I for:  by azuurhou for vds.240
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
 *	06/19/97	Sundar		Modified the functions SMCompFrame
 *					& SMUpdFrame for CR:179528227	
 *	12/02/97	Sundar		Modified for the CR:179309743.
 * -------------------------------------------------------------------*/

/*
	
File SMfrm_ut1.I

Abstract : 
  

	Implemented functions used for the frame system.

	- Design date: 20-Oct-1991.

	- Christian Heraud ISDC.
*/

class implementation Root;

#include <stdio.h>
#include "OMmacros.h"
#include "exmacros.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "godef.h"
#include "igr.h"
#include "igetypedef.h"
#include "gr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "macro.h"
#include "parametric.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "expression.h"
#include "expmacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "EMSssprops.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "growner.h"
#include "SMdef.h"
#include "SMframe.h"
#include "VDmem.h"
#include "v_dbgmacros.h"


#include "AS_status.h"

/*#define DEBUG */

#define EPSILON 0.00001

from NDnode 		import NDchg_state, NDs_compute_node, NDget_objects;
from NDnode		import NDdisplay, NDchange_connect;
from expression         import NDgive_value;
from ci_macro		import init;
from GRvg		import GRchglevel, GRchgname, GRgetname, GRgetsymb,
                               GRputsymb;
from GRgraphics		import GRchgprops;
from SMfrm_syst         import  ACcreate,
                                ACadd_component_with_name,
                                GRcomponent_disconnecting,
                                SMchange_component_name,
                                SMremove_component,
 				GRdelete_owner,
 			        SMdisplay_all_frame;

from NDmacro import ACreturn_foot;
from SMmgr   import SMGetState,SMChgState;

extern GRclassid OPP_ACrg_collect_class_id, OPP_SMframe_class_id;
extern GRclassid OPP_SMfrm_syst_class_id;

/*
/*  SMCrtUniFrm()
/*  Create a single frame */
/*
/*   Return 1 if OK; 0 if big failure and 2 if warning 
/* */
static int SMCrtUniFrm(frame_info,owner,cs,frame_def_col,frame_col,mod_env,
		       fr_symb,new_frame)
struct frame	 *frame_info;    /* frame info of the new frame     (I) */
struct GRid      *owner;         /* The SMfrm_syst for frame system (I) */
struct GRid	 *cs        ;    /* Identified of the cs    (I) */
struct GRid      *frame_def_col; /* Identified of frame_def (I) */       
struct GRid      *frame_col;     /* Identified of frame_col (I) */
struct GRmd_env  *mod_env;       /* The module env          (I) */
struct GRsymbology *fr_symb;     /* The symbology of frame system (I) */
struct GRid      *new_frame;     /* The new created frame   (O) */    
{
  IGRlong 	 sts, msg,status;
  struct GRid     exp; 
  struct GRid	 mac;
  struct GRid     list[4];
  IGRshort layer;
  
  list[0] = *cs;
  list[2] = *frame_def_col;
  list[3] = *frame_col;
  
  
  /* create the expression of the frame number */
  exp.osnum = mod_env->md_id.osnum;
  exp$create(exp_name  = NULL,
	     exp_value = (double) frame_info->number,
	     p_exp_id  = &exp.objid,
	     osnum     = exp.osnum);
  
  sts = om$send(msg = message NDnode.NDchg_state(ND_DEL_NO_CH | ND_WAIT_DEL,
						 ND_DEL_NO_CH | ND_WAIT_DEL),
		senderid = NULL_OBJID,
		targetid = exp.objid,
		targetos = exp.osnum );
  if(!(sts&1)) { printf("Warning, expression not in ND_DEL_NO_CH state\n"); }
  list[1] = exp;
  
  /* create the frame */
  mac.osnum = mod_env->md_id.osnum;
  sts = om$construct( classid = OPP_SMframe_class_id,
		     osnum   = mac.osnum,
		     p_objid = &mac.objid );
  if(!(sts&1)) return 0;
  
  sts = om$send(msg = message ci_macro.init((IGRint *)&msg,AChdr_nodisplay,
					    "SMFrPln", 4, list, NULL, mod_env),
		senderid = NULL_OBJID,
		targetid = mac.objid,
		targetos = mac.osnum);
  if(!(sts & msg &1)) return 0;
  
  /* Add component to SMfrm_syst */
  if(owner != NULL)
   {  
     status = om$send(msg = message SMfrm_syst.ACadd_component_with_name
		      (&msg,&mac,frame_info->name),
		      senderid = NULL_OBJID,
		      targetid = owner->objid,
		      targetos = owner->osnum);  
     
     if(!(status & 1) || (msg != MSSUCC))
      {
	printf("error ACadd_component for frame name %s\n",frame_info->name);
	return 0;
      }
   }

  if(new_frame != NULL) 
   {
     new_frame->objid = mac.objid;
     new_frame->osnum = mac.osnum;
   }


  om$send(msg = message GRvg.GRputsymb(&msg, fr_symb),
	  senderid = NULL_OBJID,
	  targetid = mac.objid,
	  targetos = mac.osnum);
  /* We doesnt't test the return status because the expression in the macro */
  /* send a bad return */

  layer = fr_symb->level + frame_info->offset_layer;
  sts = om$send(msg = message GRvg.GRchglevel(&msg, &layer),
		senderid = NULL_OBJID,
		targetid = mac.objid,
		targetos = mac.osnum);
  if(!(sts&msg&1)) 
   { 
     printf("Cannot modify the level of frame : %d\n",frame_info->number);
     return 2;
   }
  return 1;
}


/*
/* SMCreateFrame
/*
/*  Given the frame, frame definition info, the lowest and highest frame
/*  create the ppl_macro and each separated frames.
/*
/*  It also dealloc the frame.
/*
/* */
SMCreateFrame(fr_syst_name,cs, frame_def_info, nb_frame, frame_info,
	      lowest_frame, highest_frame,owner,bad_frame)
char   		 *fr_syst_name;          /* The name of the frame systeme (I) */
struct GRid	 *cs;			/* Identified of the cs (I) */
struct frame_def *frame_def_info;	/* frame def info	(I) */
int		  nb_frame;		/* number of frames	(I) */
struct frame	 *frame_info;		/* frame info		(I) */
int		  lowest_frame, highest_frame; /*               (I) */
struct GRid      *owner; /* The SMfrm_syst created (if NULL doesnt' create) [O]*/
int		 *bad_frame;       /* Frame number where it fails  (O) */ 
{
 struct GRid	 frame_def_col, frame_col;
 int 		 i;
 struct GRmd_env mod_env;
 IGRlong         msg,status;
 struct GRsymbology fr_symb;
 struct IGRdisplay act_display;
 IGRshort        act_layer;
 IGRlong 	 sizebuf, nret;

 *bad_frame	= 0;
 sizebuf = sizeof(struct GRmd_env);
 gr$get_module_env(   msg     = &msg,
                      sizbuf  = &sizebuf,
                      buffer  = &mod_env,
                      nret    = &nret);

 if(SMCrtFrmDefCol(frame_def_info, &frame_def_col, 0) != 1) 
  {
   printf("Error in creating the rg collection for the frame definition\n");
   return 0;
  }

 if(SMCrtFrmCol(frame_info, nb_frame, lowest_frame, highest_frame, &frame_col, 0) != 1) 
  {
   printf("Error in creating the rg collection for the frame \n");
   return 0;
  }

 if(owner != NULL)
  {
    owner->osnum =  mod_env.md_id.osnum;

    status = om$construct(msg = message SMfrm_syst.ACcreate
			  (&msg,fr_syst_name),
			  classid = OPP_SMfrm_syst_class_id,
			  osnum = owner->osnum,
			  p_objid = &owner->objid);
    if(!(status & 1) || (msg != MSSUCC)) 
     {
       printf("Can't create SMfrm_syst\n");
       return 0;
     }
  }

 /* Get active symbology */
 sizebuf = sizeof(IGRshort);
 gr$get_active_level(msg=&msg,sizbuf=&sizebuf,buffer = &act_layer,nret = &nret);

 sizebuf = sizeof(struct IGRdisplay);
 gr$get_active_display(msg=&msg,sizbuf=&sizebuf,buffer=&act_display,nret=&nret);
		    
 fr_symb.level        = act_layer;
 fr_symb.display_attr = act_display;

 for(i=0;i<nb_frame;i++)
  {
    if(!SMCrtUniFrm(&frame_info[i],owner,cs,&frame_def_col,
		    &frame_col,&mod_env,&fr_symb,(struct GRid *)NULL))
     {
       printf("Bad placement (index: %d) for the frame number: %d\n",
	      *bad_frame = frame_info[i].number);
       if(nb_frame != 0) _FREE(frame_info);
       return 0;
     }
  }

 status = om$send(msg = message SMfrm_syst.SMdisplay_all_frame(&msg,GRbd,NULL),
		  senderid = NULL_OBJID,
		  targetid = owner->objid,
		  targetos = owner->osnum);
 if(!(status & msg & 1)) 
   printf("Warning, cannot display the frame system\n");
 
 /* Dealloc the frame info */
 if(nb_frame != 0) _FREE(frame_info);

 return 1;
}



/*
/* SMCompFrame:
/*
/*  Verify and set default values
/*
/*  If fail the bad_framenumber is the frame number where the error has been 
/*  found.
/*
/*  Return 1 if success else 0;
/*
/* */

SMCompFrame(frame, nb_frame, frame_def_info, lowest_frame, highest_frame, bad_frame_number)
struct frame 	  *frame;	 /* Frame info			 (I/O) */
int	      	   nb_frame;     /* Number of frame defined 	 (I)   */
struct frame_def  *frame_def_info;	 /* Main frame info		 (I)   */ 
int		  *lowest_frame;    /* Lowest frame number	 (O)   */
int		  *highest_frame;   /* highest frame number	 (O)   */
int		  *bad_frame_number; /* If fail the corresponding 
					frame number		 (O)   */
{
	int 		i, ref_frame,
			frame_index;
	double		old_pos;
  
	SetProc( SMCompFrame ); Begin

	/* SUNDAR for CR:179528227
	*lowest_frame  = 0;
	*highest_frame = 0;
	*/

	*lowest_frame  = frame[0].number;
	*highest_frame = frame[0].number;
  
	/* for( i=0 ; i<nb_frame ; i++ ){	SUNDAR for  CR:179528227 */
	for( i=1 ; i<nb_frame ; i++ ){
	  if(frame[i].number < *lowest_frame)  *lowest_frame  = frame[i].number;
	  if(frame[i].number > *highest_frame) *highest_frame = frame[i].number;
	}
  
	__DBGpr_com(" Verification of the number of frames ");
	if( *highest_frame - *lowest_frame != nb_frame - 1){
	  printf("Some intermediate frames have not been defined\n");
	  *bad_frame_number = *highest_frame;
	  return 0;
	}
  
	__DBGpr_com(" Set the frame 0 ");
	/* Commented for CR:179528227 by SUNDAR
	if( SMIsFrameDef( frame, nb_frame, 0, &frame_index) != 1 ){

	  printf("The reference frame number 0 has not been defined\n");
	  *bad_frame_number = 0;
	  return 0;
	}
	*/
	
	/* Added for CR:179528227 by SUNDAR */
	if ( *lowest_frame <= 0 && *highest_frame >= 0)
		ref_frame=0;
	else
		ref_frame=*lowest_frame;

	if( SMIsFrameDef( frame, nb_frame, ref_frame, &frame_index) != 1 ){
		printf("The reference frame number %d has not been defined\n",
			ref_frame);
		*bad_frame_number = ref_frame;
		return 0;
	}

	/* for 179309743 by Sundar
	sprintf(frame[frame_index].name,"%s%d", frame_def_info->main_info.annot,
						frame[frame_index].number );
	*/
	if ( !SMSetFrmName( frame_def_info->nm_sect_info, 
			frame_def_info->nb_nm_sect,
			frame_def_info->main_info.offset_dist,
			frame[frame_index].number,
			frame_def_info->main_info.unit,
			frame_def_info->main_info.name_type,
			frame_def_info->main_info.annot,
			frame[frame_index].name)){
		sprintf(frame[frame_index].name,"%s%d",
				frame_def_info->main_info.annot,
				frame[frame_index].number );
	}

	/*
	printf ("name[%d]=%s\n", frame_index, frame[frame_index].name);
	printf ("rel_pos[%d]=%f\n", frame_index, frame[frame_index].rel_pos);
	printf ("abs_pos[%d]=%f\n", frame_index, frame[frame_index].abs_pos);
	*/

	frame[frame_index].abs_pos = frame_def_info->main_info.offset_dist;
	old_pos = frame[frame_index].abs_pos;
  
   /* Set the positive frames */
   /* for(i=1;i<=*highest_frame;i++) SUNDAR for CR:179528227 */
   for(i=ref_frame+1;i<=*highest_frame;i++)
   {
      if(SMIsFrameDef(frame, nb_frame, i, &frame_index) != 1)
      {
	printf("The frame number: %d has not been defined\n", i);
	*bad_frame_number = i;
	return 0;
      }
      /* Set the frame name */
      /* for 179309743 by Sundar
      sprintf(frame[frame_index].name,"%s%d",
	     frame_def_info->main_info.annot,frame[frame_index].number);
      */
	if (!SMSetFrmName( frame_def_info->nm_sect_info, 
                        frame_def_info->nb_nm_sect,
                        old_pos + frame[frame_index].rel_pos,
                        frame[frame_index].number,
                        frame_def_info->main_info.unit,
                        frame_def_info->main_info.name_type,
                        frame_def_info->main_info.annot,
                        frame[frame_index].name)){
		sprintf(frame[frame_index].name,"%s%d",
                                frame_def_info->main_info.annot,
                                frame[frame_index].number );
	}
	/*
	printf ("name[%d]=%s\n", frame_index, frame[frame_index].name);
	printf ("rel_pos[%d]=%f\n", frame_index, frame[frame_index].rel_pos);
        printf ("abs_pos[%d]=%f\n", frame_index, frame[frame_index].abs_pos);
	*/

      /* Set the absolute position */
      frame[frame_index].abs_pos = old_pos + frame[frame_index].rel_pos;
      old_pos = frame[frame_index].abs_pos;
   }  
  
   /* Set the negative frames */
   old_pos = frame_def_info->main_info.offset_dist;
   /* for(i=-1;i>=*lowest_frame;i--)	SUNDAR for CR:179528227 */
   for(i=(*highest_frame < -1) ? *highest_frame : -1;i>=*lowest_frame;i--)
   {
      if(SMIsFrameDef(frame, nb_frame, i, &frame_index) != 1)
      {
 	 printf("The frame number: %d has not been defined\n", i);
	 *bad_frame_number = i;
	 return 0;
      }
      /* Set the frame name */
      /*
      sprintf(frame[frame_index].name,"%s%d",
	     frame_def_info->main_info.annot,frame[frame_index].number);
      */
	if (!SMSetFrmName( frame_def_info->nm_sect_info, 
                        frame_def_info->nb_nm_sect,
                        old_pos - frame[frame_index].rel_pos,
                        frame[frame_index].number,
                        frame_def_info->main_info.unit,
                        frame_def_info->main_info.name_type,
                        frame_def_info->main_info.annot,
                        frame[frame_index].name)){
		sprintf(frame[frame_index].name,"%s%d",
                                frame_def_info->main_info.annot,
                                frame[frame_index].number );
	}

	/*
	printf ("name[%d]=%s\n", frame_index, frame[frame_index].name);
	printf ("rel_pos[%d]=%f\n", frame_index, frame[frame_index].rel_pos);
        printf ("abs_pos[%d]=%f\n", frame_index, frame[frame_index].abs_pos);
	*/

      /* Set the absolute position */
      frame[frame_index].abs_pos = old_pos - frame[frame_index].rel_pos;
      old_pos = frame[frame_index].abs_pos;
   }  
  
#ifdef vdsDEBUG
  printf("\t\t Frame parameters \n");
  printf("axis: %c, orient: %c, justif: %s, annot: %s\n",frame_def_info->main_info.axis,
	 frame_def_info->main_info.orient ,frame_def_info->main_info.justif ,frame_def_info->main_info.annot);
  printf("rev_dist: %lf, plane_size: %lf, reinf_plane: %lf, offset: %lf\n",
	 frame_def_info->main_info.rev_dist, frame_def_info->main_info.plane_size ,
	 frame_def_info->main_info.reinf_size ,frame_def_info->main_info.offset_dist);
  printf("\n");
  printf("number	name \trel_pos  \tabs_pos \toffset \treinf \treverse\n");
  for(i=0;i<nb_frame;i++)
  {
   printf(" %d,\t%s,\t%lf,\t%lf,\t%d,\t%d\t%d\n",frame[i].number,frame[i].name,
	    frame[i].rel_pos,frame[i].abs_pos,frame[i].offset_layer,
	    frame[i].reinf,frame[i].reverse);
  }
#endif

  return 1;
}

 /* SMUpdFrame */
 /* Update the frames */

SMUpdFrame(owner,cs,nb_frame, frame,glob_frame_obj,execute_batch,bad_frame)
struct GRid      *owner;                /* Owner of the frame system(I/O) */
struct GRid	 *cs;			/* Identified of the cs     (I) */
IGRint		  nb_frame;		/* Number of frames	    (I) */
struct frame     *frame;		/* Frame structure	    (I) */
struct glob_frame_obj *glob_frame_obj;	/* Global struct info	    (I) */
IGRboolean       execute_batch;         /* If true, we can execute batch (I) */ 
IGRint		 *bad_frame;		/* If fail, bad frame number(O) */
{
  IGRint 	 i, cn_type, sts, wait_batch, low_frm;
  IGRlong	 msg;
  IGRchar 	 exp[80];
  struct GRmd_env mod_env;
  IGRlong 	 sizebuf, nret;
  IGRshort act_layer;
  int fr_index;
  struct GRsymbology fr_symb;
  struct IGRdisplay act_display;
  IGRshort state = ~0, old_state = ~0;
  extern IGRboolean ASbroadcast_in_progress;
  IGRboolean save_broadcast;

  SetProc( SMUpdFrame ); Begin 

  sizebuf = sizeof(struct GRmd_env);
  gr$get_module_env(msg     = &msg,
		    sizbuf  = &sizebuf,
		    buffer  = &mod_env,
		    nret    = &nret);
  
  *bad_frame = 0;
  wait_batch = 0;

	/*
	for (i=0; i<nb_frame; i++){
		if (strcmp(glob_frame_obj->frame_obj[i].frame_name,
				frame[i].name) ){
			strcpy(glob_frame_obj->frame_obj[i].frame_name,
                                frame[i].name);
			glob_frame_obj->frame_obj[i].status |= NAME_FRAME;
			glob_frame_obj->frame_obj[i].status |= DISP_FRAME;
			glob_frame_obj->frame_obj[i].status |= MOD_FRAME;
		}
	}
	*/

		
  /* Get the active symbology of the frame 0. For the layer, substract offset */
 /* of frame 0 to have current system layer when frame system was created */
  /* Added by SUNDAR for CR:179528227 */
  low_frm = frame[0].number;
  for (i=1; i<nb_frame; i++)
  	if ( frame[i].number < low_frm )
		low_frm=frame[i].number;

 /* Changed 0 -> low_frm  by SUNDAR for CR:179528227 */
 if(SMIsFrameSyst(glob_frame_obj->frame_obj, nb_frame, low_frm,&fr_index) != 1) 
  { printf("problem with index of frame 0/lowest\n"); return 0;}
  sts = om$send(msg = message GRvg.GRgetsymb(&msg, &fr_symb),
		senderid = NULL_OBJID,
		targetid = glob_frame_obj->frame_obj[fr_index].frame.objid,
		targetos = glob_frame_obj->frame_obj[fr_index].frame.osnum);
  if(!(sts & msg & 1))
   {
     printf("Warning, can't get symbology of frame 0\n");
     printf("Frame will be update with current symbology\n");
     sizebuf = sizeof(IGRshort);
     gr$get_active_level(msg=&msg,sizbuf=&sizebuf,
			 buffer = &act_layer,nret = &nret);
     sizebuf = sizeof(struct IGRdisplay);
     gr$get_active_display(msg=&msg,sizbuf=&sizebuf,
			   buffer=&act_display,nret=&nret);
     fr_symb.level        = act_layer;
     fr_symb.display_attr = act_display;
   }
  else
   {
     /* Changed 0 -> low_frm  by SUNDAR for CR:179528227 */
     if(!SMIsFrameDef(frame, nb_frame, low_frm, &fr_index))
      {printf("problem with index of frame 0/lowest\n"); return 0;}
     fr_symb.level -= frame[fr_index].offset_layer;
   }

  /* First erase all deleted and modified frame */
  if(execute_batch) SMEraseFrame(glob_frame_obj,nb_frame);

  __DBGpr_int(" #FRAMES ", nb_frame );

  for(i=0;i<nb_frame;i++)
  {
     if(glob_frame_obj->frame_obj[i].status == SAME_FRAME) continue;
     else if(glob_frame_obj->frame_obj[i].status & CRT_FRAME)
      {
	/* A new frame has to be created */
	
	/* search the index */
	if(SMIsFrameDef(frame, nb_frame, glob_frame_obj->frame_obj[i].new_frame_number, &fr_index) != 1)
	 {
	   printf("Search index not found\n");
	   *bad_frame = glob_frame_obj->frame_obj[i].new_frame_number;
	   return 0;
	 }
	
	msg = SMCrtUniFrm(&frame[fr_index],
			  owner,
			  cs,
			  &glob_frame_obj->frame_def,
			  &glob_frame_obj->frame_info,
			  &mod_env,
			  &fr_symb,
			  &glob_frame_obj->frame_obj[i].frame);
	switch(msg)
	 {
	 case 0 : printf("Error creating frame %d\n",i); return 0;
	 case 1 : break;
	 case 2 : printf("Warning creating frame %d\n",i); break; 
	 }
	state = SM_MOD;
     }
     else if(glob_frame_obj->frame_obj[i].status & DEL_FRAME)
     {
	/* A frame has to be deleted */
        sts = om$send(msg = message SMfrm_syst.SMremove_component
		      (&msg, &glob_frame_obj->frame_obj[i].frame),
			 senderid = NULL_OBJID,
			 targetid = owner->objid,
			 targetos = owner->osnum);
	as$status(sts = sts);
	if(!(sts & msg & 1))
	 {
	   *bad_frame = glob_frame_obj->frame_obj[i].new_frame_number;
	   return 0;
	 }

	state = SM_MOD;
	wait_batch = 1;
	cn_type    = 1; /* recompute the object */
	sts = nd$wait_batch(type       = GR_DELETED,
			    l_object   = &glob_frame_obj->frame_obj[i].frame,
			    l_obj_info = &cn_type,
			    nb_obj     = 1);
	if(!(sts&1))
	 {
	   *bad_frame = glob_frame_obj->frame_obj[i].new_frame_number;
	   return 0;
	 }
      }
     else if(glob_frame_obj->frame_obj[i].status & MOD_FRAME)
      {
	/* Change the expression for number if needed  */
	if(glob_frame_obj->frame_obj[i].new_frame_number != 
	   glob_frame_obj->frame_obj[i].old_frame_number)
	 {
	   /* Change the expression and put it in a wait_batch list */
	   save_broadcast = ASbroadcast_in_progress;
	   ASbroadcast_in_progress = TRUE;

	   sprintf(exp,"%d",glob_frame_obj->frame_obj[i].new_frame_number);
	   sts = exp$modify(exp_id=glob_frame_obj->frame_obj[i].expression.objid,
			    osnum=glob_frame_obj->frame_obj[i].expression.osnum, 
			    exp_syntax = exp);
	   ASbroadcast_in_progress = save_broadcast;
	   if(!(sts&1))
	    {
	      printf("Cannot update the expression for the frame number: %d\n",
	    		glob_frame_obj->frame_obj[i].new_frame_number);
	      *bad_frame = glob_frame_obj->frame_obj[i].new_frame_number;
	      
	      return 0;
	    }
	 } 
	if(glob_frame_obj->frame_obj[i].status & COMP_FRAME)
	 {
	   state = SM_MOD;
	   wait_batch = 1;
	   cn_type    = 1; /* recompute the object */
	   sts = nd$wait_batch(type = GR_GEOM_POSTED,
			       l_object   = &glob_frame_obj->frame_obj[i].frame,
			       l_obj_info = &cn_type,
			       nb_obj     = 1);
	   if(!(sts&1))
	    {
	      *bad_frame = glob_frame_obj->frame_obj[i].new_frame_number;
	      return 0;
	    }
	 }
	else if(glob_frame_obj->frame_obj[i].status & DISP_FRAME)
	 {
	   /* It is a change of the display parameters  */
	   sts = om$send(msg = message NDnode.NDs_compute_node(&msg, 0, NULL),
			 senderid = NULL_OBJID,
			 targetid = glob_frame_obj->frame_obj[i].frame.objid,
			 targetos = glob_frame_obj->frame_obj[i].frame.osnum);
	   if(!(sts & msg &1))
	    {
	      printf("Error Updating the frame number: %d\n",
		     glob_frame_obj->frame_obj[i].new_frame_number);
	      *bad_frame = glob_frame_obj->frame_obj[i].new_frame_number;
	      return 0;
	    }
	 }
      }
         
     if((glob_frame_obj->frame_obj[i].status & NAME_FRAME) && owner != NULL)
      {
	sts = om$send(msg = message SMfrm_syst.SMchange_component_name
		      (&msg,
		       &glob_frame_obj->frame_obj[i].frame,
		       glob_frame_obj->frame_obj[i].frame_name),
		      senderid = NULL_OBJID,
		      targetid = owner->objid,
		      targetos = owner->osnum);
	if(!(sts & msg & 1))
	  printf("Erreur change name of %s\n",glob_frame_obj->frame_obj[i].frame_name);
      }
   }

  /* Modify the state */
  sts = om$send(msg = message SMmgr.SMGetState(&old_state),
		   senderid = NULL_OBJID,
		   targetid = owner->objid,
		   targetos = owner->osnum);
  if(!(sts & 1)) 
   {
     printf("Can't get the state of frame system\n");
     return 0;
   }
 
  state = old_state | state;

  sts = om$send(msg = message SMmgr.SMChgState(SM_STATE,state),
		senderid = NULL_OBJID,
		targetid = owner->objid,
		targetos = owner->osnum);
  if(!(sts & 1)) 
   {
     printf("Can't change the state of frame system\n");
     return 0;
   }


  if(execute_batch) SMFrExBatch(glob_frame_obj,nb_frame);
 
  return 1;
}



/*
/* SMGetFrmSyst
/*
/* Given a frame object, retrieve the roots.
/*
/* Alloc the struct "frame_obj" of glob_frame_obj. This must be deallocated
/* by the user.
/*
/* */ 

SMGetFrmSyst(owner,cs, frame_def_obj, frame_obj, nb_frame, glob_frame_obj)
struct GRid		*owner,*cs, *frame_def_obj, *frame_obj	;
IGRint			 nb_frame;
struct glob_frame_obj 	*glob_frame_obj;
{
	struct GRid 	*buff=NULL;
	IGRint		i, count;
	IGRlong		sts;
	IGRdouble	fr_number;
	
	SetProc( SMGetFrmSyst ); Begin

	if( ! nb_frame ) return 0 ;

	glob_frame_obj->frame_obj = NULL;
	glob_frame_obj->frame_obj = _MALLOC(nb_frame,struct frame_obj);
	if( glob_frame_obj->frame_obj == NULL ){
	  printf("Error, bad dynamic space allocation\n");
	  return 0;
	}

	/* Get all the frame obj */
	glob_frame_obj->cs         = *cs;
	glob_frame_obj->frame_def  = *frame_def_obj;
	glob_frame_obj->frame_info = *frame_obj;

	sts =
	om$send(msg = message NDnode.NDget_objects(ND_CHILDREN|ND_IN_BUF, NULL,
 			 	0, &buff, 0, OM_K_MAXINT, &count),
 		senderid = NULL_OBJID,
		targetid = glob_frame_obj->frame_info.objid,
		targetos = glob_frame_obj->frame_info.osnum);
	if(!(sts&1)){
	  printf("Error, cannot get the roots\n");
	  goto wrapup ; /* return 0; */
	}

	__DBGpr_int(" Count ", count );
	if(count != nb_frame){
	  printf("Error count: %d must be: %d\n", count, nb_frame);
	  goto wrapup;
	}
 
	for( i=0 ; i<nb_frame ; i++ ){
	  glob_frame_obj->frame_obj[i].status = 0;
	  glob_frame_obj->frame_obj[i].frame  = buff[i];
	  glob_frame_obj->frame_obj[i].frame_name[0] = '\0';
	}

	for( i=0 ; i<nb_frame ; i++ ){
	  sts =
	  om$send(msg = message NDnode.NDget_objects
		  (ND_ROOT, &glob_frame_obj->frame_obj[i].expression, 
		   1, NULL, 1, 1, &count),
		  senderid = NULL_OBJID,
		  targetid = glob_frame_obj->frame_obj[i].frame.objid, 
		  targetos = glob_frame_obj->frame_obj[i].frame.osnum);
	  if(!(sts&1)){
	    printf("Error, cannot get the roots (index: %d)\n",i);
	    goto wrapup; /* return 0; */
	  }

	  if(count != 4){
	    goto wrapup ; /*  return 0; */
	  }

	  sts =
	  om$send(msg = message expression.NDgive_value(&fr_number),
 		  senderid = NULL_OBJID,
		  targetid = glob_frame_obj->frame_obj[i].expression.objid,
		  targetos = glob_frame_obj->frame_obj[i].expression.osnum);
	  if(!(sts&1)){
	    printf("Error, cannot get the value (index: %d)\n",i);
	    goto wrapup; /* return 0; */
	  }
	  glob_frame_obj->frame_obj[i].old_frame_number = (int) fr_number;
	}

	End
	return 1;

 wrapup:
	_FREE ( glob_frame_obj->frame_obj );
	glob_frame_obj->frame_obj = NULL ;
	End
        return 0;
}

/*
/* SMPlaceFrame
/*
/*  Given the frame definition info, computes the frames and create
/*  the ppl_macro for each separated frames.
/*
/*  It also dealloc the struct sect_info of the frame def.
/*
/*  Return 1 if ok else 0. When it fails the frame number where and error
/*  has been detected is returned by bad_frame.
/*
/* */
SMPlaceFrame(fr_syst_name,cs, frame_def_info, bad_frame)
char             *fr_syst_name;         /* The name of the frame system (I) */
struct GRid	 *cs;			/* Identified of the cs 	(I) */
struct frame_def *frame_def_info;	/* frame def info		(I) */
IGRint		 *bad_frame;		/* If fail, bad frame number 	(O) */
{
 int 		lowest_frame, highest_frame;
 struct frame  *frame;	
 int	 	nb_frame;
 struct GRid    owner;

 *bad_frame = 0;

 if(SMSetFrame(frame_def_info, &nb_frame, &frame, &lowest_frame, 
 	       &highest_frame, bad_frame) != 1)
   {
    printf("Cannot generated the frame structure\n");
    return 0;
   }
    

 if(SMCreateFrame(fr_syst_name,cs, frame_def_info, nb_frame,
		  frame, lowest_frame,highest_frame,&owner, bad_frame) != 1)
   {
    printf("Cannot generated the frame objects\n");
    return 0;
   }

 return 1;
}

/*
/* SMModFrame
/*
/*  Given the frame definition info and the modifiied one, computes the frames 
/*  and update the ppl_macro for each separated frames (only if necessary).
/*
/*  for this release, no frame can be added or deleting. Only global
/*  parameters can be modified.
/*
/*  If the modification affect only the display and not the location, the 
/*  dependancy will not be updated.
/*
/*  Return 1 if ok else 0. When it fails the frame number where and error
/*  has been detected is returned by bad_frame.
/*
/* */
SMModFrame(new_fr_name,owner,cs,new_cs,frame_def_obj,
	   frame_obj, frame_def_info, mod_frame_def_info, bad_frame)
char             *new_fr_name;           /* New Name of the frame_system (I)   */
struct GRid      *owner;		/* The owner of frame system    (I)   */
struct GRid	 *cs;			/* Identified of the cs 	(I/O) */
struct GRid      *new_cs;     	        /* cs locate in the modify      (I)   */
struct GRid	 *frame_def_obj;	/* Identified of the frame def  (I/O) */
struct GRid	 *frame_obj;		/* Identified of the frame info (I/O) */
struct frame_def *frame_def_info;	/* Existing frame def info	(I)   */
struct frame_def *mod_frame_def_info;	/* Modified frame def info	(I)   */
IGRint		 *bad_frame;		/* If fail, bad frame number 	(O)   */
{
 int 		lowest_frame, highest_frame;
 int 		lowest_mod_frame, highest_mod_frame;
 struct frame  *frame, *mod_frame;	
 int	 	nb_frame, nb_mod_frame;
 struct	glob_frame_obj glob_frame_obj;
 IGRlong msg,status;
 
 *bad_frame = 0;


 if(SMSetFrame(frame_def_info, &nb_frame, &frame, &lowest_frame, 
 	       &highest_frame, bad_frame) != 1)
   { printf("Cannot retrieve the existing frame structure\n"); return 0;}

 if(SMSetFrame(mod_frame_def_info, &nb_mod_frame, &mod_frame, &lowest_mod_frame, 
 	       &highest_mod_frame, bad_frame) != 1)
   { printf("Cannot compute the frame structure\n"); return 0;}

 if(nb_mod_frame != nb_frame)
  { printf("Error, the number of frames has been modified\n"); return 0;}

 if(SMGetFrmSyst(owner,cs,frame_def_obj, frame_obj,
		  nb_frame, &glob_frame_obj) != 1)
  { printf("Error, cannot retrieve the frame system objects\n"); return 0;}
   
 if(SMCrtFrmObj(new_cs,frame_def_info, nb_frame, frame, lowest_frame, 
 	         highest_frame, mod_frame_def_info, nb_mod_frame, mod_frame, 
	         lowest_mod_frame, highest_mod_frame, bad_frame, 
		 &glob_frame_obj) != 1)
   { printf("Cannot create the frame objects\n"); return 0;}

 if(SMUpdFrame(owner,new_cs,nb_frame, frame,&glob_frame_obj,TRUE,bad_frame) != 1)
   { printf("Cannot update the frame system\n"); return 0;}

 *cs            = *new_cs;
 *frame_def_obj = glob_frame_obj.frame_def;
 *frame_obj     = glob_frame_obj.frame_info;


 /* Jean 6/25/93 : Change name of frame system with classical sman function */
 if(!SMChgElemName(owner,new_fr_name,NULL))
  { printf("Cannot change frame system name\n");return 0;}
 
 /* Free the frame_obj structure */
 _FREE(glob_frame_obj.frame_obj);

 if(nb_frame != 0) _FREE(frame);
 if(nb_mod_frame != 0) _FREE(mod_frame);

 return 1;
}

/*  This fonction erase all frame which are deleted or modified */
SMEraseFrame(glob_frame_obj,nb_frame)
struct glob_frame_obj 	*glob_frame_obj;  /*  [I]  */
int nb_frame; /* [I] */
{ 
  int wait_batch;
  int i;
  IGRlong sts;

  /* do the exec batch to update what has been updated */
  nd$mod_batch(request     = ND_INQ,
	       p_ret_mode = &wait_batch);
  
  if(wait_batch == ND_DEFER) return 1; /* Nothing to do */
  
   /* Erase the frame */
  for(i=0;i<nb_frame;i++)
    if((glob_frame_obj->frame_obj[i].status & DEL_FRAME)  ||
       (glob_frame_obj->frame_obj[i].status & DISP_FRAME) ||
       (glob_frame_obj->frame_obj[i].status & NAME_FRAME) ||
       (glob_frame_obj->frame_obj[i].status & COMP_FRAME))
     {
       sts = om$send(msg = message NDnode.NDdisplay(0, GRbe, NULL),
		     senderid = NULL_OBJID,
		     targetid = glob_frame_obj->frame_obj[i].frame.objid,
		     targetos = glob_frame_obj->frame_obj[i].frame.osnum);
       if(!(sts&1)) 
	    printf("Warning, cannot erase the frame number: %d\n",
		   glob_frame_obj->frame_obj[i].new_frame_number);
     } 
  return 1;
}

 /*  This fonction execute the batch (if not in ND_DEFER) */
 /*  and redisplay the frames */

SMFrExBatch(glob_frame_obj,nb_frame)
struct glob_frame_obj 	*glob_frame_obj;  /*  [I]  */
int nb_frame; /* [I] */ 
{
  int wait_batch;
  int i;
  IGRlong sts;

  /* do the exec batch to update what has been updated */
  nd$mod_batch(request     = ND_INQ,
	       p_ret_mode = &wait_batch);
  
  if(wait_batch == ND_DEFER) return 1; /* Nothing to do */
 
  nd$exec_batch(mode = ND_DISP_BODY);

  for(i=0;i<nb_frame;i++)
   {
     if((glob_frame_obj->frame_obj[i].status & NAME_FRAME) || 
	(glob_frame_obj->frame_obj[i].status & DISP_FRAME) ||
	(glob_frame_obj->frame_obj[i].status & COMP_FRAME) ||
	(glob_frame_obj->frame_obj[i].status & CRT_FRAME))
      {
	/* Display the frame */
	sts = om$send(msg = message NDnode.NDdisplay(1,GRbd,NULL),
		      senderid = NULL_OBJID,
		      targetid = glob_frame_obj->frame_obj[i].frame.objid,
		      targetos = glob_frame_obj->frame_obj[i].frame.osnum);
	if(!(sts&1)) 
	 {
	   printf("Warning, cannot display the frame number: %d\n",
		  glob_frame_obj->frame_obj[i].new_frame_number);
	   continue;
	 }
      }
   }     
  return 1;
}

end implementation Root;




