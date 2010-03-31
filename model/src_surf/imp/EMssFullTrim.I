/*
  DESCRIPTION:

    This method takes as input a pair of EMSdataselects representing
    corresponding uv-data on two surfaces (myself and other_obj) such as would
    be output by surface-surface intersection. It outputs the boundaries on
    the polylines that represent the area portions w.r.t. to the boundaries
    on the surfaces.

  ARGUMENTS

    mattyp, mat         - Input: The matrix and matrix-type to be used for this
                          object.
    my_uvdata,          - Input: The dataselects containing the parametric
    ot_uvdata             data on this surface and the other surface
                          that have to be trimmed w.r.t. to their respective
                          boundaries.
    my_xyzdata,          -Input: The dataselects containing the xyz
    ot_xyzdata            data on this surface and the other surface
                          that correspond to my_uvdata and ot_uvdata.
			  These may be the same when the two uvdata are
			  interpolatable 2d polylines, in which case the
			  xyzdata are not used,  so NULLS may be sent.
    mytolbasis,		- Input: parametric tolerance basis pointers.
    ottolbasis

    ot_data             - Input: The other surface data with which this
                          intersection is to be performed. Can be a
                          surface-object, surface-buffer or an infinite plane
                          definition.
    ot_envinfo          - Input: The other surface data's environment
                          information 
    correl_params	- Input: Information that correlates the my-data
                          with other-data, in the case where there isn't an
                          inherent one-to-one match.
    options             - Input: Options mask that controls the trimming:
                          For now trimming is always interpolated and this
                          mask should be NULL.
    num_bdrys           - Output: The number of boundary pairs that define the
                          portion on either of the line-strings that is
                          to be KEPT.
    my_bdrys,           - Output: Linked lists containing the ordered lists of 
    ot_bdrys              trim points for my_uvdata and ot_uvdata.
    my_bdryparms,       - Output: Linked lists containing information on
    ot_bdryparms          the surface-edges that generated these trim points.
                          If a specific trim point was not generated explicitly
                          by an edges on it's surface (perhaps by an edge on
                          the other surface or simply because it is 
                          dangling end-point) the edgeid field in the node
                          would have been set to NULL_OBJID.

  RETURN VALUE

    Upon exit the completion code will be one of the following

      - EMS_S_Success 
          if succeeded
      - EMS_E_InvalidArg 
          if the other surface data is neither an OM-object or a
           surface buffer or,
          the 'options' flag is non-NULL.
      - EMS_E_NoDynamicMemory
          if dynamic memory allocation was tried but failure occurred.
      - EMS_E_SurfaceError
          if a failure occurred when a call to a surface method was
          made.
      - EMS_E_LoopsetError
          if a failure occurred when a call to a surface-loopset method was
          made.
      - EMS_E_Fail
          Most probably a failure in a call to a math-function.
          In some cases the reason for failure was not understood in greater
          detail. 
    
  NOTES

    The other surface data could be a surface buffer or an OM-object. In
    the former case the trim result is as if the other surface did not have
    a loopset.

  ALGORITHM
 
    This is basically a 'passon' method which switches the operation to
    the appropriate surface-loopset. If this surface has a loopset, the
    handling is done by this loopset. If there is no loopset on this surface,
    the other surface is looked up for a loopset. If the other surface has
    a loopset the message is handled therafter by it. If none of the surfaces
    have a loopset, no trimming is really required and the boundaries
    corresponding to the entire data are returned as the output.

  SEE ALSO

    The file containing the loopset method - EMlsfulltrim.

  HISTORY

    SS  :  11/01/86  :  Creation
    RV  :  04/25/88  :  Modified to support general EMSdataselects, added
			arguments for xyz-data, partolbasis and surface
			geometries. Also changed the name from
			EMpyfulltrim to EMfulltrim.
    NP  :  08/25/92  :  Modified for ANSI compliance. "epptr" had been mistakenly
			cast to "struct EMsfintedpar *" instead of 
			"struct EMSsfintedpar *". 
                                ^^^
*/

class implementation EMSsubbs;

#include "EMS.h"
# include <stdio.h>
# include "msdef.h"
# include "emsdef.h"
# include "EMSbnddef.h"
# include "EMSbnd.h"
# include "emssfint.h"
# include "OMmacros.h"
# include "bserr.h"
# include "EMSbnddef.h"

# define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSloopset import EMlsfulltrim, EMget_props;

method EMfulltrim (IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
                     struct EMSdataselect *my_uvdata; 
                     struct EMSdataselect *my_xyzdata; 
		     struct IGRbsp_surface *my_srf;
		     struct EMSpartolbasis *mytolbasis;
                     struct EMSdataselect *ot_data; 
                     struct GRmdenv_info *ot_envinfo;
                     struct EMSdataselect *ot_uvdata;
                     struct EMSdataselect *ot_xyzdata;
		     struct IGRbsp_surface *ot_srf;
		     struct EMSpartolbasis *ottolbasis;
                     IGRdouble *correl_params;
                     IGRushort options;
                     IGRint *num_bdrys; struct EMSpypoint **my_bdrys;
                     struct EMSsfintedpar **my_bdryparms;
                     struct EMSpypoint **ot_bdrys; 
                     struct EMSsfintedpar **ot_bdryparms)
{
  IGRboolean in_world = TRUE;
  IGRint stat_OM;
  IGRuint count; 
  IGRlong msg_loc;
  struct GRid this_id;
  struct GRmdenv_info this_envinfo;
  struct EMSdataselect this_data;
  struct EMSsfintedpar *epptr;
  OM_S_CHANSELECT chan_to_loopset;
  void EMmkpybdrys();
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMerr_hndlr (ot_data->datatype != EMSdata_object &&
   ot_data->datatype != EMSdata_surface, *msg, EMS_E_InvalidArg, ret_end);

  *num_bdrys = 0;
  *my_bdrys = NULL;
  *my_bdryparms = NULL;
  *ot_bdrys = NULL;
  *ot_bdryparms = NULL;

  chan_to_loopset.type = OM_e_addr;
  chan_to_loopset.u_sel.addr = &ME.EMSsubbs->to_loopset;

  stat_OM = om$get_channel_count (object = me, p_chanselect = &chan_to_loopset,
             count = &count);
  EMomerr_exit (stat_OM, ret_end);

  if (count)
    {
    /* 
     * This surface has a loopset. The trimming can be taken care of by 
     * this loopset. NOTE : removed code to get parametric tolerances
     * to avoid duplication with the loopset method. (RV)
     */ 

    stat_OM = om$send (msg = message EMSloopset.EMlsfulltrim (&msg_loc, 
               mattyp, mat, my_uvdata, my_xyzdata, my_srf, mytolbasis, 
	       ot_data, ot_envinfo, ot_uvdata, ot_xyzdata, ot_srf, 
	       ottolbasis, correl_params, options, num_bdrys,
               my_bdrys, my_bdryparms, ot_bdrys, ot_bdryparms),
               p_chanselect = &chan_to_loopset);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopsetError, ret_end);
    }
  else
    {
    if (ot_data->datatype == EMSdata_object)
      {
      stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);
      EMomerr_exit (stat_OM, ret_end);

      stat_OM = om$get_channel_count (objid = ot_data->data.object->objid,
                 osnum = ot_data->data.object->osnum,
                 p_chanselect = &chan_to_loopset, count = &count);
      EMomerr_exit (stat_OM, ret_end);
      }
    else
      count = 0;

    if (count)
      {
      /*
       * The other surface has a loopset. The task of trimming
       * is now taken over by the other surface. The arguments
       * reflect this shift of responsibility.
       */

      this_id.objid = my_id;
      this_id.osnum = OM_Gw_current_OS;
      this_envinfo.matrix_type = *mattyp;
      OM_BLOCK_MOVE (mat, this_envinfo.matrix, sizeof (IGRmatrix));
      this_data.datatype = EMSdata_object;
      this_data.data.object = &this_id;

      stat_OM = om$send (msg = message EMSsubbs.EMfulltrim (&msg_loc, 
                 &ot_envinfo->matrix_type, ot_envinfo->matrix, ot_uvdata, 
		 ot_xyzdata, ot_srf, ottolbasis, &this_data, &this_envinfo, 
		 my_uvdata, my_xyzdata, my_srf, mytolbasis, correl_params,
		 options, num_bdrys,
                 ot_bdrys, ot_bdryparms, my_bdrys, my_bdryparms),
                 targetid = ot_data->data.object->objid,
                 targetos = ot_data->data.object->osnum);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
      }
    else
      {
      /*
       * Since none of the surfaces have boundaries, there is
       * essentially no trimming. Return the boundaries that 
       * represent the  entire data.
       */
      
      if (my_bdrys || my_bdryparms || ot_bdrys || ot_bdryparms)
        {
        if (my_bdrys)
          {
          EMmkpybdrys (&msg_loc, my_uvdata, my_bdrys, num_bdrys, NULL, NULL,
           NULL, NULL);
          EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
          }
        if (my_bdryparms)
          {
          epptr = (struct EMSsfintedpar *) EMsfintedpar_malloc (&msg_loc, 2);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_NoDynamicMemory,
           ret_end);
          epptr->edgeid = NULL_OBJID;
          epptr->next->edgeid = NULL_OBJID;
          *my_bdryparms = epptr;
          }

        if (ot_bdrys)
          {
          EMmkpybdrys (&msg_loc, ot_uvdata, ot_bdrys, num_bdrys, NULL, NULL,
           NULL, NULL);
          EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
          }
        if (ot_bdryparms)
          {
          epptr = (struct EMSsfintedpar *) EMsfintedpar_malloc (&msg_loc, 2);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_NoDynamicMemory,
           ret_end);
          epptr->edgeid = NULL_OBJID;
          epptr->next->edgeid = NULL_OBJID;
          *ot_bdryparms = epptr;
          }
        }
      else
        *num_bdrys = 1;
      }                   
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSsubbs.EMfulltrim");
  return (stat_OM);
}

end implementation EMSsubbs;
