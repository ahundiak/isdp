/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This is an overridden implementation for ptedge.
	
Algorithm

   Do a point location test with the input loopset.
   If the location is INAREA then return two boundaries as if an entire
   non degenerate edge is in area. For all other locations (ONEDGE, ONVRTX, 
   INHOLE) return no boundaries.

*/
class implementation EMSptedge;

#include "EMS.h"
#include "OMmacros.h"
#include "emssfint.h"
#include "emsinter.h"
#include "emsinterdef.h"

from EMSloopset import EMpt_location;

method EMtrimyourself(IGRlong *EMmsg;GRobjid *against;
                      IGRushort options;
                      struct EMSsfintedpar **against_bdrys,
                                           **my_bdrys;
                      IGRint *num_bdrys;
                      struct EMSpartedinfo *part;
                      struct EMSpartolbasis *partolbasis)
{
  IGRlong		sts, i;
  struct EMSsfintedpar *EMsfintedpar_malloc(),
		       *my_sfintedpar, *against_sfintedpar;
  struct EMSptloc_info	location;
  IGRboolean		keep = FALSE;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  if(my_bdrys) *my_bdrys = NULL;
  if(against_bdrys) *against_bdrys = NULL;

  sts = om$send(msg=message EMSloopset.EMpt_location
			(EMmsg, ME.EMSptedge->point, &location, partolbasis), 
			 targetid=*against);
  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);

  if(location.location == EMS_L_INAREA)
   keep = TRUE;
  else if( ((location.location == EMS_L_ONEDGE) || 
	   (location.location == EMS_L_ONVRTX)) && 
	   (options & EMS_INTER_BDRYISAREA))
   keep = TRUE;

  if(keep)
   {
     *num_bdrys = 1;

     /*create the link list of structures EMSsfintedpar 
       for all my boundaries.
       Even if the exact size of memory required is known here, the
       function EMsfintedpar_malloc is called so that mallocing and freeing
       of memory can be done in a centralized way.
     */

     if(my_bdrys)
      {
       *my_bdrys = EMsfintedpar_malloc(EMmsg, 2);
       EMerr_hndlr(!(1&*EMmsg),*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
      }

     if(against_bdrys)
      {
       *against_bdrys = EMsfintedpar_malloc(EMmsg, 2);
       EMerr_hndlr(!(1&*EMmsg),*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
      }

    /* For each positive boundary on me,use a structure and initialize all the
      fields in it to return the information to the caller.
    */

     if(my_bdrys) my_sfintedpar = *my_bdrys;
     if(against_bdrys) against_sfintedpar = *against_bdrys;

     for(i=0; i<2; i++)
      {
	if(my_bdrys)
	 {
          my_sfintedpar->edgeid = my_id;
	  my_sfintedpar->edgepar.span_inx = 0;
	  my_sfintedpar->edgepar.param = i ? 1.0 : 0.0;
          OM_BLOCK_MOVE(ME.EMSptedge->point, my_sfintedpar->point, 
				2 * sizeof(IGRdouble));
          my_sfintedpar->intloc = i ? EMScvint_rtend : EMScvint_lfend;
 	  my_sfintedpar->info = NULL;
          my_sfintedpar = my_sfintedpar->next;
	 }
	
	if(against_bdrys)
	 {
          if(location.location == EMS_L_INAREA) 
		against_sfintedpar->intloc = EMScvint_unknown;
	  else against_sfintedpar->intloc = location.edge[0].nst_pt.location;
	
          OM_BLOCK_MOVE(location.edge[0].nst_pt.proj_pt, 
			against_sfintedpar->point, 2 * sizeof(IGRdouble));
			
	  OM_BLOCK_MOVE(&location.edge[0].nst_pt.param, 
			&against_sfintedpar->edgepar, 
			sizeof(struct EMSedgebound));
			
          if(location.location == EMS_L_INAREA) 
            against_sfintedpar->edgeid = NULL_OBJID;
          else
            against_sfintedpar->edgeid = location.edge[0].edge_id;

	  against_sfintedpar->info = NULL;
          against_sfintedpar = against_sfintedpar->next;
         }

      }
     *EMmsg = EMS_I_InAreaTrim;

    } /* if(keep) */
   
   else
    {
      *EMmsg = EMS_I_InHoleTrim;
      *num_bdrys = 0;
    }

wrapup:
   EMWRAPUP(*EMmsg,sts,"In EMSptedge.EMtrimyourself");    
   return (sts);
}

end implementation EMSptedge;
