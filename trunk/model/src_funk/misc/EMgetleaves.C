#include <math.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "dpdef.h"
#include "dp.h"
#include "igrdp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "madef.h"
#include "maerr.h"
#include "exdef.h"
#include "exmacros.h"
#include "bserr.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "emsdef.h"
#include "emsdattyp.h"
#include "bsgeom_cvsf.h"

#define STATIC_SCRATCH_BYTES 30

#define U 0
#define V 1
 
#define X 0
#define Y 1
#define Z 2

#define CONST_U  1
#define CONST_V  2

#define SQUARE(x) ((x) * (x))

extern GRclassid OPP_EMSsubbs_class_id, OPP_GRcurve_class_id;
extern GRclassid OPP_EMScomposite_class_id;

/* DESCRIPTION: This function takes in ANY kind of composite (curve or surface)
 * -----------  and returns the lowermost level components (leaves) in it. It
 *              also has the option of returning all composite elements that
 *              are part of the tree of the incoming composite. This function
 *              correctly assumes that composites can be formed out of other
 *              composites.
 *              
 *              Since the function is of a recursive nature, it is important
 *              to correctly initialize input arguments.
 *               
 *              The function will return ANY or ALL of the following output (the
 *              caller should set to NULL, output that is not needed).
 *              1. Leaf components in the tree
 *              2. Any composites in the tree
 *              3. Whether the incoming object is a composite.
 *
 * INPUT/OUTPUT:
 *
 * O: EFmsg           Return code
 * I: input_obj       Id of incoming object. Can be a composite or a 
 *                    non-composite. If non-composite, simply returned
 *                    in the output array.
 * O: num_comps       Numer of lowest level (leaf) components in the input
 *                    object (if non-composite, 1)
 *                    (Can be NULL)
 * O: comps           Array of leaf components. Malloced in here. Even if the
 *                    input is not a composite, an array of size 1 is malloced 
 *                    to return the input id back.CALLER MUST FREE THIS MEMORY.
 *                    (Can be NULL)
 * O: is_composite    Whethe the incoming object is a composite
 *                    (Can be NULL)
 * O: num_composites  The number of composites in the tree of the incoming
 *                    object. If the input object was not a composite, it is
 *                    zero.
 *                    (Can be NULL)
 * O: composites      Array of composites in the tree of the incoming
 *                    object. If the input object was not a composite, it is
 *                    not malloced. CALLER MUST FREE THIS MEMORY.
 *                    (Can be NULL)
 *
 * WHEN CALLING THE FUNCTION, SET
 * ------------------------------
 * *num_comps = 0
 * *num_composites = 0
 * comps = NULL
 * composites = NULL
 *
 *
 * HISTORY:
 *
 * 01/03/94 :  NP  : Creation.
 */ 

void EFget_lowest_components(EFmsg, input_obj, num_comps, comps, is_composite,
                              num_composites, composites)
IGRlong *EFmsg;
struct GRid *input_obj;
IGRint *num_comps, *num_composites;
GRobjid **comps, **composites;
IGRboolean *is_composite;
{
  IGRlong sts, msg_loc;
  IGRint i, loc_num_comps=0;
  OMuint count;
  OM_S_CHANSELECT to_components;
  OM_S_OBJECT_LINKAGE *comps_list;
  struct GRid  loc_grid;
  GRspacenum os;
  IGRboolean loc_is_composite;

  sts    = OM_S_SUCCESS;
  *EFmsg = EMS_S_Success;

  comps_list = NULL;

  /* When recursive calls are made, the variable "loc_is_composite" is passed,
   * so that what is returned back to the caller is the determination made in
   * the FIRST call to this function which is important, since the individual
   * components may not be composites and if "is_composites" is passed in, it 
   * may get overwritten during the recursion.
   */
  if (is_composite)
     *is_composite = FALSE; /* assume */

  os  = input_obj->osnum;

  
  sts = EMmake_chanselect(GRcmpowner_to_components, &to_components);
  EMerr_hndlr (!(1&sts), *EFmsg, sts, wrapup);


  if (!EFisAncestryValid(&msg_loc, input_obj->objid, input_obj->osnum,
                             OPP_EMScomposite_class_id, TRUE))
  {
    if (is_composite)
       *is_composite = FALSE;
    
    if (num_comps)
          (*num_comps)++;

    if (comps && num_comps)
    {
       if (*comps)
         *comps = (GRobjid *)om$realloc(
                      ptr  = (IGRchar *)(*comps),
                      size = (*num_comps) * sizeof (GRobjid));
       else
         *comps = (GRobjid *)om$malloc(size= sizeof(GRobjid));
   
       EMerr_hndlr(!(*comps),*EFmsg, EMS_E_NoDynamicMemory, wrapup);
   
       (*comps)[(*num_comps)-1] = input_obj->objid;
    }
  }
  else
  {
    if (is_composite)
       *is_composite = TRUE;


    /* get the number of components */
    sts = om$get_channel_count (osnum = os, 
                                objid = input_obj->objid,
                                p_chanselect = &to_components,
                                count = (OMuint *)&loc_num_comps);
    EMerr_hndlr(!(1&sts),*EFmsg, EMS_E_OMerror, wrapup);

    comps_list = (OM_S_OBJECT_LINKAGE *) alloca (loc_num_comps *
                                   sizeof(OM_S_OBJECT_LINKAGE)) ;
    sts = om$get_channel_objects (osnum=os, objid=input_obj->objid,
                                  p_chanselect = &to_components,
                                  list=comps_list, size=loc_num_comps,
                                  count = &count);
    EMerr_hndlr(!(1&sts)||(count!=loc_num_comps),*EFmsg, EMS_E_OMerror, wrapup);


    for (i=0; i<loc_num_comps; i++)
    {
         /* make a recursive call to this function */

         loc_grid.objid = comps_list[i].S_objid; 
         loc_grid.osnum = os;

         (void) EFget_lowest_components(&msg_loc, &loc_grid, num_comps, comps,
                                         &loc_is_composite, num_composites,
                                         composites);
         EMerr_hndlr(!(1&msg_loc),*EFmsg, msg_loc, wrapup);
    }

    if (num_composites)
       (*num_composites)++;

    if (composites && num_composites)
    {
       if (*composites)
         *composites = (GRobjid *)om$realloc(
                      ptr  = (IGRchar *)(*composites),
                      size = (*num_composites) * sizeof (GRobjid));
       else
         *composites = (GRobjid *)om$malloc(size= sizeof(GRobjid));

       EMerr_hndlr(!(*composites),*EFmsg, EMS_E_NoDynamicMemory, wrapup);

       (*composites)[(*num_composites)-1] = input_obj->objid;

    }

  }

  wrapup:

  if (comps_list)
    stackfree (comps_list);

  EMWRAPUP (*EFmsg, sts, "In EFget_lowest_components");
}  


