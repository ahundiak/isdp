/* ###################   APOGEE COMPILED   ################## */
/* 
 DESCRIPTION
  
 This method takes a list of surface object ids (along with other
 necessary information about each of the surfaces) and merges all of them
 together, forming a single surface. The order in which this 
 merge takes place is strictly in the order in which they are present in 
 the input surfaces array. That is, no attempt is made to try permutations
 and  combinations among the surfaces to find continuity. If continuity 
 conditions are not met between successive surfaces, the method aborts and an
 error status is returned. No merged surface object gets created in
 this case. If all went well a merged surface object is output.

 RETURN VALUES

 *msg                    completion code
                         - MSSUCC if successful
                         - MANOMEMORY if no dynamic memory available
                         - MSINARG if math failed, note that this probably
                           indicates that the input surfaces were not 
                           connected or were not compatible
                         - MSFAIL (severe) if failure
                           due to allocation problems

 NOTES

 The merged surface is reparameterized based on the length of it's polygon.
   
 ALGORITHM
  
 Get all the surfaces and merge them together.

 HISTORY

 ss     09/30/86 : Design date.
 rlw    ??/??/?? : Modified to reparameterize surface after merge.
 rlw    05/16/87 : Fix typo on an EMallocsf().  This was causing
                   the routine to allocate insufficent memory at times
 rlw    05/19/87 : Reworked this method to be more efficent.  Also
                   changed it's name and the way the input is given as
                   well as breaking most of the functionality out into
                   a function.
 rlw    10/09/87 : Remove reparameterization logic and changed to use
                   another math merge routine
 rlw	02/12/88 : Added knot normalization logic
 pp     06/27/89 : Mallocing more memory during merging surfaces.See
                   comments below.
 RC     12/21/89 : Replaced BSmergesfnn() by BSmergsfnna(). Now math
                   will allocate memory for the merged surface. Also,
                   removed the code to allocate the merged surface.
 NP	08/18/92   Moved the static declaration of "EMmerge_the_surfaces"
		   to global file scope for ANSI compliance.

 */

class implementation EMSgenbs;

#include "EMS.h"
#define DEBUG 0
#if DEBUG
#include <stdio.h>
#endif
# ifndef OM_D_MINIMUM
# include "OMminimum.h"     /* for gocmacros.h  */
# endif
# ifndef igrtypedef_include
# include "igrtypedef.h"     /* for gocmacros.h  */
# endif
# ifndef gocmacros_include
# include "gocmacros.h"     /* GRgetabsg macro  */
# endif
#include "OMerrordef.h"
#include "msdef.h"
#include "madef.h"
#include "bserr.h"
#include "emsdef.h"

static IGRboolean  EFmerge_the_surfaces();

method EMmerge_surfaces(
  IGRlong       number_of_surfaces;
  struct        GRlc_info surfaces[];
  struct        GRvg_construct *construct_list;
  IGRlong       *msg)
{
 extern  IGRboolean  BSfreesf();
 IGRboolean     status;
 IGRlong        msg_loc, sts;
 struct         IGRbsp_surface *merged_surface;
/*
 * Initialize
 */
 *msg = MSSUCC;
 merged_surface = NULL;
/*
 * Merge the surfaces
 */
 status = EFmerge_the_surfaces(
   number_of_surfaces,
   surfaces,
   my_id,
   &merged_surface,
   msg);
  if (!status) goto wrapup;
/*
 * Fill the instance data
 */
 construct_list->geometry = (IGRchar *) merged_surface;
 sts = om$send(mode = OM_e_wrt_object,
               msg = message GRgraphics.GRconstruct(
                construct_list),
               senderid = my_id,
               targetid = my_id);
 construct_list->geometry = NULL;
  if (!(1 & sts)) goto wrapup;
/*
 * Error logic
 */
wrapup:
 if (merged_surface) status = BSfreesf(&msg_loc, merged_surface);
 if (1 & *msg)
  return(OM_S_SUCCESS);
 else
  {
   sts = om$send(mode = OM_e_wrt_object,
                 msg = message Root.delete(1),
                 senderid = my_id,
                 targetid = my_id);
   return(OM_E_ABORT);
  }
}

/* 

 Static function to merge together several surfaces.

 ss     09/30/86 : Design date.
 rlw    ??/??/?? : Modified to reparameterize surface after merge.
 rlw    05/16/87 : Fix typo on an EMallocsf().  This was causing
                   the routine to allocate insufficent memory at times
 rlw    05/19/87 : Moved all of the logic to this function.
 rlw    10/09/87 : Remove reparameterization logic and changed to use
                   another math merge routine
  
 */

static IGRboolean EFmerge_the_surfaces(
  number_of_surfaces,
  surfaces,
  my_stupid_id,
  the_merged_surface,
  msg)

IGRlong         number_of_surfaces;
struct          GRlc_info surfaces[];
OM_S_OBJID      my_stupid_id;
struct          IGRbsp_surface **the_merged_surface;
IGRlong         *msg;

{
  extern  void  BSallocsf();
  extern  void  BSmergsfnna();
  IGRchar       *generic_pointer;
  IGRshort      order;
  IGRboolean    status, rational;
  extern IGRboolean  BSsf_copy();
  extern IGRboolean  BSfreesf();
  IGRlong   msg_loc, i, sts, num_poles;
  struct IGRbsp_surface *tmp_surface, *merged_surface, *new_surface;
  struct         IGRbsp_surface *surface;

/*
 * Initialize
 */

#if DEBUG
 fprintf(stderr, "\nInside merge surface function there are %d surfaces",
         number_of_surfaces);
#endif

 *msg = MSSUCC;
 *the_merged_surface = NULL;
 tmp_surface = NULL;
 merged_surface = NULL;
 new_surface = NULL;

/*
 * For each surface get the geometry and merge it in with the rest
 */

 for (i = 0; i < number_of_surfaces; i++)
  {

/*
 * Get the abstract buffer of the surface
 */

   sts = om$send(msg = message EMSgenbs.GRgenabsg(
                  msg,
                  &surfaces[i].module_info.md_env.matrix_type,
                  surfaces[i].module_info.md_env.matrix,
                  &generic_pointer),
                 senderid = my_stupid_id,
                 targetid = surfaces[i].located_obj.objid,
                 targetos = surfaces[i].located_obj.osnum);
    if (! (1 & sts))
     {
      *msg = MSFAIL;
      goto wrapup;
     }
   surface = (struct  IGRbsp_surface *) generic_pointer;

   BSallocsf(
     surface->u_order,
     surface->v_order,
     surface->u_num_poles,
     surface->v_num_poles,
     surface->rational,
     0,                                         /* No boundaries */
     &tmp_surface,
     &msg_loc);
    if (msg_loc != BSSUCC)
     {
      *msg = MANOMEMORY;
      goto wrapup;
     }

   status = BSsf_copy(
     &msg_loc,
     surface, 
     tmp_surface);
    if (!status)
     {
      *msg = MSFAIL;
      goto wrapup;
     }
/*
 * Merge it with the rest of them
 */
   if (i == 0)
    {
     merged_surface = tmp_surface;
     tmp_surface = NULL;
    }
   else
    {
     BSmergsfnna (merged_surface, tmp_surface, &new_surface, &msg_loc);
     if (msg_loc != BSSUCC)
      {
        if (msg_loc == BSNOTCOMP)
         *msg = MSINARG;
        else
         *msg = MSFAIL;
        goto wrapup;
      }

     status = BSfreesf(
       &msg_loc, 
       tmp_surface);
     tmp_surface = NULL;

     status = BSfreesf(
       &msg_loc,
       merged_surface);
     merged_surface = new_surface;

     new_surface = NULL;

    } /* ELSE FOR if (i == 0) */
  } /* for (i = 0; i < object_count; i++) */

/*
 * Return the results
 */

 merged_surface->num_boundaries = 0;
 *the_merged_surface = merged_surface;
 merged_surface = NULL;

/*
 * Normalize the surfaces knot vector
 */

 BSnrsfkntvc(*the_merged_surface);

/*
 * Eof
 */

wrapup:
 if (tmp_surface)    status = BSfreesf (&msg_loc, tmp_surface);
 if (merged_surface) status = BSfreesf (&msg_loc, merged_surface);
 if (new_surface)    status = BSfreesf (&msg_loc, new_surface);
 if (! (1 & *msg))
  return(FALSE);
 else
  return(TRUE);
}

end implementation EMSgenbs;
