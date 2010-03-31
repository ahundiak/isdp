/* ###################   APOGEE COMPILED   ################## */
/* 
DESCRIPTION
===========
			
 	This function does the following:

	 1) For a freshly constructed surface it puts its range in 
             the rtree.
         2) For an exsisting surface it updates the rtree to reflect 
            the new range.

NOTES
=====

ARGUMENTS
=========
	
  VARIABLE		    MODE    DESCRIPTION
  --------                  ----    -----------

  old_range          	    Input   Old range to be updated, can be NULL
				     for a freshly constructed surface.
				     Type (GRrange *)
					
  new_range          	    Input   New range to be updated (for an exsis-
				     ting surface) OR new range to be ent-
				     ered in the rtree ( for a new surf).
				     Type (GRrange *)
					
  my_id                     Input  Object id of the surface.
			            Type (GRobjid *).

  me_GRgraphics_properties  Input  GRgraphics properties of the object (I
				    do not know why IGE needs this becau-
				    se I know they do not use this).
				    Type (short *).

  grmd_env                  Input  Module environment of the object.
				    Type (struct GRmdenv *).

  post_info                 Input  Post information, contains construct
			            flag as a field. Set it to TRUE for
				    new surfaces and FALSE for exsisting
				    surfaces.

RETURN VALUE
============

TRUE : If success.
FASE : If not a success.

HISTORY
=======
	
SAM		Aug 11, 1988		Creation.

*/

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "godef.h"
#include "gr.h"
#include "igrdp.h"
#include "go.h"
#include "EMSmsgdef.h"
#include "OMerrordef.h"
#include "EMS.h"


IGRboolean EFmodify_surface_rtree_range(old_range, new_range, my_id,
					me_GRgraphics_properties,
					grmd_env, post_info)
 GRrange old_range;
 GRrange new_range;
 GRobjid *my_id;
 IGRshort *me_GRgraphics_properties;
 struct GRmd_env *grmd_env;
 struct GRpost_info *post_info;

 {
  IGRlong OM_stat, mthd_stat;

  OM_stat = OM_S_SUCCESS;
  mthd_stat = EMS_S_Success;

  if(post_info->construct_flag)
  {
   extern IGRlong GRowneradd();

   OM_stat = GRowneradd(&mthd_stat, grmd_env, my_id, 
			&(grmd_env->md_id.osnum),new_range);
   if(!(1&OM_stat&mthd_stat)) return(FALSE);
  }
  else
  {
   extern IGRlong GRupdaterng();

   OM_stat = GRupdaterng(&mthd_stat, grmd_env, post_info, my_id,
                      	 me_GRgraphics_properties, /* They dont use it */
			 old_range, new_range);
   if(!(1&OM_stat&mthd_stat)) return(FALSE);
  }
  return(TRUE);
 }

