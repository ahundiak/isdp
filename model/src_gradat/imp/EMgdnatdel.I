/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgradata;

#include "EMS.h"
# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"     /* EMS error codes  */
# endif

# ifndef emserr_include
# include "emserr.h" 
# endif

# ifndef EMStypedef_include
# include "EMStypedef.h"    /* EMSmsgReport     */
# endif

# ifndef EMSlogic_include
# include "EMSlogic.h"      /* EMSmsgReport     */
# endif

# ifndef EMScmacros_include
# include "EMScmacros.h"    /* EMSmsgReport     */
# endif

# ifndef EMSfrtdef_include
# include "EMSfrtdef.h"     /* EMFRT_UPTODATE   */
# endif

method EMdelete_nat_gradata (IGRlong *EMmsg)
{

  IGRlong               OM_stat;
  
  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  /*
   * if I am a natural graphic data object, delete myself.
   * The definition of natural property is that I am connected
   * to a surface but not to a loop.
   */

  if (!(me->props & EMGD_NONNATURAL))
    OM_stat = om$send ( mode = OM_e_wrt_message,
                        msg = message Root.delete(1),
                        targetid = my_id);
    
wrapup:

  EMWRAPUP (*EMmsg, OM_stat, "In EMSgradata.EMdelete_nat_gradata");
  return (OM_stat);

}

end implementation EMSgradata;
