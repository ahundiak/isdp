/*
  DESCRIPTION

    This function returns the loop (and it's children, as specified by
    'depth') in the form of an array of closed polylines (the beginning and
    ending point are repeated). Each of the loops has been packaged as a
    linestring. This geometry is available in xyz and/or uv. In addition,
    the loops' stored uv-range, it's properties and it's object-id may
    be obtained (whenever the corresponding argument is non-NULL).

    This function will not return those inner loops as boundaries that have
    a degenerate or undefined (as in open-loops) area and are at the same
    time standalone (they do not have any topological connection with
    any other edge). This behaviour, though, can be overridden by specifying
    EMS_GETB_INCLUDEDEGEN. A finer control on including certain types of
    degenerate loops can be achieved by specifying EMS_GETB_INCLUDETOPODEGEN.
    By specifying this option those loops that have any topological connection
    with other edges get included, regardless.

    When the EMS_GETB_COMPATIBLEXYZ option is used, this function will return
    the xyz data solely from the non-subordinate edges out of the pair of
    common edges. Under this option the xyz end-points of all the edges
    terminating at a vertex will be consistent (identically exact).
    This has the effect of consistent geometry being returned from adjacent
    surfaces.

    The option EMS_GETB_COMPATIBLEUV option, will return uv data that contains
    the same number of points as the non-subordinate, stroked edge will
    have. This ensures one to one correspondence between points in uv-space
    and xyz-space, even across surfaces. The option to EMS_GETB_STROKEISO,
    can be used to force the iso-edge to be stroked even if the compatibility
    option is not used.

    This function will return each edge as a separate polyline. So, from the 
    output, polys belonging to a loop cannot be distinguished. 
    EMSloopset.EMlsgetbdry and EMSloop.EMlpgetbdry methods merge all the 
    edge boundaries in to one polyline.

    The first call to this function must initialize the output arguments
    to NULLS. All memory is allocated inside the call to this function.

  HISTORY

    SS  :  06/14/90  :  Creation. Initial stuff from EMlppack
*/

class implementation Root;

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "igetypedef.h"

#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"

#include "EMS.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "emsdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include <stdio.h>
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "emsmacros.h"

#include "PWminimum.h"
#include "PWerror.h"

#include "PWapi/lpbdry.h"

from EMSedge import EMgetstrkpy, EMget_props;
from EMSloop import EMget_props, EMgeomattr, EMtopoattr;



PWresult pwGetLpBdry
(
 PWobjid		lp,
 PWosnum		os,
 short 		        *mattyp, 
 PWmatrix 		mat,
 struct IGRbsp_surface  *srfgeom,
 struct EMSpartolbasis  *partolbas,
 unsigned short 	options,
 int 		        depth,
 int 		        *numbdrys,
 struct IGRpolyline 	**xyzbdrys,
 struct IGRpolyline 	**uvbdrys,
 PWobjid		**edids,
 unsigned short		**edprops
)
{
  IGRboolean reversed, is_degen, is_connected;
  IGRushort loc_options, lpprops;
  IGRint i, j, relinx;
  IGRint numb, num_xyzpts, num_uvpts;
  OMuint count;
  IGRlong msg_loc, stat_OM;
  IGRdouble *uvpts, *xyzpts, (*ptr3)[3], (*ptr2)[2], uvtol;
  struct IGRpolyline *xyzb, *uvb;

  OM_S_CHANSELECT chan_to_edges, chan_to_inner;
   
  unsigned int retval = PW_K_Success;

  OM_S_OBJECT_LINKAGE loopset;

  IGRushort eprops;
  
  stat_OM = OM_S_SUCCESS;

  uvpts = NULL;
  xyzpts = NULL;
  numb = *numbdrys;

  stat_OM = om$send(msg = message EMSloop.EMget_props(&msg_loc, &lpprops),
		    targetid = lp,
		    senderid = lp,
		    targetos = os);
  OnErrorState(!(1&stat_OM), retval, SetError(PW_K_Pathway, PW_K_Internal),
	       ret_end);

  if(!(lpprops & EMLP_ACTIVE))
    goto ret_end;

  EMmake_chanselect (EMSbd_owner_to_comps, &chan_to_edges);
  stat_OM = om$get_channel_count (objid = lp, osnum = os, 
				  p_chanselect = &chan_to_edges,
				  count = &count);
  OnErrorState(!(1&stat_OM), retval, SetError(PW_K_Pathway, PW_K_Internal),
	       ret_end);
  
  loc_options = NULL;
  if (options & EMS_GETB_COMPATIBLEUV)
    loc_options |= EMS_GETB_COMPATIBLEUV;
  if (options & EMS_GETB_COMPATIBLEXYZ)
    loc_options |= (EMS_GETB_COMPATIBLEXYZ | EMS_GETB_CONSISTLFXYZVTX);
  if (options & EMS_GETB_STROKEISO)
    loc_options |= EMS_GETB_STROKEISO;

  reversed = lpprops & EMLP_REVERSED;
  for (i=0, j=count-1; i<count; i++, j--)
    {
    GRobjid edid = NULL_OBJID;
    PWosnum edos;  

    relinx = reversed ? j : i;

    stat_OM = om$get_objid_at_index (objid = lp, osnum = os, 
				 index = relinx,
				 p_chanselect = &chan_to_edges, 
				 objidaddr = &edid,
				 osnumaddr = &edos);
    
    if((options & EMS_GETB_DOMINANT) || edprops)
    {
        stat_OM = om$send(msg = message EMSedge.EMget_props(&msg_loc, &eprops),
	                  targetid = edid,
		          senderid = lp,
		          targetos = edos);
        OnErrorState(!(1&stat_OM), retval, SetError(PW_K_Pathway, PW_K_Internal),
	             ret_end); 
   
        if( (options & EMS_GETB_DOMINANT) && (eprops & EMED_SUBORDINATE) ) continue;
    }

    stat_OM = om$send (msg = message EMSedge.EMgetstrkpy (&msg_loc, mattyp,
               mat, srfgeom, partolbas, loc_options, &num_xyzpts, &num_uvpts,
               xyzbdrys ? &xyzpts : NULL, uvbdrys ? &uvpts : NULL),
	       targetid = edid,
	       senderid = lp,
	       targetos = edos);	       
    OnErrorState(!(1&stat_OM & msg_loc), retval, 
		 SetError(PW_K_Pathway, PW_K_Internal), ret_end);

    if (xyzbdrys && !num_xyzpts || uvbdrys && !num_uvpts)
      continue;

    if (xyzbdrys || uvbdrys)
      {
      if(xyzbdrys)
      {
        if (*xyzbdrys)
          *xyzbdrys = (struct IGRpolyline *)om$realloc (ptr = (char *)*xyzbdrys, 
                      size = (numb + 1) * sizeof (struct IGRpolyline));
        else
          *xyzbdrys = (struct IGRpolyline *) om$malloc (size = 
                     sizeof (struct IGRpolyline));
        OnErrorState(!*xyzbdrys, retval, 
	  	     SetError(PW_K_Pathway, PW_K_DynamicMemory), ret_end);
        xyzb = &(*xyzbdrys)[numb];
        xyzb->num_points = 0;
        xyzb->points = NULL;
        ptr3 = NULL;
        ptr3 = (IGRdouble (*)[3])om$malloc (size = num_xyzpts * sizeof (IGRpoint));
        OnErrorState(!ptr3, retval, 
	  	     SetError(PW_K_Pathway, PW_K_DynamicMemory), ret_end);
        xyzb->points = (IGRdouble *)ptr3;
      
        OM_BLOCK_MOVE (xyzpts, ptr3[xyzb->num_points],  //num_points = 0
  	               num_xyzpts * sizeof (IGRpoint));
        xyzb->num_points = num_xyzpts;

        om$dealloc(ptr = xyzpts); xyzpts = NULL;

      } //if xyzbdrys

      if(uvbdrys)
      {
        if (*uvbdrys)
          *uvbdrys = (struct IGRpolyline *)om$realloc (ptr = (char *)*uvbdrys, 
                      size = (numb + 1) * sizeof (struct IGRpolyline));
        else
          *uvbdrys = (struct IGRpolyline *) om$malloc (size = 
                     sizeof (struct IGRpolyline));
        OnErrorState(!*uvbdrys, retval, 
	  	     SetError(PW_K_Pathway, PW_K_DynamicMemory), ret_end);
        uvb = &(*uvbdrys)[numb];
        uvb->num_points = 0;
        uvb->points = NULL;
        ptr2 = NULL;
        ptr2 = (IGRdouble (*)[2])om$malloc (size = num_uvpts*2*sizeof (IGRdouble));
        OnErrorState(!ptr2, retval, 
	  	     SetError(PW_K_Pathway, PW_K_DynamicMemory), ret_end);
        uvb->points = (IGRdouble *)ptr2;
      
        OM_BLOCK_MOVE (uvpts, ptr2[uvb->num_points],  //num_points = 0
  	               num_uvpts * 2 * sizeof (IGRdouble));
        uvb->num_points = num_uvpts;

        om$dealloc(ptr = uvpts); uvpts = NULL;

      } // if uvbdrys

      if (edids)
      {
      if (*edids)
        *edids = (GRobjid *)om$realloc (ptr = (char *) *edids, 
      		  size = (numb + 1) * sizeof (GRobjid));
      else
        *edids = (GRobjid *)om$malloc (size = sizeof (GRobjid));

      OnErrorState(!*edids, retval, 
		   SetError(PW_K_Pathway, PW_K_DynamicMemory), ret_end);
 
      (*edids)[numb] = edid;
      }

      if (edprops)
      {
      if (*edprops)
        *edprops = (IGRushort *)om$realloc (ptr = (char *)*edprops, 
                    size = (numb + 1) * sizeof (IGRushort));
      else
        *edprops = (IGRushort *)om$malloc (size = sizeof (IGRushort));
    
      OnErrorState(!*edprops, retval, 
		   SetError(PW_K_Pathway, PW_K_DynamicMemory), ret_end);

      (*edprops)[numb] = eprops;
      }

      numb++;

      } // if xyzbdrys || uvbdrys
    } // for all the edges

  // Now increment the output number of boundaries

  *numbdrys = numb;
  
  if (depth)
    {
    EMmake_chanselect (EMSloop_to_inner, &chan_to_inner);
    count = 0;
    om$get_channel_count (objid = lp, osnum = os, 
			  p_chanselect = &chan_to_inner,
			  count = &count);
    if (count)
      {
      for (i=0; i<count; i++)
        {
	PWobjid ilpid = NULL_OBJID;
	PWosnum ilpos;  

        stat_OM = om$get_objid_at_index (objid = lp, osnum = os, 
					 index = i,
					 p_chanselect = &chan_to_inner, 
					 objidaddr = &ilpid,
					 osnumaddr = &ilpos);

        is_degen = FALSE;
        if (! (options & EMS_GETB_INCLUDEDEGEN))
          {
          uvtol = partolbas->is_valid ? partolbas->tol : EMS_HIGH_UVLENTOL;
          stat_OM = om$send (msg = message EMSloop.EMgeomattr (&msg_loc, NULL,
                     uvtol, &is_degen, NULL),
		     targetid = ilpid,
		     senderid = lp,
		     targetos = ilpos);
	  OnErrorState(!(1&stat_OM & msg_loc), retval, 
		       SetError(PW_K_Pathway, PW_K_Internal), ret_end);

          if (is_degen && (options & EMS_GETB_INCLUDETOPODEGEN))
            {
            stat_OM = om$send (msg = message EMSloop.EMtopoattr (&msg_loc,
                       NULL, &is_connected, NULL, NULL, NULL), 
	               targetid = ilpid,
		       senderid = lp,
		       targetos = ilpos);
	  OnErrorState(!(1&stat_OM & msg_loc), retval, 
		       SetError(PW_K_Pathway, PW_K_Internal), ret_end);

            if (is_connected)
              is_degen = FALSE;
          } // is_degen and include top degen
	} // dont include degen 

        if (!is_degen)
          {
	  retval = pwGetLpBdry(ilpid, ilpos, mattyp, mat, srfgeom, partolbas,
			       options, depth-1, 
			       numbdrys, xyzbdrys, uvbdrys, edids, edprops);
	  OnErrorCode(retval, ret_end);
          } // !is_degen
        } // for loop
      } // count
    } //depth

ret_end:
  
  if(!(1&retval))
  {
    if(xyzpts) { om$dealloc(ptr = xyzpts); xyzpts = NULL; }
    if(uvpts)  { om$dealloc(ptr = uvpts);  uvpts = NULL; }
  }
  
  return (retval);
}

end implementation Root;

