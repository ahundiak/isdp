/* $Id: SMfrm_ut4.I,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */
 
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/smframe/func / SMfrm_ut4.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SMfrm_ut4.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:35  cvs
 *      Initial import to CVS
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
# Revision 1.2  1996/04/17  14:41:12  pinnacle
# Replaced: smframe/cmd/SMModNotif.I for:  by ksundar for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
	
File SMfrm_ut4.I

Abstract : 
  

	Implemented functions used for changing version of frame system 

	- Design date:  April - 92

	- Jean Jasinczuk : 
*/

class implementation Root;

#include <stdio.h>
#include "OMmacros.h"
#include "exdef.h"
#include "exmacros.h"

#include "igrtypedef.h"
#include "igrdef.h"
#include "godef.h"
#include "igr.h"
#include "igetypedef.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "parametric.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "expression.h"
#include "expmacros.h"
#include "igrdp.h"
#include "go.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "SMframe.h"


#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "SMmsg.h"
#include "VDmem.h"

#include "AS_status.h"

struct FRSel 
{
  int nb_cc;
  int size;
  struct GRid *cc;
};

#define INCR 50

/* #define DEBUG 1 */

#define EPSILON 0.00001

from NDnode		import  NDget_objects, NDchange_connect;
from GRvg		import  GRchgname, GRgetname;
from SMfrm_syst         import  ACcreate,
                                ACadd_component_with_name,
                                GRcomponent_disconnecting,
                                SMchange_component_name,
                                SMremove_component,
 				GRdelete_owner;
                    
from NDmacro    import ACreturn_foot;
from ACcpx      import find_macro, ACload_macro;
from ACcpx_defn import ACgive_name;

extern GRclassid OPP_ACrg_collect_class_id, OPP_nci_macro_class_id;
extern GRclassid OPP_SMfrm_syst_class_id,OPP_SMframe_class_id;

SMOldFillFrame(frame, frame_number, sect_info, mod)
struct frame 	  *frame;	 /* Frame info			(I/O) */
int	      	   frame_number; /* Frame number		 (I)  */
struct sect_info  *sect_info;	 /* Sect frame parameters	 (I)  */
short		   mod;		 /* If it is a modification (1)  (I)  */
{
 int fr;

 fr 	       = sect_info->fr;
 frame->number = frame_number;

 if(mod == 1)
  {
   /* Modify the data of an existing one */
   if(sect_info->spacing > NO_SPACING) frame->rel_pos = sect_info->spacing;
   if(sect_info->offset  > NO_OFFSET)  frame->offset_layer = sect_info->offset; 
   if(sect_info->reinf   > NO_REINF && sect_info->reinf > 0)   
    {
     if(((frame_number - fr) % sect_info->reinf) == 0) frame->reinf = 1;
     else 					       frame->reinf = 0;
    }
  } 
 else
  {
   /* Defined a new frame */
   frame->name[0]      = '\0';   
   frame->rel_pos      = sect_info->spacing;
   frame->abs_pos      = 0;
   frame->offset_layer = sect_info->offset;
   if(sect_info->reinf > NO_REINF && sect_info->reinf > 0)   
    {
     if(((frame_number - fr) % sect_info->reinf) == 0) frame->reinf = 1;
     else 					       frame->reinf = 0;
    }
   else frame->reinf = 0;
  }
 return 1;
}

/* 
/* SMOldSetFrame
/*
/*  Fill the structure gathering all the frames. The array of frame
/*  is allocated by the function and must be deallocated by the user.
/*
/*  Return 1 if ok else 0;
/*
/* */
SMOldSetFrame(frame_def_info, nb_frame, frame, lowest_frame, highest_frame, bad_frame)
struct frame_def       *frame_def_info;	 /* main frame def parameters	 (I) */
int		       *nb_frame;	 /* nb frames			 (O) */
struct frame          **frame;	 	 /* frame info			 (O) */
int		       *lowest_frame; 	 /* Lowest frame number		 (O) */
int		       *highest_frame;   /* highest frame number	 (O) */
int		       *bad_frame;       /* Frame number where it fails  (O) */ 
{
 int	nb_alloc_frame;
 int	i, j, k;

 
 nb_alloc_frame = 0;
 *nb_frame 	= 0;
 *bad_frame	= 0;
 /* Loop for all the sections */
 for(i=0;i<frame_def_info->nb_sect;i++)
  {
   /* Loop for all the frames defined for one section */
   for(j=frame_def_info->sect_info[i].fr;j<=frame_def_info->sect_info[i].to;j++)
    {
     if(SMIsFrameDef(*frame, *nb_frame, j, &k) == 1)
      {
       /* The frame has already been defined */
       if(SMOldFillFrame(&((*frame)[k]), j, &frame_def_info->sect_info[i],  1) != 1)
	{
	 printf("Error for the frame number: %d\n", j);
         *bad_frame = j;
	 return 0;
	}
      }
     else
      {
       /* First def for the frame */
       if(SMAllocFrame(frame, *nb_frame, &nb_alloc_frame) != 1)
        {
	 return 0;
	}

       if(SMOldFillFrame(&((*frame)[*nb_frame]), j, &frame_def_info->sect_info[i], 0) != 1)
        {
	 printf("Error for the frame number: %d\n", j);
         *bad_frame = j;
	 return 0;
	}
       *nb_frame = *nb_frame + 1;
      }
    } /* End  Loop for all the frames defined for one section */
  } /* End Loop for all the sections */
 /* Verify and set the NO_OFFSET, NO_REINF, NO_SPACING */
 if(SMVerDefault(*frame, *nb_frame, &k) != 1)
  {
   printf("Error, Bad spacing definition from the frame number: %d\n", k);
   *bad_frame = k;
   return 0;
  }

 /* Compute the frame */
 if(SMCompFrame(*frame, *nb_frame, &(frame_def_info->main_info), 
 		 lowest_frame, highest_frame, &k) != 1)
  {
   printf("Error, Bad definition from the frame number: %d\n",k);
   *bad_frame = k;
   return 0;
  }

 return 1;

}

/* Recreate the sections for the new version */
/* We based on the frame and create section when spacing change */

SMOldCreateSect(frame,nb_frame,lowest_frame,highest_frame,sect_info,nb_sect)
struct frame   frame[];	       /* [I] Frame array  */
IGRint	       nb_frame;       /* [I] Number of frames   */
IGRint         lowest_frame;   /* [I] Number of the lowest  frame */
IGRint         highest_frame;  /* [I] Number of the highest frame */
struct sect_info sect_info[];  /* [O] Sections created by the frames */
IGRint 	       *nb_sect;       /* [O] Number of created section */
{
  IGRint cur_sect = 0;
  IGRint fr_num;
  IGRdouble cur_spacing = 0.0,prec_spacing = 0.0;
  IGRint fr_index,prec_fr_index = 0;

  /* We consider spacing between two consecutive frame. When spacing is */
  /* constant, we go further. When spacing change, we create a new section. */

  for(fr_num=lowest_frame;fr_num<=highest_frame;fr_num++)
  {
    if(SMIsFrameDef(frame, nb_frame, fr_num, &fr_index) != 1)
     {
       printf("The frame number: %d has not been defined\n", fr_num);
       return 0;
     }
    if(fr_num == lowest_frame)
     {
        sect_info[cur_sect].fr = lowest_frame;
	sect_info[cur_sect].offset  = frame[fr_index].offset_layer;
	sect_info[cur_sect].reinf   = NO_REINF;
	prec_fr_index = fr_index;
	prec_spacing = -9999;
	continue;
      }

    if(fr_num == highest_frame)
     {
       sect_info[cur_sect].to = fr_num;
       sect_info[cur_sect].spacing = cur_spacing;
       *nb_sect = cur_sect + 1;
       break;
     }

    if(fr_num > lowest_frame)
     {
       cur_spacing = frame[fr_index].abs_pos - frame[prec_fr_index].abs_pos;
       if(cur_spacing == prec_spacing || prec_spacing == -9999)
	{
	  prec_fr_index = fr_index;
	  prec_spacing  = cur_spacing;
	  continue;
	}

       /* Spacing change, so a new section must be create */ 
       sect_info[cur_sect].to = frame[prec_fr_index].number;
       sect_info[cur_sect].spacing = prec_spacing;
       /* Now create a new section */
       cur_sect++;
       if(cur_sect >= NB_MAX_SECTION)
	{
	  printf("Too much section\n");
	  return 0;
	}
       sect_info[cur_sect].fr = frame[prec_fr_index].number;
       sect_info[cur_sect].offset  = frame[fr_index].offset_layer;
       sect_info[cur_sect].reinf   = NO_REINF;
       prec_spacing = cur_spacing;
       prec_fr_index = fr_index;
     }
   
  }

#ifdef DEBUG
  printf("Number of sections created : %d \n",*nb_sect);
  for(i = 0; i < *nb_sect; i++)
    printf("Sect %d : fr = %d to = %d spac = %2.3f, offset = %d\n\n", 
	   i,sect_info[i].fr,sect_info[i].to, sect_info[i].spacing,
	   sect_info[i].offset);
#endif
  return 1;

}


SMOldFindReinf(frame,nb_frame,lowest_frame,highest_frame,reinf_str)
struct frame   frame[];	       /* [I] Frame array  */
IGRint	       nb_frame;       /* [I] Number of frames   */
IGRint         lowest_frame;   /* [I] Number of the lowest  frame */
IGRint         highest_frame;  /* [I] Number of the highest frame */
char           *reinf_str;     /* [O] String defining  reinforced */
{
  int between_reinf, prec_reinf, first_reinf;
  int fr_num,fr_index;
  char tmp[80];

  between_reinf = -9999;
  prec_reinf = -9999;
  first_reinf = -9999;

  reinf_str[0] = '\0';

  /* We examine the difference (in number) between two reinforced frame. */
  /* If there is  a change, then we create an expression [first-prec,beetween]*/
  /* where "between" is the interval between reinf frame  */

  for(fr_num=lowest_frame;fr_num<=highest_frame;fr_num++)
  {
    if(SMIsFrameDef(frame, nb_frame, fr_num, &fr_index) != 1)
     {
       printf("The frame number: %d has not been defined\n", fr_num);
       return 0;
     }

    if(frame[fr_index].reinf)
     {
       if(first_reinf == -9999)       /* First reinf frame */
	{
	  first_reinf = fr_num;
	  continue;
	}
       else
	{
	  if(between_reinf == -9999)   /* It is the second reinforced frame */ 
	   {
	     prec_reinf  = fr_num;
	     between_reinf = fr_num - first_reinf;
	   }
	  else 
	   {
	     if(fr_num - prec_reinf ==  between_reinf)  /* In same section */
	       prec_reinf = fr_num;
	     else  /* Create an expression of the form [first-prec,between] */
	      {
		if(between_reinf != 1)
		  sprintf(tmp,"[%d-%d,%d],",
			  first_reinf,prec_reinf,between_reinf);
		else
		  sprintf(tmp,"[%d-%d],",first_reinf,prec_reinf);

		strcat(reinf_str,tmp);
		first_reinf = fr_num;
		between_reinf = -9999;
		prec_reinf = -9999;
	      }
	   }
	}
     }
  } /* for(fr_num) */

  /* End the reinf when quit the loop */
  if(first_reinf != -9999)
   {
     if(prec_reinf != -9999)
      {
	if(between_reinf != 1)
	  sprintf(tmp,"[%d-%d,%d]",first_reinf,prec_reinf,between_reinf);
	else
	  sprintf(tmp,"[%d-%d]",first_reinf,prec_reinf);
	strcat(reinf_str,tmp);
      }
     else
      {
	sprintf(tmp,"%d",first_reinf);
	strcat(reinf_str,tmp);
      }
   }

#ifdef DEBUG
  printf("Reinf string is %s\n",reinf_str);
#endif

  return 1;
}

/* This function is used to change version of frame system */
/* For old version , find the directory of the frame 0 */
/* retrieve glob_frame_obj, frame, nb_frame              */
/* glob_frame_obj,frame must be deallocated by user */
/* It return 0 if problem */

SMOldFindDir(cs,frame_def_obj,frame_obj,frame_def_info,
	      glob_frame_obj,frame,nb_frame,lowest_frame,highest_frame,
	      dir,new_fr_name,other_elem)
struct GRid	 *cs;			/* Identified of the cs 	(I)   */
struct GRid	 *frame_def_obj;	/* Identified of the frame def  (I)   */
struct GRid	 *frame_obj;		/* Identified of the frame info (I)   */
struct frame_def *frame_def_info;	/* Existing frame def info	(I)   */
struct glob_frame_obj *glob_frame_obj;  /* glob_frame_obj genereted     (O)   */
struct frame      **frame;              /* The frame array              (O)   */
IGRint            *nb_frame;            /* Number of existing frame     (O)   */
IGRint *lowest_frame,*highest_frame;    /*  [I] */
char 		  *dir;               /*Directory name of frame 0  */
char              *new_fr_name;      /* New name for frame system */ 
int               *other_elem;      /* TRUE if other elem in dir than frame   */
{
  IGRlong	msg,status;
  char          name[DI_PATH_MAX],plane_name[DI_PATH_MAX];
  int           fr_index;
  struct GRid   *obj;
  int           i,j;
  int		nb_lines;
  IGRint        bad_frame;
  int 		find;

  *frame = NULL;
  *nb_frame = 0;
  obj = NULL;

  if(SMOldSetFrame(frame_def_info, nb_frame, frame, lowest_frame, 
		   highest_frame, &bad_frame) != 1)
   {
     printf("Cannot retrieve the existing frame structure\n");
     return 0;
   } 

  if(SMGetFrmSyst(NULL,cs,frame_def_obj,frame_obj,
		   *nb_frame, glob_frame_obj) != 1)
   {
     printf("Error, cannot retrieve the frame system objects\n");
     goto wrapup;
   }

  if(SMIsFrameSyst(glob_frame_obj->frame_obj, *nb_frame, 0,
                    &fr_index) != 1)
    {
      printf("problem with index of frame 0\n");
      goto wrapup;
    }
 
   
  status = om$send(msg = message GRvg.GRgetname
		   (&msg,plane_name),
		   senderid = NULL_OBJID,
		   targetid = glob_frame_obj->frame_obj[fr_index].frame.objid,
		   targetos = glob_frame_obj->frame_obj[fr_index].frame.osnum);
   if(!(status & msg & 1))
    {
     printf("Error getting the name of frame 0\n");
     goto wrapup;
   }
  
  di$split(pathname = plane_name,dirname = dir);

  strcpy(name,dir);
  strcat(name,":*");
  status = di$dump(regexp = name,
		   grids  = (DIgrid **)&obj,
		   ptr    = &nb_lines);
  if(status != DIR_S_SUCCESS || nb_lines <= 0) return 0;

  /* Test if there are element which are not in the frame system */
  /* in the same directory */

  *other_elem = FALSE;
  for(i=0;i<nb_lines;i++)
   {
     switch(status) 
      {
      case DIR_S_SUCCESS:
      	find = FALSE;
      	for(j=0; j< *nb_frame; j++)
	 {
	   if(glob_frame_obj->frame_obj[j].frame.objid == obj[i].objid &&
	      glob_frame_obj->frame_obj[j].frame.osnum == obj[i].osnum)
	    {
	      find = TRUE;
	      break;
	    }
	 }
	if(!find)
	 {
#ifdef DEBUG
	   printf("Warning,directory contain other element\n");
#endif
	   *other_elem = TRUE;
	 }
	break;

      case DIR_W_NAME_NOT_FOUND :
	printf("Strange error, object %d not found\n",obj[i]);
	goto wrapup;

	default :
	  printf("Unknown error, object %d not found\n",obj[i]);
	goto wrapup;
      }
     if(*other_elem) break;
   }

  for(i=0; i < *nb_frame; i++)
   {
     if(!SMRecomputeFrName(&glob_frame_obj->frame_obj[i].frame,
			   frame_def_info->main_info.annot,
			   glob_frame_obj->frame_obj[i].old_frame_number,
			   glob_frame_obj->frame_obj[i].frame_name))
       printf("Erreur retreiving name of frame %d\n",i);
   }


  /* If other elem in directory, return the annotation as new name */
  if(*other_elem)
   {
     DIobjid tmp_id;
     int k;

     strcpy(new_fr_name,frame_def_info->main_info.annot);
     k = strlen(new_fr_name);
     new_fr_name[k] = frame_def_info->main_info.axis;
     new_fr_name[k+1] = 0;
     status = di$translate(objname = new_fr_name,
			   p_objid = &tmp_id);
     if(status&1) /* The directory already exist, find other name */
      {
	int ind;

	for(ind=0;ind<2000;ind++)
	 {
	   sprintf(&new_fr_name[k+1],"%d",ind);
	   status = di$translate(objname = new_fr_name,
				 p_objid = &tmp_id);
	   if(!(status & 1)) break;
	 }
	if(ind == 2000) goto wrapup;
      }
   }
  else strcpy(new_fr_name,dir);

  /* Free allocate mem */
  if(obj != NULL) _FREE(obj);  
  return 1;

 wrapup:
  if(obj != NULL) _FREE(obj);  
  return 0;
}  
  
  

 /* SMChangeFrmVers */
 /* Modify structure of the frame system to be compatible between version */

SMChangeFrmVers(fr_syst_name,frame_def_info,glob_frame_obj,frame,nb_frame,
		 lowest_frame,highest_frame,old_dir,destroy,owner)
char             *fr_syst_name;         /* [I] New Name for frame_system */
struct frame_def *frame_def_info;	/* [I] Existing frame def info	 */
struct glob_frame_obj *glob_frame_obj;  /* [I] Glob frame obj */
struct  frame    *frame;               /*  [I] The frame array  */
IGRint  nb_frame;                      /*  [O] Number of existing frame */
IGRint lowest_frame,highest_frame;     /*  [I] */
char   *old_dir;                       /*  [I] Old dir of frame system */
int    destroy;                        /*  [I] TRUE to delete the old dir */
struct GRid      *owner;	       /*  [O] The owner of frame system */
{
 IGRlong	 msg,status;
 struct GRmd_env mod_env;
 IGRlong 	 sizebuf, nret;
 IGRint 	 i,k;
 struct sect_info new_sect_info[NB_MAX_SECTION];
 IGRint new_nb_sect;
 struct GRid old_root[2],new_root[2];
 struct GRid   new_frame_def;
 char att_name[40];
 char macro_name[DI_PATH_MAX];
 struct GRid mac_def;

 if(!SMOldCreateSect(frame,nb_frame,lowest_frame,highest_frame,
		      new_sect_info,&new_nb_sect))
  {
    printf("can't create old section");
    goto wrapup;
  }

 if(!SMOldFindReinf(frame,nb_frame,lowest_frame,highest_frame,
		 frame_def_info->main_info.reinfstr))
  {
    printf("can't create reinf string");
    goto wrapup;
  }

 /* Frame can't be individually reverse in old version so ... */
 frame_def_info->main_info.revstr[0] = '\0';
 strcpy(att_name,"F");
 for(i = 0; i < nb_frame; i++)
  {
    frame[i].reverse = FALSE;     
    sprintf(&att_name[1],"%d",frame[i].number);
    k = strlen(att_name);
    strcpy(&att_name[k], "reverse");
    if(!VDSSetAttDbl(&glob_frame_obj->frame_info,
		     att_name,(double) frame[i].reverse,0))
      printf("Warning, can't set the reverse attributes\n");
  }

 /* The macro was VDFrPln and must be SMFrPln */
 /* Search the GRid of this macro lib */

 VDSget_filename(macro_name);
 DIstmcat(macro_name,"constructs_lib:SMmacro:constructs","SMFrPln",NULL);
 status = di$translate(objname = macro_name,
		       p_objid = &mac_def.objid, p_osnum = &mac_def.osnum); 
 if(status != OM_S_SUCCESS)
  {printf("Doesn't find macro_def %s\n",macro_name); return 0;} 

 sizebuf = sizeof(struct GRmd_env);
 gr$get_module_env(msg     = &msg,
		   sizbuf  = &sizebuf,
		   buffer  = &mod_env,
		   nret    = &nret);

 /* Delete the name of the frame from their directory */
 for(i=0; i<nb_frame;i++)
  {
    status = om$send(msg = message GRvg.GRchgname
		     (&msg,NULL,NULL),
		     senderid = NULL_OBJID,
		     targetid = glob_frame_obj->frame_obj[i].frame.objid,
		     targetos = glob_frame_obj->frame_obj[i].frame.osnum); 
    as$status(action = CONTINUE);
  
    if(!(msg & 1))
      printf("Problem remove name %s \n",
	     glob_frame_obj->frame_obj[i].frame_name);
  }
 
 if(destroy)
  {
    status = di$rmdir(dirname = old_dir);
    if(status != DIR_S_SUCCESS)
      printf("Warning, problem removing directory %s\n",old_dir);
  }

 /* Construct SMfrm_syst and put component in it */
 owner->osnum  = mod_env.md_id.osnum;
 status = om$construct(msg = message SMfrm_syst.ACcreate
		       (&msg,fr_syst_name),
		       classid = OPP_SMfrm_syst_class_id,
		       osnum   = owner->osnum,
		       p_objid = &owner->objid);

 if(!(status & 1) || (msg != MSSUCC)) 
  {
    printf("Can't create SMfrm_syst\n");
    return 0;
  }


 /* Add each frame to SMfrm_syst */
 for(i = 0; i< nb_frame; i++)
  {
    status = om$send(msg = message SMfrm_syst.ACadd_component_with_name
		     (&msg,
		      &glob_frame_obj->frame_obj[i].frame,
		      glob_frame_obj->frame_obj[i].frame_name),
		     senderid = NULL_OBJID,
		     targetid = owner->objid,
		     targetos = owner->osnum);  
     
    if(!(status & 1) || (msg != MSSUCC))
     {
       printf("error ACadd_component for frame name %s\n",
	      glob_frame_obj->frame_obj[i].frame_name);
       return 0;
     }
  }

 frame_def_info->nb_sect   = new_nb_sect;
 frame_def_info->sect_info = new_sect_info;

 /* Create a new frame def collection */

  if(SMCrtFrmDefCol(frame_def_info, &new_frame_def, 0) != 1)
   {
     printf("Error, cannot update the frame def rg collection\n");
     return 0;
   }
 
 old_root[0] = glob_frame_obj->frame_def;
 new_root[0] = new_frame_def;

 for(i = 0; i< nb_frame; i++)
  {
 
    status = om$send(msg = message ACcpx.ACload_macro(mac_def),
		     senderid = NULL_OBJID,
		     targetid = glob_frame_obj->frame_obj[i].frame.objid,
		     targetos = glob_frame_obj->frame_obj[i].frame.osnum);
    if(!(status & 1))
     {
       printf("Problem with load_macro\n");
       continue;
     }
    
    if(om$change_class(objid =  glob_frame_obj->frame_obj[i].frame.objid,
		       osnum = glob_frame_obj->frame_obj[i].frame.osnum,
		       classname = "SMframe") != OM_S_SUCCESS)
     {
       printf("Problem with change class of frame %d\n",
	      glob_frame_obj->frame_obj[i].frame.objid);     
       return 0;
     }

    status = om$send(msg = message NDnode.NDchange_connect
		  (1,old_root, new_root),
		  senderid = NULL_OBJID,
		  targetid = glob_frame_obj->frame_obj[i].frame.objid,
		  targetos = glob_frame_obj->frame_obj[i].frame.osnum);
    if(!(status&1)) 
     {
       printf("Problem with change connect\n");     
       return 0;
     }
  }

 return 1;

wrapup: 
  return 0;
}

/* #define DEBUG 1 */
/* Place the Grid of the object (if it is a frame) in the list */
/* Allocate the sel.cc field in fr_info which must be deallocated by user */

SMGiveYourId(msg,obj,f_info)
long 	*msg;
struct GRid *obj;
struct GRfunction_info	*f_info;
{
  struct GRid	macro_def;
  char *mac_name=NULL;
  int count;
  struct GRid roots[4];
  struct FRSel	*info=NULL;
  IGRlong status;

  if(SMIsKindOf(obj,OPP_SMframe_class_id))
   {
#ifdef DEBUG
     printf("Objid %d is already update \n",obj->objid);
#endif
     return 1; /* Already update */
   }

  status = om$send(msg = message ACcpx.find_macro(&macro_def),
		   senderid = NULL_OBJID,
		   targetid = obj->objid,
		   targetos = obj->osnum );
  if(status != OM_S_SUCCESS) goto notframesyst;
  
  status = om$send(msg = message ACcpx_defn.ACgive_name(&mac_name),
		   senderid = NULL_OBJID,
		   targetid = macro_def.objid,
		   targetos = macro_def.osnum );
  if(status != OM_S_SUCCESS) goto notframesyst;
  
  if(strncmp(mac_name,"VDFrPln",7) !=0 ) goto notframesyst;
  
  status = om$send(msg = message NDnode.NDget_objects
		   (ND_ROOT,roots,4,NULL,0,3,&count),
		   senderid = NULL_OBJID,
		   targetid = obj->objid,
		   targetos = obj->osnum );
  if(status != OM_S_SUCCESS || count != 4) goto notframesyst;

  info = (struct FRSel *)f_info->info;
  if(info->nb_cc + 1 >= info->size)
   {
     int size;
     size = info->size + INCR;
     if(info->size == 0)
      {
	/*"Allocation of: %d Objects\n", size */
	info->cc = _MALLOC(size,struct GRid);
      }
     else
      {
	/*"Reallocation of: %d Objects (old size: %d\n", size, info->size */
	info->cc = _REALLOC(info->cc, size,struct GRid);
      }
     if(info->cc == NULL)
      {
	printf("Error in ISvalid_cc, no memory space available\n");
	info->size  = 0;
	info->nb_cc = 0;
	*msg        = 10;
	return 0;
      }
     /*"allocated address: %u\n",info->cc */
     info->size = size;
   }

  info->cc[info->nb_cc++] = *obj;
  
  *msg  = MSSUCC;
  return OM_S_SUCCESS;

 notframesyst:
#ifdef DEBUG
  printf("Objid %d is not a frame \n",obj->objid);
#endif
  return 1;
}


/* Control it's a frame system, update it */ 
SMUpdFrmSyst(obj)
struct GRid *obj;
{
  struct GRid      roots[4];
  char             dir[DI_PATH_MAX],new_fr_name[DI_PATH_MAX];
  struct           glob_frame_obj glob_frame_obj;
  struct frame     *frame;
  IGRint           lowest_frame,highest_frame;
  int              destroy_dir,count;
  struct frame_def frame_def_info;
  struct sect_info sect_info[NB_MAX_SECTION];
  IGRint           nb_frame,other_elem;
  struct GRid      owner;
  IGRlong          status;
 
  frame = NULL;
  
  if(SMIsKindOf(obj,OPP_SMframe_class_id))
   {
#ifdef DEBUG
     printf("Objid %d is already update \n",obj->objid);
#endif
     return 1; /* Already update */
   }

  status = om$send(msg = message NDnode.NDget_objects
		   (ND_ROOT,roots,4,NULL,0,3,&count),
		   senderid = NULL_OBJID,
		   targetid = obj->objid,
		   targetos = obj->osnum );
  if(status != OM_S_SUCCESS || count != 4) return 0;
  
  glob_frame_obj.frame_obj = NULL;

  frame_def_info.sect_info = sect_info;
  if(!SMFillFrmDefInfo(&roots[2],NB_MAX_SECTION,&frame_def_info))
   {

     printf("Problem retreiving frame_def_info for frame %d\n",obj->objid);
     return 1;
   }

  if(!SMOldFindDir(&roots[0],&roots[2],&roots[3],&frame_def_info,
		   &glob_frame_obj,&frame,&nb_frame,
		   &lowest_frame,&highest_frame,
		   dir,new_fr_name,&other_elem))
   {
     printf("Problem with old frame system for frame objid %d\n",obj->objid);
     return 0;
   }

  if(!other_elem) destroy_dir = TRUE; else destroy_dir = FALSE;

  if(!SMChangeFrmVers(new_fr_name,&frame_def_info,
		      &glob_frame_obj,frame,nb_frame,
		      lowest_frame,highest_frame,dir,destroy_dir,
		      &owner))
   {
     printf("Problem Updating frame system for frame objid %d\n",obj->objid);
     return 0;
   }

#ifdef DEBUG
  printf("OK Update de frame system for frame %d \n",obj->objid);
  printf("Objid of the frame system create is %d\n",owner.objid);
#endif
  _FREE(frame);
  _FREE(glob_frame_obj.frame_obj);

  if(other_elem)
   {
     char s_name[DI_PATH_MAX];

     di$split(pathname = new_fr_name,name = s_name);
     ex$message(msgnumb = SM_I_FrNewName,
		type = "%s",var = `s_name`);
   }
  
  return 1;
}

end implementation Root;



