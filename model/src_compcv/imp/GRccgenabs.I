/* 
 DESCRIPTION
  
 This method generates the abstract data
 representation for a composite curve.

 RETURN VALUES

 *msg	  IGRlong	 completion code
                         - MSSUCC if successful
                         - MSFAIL (severe) if failure
                           due to allocation problems
 **absgptr    IGRchar	 pointer to abstract geometry
  
 NOTES

 This method should not be present in the system.
   
 ALGORITHM
  
 Get all component curves and merge them together.

 HISTORY

 rlw	05/08/87 : Creation date
 rlw	05/18/87 : Modified because I made up a merge curve function that
                   is shared between this command and the merge curve command
 DLB    10/28/87 : Modified channel for version 1.1.0  
 dhm    10/20/88 : Set num_boundaries in the output to 0 to fix a memory
                   fault problem.
 rlw    01/31/89 : Modified not to core dump if the composite has no children.
 SM	11-Oct-89: Pass NULL for curve buffers to EFmerge_curves().
 SM     29-Oct-92: If EFmerge_curve fails, retry by setting the basis
                   tol to 2*cht. This change is to better handle comp. cvs
                   produced from sf/sf intersection, where the trace tol
                   used is 2*cht. See GRccpostab.I for related changes.
 SM     08-Mar-93  Moved the above to the EFmerge_curves function for
                   consistency across the board. The implication being that
                   we can now merge any 2 curves within 2*cht.
 Sudha   06/21/93        modified for BSprototype ansification
 */

class implementation GRcompcurve;

#include "EMScc.h"
#define MAX_COMPONENTS 20
#include "bs.h"				/* Has bs error codes */
#include "bsparameters.h"
#include "madef.h"			/* Has MAIDMX */
#include "msdef.h"			/* Has MSSUCC, MSFAIL */
#include "OMmacros.h"			/* Has OM_BLOCK_MOVE macro */
#include "bsfreecv.h"
#define DEBUG 0

method GRgenabsg(IGRlong *msg; IGRshort *matrix_type;
		 IGRmatrix matrix; IGRchar **absgptr)
{
 IGRboolean		status;
 IGRuint		object_count;
 IGRlong		msg_loc, i, sts;
 struct			IGRbsp_curve *merged_curve, *curve;
 struct			GRlc_info static_locate_information[MAX_COMPONENTS];
 struct			GRlc_info *locate_information;
 struct GRmdenv_info	composite_module_enviroment;
 OM_S_CHANSELECT	my_chanselect;
 OM_S_OBJECT_LINKAGE	static_objects[MAX_COMPONENTS], *objects;
 extern IGRboolean      EFmerge_curves();
 extern IGRboolean      GRgetbuffer();

/*
 * Initialize
 */

 *msg = MSSUCC;
 merged_curve = NULL;
 objects = NULL;
 locate_information = NULL;

/*
 * Get the object id's of my component curves
 */

 my_chanselect.type = OM_e_addr;
 my_chanselect.u_sel.addr = &ME.GRcmpowner->to_components;
 sts = om$get_channel_count(object = me,
                            p_chanselect = &my_chanselect,
                            count = &object_count);
  if (! (1 & sts))
   {
    *msg = MSFAIL;
    return(OM_E_ABORT);
   }
 if (! object_count)
  {
#if DEBUG
   fprintf(stderr, "\n\nComposite curve %d is invalid", my_id);
   fprintf(stderr, "\nIt's children have left home without a message\n\n"); 
#endif
   sts = om$send(
     msg = message Root.delete(0),
     targetid = my_id);
   *msg = MSFAIL;
   return(OM_E_ABORT);
  }
/*
 * Get the memory to store the linkages in
 */
 if (object_count > MAX_COMPONENTS)
  {
   objects = (OM_S_OBJECT_LINKAGE *) malloc(object_count *
             sizeof(OM_S_OBJECT_LINKAGE));
    if (!objects)
     {
      *msg = MANOMEMORY;
      goto wrapup;
     }
   locate_information = (struct GRlc_info *) malloc(object_count *
                        sizeof(struct GRlc_info));
    if (!locate_information)
     {
      *msg = MANOMEMORY;
      goto wrapup;
     }
  }
 else
  {
   objects = &static_objects[0];
   locate_information = &static_locate_information[0];
  }
/*
 * Get the objects off of my channel
 */
 sts = om$get_channel_objects(object = me,
                              p_chanselect = &my_chanselect,
                              list = objects,
                              size = object_count,
                              count = &object_count);
  if (! (1 & sts))
   {
    *msg = MSFAIL;
    goto wrapup;
   }
/*
 * Setup the module enviroment of each object.  By design my components
 * must have the same module enviroment as I do.
 */
 composite_module_enviroment.matrix_type = *matrix_type;
 OM_BLOCK_MOVE(matrix, composite_module_enviroment.matrix, sizeof(IGRmatrix));
 for (i = 0; i < object_count; i++)
  {
   locate_information[i].located_obj.objid = objects[i].S_objid;
   locate_information[i].located_obj.osnum = objects[i].osnum;
   locate_information[i].module_info.md_env = composite_module_enviroment;
  }
/*
 * Get the merged curve
 */
 status = EFmerge_curves(
   object_count,
   locate_information,
   NULL, 
   my_id,
   &merged_curve,
   FALSE, 		/* Do not try filling gaps */
   msg);
 if (!status) goto wrapup;

/*
 * Get the size of this thing and put it in the abstract bufferr
 */
 merged_curve->num_boundaries = 0;
 status = GRgetbuffer(msg,
                      matrix_type,
                      matrix,
                      &merged_curve->num_poles,
                      &merged_curve->order,
                      &merged_curve->rational,
                      &merged_curve->num_boundaries,
                      &my_id,
                      absgptr);
  if (!status)
   {
    *msg = MSFAIL;
    goto wrapup;
   }
 curve = (struct IGRbsp_curve *) *absgptr;
 OM_BLOCK_MOVE(merged_curve->poles,
               curve->poles,
               sizeof(IGRpoint) * merged_curve->num_poles);
 OM_BLOCK_MOVE(merged_curve->knots,
               curve->knots,
               sizeof(IGRdouble) * merged_curve->num_knots);
 if (merged_curve->rational)
  OM_BLOCK_MOVE(merged_curve->weights,
                curve->weights,
                sizeof(IGRdouble) * merged_curve->num_poles);
 curve->order = merged_curve->order;
 curve->periodic = merged_curve->periodic;
 curve->non_uniform = merged_curve->non_uniform;
 curve->num_poles = merged_curve->num_poles;
 curve->num_knots = merged_curve->num_knots;
 curve->rational = merged_curve->rational;
 curve->planar = merged_curve->planar;
 curve->phy_closed = merged_curve->phy_closed;
 curve->num_boundaries = 0;
 curve->bdrys = NULL;

/*
 * Eof
 */
wrapup:
 if (merged_curve) status = BSfreecv (&msg_loc, merged_curve);
 if (objects && (objects != &static_objects[0])) free(objects);
 if (locate_information && 
     (locate_information != &static_locate_information[0])) 
    free(locate_information);
 if (! (1 & *msg))
  return(OM_E_ABORT);
 else
  return(OM_S_SUCCESS);
}

end implementation GRcompcurve;
