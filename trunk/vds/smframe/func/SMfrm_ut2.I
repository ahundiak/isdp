/* $Id: SMfrm_ut2.I,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smframe/func / SMfrm_ut2.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMfrm_ut2.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:35  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.7  1998/03/04  14:58:30  pinnacle
# Replaced: smframe/func/SMfrm_ut2.I for:  by rchennup for vds
#
# Revision 1.6  1998/02/09  16:01:38  pinnacle
# Replaced: smframe/func/SMfrm_ut2.I for:  by azuurhou for vds
#
# Revision 1.5  1998/01/19  21:31:48  pinnacle
# Replaced: smframe/func/SMfrm_ut2.I for:  by v250_int for vds
#
# Revision 1.4  1998/01/12  21:32:50  pinnacle
# Replaced: smframe/func/SMfrm_ut2.I for:  by azuurhou for vds
#
# Revision 1.3  1997/12/02  09:39:38  pinnacle
# Replaced: smframe/func/SMfrm_ut2.I for:  by ksundar for vds
#
# Revision 1.2  1997/06/23  06:17:14  pinnacle
# Replaced: smframe/func/SMfrm_ut2.I for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/10/22  14:16:04  pinnacle
# TR179601559
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1996/05/13  16:05:28  pinnacle
# Replaced: smframe/func/SMfrm_ut[12].I for:  by jwfrosch for vds.240
#
# Revision 1.4  1996/05/10  18:59:10  pinnacle
# Replaced: ./smframe/func/SMfrm_ut2.I for:  by azuurhou for vds.240
#
# Revision 1.3  1996/04/17  14:34:52  pinnacle
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
 *      10/22/96        ah              TR179601559 Get rid or error msg
 *
 *	05/10/96	HF		TR's 179600757 & 179601535
 *					increase _REALLOC by 1
 *
 *		(*nb_frame+nb_add_frame) ==>> (*nb_frame+nb_add_frame+1)
 *
 *		because otherwise "new_fr_index++;" will cause
 *		assignment at this index to be BEYOND allocated
 *		memory !!!
 *
 *	06/18/97	Sundar		Modified the functions SMFillFrame &
 *					SMVerDefault for the CR:179600824 to
 *					accept - spacing.
 *	12/02/97	Sundar		Modified for the CR:179309743.
 * -------------------------------------------------------------------*/
  
class implementation Root;

#include <stdio.h>
#include <malloc.h>
#include <math.h>

#include "OMmacros.h"
#include "exmacros.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igrdp.h"
#include "godef.h"
#include "igr.h"
#include "igetypedef.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "parametric.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "go.h"
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
#include "griodef.h" 
#include "griomacros.h"
#include "SMframe.h"
#include "vdsmacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

#include "AS_status.h"

/*Prototypes */

/*#define DEBUG */
#define OLDNAME 1

#define EPSILON 0.00001

from NDnode 		import NDchg_state, NDs_compute_node, NDget_objects;
from NDnode		import  NDdisplay, NDchange_connect;
from ACrg_collect	import ACadd_list_attribute, ACget_named_attribute;
from ACrg_collect	import ACmod_list_attribute;
from ci_macro		import init;
from GRvg		import GRputname, GRchglevel, GRchgname, GRgetname;
from GRgraphics		import GRchgprops;
from SMfrm_syst         import GRdelete_owner;
                    

from NDmacro import ACreturn_foot;

extern GRclassid OPP_ACrg_collect_class_id;
extern GRclassid OPP_SMfrm_syst_class_id;

/* Compare two IGRint */
static int SMfrm_comp_increase(a,b)
IGRint *a,*b;
{
  return((*a == *b) ? 0 : ( *a < *b) ? -1 : 1);
}

/* 
/* SMFillFrmDefInfo
/*
/*  Given the frame definition identifier, fill the structure gathering 
/*  the frame definition parameters. The "max_sect" is the maximun number
/*  of allocated sections.
/* 
/*  Return 1 if ok else 0;
/*
/* */
SMFillFrmDefInfo(rg_coll, max_sect, frame_def_info)
struct GRid	 *rg_coll;        /* Identifier of the coll	(I) */
int		  max_sect;	  /* Maximun number of sections (I) */ 
struct frame_def *frame_def_info; /* Main frame def parameters	(O) */
{
 IGRint		 k, i;
 char		 att_name[40], tmp[10];
 double 	 dbl;
 char            buf[NB_CUT_STR * ATTR_TXT];
 char 		 nameattr[20];
 
 SetProc( SMFillFrmDefInfo ); Begin
 strcpy(att_name, " ");
 
 /* Fill the info of nb sect_info */
 if(VDSGetAttDbl(rg_coll, "nb_sect", &dbl) != 1) {

/* ah TR179601559
 * This fix results in this routine being called when frame systems
 * are placed using the execute button.  As a result, a spurious
 * error message is generated.
 * 
 * Have this routine fail silently when rg_coll holds no attributes.
 */

  return 0;
 }

 frame_def_info->nb_sect = dbl;
 if(frame_def_info->nb_sect > max_sect)
  {
    printf("Warning, to many sections\n");
    frame_def_info->nb_sect = max_sect;
  }
 
 /* Fill the info of main_info */
 if(VDSGetAttTxt(rg_coll, "axis", tmp) != 1) goto wrapup;
 frame_def_info->main_info.axis = tmp[0];
 
 if(VDSGetAttTxt(rg_coll, "orient", tmp) != 1) goto wrapup;
 frame_def_info->main_info.orient = tmp[0];
 
 if(!VDSGetAttTxt(rg_coll,"justif"    , frame_def_info->main_info.justif) ||
    !VDSGetAttTxt(rg_coll,"annot"     , frame_def_info->main_info.annot)  ||
    !VDSGetAttDbl(rg_coll,"rev_dist"  , &frame_def_info->main_info.rev_dist) ||
    !VDSGetAttDbl(rg_coll,"plane_size", &frame_def_info->main_info.plane_size)||
    !VDSGetAttDbl(rg_coll,"reinf_size", &frame_def_info->main_info.reinf_size)||
    !VDSGetAttDbl(rg_coll,"offset"    , &frame_def_info->main_info.offset_dist))
  {
    printf("Erreur retrieving frame parameter\n");
    return 0;
  }
 
 /* Jean 21 July 93 */
 /* Retrieve name_type and unit: put a default value if not found */
 if(!(VDSGetAttDbl(rg_coll,"name_type", &dbl)))
   frame_def_info->main_info.name_type = NAME_BY_NUMBER; 
 else
   frame_def_info->main_info.name_type = (int)dbl;

 if(!(VDSGetAttTxt(rg_coll,"unit", frame_def_info->main_info.unit)))
  {
    OMuword  mod_osnum;
    short    flag = 0, num_defaults = 1;
    IGRlong  msg;

    ex$get_cur_mod (osnum=&mod_osnum);
    co$get_default_units(msg           = &msg,
			 table_name    = GRIO_DISTANCE,
			 osnum         = mod_osnum,
			 flag          = &flag,
			 num_defaults  = &num_defaults,
			 default_units = frame_def_info->main_info.unit);
  }


 frame_def_info->main_info.reinfstr[0] = '\0';
 frame_def_info->main_info.revstr[0]   = '\0';
 
 /* Get the reinforced string */
 buf[0] = '\0';
 for(i = 0; i < NB_CUT_STR ; i++)
  {
    sprintf(nameattr,"reinfstr%d",i);
    if(!VDSGetAttTxt(rg_coll,nameattr,buf + i * (ATTR_TXT - 1)));
     /* printf("Can't retrieve expression for reinforced frame\n"); */
  }
 strcpy(frame_def_info->main_info.reinfstr,buf);
 
 /* Get the reverse string */
 buf[0] = '\0';
 for(i = 0 ; i < NB_CUT_STR; i++)
  {
    sprintf(nameattr,"revstr%d",i);
    if(!VDSGetAttTxt(rg_coll,nameattr,buf + i * (ATTR_TXT - 1)));
     /* printf("Can't retrieve expression for reverse frame\n"); */
  }
 strcpy(frame_def_info->main_info.revstr,buf);
 
 /* Fill the info for each section */
 strcpy(att_name,"S");
 for(i=0;i<frame_def_info->nb_sect;i++)
  {
    sprintf(&att_name[1],"%d",i);
    k = strlen(att_name);
    
    strcpy(&att_name[k], "from");
    if(VDSGetAttDbl(rg_coll, att_name, &dbl) != 1) goto wrapup;
    frame_def_info->sect_info[i].fr = (int) dbl;
    
    strcpy(&att_name[k], "to");
    if(VDSGetAttDbl(rg_coll, att_name, &dbl) != 1) goto wrapup;
    frame_def_info->sect_info[i].to = (int) dbl;
    
    strcpy(&att_name[k], "spacing");
    if(VDSGetAttDbl(rg_coll,att_name, &frame_def_info->sect_info[i].spacing) != 1)
      goto wrapup;
    
    strcpy(&att_name[k], "reinf");
    if(VDSGetAttDbl(rg_coll, att_name, &dbl) != 1) goto wrapup;
    frame_def_info->sect_info[i].reinf = (int) dbl;
    
    strcpy(&att_name[k], "offset");
    if(VDSGetAttDbl(rg_coll, att_name, &dbl) != 1) goto wrapup;
    frame_def_info->sect_info[i].offset = (int) dbl;
    
  }

 /* Fill the info of nb nm_sect_info */
 if(VDSGetAttDbl(rg_coll, "nb_nm_sect", &dbl) != 1) {
                        /* return 0; AD */
			dbl = 0 ;
 }
 
 frame_def_info->nb_nm_sect = dbl;
 if(frame_def_info->nb_nm_sect > max_sect)
  {
    printf("Warning, to many name sections\n");
    frame_def_info->nb_nm_sect = max_sect;
  }

 /* Fill the info for each name section */
 strcpy(att_name,"N");
 for(i=0;i<frame_def_info->nb_nm_sect;i++)
 {
    sprintf(&att_name[1],"%d",i);
    k = strlen(att_name);
 
    strcpy(&att_name[k], "from");
    if(VDSGetAttDbl(rg_coll, att_name, &dbl) != 1) goto wrapup;
    frame_def_info->nm_sect_info[i].fr = (int) dbl;
 
    strcpy(&att_name[k], "to");
    if(VDSGetAttDbl(rg_coll, att_name, &dbl) != 1) goto wrapup;
    frame_def_info->nm_sect_info[i].to = (int) dbl;
 
    strcpy(&att_name[k], "name");
    if(VDSGetAttTxt(rg_coll,att_name, &frame_def_info->nm_sect_info[i].name) !=
1)
      goto wrapup;
 
    strcpy(&att_name[k], "dorn");
    if(VDSGetAttDbl(rg_coll, att_name, &dbl) != 1) goto wrapup;
    frame_def_info->nm_sect_info[i].dorn = (int) dbl;
 
  }

 
 End
 return 1;
 
 wrapup:
 printf("Error name: %s not found\n",att_name);
 End
 return 0;
}


/* 
/* SMFillFrame
/* 
/* Fill one frame.
/* We don't set the spacing for first frame in a section
/*
/*
/*  Return 1 if ok else 0;
/*
/* */
SMFillFrame(frame, frame_number, sect_info,reinf,nb_reinf,rev,nb_rev,mod)
struct frame 	  *frame;	 /* Frame info			(I/O) */
int	      	   frame_number; /* Frame number		 (I)  */
struct sect_info  *sect_info;	 /* Sect frame parameters	 (I)  */
int               *reinf;        /* Array of reinforced frame    (I) */
int               nb_reinf;      /* Number of reinforced         (I) */
int               *rev;          /* Array of reversed frame      (I) */
int               nb_rev;        /* Number of reversed frame     (I) */
short		   mod;		 /* If it is a modification (1)  (I)  */
{
 int fr;
 int j;

 fr 	       = sect_info->fr;
 frame->number = frame_number;

 frame->reinf   = 0;
 frame->reverse = 0;
 if(mod == 1)
  {
   /* Modify the data of an existing one */
   /* SUNDAR replaced > with != for CR:179600824*/
   if(sect_info->spacing != NO_SPACING )
    {
      if(frame->number > fr && frame->number < sect_info->to)
	frame->rel_pos = sect_info->spacing;
      if(frame->number == fr && frame->number < 0)
	frame->rel_pos = sect_info->spacing;
      if(frame->number == sect_info->to && frame->number > 0)
	frame->rel_pos = sect_info->spacing;
    }

   if(sect_info->offset  > NO_OFFSET)  frame->offset_layer = sect_info->offset;
#ifdef OLDVERSION
   if(sect_info->reinf   > NO_REINF && sect_info->reinf > 0)   
    {
     if(((frame_number - fr) % sect_info->reinf) == 0) frame->reinf = 1;
     else 					       frame->reinf = 0;
    } 
#endif
 } 
 else
  {
   /* Defined a new frame */
   frame->name[0]      = '\0';  

   frame->rel_pos = sect_info->spacing;
   if(frame->number == fr && frame_number > 0)
     frame->rel_pos = NO_SPACING; 
   if(frame->number == sect_info->to && frame_number < 0)
     frame->rel_pos = NO_SPACING;

   frame->abs_pos      = 0;
   frame->offset_layer = sect_info->offset;
#ifdef OLDVERSION
   if(sect_info->reinf > NO_REINF && sect_info->reinf > 0)   
    {
     if(((frame_number - fr) % sect_info->reinf) == 0) frame->reinf = 1;
     else 					       frame->reinf = 0;
    }
   else frame->reinf = 0;
#endif
 }

 for(j = 0; j < nb_reinf ; j++)
   if(reinf[j] == frame_number)
    {
      frame->reinf = 1;
      break;
    }

 for(j = 0; j < nb_rev; j++)
   if(rev[j] == frame_number)
    {
      frame->reverse = 1;
      break;
    }

 return 1;
}


/* 
/* SMSetFrame
/*
/*  Fill the structure gathering all the frames. The array of frame
/*  is allocated by the function and must be deallocated by the user.
/*
/*  Return 1 if ok else 0;
/*
/* */
SMSetFrame(frame_def_info, nb_frame, frame, lowest_frame, highest_frame, bad_frame)
struct frame_def       *frame_def_info;	 /* main frame def parameters	 (I) */
int		       *nb_frame;	 /* nb frames			 (O) */
struct frame          **frame;	 	 /* frame info			 (O) */
int		       *lowest_frame; 	 /* Lowest frame number		 (O) */
int		       *highest_frame;   /* highest frame number	 (O) */
int		       *bad_frame;       /* Frame number where it fails  (O) */ 
{
	int		nb_alloc_frame;
	int		i, j, k;
	int		*reinf_num,
			*rev_num; /* Array for reinf and reverse number */
	int		nb_rev,
			nb_reinf;  /* Number of reinforced and reverse frame */ 
	char		syn_error[40]; 
	int		fr_index;

	SetProc( SMSetFrame ); Begin

	nb_alloc_frame	= 0;
	*nb_frame 	= 0;
	*bad_frame	= 0;
	reinf_num	= rev_num = NULL;

	if( ! SMFrmAnalyseExp(	frame_def_info->main_info.reinfstr,
				&reinf_num,
				&nb_reinf,
				syn_error))
		nb_reinf = 0;

	__DBGpr_int(" nb_reinf ", nb_reinf );
 
	if( ! SMFrmAnalyseExp(	frame_def_info->main_info.revstr,
				&rev_num,
				&nb_rev,
				syn_error ))
		nb_rev = 0;

	__DBGpr_int(" nb_rev ", nb_rev );
	__DBGpr_int(" # Sections ", frame_def_info->nb_sect );

  /* Loop for all the sections */
  for(i=0;i<frame_def_info->nb_sect;i++)
 {
    /* Loop for all the frames defined for one section */
    for(	j  =  frame_def_info->sect_info[i].fr;
		j  <= frame_def_info->sect_info[i].to;
		j++ )
    {
      if(SMIsFrameDef(*frame, *nb_frame, j, &k) == 1)
      {
        /* The frame has already been defined */
        if(SMFillFrame(&((*frame)[k]), j, &frame_def_info->sect_info[i],
		       reinf_num,nb_reinf,rev_num,nb_rev,1) != 1)
	{
 	  printf("Error for the frame number: %d\n", j);
          *bad_frame = j;
	  goto wrapup;
	}
      }
      else
      {
        /* First def for the frame */
        if(SMAllocFrame(frame, *nb_frame, &nb_alloc_frame) != 1)
	{
	  *bad_frame = j; 
	  goto wrapup;
	}
       
        if(SMFillFrame(&((*frame)[*nb_frame]), j, &frame_def_info->sect_info[i],
		       reinf_num,nb_reinf,rev_num,nb_rev,0) != 1)
        {
	  printf("Error for the frame number: %d\n", j);
	  *bad_frame = j;
	  goto wrapup;
	}
        *nb_frame = *nb_frame + 1;
      }
    } /* End  Loop for all the frames defined for one section */
  } /* End Loop for all the sections */
  

  /* We don't set the spacing for the lowest_frame in each section */
  /* So the lowest frame as no spacing defined (not need if frame 0)*/
  /* Get the lowest frame and set it's spacing */

  *lowest_frame  = 0;
  for(i = 0; i < *nb_frame; i++)
    if((*frame)[i].number < *lowest_frame)  *lowest_frame = (*frame)[i].number;

  /*  Get the index of the lowest frame */
  SMIsFrameDef(*frame, *nb_frame, *lowest_frame, &fr_index);
   
  /* the spacing of the lowest is determined by his section */  
  for( i=0 ; i<frame_def_info->nb_sect ; i++ ){
    if(*lowest_frame == frame_def_info->sect_info[i].fr)
      (*frame)[fr_index].rel_pos = frame_def_info->sect_info[i].spacing;
  }
 
  /* Verify and set the NO_OFFSET, NO_REINF, NO_SPACING */
  if( SMVerDefault(	*frame,
			*nb_frame,
			&k ) != 1 ){
    printf("Error, Bad spacing definition from the frame number: %d\n", k);
    *bad_frame = k;
    goto wrapup;
  }

 /* Compute the frame */
  if( SMCompFrame(	*frame,
			*nb_frame,
			frame_def_info, 
			lowest_frame,
			highest_frame, &k) != 1 ){
    printf("Error, Bad definition from the frame number: %d\n",k);
    *bad_frame = k;
    goto wrapup;
  }

 _FREE(rev_num);
 _FREE(reinf_num);
 return 1;

 wrapup:
 _FREE(rev_num);
 _FREE(reinf_num);
 return 0;
}


/*
/* SMCrtFrmCol:
/*
/* Create or modify the frame collection.
/*
/*
/*  If mod = 0 then create the rg collection else only modify it.
/*
/*  Return 1 if ok else 0;
/*
/* */
SMCrtFrmCol(frame, nb_frame, lowest_frame, highest_frame, rg_coll, mod)
struct frame 	 *frame;     /* Frame info			(I)  */
IGRint		  nb_frame;	  /* Number of frames		(I)  */
IGRint		  lowest_frame;   /* Lowest frame number	(I)  */
IGRint		  highest_frame;  /* Highest frame number	(I)  */
struct GRid	 *rg_coll;        /* Created collection	       (I/O) */
IGRint		  mod;		  /* 1 modify, 0 create		(I)  */
{
  IGRint			k, i;
  IGRlong 		sts;
  char			att_name[40];
  OM_S_OBJID      mod_id;
  OMuword         mod_osnum;
  
  ex$get_cur_mod (id=&mod_id, osnum=&mod_osnum);
  strcpy(att_name, " ");
  
  if(mod != 1)
   {
     /* Constuct the rg collection */
     rg_coll->osnum = mod_osnum;
     sts = om$construct( classid = OPP_ACrg_collect_class_id,
			osnum   = rg_coll->osnum,
			p_objid = &rg_coll->objid );
     if(!(sts&1)) return 0;
     
     sts = om$send(msg = message NDnode.NDchg_state(ND_DEL_NO_CH | ND_WAIT_DEL,
						    ND_DEL_NO_CH | ND_WAIT_DEL),
		   senderid = NULL_OBJID,
		   targetid = rg_coll->objid,
		   targetos = rg_coll->osnum );
     if(!(sts&1)) return 0;
   }
  
  /* Add the info of lowest_frame and highest_frame */
  if(VDSSetAttDbl(rg_coll, "lowest_frame", (double) lowest_frame, mod) != 1 ||
     VDSSetAttDbl(rg_coll, "highest_frame", (double) highest_frame, mod) != 1)
    goto wrapup;
  
  strcpy(att_name,"F");
  for(i=0;i<nb_frame;i++)
   {
     if(frame[i].number == NO_FRAME) continue;
     
     sprintf(&att_name[1],"%d",frame[i].number);
     k = strlen(att_name);
     
     strcpy(&att_name[k], "number");


     if(!VDSSetAttDbl(rg_coll, att_name, (double) frame[i].number, mod))
       goto wrapup;
     
     strcpy(&att_name[k], "rel_pos");
     if(!VDSSetAttDbl(rg_coll, att_name, frame[i].rel_pos, mod))
       goto wrapup;
     
     strcpy(&att_name[k], "abs_pos");
     if(!VDSSetAttDbl(rg_coll,att_name, frame[i].abs_pos, mod))
       goto wrapup;
     
     strcpy(&att_name[k], "offset");
     if(!VDSSetAttDbl(rg_coll,att_name,(double) frame[i].offset_layer, mod))
       goto wrapup;
     
     strcpy(&att_name[k], "reinf");
     if(!VDSSetAttDbl(rg_coll, att_name,(double) frame[i].reinf, mod))
       goto wrapup;
     
     strcpy(&att_name[k], "reverse");
     if(!VDSSetAttDbl(rg_coll, att_name,(double) frame[i].reverse, mod))
       printf("Warning, can't set the reverse attributes\n");
     
     strcpy(&att_name[k], "name");
     if(VDSSetAttTxt(rg_coll, att_name, frame[i].name, mod) != 1) 
      {
	/* in comment because this one has been added after ... */
	/* goto wrapup; */
      } 
   } 
  
  return 1;
  
 wrapup:
  if(mod==0) printf("Error adding name: %s\n",att_name);
  else	printf("Error modifying name: %s\n",att_name);
  return 0;
}


/*
/* SMCrtFrmObj:
/* Eventually update here the coordinate system in glob_frame_obj */
/* */
SMCrtFrmObj(new_cs,frame_def_info, nb_frame, frame, lowest_frame,
		 highest_frame, mod_frame_def_info, nb_mod_frame, mod_frame, 
	         lowest_mod_frame, highest_mod_frame, bad_frame, 
		 glob_frame_obj)
struct GRid             *new_cs; 
struct frame_def 	*frame_def_info, *mod_frame_def_info; 
IGRint		 	 nb_frame, nb_mod_frame; 
struct frame	 	*frame, *mod_frame;
IGRint		 	 lowest_frame, highest_frame;
IGRint        	 	 lowest_mod_frame, highest_mod_frame;
IGRint			*bad_frame;
struct glob_frame_obj 	*glob_frame_obj;

{
 IGRlong	sts;
 IGRint 	mod_fr_nb, fr_nb, frame_status, chg_frame_struct, i;
 IGRint 	frame_index, mod_frame_index, fr_syst_index;
 IGRdouble	fabs();
 char plane_name[40];
 int  user_name;
 int		iDummy ;


 iDummy		= highest_frame ;

 user_name     = 0;
 plane_name[0] = '\0';
 *bad_frame = 0;
 
 /* if((highest_mod_frame - lowest_mod_frame) != (highest_frame - lowest_frame))
    /* */
   if(nb_frame != nb_mod_frame)
    {
      printf("Error, the number of frames does not match the previous one\n");
      *bad_frame = lowest_mod_frame;
      return 0;
    }
 
 /* Look for the main parameters */
 frame_status = 0;
 
 if(new_cs->objid != glob_frame_obj->cs.objid ||
    new_cs->osnum != glob_frame_obj->cs.osnum)
  {
    /* Coordinate system as been changed */
    frame_status |= MOD_FRAME | COMP_FRAME;
  }
 
 if(mod_frame_def_info->main_info.axis != frame_def_info->main_info.axis)
  {
    /* New axis */
    frame_status |= MOD_FRAME | COMP_FRAME;
  }
 
 if(mod_frame_def_info->main_info.orient != frame_def_info->main_info.orient)
  {
    /* New orientation */
    frame_status |= MOD_FRAME | COMP_FRAME;
  }
 
 if(strncmp(mod_frame_def_info->main_info.justif, frame_def_info->main_info.justif, 2) != 0)
  {
    /* New justif */
    frame_status |= MOD_FRAME | DISP_FRAME;
  }
 
 if(strcmp(mod_frame_def_info->main_info.annot, frame_def_info->main_info.annot) != 0)
  {
    /* New annotation */
    frame_status |= MOD_FRAME | DISP_FRAME | NAME_FRAME;
  }
 
 if(mod_frame_def_info->main_info.rev_dist != frame_def_info->main_info.rev_dist)
  {
    /* Modif where the plane are reversed */
    frame_status |= MOD_FRAME | COMP_FRAME;
  }
 
 if(mod_frame_def_info->main_info.plane_size != frame_def_info->main_info.plane_size)
  {
    /* New plane size */
    frame_status |= MOD_FRAME | DISP_FRAME;
  }
 
 if(mod_frame_def_info->main_info.reinf_size != frame_def_info->main_info.reinf_size)
  {
    /* New reinf plane size */
    frame_status |= MOD_FRAME | DISP_FRAME;
  }
 
 if(mod_frame_def_info->main_info.offset_dist != frame_def_info->main_info.offset_dist)
  {
    /* New offset distance */
    frame_status |= MOD_FRAME | COMP_FRAME;
  }
 
 if(mod_frame_def_info->main_info.orient != frame_def_info->main_info.orient)
  {
    /* New orientation */
    frame_status |= MOD_FRAME | COMP_FRAME;
  }
 
 /* Jean : 21 July 93 : Look if change in frame annotation */
 if(mod_frame_def_info->main_info.name_type != frame_def_info->main_info.name_type)
  {
    /* New type for frame name */
    frame_status |= MOD_FRAME | DISP_FRAME;
  }
 
 if(mod_frame_def_info->main_info.name_type == NAME_BY_DIST &&
    strcmp(mod_frame_def_info->main_info.unit,frame_def_info->main_info.unit))
  {
    /* New unit for frame system and name is by distance */
    frame_status |= MOD_FRAME | DISP_FRAME;
  }

 chg_frame_struct = 0;
 fr_nb 		  = lowest_frame;
 for(mod_fr_nb = lowest_mod_frame; mod_fr_nb <= highest_mod_frame; mod_fr_nb++)
  {
    if(SMIsFrameDef(mod_frame, nb_mod_frame, mod_fr_nb, &mod_frame_index) != 1)
     {
       /* No frame found */
       *bad_frame = mod_fr_nb;
     }  
    
    if(SMIsFrameDef(frame, nb_frame, fr_nb, &frame_index) != 1)
     {
       /* No frame found */
       *bad_frame = fr_nb;
     }
    
    if(SMIsFrameSyst(glob_frame_obj->frame_obj, nb_frame, fr_nb,
		      &fr_syst_index) != 1)
     {
       *bad_frame = mod_fr_nb;
       return 0;
     }
    

    glob_frame_obj->frame_obj[fr_syst_index].new_frame_number = mod_fr_nb;
    glob_frame_obj->frame_obj[fr_syst_index].frame_name[0]    = '\0';
    glob_frame_obj->frame_obj[fr_syst_index].status           = frame_status;
    
    if(mod_fr_nb != fr_nb)
     {
       /* the frame number has changed */
       glob_frame_obj->frame_obj[fr_syst_index].status |= MOD_FRAME | COMP_FRAME | NAME_FRAME;
       chg_frame_struct = 1;
     }
    
    if(mod_frame[mod_frame_index].reinf != frame[frame_index].reinf)
     {
       /* reinforced change */
       glob_frame_obj->frame_obj[fr_syst_index].status |= MOD_FRAME | DISP_FRAME;
     }
    
    if(mod_frame[mod_frame_index].reverse != frame[frame_index].reverse)
     {
       /* orientation change */
       glob_frame_obj->frame_obj[fr_syst_index].status |= MOD_FRAME | COMP_FRAME;
     }
    
    
    if(fabs(mod_frame[mod_frame_index].abs_pos - frame[frame_index].abs_pos) > EPSILON)
     {
       /* The location is not the same */
       glob_frame_obj->frame_obj[fr_syst_index].status |= MOD_FRAME | COMP_FRAME;
     }

     /* PL 06/07/94 add test on offset_layer */

    if(mod_frame[mod_frame_index].offset_layer != frame[frame_index].offset_layer)
     {
	IGRshort	layer, act_layer;
  	IGRlong 	msg, sizebuf, nret;
	
       /* offset_layer change change it here*/

  	   sizebuf = sizeof(IGRshort);
  	   gr$get_active_level(msg=&msg,sizbuf=&sizebuf,
			 buffer = &act_layer,nret = &nret);

           layer = act_layer + mod_frame[mod_frame_index].offset_layer;

	   sts = om$send(msg = message GRvg.GRchglevel(&msg, &layer),
			 senderid = NULL_OBJID,
			 targetid = glob_frame_obj->frame_obj[fr_syst_index].frame.objid,
			 targetos = glob_frame_obj->frame_obj[fr_syst_index].frame.osnum);
	   if(!(sts & msg &1))
	    {
	      printf("Error changing the frame level: %d\n",    layer);
	      *bad_frame = mod_fr_nb;
	      return 0;
	    }

       glob_frame_obj->frame_obj[fr_syst_index].status |= MOD_FRAME ;
     }


	/* Copy anyway
    if(strcmp(mod_frame[mod_frame_index].name, frame[frame_index].name))
	*/
     {
       strcpy(glob_frame_obj->frame_obj[fr_syst_index].frame_name, 
			mod_frame[mod_frame_index].name);
	glob_frame_obj->frame_obj[fr_syst_index].status |= MOD_FRAME | DISP_FRAME | NAME_FRAME;
    } 

	#if 0
    /* If the name of the occurrence is user defined we don't touch it, */
    /* else we compute it */
    plane_name[0] = '\0';
    user_name     = 0;
    if(!SMGetUserName(&glob_frame_obj->frame_obj[fr_syst_index].frame, 
		      frame_def_info->main_info.annot, plane_name, &user_name))
      printf("Warning, error getting the name of the plane\n");
    
    if(user_name == 1)
     {
       /* User defined name */
       strcpy(glob_frame_obj->frame_obj[fr_syst_index].frame_name, plane_name);
       strcpy(mod_frame[mod_frame_index].name			 , plane_name);
       /* glob_frame_obj->frame_obj[fr_syst_index].status &= ~NAME_FRAME; 
       /* It should work but ... */
     }
     else
      {
	char tmp[20];

	/* Define the new name */
	strcpy(glob_frame_obj->frame_obj[fr_syst_index].frame_name,
	       mod_frame_def_info->main_info.annot);
	sprintf(tmp,"%d",mod_fr_nb);
	strcat(glob_frame_obj->frame_obj[fr_syst_index].frame_name,tmp);
	strcpy(mod_frame[mod_frame_index].name, glob_frame_obj->frame_obj[fr_syst_index].frame_name);
      }
	#endif
       
    fr_nb++;
  }   
 
 /* Modify the coordinate system if needed */ 
 if(new_cs->objid != glob_frame_obj->cs.objid ||
    new_cs->osnum != glob_frame_obj->cs.osnum)
  {
    for(i=0; i<nb_frame; i++)
     {
       sts = om$send(msg = message NDnode.NDchange_connect
	             (1,&glob_frame_obj->cs, new_cs),
		     senderid = NULL_OBJID,
		     targetid = glob_frame_obj->frame_obj[i].frame.objid,
		     targetos = glob_frame_obj->frame_obj[i].frame.osnum); 
       if(!(sts&1)) 
	{
	  printf("Cannot change the coordinate system for the frame: %d\n",
		 glob_frame_obj->frame_obj[i].old_frame_number);
	  *bad_frame = glob_frame_obj->frame_obj[i].old_frame_number;
	  return 0;
	}
     }
  }
 
 /* Modify the frame def and the frame rg coll */
 /* Warning. It will be faster to modify only the parameters which have */
 /* changed. To do later on if it is too slow. */
 /* If the number of frames did not change but if the lowest and highest */
 /* have changed, we need to kill the old rg collection of the frame */
 /* def and to recreate a new one. */
 /* The same if the number of section has changed */
 /* */
		     

 if((mod_frame_def_info->nb_sect != frame_def_info->nb_sect)
	|| (mod_frame_def_info->nb_nm_sect != frame_def_info->nb_nm_sect))
  {
    struct GRid new_frame_def;
    
    if(SMCrtFrmDefCol(mod_frame_def_info, &new_frame_def, 0) != 1)
     {
       printf("Error, cannot set the frame def rg collection\n");
       return 0;
     }
    /* Change root */
    for(i=0; i<nb_frame; i++)
     {
       sts = om$send(msg = message NDnode.NDchange_connect 
		     (1,&glob_frame_obj->frame_def, &new_frame_def),
		     senderid = NULL_OBJID,
		     targetid = glob_frame_obj->frame_obj[i].frame.objid,
		     targetos = glob_frame_obj->frame_obj[i].frame.osnum); 
       if(!(sts&1)) 
	{
	  printf("Cannot change the frame def for the frame: %d\n",glob_frame_obj->frame_obj[i].new_frame_number);
	  *bad_frame = glob_frame_obj->frame_obj[i].new_frame_number;
	  return 0;
	}
     }
    glob_frame_obj->frame_def = new_frame_def;
  }
 else
  {
    /* Only update */
    if(SMCrtFrmDefCol(mod_frame_def_info, &glob_frame_obj->frame_def, 1) != 1)
     {
       printf("Error, cannot update the frame def rg collection\n");
       return 0;
     }
  }

/* Modified for CR:179309743 begin*/

#if 0
if(mod_frame_def_info->nb_nm_sect != frame_def_info->nb_nm_sect)
  {
    struct GRid new_frame_def;
   
    if(SMCrtFrmDefCol(mod_frame_def_info, &new_frame_def, 0) != 1)
     {
       printf("Error, cannot set the frame def rg collection\n");
       return 0;
     }
    /* Change root */
    for(i=0; i<nb_frame; i++)
     {
       sts = om$send(msg = message NDnode.NDchange_connect
                     (1,&glob_frame_obj->frame_def, &new_frame_def),
                     senderid = NULL_OBJID,
                     targetid = glob_frame_obj->frame_obj[i].frame.objid,
                     targetos = glob_frame_obj->frame_obj[i].frame.osnum);
       if(!(sts&1))
        {
          printf("Cannot change the frame def for the frame: %d\n",
		glob_frame_obj->frame_obj[i].new_frame_number);
          *bad_frame = glob_frame_obj->frame_obj[i].new_frame_number;
          return 0;
        }
     }
    glob_frame_obj->frame_def = new_frame_def;
  }
 else
  {
    /* Only update */
    if(SMCrtFrmDefCol(mod_frame_def_info, &glob_frame_obj->frame_def, 1) != 1)
     {
       printf("Error, cannot update the frame def rg collection\n");
       return 0;
     }
  }
#endif
/* Modified for CR:179309743 end*/

 
 if(chg_frame_struct == 1)
  {
    struct GRid new_frame_info;
    
    if(SMCrtFrmCol(mod_frame, nb_mod_frame, lowest_mod_frame, highest_mod_frame,
		   &new_frame_info, 0) != 1)
     {
       printf("Error, cannot update the frame info rg collection\n");
       return 0;
     }
    /* Change root */
    for(i=0; i<nb_frame; i++)
     {
       sts = om$send(msg = message NDnode.NDchange_connect
		     (1,&glob_frame_obj->frame_info, &new_frame_info),
		     senderid = NULL_OBJID,
		     targetid = glob_frame_obj->frame_obj[i].frame.objid,
		     targetos = glob_frame_obj->frame_obj[i].frame.osnum); 
       if(!(sts&1)) 
	{
	  printf("Cannot change the frame for the frame: %d\n",
		 glob_frame_obj->frame_obj[i].new_frame_number);
	  *bad_frame = glob_frame_obj->frame_obj[i].new_frame_number;
	  return 0;
	}
     } 
    glob_frame_obj->frame_info = new_frame_info;
    /* Delete the old one */
  }
 else
  {
    if(SMCrtFrmCol(mod_frame, nb_mod_frame, lowest_mod_frame, highest_mod_frame,
		   &glob_frame_obj->frame_info, 1) != 1)
     {
       printf("Error, cannot update the frame info rg collection\n");
       return 0;
     }
  }
 
 return 1;
}



/* 
/* SMCrtFrmDefColl
/*
/*  Create or modify the rg_collection.
/*
/*  If mod = 0 then create the rg collection else only modify it.
/*
/*  Return 1 if ok else 0;
/*
/*  A faster implementation can be done. This consists to gather all
/*  the parameters inside a rg collection.
/*
/* */
SMCrtFrmDefCol(frame_def_info, rg_coll, mod)
struct frame_def *frame_def_info; /* Main frame def parameters	 (I)  */
struct GRid	 *rg_coll;        /* Identifier of the coll	(I/O) */
IGRint		  mod;		  /* 1 modify, 0 create		 (I)  */
{
 IGRint		 k, i;
 IGRlong 	 sts;
 char		 att_name[40], tmp[10];
 OM_S_OBJID      mod_id;
 OMuword         mod_osnum;
 char            buf[ATTR_TXT];
 char 		 nameattr[20];
 
 ex$get_cur_mod (id=&mod_id, osnum=&mod_osnum);
 strcpy(att_name, " ");
 
 if(mod != 1)
  {
    /* Constuct the rg collection */
    rg_coll->osnum = mod_osnum;
    sts = om$construct(classid = OPP_ACrg_collect_class_id,
		       osnum   = rg_coll->osnum,
		       p_objid = &rg_coll->objid );
    if(!(sts&1)) return 0;
    
    sts = om$send(msg = message NDnode.NDchg_state(ND_DEL_NO_CH | ND_WAIT_DEL,
						   ND_DEL_NO_CH | ND_WAIT_DEL),
		  senderid = NULL_OBJID,
		  targetid = rg_coll->objid,
		  targetos = rg_coll->osnum );
    if(!(sts&1)) return 0;
  }
 
 /* Add the info of nb sect_info */
 if(VDSSetAttDbl(rg_coll, "nb_sect", (double) frame_def_info->nb_sect, mod) != 1)
   goto wrapup;
 
 /* Add the info of main_info */
 tmp[0] = frame_def_info->main_info.axis;
 tmp[1] = '\0';
 if(!VDSSetAttTxt(rg_coll, "axis", tmp, mod)) goto wrapup;
 
 tmp[0] = frame_def_info->main_info.orient;
 tmp[1] = '\0';
 if(!VDSSetAttTxt(rg_coll, "orient", tmp, mod)) goto wrapup;
 
 if(!VDSSetAttTxt(rg_coll, "justif", frame_def_info->main_info.justif,mod) ||
    !VDSSetAttTxt(rg_coll, "annot" , frame_def_info->main_info.annot,mod) ||
    !VDSSetAttDbl(rg_coll, "rev_dist",frame_def_info->main_info.rev_dist, mod) ||
    !VDSSetAttDbl(rg_coll, "plane_size",
		  frame_def_info->main_info.plane_size,mod)||
    !VDSSetAttDbl(rg_coll, "reinf_size",
		  frame_def_info->main_info.reinf_size,mod) ||
    !VDSSetAttDbl(rg_coll, "offset",frame_def_info->main_info.offset_dist,mod))
   goto wrapup;

  /* Jean 21 July : Special traitment for name_type : attribute add later */
 if(!VDSSetAttDbl(rg_coll, "name_type",
		  (double)frame_def_info->main_info.name_type,mod))
   if(mod == 1) /* Modfif fail maybe because attribute doesn't exists */
    {
      if(!VDSSetAttDbl(rg_coll, "name_type",
		       (double)frame_def_info->main_info.name_type,0))
	goto wrapup;
    }
   else
     goto wrapup;
 
 /* Jean 21 July : Special traitment for unit : attribute add later */
 if(!VDSSetAttTxt(rg_coll,"unit",frame_def_info->main_info.unit,mod))
   if(mod == 1) /* Modfif fail maybe because attribute doesn't exists */
    {
      if(!VDSSetAttTxt(rg_coll,"unit",frame_def_info->main_info.unit,0))
	goto wrapup;
    }
   else
     goto wrapup;
 
 
 /* Set the reinforced string */
 /* (The ATTR_TXT is not enough large to support a big string) */
 
 for(i = 0; i < NB_CUT_STR; i++)
  {
    buf[0] = '\0';
    strncpy(buf,frame_def_info->main_info.reinfstr + i * (ATTR_TXT -1),
	    ATTR_TXT -1);
    buf[ATTR_TXT -1] = '\0';
    sprintf(nameattr,"reinfstr%d",i);
    if(!VDSSetAttTxt(rg_coll,nameattr,buf,mod))
      printf("Can't set attribute for reinforced frame\n");
  }
 
 
 /* Set the reverse string */
 for(i = 0; i< NB_CUT_STR ;i++)
  {
    buf[0] = '\0';
    strncpy(buf,frame_def_info->main_info.revstr + i * (ATTR_TXT -1),
	    ATTR_TXT -1);
    buf[ATTR_TXT -1] = '\0';
    sprintf(nameattr,"revstr%d",i);
    if(!VDSSetAttTxt(rg_coll,nameattr,buf,mod))
      printf("Can't set attribute for reverse frame\n");
  }
 
 /* Add the info for each section */
 strcpy(att_name,"S");
 for(i=0;i<frame_def_info->nb_sect;i++)
  {
    sprintf(&att_name[1],"%d",i);
    k = strlen(att_name);
    
    strcpy(&att_name[k], "from");
    if(VDSSetAttDbl(rg_coll, att_name, (double) frame_def_info->sect_info[i].fr, mod) != 1) goto wrapup;
    
    strcpy(&att_name[k], "to");
    if(VDSSetAttDbl(rg_coll,att_name,(double) frame_def_info->sect_info[i].to,mod) != 1) goto wrapup;
    
    strcpy(&att_name[k], "spacing");
    if(VDSSetAttDbl(rg_coll, att_name, frame_def_info->sect_info[i].spacing, mod) != 1) goto wrapup;
    
    strcpy(&att_name[k], "reinf");
    if(VDSSetAttDbl(rg_coll, att_name, (double) frame_def_info->sect_info[i].reinf, mod) != 1) goto wrapup;
    
    strcpy(&att_name[k], "offset");
    if(VDSSetAttDbl(rg_coll, att_name, (double) frame_def_info->sect_info[i].offset, mod) != 1) goto wrapup;
    
  }

	/* Add the info of nb nm_sect_info */
 if(VDSSetAttDbl(rg_coll, "nb_nm_sect", (double) frame_def_info->nb_nm_sect, mod) != 1){
	/* printf(" Not existing ...\n "); */
        if( VDSSetAttDbl(rg_coll, "nb_nm_sect",
			(double) frame_def_info->nb_nm_sect, 0) != 1){
		printf(" Added failed \n");
		return 0 ;
	}
  }

  /* Add the info for each name section */
 strcpy(att_name,"N");
 for(i=0;i<frame_def_info->nb_nm_sect;i++)
  {
    sprintf(&att_name[1],"%d",i);
    k = strlen(att_name);
 
    strcpy(&att_name[k], "from");
    if(VDSSetAttDbl(rg_coll, att_name, (double) frame_def_info->nm_sect_info[i].fr, mod) != 1) goto wrapup;
 
    strcpy(&att_name[k], "to");
    if(VDSSetAttDbl(rg_coll,att_name,(double) frame_def_info->nm_sect_info[i].to,mod) != 1) goto wrapup;
 
    strcpy(&att_name[k], "name");
    if(VDSSetAttTxt(rg_coll, att_name, frame_def_info->nm_sect_info[i].name, mod
) != 1) goto wrapup;
 
    strcpy(&att_name[k], "dorn");
    if(VDSSetAttDbl(rg_coll, att_name, (double) frame_def_info->nm_sect_info[i].dorn, mod) != 1) goto wrapup;
 
  }

 
 return 1;
 
 wrapup:
 if(mod==0) printf("Error adding name: %s\n",att_name);
 else	printf("Error modifying name: %s\n",att_name);
 return 0;
}


SMAllocFrame(frame, frame_index, nb_alloc_frame)
struct frame 	**frame;	   /* Frame info		(I/O) */
int		  frame_index;	   /* Frame index		 (I)  */
int		 *nb_alloc_frame;  /* Nb frame allocated	(I/O) */
{
#define INC 100
 
 if(frame_index >= *nb_alloc_frame)
  {
   if(*nb_alloc_frame == 0)
    {
     /* Alloc the frame structure */
     *frame = _MALLOC(INC,struct frame);
    }
   else 
    {
     /* Realloc the frame structure */
     *frame = _REALLOC( *frame, (*nb_alloc_frame+INC),struct frame);
    }
   if(*frame == NULL)
    {
     printf("Error, bad dynamic space allocation in VDAllocFrame\n");
     return 0;
    }
   *nb_alloc_frame += INC;
  }
 return 1; 
}


/*
/* SMIsFrameDef:
/*
/* Given a frame number, return the corresponding frame index
/* 
/* return 1 => success else fail.
/* */
SMIsFrameDef(frame, nb_frame, frame_number, frame_index)
struct frame 	  *frame;	 /* Frame info			 (I) */
int	      	   nb_frame;     /* Number of frame defined 	 (I) */
int	      	   frame_number; /* Frame number		 (I) */
int		  *frame_index;  /* If found, frame index	 (O) */
{
 int i;

 for(i=0;i<nb_frame;i++)
  {
   if(frame[i].number == frame_number) 
    {
     /* found */
     *frame_index = i;
     return 1;
    }
  }
 /* not found */    
 return 0;
}


/*
/* SMVerDefault:
/*
/*  Verify and set default values
/*
/*  If fail the bad_frame_index is the index where the error has been found.
/*
/*  Return 1 if success else 0.
/*
/* */

SMVerDefault(frame, nb_frame, bad_frame_number)
struct frame 	  *frame;	 /* Frame info			 (I/O) */
int	      	   nb_frame;     /* Number of frame defined 	 (I)   */
int		  *bad_frame_number; /* If fail the corresponding 
				       frame number (O)   */
{
 int i, iDummy;

  iDummy = *bad_frame_number;

  for(i=0;i<nb_frame;i++)
  {
	/*	SUNDAR for CR:179600824
    if(frame[i].rel_pos      <= NO_SPACING) 
    { 
      *bad_frame_number = frame[i].number; 
      return 0; 
    }
	*/
    if(frame[i].offset_layer <= NO_OFFSET)  frame[i].offset_layer  = 0;
   
    if(frame[i].reinf        <= NO_REINF)   frame[i].reinf 	  = 0;
  }
  return 1;
}   

/*
/* SMGetPlInfo
/* 
/*  Given the objid of the frame and the frame definition, returns the
/*  interesting parameters values for placement.
/* 
/*  Return 1 if OK else retun 0.
/* 
/* */
SMGetPlInfo(frame, frame_def, frame_number, axis, dist, size, name, 
  		 justif, props)
struct GRid	*frame;		/* Frame identifier		(I) */
struct GRid	*frame_def;	/* Frame definition identifier	(I) */
int		 frame_number;  /* Frame number to look		(I) */
char		*axis;		/* Axis				(O) */
IGRdouble		*dist;		/* Distance onlong axis		(O) */
IGRdouble		*size;		/* Size of the plane		(O) */
char		*name;		/* Text displayed 		(O) */
char		*justif;	/* Justification		(O) */
IGRuchar        *props;	        /* Reversed Normal props	(O) */
{
 int 	k;
 char 	orient[2], att_name[40], annot[16], tmp[10];
 double rev_dist, plane_size, reinf_size, reinf;
 double reverse;
 short  rev; 
 
 /* Get param from frame_def */

 if(VDSGetAttTxt(frame_def, "axis", axis) != 1) 
   {printf("axis not found\n"); return 0; }

 if(VDSGetAttTxt(frame_def, "orient", orient) != 1) 
   {printf("orient not found\n"); return 0; }

 if(VDSGetAttTxt(frame_def, "justif", justif) != 1) 
   {printf("justif not found\n"); return 0; }

 if(VDSGetAttTxt(frame_def, "annot", annot) != 1) 
   {printf("annot not found\n"); return 0; }

 if(VDSGetAttDbl(frame_def, "rev_dist", &rev_dist) != 1) 
   {printf("rev_dist not found\n"); return 0; }

 if(VDSGetAttDbl(frame_def, "plane_size", &plane_size) != 1) 
   {printf("plane_size not found\n"); return 0; }

 if(VDSGetAttDbl(frame_def, "reinf_size", &reinf_size) != 1) 
   {printf("reinf_size not found\n"); return 0; }

 /* Get parameter of the corresponding frame */
 strcpy(att_name,"F");
 sprintf(tmp,"%d",frame_number);
 strcpy(&att_name[1],tmp);
 k = strlen(att_name);

 strcpy(&att_name[k], "reinf");
 if(VDSGetAttDbl(frame, att_name, &reinf) != 1) 
   {printf("reinf not found for %s\n",att_name); return 0; }

 strcpy(&att_name[k],"abs_pos");
 if(VDSGetAttDbl(frame, att_name, dist) != 1) 
   {printf("dist not found\n"); return 0; }

 reverse = (double)FALSE;
 strcpy(&att_name[k],"reverse");
 if(VDSGetAttDbl(frame, att_name, &reverse) != 1)
   printf("Warning, reverse attributes not found\n");
     
 if(reinf == 1)
  {
   *size = reinf_size;

	#if 0
     /* Built the names */
   /* 26 July : Retrieve name position : if work it's name type */

   if(!SMGetFrmPosTxt(frame_def,*dist,name))
    {
      strcpy(&att_name[k],"name");

      if(VDSGetAttTxt(frame, att_name, name) != 1) 
       {
	 /* printf("Warning, name not found\n"); */
	 strcpy(name,annot);
	 strcat(name,tmp);
       }
    }
	#endif

	{
		struct nm_sect_info 	nm_sect_info[NB_MAX_SECTION];
		IGRint 			nb_nm_sect;
		IGRdouble		dbl, offset_dist;
		IGRchar			units[ATTR_TXT];
		IGRint			name_type;
		IGRint			kk, ii;
		IGRchar            	att_name[40];
	
		if(VDSGetAttDbl(frame_def, "nb_nm_sect", &dbl) != 1) {
                        printf("Error retrieving nb_nm_sect\n");
                        /* return 0; AD */
			dbl = 0 ;
                }
		nb_nm_sect = (int) dbl;

		strcpy(att_name,"N");
 		for(ii=0; ii<nb_nm_sect; ii++) {
    			sprintf(&att_name[1],"%d",ii);
    			kk = strlen(att_name);
 
    			strcpy(&att_name[kk], "from");
    			if(VDSGetAttDbl(frame_def, att_name, &dbl) != 1) {
				printf("Error retrieving %s\n", att_name);
				return 0;
			}
    			nm_sect_info[ii].fr = (int) dbl;
 
    			strcpy(&att_name[kk], "to");
    			if(VDSGetAttDbl(frame_def, att_name, &dbl) != 1){
				printf("Error retrieving %s\n", att_name);
                                return 0;
                        }
    			nm_sect_info[ii].to = (int) dbl;
 
    			strcpy(&att_name[kk], "name");
    			if(VDSGetAttTxt(frame_def,att_name, nm_sect_info[ii].name) != 1){
				printf("Error retrieving %s\n", att_name);
                                return 0;
                        }
    			strcpy(&att_name[kk], "dorn");
    			if(VDSGetAttDbl(frame_def, att_name, &dbl) != 1){
				printf("Error retrieving %s\n", att_name);
                                return 0;
                        }
    			nm_sect_info[ii].dorn = (int) dbl;
 
  		}

		if(VDSGetAttDbl(frame_def, "offset", &offset_dist) != 1) {
			printf("Error retrieving offset\n");
    			return 0;
       		}	
		if(VDSGetAttTxt(frame_def, "unit", units) != 1) {
                        printf("Error retrieving unit\n");
                        return 0;
                }
		if(VDSGetAttDbl(frame_def, "name_type",&dbl) != 1){
			printf("Error retrieving name_type\n");
                        return 0;
		} 
		name_type = (int)dbl;

		if ( !SMSetFrmName( 	nm_sect_info,
                        	nb_nm_sect,
                        	*dist, /* offset_dist, */
                        	frame_number,
                        	units,
                        	name_type,
				annot,
                        	name) ){
			if(!SMGetFrmPosTxt(frame_def,*dist,name))
                        {
                                strcpy(&att_name[k],"name");

                                if(VDSGetAttTxt(frame, att_name, name) != 1)
                                {
                                    /* printf("Warning, name not found\n"); */
                                    strcpy(name,annot);
                                    strcat(name,tmp);
                                }
                        }
		}		
	}
 }
 else
  {
   *size = plane_size;
   name[0] = '\0';
  }

 /* Determined if the normal sens */

  rev = (reverse == (double)TRUE) + (orient[0] == 'N') +
        ((rev_dist > NO_REV_DIST) && (*dist >= rev_dist));  

 
  if(rev % 2 == 0)  *props = 0x00;
  else              *props = EMSIS_NRML_REVERSED;

#ifdef DEBUG  
  printf("rev = %d rev % 2 = %d \n",rev,rev % 2);
#endif

 return 1;
}


/* Given a frame_number return the frame_index */

SMIsFrameSyst(frame_obj, nb_frame, frame_number, frame_index)
struct frame_obj 	*frame_obj; 	/* [I] */
IGRint			 nb_frame; 	/* [I] */
IGRint			 frame_number;  /* [I] */
IGRint			*frame_index;   /* [O] */
{
 int i;

 for(i=0;i<nb_frame;i++)
  {
   if(frame_obj[i].old_frame_number == frame_number) 
    {
     /* found */
     *frame_index = i;
     return 1;
    }
  }
 /* not found */    
 return 0;
}



/*
/*  SMGetUserName:
/*
/*  This function gets the name of the plane occurrence and determines
/*  if it is or not a user name (system name). To do it we just verify
/*  if the plane name begun with the same as the annotation.
/*
/* */

SMGetUserName(plane, annot, plane_name, user_name)
struct GRid	*plane;		/* Identifier of the plane	(I) */
char		*annot;		/* System annotation		(I) */
char		*plane_name;	/* Plane name (short name)	(O) */
int		*user_name;	/* 1 if user name else 0	(O) */
{
 int k;

 *user_name = 0;

 vd$get_name(name = plane_name, obj = plane);
 if(plane_name[0] == '\0')
  {
   /* No name ... */
   return 1;
  }
 
 k = strlen(annot);
 if(strncmp(plane_name, annot, k) != 0) *user_name = 1;

 return 1;
}

/* Recompute the name of an existing frame */
/* If the name of the occurrence is user defined we don't touch it, */
/* else we compute it */

SMRecomputeFrName(frame,annot,frame_number,frame_name)
struct GRid *frame;       /* [I] The grid of the frame */
IGRchar *annot;           /* [I] annotation of the frame system */
IGRint frame_number;     /*  [I] The number of the frame */
IGRchar *frame_name;     /*  [O] The frame name */
{
  IGRchar	plane_name[80];
  int           user_name;
			
  plane_name[0] = '\0';
  user_name     = 0;

  if(SMGetUserName(frame, annot, plane_name, &user_name) != 1)
    printf("Warning, error getting the name of plane for frame %d\n",frame_number);
     
  if(user_name == 1 && plane_name[0] != '\0')
   {
     /* User defined name */
     strcpy(frame_name, plane_name);
   }
  else
   {
     /* Define the new name */
     sprintf(frame_name,"%s%d",annot,frame_number);
   }
  
   return 1;
}   

/*
/* SMRemFrmSyst:
/*
/* Remove from the frame system stucture the deleted frames and fill
/* the status which defined the kind of operation to do on a particular
/* frame (delete, compute, change name, ....).
/*
/* It also modify the frame def and frame info structure
/* It also modify the lowest and highest frame number but the nb_frame 
/* is not modify because we need to process all the frames (even the 
/* deleted ones.
/*
/* */

static int SMRemFrmSyst(frame_def_info, nb_frame,
			 frame, lowest_frame, highest_frame,
			 nb_del_frame, frame_list, bad_frame, glob_frame_obj)
struct frame_def 	*frame_def_info;
IGRint		 	*nb_frame;
struct frame	 	**frame;
IGRint		 	*lowest_frame, *highest_frame, nb_del_frame;
struct GRid		*frame_list;
IGRint			*bad_frame;
struct glob_frame_obj 	*glob_frame_obj;
{
 IGRint 	fr_nb;
 IGRint		fr_syst_index, frame_index;
 IGRint  	mod, n_mod, p_mod;
 IGRint		i, new_nb_frame, n_lowest_frame, n_highest_frame;
 IGRlong	sts;
 struct GRid    new_frame_info;

 *bad_frame = 0;

 /* Set the status delete to the frame to delete */
 mod = 0; /* Number of frame already deleted */
 for(fr_nb = *lowest_frame; fr_nb <=  *highest_frame; fr_nb++)
  {
   if(SMIsFrameSyst(glob_frame_obj->frame_obj, *nb_frame, fr_nb, &fr_syst_index) != 1)
    {
     *bad_frame = fr_nb;
     return 0;
    }
   
   glob_frame_obj->frame_obj[fr_syst_index].status = 0;
   if(mod == nb_del_frame) continue;

   for(i=0;i<nb_del_frame;i++)
    {
     if((glob_frame_obj->frame_obj[fr_syst_index].frame.objid == frame_list[i].objid) &&
        (glob_frame_obj->frame_obj[fr_syst_index].frame.osnum == frame_list[i].osnum))
      {
       /* This frame has to be deleted */
       glob_frame_obj->frame_obj[fr_syst_index].status = DEL_FRAME;
       frame_list[i].objid = NULL_OBJID;
       mod ++;
       break;
      }
    }
  } /* end  for(fr_nb = *lowest_frame; fr_nb <=  *highest_frame; fr_nb++) */

 if(mod != nb_del_frame) 
  { 
   printf("Warning, %d frame to delete, only %d found\n", nb_del_frame, mod); 
   for(i=0;i<nb_del_frame;i++)
    { 
     if(frame_list[i].objid == NULL_OBJID) continue;
     printf("Frame object not deleted: %d, %d\n",frame_list[i].objid,frame_list[i].osnum);
     /* Should get the frame number and return it in bad_frame .... */
     break;
    }
   /* return 0; */
  }

 /* Second loop to set the status and ... */
 /* It is possible to do it in one loop, but it is fast enought doing it
 /* using two loops and it will be simpler to maintain and debug ....
 /* (don't forget that the list of the frames to delete is not ordered) 
 /*
 /* The frame and frame def structure will also be updated 
 /* */

 mod   = 0;
 n_mod = 0;
 p_mod = 0;
 /* For the negative frame number */
 for(fr_nb = -1; fr_nb >= *lowest_frame; fr_nb--)
  {
   if(SMIsFrameSyst(glob_frame_obj->frame_obj, *nb_frame, fr_nb, &fr_syst_index) != 1)
    {
     *bad_frame = fr_nb;
     return 0;
    }

   if(glob_frame_obj->frame_obj[fr_syst_index].status & DEL_FRAME)
    {
     mod++;
     n_mod++;
     continue;     
    }

   if(n_mod == 0)
    {
     /* Nothing has changed */
     glob_frame_obj->frame_obj[fr_syst_index].status = 0;
     glob_frame_obj->frame_obj[fr_syst_index].new_frame_number = 
	  glob_frame_obj->frame_obj[fr_syst_index].old_frame_number;
    }
   else 
    {
     /* some frames (mod) have been deleted */

     glob_frame_obj->frame_obj[fr_syst_index].new_frame_number = 
	    glob_frame_obj->frame_obj[fr_syst_index].old_frame_number + n_mod;

     glob_frame_obj->frame_obj[fr_syst_index].status = MOD_FRAME | COMP_FRAME |
     						       NAME_FRAME;
    }
  } /* end  for(fr_nb = 0; fr_nb <=  *lowest_frame; fr_nb++) */

 /* For the positive frame number */
 for(fr_nb = 0; fr_nb <=  *highest_frame; fr_nb++)
  {
   if(SMIsFrameSyst(glob_frame_obj->frame_obj, *nb_frame, fr_nb, &fr_syst_index) != 1)
    {
     *bad_frame = fr_nb;
     return 0;
    }

   if(glob_frame_obj->frame_obj[fr_syst_index].status & DEL_FRAME)
    {
     mod++;
     if(fr_nb > 0) p_mod++;
     else
      {
       /* delete the frame 0, I dream */
       *bad_frame = 0;
       return 0;
      }
     continue;     
    }

   if(p_mod == 0)
    {
     /* Nothing has changed */
     glob_frame_obj->frame_obj[fr_syst_index].status = 0;
     glob_frame_obj->frame_obj[fr_syst_index].new_frame_number = 
	  glob_frame_obj->frame_obj[fr_syst_index].old_frame_number;
    }
   else 
    {
     /* some frames (mod) have been deleted */

     glob_frame_obj->frame_obj[fr_syst_index].new_frame_number = 
	    glob_frame_obj->frame_obj[fr_syst_index].old_frame_number - p_mod;


     glob_frame_obj->frame_obj[fr_syst_index].status = MOD_FRAME | COMP_FRAME |
     						       NAME_FRAME;
    }
  } /* end  for(fr_nb = 0; fr_nb <=  *highest_frame; fr_nb++) */

 /* Update the name if new frame number and find the new lowest and highest
 /* frame number.
 /* */
 n_lowest_frame  = 0;
 n_highest_frame = 0;
 for(i=0;i<*nb_frame;i++)
  {
   if(glob_frame_obj->frame_obj[i].status & DEL_FRAME) continue;
   
   /* IMPORTANT : For now we invariably compute the name */
   /* because we attach all frames to owner */

   SMRecomputeFrName(&glob_frame_obj->frame_obj[i].frame,
		      frame_def_info->main_info.annot,
		      glob_frame_obj->frame_obj[i].new_frame_number,
		      glob_frame_obj->frame_obj[i].frame_name);
   
   /* Set up the new lowest & highet frame number */
   if(n_lowest_frame >   glob_frame_obj->frame_obj[i].new_frame_number)
        n_lowest_frame  = glob_frame_obj->frame_obj[i].new_frame_number;
   if(n_highest_frame <  glob_frame_obj->frame_obj[i].new_frame_number)
        n_highest_frame = glob_frame_obj->frame_obj[i].new_frame_number;
  }
 new_nb_frame = *nb_frame - mod;
 
 /* Update the frame def section with new lowest and highest frame number */
 /* May be a problem if we have to remove a full section */
 for(i=0;i<frame_def_info->nb_sect;i++)
  {
   if(frame_def_info->sect_info[i].fr < n_lowest_frame)
    {
     frame_def_info->sect_info[i].fr = n_lowest_frame;
     /* Test if the section has to be removed */
     if(frame_def_info->sect_info[i].to < n_lowest_frame)
      {
       /* Just dummy section */
       frame_def_info->sect_info[i].to = n_lowest_frame;
      }
    }
   if(frame_def_info->sect_info[i].to > n_highest_frame)
    {
     frame_def_info->sect_info[i].to = n_highest_frame;
     /* Test if the section has to be removed */
     if(frame_def_info->sect_info[i].fr > n_highest_frame)
      {
       /* Just dummy section */
       frame_def_info->sect_info[i].fr = n_highest_frame;
      }
    }
  }

 /* From the frame def info structure, recreate the frame structure */
 /* Free the old frame info structure */
 _FREE(*frame); 
 if(SMSetFrame(frame_def_info, &new_nb_frame, frame, lowest_frame, highest_frame, bad_frame) != 1)
  {
   /* Impossible to recreate the frame info structure */
   return 0;
  }

 if(*lowest_frame  != n_lowest_frame)  {*bad_frame = n_lowest_frame;  return 0;}
 if(*highest_frame != n_highest_frame) {*bad_frame = n_highest_frame; return 0;}

 if(*nb_frame != new_nb_frame + mod)
  {
   printf("Warning, the number of frames does not match the computed one\n");
  }

 /* We have the old frame info and the new frame info structure. There are
 /* some info to retrieve from the old one and put to the new one.
 /* It is the name (only if the name is user defined)
 /* Remenber thet The key of the glob_frame_obj is the old frame name
 /* */ 

 for(i=0;i<*nb_frame;i++)
  { 
   if(!(glob_frame_obj->frame_obj[i].status &  MOD_FRAME)) continue;
   if(SMIsFrameDef(*frame, new_nb_frame, glob_frame_obj->frame_obj[i].new_frame_number, &frame_index) != 1)
    {
     *bad_frame = glob_frame_obj->frame_obj[i].old_frame_number;
     return 0;
    }

   strcpy((*frame)[frame_index].name,glob_frame_obj->frame_obj[i].frame_name);
  }
 


 /* Recreate the collections*/

 /* Only update frame def collection */
 if(SMCrtFrmDefCol(frame_def_info, &glob_frame_obj->frame_def, 1) != 1)
  {
   printf("Error, cannot update the frame def rg collection\n");
   return 0;
  }

 /* create a new frame collection */
 
   if(SMCrtFrmCol(*frame, new_nb_frame, *lowest_frame, *highest_frame,
        	&new_frame_info, 0) != 1)
    {
     printf("Error, cannot update the frame info rg collection\n");
     return 0;
    }
   /* Change root */
   for(i=0; i<*nb_frame; i++)
    {
     if(glob_frame_obj->frame_obj[i].status & DEL_FRAME) continue;

     sts = om$send(msg = message NDnode.NDchange_connect
	           (1,&glob_frame_obj->frame_info, &new_frame_info),
		   senderid = NULL_OBJID,
		   targetid = glob_frame_obj->frame_obj[i].frame.objid,
		   targetos = glob_frame_obj->frame_obj[i].frame.osnum); 
     if(!(sts&1)) 
      {
       printf("Cannot change the frame for the frame: %d\n",glob_frame_obj->frame_obj[i].new_frame_number);
       *bad_frame = glob_frame_obj->frame_obj[i].new_frame_number;
       return 0;
      }
    } 
   glob_frame_obj->frame_info = new_frame_info;
   /* Delete the old one */
  
 return 1;
}

/*
/* SMRemFrame
/*
/*  Given the frame definition info and a list of frame to delete,
/*  recompute the frame system.
/*
/*  The dependency will be moved and updated. Only the modified frames
/*  will be recomputed.
/*
/*
/*  Return 1 if ok else 0. When it fails the frame number where and error
/*  has been detected is returned by bad_frame.
/*
/* */
SMRemFrame(owner,cs, frame_def_obj, frame_obj, frame_def_info,
	   nb_del_frame, frame_list, bad_frame)
struct GRid      *owner;                /* Owner of the frame system(I) */
struct GRid	 *cs;			/* Identified of the cs or plane (I)  */
struct GRid	 *frame_def_obj;	/* Identified of the frame def  (I/O) */
struct GRid	 *frame_obj;		/* Identified of the frame info (I/O) */
struct frame_def *frame_def_info;	/* Existing frame def info	(I)   */
IGRint		  nb_del_frame;		/* Number of frames to delete   (I)   */
struct GRid	 *frame_list;		/* List of frames to delete	(I)   */
IGRint		 *bad_frame;		/* If fail, bad frame number 	(O)   */
{
 int 		lowest_frame, highest_frame;
 struct frame  *frame;
 int	 	nb_frame;
 struct	glob_frame_obj glob_frame_obj;

 *bad_frame = 0;

 if(nb_del_frame < 1) return 1;

 if(SMSetFrame(frame_def_info, &nb_frame, &frame, &lowest_frame, 
 	       &highest_frame, bad_frame) != 1)
   {
    printf("Cannot retieve the existing frame structure\n");
    return 0;
   }

 if(SMGetFrmSyst(owner,cs, frame_def_obj, frame_obj,
		  nb_frame, &glob_frame_obj) != 1)
  {
   printf("Error, cannot retrieve the frame system objects\n");
   return 0;
  }

 /* Remove from the frame system structure */
 if(SMRemFrmSyst(frame_def_info, &nb_frame, &frame, &lowest_frame, 
 	         &highest_frame, nb_del_frame, frame_list, bad_frame, 
		 &glob_frame_obj) != 1)
   {
    printf("Cannot create the frame objects\n");
    return 0;
   }

 if(SMUpdFrame(owner,cs,nb_frame, frame,&glob_frame_obj,TRUE,bad_frame) != 1)
  {
    printf("Cannot update the frame system\n");
    return 0;
  }

 *frame_def_obj = glob_frame_obj.frame_def;
 *frame_obj     = glob_frame_obj.frame_info;

 /* Free the frame_obj structure */
 _FREE(glob_frame_obj.frame_obj);

 if(nb_frame != 0) _FREE(frame);

 return 1;
}

/*
/* SMAdFrmsyst:
/*
/* Add to the frame system stucture the new frames and fill
/* the status which defined the kind of operation to do on a particular
/* frame (delete, compute, change name, ....).
/*
/* A positive number for a new frame is introduced at the good place 
/* The greater frame are moved right
/* EX : 2 in 0 1 2 3 ==> 0 -> 0 : 1 -> 1 : New 2 : 2 -> 3 : 3 -> 4
/*
/* A negative number for a new frame is introduced at the good place 
/* The lowest frame  are moved left
/* Ex : -2 in -3 -2 -1 0 ==> -3 -> -4 : -2 -> -3 : New -2 : -1 -> -1 : 0 -> 0 
/* 
/* It also modify the frame def and frame info structure
/* It also modify the lowest , highest frame number and  nb_frame . 
/*
/* It is permit two have the same number more than one time in the frame list
/* In this case, two consecutive frame will be add  
/*
/* */

static int SMAdFrmsyst( frame_def_info, nb_frame,
			frame, lowest_frame, highest_frame,
			nb_add_frame, frame_list, bad_frame, glob_frame_obj)
struct frame_def 	*frame_def_info;
IGRint		 	*nb_frame;
struct frame	 	**frame;
IGRint		 	*lowest_frame, *highest_frame, nb_add_frame;
IGRint			*frame_list;
IGRint			*bad_frame;
struct glob_frame_obj 	*glob_frame_obj;
{
	IGRint		fr_nb,
			fr_syst_index,
			frame_index,
			new_fr_index,
			mod, n_mod, p_mod,
			i, new_nb_frame, n_lowest_frame, n_highest_frame;
	IGRlong		sts;
	struct	GRid	new_frame_info;
	int		SMfrm_comp_increase();

	SetProc( SMAdFrmsyst ); Begin
  
	*bad_frame = 0;

	__DBGpr_int(" nb_add_frame ", nb_add_frame );
	__DBGpr_int(" lowest_frame ", *lowest_frame );
	__DBGpr_int(" highst_frame ", *highest_frame );
	/*
	 * Realloc of glob_frame_obj->frame_obj 
	 * This allow to add the new created frame info
	 */
	/*
	 * HF 05/10/96	: TR's 179600757 & 179601535
	 *		: increase _REALLOC by 1
	 *
	 *	(*nb_frame+nb_add_frame) ==>> (*nb_frame+nb_add_frame+1)
	 *
	 * because otherwise "new_fr_index++;" will cause
	 * assignment at this index to be BEYOND allocated memory !!!
	 */
	glob_frame_obj->frame_obj = _REALLOC(	glob_frame_obj->frame_obj,
						(*nb_frame+nb_add_frame+1),
						struct frame_obj );
	if( glob_frame_obj->frame_obj == NULL ){
	  printf("Error, bad dynamic space allocation\n");
	  return 0;
	}

	__DBGpr_int(" TOTAL SIZE ", *nb_frame+nb_add_frame );
  
	new_fr_index = (*highest_frame - *lowest_frame) + 1;
	glob_frame_obj->frame_obj[new_fr_index].status = 0;
	n_lowest_frame = *lowest_frame;
	n_highest_frame = *highest_frame;
  
	mod   = 0;
	n_mod = 0;
	p_mod = 0;
  
	/* Algorithm is valid only with a sort list */
	qsort(	(char *)frame_list,
		nb_add_frame,
		sizeof(IGRint),
		SMfrm_comp_increase );
  
	/*
	 * First the new negative frame.
	 * We considered the list in decreasing order.
	 */
  for(i = nb_add_frame -1 ; i >= 0 ; i--)
  {
     /* n_mod represent how many elements have been introduce before
	the current , so the new frame number is update with n_mod */
     if(frame_list[i] > 0) continue;
     if(frame_list[i] == 0) {
       *bad_frame = 0;
       printf("Warning, can't add frame 0");
     }
     
     if(*lowest_frame > frame_list[i])
      {
        /* Add new lowest frame */
	mod++;
	n_mod++;
	glob_frame_obj->frame_obj[new_fr_index].new_frame_number =
          glob_frame_obj->frame_obj[new_fr_index].old_frame_number =
            n_lowest_frame - n_mod;
	glob_frame_obj->frame_obj[new_fr_index].status = CRT_FRAME;
	new_fr_index++;
	glob_frame_obj->frame_obj[new_fr_index].status = 0;
      }
     else
      { 
        /* Add a negative frame */
        mod++;
        glob_frame_obj->frame_obj[new_fr_index].new_frame_number =
	  glob_frame_obj->frame_obj[new_fr_index].old_frame_number = 
	    frame_list[i] - n_mod;
        glob_frame_obj->frame_obj[new_fr_index].status = CRT_FRAME;
        new_fr_index++;
        n_mod++;
        glob_frame_obj->frame_obj[new_fr_index].status = 0; 
      }
  }
  
  /* Now we update the old negative frame */

  __DBGpr_int(" lowest_frame ", *lowest_frame );

  for(fr_nb = *lowest_frame ; fr_nb <= -1; fr_nb++)
  {
    if(	SMIsFrameSyst(	glob_frame_obj->frame_obj,
			*nb_frame,
			fr_nb, &fr_syst_index) != 1 ){
	*bad_frame = fr_nb;
	return 0;
    }
    n_mod = 0;

    __DBGpr_int(" FrmSyst Index ", fr_syst_index );

    /* How many negative new frame have highest number as the current frame */

    for(i=0;i<nb_add_frame;i++)
    {
      if(frame_list[i] > 0) break;
      else 
        if(frame_list[i] >= glob_frame_obj->frame_obj[fr_syst_index].old_frame_number)
	    n_mod++;  
    }
    /*
     * The new frame number is simply the old one minus the number of
     * frame wich are inferior
     */
    glob_frame_obj->frame_obj[fr_syst_index].new_frame_number = 
       glob_frame_obj->frame_obj[fr_syst_index].old_frame_number - n_mod;  
    if(n_mod != 0 || frame_list[0] < 0)
       glob_frame_obj->frame_obj[fr_syst_index].status =
	 MOD_FRAME | COMP_FRAME | NAME_FRAME;
  }
  
  /* Now the same algorithm for positive number */
  for(i = 0 ; i < nb_add_frame ; i++)
  {
    /*
     * p_mod represent how many element have been introduce before
     * the current , so the new frame number is update with p_mod
     */
    if( frame_list[i] <= 0) continue;

    __DBGpr_int(" Add new highest frame ", new_fr_index );

    if( *highest_frame < frame_list[i] ){

	mod++;
	p_mod++;       
	glob_frame_obj->frame_obj[new_fr_index].new_frame_number =
          glob_frame_obj->frame_obj[new_fr_index].old_frame_number =
            n_highest_frame + p_mod;
	glob_frame_obj->frame_obj[new_fr_index].status = CRT_FRAME;
	new_fr_index++;
	glob_frame_obj->frame_obj[new_fr_index].status = 0;
     }
     else{

	mod++;
	glob_frame_obj->frame_obj[new_fr_index].new_frame_number =
	  glob_frame_obj->frame_obj[new_fr_index].old_frame_number = 
	    frame_list[i] + p_mod;
        p_mod++;
        glob_frame_obj->frame_obj[new_fr_index].status = CRT_FRAME;
        new_fr_index++;
        glob_frame_obj->frame_obj[new_fr_index].status = 0; 
     }
     __DBGpr_int(" After new highest frame ", new_fr_index );
  }
  
  /* Now we update the old positive frame */
  for(fr_nb = 0; fr_nb <=  *highest_frame; fr_nb++)
  {
    if(	SMIsFrameSyst(	glob_frame_obj->frame_obj,
			*nb_frame, fr_nb, &fr_syst_index) != 1 ){
	*bad_frame = fr_nb;
	return 0;
    }
    p_mod = 0;
     
    /* How many positive new frame have lowest number as the current frame */
    for(i=0;i<nb_add_frame;i++){

      if(frame_list[i] < 0) continue;
      else 
        if(frame_list[i] <= glob_frame_obj->frame_obj[fr_syst_index].old_frame_number)
	    p_mod++;  
    }
     
    /*
     * The new frame number is simply the old one plus the number of
     *  frame wich are inferior
     */
    glob_frame_obj->frame_obj[fr_syst_index].new_frame_number = 
       glob_frame_obj->frame_obj[fr_syst_index].old_frame_number + p_mod;  
    if(p_mod != 0 || frame_list[0] < 0)
       glob_frame_obj->frame_obj[fr_syst_index].status =
	 MOD_FRAME | COMP_FRAME | NAME_FRAME;
  }
  
  *nb_frame = *nb_frame + mod;
  
#ifdef	vdsDEBUG
  for( i=0; i<*nb_frame ; i++ ){

    printf("Frame_obj %d : old_number = %d new_number %d frame_status = %x\n",
		i,
		glob_frame_obj->frame_obj[i].old_frame_number,
		glob_frame_obj->frame_obj[i].new_frame_number,
		glob_frame_obj->frame_obj[i].status );
  } 

#endif
  
  /* Update the name if new frame number */
  n_lowest_frame  = 9999;
  n_highest_frame = -9999;
  for(i=0;i<*nb_frame;i++)
  {
     /* For now we invariably compute the name because we recreate all names */
     /* If the name of the occurrence is user defined we don't touch it, */
     /* else we compute it */

     SMRecomputeFrName(&glob_frame_obj->frame_obj[i].frame,
			frame_def_info->main_info.annot,
			glob_frame_obj->frame_obj[i].new_frame_number,
			glob_frame_obj->frame_obj[i].frame_name);

     
     /* Set up the new lowest & highet frame number */
     if(n_lowest_frame >    glob_frame_obj->frame_obj[i].new_frame_number)
       n_lowest_frame  = glob_frame_obj->frame_obj[i].new_frame_number;
     if(n_highest_frame <   glob_frame_obj->frame_obj[i].new_frame_number)
       n_highest_frame = glob_frame_obj->frame_obj[i].new_frame_number;
  }

  new_nb_frame = *nb_frame;
  
  /*
   * Update the frame def section with new lowest and highest frame number
   * We must extend some section definitions 
   * We are just going to extend the minus lowest section and highest section.
   */
    
  /* Update all section which have minus or highest number */
  if( n_lowest_frame < *lowest_frame || n_highest_frame > *highest_frame )
    for(i = 0; i < frame_def_info->nb_sect; i++)
     {
       if(frame_def_info->sect_info[i].fr == *lowest_frame)
	 frame_def_info->sect_info[i].fr = n_lowest_frame;
       if(frame_def_info->sect_info[i].to == *highest_frame)
	 frame_def_info->sect_info[i].to = n_highest_frame;
     }       
  
  /* From the frame def info structure, recreate the frame structure */
  /* Free the old frame info structure */

  _FREE(*frame); 
  *frame = NULL ;

  if(	SMSetFrame(	frame_def_info,
			&new_nb_frame,
			frame,
			lowest_frame,
			highest_frame, bad_frame) != 1 ){
     /* Impossible to recreate the frame info structure */
     return 0;
  }
  
  if( *lowest_frame != n_lowest_frame ){
	*bad_frame = n_lowest_frame;  return 0;
  }
  if( *highest_frame != n_highest_frame ){
	*bad_frame = n_highest_frame; return 0;
  }
  
  if(*nb_frame != new_nb_frame)
    printf("Warning, the number of frames does not match the computed one\n");
    
  /* We have the old frame info and the new frame info structure. There are  */
  /* some info to retrieve from the old one and put to the new one.          */
  /* It is the name (only if the name is user defined)                       */
  /* Remenber that the key of the glob_frame_obj is the old frame name       */
	
  for(i=0;i<*nb_frame;i++)
  { 
     if(!(glob_frame_obj->frame_obj[i].status == MOD_FRAME)) continue;
		
     if(SMIsFrameDef(*frame, new_nb_frame, glob_frame_obj->frame_obj[i].new_frame_number, &frame_index) != 1)
      {
	*bad_frame = glob_frame_obj->frame_obj[i].old_frame_number;
	return 0;
      }
     
     strcpy(	(*frame)[frame_index].name,
		glob_frame_obj->frame_obj[i].frame_name );
  }
  
  /* Recreate the collections*/
  
  /* Only update frame def collection */
  if(SMCrtFrmDefCol(frame_def_info, &glob_frame_obj->frame_def, 1) != 1)
   {
     printf("Error, cannot update the frame def rg collection\n");
     return 0;
   }
  
  /* create a new frame collection */
  
  if(SMCrtFrmCol(*frame, new_nb_frame, *lowest_frame, *highest_frame,
		 &new_frame_info, 0) != 1)
   {
     printf("Error, cannot update the frame info rg collection\n");
     return 0;
   }

   __DBGpr_com(" Change root ");

   for(i=0; i<*nb_frame; i++)
   {
      if(glob_frame_obj->frame_obj[i].status & CRT_FRAME) continue;
     
      sts = om$send(msg = message NDnode.NDchange_connect
		   (1,&glob_frame_obj->frame_info, &new_frame_info),
		   senderid = NULL_OBJID,
		   targetid = glob_frame_obj->frame_obj[i].frame.objid,
		   targetos = glob_frame_obj->frame_obj[i].frame.osnum); 
      if(!(sts&1)) 
      {
	printf("Cannot change the frame for the frame: %d\n",glob_frame_obj->frame_obj[i].new_frame_number);
	*bad_frame = glob_frame_obj->frame_obj[i].new_frame_number;
	return 0;
      }
   } 

   __DBGpr_com(" SET STRUCTURE " );
   glob_frame_obj->frame_info = new_frame_info;

   /* Delete the old one */
  
  End
  return 1;
}

/*
/* SMAdFrame
/*
/*  Given the frame definition info and a list of frame number to add,
/*  recompute the frame system.
/*
/*  The dependency will be moved and updated. Only the modified frames
/*  will be recomputed.
/*
/*
/*  Return 1 if ok else 0. When it fails the frame number where and error
/*  has been detected is returned by bad_frame.
/*
/* */
SMAdFrame(owner,cs, frame_def_obj, frame_obj, frame_def_info,
	  nb_add_frame, frame_list, bad_frame)
struct GRid      *owner;                /* Owner of the frame system(I) */
struct GRid	 *cs;			/* Identified of the cs or plane (I)  */
struct GRid	 *frame_def_obj;	/* Identified of the frame def  (I/O) */
struct GRid	 *frame_obj;		/* Identified of the frame info (I/O) */
struct frame_def *frame_def_info;	/* Existing frame def info	(I)   */
IGRint		  nb_add_frame;		/* Number of frames to delete   (I)   */
IGRint		 *frame_list;		/* List of frames number to add	(I)   */
IGRint		 *bad_frame;		/* If fail, bad frame number 	(O)   */
{
	int 		lowest_frame, highest_frame;
	int	 	nb_frame;
	struct	frame		*frame;
	struct	glob_frame_obj	glob_frame_obj;
	IGRint		okay = FALSE ;

  SetProc( SMAdFrame ); Begin

  *bad_frame	= 0;
  frame		= NULL ;
  nb_frame 	= 0 ;
  glob_frame_obj.frame_obj 	= NULL ;

  if( nb_add_frame < 1) return 1;

  if(	SMSetFrame(	frame_def_info, 
			&nb_frame,
			&frame,
			&lowest_frame, 
			&highest_frame, bad_frame) != 1 ){
	printf("Cannot retrieve the existing frame structure\n");
	goto wrapup ;
  }

  __DBGpr_int(" #Frames ", nb_frame );

  if(	SMGetFrmSyst(	owner,
			cs,
			frame_def_obj,
			frame_obj,
			nb_frame,
			&glob_frame_obj ) != 1 ){
	printf("Error, cannot retrieve the frame system objects\n");
	goto wrapup ;
  }

  __DBGpr_com(" Add to the frame system structure ");
  if(	SMAdFrmsyst(	frame_def_info,
			&nb_frame,
			&frame,
			&lowest_frame, 
			&highest_frame,
			nb_add_frame,
			frame_list,
			bad_frame,
			&glob_frame_obj ) != 1 ){
	printf("Cannot create the frame objects\n");
	goto wrapup ;
  }

  if(	SMUpdFrame(	owner,
			cs,
			nb_frame,
			frame,
			&glob_frame_obj,
			TRUE, bad_frame ) != 1 ){
	printf("Cannot update the frame system\n");
	goto wrapup ;
  }

  *frame_def_obj = glob_frame_obj.frame_def;
  *frame_obj     = glob_frame_obj.frame_info;

  okay = TRUE ;

wrapup:

	_FREE( glob_frame_obj.frame_obj );
	_FREE( frame );

	End
	return okay;
}

/* Jean : 26 July 93 */
/* This fonction return the frame position (converted and formated) if */
/* frame annotation is of type NAME_BY_NUMBER.                         */
/* Return 0 if cvt_pos not found (ex NAME_BY_NUMBER)                   */

SMGetFrmPosTxt(
struct GRid *frame_def,          /* [I] Frame def position           */
IGRdouble    dist,               /* [I] Distance of frame to the CS  */
IGRchar     *pos_txt             /* [O] Converted position           */
)
{
  IGRdouble      name_type,cvt_pos;
  IGRint	 cvt_int ;
  IGRchar        unit[ATTR_TXT];

  pos_txt[0] = '\0';
  cvt_int = 0;

  if(!VDSGetAttDbl(frame_def, "name_type",&name_type) ||
     name_type != NAME_BY_DIST)
    return 0;


  if(!(VDSGetAttTxt(frame_def,"unit", unit)))
   {
     OMuword  mod_osnum;
     short    flag = 0, num_defaults = 1;
     IGRlong  msg;
     
     ex$get_cur_mod (osnum=&mod_osnum);
     co$get_default_units(msg           = &msg,
			  table_name    = GRIO_DISTANCE,
			  osnum         = mod_osnum,
			  flag          = &flag,
			  num_defaults  = &num_defaults,
			  default_units = unit);
   }
  
  if(!SMfr_convert_int_unit(dist,unit,&cvt_pos))
    cvt_pos = dist;

/**
  cvt_pos = ceil(cvt_pos);
  cvt_pos *= 100;
  cvt_int = (IGRint) (cvt_pos) ;
  cvt_pos = cvt_int ;
  cvt_pos /= 100;
 **/

  sprintf(pos_txt,"%g",cvt_pos);

  return 1;
}

end implementation Root;

