/* ###################   APOGEE COMPILED   ################## */
class implementation EMShelper;


# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"     /* EMS error codes  */
# endif


method EMcreator_undoing( IGRlong *EMmsg; 
                          GRobjid *creator_id )
{
  *EMmsg = EMS_S_Success;
  
  return( OM_S_SUCCESS );
}

end implementation EMShelper;
