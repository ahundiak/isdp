
/* $Id: VRplanei.I,v 1.5 2002/05/01 20:54:11 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrplane / VRplanei.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRplanei.I,v $
 *	Revision 1.5  2002/05/01 20:54:11  louis
 *	Remove kudges for tr5415
 *	
 *	Revision 1.4  2002/04/10 19:58:00  louis
 *	TR5649-standardize tolerances
 *	
 *	Revision 1.3  2001/02/20 01:15:33  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/12 23:34:20  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/23  23:39:26  pinnacle
# Created: route/vrplane/VRplanei.I by lawaddel for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1998/03/29  10:21:56  pinnacle
# Replaced: vrplane/VRplanei.I for:  by apazhani for route
#
# Revision 1.2  1998/03/27  20:22:22  pinnacle
# Replaced: vrplane/VRplanei.I for:  by azuurhou for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/17  17:33:16  pinnacle
# Replaced: vrplane/VRplanei.I for:  by r240_int for route240
#
 *
 * History:
 *	01/15/96	tlb	Add prototypes
 *	03/27/98	alwin	Control GRxform broadcast recompute.
 *	03/29/98	alwin	Removed the above modifications.
 *      04/08/02        law     TR5649-standardize tolerance with VRGetTol
 *      05/01/02        law     tr5415-Add NDchildren_deleted method
 *
 *************************************************************************/
class implementation VRplane;
/*

HISTORY
-------

  DP 11-13-89 : Design date
  BD 06-11-92 : Change buffers size in disp_dummy_plan() function which used
		to write out of their range.
*/

#include "igrdef.h"    
#include "igr.h"    
#include "grdpbdef.h"    
#include "grdpbmacros.h"    
#include "grerr.h"
#include "grownerdef.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "nddef.h"
#include "AS_status.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "dp.h"    
#include "nddef.h"    
#include "ndmacros.h"    
#include "asbox.h"    

#include "msdef.h"
#include "msmacros.h"
#include "VRMath.h"
#include "EMS.h"
#include "bs.h"
#include "msdef.h"
#include "maerr.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "matypemx.h"
#include "maidmx.h"
#include "mainvmx.h"
#include "mamulmx.h"
#include "gocmacros.h"                  /* Has GRgetabsg macro */
#include "vrdbgmacros.h"

#define AS_DEBUG

from	ACpretendin	import	ACiconnect;

extern	GRclassid	OPP_ACpretendin_class_id;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                           method NDchildren_deleted                        */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
method NDchildren_deleted( IGRlong *msg;
                           IGRint count_deleted; struct GRid list_deleted [];
                           struct GRid *new_obj; struct GRmd_env *md_env)
{
    long status;
    struct GRid  my_grid;
    IGRchar my_state, ClassName[128];
    int i,j,n_ch;
    struct GRid *children;

    SetProc( VRplane_NDchildren_deleted ); Begin;

    /* Is the element support only ? */

    new_obj->objid = my_id;
    new_obj->osnum = OM_Gw_current_OS;

    __DBGpr_obj(" Me!", *new_obj );

    status = om$send(msg = message NDnode.NDget_state(&my_state),
                     targetid = my_id);
    __DBGpr_int(" my state",my_state);

    if(!(status&1) || !(my_state&ND_DEL_NO_CH))
    {
        End
        return OM_S_SUCCESS;
    }

    /* Get its children */

    status = om$send(msg = message NDnode.NDget_objects(ND_CHILDREN | ND_IN_BUF,
                                         NULL,0,&children,0,OM_K_MAXINT,&n_ch),
                     targetid = my_id);
    as$status(action = RET_STATUS);

    __DBGpr_objlist(" my kids",n_ch,children);
    __DBGpr_objlist(" delete list", count_deleted, list_deleted);

    /* Are there deleted as well */

    for(i=0;i<n_ch;i++)
    {
        for(j=0;j<count_deleted;j++)
        {
            if( children[i].objid == list_deleted[j].objid &&
                children[i].osnum == list_deleted[j].osnum)
                break;
        }

        if(j>=count_deleted)
        {
                om$get_classname( objid         = children[i].objid,
                                  classname     = ClassName );

                if( strcmp( ClassName, "VRcompoint" ) != 0 )
                {
                    /* The plane object has a child that is -
                     *    [1] Not in the delete list
                     *    [2] Not a compoint (i.e., it could be a line
                     *        segment or a CCOMP or ...).
                     *
                     * Therefore, this plane should not be deleted.
                     */

                    End
                    return OM_S_SUCCESS;
                }
        }
    }

    /*| all the children are deleted --> the element can be deleted */
    /* Either that - or that it is a plane with ONLY VRcompoint object(s) as
     * its child(ren) - which can safely be deleted. */

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;

    nd$wait_batch(type = GR_DELETED,
                  nb_obj = 1,
                  l_object = &my_grid);
    End
    return(OM_S_SUCCESS);
}
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                           method GRlocate_owner                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method GRlocate_owner
  (
  IGRlong          *p_msg;        /* OUT    Return code of the method         */
  struct GRlc_cvl  *p_cvl;        /* IN     Module and action handler info    */
  struct GRlc_path *p_path;       /* IN/OUT The locate path of objects        */
  IGRint           *p_path_pos    /* IN/OUT Position of the obj in the path   */
  )
  /*
  DESCRIPTION: Locate directly the object of class VRplane.
  */
  {
  IGRlong     status;             /* Status returned by om                    */
  int         index;              /* Index for a loop                         */

  SetProc( VRplane_GRlocate_owner ); Begin
  /*| Store the locate point */

if (p_cvl->attributes.type == GR_pt_loc ||
    p_cvl->attributes.type == GR_bl_loc)
 {
  for(index=0; index<3; index++)
     me->origin[index] = p_cvl->attributes.acc_point[index];
 }

  /*| Locate my object */

  status = om$send
             (msg      = message ASnode.GRlocate_owner
                                 (p_msg, p_cvl, p_path, p_path_pos),
              mode     = OM_e_wrt_message,
              targetid = my_id,
              targetos = OM_Gw_current_OS);
  End
  return(status);
}/* end GRlocate_owner*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             method GRxform                                 */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method GRxform
  (
  IGRlong          *p_msg;        /* OUT    Return code of the method         */
  struct GRmd_env  *p_md_env;     /* IN     Module environment                */
  IGRshort         *p_matrix_type;/* IN     type of the matrix                */
  IGRmatrix        matrix;        /* IN     Matrix of the transformation      */
  GRobjid          *p_new_objid   /* OUT    New object created                */
  )
  /*
  DESCRIPTION: Transform the geometry of this object by a matrix
  */
  {
  IGRint      cn_type;            /* Type for the batch                       */
  struct GRid my_grid;            /* My object identifier                     */
  extern IGRboolean ASbroadcast_in_progress; /* JLA'S MAGIC                   */

  SetProc( VRplane_GRxform ); Begin 

  if(me->plane_state&VR_FIXED_PLANE)
   {
    ex$message( 	field   = ERROR_FIELD,
            		in_buff = "PLANE IS LOCKED" );

    *p_msg = MSSUCC;
    *p_new_objid = my_id;
    End
    return(OM_S_SUCCESS);
   }

  /*| Compute the new origin and vector of the plane */

  VRmatpoint(p_msg, matrix, me->origin, me->origin, 1.);
  VRmatpoint(p_msg, matrix, me->normal, me->normal, 0.);

  /*| Notify the modification to the batch */

  __DBGpr_com( " Notify the modification to the batch " );

  if(!ASbroadcast_in_progress)
  {
	__DBGpr_com( " Yeah! It's on batch now " );
	my_grid.objid = my_id;
	my_grid.osnum = OM_Gw_current_OS;
	cn_type = ND_COMP_XF;

	nd$wait_batch(type    = GR_GEOM_POSTED,
		   l_object   = &my_grid,
		   l_obj_info = &cn_type,
		   nb_obj     = 1 );
  }/* end if */
  *p_msg = MSSUCC;
  *p_new_objid = my_id;

  End
  return(OM_S_SUCCESS);
}/* end GRxform */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                           method NDgive_structure                          */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDgive_structure
  (
  IGRlong            *p_msg;      /* OUT    Return code of the method         */
  struct  ret_struct *p_str;      /* OUT    Returned structure                */
  struct  GRmd_env   *p_info      /* IN     Pointer to the module environment */
  )
  /*
  DESCRIPTION: Return the instances of the object in a CS structure
               the normal is the Z axis of the CS. i.e -> cs[2], cs[6], cs[10],
               the origin is the origin of the CS. i.e -> cs[3], cs[7], cs[11].
               The other coordinates (X_vector, Y_vector and projections are not
               initialized).
  */
  {
/*   SetProc( VRplane_NDgive_structure ); Begin */
  /*| Fill the ref structure */

  p_str->type = plan_type;
/*  status = VRplan_matrix(p_msg, me->origin, me->normal, p_str->var.ref_st.t);
*/
  GRabsg_del_all();
  /*^
  int index;
  for (index=0; index<3; index++)
    {
    printf("me->origin[%d]=%lf\n",index,me->origin[index]);
    printf("me->normal[%d]=%lf\n",index,me->normal[index]);
  }*/

  p_str->var.ref_st.t[0] = me->origin[0];
  p_str->var.ref_st.t[1] = me->origin[1];
  p_str->var.ref_st.t[2] = me->origin[2];
  p_str->var.ref_st.t[3] = me->normal[0];
  p_str->var.ref_st.t[4] = me->normal[1];
  p_str->var.ref_st.t[5] = me->normal[2];

  /* ET LE TYPE BORDEL !!!!!! */
  p_str->type = debug_type;

/*  End */
  return(OM_S_SUCCESS);
}/* end NDgive_structure*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                method NDplace                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDplace
  (
  struct GRas     *p_assoc_list;  /* IN     Pointer to the assoc data         */
  struct GRmd_env *p_md_env;      /* IN     Pointer to the module environment */
  char            *p_go_cnst_lis  /* IN     Pointer to the graphic data       */
  )
  /*
  DESCRIPTION: Given an origin and normal, this method places the instances of a VRplane
               object.
  */
  {
  double    *plane_inst;          /* data defining the plane                  */
  IGRlong     status;             /* Status returned by om                    */
  SetProc( VRplane_NDplace ); Begin
  if( ( p_assoc_list ) && ( p_assoc_list->as_attr ) )
  {
    plane_inst = (double *)p_assoc_list->as_attr;

    /*| Fill the plane instances */

    me->origin[0] = plane_inst[0];
    me->origin[1] = plane_inst[1];
    me->origin[2] = plane_inst[2];
    me->normal[0] = plane_inst[3];
    me->normal[1] = plane_inst[4];
    me->normal[2] = plane_inst[5];
  }

  status = om$send
             (msg = message NDnode.NDchg_state 
			( (IGRchar) ND_DEL_NO_CH | ND_WAIT_DEL, 
			  (IGRchar) ND_DEL_NO_CH | ND_WAIT_DEL),
              targetid = my_id);
  End
  return(status);

}/* end NDplace*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method VRpostabsg                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRpostabsg
  (
  long              *p_msg;         /* OUT    Completion code                 */
  struct GRmd_env   *p_md_env;      /* IN     Current module environment      */
  struct ret_struct *p_str          /* IN     Geometry to update              */
  )
  /*
  DESCRIPTION: Given a CS matrix return structure, this method post the instances
               of an VRplane object.
               the normal is the Z axis of the CS. i.e -> cs[2], cs[6], cs[10],
               the origin is the origin of the CS. i.e -> cs[3], cs[7], cs[11].
               The other coordinates (X_vector, Y_vector and projections are not
               used).
  NOTE:        This method is written to replace the GRpostabs of the Graphic
               object.
  */
  {

  SetProc( VRplane_VRpostabsg ); Begin
  if(me->plane_state&VR_FIXED_PLANE)
   {
    *p_msg = MSFAIL;
    End
    return(OM_S_SUCCESS);
   }

  /*| Put the instances */

  me->origin[0] = p_str->var.ref_st.t[3];
  me->origin[1] = p_str->var.ref_st.t[7];
  me->origin[2] = p_str->var.ref_st.t[11];
  me->normal[0] = p_str->var.ref_st.t[2];
  me->normal[1] = p_str->var.ref_st.t[6];
  me->normal[2] = p_str->var.ref_st.t[10];

  if(p_md_env->md_env.matrix_type!=MAIDMX)
    {
    /*| Compute the origin and vector of the plane */

    VRmatpoint(p_msg, p_md_env->md_env.matrix, me->origin, me->origin, 1.);
    VRmatpoint(p_msg, p_md_env->md_env.matrix, me->normal, me->normal, 0.);
  }/* end if(p_md_env->md_env.matrix_type*/

  End
  return(OM_S_SUCCESS);
}/* end VRpostabs */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                              method NDdisplay                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDdisplay
  (
  IGRint          dp_type;          /* IN     Purpose of display              */
  enum GRdpmode   mode;             /* IN     Display mode                    */
  struct GRmd_env *p_md_env         /* IN     Module environment              */
  )
  /*
  DESCRIPTION: Displays an VRplane object (Just a display by buffer)
  */
  {
  struct GRid my_grid;              /* My object identifier                   */
  long        msg;                  /* Completion code                        */
  IGRmatrix	*MatList[1];	/* Array of matrix for display */

  SetProc( VRplane_NDdisplay ); Begin
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  MatList[0] = (IGRmatrix *) p_md_env->md_env.matrix;

  dp$display
    (msg      = &msg,
     num_elem = 1,
     oids     = &my_grid,
     mode     = mode,
     matrix   = MatList,
     mtx_type = &p_md_env->md_env.matrix_type);

  End
  return(OM_S_SUCCESS);
}/* end NDdisplay*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method GRdisyourself                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method GRdisyourself
  (
  IGRlong       *p_msg;           /* OUT    Return code of the function       */
  IGRshort      *p_mat_type;      /* IN     Matrix type to used with this G.O.*/
  IGRdouble     *matrix;          /* IN     Matrix to used with this G.O.     */
  enum GRdpmode *p_mode;          /* IN     Display mode                      */
  struct IGRaltdisplay  *alt_symb;/* IN     Alternate display attributes      */
  struct DP_information *sp_info; /* IN     Special display information       */
  OM_p_KEY_DESC         range_key /* IN     Pointer to range info             */
  )
  /*
  DESCRIPTION: This method loads the data necessary to display a graphic object
  */
  {
  IGRlong     status;             /* Status returned by om                    */

   SetProc( VRplane_GRdisyourself ); Begin
  /*| Display the element */

  if(*p_mode==GRbdhd)
     disp_dummy_plan(p_msg,me->origin, me->normal, GRhd, sp_info);
  else if(*p_mode!=GRbd)
    disp_dummy_plan(p_msg,me->origin, me->normal, *p_mode, sp_info);

  status = om$send
             (msg = message ASnode.GRdisyourself(p_msg,p_mat_type,
                            matrix, p_mode,alt_symb, sp_info, range_key),
              mode = OM_e_wrt_message,
              targetid = my_id);

  End
  return(OM_S_SUCCESS);
}/* end GRdisyourself*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                              method GRdetplane                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method GRdetplane
  (
  IGRlong            *p_msg;      /* OUT    Return code of the method         */
  IGRshort           *p_mat_type; /* OUT    matrix type to used with this G.O.*/
  IGRdouble          *matrix;     /* OUT    matrix to used with this G.O.     */
  struct  IGRplane   *p_plane     /* OUT    Pointer to the plane info         */
  )
  /*
  DESCRIPTION: Return pointer to the instances of the object in a plane 
               structure.
  */
  {
  IGRlong	retmsg;
  int                index;       /* Index for a loop                         */
  IGRint	i;

  SetProc( VRplane_GRdetplane ); Begin

  /* 
  if(p_mat_type) *p_mat_type = MAIDMX;
  if(matrix)     MAidmx(p_msg,matrix);
  */

  /*| Fill the plane structure */

  /*
  */
MAtypemx (&retmsg,matrix,p_mat_type);
if (*p_mat_type != MAIDMX)
    {
    for (i=0;i<3;i++)
	{
	p_plane->normal [i] =	me->normal [0] * matrix [i*4] +
				me->normal [1] * matrix [i*4+1] +
				me->normal [2] * matrix [i*4+2];
	}
    for (i=0;i<3;i++)
	{
	p_plane->point [i] =	me->origin [0] * matrix [i*4] +
				me->origin [1] * matrix [i*4+1] +
				me->origin [2] * matrix [i*4+2] +
				matrix [i*4+3];
	} 
    }
else
    {
    for(index=0; index<3; index++)
	{
	p_plane->normal[index] = me->normal[index];
	p_plane->point[index]  = me->origin[index];
	} 

	/*"normal = %f %f %f\n", p_plane->normal[0],p_plane->normal[1],p_plane->normal[2] */ 
	/*"point  = %f %f %f\n", p_plane->point[0],p_plane->point[1],p_plane->point[2]    */ 

    } /* end if */

End
return(OM_S_SUCCESS);

}/* end GRdetplane*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method GRgetobjinfo                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method GRgetobjinfo
  (
  IGRlong           *p_msg;         /* OUT    Returned code                   */
  struct GRobj_info *p_info         /* OUT    Returned information            */
  )
  /*
  DESCRIPTION: Get the object information
  */
  {
  SetProc( VRplane_GRgetobjinfo ); Begin
  *p_msg = MSSUCC;
  strcpy(p_info->type,"Construction Plane");
  End
  return(OM_S_SUCCESS);
}/* end GRgetobjinfo */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                              method GRgetsymb                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method GRgetsymb
  (
  IGRlong            *p_msg;        /* OUT    Returned code                   */
  struct GRsymbology *p_info        /* OUT    Returned symbology              */
  )
  /*
  DESCRIPTION: Avoid to return a stupid level
  */
  {
  *p_msg = GR_I_NO_LAYER;
  return(OM_S_SUCCESS);
}/* end GRgetsymb */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             method GRkeypoint                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method GRkeypoint
  (
  IGRlong            *p_msg;      /* OUT    Returned code                     */
  IGRshort           *p_mat_type; /* IN     matrix type to used with this G.O.*/
  IGRdouble          *matrix;     /* IN     matrix to used with this G.O.     */
  struct IGRline     *boreline;   /* IN     Boreline of the locate            */
  IGRpoint           keypoint;    /* OUT    Key point                         */
  struct GRparms     *key_parm    /* OUT    Key parameters                    */
  )
  /*
  DESCRIPTION: Return the key point of a plane (origin)
  */
  {
  int         index;              /* Index for a loop                         */
 
  SetProc( VRplane_GRkeypoint ); Begin
  *p_msg = MSSUCC;

  /*| Give the origin of the plane */

  for(index=0; index<3; index++) keypoint[index]=me->origin[index];

  if(*p_mat_type!=MAIDMX)
    {
    /*| Compute the origin of the plane */

    VRmatpoint(p_msg, matrix, keypoint, keypoint, 1.);
   }/* end if(*p_mat_type)*/
  End
  return(OM_S_SUCCESS);
}/* end GRkeypoint */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             method NDcompute_node                          */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDcompute_node
  (
  IGRlong            *p_msg;      /* OUT    Returned code                     */
  IGRint             cn_type;     /* IN     Type of compute                   */
  int                count;       /* IN     Number of parents                 */
  struct GRid        list[];      /* IN     List of parents                   */
  struct GRmd_env    *p_md_env    /* IN     Pointer to the environment        */
  )
  /*
  DESCRIPTION: Compute the coordinates if the plane is attached to a coordinate
               system.
  */
  {
  struct ret_struct  ret_str;     /* Structure of the coordinate system       */
  long               status;      /* Status returned by om                    */
  short              four=4;      /* Dimension of a matrix                    */
  IGRmatrix          matrix;      /* Temporary matrix for compute             */
 
  SetProc( VRplane_NDcompute_node ); Begin
  if(count>0)
    {
    status = om$send(msg = message NDnode.NDgive_structure
                                          (p_msg,&ret_str,p_md_env),
                      targetid = list->objid,
                      targetos = list->osnum);
    as$status(action = RET_STATUS);

    /*| Test if the compute is after an xform */

    if(cn_type & ND_COMP_XF)
      {
      /*| Get the new local coordinates from global coordinates */

      MAinvmx(p_msg,&four,ret_str.var.ref_st.t,matrix);
      VRmatpoint(p_msg,matrix,me->origin,me->loc_origin, 1.);
      VRmatpoint(p_msg,matrix,me->normal,me->loc_normal, 0.);
      }
    else
      {
      /*| Get the new global coordinates from local coordinates */

      VRmatpoint(p_msg,ret_str.var.ref_st.t,me->loc_origin,me->origin, 1.);
      VRmatpoint(p_msg,ret_str.var.ref_st.t,me->loc_normal,me->normal, 0.);
    }/* end if(cn_type)*/
  }/* end if(count)*/
 End
 return(OM_S_SUCCESS);
}
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             method NDattach_to_cs                          */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDattach_to_cs
  (
  IGRlong *p_msg;
  struct GRid cs_grid;
  struct GRid contents;
  struct GRid *as_grid;
  struct GRmd_env *p_md_env
  )
  /*
  DESCRIPTION: attach the plane to a coordinate system
  */
  {
  long               status;      /* Status returned by om                    */
  short              four=4;      /* Dimension of a matrix                    */
  IGRmatrix          matrix;      /* Temporary matrix for compute             */
  struct ret_struct  ret_str;     /* Structure of the coordinate system       */
  struct GRid        my_grid;     /* My identifier                            */

  /*| Look for a possible cycle in the graph   */
  SetProc( VRplane_NDattach_to_cs ); Begin

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  if(nd$dep_exist( l_root = &my_grid,  nb_root = 1,
                   l_tip  = &contents,  nb_tip = 1 ))
  {
      End
      return (OM_S_SUCCESS);
  }

  /*| Do the connexion */

  status = om$send
             (msg = message NDnode.NDconnect(1,&contents,NULL_GRID,ND_FULL),
              targetid = my_id);
  as$status();

  /*| Get the new local coordinates from global coordinates */

  status = om$send(msg = message NDnode.NDgive_structure
                                          (p_msg,&ret_str,p_md_env),
                   targetid = contents.objid,
                   targetos = contents.osnum);
  as$status(action = RET_STATUS);

  MAinvmx(p_msg,&four,ret_str.var.ref_st.t,matrix);
  VRmatpoint(p_msg,matrix,me->origin,me->loc_origin, 1.);
  VRmatpoint(p_msg,matrix,me->normal,me->loc_normal, 0.);
  End
  return(status);
}/* end method NDattach_to_cs*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             method NDdetach_to_cs                          */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method  NDdetach_from_cs
  (
  IGRlong *msg;
  struct GRid cs_grid;
  struct GRid contents;
  struct GRid *as_grid;
  struct GRmd_env *md_env
  )
  /*
  DESCRIPTION: Dettach the plane from a coordinate system
  */
  {
  IGRlong status;
  IGRint count;
  struct GRid my_root;

  SetProc( VRplane_NDdetach_from_cs ); Begin
  *msg = MSSUCC;
  as_grid->objid = my_id;
  as_grid->osnum = OM_Gw_current_OS;

  /*| Get my parents */

   status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,&my_root,1,NULL,
                                               0,1,&count),
                    targetid = my_id);
   as$status(action = RET_STATUS);
   if( count == 0 )
   {
      End
      return(OM_S_SUCCESS);
   }
   if(!IF_NULL_OBJID(contents.objid)  &&
      !IF_EQ_OBJID(contents.objid,my_root.objid)) return(OM_S_SUCCESS);

  /*| disconnect the source object from the AScontents */

  status = om$send
             (msg = message NDnode.NDdisconnect( 0, NULL ),
              targetid = my_id);
  End
  return(status);
}/* end NDdetach_from_cs*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        function disp_dummy_plan                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#undef AS_DEBUG

#define NB_PT_PLAN      5         /* Number of points to define the plan      */
#define NV_HALF_PLANE  20         /* Size of a half plane                     */
#define NB_PT_NORMAL   2          /* Number of points to define the normal    */

disp_dummy_plan(p_msg, origin, vector, mode, sp_info)

  IGRlong       *p_msg;           /* OUT    Return code of the function       */
  IGRdouble     origin[];         /* IN     Origin of this plane              */
  IGRdouble     vector[];         /* IN     Vector normal of this plane       */
  enum GRdpmode mode;             /* IN     Display mode                      */
  struct DP_information *sp_info; /* IN     Special display information       */
  /*
  DESCRIPTION: This function draws the graphic representation of a dummy plane 
  CONSTAINTS:  Must know the window to have a constant display size
  */
  /*.disp_dummy_plan*/
  {
  IGRlong     status;             /* Status returned by om                    */
  int         index;              /* Index for a loop                         */
  struct IGRpolyline  polyline;   /* Polyline representing the plane          */
  struct IGRdisplay   display;    /* Display attributes of the plane          */
  struct DPele_header header0;    /* Buffer to display the plane              */
  double buffer1[/*NB_PT_PLAN*3*/  16];   /* Points of the polyline                   */
  double buffer2[/*NB_PT_PLAN*3*/  16];   /* Points of the polyline                   */
  short       one=1;              /* Dimension of a vector                    */
  short       four=4;             /* Dimension of a matrix                    */
  IGRmatrix   matrix;             /* Matrix of the environment                */
  struct IGRpolyline  normal;     /* normal representing the plane            */
  struct DPele_header header1;    /* Buffer to display                        */
  double buffer_n[3*NB_PT_NORMAL];/* Points of the normal to the plane        */
  double      size_plane;         /* Size of the display for a plane          */

  /*| --------------- */
  /*| Trace the plane */
  /*| --------------- */
  SetProc( VRplane_disp_dummy_plan ); Begin

  status = VRplan_matrix(p_msg, origin, vector, matrix);

  polyline.num_points = NB_PT_PLAN;
  polyline.points     = buffer2;

  size_plane = NV_HALF_PLANE/sp_info->gragad->vvol_viewport_scale;

  buffer1[0] =-size_plane;
  buffer1[1] = size_plane;
  buffer1[2] = 0;
  buffer1[3] = 1;

  buffer1[4] = size_plane;
  buffer1[5] = size_plane;
  buffer1[6] = 0;
  buffer1[7] = 1;

  buffer1[8] = size_plane;
  buffer1[9] =-size_plane;
  buffer1[10] = 0;
  buffer1[11] = 1;

  buffer1[12]=-size_plane;
  buffer1[13]=-size_plane;
  buffer1[14] = 0;
  buffer1[15] = 1;

  /*| Compute the points of the plane in the environment */

  MAmulmx(p_msg,&four,&four,&one,matrix,buffer1,buffer2);
  MAmulmx(p_msg,&four,&four,&one,matrix,&buffer1[4],&buffer2[3]);
  MAmulmx(p_msg,&four,&four,&one,matrix,&buffer1[8],&buffer2[6]);
  MAmulmx(p_msg,&four,&four,&one,matrix,&buffer1[12],&buffer2[9]);

  for(index=0; index<3; index++)
    {
    buffer2[12+index] = buffer2[index];
  }/* end for(index)*/

  /*| Display the plane */

  display.color =  1;
  display.weight = 0;
  display.style = 0;

  dp$build_dis_buffer
    (buffer      = &header0,
     type        = IGRPY,
     display_att = &display,
     geometry    = (struct IGRpolyline *)&polyline);

  dp$dispelem
    (msg     = p_msg,
     buffer  = &header0,
     mode    = mode,
     dp_info = sp_info);

  /*| ----------------------- */
  /*| Trace the normal vector */
  /*| ----------------------- */

  normal.num_points = NB_PT_NORMAL;
  normal.points     = buffer_n;
  
  for(index=0; index<3; index++)
    {
    buffer_n[index]   = origin[index];
    buffer_n[index+3] = size_plane*vector[index]+origin[index];
  }/* end for(index)*/

  dp$build_dis_buffer
    (buffer      = &header1,
     type        = IGRPY,
     display_att = &display,
     geometry    = (struct IGRpolyline *) &normal);

  dp$dispelem
    (msg     = p_msg,
     buffer  = &header1,
     mode    = mode,
     dp_info = sp_info);
  End
  return(TRUE);
}/* end disp_dummy_plan*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            function VRplan_matrix                          */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#define EPSILON        1.e-3      /* Minimum length of a vector               */

VRplan_matrix(p_msg, origin, vector, matrix)

  IGRlong            *p_msg;      /* OUT    Return code of the function       */
  IGRdouble          origin[];    /* IN     Origin of this plane              */
  IGRdouble          vector[];    /* IN     Vector normal of this plane       */
  IGRdouble          matrix[];    /* OUT    matrix created                    */
  /*
  DESCRIPTION: Convert a plane structure in a matrix form 
  */
  {
  double      length;             /* Length of a vector                       */
  double      v_len();            /* Function returning the length of a vector*/
  int         index;              /* Index for a loop                         */
  
  SetProc( VRplane_VRplan_matrix ); Begin
  MAidmx(p_msg,matrix);

  /*| Compute the Y vector = NORMAL ^ X */

  v_cross(vector,matrix,&matrix[4]);
  length = v_len(&matrix[4]);

  if(length>VRGetTol(VR_LENGTH_TOL))
    {
    /*| Deduce X = Y ^ NORMAL */

    for(index=0; index<3; index++) matrix[index+4]/=length;
    v_cross(&matrix[4],vector,matrix);
    }
  else
    {
    matrix[4] = 0;
    matrix[5] = 1;
    matrix[6] = 0;

    /*| Compute the X vector = Y ^ NORMAL */

    v_cross(&matrix[4],vector,matrix);
    length = v_len(matrix);

    if(length>VRGetTol(VR_LENGTH_TOL))
      {
      /*| Deduce Y = NORMAL ^ X */

      for(index=0; index<3; index++) matrix[index] /= length;
      v_cross(vector,matrix,&matrix[4]);
      }
    else
      {
      /*| The normal vector is NULL */

      End
      return(FALSE);
    }/* end if(length)*/
  }/* end if(v_len)*/

  for(index=0; index<3; index++)
    {
    matrix[12+index] = origin[index];
    matrix[8+index]  = vector[index];
  }/* end for(index)*/

  AStrans_mat(matrix,matrix);
  End
  return(OM_S_SUCCESS);
}/* end VRplan_matrix*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                           function VRmat_point                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRmatpoint(p_msg, matrix, point, res_point, last_value)

  IGRlong          *p_msg;        /* OUT    Return code of the method         */
  IGRmatrix        matrix;        /* IN     Matrix of the transformation      */
  IGRpoint         point;         /* IN     Point to transform                */
  IGRpoint         res_point;     /* IN     Resultant point                   */
  IGRdouble        last_value;    /* IN     Last value for the product        */
  /*
  DESCRIPTION: Change the coordinates of a point (multiplication by a matrix)
  */
  /*.VRmatpoint*/
  {
  int         index;              /* Index for a loop                         */
  short       one=1;              /* Dimension of a vector                    */
  short       four=4;             /* Dimension of a matrix                    */
  double      vector1[4];         /* Temporary vector to do an operation      */
  double      vector2[4];         /* Temporary vector to do an operation      */

  /*| Compute the origin of the plane */
  SetProc( VRplane_VRmatpoint ); Begin

  for(index=0; index<3; index++) vector1[index]=point[index];
  vector1[3] = last_value;
  MAmulmx(p_msg,&four,&four,&one,matrix,vector1,vector2);
  for(index=0; index<3; index++) res_point[index]=vector2[index];
  End
  return(OM_S_SUCCESS);
}/* end VRmatpoint */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDcopy_to_root(	IGRlong *msg; IGRint cp_type;
              		struct GRmd_env *md_env, *new_info; struct GRid *newobjid )
{
  IGRint status;

  SetProc( VRplane_NDcopy_to_root ); Begin
  *msg = MSSUCC;

  status=om$send( msg      = message ASnode.NDcopy
                                  ( msg, cp_type, md_env, new_info, newobjid ),
                  targetid = my_id );
  as$status();

  End
  return(status);
}

method GRcopy( IGRlong *msg; struct GRmd_env *obj_dsenv;
               struct GRmd_env *new_dsenv; GRobjid *newobjid)
{
 int status;

/* to avoid copy of dependency */
 extern IGRboolean ASbroadcast_in_progress;
 IGRboolean save_br;

 SetProc( VRplane_GRcopy ); Begin
 save_br = ASbroadcast_in_progress;
 ASbroadcast_in_progress = TRUE;
 status = om$send(msg = message ASnode.GRcopy
				       ( msg, obj_dsenv, new_dsenv, newobjid),
		  targetid = my_id,
		  mode = OM_e_wrt_message);
 ASbroadcast_in_progress = save_br;

 /*"GRcopy msg %d MSSUCC %d\n",*msg,MSSUCC*/
 /*"status %d\n",status*/
 status = OM_S_SUCCESS;
 *msg = MSSUCC;
 End
 return(status);

}

/* Set or inquire the status of the plane */

method VRget_plane_state(int *state)
{
 *state = me->plane_state;
 return OM_S_SUCCESS;
}

method VRchg_plane_state(int mask, state)
{
 me->plane_state = (me->plane_state & ~mask) | (state & mask);
 return OM_S_SUCCESS;
}


/* To not copy network in dynamics */

method NDget_objects(int type;struct GRid *list;int size; struct GRid **buffer;
                     int ifrom,ito,*count)
{
 extern IGRboolean dynamics_in_progress;

 SetProc( VRplane_NDget_objects ); Begin
 if(dynamics_in_progress && type&ND_CHILDREN)
  {
   *count = 0;
   End
   return OM_S_SUCCESS;
  }

 else
 {
   End
   return om$send(msg = message ASnode.NDget_objects
                                (type,list,size,buffer,ifrom,ito,count),
                    targetid = my_id,
                    mode = OM_e_wrt_message);
 }
}

/*============================================================================*/

method NDmake_source( IGRlong *msg; struct GRid *located_obj, *context;
                      char *path; GRspacenum as_osnum; struct GRid *PretendId )
{
  IGRint		found=FALSE, index=0; 
  IGRlong		status=OM_S_SUCCESS;
  GRclassid 		obj_class;
  struct 	GRid   	child, child_context;

  SetProc( VRplane_NDmake_source ); Begin
  if( IF_NULL_OBJID( context->objid ) )
  {
   	if( as_osnum != OM_Gw_current_OS )
        {
          End
          return( OM_W_ABORT );
        }
   	PretendId->objid = my_id;
   	PretendId->osnum = OM_Gw_current_OS;
   	*msg = MSSUCC;
   	status = OM_S_SUCCESS;
  }
  else
  {
  	/*| Try to find a matching ACpretendin */

  	while(1)
  	{
    		status = om$get_objid_at_index( objid        = my_id,
				    		p_chanselect = &AS_notification,
				    		index        = index++,
				    		osnumaddr    = &child.osnum,
				    		objidaddr    = &child.objid);
    		if( !( status & OM_S_SUCCESS ) ) break;

    		status = om$get_classid( 	osnum     = child.osnum, 
      			     			objid     = child.objid, 
			     			p_classid = &obj_class );
    		as$status( action = RET_STATUS );

    		if( om$is_ancestry_valid( 	subclassid   = obj_class,
		              			superclassid = OPP_ACpretendin_class_id ) != OM_S_SUCCESS ) continue;
                                        	     			
    		status = om$get_objid_at_index( osnum        = child.osnum,
                                    		objid        = child.objid,
				    		index        = 0,
                                    		p_chanselect = &AS_listeners,
				    		osnumaddr    = &child_context.osnum,
				    		objidaddr    = &child_context.objid);

    		if( !( status & OM_S_SUCCESS ) ) continue;

    		if( ( context->objid == child_context.objid ) &&
                                    		( context->osnum == child_context.osnum ) )
    		{
      			/*| matching pretendin found */

      			PretendId->objid = child.objid;
      			PretendId->osnum = child.osnum;
      			found = TRUE;
      			break;
    		} 
  	}

  	if( !found )
  	{
    		PretendId->osnum = context->osnum;
    		status = om$construct( 	classid = OPP_ACpretendin_class_id,
			   		p_objid = &PretendId->objid,
			   		osnum   = PretendId->osnum,
                           		msg     =  message ACpretendin.ACiconnect
                                      			( 0, *located_obj, *context, "." ) );
    		as$status( action = RET_STATUS );
  	}
  }

  /*" created pret %d %d \n", PretendId->objid, PretendId->osnum */

  End
  return OM_S_SUCCESS;
}


end implementation VRplane;
