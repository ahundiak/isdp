/*
ABSTRACT : 

  The class ASmodifier is a subclass of Root . All these classes describe 
  curve modifications witch only affect the display off the curve and
  not the geometry.


CHANGE HISTORY
	
  D.Payannet   02 april 87 : design date
*/
class specification ASmodifier (0:1) of Root;

#include "OMindex.h"
#include "OMlimits.h"
#include "OMminimum.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lc.h"
#include "dpstruct.h"
#include "parametric.h"

#define  NMODIF_MAX  10           /* Maximum number of modifications          */
#define  EXTEND0      0           /* Case of EXTEND the point 0 of the bsp    */
#define  EXTEND1      1           /* Case of EXTEND the point 1 of the bsp    */
#define  PART_DEL     2           /* Case of PARTIAL DELETE modification      */


instance ASmodifier
  {
  IGRint  nmodif;                 /* Number of modifications (partial delete) */
  IGRint  nseg;                   /* Number of segments after the partial del */
  IGRchar typ_mod[NMODIF_MAX];    /* Differents types of modifications        */
  IGRchar par_mod[NMODIF_MAX];    /* Number of parents of the modification    */
};


message ASmod_take_kill
  (
  struct GRid old_modif;          /* IN    Identifier of the old modifier     */
  struct GRmd_env *md_env        /* IN    Information about the graphic env. */
  );

/*
  DESCRIPTION

  Get all the children of the old modifier, connect them on the new modifier
  (my_id) and disconnect them from the old modifier, Kill the old modifier.

*/

message ASmod_g_modif
  (
  IGRint *nmodif;                  /* OUT     Number of modifications         */
  IGRchar typ_mod[];               /* OUT     Type of modifications           */
  IGRchar par_mod[]                /* OUT     Number of modifications parents */
  );
/*
  DESCRIPTION

  Give the instances of the modifier.

*/
end specification ASmodifier;
