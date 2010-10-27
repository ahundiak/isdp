/* $Id: AScspointi.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdassoc/AScspointi.I
 *
 * Description:
 *		Overwrite NDplace to inform user with error;
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: AScspointi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
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
# Revision 1.1  1996/03/06  00:33:16  pinnacle
# Created: vdassoc/AScspointi.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	03/06/96	adz		creation date
 *
 ***************************************************************************/

class implementation AScspoint;

#include "OMmacros.h"
#include "ASmatrix.h"
#include "AS_status.h"

#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "nddef.h"
#include "madef.h"
#include "ndmacros.h"
#include "ASmsg.h"
#include "msmacros.h"
#include "v_dbgmacros.h"

#define CARTESIAN   0
#define CYLINDRICAL 1
#define SPHERICAL   2

extern GRclassid  OPP_GR3dpoint_class_id;
 
IGRdouble cos(), sin();


/*                  ----  AScspoint.NDplace  ----                            */

method NDplace(	struct GRas		*asso_lis;
		struct GRmd_env		*md_env;
		IGRchar			*go_cnst_lis )
 {
  IGRint                i;
  IGRlong               rc;
  OMuint 		count;
  struct GRid 		*parent;
  IGRlong   		msg, status;
  struct ret_struct 	obj_struct, objdef;
  IGRpoint		origin, old_work_pt, nw_work_pt;
  IGRdouble 		rotate[9], scale, param1, param2, param3;

  count = asso_lis->num_parents;
  parent = asso_lis->parents;

  if( IF_EQ_OBJID( asso_lis->go_objid.objid, NULL_OBJID ))
  {
     me->cs_type = (char) *asso_lis->as_attr;
     /*" int cs_type : %d\n", (int)me->cs_type */
  }
  else
  {
    status = as$any_give_structure(go_grid = asso_lis->go_objid,
                       		   mod_env = md_env,
				   inst    = &objdef );
    as$status(action = RET_STATUS);
    me->cs_type = (char)CARTESIAN;
  }

  if( count != 4 ) return(OM_W_ABORT);

  status = om$send( msg = message NDnode.NDgive_structure( &msg, &obj_struct,
                                                           md_env),
                    targetid = parent->objid);
  as$status(action = RET_STATUS);
  if(obj_struct.type != double_type) return OM_W_ABORT;
  param1 = obj_struct.var.root_pm_st.value;

  status = om$send( msg = message NDnode.NDgive_structure( &msg, &obj_struct,
                                                           md_env),
                    targetid = (parent+1)->objid);
  as$status(action = RET_STATUS);
  if(obj_struct.type != double_type) return OM_W_ABORT;
  param2 = obj_struct.var.root_pm_st.value;

  status = om$send( msg = message NDnode.NDgive_structure( &msg, &obj_struct,
                                                           md_env),
                    targetid = (parent+2)->objid);
  as$status(action = RET_STATUS);
  if(obj_struct.type != double_type) return OM_W_ABORT;
  param3 = obj_struct.var.root_pm_st.value;

  status = om$send( msg = message NDnode.NDgive_structure( &msg,
                                                           &obj_struct,
                                                           md_env),
                    targetid = (parent+3)->objid);
  as$status(action = RET_STATUS);

  if(!(obj_struct.type & ref_generic)) 
   {
    printf("Bad root for the AScspoint\n");
    return(OM_W_ABORT);
   }

  /*"valeur du parametre: %lf\n", param1 */
  /*"valeur du parametre: %lf\n", param2 */
  /*"valeur du parametre: %lf\n", param3 */

#ifdef	vdsDEBUG
  pr_mat("coord syst", 4, 4, obj_struct.var.ref_st.t);
#endif

  if(go_cnst_lis != NULL)
  {
   struct  IGRpolyline geom;
  
   /*| Prepare the geometry to construct the G.O */
 
   origin[0] = obj_struct.var.ref_st.t[3];
   origin[1] = obj_struct.var.ref_st.t[7];
   origin[2] = obj_struct.var.ref_st.t[11];

#ifdef	vdsDEBUG
   pr_point("origin: ",origin); 
#endif

   for(i=0;i<3;i++)
   {
     rotate[i]   = obj_struct.var.ref_st.t[i*4];
     rotate[i+3] = obj_struct.var.ref_st.t[1+i*4];
     rotate[i+6] = obj_struct.var.ref_st.t[2+i*4];
   }

   scale = obj_struct.var.ref_st.t[15];

   switch( (int)me->cs_type )
   {
     case CARTESIAN   : /*" the type of parameters is CARTESIAN\n" */
                        nw_work_pt[0] = param1;
                        nw_work_pt[1] = param2;
                        nw_work_pt[2] = param3;
                        break;

     case CYLINDRICAL : /*" the type of parameters is CYLINDRICAL\n" */
                        param1 = param1 * PI / 180.0;  
                        nw_work_pt[0] = param2 * cos(param1);
                        nw_work_pt[1] = param2 * sin( param1 );
                        nw_work_pt[2] = param3;
                        break;

     case SPHERICAL   : /*" the type of parameters is SPHERICAL\n" */
                        param1 = param1 * PI / 180.0;  
                        param2 = param2 * PI / 180.0;  
                        nw_work_pt[0] = param3 * cos(param1) * cos(param2);
                        nw_work_pt[1] = param3 * sin(param1) * cos(param2);
                        nw_work_pt[2] = param3 * sin(param2);
                        break;

     default          : printf(" type not correct\n");
                        return(OM_W_ABORT);

   }

#ifdef	vdsDEBUG
   pr_point("local: ",nw_work_pt);
#endif

   /* compute the corresponding point in the word cordinate system */   
   BSptnwtold( &rc, origin, rotate, &scale, nw_work_pt, old_work_pt );

#ifdef	vdsDEBUG
   __DBGpr_int(" BSptnwtold ", rc );
   pr_point("world: ", old_work_pt);
#endif

   geom.num_points = 1;
   geom.points     = old_work_pt;

   /*| Construct the G.O */
   ((struct GRvg_construct *)go_cnst_lis)->geometry = (char *) &geom;

   status = om$send( msg      = message ASnode.ASconstruct_go
		( asso_lis, md_env, go_cnst_lis , OPP_GR3dpoint_class_id,TRUE),
                     targetid = my_id);
   if( !(status&1)){
     UI_status(" Assoc. Point on C.S. Failed : Invalid Input ");
   }
  }

  /*| add to the graph */
  status = om$send( msg      = message NDnode.NDconnect( asso_lis->num_parents,
                                                         asso_lis->parents,
                                                         NULL_GRID,
                                                         ND_NEW),
                    targetid = my_id);

  as$status();
 
  return(OM_S_SUCCESS);  

}   /*           ----  end NDplace  ----                */

end implementation AScspoint;

