class implementation GRvg;

#include "OMmacros.h"
#include "emsdattyp.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "gocmacros.h"
#include "bserr.h"
#include "bsmkvec.h"

#define X 0
#define Y 1
#define Z 2

#define FIRST  0
#define SECOND 1

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_GRbspline_class_id, OPP_GRcurve_class_id;
#ifndef IDRAW
extern GRclassid OPP_EMSsubbs_class_id;
#endif

/*
  DESCRIPTION

    This function can be used to get the B-spline geometry of a given
    surface/curve. It mallocs a contiguous, buffer that is appropriately
    partitioned to hold the geometry. Deallocation is done on just this
    one address.

  HISTORY

    Sudha  07/09/93  :  Modified for BSprototypes anisfication
    SS  :  10/19/89  :  Made the 'type' argument optional (NULL is possible)
    rlw :  04/14/89  :  Added conditional compilation statements for I/DRAW
    rlw :  02/20/89  :  Fixed my fix
    rlw :  02/10/89  :  Modified to support composite curves
    SS  :  10/15/87  :  Creation
*/

IGRint EMgetvggeom (msg, mattyp, mat, object, geom, type)
IGRlong *msg;
IGRshort *mattyp;
IGRmatrix mat;
struct GRid *object;
IGRchar **geom;
enum EMSdatatype *type;
{
  IGRint buff_size;
  IGRlong msg_loc, stat_OM;
  GRclassid classid;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *geom = NULL;

  if (type)
    {
    stat_OM = om$get_classid (objid = object->objid, osnum = object->osnum,
               p_classid = &classid);
    EMomerr_exit (stat_OM, ret_end);

    stat_OM = om$is_ancestry_valid (subclassid = classid, 
               superclassid = OPP_GRcurve_class_id);
    if (stat_OM == OM_S_SUCCESS)
      *type = EMSdata_curve3d;
    else
      {
#ifndef IDRAW
      stat_OM = om$is_ancestry_valid (subclassid = classid, 
                 superclassid = OPP_EMSsubbs_class_id);
      if (stat_OM == OM_S_SUCCESS)
        *type = EMSdata_surface;
      else
#endif
        EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);
      }
    }

  stat_OM = om$send (msg = message GRvg.GRgetsize (&msg_loc, mattyp, mat,
             (IGRlong *)&buff_size), 
	targetid = object->objid, targetos = object->osnum,
        senderid = NULL_OBJID);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  *geom = (IGRchar *) om$malloc (size = buff_size);
  EMerr_hndlr (! *geom, *msg, EMS_E_NoDynamicMemory, ret_end);

  stat_OM = om$send (msg = message GRvg.GRgetgeom (&msg_loc, mattyp, mat,
             *geom), targetid = object->objid, targetos = object->osnum,
             senderid = NULL_OBJID);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMgetvggeom");
  return (stat_OM);
}

/*
  DESCRIPTION 

    This function is used to obtain the abstracted geometry of a given
    vector-graphics object. The memory for the object should NOT be
    freed as it is returned in a "system" buffer. This function is used
    for the express purpose of read-only operations on the geometry.

  HISTORY
   
    SS  :  05/04/89  :  Creation
*/

IGRlong EMgetabsg (msg, mattyp, mat, osnum, objid, geom)
IGRlong *msg;
IGRshort *mattyp;
IGRmatrix mat;
GRspacenum osnum;
GRobjid objid;
IGRchar **geom;
{
  IGRboolean inbuff;
  IGRlong msg_loc, stat_OM;
  extern IGRboolean GRabsg_test();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  inbuff = GRabsg_test (&msg_loc, mattyp, mat, &osnum, &objid, geom);
  if (!inbuff)
    {
    stat_OM = om$send (msg = message GRvg.GRgenabsg (&msg_loc, mattyp, mat,
               geom), targetid = objid, targetos = osnum,
               senderid = NULL_OBJID);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }

ret_end:
  return (stat_OM);
}

end implementation GRvg;

