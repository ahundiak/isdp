/* $Id: SMInfPlanei.I,v 1.1.1.1 2001/01/04 21:07:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smplane/imp / SMInfPlanei.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMInfPlanei.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:36  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1999/02/12  19:17:12  pinnacle
# Replaced: smplane/imp/SMInfPlanei.I for:  by mdong for vds
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
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
 *	02/11/99	Ming		Created method SMGetSFrameList();
 *					for TR179801899
 *
 * -------------------------------------------------------------------*/

class implementation SMInfPlane;

#include "OMmacros.h"
#include "string.h"
#include "AS_status.h"
#include "msdef.h"
#include "expression.h"
#include "expmacros.h"
#include "nddef.h"
#include "asmacros.h"
#include "vdsmacros.h"
#include "gr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "EMSssprops.h"
#include "refdef.h"

#include "grerr.h"
#include "vds.h"
#include "VDmsg.h"
#include "VDmem.h"
#include "SMmsg.h"
#include "SMdef.h"


#define AS_DEBUG
/* #define DEBUG 1 */
#define INCR 50

extern GRclassid OPP_SMfrm_syst_class_id,OPP_Gexp_class_id;

from Gexp import create;
from expression import NDgive_value;
from GRcontext  import GRgetmodule_env;
from GRcontext  import GRgetinstance;

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
 strcpy(info->type,"Infinite plane ");

 *msg = MSSUCC;
 return(OM_S_SUCCESS);
}


method GRgenabsg(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix; 
		 IGRchar **absgptr)
{
  IGRlong     sts;
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


method  GRgetsize(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix; 
	IGRlong *size)
{
  IGRlong     status;
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
  IGRlong     status;
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

method NDgive_structure(IGRlong *msg; struct ret_struct *p_rs; 
			struct GRmd_env *md_env)
{
  IGRint      status;
  struct GRid plane;

   /* Don't forget that it is also a plane */
  status = om$send(msg = message NDmacro.ACreturn_foot
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

method EMget_props( IGRlong *EMmsg; IGRuchar *props )
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

method	ACconstruct_feet(IGRlong *rc; IGRint cn_type; 
			 IGRint count; struct GRid list[];
			 struct GRmd_env *md_env;
			 IGRint *fcount; struct GRid *feet_list )
{
  IGRlong               status,loc_msg;
  IGRint                rc1;
  IGRlong               sizebuf, nret;
  IGRshort              level ;
  struct GRid           cs,plane;
  IGRdouble             dist,size;
  struct ret_struct     temp1_rts;
  struct IGRdisplay     display;	
  char	 		axe;
  IGRchar               name[80],tmp[80];
  char                  justif[3];
  struct GRvg_construct cst;
  IGRmatrix             matrix,cs_mat;
  IGRshort              mat_type;
  IGRuchar	        props;
  short		        cs_pl;

   /* Construct construction list */
  sizebuf = sizeof(struct IGRdisplay);
  gr$get_active_display(msg     = &loc_msg,
			sizbuf  = &sizebuf,
			buffer  = &display,
			nret    = &nret);

  sizebuf = sizeof(IGRshort);
  gr$get_active_level(  msg     = &loc_msg,
		      sizbuf  = &sizebuf,
		      buffer  = &level,
		      nret    = &nret);

  cst.msg        = &loc_msg;
  cst.newflag    = FALSE;
  cst.geometry   = NULL;
  cst.env_info   = md_env;
  cst.class_attr = NULL;
  cst.name       = NULL;
  cst.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  cst.display    = &display;
  cst.level      = level;

  /*   Retrieve the template : coord syst */
  status = om$send(msg = message ACcpx.ACfind_temp_obj(&rc1,"cs",&cs),
		   targetid = my_id);
  if(!(status & rc1 &1))
   {printf("Erreur retrieve cs template\n"); goto wrapup;}

  /*  Extract the matrix (from the cs or a plane) */
  status = om$send( msg = message NDmacro.ACreturn_foot
		   (&loc_msg , "",&cs, &mat_type, matrix ),
		   targetid = cs.objid,
		   targetos = cs.osnum );
  if(!(status & loc_msg & 1))
   {printf("Erreur retreiving matrix of the cs\n"); goto wrapup; }

  if(!VDget_mat(&cs, mat_type, matrix, cs_mat, &props, &cs_pl))
   {printf("Erreur VDget_mat for objid %d\n",cs.objid); goto wrapup; }

  /* retrieve the distance */
  status = om$send(msg = message ACcpx.ACfind_temp_struct
		   (&rc1, "dist_on_axe",&temp1_rts,md_env),
		   targetid = my_id);
  if(!(status & rc1 &1)){printf("Erreur retrieve dist_on_axe\n"); goto wrapup;}
  dist = temp1_rts.var.root_pm_st.value;

  /* retrieve the axis */
  status = om$send(msg = message ACcpx.ACfind_temp_struct
		   (&rc1, "axe",&temp1_rts,md_env),
		   targetid = my_id);
  if(!(status & rc1 &1)){printf("Erreur retrieve axis\n"); goto wrapup;}
  
  if(temp1_rts.var.text_st.text_string[0] != 'x' &&
     temp1_rts.var.text_st.text_string[0] != 'y' &&
     temp1_rts.var.text_st.text_string[0] != 'z') axe = 'z';
  else axe = temp1_rts.var.text_st.text_string[0];

  if(cs_pl == 1) axe = 'z';

  /* Retrieve the plane_size */
  status = om$send(msg = message ACcpx.ACfind_temp_struct
		   (&rc1,"plane_size",&temp1_rts, md_env),
		   targetid = my_id);
  as$status(action = RET_STATUS);
  if(rc1 & 1) size = temp1_rts.var.root_pm_st.value; else goto wrapup;

  /* Retrieve the justification */
  status = om$send(msg = message ACcpx.ACfind_temp_struct
		   (&rc1, "justif",&temp1_rts,md_env),
		   targetid = my_id);
  if(!(status & rc1 &1))
   {printf("Erreur retrieve justif\n"); goto wrapup;}
  strcpy(justif,temp1_rts.var.text_st.text_string);

  /* Retrieve reverse */
  status = om$send(msg = message ACcpx.ACfind_temp_struct
		   (&rc1,"reverse",&temp1_rts, md_env),
		   targetid = my_id);
  as$status(action = RET_STATUS);
  if(!(rc1 & 1))
    printf("warning,can't retrieve reverse template\n");

  /* If negative orientation, made a xor with orientation  */
  if(temp1_rts.var.root_pm_st.value == 1.0)
   {
     dist = -dist;
     props = props ^ EMSIS_NRML_REVERSED;    
   }

  /* Retrieve texte */
  status = om$send(msg = message ACcpx.ACfind_temp_struct
		   (&rc1, "texte", &temp1_rts, md_env),
		   targetid = my_id);
  as$status(action = RET_STATUS);

  if(rc1 & 1)strcpy(name,temp1_rts.var.text_st.text_string);
  
  /* Construct the plane as feet 0 */
  vd$const_plane (msg     = &rc1,
		  matrix  = cs_mat,
		  axe     = axe,
		  dist    = dist,
		  size    = size,
		  name    = name,
		  justif  = justif,
		  props   = props,
		  cst     = &cst,
		  obj     = &plane);
  if (!(rc1 & 1))
    {
     printf("error in const_plane\n");
     feet_list[0].objid = NULL_OBJID;
   }
  else
   {
     feet_list[0].objid = plane.objid;
     feet_list[0].osnum = plane.osnum;
   }
  
  /* Construct the expression given dist as feet 1 */
  tmp[0] = '\0';
  sprintf(tmp, "%lf",dist >= 0 ? dist : -1 * dist);
  feet_list[1].osnum = OM_Gw_current_OS;

  status = om$construct(classid = OPP_Gexp_class_id,
			osnum   = feet_list[1].osnum,
			p_objid = &feet_list[1].objid);
  as$status(action = RET_STATUS);

  
  status = om$send(msg = message Gexp.create(NULL, tmp , (IGRshort *)&rc1),
		   targetid = feet_list[1].objid,
		   targetos = feet_list[1].osnum);
  if(!(status & rc1 & 1)) feet_list[1].objid = NULL_OBJID;

  *fcount = 2;
  *rc = MSSUCC;
  return OM_S_SUCCESS;

 wrapup:
  *rc = MSFAIL;
  return OM_S_SUCCESS;
}

method SMgive_rel_position(IGRlong *msg;IGRdouble *plane_pos)
{
 IGRlong     status;
 struct GRid expression;

 status = om$send(msg = message NDmacro.ACreturn_foot
		  (msg,"exp",&expression, NULL,  NULL),
		  targetid = my_id);
 if(!(status & *msg &1))
  { *msg = MSFAIL; goto quit;} 

 status = om$send(msg = message expression.NDgive_value(plane_pos),
		  targetid = expression.objid,
		  targetos = expression.osnum);
 if(!(status&1)){ *msg = MSFAIL;goto quit;}
 
 *msg = MSSUCC;

 quit:
 return OM_S_SUCCESS;
}
   

method NDdrawing_copy_geom ( struct GRid *selected_elements;
			     int nb_elements;
			     struct GRid **drawing_elements;
			     int    *nb_drawing_elem;
			     double *vector,*point;
			     int *level;
			     struct IGRlbsys *lbsys;
			     struct GRmd_env *from_env,*to_env)
{
 long        status;
 struct GRid myself;

 myself.objid = my_id;
 myself.osnum  = OM_Gw_current_OS;

 status = VDextract_plane(&myself,drawing_elements, nb_drawing_elem,
			  level,lbsys,from_env,to_env);
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

method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

	long		sts ;	/* OM return code	*/

	/*
	 * name.
	 */
	myDef->info		= SM_I_ObjInfPlane ;
	myDef->type		= 0 ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/

/***************************************************************************/

method SMGetSFrameList( IGRlong *msg; struct SMObjList *list )
{
	IGRlong         status, loc_msg;
   	IGRint		i;
 	IGRlong         sizebuf, nret;
	struct GRmd_env cur_env;
	IGRshort        mx_type, flag;
	OMuint          count;
	GRspacenum      ref_osnum;
	struct GRid     Super, ctx_id;
	IGRmatrix       ctx_matrix;
	IGRchar         osname[OM_K_MAXOSNAME_LEN];
	OM_S_CHANSELECT super_chan;

	
	*msg = MSFAIL;

	if( list->nb_alloc == 0 )
  	{
   	  list->list = _MALLOC( INCR, struct GRobj_env );
   	  list->nb_alloc = INCR;
  	}
 	else if( list->nb_objects >= list->nb_alloc )
  	{
   	  list->list = _REALLOC( list->list,
                         	 (INCR+list->nb_alloc),
				 struct GRobj_env );
	  list->nb_alloc += INCR;
  	}

 	if( list->list == NULL )
  	{
	  printf("Bad dynamic allocation space\n");
	  list->nb_alloc -= INCR;
	  return OM_W_ABORT;
  	}

	sizebuf = sizeof( struct GRmd_env );
  	gr$get_module_env( msg     = &loc_msg,
                    	   sizbuf  = &sizebuf,
                    	   buffer  = &cur_env,
                    	   nret    = &nret );
	if( cur_env.md_id.osnum == OM_Gw_current_OS )
	{
	  list->list[list->nb_objects].mod_env = cur_env;
	}
 	else
	{
     	  status = om$make_chanselect(channame = "Super_rfmgr.to_context",
                                      p_chanselect = &super_chan);
          as$status(action = RET_STATUS);

          /*
	  ** get the context Super
	  */
          status = GRgetctxsuper( &loc_msg, &Super );
          if(!(status&loc_msg&1)) return OM_W_ABORT;

          status = om$get_channel_count( osnum        = Super.osnum,
                                         objid        = Super.objid,
                                         p_chanselect = &super_chan,
                                         count = &count );
          if( !(status&1) ) return status;

          for( i = 0 ; i < count ; ++i )
          {
            /*
	    ** get each context object
	    */
            status =
	    om$send( msg          = message GRcontext.GRgetinstance(
						&loc_msg,
						&mx_type,
						ctx_matrix,
						&ref_osnum,
                        			&flag,&ctx_id),
                     senderid     = Super.objid,
                     targetos     = Super.osnum,
                     p_chanselect = &super_chan,
                     to           = i,
                     from         = i );
            if( !(status&loc_msg&1) ) continue;

            /*
	    ** See if reference file is the one we look for
            ** WARNING: In case of multiple attachement, only first 
	    ** attachement is retrieve
	    */

            if( ref_osnum == OM_Gw_current_OS )
            {
              /*
	      ** see if this object space is active before
              **trying to use this context object.
              */

              status = om$os_number_to_name( osnum=ref_osnum,
                                             osname = osname );
              if( !(status&1) ) continue;

              if ( !(flag&GRACTIVATED_CONTEXT) ) continue;

              status =
	      om$send(msg = message GRcontext.GRgetmodule_env(
					&loc_msg,
					&list->list[list->nb_objects].mod_env),
                      targetid = ctx_id.objid,
                      targetos = ctx_id.osnum );
              as$status(action = RET_STATUS);
              break;
            }
          }
	}

	list->list[list->nb_objects].obj_id.objid = my_id;
	list->list[list->nb_objects].obj_id.osnum = OM_Gw_current_OS;
	list->nb_objects++;


  	*msg = MSSUCC;
  	return(OM_S_SUCCESS);
} /* method SMGetSFrameList */
/*----------------------------------------------------------------------------*/

end implementation SMInfPlane;


