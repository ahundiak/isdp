/* $Id: VRplanetmp.I,v 1.3 2001/02/20 01:15:43 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrplane / VRplanetmp.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRplanetmp.I,v $
 *	Revision 1.3  2001/02/20 01:15:43  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/12 23:34:20  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/23  23:39:46  pinnacle
# Created: route/vrplane/VRplanetmp.I by lawaddel for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/04/04  21:40:26  pinnacle
# Replaced: vrplane/VRplanetmp.I for:  by ashankar for route240
#
# Revision 1.2  1996/01/17  17:33:22  pinnacle
# Replaced: vrplane/VRplanetmp.I for:  by r240_int for route240
#
 *
 * History:
 *	01/15/96	tlb	Add prototypes
 *
 *************************************************************************/
class implementation VRplane;


/*

implementation file to remove as soon as the planes will be redesigned

HISTORY
-------

  DP 12-15-89 : Design date
*/

#include "EMS.h"
# ifndef OM_D_MINIMUM
# include "OMminimum.h"     /* for gocmacros.h  */
# endif
# ifndef igrtypedef_include
# include "igrtypedef.h"     /* for gocmacros.h  */
# endif
# ifndef gocmacros_include
# include "gocmacros.h"     /* GRgetabsg macro  */
# endif
# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

#include <stdio.h>
#include "madef.h"
#include "EMSlogic.h"
#include "EMStypedef.h"
#include "EMScmacros.h"

#include "igrdef.h"    
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
#include "bserr.h"    

#include "vrplane_pto.h"    
#include "bstst_plan.h"    
#include "bsplane3pt.h"    
#include "maidmx.h"    
#include "VDmem.h"    
#include "vrdbgmacros.h"

#define AS_DEBUG

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method ACreturn_foot                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method ACreturn_foot( IGRlong			*msg;
		      IGRchar			*footname;
		      struct	GRid		*foot_obj;
		      IGRshort			*mat_type;
		      IGRdouble			*matrix )
{
	IGRlong	retcode;
        SetProc( VRplane_ACreturn_foot ); Begin

	if( 	!footname ||
		footname[0] != '\0' )
        {
          End
          return OM_E_INVARG;
        }

	*msg    = MSSUCC;
	foot_obj->osnum = OM_Gw_current_OS;
	foot_obj->objid = my_id;
	if(mat_type) *mat_type = MAIDMX;
	if(matrix) MAidmx(&retcode,matrix);
        End
	return OM_S_SUCCESS;

}/* end ACreturn_foot */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method ASreturn_go                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method ASreturn_go
  (
  struct GRid *p_go;              /* OUT    Graphic object connected          */
  IGRshort    *p_mat_type;        /* OUT    matrix type to used with this G.O.*/
  IGRdouble   *matrix             /* OUT    matrix to used with this G.O.     */
  )
  /*
  DESCRIPTION: Returns the graphic object of an VRplane object (I.e. my_object)
               Returns also the matrix and matrix type of the current module env
  */
  {
  long        msg;                /* Returned code of a function              */
  SetProc( VRplane_ASreturn_go ); Begin
  /*| Fill the object */

  p_go->objid = my_id;
  p_go->osnum = OM_Gw_current_OS;

  /*| Fill the matrix */

  if(p_mat_type) *p_mat_type = MAIDMX;
  if(matrix)     MAidmx(&msg,matrix);
  End
  return(OM_S_SUCCESS);
}/* end ASreturn_go */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method ASconstruct_go                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method ASconstruct_go
  (
  struct GRas     *asso_lis;        /* IN/OUT Associative information         */
  struct GRmd_env *md_env;          /* IN     Module information              */
  IGRchar         *go_cnst_lis;     /* IN     Graphic object construction list*/
  GRclassid       go_classid;       /* IN     Class of the object to construct*/
  IGRboolean      altconstruct      /* IN     flag=TRUE if used GRaltconstruct*/
  )
  /*
  DESCRIPTION: Constructs the graphic object of an VRplane object (I.e. does
               nothing).
  */
  {
  GRobjid            go_objid;      /* Dummy graphic object                   */
  long               msg;           /* Return message                         */
  struct GRpost_info info;          /* Processing control information         */
  IGRlong            status;        /* Status returned by om                  */

  SetProc( VRplane_ASconstruct_go ); Begin
  info.construct_flag = FALSE;
  
  status = om$send
             (msg      = message GRvg.GRpostabsg(&msg,md_env,&info,
              ((struct GRvg_construct *)go_cnst_lis)->geometry,&go_objid),
              targetid = my_id);
   End
   return(status);
}/* end ASconstruct_go */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                              method GRgetsize                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define SECURITY 50             /* To avoid surprises                         */

method GRgetsize
  (
  IGRlong   *msg;               /* OUT    Completion code                     */
  IGRshort  *matrix_type;       /* IN     Transformation matrix type          */
  IGRmatrix matrix;             /* IN     Transformation matrix               */
  IGRlong   *p_size             /* OUT    Size of the structure               */
  )
  /*
  DESCRIPTION:
  */
  {
  SetProc( VRplane_GRgetsize ); Begin
  *msg = MSSUCC;

  *p_size = 100;
  *p_size *= sizeof(IGRdouble);
  *p_size += sizeof(struct IGRbsp_surface);
  *p_size += SECURITY;

  End
  return(OM_S_SUCCESS);
}/* end GRgetsize */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                              method GRgenabsg                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method GRgenabsg
  (
  IGRlong   *p_msg;             /* OUT    Completion code                     */
  IGRshort  *matrix_type;       /* IN     Transformation matrix type          */
  IGRmatrix matrix;             /* IN     Transformation matrix               */
  IGRchar   **pp_absgptr        /* OUT    Pointer to the abstract geometry    */
  )
  /*
  DESCRIPTION:
  */
  {
  static  char	*abs_geom=NULL;  /* My abstract geometry                       */
  static  int	size_geom=0;     /* Size of the geometry                       */
  IGRlong	size;            /* Size of the geometry computed              */
  IGRlong	status;          /* Status returned by om                      */

  /*| Get the size of the geometry */
  SetProc( VRplane_GRgenabsg ); Begin
  status =
  om$send(msg  = message GRvg.GRgetsize(p_msg, matrix_type, matrix, &size),
              targetid = my_id);
  as$status();

  /*" size = %d\n",size*/

  if(abs_geom == NULL) { abs_geom = (char *) _MALLOC(size, char); size_geom = size; }
  else if (size > size_geom) printf ("Osashi ! Must reallocate memory \n");

  /*| Get the geometry */

  (*pp_absgptr) = abs_geom;
  status = om$send
             (msg  = message GRvg.GRgetgeom(p_msg,matrix_type,matrix,abs_geom),
              targetid = my_id);
  as$status();
 
  End
  return(OM_S_SUCCESS);
}/* end GRgenabsg */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                              method GRgetgeom                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method GRgetgeom
  (
  IGRlong   *p_msg;             /* OUT    Completion code                     */
  IGRshort  *matrix_type;       /* IN     Transformation matrix type          */
  IGRmatrix matrix;             /* IN     Transformation matrix               */
  IGRchar   *p_geometry         /* OUT    Pointer to the abstract geometry    */
  )
  /*
  DESCRIPTION:
  */
  {
  IGRlong            status;        /* Status returned by om                  */
  IGRmatrix          my_matrix;     /* Internal matrix                        */
  IGRpoint           x_point;       /* Point along X axis                     */
  IGRpoint           y_point;       /* Point along Y axis                     */
  int                index;         /* Index for a loop                       */
  struct IGRbsp_surface *p_geom;    /* Pointer to the geometry                */

  SetProc( VRplane_GRgetgeom ); Begin
  p_geom = (struct IGRbsp_surface *) p_geometry;

  /*| Prepar the structure for the plane */

  EMSbs_partition(4,4,4,4,1,0,(IGRlong *)NULL,p_geom);

  /*| Transform the plane in a matrix form */

  status = VRplan_matrix(p_msg,me->origin,me->normal,my_matrix);
  AStrans_mat(my_matrix,my_matrix);

  /*| Convert the matrix to a geometry form */

  for(index=0; index<3; index++)
    {
    x_point[index] = my_matrix[index]+my_matrix[index+12];
    y_point[index] = my_matrix[index+4]+my_matrix[index+12];
  }/* end for */

  status = BSplane3pt(p_msg,&my_matrix[12],x_point,y_point,(struct IGRbsp_surface *)p_geometry);

  if(!status)
  {
    End
    return(OM_W_ABORT);
  }
  return(OM_S_SUCCESS);
}/* end GRgetgeom */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             method GRpostabsg                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method GRpostabsg
  (
  IGRlong            *msg;      /* OUT    Completion code                     */
  struct GRmd_env    *md_env;   /* IN     Module environment                  */
  struct GRpost_info *post_info;/*        Processing control information      */
  IGRchar            *absptr;   /* IN     Pointer to the geometry to post     */
  GRobjid            *newobjid  /* OUT    New objid if the class changes      */
  )
  /*
  DESCRIPTION:
  */
  {
  IGRboolean     is_planar;
  IGRlong        loc_msg;
  struct         IGRbsp_surface *surface;

  SetProc( VRplane_GRpostabsg ); Begin
  if(me->plane_state&VR_FIXED_PLANE)
   {
    *msg = MSFAIL;
    *newobjid = my_id;
    End
    return(OM_S_SUCCESS);
   }

  *msg = MSSUCC;

  surface = (struct IGRbsp_surface *)(absptr);

  /*| Determine planarity*/

  BStst_plan(surface->u_num_poles * surface->v_num_poles,surface->poles,
            (surface->rational ? surface->weights : NULL),&is_planar,
             me->normal,&loc_msg);

  if (loc_msg == BSSUCC)
    {
    if (is_planar)
      {
      /*| Planar surface */

      *msg = MSSUCC;
      OM_BLOCK_MOVE(surface->poles,me->origin,sizeof(IGRpoint));
      
      if (surface->rational)
        {
        /*| Rational surface */

        me->origin[0] /= surface->weights[0];
        me->origin[1] /= surface->weights[0];
        me->origin[2] /= surface->weights[0];
      }
      }
    else
     *msg = MANONPLANAR;
   }
  else if (loc_msg == BSNOSTKMEMORY)
   *msg = MANOMEMORY;
  else
   *msg = MSFAIL;

  if((*msg == MANONPLANAR) || (1 & *msg))
  {
    End
    return(OM_S_SUCCESS);
  }
  else
  {
    End
    return(OM_E_ABORT);
  }
}/* end GRpostabsg */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
end implementation VRplane;
