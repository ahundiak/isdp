class implementation ASmodifier;

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "ASmatrix.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "msdef.h"
#include "grerr.h"
#include "madef.h"
#include "graph.h"

#define   AS_DEBUG   1           /* For debug preprocessor                    */

#define MAX_SEG 10
#define NB_POINT 2
#define PARTIAL_SYMBOL 100


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          method ASmod_take_kill                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/*
  take the old_modif and kill this object
*/

method ASmod_take_kill ( struct GRid old_modif; struct GRmd_env *md_env)
 {
  IGRlong   status;
  struct GRid new_modif;

  new_modif.objid = my_id;
  new_modif.osnum = OM_Gw_current_OS;
  status = AStake_and_kill_mod(old_modif,new_modif,me->typ_mod,me->par_mod,
			       &me->nmodif,md_env);
  return(status);
 }
  
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method ASmod_g_modif                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*
  Give the instances of the current modifier
*/

method ASmod_g_modif ( IGRint *nmodif; IGRchar typ_mod[]; IGRchar par_mod[] )
  {
  IGRint index;                    /* Index for a loop                        */

  /* Initialize the number of modifications */

  *nmodif = me->nmodif;

  /* Fill the array of typ_mod */

  for(index=0 ; index < *nmodif ; index++)
   {
    typ_mod[index] = me->typ_mod[index];
    par_mod[index] = me->par_mod[index];
   }
  return (OM_S_SUCCESS);
}/* end method ASmod_g_modif */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
end implementation ASmodifier;
