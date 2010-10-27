/* $Id: VDSframe_ut.I,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */
 
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/smframe/vdframe / VDSframe_ut.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDSframe_ut.I,v $
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
# Revision 1.2  1996/04/17  14:48:50  pinnacle
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
	
Abstract : 

	Implemented functions used for the frame system.

	- Design date: 20-Oct-1991.

	- Christian Heraud ISDC.
*/

    
  
class implementation Root;

#include <stdio.h>
#include <stdlib.h>
#include "OMmacros.h"
#include "exmacros.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "igrdef.h"
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
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "expression.h"
#include "expmacros.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "DImacros.h"
#include "EMSssprops.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VDSframe_def.h"
#include "vdsmacros.h"
#include "VDmem.h"

#include "AS_status.h"

/*#define DEBUG /* */

#define EPSILON 0.00001

from NDnode 		import NDchg_state, NDs_compute_node, NDget_objects;
from NDnode		import NDgive_value, NDdisplay, NDchange_connect;
from ACrg_collect	import ACadd_list_attribute, ACget_named_attribute;
from ACrg_collect	import ACmod_list_attribute;
from ci_macro		import init;
from GRvg		import GRputname, GRchglevel, GRchgname, GRgetname;
from GRgraphics		import GRchgprops;

from NDmacro import ACreturn_foot;

extern GRclassid OPP_ACrg_collect_class_id, OPP_nci_macro_class_id;
/* 
/* VDFillFrameInfo
/*
/*  Given the frame definition identifier, fill the structure gathering 
/*  the frame definition parameters. The "max_sect" is the maximun number
/*  of allocated sections.
/* 
/*  Return 1 if ok else 0;
/*
/* */
VDFillFrmDefInfo(rg_coll, max_sect, frame_def_info)
struct GRid	 *rg_coll;        /* Identifier of the coll	(I) */
int		  max_sect;	  /* Maximun number of sections (I) */ 
struct frame_def *frame_def_info; /* Main frame def parameters	(O) */
{
 IGRint		 k, i;
 IGRlong 	 sts;
 char		 att_name[40], tmp[10];
 double 	 dbl;
 
 strcpy(att_name, " ");

 /* Fill the info of nb sect_info */
 if(VDSGetAttDbl(rg_coll, "nb_sect", &dbl) != 1) goto wrapup;
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

 if(VDSGetAttTxt(rg_coll, "justif"    , frame_def_info->main_info.justif) != 1) goto wrapup;
 if(VDSGetAttTxt(rg_coll, "annot"     , frame_def_info->main_info.annot) != 1) goto wrapup;
 if(VDSGetAttDbl(rg_coll, "rev_dist"  , &frame_def_info->main_info.rev_dist) != 1) goto wrapup;
 if(VDSGetAttDbl(rg_coll, "plane_size", &frame_def_info->main_info.plane_size) != 1) goto wrapup;
 if(VDSGetAttDbl(rg_coll, "reinf_size", &frame_def_info->main_info.reinf_size) != 1) goto wrapup;
 if(VDSGetAttDbl(rg_coll, "offset"    , &frame_def_info->main_info.offset_dist) != 1) goto wrapup;
 
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
   if(VDSGetAttDbl(rg_coll, att_name, &frame_def_info->sect_info[i].spacing) != 1) goto wrapup;

   strcpy(&att_name[k], "reinf");
   if(VDSGetAttDbl(rg_coll, att_name, &dbl) != 1) goto wrapup;
   frame_def_info->sect_info[i].reinf = (int) dbl;

   strcpy(&att_name[k], "offset");
   if(VDSGetAttDbl(rg_coll, att_name, &dbl) != 1) goto wrapup;
   frame_def_info->sect_info[i].offset = (int) dbl;
  }

 return 1;

wrapup:
     printf("Error name: %s not found\n",att_name);
     return 0;
}


/* 
/* VDCrtFrmDefColl
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
VDCrtFrmDefCol(frame_def_info, rg_coll, mod)
struct frame_def *frame_def_info; /* Main frame def parameters	 (I)  */
struct GRid	 *rg_coll;        /* Identifier of the coll	(I/O) */
IGRint		  mod;		  /* 1 modify, 0 create		 (I)  */
{
 IGRint		 k, i;
 IGRlong 	 sts;
 char		 att_name[40], tmp[10];
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
 
 /* Add the info of nb sect_info */
 if(VDSSetAttDbl(rg_coll, "nb_sect", (double) frame_def_info->nb_sect, mod) != 1) goto wrapup;

 /* Add the info of main_info */
 tmp[0] = frame_def_info->main_info.axis;
 tmp[1] = '\0';
 if(VDSSetAttTxt(rg_coll, "axis", tmp, mod) != 1) goto wrapup;

 tmp[0] = frame_def_info->main_info.orient;
 tmp[1] = '\0';
 if(VDSSetAttTxt(rg_coll, "orient", tmp, mod) != 1) goto wrapup;
 if(VDSSetAttTxt(rg_coll, "justif"    , frame_def_info->main_info.justif, mod) != 1) goto wrapup;
 if(VDSSetAttTxt(rg_coll, "annot"     , frame_def_info->main_info.annot, mod) != 1) goto wrapup;
 if(VDSSetAttDbl(rg_coll, "rev_dist"  , frame_def_info->main_info.rev_dist, mod) != 1) goto wrapup;
 if(VDSSetAttDbl(rg_coll, "plane_size", frame_def_info->main_info.plane_size, mod) != 1) goto wrapup;
 if(VDSSetAttDbl(rg_coll, "reinf_size", frame_def_info->main_info.reinf_size, mod) != 1) goto wrapup;
 if(VDSSetAttDbl(rg_coll, "offset"    , frame_def_info->main_info.offset_dist, mod) != 1) goto wrapup;
 
 /* Add the info for each section */
 strcpy(att_name,"S");
 for(i=0;i<frame_def_info->nb_sect;i++)
  {
   sprintf(&att_name[1],"%d",i);
   k = strlen(att_name);

   strcpy(&att_name[k], "from");
   if(VDSSetAttDbl(rg_coll, att_name, (double) frame_def_info->sect_info[i].fr, mod) != 1) goto wrapup;

   strcpy(&att_name[k], "to");
   if(VDSSetAttDbl(rg_coll, att_name, (double) frame_def_info->sect_info[i].to, mod) != 1) goto wrapup;

   strcpy(&att_name[k], "spacing");
   if(VDSSetAttDbl(rg_coll, att_name, frame_def_info->sect_info[i].spacing, mod) != 1) goto wrapup;

   strcpy(&att_name[k], "reinf");
   if(VDSSetAttDbl(rg_coll, att_name, (double) frame_def_info->sect_info[i].reinf, mod) != 1) goto wrapup;

   strcpy(&att_name[k], "offset");
   if(VDSSetAttDbl(rg_coll, att_name, (double) frame_def_info->sect_info[i].offset, mod) != 1) goto wrapup;
  }

 return 1;

wrapup:
     if(mod==0) printf("Error adding name: %s\n",att_name);
     else	printf("Error modifying name: %s\n",att_name);
     return 0;
}

/*
/* VDCrtFrmCol:
/*
/* Create or modify the frame collection.
/*
/*
/*  If mod = 0 then create the rg collection else only modify it.
/*
/*  Return 1 if ok else 0;
/*
/* */
VDCrtFrmCol(frame_info, nb_frame, lowest_frame, highest_frame, rg_coll, mod)
struct frame 	 *frame_info;     /* Frame info			(I)  */
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
 if(VDSSetAttDbl(rg_coll, "lowest_frame", (double) lowest_frame, mod) != 1) goto wrapup;
 if(VDSSetAttDbl(rg_coll, "highest_frame", (double) highest_frame, mod) != 1) goto wrapup;

 strcpy(att_name,"F");
 for(i=0;i<nb_frame;i++)
  {
   if(frame_info[i].number == NO_FRAME) continue;

   sprintf(&att_name[1],"%d",frame_info[i].number);
   k = strlen(att_name);

   strcpy(&att_name[k], "number");
   if(VDSSetAttDbl(rg_coll, att_name, (double) frame_info[i].number, mod)  != 1) goto wrapup;

   strcpy(&att_name[k], "rel_pos");
   if(VDSSetAttDbl(rg_coll, att_name, frame_info[i].rel_pos, mod) != 1) goto wrapup;

   strcpy(&att_name[k], "abs_pos");
   if(VDSSetAttDbl(rg_coll, att_name, frame_info[i].abs_pos, mod) != 1) goto wrapup;

   strcpy(&att_name[k], "offset");
   if(VDSSetAttDbl(rg_coll, att_name, (double) frame_info[i].offset_layer, mod)  != 1) goto wrapup;

   strcpy(&att_name[k], "reinf");
   if(VDSSetAttDbl(rg_coll, att_name, (double) frame_info[i].reinf, mod)   != 1) goto wrapup;

   strcpy(&att_name[k], "name");
   if(VDSSetAttTxt(rg_coll, att_name, frame_info[i].name, mod) != 1) 
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
/* VDSetFrame
/*
/*  Fill the structure gathering all the frames. The array of frame
/*  is allocated by the function and must be deallocated by the user.
/*
/*  Return 1 if ok else 0;
/*
/* */
VDSetFrame(frame_def_info, nb_frame, frame, lowest_frame, highest_frame, bad_frame)
struct frame_def       *frame_def_info;	 /* main frame def parameters	 (I) */
int		       *nb_frame;	 /* nb frames			 (O) */
struct frame          **frame;	 	 /* frame info			 (O) */
int		       *lowest_frame; 	 /* Lowest frame number		 (O) */
int		       *highest_frame;   /* highest frame number	 (O) */
int		       *bad_frame;       /* Frame number where it fails  (O) */ 
{
 int	nb_alloc_frame, frame_index;
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
     if(VDSIsFrameDef(*frame, *nb_frame, j, &k) == 1)
      {
       /* The frame has already been defined */
       if(VDSFillFrame(&((*frame)[k]), j, &frame_def_info->sect_info[i],  1) != 1)
	{
	 printf("Error for the frame number: %d\n", j);
         *bad_frame = j;
	 return 0;
	}
      }
     else
      {
       /* First def for the frame */
       if(VDSAllocFrame(frame, *nb_frame, &nb_alloc_frame) != 1)
        {
	 return 0;
	}

       if(VDSFillFrame(&((*frame)[*nb_frame]), j, &frame_def_info->sect_info[i], 0) != 1)
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
 if(VDVerDefault(*frame, *nb_frame, &k) != 1)
  {
   printf("Error, Bad spacing definition from the frame number: %d\n", k);
   *bad_frame = k;
   return 0;
  }

 /* Compute the frame */
 if(VDCompFrame(*frame, *nb_frame, &(frame_def_info->main_info), 
 		 lowest_frame, highest_frame, &k) != 1)
  {
   printf("Error, Bad definition from the frame number: %d\n",k);
   *bad_frame = k;
   return 0;
  }

 return 1;

}
/*
/* VDCreateFrame
/*
/*  Given the frame, frame definition info, the lowest and highest frame
/*  create the ppl_macro and each separated frames.
/*
/*  It also dealloc the frame.
/*
/* */
VDCreateFrame(cs, frame_def_info, nb_frame, frame_info, lowest_frame, 
	      highest_frame, bad_frame)
struct GRid	 *cs;			/* Identified of the cs (I) */
struct frame_def *frame_def_info;	/* frame def info	(I) */
int		  nb_frame;		/* number of frames	(I) */
struct frame	 *frame_info;		/* frame info		(I) */
int		  lowest_frame, highest_frame; /*               (I) */
int		 *bad_frame;       /* Frame number where it fails  (O) */ 
{
 struct GRid	 frame_def_col, frame_col;
 int 		 i;
 struct GRmd_env mod_env;
 IGRlong 	 sizebuf, nret;
 IGRlong         msg;

  *bad_frame	= 0;
 sizebuf = sizeof(struct GRmd_env);
 gr$get_module_env(   msg     = &msg,
                      sizbuf  = &sizebuf,
                      buffer  = &mod_env,
                      nret    = &nret);

 if(VDCrtFrmDefCol(frame_def_info, &frame_def_col, 0) != 1) 
  {
   printf("Error in creating the rg collection for the frame definition\n");
   return 0;
  }

 if(VDCrtFrmCol(frame_info, nb_frame, lowest_frame, highest_frame, &frame_col, 0) != 1) 
  {
   printf("Error in creating the rg collection for the frame \n");
   return 0;
  }
 
 
 for(i=0;i<nb_frame;i++)
  {
   if(!VDCrtUniFrm(&frame_info[i],cs,&frame_def_col,&frame_col,&mod_env, NULL))
    {
      printf("Bad placement (index: %d) for the frame number: %d\n",i,frame_info[i].number);
      *bad_frame = frame_info[i].number;
      break;
     }
   }

 /* Dealloc the frame info */
 if(nb_frame != 0) _FREE(frame_info);

 return 1;
}


/*
/*  VDCrtUniFrm()
/*  Create a single frame */
/*
/*   Return 1 if OK; 0 if big failure and 2 if warning 
/* */
VDCrtUniFrm(frame_info,cs,frame_def_col,frame_col,mod_env,path)
struct frame	 *frame_info;    /* frame info		    (I) */
struct GRid	 *cs        ;    /* Identified of the cs    (I) */
struct GRid      *frame_def_col; /* Identified of frame_def (I) */       
struct GRid      *frame_col;     /* Identified of frame_col (I) */
struct GRmd_env  *mod_env;       /* The module env          (I) */
char             *path;          /* The path for the frame  (I) */
{
 IGRlong 	 sts, msg;
 IGRshort	 action, props;
 struct GRid     exp; 
 struct GRid	 mac;
 struct GRid     list[4];
 char            tmp[PATH_MAX];    
 OM_S_CHANSELECT to_owners;

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
   sts = om$construct( classid = OPP_nci_macro_class_id,
                       osnum   = mac.osnum,
                       p_objid = &mac.objid );
   if(!(sts&1)) return 0;

   sts = om$send(msg = message ci_macro.init((IGRint *) &msg, 0, "VDFrPln",
                                                  4, list, NULL, mod_env),
			senderid = NULL_OBJID,
                        targetid = mac.objid,
                        targetos = mac.osnum);
   if(!(sts&1)) return 0;
   if(msg == 0) return 2;
   
   /* modif the properties to READ ONLY */
   if(1)
   {
    struct GRid foot;

     action = 1; /* set with mask */
     props  = GRIS_READ_ONLY;
     
     sts = om$send(msg = message NDmacro.ACreturn_foot
		   (&msg, "plane",&foot, NULL,  NULL),
		   senderid = NULL_OBJID,
		   targetid = mac.objid,
		   targetos = mac.osnum); 
  
    if(!(sts & msg & 1))
       printf("Warning, can get the foot of frame macro\n");
    else
     {
       sts = om$send(msg = message GRgraphics.GRchgprops
		     (&msg, &action, &props), 
		     senderid = NULL_OBJID,
		     targetid = foot.objid,
		     targetos = foot.osnum);
       if(!(sts & 1) || (msg != MSSUCC))
	 printf("Warning, did not set properties to read only\n");
   
       sts = om$send(msg = message GRgraphics.GRchgprops
		     (&msg, &action, &props), 
		     senderid = NULL_OBJID,
		     targetid = mac.objid,
		     targetos = mac.osnum);
       if(!(sts & 1) || (msg != MSSUCC))
	 printf("Warning, did not set properties to read only\n");
     }
    }

   /* Add a name */
   /* strcpy(frame_name, frame_def_info->main_info.annot);
   /* sprintf(tmp,"%d",frame_info->number);
   /* strcat(frame_name,tmp);
   /* */

 
   if(path == NULL)
      strcpy(tmp, frame_info->name);
   else
    {
      strcpy(tmp, path);
      strcat(tmp, frame_info->name);
    }
   sts = om$send(msg = message GRvg.GRputname(&msg, tmp),
                        senderid = NULL_OBJID,
                        targetid = mac.objid,
                        targetos = mac.osnum);
   if(!(sts&1)) 
      { 
       printf("Warning, cannot set the name for the frame number: %d\n",frame_info->number);
       /* This is just a warning because an reverse plane could have been
       /* place on it and the name can already exist */
       /* *bad_frame = frame_info->number;
       return 2;
       /* */
      }

   if(frame_info->offset_layer != 0)
    {
     IGRshort 	layer, act_layer;
     IGRlong 	sizebuf, nret;

     /* Get the active layer and add the offset layer */
     sizebuf = sizeof(IGRshort);
     gr$get_active_level(msg     = &msg,
                         sizbuf  = &sizebuf,
                         buffer  = &act_layer,
                         nret    = &nret);

     layer = act_layer + frame_info->offset_layer;
     sts = om$send(msg = message GRvg.GRchglevel(&msg, &layer),
                        senderid = NULL_OBJID,
                        targetid = mac.objid,
                        targetos = mac.osnum);
     if(!(sts&1)) 
      { 
       printf("Cannot modify the level for the frame number: %d\n",frame_info->number);
       return 2;
      }
    }
    return 1;
}

/* 
/* VDSFillFrame:
/* 
/* Fill one frame.
/*
/*
/*  Return 1 if ok else 0;
/*
/* */
VDSFillFrame(frame, frame_number, sect_info, mod)
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
/* VDSIsFrameDef:
/*
/* Given a frame number, return the corresponding frame index
/* 
/* return 1 => sucess else fail.
/* */
VDSIsFrameDef(frame, nb_frame, frame_number, frame_index)
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
/* VDVerDefault:
/*
/*  Verify and set default values
/*
/*  If fail the bad_frame_index is the index where the error has been found.
/*
/*  Return 1 if success else 0.
/*
/* */

VDVerDefault(frame, nb_frame, bad_frame_number)
struct frame 	  *frame;	 /* Frame info			 (I/O) */
int	      	   nb_frame;     /* Number of frame defined 	 (I)   */
int		  *bad_frame_number; /* If fail the corresponding 
				       frame number (O)   */
{
 int i;

 for(i=0;i<nb_frame;i++)
  {
   if(frame[i].rel_pos      <= NO_SPACING) 
    { 
     *bad_frame_number = frame[i].number; 
     return 0; 
    }
   if(frame[i].offset_layer <= NO_OFFSET)  frame[i].offset_layer  = 0;
   if(frame[i].reinf        <= NO_REINF)   frame[i].reinf 	  = 0;
  }
 return 1;
}   


/*
/* VDCompFrame:
/*
/*  Verify and set default values
/*
/*  If fail the bad_framenumber is the frame number where the error has been 
/*  found.
/*
/*  Return 1 if success else 0;
/*
/* */

VDCompFrame(frame, nb_frame, main_info, lowest_frame, highest_frame, bad_frame_number)
struct frame 	  *frame;	 /* Frame info			 (I/O) */
int	      	   nb_frame;     /* Number of frame defined 	 (I)   */
struct main_info  *main_info;	 /* Main frame info		 (I)   */ 
int		  *lowest_frame;    /* Lowest frame number	 (O)   */
int		  *highest_frame;   /* highest frame number	 (O)   */
int		  *bad_frame_number; /* If fail the corresponding 
				       frame number		 (O)   */
{
 int 		i;
 int 		frame_index;
 double 	old_pos;
 
 /* Get the lowest and highest frame */
 *lowest_frame  = 0;
 *highest_frame = 0;

 for(i=0;i<nb_frame;i++)
  {
   if(frame[i].number < *lowest_frame)  *lowest_frame  = frame[i].number;
   if(frame[i].number > *highest_frame) *highest_frame = frame[i].number;
  }

 /* Verification of the number of frames */
 if(*highest_frame - *lowest_frame != nb_frame - 1)
  {
   printf("Some intermediate frames have not been defined\n");
   *bad_frame_number = *highest_frame;
   return 0;
  }

 /* Set the frame 0 */
 if(VDSIsFrameDef(frame, nb_frame, 0, &frame_index) != 1)
  {
   printf("The reference frame number 0 has not been defined\n");
   *bad_frame_number = 0;
   return 0;
  }
 sprintf(frame[frame_index].name,"%s%d",main_info->annot,frame[frame_index].number);
 frame[frame_index].abs_pos = main_info->offset_dist;
 old_pos = frame[frame_index].abs_pos;
 
 /* Set the positive frames */
 for(i=1;i<=*highest_frame;i++)
  {
   if(VDSIsFrameDef(frame, nb_frame, i, &frame_index) != 1)
    {
     printf("The frame number: %d has not been defined\n", i);
     *bad_frame_number = i;
     return 0;
    }
   /* Set the frame name */
   sprintf(frame[frame_index].name,"%s%d",main_info->annot,frame[frame_index].number);
   /* Set the absolute position */
   frame[frame_index].abs_pos = old_pos + frame[frame_index].rel_pos;
   old_pos = frame[frame_index].abs_pos;
  }  

 /* Set the negative frames */
 old_pos = main_info->offset_dist;
 for(i=-1;i>=*lowest_frame;i--)
  {
   if(VDSIsFrameDef(frame, nb_frame, i, &frame_index) != 1)
    {
     printf("The frame number: %d has not been defined\n", i);
     *bad_frame_number = i;
     return 0;
    }
   /* Set the frame name */
   sprintf(frame[frame_index].name,"%s%d",main_info->annot,frame[frame_index].number);
   /* Set the absolute position */
   frame[frame_index].abs_pos = old_pos - frame[frame_index].rel_pos;
   old_pos = frame[frame_index].abs_pos;
  }  
 
#ifdef DEBUG
 printf("\t\t Frame parameters \n");
 printf("axis: %c, orient: %c, justif: %s, annot: %s\n",main_info->axis,
	 main_info->orient ,main_info->justif ,main_info->annot);
 printf("rev_dist: %lf, plane_size: %lf, reinf_plane: %lf, offset: %lf\n",
	 main_info->rev_dist, main_info->plane_size ,
	 main_info->reinf_size ,main_info->offset_dist);
 printf("\n");
 printf("number	name \trel_pos  \tabs_pos \toffset_layer \treinf\n");
 for(i=0;i<nb_frame;i++)
  {
   printf(" %d,\t%s,\t%lf,\t%lf,\t%d,\t%d\n",frame[i].number,frame[i].name,
		frame[i].rel_pos,frame[i].abs_pos,frame[i].offset_layer,
		frame[i].reinf);
  }
#endif
 return 1;
}

VDSAllocFrame(frame, frame_index, nb_alloc_frame)
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
     *frame = _MALLOC(INC * sizeof(struct frame),(struct frame));
    }
   else 
    {
     /* Realloc the frame structure */
     *frame = _REALLOC( (*nb_alloc_frame + INC)*sizeof(struct frame),
			(struct frame));
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

VDSSetAttDbl(coll, att_name, att_value, mod)
struct GRid *coll;              /* Collection id to update  (I) */
char        *att_name;          /* attribute name           (I) */
double       att_value;         /* new value to store       (I) */
int	     mod;		/* 1=> only modif else 0    (I) */
 {
  IGRlong status, msg;
  struct ACrg_coll att;

  strcpy(att.name, att_name);
  att.desc.type          = AC_ATTRIB_DOUBLE;
  att.desc.value.att_exp = att_value;

  if(mod != 1)
   {
    status = om$send(  msg      = message ACrg_collect.ACadd_list_attribute(
                                                &msg,
                                                1,
                                                &att),
                                senderid = NULL_OBJID,
                                targetid = coll->objid,
                                targetos = coll->osnum );
   }
  else
   {
    status = om$send(  msg      = message ACrg_collect.ACmod_list_attribute(
                                                &msg,
                                                1,
                                                &att),
                                senderid = NULL_OBJID,
                                targetid = coll->objid,
                                targetos = coll->osnum );
   }
  if((!(status&1))|(!(msg&1))) return 0;

  return 1;
}

VDSGetAttDbl(coll, att_name, att_value)
struct GRid *coll;              /* Collection id to update  (I) */
char        *att_name;          /* attribute name           (I) */
double      *att_value;         /* returned value           (O) */
{
  IGRlong status, msg;
  struct ACrg_coll att;


  strcpy(att.name, att_name);
  status = om$send(  msg      = message ACrg_collect.ACget_named_attribute(
                                                &msg,
                                                &att),
                                senderid = NULL_OBJID,
                                targetid = coll->objid,
                                targetos = coll->osnum );
  if((!(status&1))|(!(msg&1))) return 0;

  if(att.desc.type != AC_ATTRIB_DOUBLE) return 0;
  *att_value = att.desc.value.att_exp;

  return 1;
}


VDSSetAttTxt(coll, att_name, att_value, mod)
struct GRid *coll;              /* Collection id to update  (I) */
char        *att_name;          /* attribute name           (I) */
char        *att_value;         /* new value to store       (I) */
int	     mod;		/* 1=> only modif else 0    (I) */
{
  IGRlong status, msg;
  struct ACrg_coll att;


  strcpy(att.name, att_name);
  att.desc.type = AC_ATTRIB_TEXT;
  strcpy(att.desc.value.att_txt, att_value);
  if(mod != 1)
   {
    status = om$send(  msg      = message ACrg_collect.ACadd_list_attribute(
                                                &msg,
                                                1,
                                                &att),
                                senderid = NULL_OBJID,
                                targetid = coll->objid,
                                targetos = coll->osnum );
   }
  else
   {
    status = om$send(  msg      = message ACrg_collect.ACmod_list_attribute(
                                                &msg,
                                                1,
                                                &att),
                                senderid = NULL_OBJID,
                                targetid = coll->objid,
                                targetos = coll->osnum );
   } 
  if((!(status&1))|(!(msg&1))) return 0;

  return 1;
}

VDSGetAttTxt(coll, att_name, att_value)
struct GRid *coll;              /* Collection id to update  (I) */
char        *att_name;          /* attribute name           (I) */
char        *att_value;         /* returned value           (O) */
{
  IGRlong status, msg;
  struct ACrg_coll att;


  strcpy(att.name, att_name);
  status = om$send(  msg      = message ACrg_collect.ACget_named_attribute(
                                                &msg,
                                                &att),
                                senderid = NULL_OBJID,
                                targetid = coll->objid,
                                targetos = coll->osnum );
  if((!(status&1))|(!(msg&1))) return 0;

  if(att.desc.type != AC_ATTRIB_TEXT) return 0;
  strcpy(att_value, att.desc.value.att_txt);

  return 1;
}

/*
/* VDGetPlInfo
/* 
/*  Given the objid of the frame and the frame definition, returns the
/*  interesting parameters values for placement.
/* 
/*  Return 1 if OK else retun 0.
/* 
/* */
VDGetPlInfo(frame, frame_def, frame_number, axis, dist, size, name, 
  		 justif, props)
struct GRid	*frame;		/* Frame identifier		(I) */
struct GRid	*frame_def;	/* Frame definition identifier	(I) */
int		 frame_number;  /* Frame number to look		(I) */
char		*axis;		/* Axis				(O) */
double		*dist;		/* Distance onlong axis		(O) */
double		*size;		/* Size of the plane		(O) */
char		*name;		/* Text displayed 		(O) */
char		*justif;	/* Justification		(O) */
unsigned IGRchar *props;	/* Reversed Normal props	(O) */
{
 int 	k;
 char 	orient[2], att_name[40], annot[16], tmp[10];
 double rev_dist, plane_size, reinf_size, reinf;

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

 /* Get parameter of the corresponfing frame */
 /* Built the names */
 
 strcpy(att_name,"F");
 sprintf(tmp,"%d",frame_number);
 strcpy(&att_name[1],tmp);
 k = strlen(att_name);

 strcpy(&att_name[k], "reinf");
 if(VDSGetAttDbl(frame, att_name, &reinf) != 1) 
   {printf("reinf not found\n"); return 0; }

 strcpy(&att_name[k],"abs_pos");
 if(VDSGetAttDbl(frame, att_name, dist) != 1) 
   {printf("dist not found\n"); return 0; }


 if(reinf == 1)
  {
   *size = reinf_size;

   strcpy(&att_name[k],"name");
   if(VDSGetAttTxt(frame, att_name, name) != 1) 
    {
     /* printf("Warning, name not found\n"); */
     strcpy(name,annot);
     strcat(name,tmp);
    }
  }
 else
  {
   *size = plane_size;
   name[0] = '\0';
  }

 /* Determined if the normal sens */
 if(orient[0] == 'P') *props = 0x00;
 else		      *props = EMSIS_NRML_REVERSED;
 if(rev_dist > NO_REV_DIST)
  {
   if(*dist >= rev_dist)
    {
     /* Inverte the normal */
     if(*props &  EMSIS_NRML_REVERSED) *props = 0x00;
     else 			       *props = EMSIS_NRML_REVERSED;
    }
  }

 return 1;
}



/*
/* VDPlaceFrame
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
VDPlaceFrame(cs, frame_def_info, bad_frame)
struct GRid	 *cs;			/* Identified of the cs 	(I) */
struct frame_def *frame_def_info;	/* frame def info		(I) */
IGRint		 *bad_frame;		/* If fail, bad frame number 	(O) */
{
 int 		lowest_frame, highest_frame;
 struct frame  *frame;	
 int	 	nb_frame;

 *bad_frame = 0;

 if(VDSetFrame(frame_def_info, &nb_frame, &frame, &lowest_frame, 
 	       &highest_frame, bad_frame) != 1)
   {
    printf("Cannot generated the frame structure\n");
    return 0;
   }
    

 if(VDCreateFrame(cs, frame_def_info, nb_frame, frame, lowest_frame, 
 	          highest_frame, bad_frame) != 1)
   {
    printf("Cannot generated the frame objects\n");
    return 0;
   }

 return 1;
}

/*
/* VDModFrame
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
VDModFrame(cs,new_cs,frame_def_obj, frame_obj, frame_def_info, mod_frame_def_info, bad_frame)
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

 *bad_frame = 0;


 if(VDSetFrame(frame_def_info, &nb_frame, &frame, &lowest_frame, 
 	       &highest_frame, bad_frame) != 1)
   {
    printf("Cannot retrieve the existing frame structure\n");
    return 0;
   }

 if(VDSetFrame(mod_frame_def_info, &nb_mod_frame, &mod_frame, &lowest_mod_frame, 
 	       &highest_mod_frame, bad_frame) != 1)
   {
    printf("Cannot compute the frame structure\n");
    return 0;
   }

 if(nb_mod_frame != nb_frame)
  {
   printf("Error, the number of frames has been modified\n");
   return 0;
  }

 if(VDSGetFrmSyst(cs,frame_def_obj, frame_obj, nb_frame, &glob_frame_obj) != 1)
  {
   printf("Error, cannot retrieve the frame system objects\n");
   return 0;
  }
   
 if(VDSCrtFrmObj(new_cs,frame_def_info, nb_frame, frame, lowest_frame, 
 	         highest_frame, mod_frame_def_info, nb_mod_frame, mod_frame, 
	         lowest_mod_frame, highest_mod_frame, bad_frame, 
		 &glob_frame_obj) != 1)
   {
    printf("Cannot create the frame objects\n");
    return 0;
   }

 if(VDSUpdFrame(new_cs, frame_def_info->main_info.annot, nb_frame, frame, 
 		lowest_frame, highest_frame, &glob_frame_obj, bad_frame) != 1)
   {
    printf("Cannot update the frame system\n");
    return 0;
   }

 *cs            = *new_cs;
 *frame_def_obj = glob_frame_obj.frame_def;
 *frame_obj     = glob_frame_obj.frame_info;

 /* Free the frame_obj structure */
 _FREE(glob_frame_obj.frame_obj);

 if(nb_frame != 0) _FREE(frame);
 if(nb_mod_frame != 0) _FREE(mod_frame);

 return 1;
}

/*
/* VDSCrtFrmObj:
/* Eventually update here the coordinate system in glob_frame_obj */
/* */
VDSCrtFrmObj(new_cs,frame_def_info, nb_frame, frame, lowest_frame,
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
 IGRchar 	tmp[80];

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


 chg_frame_struct = 0;
 fr_nb 		  = lowest_frame;
 for(mod_fr_nb = lowest_mod_frame; mod_fr_nb <= highest_mod_frame; mod_fr_nb++)
  {
   if(VDSIsFrameDef(mod_frame, nb_mod_frame, mod_fr_nb, &mod_frame_index) != 1)
    {
     /* No frame found */
     *bad_frame = mod_fr_nb;
    }  

   if(VDSIsFrameDef(frame, nb_frame, fr_nb, &frame_index) != 1)
    {
     /* No frame found */
     *bad_frame = fr_nb;
    }

   if(VDSIsFrameSyst(glob_frame_obj->frame_obj, nb_frame, fr_nb,
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

   if(fabs(mod_frame[mod_frame_index].abs_pos - frame[frame_index].abs_pos) > EPSILON)
    {
     /* The location is not the same */
     glob_frame_obj->frame_obj[fr_syst_index].status |= MOD_FRAME | COMP_FRAME;
    }

   /* if(glob_frame_obj->frame_obj[fr_syst_index].status & NAME_FRAME) */
   if(1)
    {
     char plane_name[40];
     int  user_name;

     /* If the name of the occurrence is user defined we don't touch it, */
     /* else we compute it */
     plane_name[0] = '\0';
     user_name     = 0;
     if(VDSGetUserName(&glob_frame_obj->frame_obj[fr_syst_index].frame, 
     		frame_def_info->main_info.annot, plane_name, &user_name) != 1)
      {
       printf("Warning, error getting the name of the plane\n");
      }

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
       /* Define the new name */
       strcpy(glob_frame_obj->frame_obj[fr_syst_index].frame_name,mod_frame_def_info->main_info.annot);
       sprintf(tmp,"%d",mod_fr_nb);
       strcat(glob_frame_obj->frame_obj[fr_syst_index].frame_name,tmp);
       strcpy(mod_frame[mod_frame_index].name, glob_frame_obj->frame_obj[fr_syst_index].frame_name);
      }
    }
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
 /* Warning. It will be faster to modify only the parameters which have 
 /* changed. To do later on if it is too slow.
 /* */

 /* 
 /* If the number of frames did not change but if the lowest and highest
 /* have changed, we need to kill the old rg collection of the frame
 /* def and to recreate a new one.
 /* 
 /* The same if the number of section has changed 
 /* */

 if(mod_frame_def_info->nb_sect != frame_def_info->nb_sect)
  {
   struct GRid new_frame_def;

   if(VDCrtFrmDefCol(mod_frame_def_info, &new_frame_def, 0) != 1)
    {
     printf("Error, cannot set the frame def rg collection\n");
     return 0;
    }
   /* Change root */
   for(i=0; i<nb_frame; i++)
    {
     sts = om$send(msg = message NDnode.NDchange_connect(1, 
     		&glob_frame_obj->frame_def, &new_frame_def),
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
   if(VDCrtFrmDefCol(mod_frame_def_info, &glob_frame_obj->frame_def, 1) != 1)
    {
     printf("Error, cannot update the frame def rg collection\n");
     return 0;
    }
  }

 if(chg_frame_struct == 1)
  {
   struct GRid new_frame_info;

   if(VDCrtFrmCol(mod_frame, nb_mod_frame, lowest_mod_frame, highest_mod_frame,
        	&new_frame_info, 0) != 1)
    {
     printf("Error, cannot update the frame info rg collection\n");
     return 0;
    }
   /* Change root */
   for(i=0; i<nb_frame; i++)
    {
     sts = om$send(msg = message NDnode.NDchange_connect(1, 
     		&glob_frame_obj->frame_info, &new_frame_info),
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
  }
 else
  {
   if(VDCrtFrmCol(mod_frame, nb_mod_frame, lowest_mod_frame, highest_mod_frame,
        	&glob_frame_obj->frame_info, 1) != 1)
    {
     printf("Error, cannot update the frame info rg collection\n");
     return 0;
    }
  }

 return 1;
}

/*
/* VDSUpdFrame
/*
/* Update the frames
/*
/* */
VDSUpdFrame(cs, old_annot, nb_frame, frame, lowest_frame, highest_frame, 
		glob_frame_obj,bad_frame)
struct GRid	 *cs;			/* Identified of the cs 	(I) */
char		 *old_annot;		/* Old annotation		(I) */
IGRint		  nb_frame;		/* Number of frames		(I) */
struct frame     *frame;		/* Frame structure		(I) */
IGRint		  lowest_frame;   	/* Lowest frame number		(I) */
IGRint		  highest_frame;       	/* Highest frame number		(I) */
struct glob_frame_obj *glob_frame_obj;	/* Global struct info		(I) */
IGRint		 *bad_frame;		/* If fail, bad frame number 	(O) */
{
 IGRint 	 i, cn_type, sts, wait_batch;
 IGRlong	 msg;
 IGRchar 	 exp[80];
 struct GRmd_env mod_env;
 IGRlong 	 sizebuf, nret;
 int frame_index;
 char tmp[PATH_MAX];

 sizebuf = sizeof(struct GRmd_env);
 gr$get_module_env(   msg     = &msg,
                      sizbuf  = &sizebuf,
                      buffer  = &mod_env,
                      nret    = &nret);

 *bad_frame = 0;
 wait_batch = 0;

 for(i=0;i<nb_frame;i++)
  {
   if(glob_frame_obj->frame_obj[i].status == SAME_FRAME) continue;
   else if(glob_frame_obj->frame_obj[i].status & CRT_FRAME)
    {
     /* A new frame has to be created */

   /* search the index */
     if(VDSIsFrameDef(frame, nb_frame, glob_frame_obj->frame_obj[i].new_frame_number, &frame_index) != 1)
    {
     printf("Search index not found\n");
     *bad_frame = glob_frame_obj->frame_obj[i].new_frame_number;
      return 0;
    }
    
     msg = VDCrtUniFrm(&frame[frame_index],
                       cs,
                       &glob_frame_obj->frame_def,
                       &glob_frame_obj->frame_info,
                       &mod_env, glob_frame_obj->bas_dir);
     switch(msg){
       case 0 : printf("Error creating frame %d\n",i); return 0;
       case 1 : break;
       case 2 : printf("Warning creating frame %d\n",i); break; 
     }
    }
   else if(glob_frame_obj->frame_obj[i].status & DEL_FRAME)
    {
     /* A frame has to be deleted */

     /* Clear the name and put the status to set the new name later */
     sts = om$send(msg = message GRvg.GRchgname(&msg, NULL,""),
                        senderid = NULL_OBJID,
                        targetid = glob_frame_obj->frame_obj[i].frame.objid,
                        targetos = glob_frame_obj->frame_obj[i].frame.osnum);
     if(!(sts&1)) 
      {
       printf("Warning, cannot clear the name for the frame number: %d\n",
     	       glob_frame_obj->frame_obj[i].new_frame_number);
       *bad_frame = glob_frame_obj->frame_obj[i].new_frame_number;
       return 0;
      }

     wait_batch = 1;;
     cn_type    = 1; /* recompute the object */
     sts = nd$wait_batch(type       = GR_DELETED,
                         l_object   = &glob_frame_obj->frame_obj[i].frame,
		         p_fr_info  = &mod_env,
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
     if(glob_frame_obj->frame_obj[i].status & COMP_FRAME)
      {
       /* The modification must be propagated */
       if(glob_frame_obj->frame_obj[i].new_frame_number != 
          glob_frame_obj->frame_obj[i].old_frame_number)
	{
         /* Change the expression and put it in a wait_batch list */

         sprintf(exp,"%d",glob_frame_obj->frame_obj[i].new_frame_number);
         sts = exp$modify (exp_id     = glob_frame_obj->frame_obj[i].expression.objid,
                           osnum      = glob_frame_obj->frame_obj[i].expression.osnum, 
		           exp_syntax = exp);
         if(!(sts&1))
	  {
	    printf("Cannot update the expression for the frame number: %d\n",
	    		glob_frame_obj->frame_obj[i].new_frame_number);
	    *bad_frame = glob_frame_obj->frame_obj[i].new_frame_number;
	    return 0;
	  }
	}

       wait_batch = 1;
       cn_type    = 1; /* recompute the object */
       sts = nd$wait_batch(type = GR_GEOM_POSTED,
                     l_object   = &glob_frame_obj->frame_obj[i].frame,
		     p_fr_info  = &mod_env,
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
       /* It is a change of the display parameters */
       if(glob_frame_obj->frame_obj[i].new_frame_number != 
          glob_frame_obj->frame_obj[i].old_frame_number)
	{
	 *bad_frame = glob_frame_obj->frame_obj[i].new_frame_number;
	 return 0;
	}

       /* Erase the frame */
       sts = om$send(msg = message NDnode.NDdisplay(0, GRbe, &mod_env),
                        senderid = NULL_OBJID,
                        targetid = glob_frame_obj->frame_obj[i].frame.objid,
                        targetos = glob_frame_obj->frame_obj[i].frame.osnum);
       if(!(sts&1)) 
        {
         printf("Warning, cannot erase the frame number: %d\n",
       	       glob_frame_obj->frame_obj[i].new_frame_number);
	}

       sts = om$send(msg = message NDnode.NDs_compute_node(&msg, 0, NULL),
                        senderid = NULL_OBJID,
	 		targetid = glob_frame_obj->frame_obj[i].frame.objid,
	 		targetos = glob_frame_obj->frame_obj[i].frame.osnum);
       if(!(sts&1))
        {
         printf("Error Updating the frame number: %d\n", glob_frame_obj->frame_obj[i].new_frame_number);
         *bad_frame = glob_frame_obj->frame_obj[i].new_frame_number;
	 return 0;
	}
      }
     else return 0;
    }
   else return 0;

   if(glob_frame_obj->frame_obj[i].status & NAME_FRAME)
    {
       /* Clear the name and put the status to set the new name later */
       sts = om$send(msg = message GRvg.GRchgname(&msg, NULL,""),
                        senderid = NULL_OBJID,
                        targetid = glob_frame_obj->frame_obj[i].frame.objid,
                        targetos = glob_frame_obj->frame_obj[i].frame.osnum);
       if(!(sts&1)) 
        {
         printf("Warning, cannot clear the name for the frame number: %d\n",
     	       glob_frame_obj->frame_obj[i].new_frame_number);
         *bad_frame = glob_frame_obj->frame_obj[i].new_frame_number;
         return 0;
	}
    }
  }

 for(i=0;i<nb_frame;i++)
  {
   if(glob_frame_obj->frame_obj[i].status & NAME_FRAME)
    {
     /* Set the name */

      tmp[0] = '\0';
 
      if( glob_frame_obj->bas_dir == NULL)
          strcpy(tmp, glob_frame_obj->frame_obj[i].frame_name );
      else
      {
         strcpy(tmp,glob_frame_obj->bas_dir); 
         strcat(tmp,glob_frame_obj->frame_obj[i].frame_name);
      }

       
     sts = om$send(msg = message GRvg.GRputname(&msg,tmp), 
                        senderid = NULL_OBJID,
                        targetid = glob_frame_obj->frame_obj[i].frame.objid,
                        targetos = glob_frame_obj->frame_obj[i].frame.osnum);
     if(!(sts&1)) 
      {
       printf("Warning, cannot set the name for the frame number: %d\n",
       	       glob_frame_obj->frame_obj[i].new_frame_number);
       continue;
      }
    }

   if(wait_batch == 0 && glob_frame_obj->frame_obj[i].status & MOD_FRAME) 
    {
     /* Display the frame */
     sts = om$send(msg = message NDnode.NDdisplay(1, GRbd, &mod_env),
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

 /* do the exec batch to update what has been updated */
 nd$mod_batch(request     = ND_INQ,
	      p_ret_mode = &wait_batch);

 if(wait_batch != ND_DEFER) nd$exec_batch();

#ifdef OLDVERSION 
  if(wait_batch == 1) nd$exec_batch(); 
#endif

 return 1;
}


/* ************ VDSDelFrmSyt *********** */
/* Delete globaly the frame system*/

VDSDelFrmSyst (cs, frame_def_obj, frame_obj, frame_def_info, bad_frame)
struct GRid	 *cs;			/* Identified of the cs or plane (I) */
struct GRid	 *frame_def_obj;	/* Identified of the frame def  (I)  */
struct GRid	 *frame_obj;		/* Identified of the frame info (I)  */
struct frame_def *frame_def_info;	/* Existing frame def info	(I)  */
IGRint		 *bad_frame;		/* If fail, bad frame number 	(O)  */
{
  int 		lowest_frame, highest_frame;
  struct frame  *frame;
  struct	glob_frame_obj glob_frame_obj;
  IGRlong	 msg;
  IGRint 	 i,sts,wait_batch;
  struct GRmd_env mod_env;
  IGRlong 	 sizebuf, nret;
  int	 	nb_frame,fr_nb;
  IGRint        fr_syst_index, cn_type; 
  *bad_frame = 0;
  
  if(VDSetFrame(frame_def_info, &nb_frame, &frame, &lowest_frame, 
		&highest_frame, bad_frame) != 1)
   {
     printf("Cannot retieve the existing frame structure\n");
     return 0;
   }
  
  if(VDSGetFrmSyst(cs, frame_def_obj, frame_obj, nb_frame, &glob_frame_obj) != 1)
   {
     printf("Error, cannot retrieve the frame system objects\n");
     return 0;
   }
  
  sizebuf = sizeof(struct GRmd_env);
  gr$get_module_env(   msg     = &msg,
		    sizbuf  = &sizebuf,
		    buffer  = &mod_env,
		    nret    = &nret);
  
  for(fr_nb = lowest_frame; fr_nb <=  highest_frame; fr_nb++)
   {
     if(VDSIsFrameSyst(glob_frame_obj.frame_obj, nb_frame, fr_nb, &fr_syst_index) != 1)
      {
	*bad_frame = fr_nb;
	return 0;
      }
     
     cn_type    = 1; /* recompute the object */
     sts = nd$wait_batch(type       = GR_DELETED,
                         l_object   = &glob_frame_obj.frame_obj[fr_syst_index].frame,
			 l_obj_info = &cn_type,
		         p_fr_info  = &mod_env,
                         nb_obj     = 1);
     if(!(sts&1))
      {
	*bad_frame = glob_frame_obj.frame_obj[fr_syst_index].old_frame_number;
	return 0;
      }
      sts = om$send(msg = message NDnode.NDdisplay (0,GRbe,&mod_env),
                    senderid = NULL_OBJID,
		    targetid =glob_frame_obj.frame_obj[fr_syst_index].frame .objid,
		    targetos = glob_frame_obj.frame_obj[fr_syst_index].frame.osnum);
       as$status(sts = sts, action = CONTINUE);
   }
  
  nd$mod_batch(request    = ND_INQ,
	       p_ret_mode = &wait_batch);
  
  if(wait_batch != ND_DEFER) nd$exec_batch();
  
  /* Free the frame_obj structure */
  _FREE(glob_frame_obj.frame_obj);
  
  if(nb_frame != 0) _FREE(frame);
  
  return 1;
}


/*
/* VDSGetFrmSyst
/*
/* Given a frame object, retrieve the roots.
/*
/* Alloc the struct "frame_obj" of glob_frame_obj. This must be deallocated
/* by the user.
/*
/* */ 

VDSGetFrmSyst(cs, frame_def_obj, frame_obj, nb_frame, glob_frame_obj)
struct GRid		*cs, *frame_def_obj, *frame_obj	;
IGRint			 nb_frame;
struct glob_frame_obj 	*glob_frame_obj;
{
 struct GRid 	list[4], *buff;
 IGRint		i, count;
 IGRlong	sts,status;
 IGRdouble	fr_number;
 char           path[PATH_MAX],untr_path[PATH_MAX];
 

 /* Alloc the frame_obj structure */
 glob_frame_obj->frame_obj = 
	_MALLOC(nb_frame * sizeof(struct frame_obj),(struct frame_obj));
 if(glob_frame_obj->frame_obj == NULL)
  {
   printf("Error, bad dynamic space allocation\n");
   return 0;
  }

 /* Get all the frame obj */

 glob_frame_obj->cs         = *cs;
 glob_frame_obj->frame_def  = *frame_def_obj;
 glob_frame_obj->frame_info = *frame_obj;

 sts =  om$send(msg = message NDnode.NDget_objects(ND_CHILDREN|ND_IN_BUF, NULL,
 			 	0, &buff, 0, OM_K_MAXINT, &count),
 			senderid = NULL_OBJID,
			targetid = glob_frame_obj->frame_info.objid,
			targetos = glob_frame_obj->frame_info.osnum);
 if(!(sts&1))
  {
   printf("Error, cannot get the roots\n");
   goto wrapup; /* return 0; */
  }

 if(count != nb_frame)
  {
   printf("Error count: %d must be: %d\n", count, nb_frame);
   goto wrapup; /* return 0; */
  }
 
 for(i=0;i<nb_frame;i++)
  {
   /* retrieve the expression */
   glob_frame_obj->frame_obj[i].status = 0;
   glob_frame_obj->frame_obj[i].frame  = buff[i];
   glob_frame_obj->frame_obj[i].frame_name[0] = '\0';
  }

 for(i=0;i<nb_frame;i++)
  {
   sts =  om$send(msg = message NDnode.NDget_objects(ND_ROOT, &glob_frame_obj->frame_obj[i].expression, 
   			1, NULL, 1, 1, &count),
 			senderid = NULL_OBJID,
			targetid = glob_frame_obj->frame_obj[i].frame.objid, 
			targetos = glob_frame_obj->frame_obj[i].frame.osnum);
   if(!(sts&1))
    {
     printf("Error, cannot get the roots (index: %d)\n",i);
     goto wrapup; /* return 0; */
    }

   if(count != 4) return 0;

   sts = om$send(msg = message NDnode.NDgive_value(&fr_number),
 			senderid = NULL_OBJID,
			targetid = glob_frame_obj->frame_obj[i].expression.objid,
			targetos = glob_frame_obj->frame_obj[i].expression.osnum);
   if(!(sts&1))
    {
     printf("Error, cannot get the value (index: %d)\n",i);
     goto wrapup; /* return 0; */
    }
   glob_frame_obj->frame_obj[i].old_frame_number = (int) fr_number;
  }

 /* Get the base directory */
 /* The ASSOMPTION is that all elements of the frame system belong to the
 /* same directory ...
 /* So retrieve the base of any frame */

   strcpy(path,"");

   status = di$untranslate(objname = untr_path,
                          objid = glob_frame_obj->frame_obj[0].frame.objid,
                          osnum = glob_frame_obj->frame_obj[0].frame.osnum);  
    
   if(status == DIR_S_SUCCESS){
        /*^printf("Complete name of frame 0: [%s]\n",untr_path);*/
        status = di$split(pathname =  untr_path,
                          dirname  =  path);
        if(status !=DIR_S_SUCCESS){
                di$report_error(sts = status, comment = "ERROR di$split");
                }
       }
     
   strcat(path,":");
   /*^printf("path in VDgetFrmSyst [%s]\n",path);*/ 
   strcpy(glob_frame_obj->bas_dir,path);
 
 return 1;
 wrapup :

	if ( glob_frame_obj->frame_obj ) _FREE ( glob_frame_obj->frame_obj );
        return 0;

}


VDSIsFrameSyst(frame_obj, nb_frame, frame_number, frame_index)
struct frame_obj 	*frame_obj;
IGRint			 nb_frame;
IGRint			 frame_number;
IGRint			*frame_index;
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
/*  VDSGetUserName:
/*
/*  This function gets the name of the plane occurrence and determines
/*  if it is or not a user name (system name). To do it we just verify
/*  if the plane name begun with the same as the annotation.
/*
/* */

VDSGetUserName(plane, annot, plane_name, user_name)
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

/*
/* VDRemFrame
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
VDRemFrame(cs, frame_def_obj, frame_obj, frame_def_info, nb_del_frame, frame_list, bad_frame)
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

 if(VDSetFrame(frame_def_info, &nb_frame, &frame, &lowest_frame, 
 	       &highest_frame, bad_frame) != 1)
   {
    printf("Cannot retieve the existing frame structure\n");
    return 0;
   }

 if(VDSGetFrmSyst(cs, frame_def_obj, frame_obj, nb_frame, &glob_frame_obj) != 1)
  {
   printf("Error, cannot retrieve the frame system objects\n");
   return 0;
  }

 /* Remove from the frame system structure */
 if(VDSRemFrmsyst(frame_def_info, &nb_frame, &frame, &lowest_frame, 
 	         &highest_frame, nb_del_frame, frame_list, bad_frame, 
		 &glob_frame_obj) != 1)
   {
    printf("Cannot create the frame objects\n");
    return 0;
   }

 if(VDSUpdFrame(cs, frame_def_info->main_info.annot, nb_frame, frame, 
 		lowest_frame, highest_frame, &glob_frame_obj, bad_frame) != 1)
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
/* VDSRemFrmSyst:
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

VDSRemFrmsyst(frame_def_info, nb_frame, frame, lowest_frame, highest_frame,
	      nb_del_frame, frame_list, bad_frame, glob_frame_obj)
struct frame_def 	*frame_def_info;
IGRint		 	*nb_frame;
struct frame	 	**frame;
IGRint		 	*lowest_frame, *highest_frame, nb_del_frame;
struct GRid		*frame_list;
IGRint			*bad_frame;
struct glob_frame_obj 	*glob_frame_obj;
{
 IGRint 	fr_nb, del_fr_nb;
 IGRint		fr_syst_index, frame_index;
 IGRchar	plane_name[40], tmp[80];
 IGRint  	mod, n_mod, p_mod, found, user_name;
 IGRint		i, new_nb_frame, n_lowest_frame, n_highest_frame;
 IGRlong	sts;
 struct GRid    new_frame_info;

 *bad_frame = 0;

 /* Set the status delete to the frame to delete */
 mod = 0; /* Number of frame already deleted */
 for(fr_nb = *lowest_frame; fr_nb <=  *highest_frame; fr_nb++)
  {
   if(VDSIsFrameSyst(glob_frame_obj->frame_obj, *nb_frame, fr_nb, &fr_syst_index) != 1)
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
   if(VDSIsFrameSyst(glob_frame_obj->frame_obj, *nb_frame, fr_nb, &fr_syst_index) != 1)
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
   if(VDSIsFrameSyst(glob_frame_obj->frame_obj, *nb_frame, fr_nb, &fr_syst_index) != 1)
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
   if(glob_frame_obj->frame_obj[i].status & NAME_FRAME)
    {
     /* If the name of the occurrence is user defined we don't touch it, */
     /* else we compute it */
     plane_name[0] = '\0';
     user_name     = 0;
     if(VDSGetUserName(&glob_frame_obj->frame_obj[i].frame,
                frame_def_info->main_info.annot, plane_name, &user_name) != 1)
      {
       printf("Warning, error getting the name of the plane\n");
      }
 
     if(user_name == 1)
      {
       /* User defined name */
       strcpy(glob_frame_obj->frame_obj[i].frame_name, plane_name);
      }
     else
      {
       /* Define the new name */
       strcpy(glob_frame_obj->frame_obj[i].frame_name,frame_def_info->main_info.annot);
       sprintf(tmp,"%d",glob_frame_obj->frame_obj[i].new_frame_number);
       strcat(glob_frame_obj->frame_obj[i].frame_name,tmp);
      }
    }

   /* Set up the new lowest & highet frame number */
   if(n_lowest_frame >    glob_frame_obj->frame_obj[i].new_frame_number)
        n_lowest_frame  = glob_frame_obj->frame_obj[i].new_frame_number;
   if(n_highest_frame <   glob_frame_obj->frame_obj[i].new_frame_number)
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
 if(VDSetFrame(frame_def_info, &new_nb_frame, frame, lowest_frame, highest_frame, bad_frame) != 1)
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
   if(VDSIsFrameDef(*frame, new_nb_frame, glob_frame_obj->frame_obj[i].new_frame_number, &frame_index) != 1)
    {
     *bad_frame = glob_frame_obj->frame_obj[i].old_frame_number;
     return 0;
    }

   strcpy((*frame)[frame_index].name,glob_frame_obj->frame_obj[i].frame_name);
  }
 


 /* Recreate the collections*/

 /* Only update frame def collection */
 if(VDCrtFrmDefCol(frame_def_info, &glob_frame_obj->frame_def, 1) != 1)
  {
   printf("Error, cannot update the frame def rg collection\n");
   return 0;
  }

 /* create a new frame collection */
 
   if(VDCrtFrmCol(*frame, new_nb_frame, *lowest_frame, *highest_frame,
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
/* VDAdFrame
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
VDAdFrame(cs, frame_def_obj, frame_obj, frame_def_info, nb_add_frame, frame_list, bad_frame)
struct GRid	 *cs;			/* Identified of the cs or plane (I)  */
struct GRid	 *frame_def_obj;	/* Identified of the frame def  (I/O) */
struct GRid	 *frame_obj;		/* Identified of the frame info (I/O) */
struct frame_def *frame_def_info;	/* Existing frame def info	(I)   */
IGRint		  nb_add_frame;		/* Number of frames to delete   (I)   */
IGRint		 *frame_list;		/* List of frames number to add	(I)   */
IGRint		 *bad_frame;		/* If fail, bad frame number 	(O)   */
{
 int 		lowest_frame, highest_frame;
 struct frame  *frame;
 int	 	nb_frame;
 struct	glob_frame_obj glob_frame_obj;

 *bad_frame = 0;

 if(nb_add_frame < 1) return 1;

 if(VDSetFrame(frame_def_info, &nb_frame, &frame, &lowest_frame, 
 	       &highest_frame, bad_frame) != 1)
   {
    printf("Cannot retrieve the existing frame structure\n");
    return 0;
   }

 if(VDSGetFrmSyst(cs, frame_def_obj, frame_obj, nb_frame, &glob_frame_obj) != 1)
  {
   printf("Error, cannot retrieve the frame system objects\n");
   return 0;
  }

 /* Add to the frame system structure */
 if(VDSAdFrmsyst(frame_def_info, &nb_frame, &frame, &lowest_frame, 
 	         &highest_frame, nb_add_frame, frame_list, bad_frame, 
		 &glob_frame_obj) != 1)
   {
    printf("Cannot create the frame objects\n");
    return 0;
   }

 if(VDSUpdFrame(cs, frame_def_info->main_info.annot, nb_frame, frame, 
 		lowest_frame, highest_frame, &glob_frame_obj, bad_frame) != 1)
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
/* VDSAdFrmSyst:
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

VDSAdFrmsyst(frame_def_info, nb_frame, frame, lowest_frame, highest_frame,
	      nb_add_frame, frame_list, bad_frame, glob_frame_obj)
struct frame_def 	*frame_def_info;
IGRint		 	*nb_frame;
struct frame	 	**frame;
IGRint		 	*lowest_frame, *highest_frame, nb_add_frame;
IGRint			*frame_list;
IGRint			*bad_frame;
struct glob_frame_obj 	*glob_frame_obj;
{
  IGRint 	fr_nb, del_fr_nb;
  IGRint	fr_syst_index, frame_index;
  IGRint        new_fr_index;
  IGRchar	plane_name[40], tmp[80];
  IGRint  	mod, n_mod, p_mod, found, user_name;
  IGRint		i, new_nb_frame, n_lowest_frame, n_highest_frame;
  IGRlong	sts;
  IGRint         *low_num_sect = NULL,*high_num_sect = NULL; 
  struct GRid   new_frame_info;

  int comp_increase();
  
  *bad_frame = 0;
  
  /* Realloc of glob_frame_obj->frame_obj */
  /* This allow to add the new created frame info */
  
  glob_frame_obj->frame_obj = _REALLOC(
		(*nb_frame + nb_add_frame)*sizeof(struct frame_obj),
		(struct frame_obj));
  if(glob_frame_obj->frame_obj == NULL)
   {
     printf("Error, bad dynamic space allocation\n");
     return 0;
   }
  
  new_fr_index = (*highest_frame - *lowest_frame) + 1;
  glob_frame_obj->frame_obj[new_fr_index].status = 0;
  n_lowest_frame = *lowest_frame;
  n_highest_frame = *highest_frame;
  
  mod   = 0;
  n_mod = 0;
  p_mod = 0;
  
  /* Algorithm is valid only with a sort list */
  qsort((char *)frame_list,nb_add_frame,sizeof(IGRint),comp_increase);
  
  /* First the new negative  frame */
  /* We considered the list in decreasing order */
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
  for(fr_nb = *lowest_frame ; fr_nb <= -1; fr_nb++)
   {
     if(VDSIsFrameSyst(glob_frame_obj->frame_obj, *nb_frame, fr_nb, &fr_syst_index) != 1)
      {
	*bad_frame = fr_nb;
	goto wrapup; /* return 0; */
      }
     n_mod = 0;
     /* How many negative new frame have highest number as the current frame */
     for(i=0;i<nb_add_frame;i++)
      {
        if(frame_list[i] > 0) break;
        else 
          if(frame_list[i] >= glob_frame_obj->frame_obj[fr_syst_index].old_frame_number)
	    n_mod++;  
      }
     /* The new frame number is simply the old one minus the number of
        frame wich are inferior */
     glob_frame_obj->frame_obj[fr_syst_index].new_frame_number = 
       glob_frame_obj->frame_obj[fr_syst_index].old_frame_number - n_mod;  
     if(n_mod != 0 || frame_list[0] < 0)
       glob_frame_obj->frame_obj[fr_syst_index].status =
	 MOD_FRAME | COMP_FRAME | NAME_FRAME;
   }
  
  
  /* Now the same algorithm for positive number */
  for(i = 0 ; i < nb_add_frame ; i++)
   {
     /* p_mod represent how many element have been introduce before
	the current , so the new frame number is update with p_mod */
     if(frame_list[i] <= 0) continue;
     if(*highest_frame < frame_list[i])
      {
        /* Add new highest frame */
	mod++;
	p_mod++;       
	glob_frame_obj->frame_obj[new_fr_index].new_frame_number =
          glob_frame_obj->frame_obj[new_fr_index].old_frame_number =
            n_highest_frame + p_mod;
	glob_frame_obj->frame_obj[new_fr_index].status = CRT_FRAME;
	new_fr_index++;
	glob_frame_obj->frame_obj[new_fr_index].status = 0;
      }
     else
      { 
	mod++;
	glob_frame_obj->frame_obj[new_fr_index].new_frame_number =
	  glob_frame_obj->frame_obj[new_fr_index].old_frame_number = 
	    frame_list[i] + p_mod;
        p_mod++;
        glob_frame_obj->frame_obj[new_fr_index].status = CRT_FRAME;
        new_fr_index++;
        glob_frame_obj->frame_obj[new_fr_index].status = 0; 
      }
   }
  
  /* Now we update the old positive frame */
  for(fr_nb = 0; fr_nb <=  *highest_frame; fr_nb++)
   {
     if(VDSIsFrameSyst(glob_frame_obj->frame_obj, *nb_frame, fr_nb, &fr_syst_index) != 1)
      {
	*bad_frame = fr_nb;
	goto wrapup : /* return 0; */
      }
     p_mod = 0;
     
     /* How many positive new frame have lowest number as the current frame */
     for(i=0;i<nb_add_frame;i++)
      {
        if(frame_list[i] < 0) continue;
        else 
          if(frame_list[i] <= glob_frame_obj->frame_obj[fr_syst_index].old_frame_number)
	    p_mod++;  
      }
     
     /* The new frame number is simply the old one plus the number of
        frame wich are inferior */
     glob_frame_obj->frame_obj[fr_syst_index].new_frame_number = 
       glob_frame_obj->frame_obj[fr_syst_index].old_frame_number + p_mod;  
     if(p_mod != 0 || frame_list[0] < 0)
       glob_frame_obj->frame_obj[fr_syst_index].status =
	 MOD_FRAME | COMP_FRAME | NAME_FRAME;
   }
  
  *nb_frame = *nb_frame + mod;
  
  /*^ for(i = 0; i < *nb_frame; i++)
    {
    printf("Frame_obj %d : old_number = %d new_number %d frame_status = %x\n",
    i, glob_frame_obj->frame_obj[i].old_frame_number,
    glob_frame_obj->frame_obj[i].new_frame_number,
    glob_frame_obj->frame_obj[i].status );
    } 
    */
  
  /* Update the name if new frame number */
  n_lowest_frame  = 9999;
  n_highest_frame = -9999;
  for(i=0;i<*nb_frame;i++)
   {
     if(glob_frame_obj->frame_obj[i].status & NAME_FRAME)
      {
	/* If the name of the occurrence is user defined we don't touch it, */
	/* else we compute it */
	plane_name[0] = '\0';
	user_name     = 0;
	if(VDSGetUserName(&glob_frame_obj->frame_obj[i].frame,
			  frame_def_info->main_info.annot, plane_name, &user_name) != 1)
	  printf("Warning, error getting the name of the plane\n");
	 
	
	if(user_name == 1)
	 {
	   /* User defined name */
	   strcpy(glob_frame_obj->frame_obj[i].frame_name, plane_name);
	 }
	else
	 {
	   /* Define the new name */
	   strcpy(glob_frame_obj->frame_obj[i].frame_name,frame_def_info->main_info.annot);
	   sprintf(tmp,"%d",glob_frame_obj->frame_obj[i].new_frame_number);
	   strcat(glob_frame_obj->frame_obj[i].frame_name,tmp);
	 }
      }
     
     /* Set up the new lowest & highet frame number */
     if(n_lowest_frame >    glob_frame_obj->frame_obj[i].new_frame_number)
       n_lowest_frame  = glob_frame_obj->frame_obj[i].new_frame_number;
     if(n_highest_frame <   glob_frame_obj->frame_obj[i].new_frame_number)
       n_highest_frame = glob_frame_obj->frame_obj[i].new_frame_number;
   }
  new_nb_frame = *nb_frame;
  
  /* Update the frame def section with new lowest and highest frame number */
  /* We must extend some section definitions */
  /* We are just going to extend the minus lowest section and highest section. */
    
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
  if(VDSetFrame(frame_def_info, &new_nb_frame, frame, lowest_frame, highest_frame, bad_frame) != 1)
   {
     /* Impossible to recreate the frame info structure */
     goto wrapup ; /* return 0; */
   }
  
  if(*lowest_frame  != n_lowest_frame)  {*bad_frame = n_lowest_frame;  return 0;}
  if(*highest_frame != n_highest_frame) {*bad_frame = n_highest_frame; return 0;}
  
  if(*nb_frame != new_nb_frame)
    printf("Warning, the number of frames does not match the computed one\n");
    
  /* We have the old frame info and the new frame info structure. There are  */
  /* some info to retrieve from the old one and put to the new one.          */
  /* It is the name (only if the name is user defined)                       */
  /* Remenber that the key of the glob_frame_obj is the old frame name       */
	
	     for(i=0;i<*nb_frame;i++)
	      { 
		if(!(glob_frame_obj->frame_obj[i].status == MOD_FRAME)) continue;
		
		if(VDSIsFrameDef(*frame, new_nb_frame, glob_frame_obj->frame_obj[i].new_frame_number, &frame_index) != 1)
		 {
		   *bad_frame = glob_frame_obj->frame_obj[i].old_frame_number;
		   goto wrapup ; /* return 0; */
		 }
		
		strcpy((*frame)[frame_index].name,glob_frame_obj->frame_obj[i].frame_name);
	      }
  
  
  
  /* Recreate the collections*/
  
  /* Only update frame def collection */
  if(VDCrtFrmDefCol(frame_def_info, &glob_frame_obj->frame_def, 1) != 1)
   {
     printf("Error, cannot update the frame def rg collection\n");
     goto wrapup ; /* return 0; */
   }
  
  /* create a new frame collection */
        
     if(VDCrtFrmCol(*frame, new_nb_frame, *lowest_frame, *highest_frame,
		    &new_frame_info, 0) != 1)
      {
	printf("Error, cannot update the frame info rg collection\n");
	goto wrapup ; /* return 0; */
      }
     /* Change root */
     for(i=0; i<*nb_frame; i++)
      {
	if(glob_frame_obj->frame_obj[i].status & CRT_FRAME) continue;
	
	
	sts = om$send(msg = message NDnode.NDchange_connect(1, 
							    &glob_frame_obj->frame_info, &new_frame_info),
		      senderid = NULL_OBJID,
		      targetid = glob_frame_obj->frame_obj[i].frame.objid,
		      targetos = glob_frame_obj->frame_obj[i].frame.osnum); 
	if(!(sts&1)) 
	 {
	   printf("Cannot change the frame for the frame: %d\n",glob_frame_obj->frame_obj[i].new_frame_number);
	   *bad_frame = glob_frame_obj->frame_obj[i].new_frame_number;
	   goto wrapup ; /* return 0; */
	 }
      } 
     glob_frame_obj->frame_info = new_frame_info;
     /* Delete the old one */
     
  return 1;

  wrapup :
	if ( glob_frame_obj->frame_obj ) _FREE ( glob_frame_obj->frame_obj );
	return 0;

}

/* Compare two IGRint */
static comp_increase(a,b)
IGRint *a,*b;
{

  return((*a == *b) ? 0 : ( *a < *b) ? -1 : 1);
}

end implementation Root;




