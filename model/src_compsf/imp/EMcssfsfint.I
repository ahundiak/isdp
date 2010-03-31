/*
  DESCRIPTION:

    This method computes the intersection between the surfaces of this
    object and the surface object that is input. The output is in the
    form of a linked-list, ordered such that all the intersection
    information related to a given surface is available in sequence. The
    input surface object could be in the form of an OM-object, surface
    buffer or represented by an infinite plane.

    Various options are available for the output. These basically govern
    the form of output and/or further manipulations to be performed on
    it. These are specified via three bit-masks. Symbolically defined
    constants are available to prepare these masks. The various options
    that can be specified by these masks are described in the documentation
    for the EMSsubbs-override.

    For the symbolically defined constants, see the file emssfintdef.h

  NOTES

    Before invoking the intersection method (other than the recursive or
    iterative invocations made by the intersection methods themselves)
    "num_inters, *my_inters and *other_inters" SHOULD be set to 0 or NULL.
    On the other hand, if "my_inters or other_inters" is NULL(by value) then
    this method assumes that that particular list is not required and is
    thus ignored.
  
    See also the documentation for the EMSsubbs-override method.

  RETURN VALUES

    Upon exit the completion code will be one of the following:

      Success codes:
      - EMS_S_Success 
          if succeeded
      - EMS_I_NoIntersect
          if no intersections were found

      Error codes:
      - EMS_E_InvalidArg 
          if the input surface data is neither a surface-object, surface
          buffer or an infinite plane.
      - EMS_E_NoDynamicMemory
          if dynamic memory allocation was tried but failure occurred.
      - EMS_E_Fail
          Call to a math function returned error.
      - EMS_E_SurfaceError
          Invocation of a surface method failed.
      - EMS_E_OMerror
          Invocation of a method on the input data failed or,
          Call to an OM-primitive failed.

  ALGORITHM

    This method when invoked will send the message successively to
    all the components of this object and the output arguments are
    appended to with each such send. At the time of return, the
    output arguments contain all the intersection information.

  HISTORY

    DLB :  10/30/87  :  Modified channel for version 1.1.0
    SS  :  03/01/87  :  Creation

*/

class implementation EMScompsurf;

#include "EMS.h"
#include "emsdef.h"
#include "emserr.h"
#include "timerdef.h"
#include "madef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern IGRboolean _use_timers;

method EMsfsfint (IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
                  struct GRvg_construct *const_args; 
                  struct EMSdataselect *other_data;
                  struct GRmdenv_info *other_datenv;
                  IGRushort outworld_options;
                  IGRushort outparam_options;
                  IGRushort trim_options;
                  IGRlong *num_inters;
                  struct EMSinters **my_inters; 
                  struct EMSinters **other_inters)
{
  IGRboolean world_range_needed = TRUE;
  IGRint stat_OM, i, numpoles;
  IGRlong msg_loc;
  GRrange other_range, my_range;
  OM_S_CHANSELECT chan_to_comps;
  extern IGRboolean BSbx2(), BSbxint();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  /*
   * Check if the ranges intersect. If not then
   * simply exit. If they do, then proceed further.
   */

  if (_use_timers)
    start_timer (T12_GETRANGE);

  stat_OM = om$send (msg = message GRvg.GRgetrang (&msg_loc, mattyp, mat,
             &world_range_needed, my_range), targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);

  if (other_data->datatype == EMSdata_object)
    {
    stat_OM = om$send (msg = message GRvg.GRgetrang (&msg_loc, 
               &other_datenv->matrix_type, other_datenv->matrix,
               &world_range_needed, other_range),
               targetid = other_data->data.object->objid,
               targetos = other_data->data.object->osnum);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
    }
  else if (other_data->datatype == EMSdata_surface)
    {
    numpoles = other_data->data.surface->u_num_poles *
                other_data->data.surface->v_num_poles;
    BSbx2 (&msg_loc, &numpoles, other_data->data.surface->poles,
           !other_data->data.surface->rational ? NULL :
            other_data->data.surface->weights, &other_range[0], 
           &other_range[3]);
    }
  else if (other_data->datatype == EMSdata_plane)
    for (i=0; i<6; i++)
      other_range[i] = (i<3 ? -MAXDOUBLE : MAXDOUBLE);
  else
    EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);

  if (_use_timers)
    stop_timer (T12_GETRANGE, FALSE, "");


  if (!BSbxint (&msg_loc, &my_range[0], &my_range[3],
                &other_range[0], &other_range[3]))
    goto ret_end;

  /*
   * Send the intersection message to each of the
   * components.
   */

  chan_to_comps.type = OM_e_addr;
  chan_to_comps.u_sel.addr = &ME.GRcmpowner->to_components;

  stat_OM = om$send (msg = OPPmargs, p_chanselect = &chan_to_comps);
  EMomerr_exit (stat_OM, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMScompsurf.EMsfsfint")
  return (stat_OM);
}
end implementation EMScompsurf;
