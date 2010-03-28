/* #######################    APOGEE COMPILED   ######################## */
class implementation GRclhdr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "gocmacros.h"

method GRchg_owner_properties (IGRlong *msg; IGRint action; IGRshort *mask)
{
IGRlong om_msg;

   *msg = MSSUCC;
   om_msg = OM_S_SUCCESS;

   if (action == 0)
   {
      me->owner_properties = me->owner_properties &  ~*mask;   /* clear */
   }else if (action == 1)
   {
      me->owner_properties = me->owner_properties | *mask;     /* set   */
   }else if (action == 2)
   {
      me->owner_properties = *mask;                      /* replace     */
   }else
   {
      *msg = MSINARG;
      om_msg = OM_E_ABORT;
   }
   GR_NOTIFY_LISTENERS(msg, &om_msg, GR_ATTR_MODIFIED);
   return(om_msg);
}

method GRget_owner_properties (IGRlong *msg; IGRshort *properties)
{
   *msg = MSSUCC;
   *properties = me->owner_properties;
   return (OM_S_SUCCESS);
}

/*\
Name
   GRget_locate_properties

Description
   This method is used to get the owner's locate properties.

   *msg           IGRlong           completion code 
   *properties    IGRint            The allowable properties:
                                       -  GR_LC_CMP_READ
                                       -  GR_LC_CMP_WRITE
                                       -  GR_LC_CMP_PRM_READ
                                       -  GR_LC_CMP_PRM_WRITE
                                       -  GR_LC_OWN_READ
                                       -  GR_LC_OWN_WRITE
                                       -  GR_LC_OWN_PRM_READ
                                       -  GR_LC_OWN_PRM_WRITE
                                       -  GR_LC_RIGID
                                       -  GR_LC_FLEXIBLE
                                       -  GR_LC_NO_PRM_COMP

Return Values
   MSSUCC   -  if successful.
   MSFAIL   -  if failure.
\*/

method GRget_locate_properties (IGRlong *msg; IGRint *properties)
{
   *msg = MSSUCC;
   *properties = GR_LC_CMP_READ        |
                 GR_LC_CMP_WRITE       |
                 GR_LC_OWN_READ        |
                 GR_LC_OWN_WRITE       |
                 GR_LC_OWN_PRM_READ    |
                 GR_LC_OWN_PRM_WRITE   |
                 GR_LC_RIGID           |
                 GR_LC_NO_PRM_COMP;  

   return (OM_S_SUCCESS);
}

end implementation GRclhdr;
