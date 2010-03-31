/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method updates the bounds of the partedge based on the new
	geometry of the full edge. The geometry inserted/removed and the 
	resultant new geometry of the fulll edge are input. The new
	bounds are output optionally.
	The geometry and the index always are with reference to the 
	'actual' geometry of the full edge, regardless of the reversed
	flags. The bounds stored with the partedge also follow the same
	convention.
	The polyline geometry should be either added or removed from the
	existing geometry. Both changes simultaneously are not allowed.
	
History
	SM	09-Mar-88	Creation.
        SM	27-Sep-88	Added argument 'remove_poly' to handle
				random removal of geometry. Also added 
				the argument 'options' for future use.
				Currently not used.
	SM	21-Feb-89	When updating partedge bounds, do explicit
				send on to_owners channel instead of using
				EMsend_partedges function so that dummy edges
				get the message too.
Arguments

   before_ptinx		input	The point index before which the insertion or
				 removal of geometry has taken place.
   insert_poly		input	The geometry inserted.
   remove_poly		input	The geometry removed.
   new_geom		input	The total new geometry after the change.
   new_curve_type	input	New curve type for the partedge. If NULL
   				the old curve type is retained.
   new_bdry		output	The new bounds of the partedge are optionally
				output. Not Interested ? NULL : non NULL.
   new_ed_props		input	The properties of the full edge after changing
				the geometry. Not interested ? NULL :
				non NULL.
   update_partedges	input	Should the partedges owning this edge be
				sent the message too?
   options		input	Room for future growth. Currently not used.

   NOTE: The geometry, before_ptinx etc. are with reference to the actual 
   geometry stored with the full edge.. They are independent of the reversed 
   bit set with the partedge and/or the full edge.
*/

class implementation EMSpartedge;

#include "EMS.h"
#include "OMmacros.h"
#include "bsparameters.h"
#include "emsdef.h"

method EMchange_bounds(IGRlong *EMmsg;
			 IGRint before_ptinx;
			 struct IGRpolyline *insert_poly;
			 struct IGRpolyline *remove_poly;
			 struct IGRpolyline *new_geom;
			 IGRuchar *new_curve_type;
			 struct EMSedgebound *new_bdry;
			 IGRushort *new_ed_props;
			 IGRboolean update_partedges;
			 IGRushort options;
			 struct EMSpartolbasis *partolbasis)
{
  IGRlong		sts, rc;
  IGRint		i;
  struct EMSedgebound	loc_new_bdry[2];
  IGRdouble		partollen;
  IGRint		EMpartedgebound_update();
  OM_S_CHANSELECT	to_owners;
  IGRint		numowners = 0;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  EMerr_hndlr(insert_poly && remove_poly, *EMmsg, EMS_E_InvalidArg, wrapup);

/* If the parametric tolerance passed in is not valid go get it.
*/
  if(!partolbasis->is_valid)
   {
     sts = om$send(msg=message EMSboundary.EMgetsurface_info(EMmsg,NULL,
                        partolbasis),targetid=my_id);
     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
   }
  sts = EFextract_par(BSTOLLENVEC,partolbasis->tol,&partollen,&rc);

  /* Get the new bounds for the partedge based on the new geometry.
  */
  sts = EMpartedgebound_update(EMmsg, before_ptinx, insert_poly, remove_poly, 
	new_geom, 2, ME.EMSpartedge->boundary, loc_new_bdry, partollen);
  EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

  /* Store the new bounds into the instance data.
  */
  OM_BLOCK_MOVE(loc_new_bdry, ME.EMSpartedge->boundary, 
				2 * sizeof(struct EMSedgebound));
				
  /* Output the new bounds if required
  */
  if(new_bdry)
    OM_BLOCK_MOVE(loc_new_bdry, new_bdry, 2 * sizeof(struct EMSedgebound));

  /* Store the new curve type if passed in
  */
  if(new_curve_type)
    ME.EMSedge->curve_type = *new_curve_type;

  /* If the (full) edge has become non iso so am I.
  */
  if(new_ed_props)
   {
    if((*new_ed_props) & EMED_ISO) ME.EMSedge->ed_props |= EMED_ISO;
    else ME.EMSedge->ed_props &= ~EMED_ISO;
   }   


  /* Send the message up, to my partedges if specified by the caller.
  */
  if(update_partedges)
   {
    sts = EMmake_chanselect (EMSedge_to_owner, &to_owners);
    sts = om$get_channel_count (object = me, p_chanselect = &to_owners,
             			   count = (OMuint *)&numowners);

    for(i=0; i<numowners; i++)
     {
      sts = om$send(msg = message EMSpartedge.EMchange_bounds
		(EMmsg, before_ptinx, insert_poly, remove_poly, new_geom, 
		 new_curve_type, new_bdry, new_ed_props, update_partedges, 
		 options, partolbasis), from = i, to = i, 
		p_chanselect = &to_owners);
		
      if(sts == OM_W_UNKNOWN_MSG)		/* could be a loop */
		sts = OM_S_SUCCESS;
      EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
     }
   }

		
wrapup:

    EMWRAPUP(*EMmsg, sts, "In EMSpartedge.EMchange_bounds");
    return(sts);
}

end implementation EMSpartedge;
