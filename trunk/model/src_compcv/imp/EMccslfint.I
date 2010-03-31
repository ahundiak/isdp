class implementation GRcompcurve;

#include "EMS.h"
#include "EMScc.h"
#include "OMmacros.h"
#include "emserr.h"
#include "emsdef.h"
#include "EMSmsgdef.h"
#include "emsinterdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define GRAIN_SIZE 3

method EMcrvslfint( IGRlong		  *msg;
		    struct GRvg_construct *cnst_list;
		    struct GRmdenv_info   *my_objenv;

		    IGRlong		  *pnt_slots;
		    IGRlong		  *grand_num_pnt;
		    struct GRid		  **pnt_ids;
		    struct GRparms	  **my_pnt_inters;
		    IGRdouble		  **inter_pnts_xyz;

		    IGRlong		  *crv_slots;
		    IGRlong		  *grand_num_crv;
		    struct GRid		  **crv_ids;
		    struct GRparms	  **my_crv_inters)

/*
Abstract
	This method intersects a composite curve with itself

Notes
	The following procedure is followed for every
	component of the composite curve.
	
		1. Self intersect the component
		
		2. Intersect a component(x) with the next component
		   but do not consider the end point coincidence as
		   intersection.

		3. Intersect the component x with components following
		   its next component but consider the end point
		   coincidence as intersection.
		
	SHORTCOMINGS:	If the composite has only 2 components and if
	the end points of the composite are coincident, then this goes
	undetected.  Possible solution: After intersection check the end
	points for coincidence.

        Please see the documentation for the GRbspline.EMcrvslfint
        implementation for the correct meaning of the output.

History
	gk	11/26/86	creation date
	rlw	05/08/87	changed channel name
	gk	5/25/87		include EMSinters definition
    DLB 10/28/87    mdo for version 1.1.0
	gk	12/3/87		arguments changed
	SS	01/06/89	Made modifications to fit the new meaning
				of the output - my_pnt_inters and
				my_crv_inters. Also cleaned up the
				error string usage.
*/

{
  OM_S_CHANSELECT	chan_def;
  OMuint		numb_components, start;
  IGRlong		i, j, k, inx, status, loc_msg,
			numslots, loc_grand_num_pnt, loc_grand_num_crv,
                        loc_pnt_slots, loc_crv_slots;

  IGRdouble 		*loc_inter_pnts_xyz = NULL;

  OM_S_OBJECT_LINKAGE	*candidate_object = NULL;

  struct GRid		other_obj, *loc_pnt_ids = NULL, *loc_crv_ids = NULL;

  IGRboolean		stat_func;

  struct GRparms	*loc_my_pnt_inters = NULL, *loc_my_crv_inters = NULL,
			*loc_ot_pnt_inters = NULL, *loc_ot_crv_inters = NULL;

/* Initialize */

  *msg = EMS_S_Success;
  status = OM_S_SUCCESS;

  status = EMmake_chanselect (GRcmpowner_to_components, &chan_def);
  EMomerr_exit (status, wrapup);

/* Get channel count */

  status = om$get_channel_count(p_chanselect = &chan_def,
			        objid = my_id,
				count = &numb_components);
  EMomerr_exit (status, wrapup);  

/* Get my childrens' id */

  candidate_object = ( OM_S_OBJECT_LINKAGE *)om$malloc
		     (size=numb_components*sizeof(OM_S_OBJECT_LINKAGE));
  EMerr_hndlr (!candidate_object, *msg, EMS_E_NoDynamicMemory, wrapup);

  status = om$get_channel_objects( objid = my_id, 
				   p_chanselect = &chan_def, 
				   list = candidate_object, 
				   size = numb_components, 
				   count = &start); /* temp variable */
  EMomerr_exit (status, wrapup);


  loc_pnt_slots = 0;
  loc_crv_slots = 0;
  for( i = 0; i < numb_components; i++ )
   {
     other_obj.objid = candidate_object[i].S_objid;
     other_obj.osnum = candidate_object[i].osnum;

/* First self intersection */

     status = om$send( msg = OPPmargs,
		       targetid = other_obj.objid,  
		       targetos = other_obj.osnum);
     EMomerr_exit (status, wrapup);
     if (EMSerror (*msg))
       goto wrapup;

     if( i IS (numb_components - 1) )continue;	/* last one? */

/*   What follows is for typical components */
/*   Intersect with next component */

     loc_grand_num_pnt = 0;
     loc_grand_num_crv = 0;
     status = om$send( msg = message GRcurve.EMcrvcrvint
               (&loc_msg, cnst_list, my_objenv, NULL,
               &other_obj, my_objenv, EMS_CVINT_NOENDCOINC,
               &loc_pnt_slots, &loc_grand_num_pnt, 
               pnt_ids ? &loc_pnt_ids : NULL,
               my_pnt_inters ? &loc_my_pnt_inters : NULL, 
               my_pnt_inters ? &loc_ot_pnt_inters : NULL, 
               inter_pnts_xyz ? &loc_inter_pnts_xyz : NULL,
               &loc_crv_slots, &loc_grand_num_crv,
               crv_ids ? &loc_crv_ids : NULL,
               my_crv_inters ? &loc_my_crv_inters : NULL,
               my_crv_inters ? &loc_ot_crv_inters : NULL),
               targetid = candidate_object[i+1].S_objid);
     EMomerr_exit (status, wrapup);
     EMerr_hndlr (EMSerror (loc_msg), *msg, EMS_E_CurveError, wrapup);

     if (loc_grand_num_pnt)
       {
       numslots = *pnt_slots;
       if (pnt_ids)
         {
         numslots = *pnt_slots;
         stat_func = EMcopymem (sizeof (struct GRid), loc_grand_num_pnt,
                      loc_pnt_ids, GRAIN_SIZE, &numslots, *grand_num_pnt,
                      pnt_ids);
         EMerr_hndlr (!stat_func, *msg, EMS_E_NoDynamicMemory, wrapup);
         }
       if (my_pnt_inters)
         {
         numslots = *pnt_slots;
         stat_func = EMcopymem (2 * sizeof (struct GRparms), loc_grand_num_pnt,
                      NULL, GRAIN_SIZE, &numslots, *grand_num_pnt,
                      my_pnt_inters);
         EMerr_hndlr (!stat_func, *msg, EMS_E_NoDynamicMemory, wrapup);

         inx = 2 * *grand_num_pnt;
         for (j=0, k=0; j<loc_grand_num_pnt; j++, k+=2)
           {
           OM_BLOCK_MOVE (&loc_my_pnt_inters[j], 
            &(*my_pnt_inters)[inx+k], sizeof (struct GRparms));

           OM_BLOCK_MOVE (&loc_ot_pnt_inters[j], 
            &(*my_pnt_inters)[inx+k+1], sizeof (struct GRparms));
           }
         }
       if (inter_pnts_xyz)
         {
         numslots = *pnt_slots;
         stat_func = EMcopymem (3 * sizeof (IGRdouble), loc_grand_num_pnt,
                      loc_inter_pnts_xyz, GRAIN_SIZE, &numslots,
                      *grand_num_pnt, inter_pnts_xyz);
         EMerr_hndlr (!stat_func, *msg, EMS_E_NoDynamicMemory, wrapup);
         }
       *pnt_slots = numslots;
       *grand_num_pnt += loc_grand_num_pnt;
       }

     if (loc_grand_num_crv)
       {
       numslots = *crv_slots;
       if (crv_ids)
         {
         numslots = *crv_slots;
         stat_func = EMcopymem (sizeof (struct GRid), loc_grand_num_crv,
                      loc_crv_ids, GRAIN_SIZE, &numslots, *grand_num_crv,
                      crv_ids);
         EMerr_hndlr (!stat_func, *msg, EMS_E_NoDynamicMemory, wrapup);
         }
       if (my_crv_inters)
         {
         numslots = *crv_slots;
         stat_func = EMcopymem (4 * sizeof (struct GRparms), loc_grand_num_crv,
                      NULL, GRAIN_SIZE, &numslots, *grand_num_crv,
                      my_crv_inters);
         EMerr_hndlr (!stat_func, *msg, EMS_E_NoDynamicMemory, wrapup);

         inx = 4 * *grand_num_crv;
         for (j=0, k=0; j<loc_grand_num_crv*2; j+=2, k+=4)
           {
           OM_BLOCK_MOVE (&loc_my_crv_inters[j], 
            &(*my_crv_inters)[inx+k], 2 * sizeof (struct GRparms));

           OM_BLOCK_MOVE (&loc_ot_crv_inters[j], 
            &(*my_crv_inters)[inx+k+2], 2 * sizeof (struct GRparms));
           }
         }
       *pnt_slots = numslots;
       *grand_num_crv += loc_grand_num_crv;
       }

/*   Intersect with other components, if any */

     if( i IS (numb_components - 2) )continue;	/* last but one */

     loc_grand_num_pnt = 0;
     loc_grand_num_crv = 0;
     status = om$send( msg = message GRcurve.EMcrvcrvint
               (&loc_msg, cnst_list, my_objenv, NULL,
               &other_obj, my_objenv, NULL,
               &loc_pnt_slots, &loc_grand_num_pnt, 
               pnt_ids ? &loc_pnt_ids : NULL,
               my_pnt_inters ? &loc_my_pnt_inters : NULL, 
               my_pnt_inters ? &loc_ot_pnt_inters : NULL, 
               inter_pnts_xyz ? &loc_inter_pnts_xyz : NULL,
               &loc_crv_slots, &loc_grand_num_crv,
               crv_ids ? &loc_crv_ids : NULL,
               my_crv_inters ? &loc_my_crv_inters : NULL,
               my_crv_inters ? &loc_ot_crv_inters : NULL),
               p_chanselect = &chan_def,
	       from = (i+2), to = (numb_components-1));
     EMomerr_exit (status, wrapup);
     EMerr_hndlr (EMSerror (loc_msg), *msg, EMS_E_CurveError, wrapup);

     if (loc_grand_num_pnt)
       {
       numslots = *pnt_slots;
       if (pnt_ids)
         {
         numslots = *pnt_slots;
         stat_func = EMcopymem (sizeof (struct GRid), loc_grand_num_pnt,
                      loc_pnt_ids, GRAIN_SIZE, &numslots, *grand_num_pnt,
                      pnt_ids);
         EMerr_hndlr (!stat_func, *msg, EMS_E_NoDynamicMemory, wrapup);
         }
       if (my_pnt_inters)
         {
         numslots = *pnt_slots;
         stat_func = EMcopymem (2 * sizeof (struct GRparms), loc_grand_num_pnt,
                      NULL, GRAIN_SIZE, &numslots, *grand_num_pnt,
                      my_pnt_inters);
         EMerr_hndlr (!stat_func, *msg, EMS_E_NoDynamicMemory, wrapup);

         inx = 2 * *grand_num_pnt;
         for (j=0, k=0; j<loc_grand_num_pnt; j++, k+=2)
           {
           OM_BLOCK_MOVE (&loc_my_pnt_inters[j], 
            &(*my_pnt_inters)[inx+k], sizeof (struct GRparms));

           OM_BLOCK_MOVE (&loc_ot_pnt_inters[j], 
            &(*my_pnt_inters)[inx+k+1], sizeof (struct GRparms));
           }
         }
       if (inter_pnts_xyz)
         {
         numslots = *pnt_slots;
         stat_func = EMcopymem (3 * sizeof (IGRdouble), loc_grand_num_pnt,
                      loc_inter_pnts_xyz, GRAIN_SIZE, &numslots,
                      *grand_num_pnt, inter_pnts_xyz);
         EMerr_hndlr (!stat_func, *msg, EMS_E_NoDynamicMemory, wrapup);
         }
       *pnt_slots = numslots;
       *grand_num_pnt += loc_grand_num_pnt;
       }

     if (loc_grand_num_crv)
       {
       numslots = *crv_slots;
       if (crv_ids)
         {
         numslots = *crv_slots;
         stat_func = EMcopymem (sizeof (struct GRid), loc_grand_num_crv,
                      loc_crv_ids, GRAIN_SIZE, &numslots, *grand_num_crv,
                      crv_ids);
         EMerr_hndlr (!stat_func, *msg, EMS_E_NoDynamicMemory, wrapup);
         }
       if (my_crv_inters)
         {
         numslots = *crv_slots;
         stat_func = EMcopymem (4 * sizeof (struct GRparms), loc_grand_num_crv,
                      NULL, GRAIN_SIZE, &numslots, *grand_num_crv,
                      my_crv_inters);
         EMerr_hndlr (!stat_func, *msg, EMS_E_NoDynamicMemory, wrapup);

         inx = 4 * *grand_num_crv;
         for (j=0, k=0; j<loc_grand_num_crv*2; j+=2, k+=4)
           {
           OM_BLOCK_MOVE (&loc_my_crv_inters[j], 
            &(*my_crv_inters)[inx+k], 2 * sizeof (struct GRparms));

           OM_BLOCK_MOVE (&loc_ot_crv_inters[j], 
            &(*my_crv_inters)[inx+k+2], 2 * sizeof (struct GRparms));
           }
         }
       *crv_slots = numslots;
       *grand_num_crv += loc_grand_num_crv;
       }
   }

wrapup:
  if (candidate_object)
    om$dealloc (ptr = candidate_object);
  if (loc_pnt_ids)
    om$dealloc (ptr = loc_pnt_ids);
  if (loc_crv_ids)
    om$dealloc (ptr = loc_crv_ids);
  if (loc_my_pnt_inters)
    om$dealloc (ptr = loc_my_pnt_inters);
  if (loc_my_crv_inters)
    om$dealloc (ptr = loc_my_crv_inters);
  if (loc_ot_crv_inters)
    om$dealloc (ptr = loc_ot_crv_inters);
  if (loc_ot_crv_inters)
    om$dealloc (ptr = loc_ot_crv_inters);
  if (loc_inter_pnts_xyz)
    om$dealloc (ptr = loc_inter_pnts_xyz);

  EMWRAPUP (*msg, status, "GRcompcv.EMcrvslfint");
  return(status);
}
end implementation GRcompcurve;
