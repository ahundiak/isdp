/* $Id: SMframei.I,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */
 
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/smframe/imp / SMframei.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SMframei.I,v $
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
# Revision 1.3  1996/04/17  14:44:16  pinnacle
# Replaced: smframe/cmd/SMModNotif.I for:  by ksundar for vds.240
#
# Revision 1.2  1995/11/07  22:35:22  pinnacle
# Replaced: ./smframe/imp/SMframei.I for:  by azuurhou for vds.240
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

class implementation SMframe;

#include "string.h"
#include "AS_status.h"
#include "msdef.h"
#include "expression.h"
#include "expmacros.h"
#include "nddef.h"
#include "asmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "OMmacros.h"
#include "EMSssprops.h"

#include "grerr.h"
#include "vds.h"
#include "VDmsg.h"
#include "SMmsg.h"
#include "VDmem.h"


#define AS_DEBUG
/* #define DEBUG 1 */

%safe
static int SMnb_copy =0;
static int SMsize_copy =0;
static struct GRid *SMoriginal = NULL;
static struct GRid *SMclone = NULL;
static struct GRmd_env SMfr_env,SMto_env;
static struct GRid new_owner;
%endsafe

from	SMfrm_syst	import ACadd_component_with_name,ACcreate;
from	ACdiowner	import ACgive_path;
from	expression	import NDgive_value;

extern GRclassid OPP_SMfrm_syst_class_id;

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
  struct GRid frame_def;
  IGRdouble   dist;
  IGRint      status,count;
  IGRlong     loc_msg;
  IGRchar     pos_txt[80];

  *msg = OM_S_SUCCESS;

  strcpy(info->type,"Frame ");
  
  /* Find the ACrg containing glob info of this frame */
  status = om$send(msg = message NDnode.NDget_objects
		   (ND_ROOT,&frame_def,1,NULL,2,2,&count),
		   targetid = my_id);
  if(!(status & 1)) return OM_S_SUCCESS;

  status = om$send( msg = message SMframe.SMgive_rel_position
		   (&loc_msg,&dist),
		   targetid = my_id);
  if(!(status & 1)) return OM_S_SUCCESS;
  
  /* Next function fill pos_txt value only if frame system is in NAME_BY_DIST */ 
  if(SMGetFrmPosTxt(&frame_def,dist,pos_txt))
    sprintf(info->type,"Frame (%s)",pos_txt);

  return(OM_S_SUCCESS);
}

method GRgetname(IGRlong *msg;IGRchar *name)
{
  IGRlong	status;
  struct GRid	my_grid,fr_syst;
  char		dir_name[DI_PATH_MAX],frame_name[DI_PATH_MAX];

  /* Find the owner of the frame */
  status = om$send(msg = message SMframe.SMfind_frm_syst(msg,&fr_syst),
		   targetid = my_id);
  if(!(status & *msg & 1))
   {
     *msg = MSFAIL;
     return OM_S_SUCCESS;
   }

  /* Find the name of the frame system */
  status = om$send(msg = message GRvg.GRgetname(msg,dir_name),
		   targetid = fr_syst.objid,
		   targetos = fr_syst.osnum);
  as$status(action = RET_STATUS);
  if(!(*msg & 1)) return OM_S_SUCCESS;
  
  /* Call to the owner my name */
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  status = om$send(msg = message ACdiowner.ACgive_path
		   (msg,&my_grid,frame_name),
		   targetid =  fr_syst.objid,
		   targetos =  fr_syst.osnum);
  as$status(action = RET_STATUS);
  if(!(*msg & 1)) return OM_S_SUCCESS;

  DIstmcpy(name,dir_name,frame_name,NULL);
  *msg = MSSUCC;
  return OM_S_SUCCESS;
}

method  GRgetsize(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix; 
	IGRlong *size)
{
  IGRlong status;
  struct GRid plane;

  status = om$send(msg = message NDmacro.ACreturn_foot
		   (msg, "plane",&plane,NULL,NULL),
		   targetid = my_id);
  as$status(action = RET_STATUS);

  status = om$send(msg = message GRvg.GRgetsize
		   (msg,matrix_type,matrix,size),
		   targetid = plane.objid,
		   targetos = plane.osnum);
  return status;
}

method GRgetgeom(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix; 
		 IGRchar *geometry)
{
  IGRlong status;
  struct GRid plane;

  status = om$send(msg = message NDmacro.ACreturn_foot
		   (msg, "plane",&plane,NULL,NULL),
		   targetid = my_id);
  as$status(action = RET_STATUS);

  status = om$send(msg = message GRvg.GRgetgeom
		   (msg,matrix_type,matrix,geometry),
		   targetid = plane.objid,
		   targetos = plane.osnum);
  return status;
}

/***************************************************************************/
/*
 * Override this message to avoid setting this object in the Display List.
 */

method GRadd_to_display_list( IGRlong *msg; IGRboolean is_hidden_line )
{
 *msg = MSFAIL;
 is_hidden_line = FALSE;

 return(OM_E_ERROR);
}

/***************************************************************************/



method NDgive_structure(IGRlong *msg; struct ret_struct *p_rs; 
			struct GRmd_env *md_env)
{
  IGRint      status;
  struct GRid plane;

   /* Don't forget that it is also a plane */
  status = om$send(msg = message SMframe.ACreturn_foot
		   (msg, "plane",&plane,NULL,NULL),
		   targetid = my_id);
  as$status(action = RET_STATUS);
  
  if(status & *msg & 1)
    status = as$any_give_structure(go_grid = plane,inst = p_rs,mod_env = md_env);
  
  if(!(status & 1)) *msg = MSFAIL;
  
  p_rs->type |= macro_generic;

  return OM_S_SUCCESS;
} 

method ASreturn_go(struct GRid *go;IGRshort *mat_type;IGRdouble *matrix)
{
  IGRlong status,msg;
  
  status = om$send(msg = message NDmacro.ACreturn_foot
		   (&msg, "plane",go,mat_type,matrix),
		   targetid = my_id);
  as$status(action = RET_STATUS);
  if(!(msg & 1)) return OM_W_ABORT;

  return OM_S_SUCCESS;
}


method  GRdetplane(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix; 
		   struct IGRplane *plane)
{
  struct GRid plane_id;
  IGRlong     status;

  status = om$send(msg = message NDmacro.ACreturn_foot
		   (msg, "plane",&plane_id,NULL,NULL),
		   targetid = my_id);
  as$status(action = RET_STATUS);

  status = om$send(msg = message GRvg.GRdetplane
		   (msg,matrix_type,matrix,plane),
		   targetid = plane_id.objid,
		   targetos = plane_id.osnum);
  as$status(action = RET_STATUS);

  return OM_S_SUCCESS;
}


/* ------------------ method  GRcopy ------------------------- */
/* 4/5/93 : Change in this method . Precedently made nothing   */
/* Now this method copy the PLANE (foot) of the frame          */

method  GRcopy(IGRlong *msg; struct GRmd_env *obj_dsenv;
	       struct GRmd_env *new_dsenv; GRobjid *newobjid)
{
  IGRlong           status;
  struct GRid       plane;

  status = om$send(msg = message NDmacro.ACreturn_foot
		   (msg, "plane",&plane,NULL,NULL),
		   targetid = my_id);
  as$status(sts = (status & *msg),action = RET_STATUS);
  
  status = om$send(msg = message GRgraphics.GRcopy
		   (msg,obj_dsenv,new_dsenv,newobjid),
		   targetid = plane.objid,
		   targetos = plane.osnum);
  as$status(sts = (status & *msg),action = RET_STATUS);

  return status; 
}


method NDcopy(long *msg;IGRint cp_type;
 		 struct GRmd_env *fr_env,*to_env;struct GRid *newobjid)
{
 SMnb_copy = 0;
 SMfr_env = *fr_env;
 SMto_env = *to_env;
 new_owner.objid = NULL_OBJID;
 return om$send(msg = message nci_macro.NDcopy
					(msg,cp_type,fr_env,to_env,newobjid),
		targetid = my_id,
		mode = OM_e_wrt_message);
}

method NDconnect(int nb_root; struct GRid *root; struct GRid original;
		 IGRint type)
{
  long               status = OM_S_SUCCESS,loc_msg;
  struct GRid        new_root[4],orig_root[4];
  int                i,j,count;
  char               name_fr_syst[DI_PATH_MAX],fr_old_name[DI_PATH_MAX];
  struct GRid        old_owner,component;
  DIobjid            tmp_id;
  extern IGRboolean  dynamics_in_progress;

  if(SMnb_copy + 5 > SMsize_copy)
   {
    SMsize_copy += 20;
    if(SMoriginal)
     {
      SMoriginal = _REALLOC(SMoriginal, SMsize_copy, struct GRid);
      SMclone = _REALLOC( SMclone, SMsize_copy, struct GRid);
     }
    else
     {
      SMoriginal = _MALLOC(SMsize_copy, struct GRid);
      SMclone = _MALLOC(SMsize_copy, struct GRid);
     }
    if(!SMoriginal || !SMclone) {SMsize_copy = 0; return OM_W_ABORT;}
   }

  if(original.objid == NULL_OBJID) goto wrapup;
  
  /* In the following code original.objid != NULL_OBJID */

  /* get parents of original */
  status = om$send(msg = message NDnode.NDget_objects
		   (ND_ROOT,orig_root,4,
		    NULL,0,OM_K_MAXINT,&count),
		   targetid = original.objid,
		   targetos = original.osnum);
  if(!(status&1)) goto wrapup;
  
  for(i=0;i<count && i<4;i++)
   {
     /* root has changed ? */
     if(root[i].objid != orig_root[i].objid ||
	root[i].osnum != orig_root[i].osnum) 
      {
	new_root[i] = root[i];
	continue;
      }
     /* Root already copied ? */
     for(j=0;j<SMnb_copy;j++)
      {
	if(root[i].objid == SMoriginal[j].objid &&
	   root[i].osnum == SMoriginal[j].osnum) 
	 {
	   new_root[i] = SMclone[j];
	   break;
	 }
      }
     if(j<SMnb_copy) continue;
     
     
     /* Copy it (execp for the cs that we can be connected to the existing) */
     /* one */
     if(i==0)
      {
	new_root[i] = root[i];
	SMoriginal[SMnb_copy] = orig_root[i];
	SMclone[SMnb_copy++] = new_root[i];
      }
     else
      {
	/* */
	status = om$send(msg = message NDnode.NDcopy(&loc_msg,0,&SMfr_env,
						     &SMto_env,new_root+i),
			 targetid = orig_root[i].objid,
			 targetos = orig_root[i].osnum);
	as$status(action = RET_STATUS);
#ifdef DEBUG
	printf("copy de objid = %d en new_objid = %d\n",
	       orig_root[i].objid,new_root[i].objid);
#endif
	status = om$send(msg= message NDnode.NDchg_state
			 (ND_DEL_NO_CH,ND_DEL_NO_CH),
			 targetid = new_root[i].objid,
			 targetos = new_root[i].osnum);
	SMoriginal[SMnb_copy] = orig_root[i];
	SMclone[SMnb_copy++] = new_root[i];
	
      }
   }
  root = new_root;

  if(dynamics_in_progress) goto wrapup; /* Don't care about owner */
  
  if(new_owner.objid == NULL_OBJID)
   {
     int ind,k;
     
     status = om$send(msg = message SMframe.SMfind_frm_syst
		      (&loc_msg,&old_owner),
		      targetid = original.objid,
		      targetos = original.osnum);
     if(!status & loc_msg & 1)
      {printf("Problem find fr_syst of %d\n",original.objid);goto wrapup;}
     
     status = om$send(msg = message GRowner.GRcopy_owner
		      (&loc_msg,&SMfr_env,&SMto_env,&new_owner.objid),
		      targetid = old_owner.objid,
		      targetos = old_owner.osnum);
     if(!(status & loc_msg & 1))
      {printf("Problem copy fr_syst\n");goto wrapup;}
     new_owner.osnum = SMto_env.md_id.osnum;
     
     status = om$send(msg = message SMfrm_syst.GRgetname
		      (&loc_msg,name_fr_syst),
		      targetid = old_owner.objid,
		      targetos = old_owner.osnum);
     if(!(status & loc_msg & 1))
      {printf("Problem get fr_syst name\n");
       new_owner.objid = NULL_OBJID;goto wrapup;}	 
     
     /* Generate a default name and put the name to the new fr_syt */
     k = strlen(name_fr_syst);
     for(ind=1;ind<1000;ind++)
      {
	sprintf(&name_fr_syst[k],"%d",ind);
	status = di$translate(objname = name_fr_syst,
			      p_objid = &tmp_id);
	if(!(status&1))
	 {
	   status = om$send(msg = message SMfrm_syst.ACcreate
			    (&loc_msg,name_fr_syst),
			    targetid = new_owner.objid,
			    targetos = new_owner.osnum);
	   if(!(status & loc_msg & 1))
	    {printf("Problem ACcreate\n");goto wrapup;}
	   break;
	 }
      }
#ifdef DEBUG
     printf("New owner objid = %d name = %s cree\n",
	    new_owner.objid,name_fr_syst);
#endif
   }
  
  /* Add the frame name to the new owner */
  status = om$send(msg = message SMframe.GRgetname(&loc_msg,fr_old_name),
		   targetid = original.objid,
		   targetos = original.osnum);
  if(!(status & loc_msg & 1))
   {printf("Problem get name of %d\n",original.objid);goto wrapup;}
  
  component.objid = my_id; component.osnum = SMto_env.md_id.osnum;
  status = om$send(msg = message SMfrm_syst.ACadd_component_with_name
		   (&loc_msg,&component,fr_old_name),
		   targetid = new_owner.objid,
		   targetos = new_owner.osnum);
  if(!(status & loc_msg & 1))
   {printf("Problem add component %d\n",component.objid);goto wrapup;}	
  

 wrapup:
  status = om$send( msg = message nci_macro.NDconnect
		   (nb_root,root,original,type),
		   targetid = my_id,
		   mode = OM_e_wrt_message);
  if ( SMoriginal ) _FREE ( SMoriginal );
  if ( SMclone ) _FREE ( SMclone );
  return status;
}

method EMget_props(IGRlong *EMmsg; IGRuchar *props)
{
  IGRlong     status,msg;
  struct GRid plane;
  
  status = om$send(msg = message NDmacro.ACreturn_foot
		   (&msg, "plane",&plane,NULL,NULL),
		   targetid = my_id);
  as$status(action = RET_STATUS);
  
  status = om$send(msg = message EMSsubbs.EMget_props
		   (EMmsg, props),
		   targetid = plane.objid,
		   targetos = plane.osnum);
  as$status(action = RET_STATUS);
  return status;
}

method GRgetrang(IGRlong *msg;IGRshort *matrix_type; IGRmatrix matrix; 
	IGRboolean *world; GRrange range)
{
  IGRlong     status;
  struct GRid plane;
  
  status = om$send(msg = message NDmacro.ACreturn_foot
		   (msg, "plane",&plane,NULL,NULL),
		   targetid = my_id);
  as$status(action = RET_STATUS);

  status = om$send(msg = message GRgraphics.GRgetrang
		   (msg,matrix_type,matrix,world,range), 
		   targetid = plane.objid,
		   targetos = plane.osnum);
  as$status(action = RET_STATUS);
  return status;
}  

/* Given the objid of a frame, give it's frame number */
method SMfind_frame_num(IGRlong *msg;IGRint *fr_number)
{
  IGRlong     status;
  IGRint      count = 0;
  struct GRid expression;
  IGRdouble   fr_num;

  status =  om$send(msg = message NDnode.NDget_objects
		    (ND_ROOT, &expression,1, NULL, 1, 1, &count),
		    senderid = NULL_OBJID,
		    targetid = my_id); 

  if(!(status&1) || ! count ) {*msg = MSFAIL;return OM_S_SUCCESS;}
   
  status = om$send(msg = message expression.NDgive_value(&fr_num),
		   senderid = NULL_OBJID,
		   targetid = expression.objid,
		   targetos = expression.osnum);
  if(!(status&1)) {*msg = MSFAIL;return OM_S_SUCCESS;}
  
  *fr_number = (IGRint)fr_num;
  *msg = MSSUCC;
  return OM_S_SUCCESS;
}  

/* Returns corresponding frame system */
/* Return 0 if not found */
method SMfind_frm_syst(IGRlong *msg;struct GRid *fr_syst)
{
 GRclassid       obj_class;
 int             index;
 long            status;
 OM_S_CHANSELECT owner;

/*| Is there an owner eligible */

 status = om$make_chanselect(channame = "GRconnector.to_owners",
			      p_chanselect = &owner);
 as$status(action = RET_STATUS);
 if(status != OM_S_SUCCESS) { *msg = MSFAIL; return OM_S_SUCCESS; }

  index = 0;
  while(1)
    {
     status = om$get_objid_at_index(objid = my_id,
				    p_chanselect = &owner,
				    index = index++,
				    objidaddr = &fr_syst->objid,
				    osnumaddr = &fr_syst->osnum);
     if(!(status&1)) break;

     status = om$get_classid (objid     = fr_syst->objid,
                              osnum     = fr_syst->osnum,
                              p_classid = &obj_class);

     if(om$is_ancestry_valid(subclassid = obj_class,
                             superclassid=OPP_SMfrm_syst_class_id)==OM_S_SUCCESS)
        {
	  *msg = MSSUCC;
	  return OM_S_SUCCESS;
	}
   }

 /*| There is no diowner eligible */

 fr_syst->objid = NULL_OBJID;
 *msg = MSFAIL;
 return OM_S_SUCCESS;
}


method SMgive_rel_position(IGRlong *msg;IGRdouble *frame_pos)
{
 IGRlong     status;
 struct GRid expression;
 IGRuchar    props;
 IGRlong     loc_msg;
 
 status = om$send(msg = message NDmacro.ACreturn_foot
		  (&loc_msg,"exp",&expression, NULL,  NULL),
		  targetid = my_id);
 if(!(status & loc_msg &1))
  { *msg = MSFAIL; goto quit;} 

 status = om$send(msg = message expression.NDgive_value(frame_pos),
		  targetid = expression.objid,
		  targetos = expression.osnum);
 if(!(status&1)){ *msg = MSFAIL;goto quit;}


 /* Jean : 26 July 93 : Modif of distance to change sign if EMSIS_NRML_REVERSED*/
 status = om$send(msg = message SMframe.EMget_props
		  (&loc_msg, &props),
		  targetid = my_id);
 if((status & loc_msg & 1) && (props & EMSIS_NRML_REVERSED))
  {
    *frame_pos *= -1;      /* To dekludge the frame position : */
			  /* negative if reverse.             */
  } 
 
 *msg = MSSUCC;

 quit:
 return OM_S_SUCCESS;
}

method GRgenabsg(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix; 
		 IGRchar **absgptr)
{
  IGRlong sts;
  struct GRid plane;

  sts = om$send(msg = message NDmacro.ACreturn_foot
		(msg, "plane",&plane, NULL,  NULL),
		targetid = my_id);
  as$status(sts = sts);

  if(!(*msg & 1))
    return OM_S_SUCCESS;
  
  sts = om$send(msg = message GRvg.GRgenabsg
		(msg,matrix_type,matrix,absgptr),
		targetid = plane.objid,
		targetos = plane.osnum);
  as$status(sts = sts);

  return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------------*/
method DIgive_output( char *output ) {

	long		sts,
			msg ;
	VDobjDef	objDef ;
	extern char 	*VDmsgkey2string __(( long msgkey )) ;

	/*
	 * Pretty-print yourself in "Display Directory Command" form.
	 */
	sts = om$send(	msg 	= message SMframe.SMgetObjDef( &msg, &objDef ),
			targetid= my_id ) ;

	if( sts & 1 & msg ) {
		strcat( output, "[" ) ;
		strcat( output, VDmsgkey2string( objDef.info ) ) ;
		strcat( output, "]" );
	} else {
		/*
		 * Just in case the messages failed ...
		 */
		strcat( output, "()" ) ;
	}

	return OM_S_SUCCESS ;

} /* method DIgive_output */

/*----------------------------------------------------------------------------*/

method SMgetObjDef( long *msg ; VDobjDef *myDef ) {

	long		sts ;	/* OM return code	*/

	/*
	 * name.
	 */
	myDef->info		= SM_I_ObjFrame ;
	myDef->type		= 0 ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method SMgetObjdDef */
/*----------------------------------------------------------------------------*/

end implementation SMframe;


