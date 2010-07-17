/* $Id: VRconsi.I,v 1.1.1.1 2001/01/04 21:12:48 cvs Exp $  */

/* I/ROUTE
 *
 * File:        vrconstrain/VRconsi.I
 *
 * Description:
 *
 *      This file contains service functions for the constraints
 *      subsystem.
 *
 * Revision History:
 *      $Log: VRconsi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:48  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.7  1996/04/16  18:53:30  pinnacle
# Replaced: vrconstrain/VRconsi.I for:  by ashankar for route240
#
# Revision 1.6  1996/02/27  08:09:58  pinnacle
# Replaced: vrconstrain/VRconsi.I for:  by ashankar for route240
#
# Revision 1.5  1996/01/22  18:19:24  pinnacle
# Replaced: vrconstrain/VRconsi.I for:  by azuurhou for route240
#
# Revision 1.4  1996/01/22  17:44:28  pinnacle
# Replaced: vrconstrain/VRconsi.I for:  by azuurhou for route240
#
# Revision 1.3  1996/01/16  22:12:28  pinnacle
# Replaced: vrconstrain/VRconsi.I for:  by r240_int for route240
#
# Revision 1.2  1995/12/07  17:03:38  pinnacle
# Replaced: vrconstrain/VRconsi.I for:  by hverstee for route240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR  DESCRIPTION
 *      12/08/95        Henk    Cleanup, remove extra as$status.
 *	01/16/96	tlb	Add prototypes
 *	01/22/96	adz	Remove print statement.
 */

class implementation VRcons;

#include "OMerrordef.h"
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "AS_status.h"

#include "vrconstr_pto.h"

#define AS_DEBUG

extern GRclassid OPP_VRcons_class_id;

/* GRid of the constraint solver */

%safe
static struct GRid VRsolver = {0,(unsigned long)-1};
%endsafe
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                    */
/* Functon called by the graph manager at begining or end of modify_batch */
/*                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRstart_modify()
{
 GRclassid     obj_class;
 int           status = OM_S_SUCCESS;

  if( (om$is_objid_valid(objid = VRsolver.objid,
                         osnum = VRsolver.osnum)) & OM_S_SUCCESS)
  {
    status = 
    om$get_classid(objid = VRsolver.objid,
                   osnum = VRsolver.osnum,
               p_classid = &obj_class);
    as$status();

    if( (status & OM_S_SUCCESS) &&
        ( om$is_ancestry_valid
               (subclassid = obj_class,
              superclassid = OPP_VRcons_class_id ) & OM_S_SUCCESS ) )
    {
      status =
      om$send(msg = message VRcons.VRset_solver_state(VR_SOLVER_INITIAL),
         senderid = NULL_OBJID,
         targetid = VRsolver.objid,
         targetos = VRsolver.osnum);
/** KLUDGE FOR TR179600259
      as$status ();
**/
    }
  }

  return ( status );
}

VRend_modify()
{
  int       status = OM_S_SUCCESS;
  int       solver_state;

  if( (om$is_objid_valid(objid = VRsolver.objid,
                         osnum = VRsolver.osnum)) & OM_S_SUCCESS)
  {
    status =
    om$send(msg = message VRcons.VRget_solver_state(&solver_state),
       senderid = NULL_OBJID,
       targetid = VRsolver.objid,
       targetos = VRsolver.osnum);

     status =
     om$send(msg = message VRcons.VRset_solver_state(VR_SOLVER_INACTIVE),
        senderid = NULL_OBJID,
        targetid = VRsolver.objid,
        targetos = VRsolver.osnum);
     as$status ();
  }

  return ( status );
}

void VRreset_solver()
{
	VRsolver.objid = NULL_OBJID;
	VRsolver.osnum = 0;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                                                        */
/* Function to retrieve or create an VRsolver in the required osnum       */
/*                                                                        */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRreturn_solver( 	struct GRid *solver,
			GRspacenum   osnum)
{
  int       status;
  GRclassid obj_class;

  status = OM_W_ABORT;

  /*   check for a valid existing solver    */
  if(VRsolver.osnum == osnum &&
     (om$is_objid_valid(objid = VRsolver.objid,
                        osnum = VRsolver.osnum) & OM_S_SUCCESS))
  {
    status = om$get_classid(objid = VRsolver.objid,
                            osnum = VRsolver.osnum,
                        p_classid = &obj_class);

    if(status & OM_S_SUCCESS)
    {
      status = om$is_ancestry_valid(subclassid = obj_class,
                                  superclassid = OPP_VRcons_class_id);
      if(!(status & OM_S_SUCCESS)) status = OM_W_ABORT;
    }
  }

  /*    if not found construct one    */
  if(!(status & OM_S_SUCCESS))
  {
    VRsolver.osnum = osnum;
    status = om$construct(classid = OPP_VRcons_class_id,
                           osnum  = VRsolver.osnum, 
                          p_objid = &VRsolver.objid,
                              msg = message VRcons.VRinit_solver());
    as$status();
  }

  *solver = VRsolver;
  return status;
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                                                        */
/* Initialize constrain solver when created                               */
/*                                                                        */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRinit_solver()
{
  me->solver_state = VR_SOLVER_INITIAL;
  NDadd_start_modif(VRstart_modify);
  NDadd_end_modif(VRend_modify);
  return OM_S_SUCCESS;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                                                        */
/* Set the state of the solver                                            */
/*                                                                        */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRset_solver_state(int state)
{
  me->solver_state = state;
  return OM_S_SUCCESS;
}

method VRget_solver_state(int *state)
{
  *state = me->solver_state;
  return OM_S_SUCCESS;
}

method VRinit_constrain()
{
  me->nb_conc = 0;
  me->nb_plane = 0;
  return OM_S_SUCCESS;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                                                        */
/* Inform the constrain solver about the constrain it has to solve        */
/*                                                                        */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRadd_constrain(struct GRid *obj)
{
  int status,size,i;

  /* Reset if necessary the list */

  if (me->solver_state == VR_SOLVER_INITIAL)
  {
    me->nb_conc = 0;
    me->nb_plane = 0;
    me->solver_state = VR_SOLVER_FIRST;
    me->iteration_number = 1;
  }

  for(i=0; i<me->nb_conc;i++)
  {
    if(  (me->conc[i].osnum == obj->osnum) &&
         (me->conc[i].objid == obj->objid))
    {
      /*"%d %d already in cons solver list\n",obj->objid,obj->osnum*/
      return OM_S_SUCCESS;
    }
  }  

  size = om$dimension_of(varray = me->conc);
  if( size <= me->nb_conc)
  {
    size = 1.5*size;
    /*"realloc me->conc with size %d\n", size */
    status = om$vla_set_dimension( varray = me->conc,
                                     size = size);
    as$status(action = RET_STATUS);
  }

  me->conc[me->nb_conc++] = *obj;

  return OM_S_SUCCESS;
}

end implementation VRcons;
