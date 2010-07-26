/* #######################    APOGEE COMPILED   ######################## */
/*\
Description
   These functions are used to support the macros defined for
   locating/adding/removing objects from the symbol libraries.

History
   Gray Winn   10/20/86    Creation Date
*/

#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "grerr.h"
#include "grsymdef.h"
#include "msdef.h"
#include "grsymmacros.h"
#include "OMindex.h"

/*
 *  Locate symbols definition in all attached symbol libraries.
 *  Returns a symbol based on the attachment ordering and time stamp
 * ordering.
 */

IGRint GRsd_locate_in_all_sl (msg, sd_name, sl_env, sd_id)
IGRlong           *msg;
IGRchar           *sd_name;
struct GRmd_env   *sl_env;
struct GRid       *sd_id;
{
IGRlong        om_msg;
IGRlong        ret_msg;
GRspacenum     located_OS;       /* OS number for the located symbol */
OM_S_OBJARRAY  object_array;     /* Structure used by locate         */
GRspacenum     os_array[MAX_SYMBOL_LIBS];
IGRint         num_os;

   *msg = MSSUCC;

   /*
    *  Generate the array of symbol libraries to be searched.
    */

   om_msg = gr$symget_sl_OS_array ( msg = &ret_msg,
            os_array = os_array, num_os_array = &num_os);

   if (om_msg & ret_msg & 1)
   {
      /*
       *  Search for the symbol in the attached symbol libraries.
       *  Currently this is just the active symbol library and
       *  thus it can return only one symbol.
       */

      object_array.size = sizeof (OM_S_OBJARRAY);
      object_array.tree_type = KEY_STRING;

      om_msg = gr$symsd_locate ( msg = &ret_msg, num_OS = num_os,
               p_OS = os_array, sd_name = sd_name,
               p_OBJARRAY = &object_array, p_loc_OS = &located_OS);

      if ((om_msg & 1) && (object_array.count))
      {
         sd_id->objid = object_array.array[0];
         sd_id->osnum = located_OS;

         /* 
          *  Get the symbol environment given an OS number from the
          *  locate.
          */

         om_msg = gr$symget_sl_env_from_OS (msg = &ret_msg,
                  sl_osnum = &located_OS, sl_env = sl_env);
         
         if (!(om_msg & ret_msg & 1))
         {
            *msg = MSFAIL;
         }
      }else
      {
         *msg = MSFAIL;
      }
   }else
   {
      *msg = GR_I_NOSL;
   }
   return(om_msg);
}   

/**************************************************************/
/*
 *   This function will return a symbol from the active symbol 
 *   library.
 */
IGRint GRsd_locate_in_asl (msg, sd_name, sl_env, sd_id)
IGRlong           *msg;
IGRchar           *sd_name;
struct GRmd_env   *sl_env;
struct GRid       *sd_id;
{
IGRlong        om_msg;
IGRlong        ret_msg;
GRspacenum     located_OS;       /* OS number for the located symbol */
OM_S_OBJARRAY  object_array;     /* Structure used by locate         */

   *msg = MSSUCC;

   /*
    *  Get the active symbol library information.
    */

   om_msg = gr$symget_asl_env ( msg = &ret_msg, asl_env = sl_env);

   if (om_msg & ret_msg & 1)
   {
      /*
       *  Search for the symbol in the active symbol library.
       *  Note that the symbol name must be unique in the active 
       *  symbol library.
       */

      object_array.size = sizeof (OM_S_OBJARRAY);
      object_array.tree_type = KEY_STRING;


      om_msg = gr$symsd_locate ( msg = &ret_msg, num_OS = 1,
               p_OS = &sl_env->md_id.osnum, sd_name = sd_name,
               p_OBJARRAY = &object_array, p_loc_OS = &located_OS);

      if ((om_msg & 1) && (object_array.count))
      {
         sd_id->objid = object_array.array[0];
         sd_id->osnum = located_OS;
      }else
      {
         *msg = MSFAIL;
      }
   }else
   {
      *msg = GR_I_NOSL;
   }
   return(om_msg);
}   

/****************************************************************/
IGRint GRsd_locate ( msg, num_OS, p_OS, sd_name, p_OBJARRAY,
                      p_loc_OS)

IGRlong          *msg;  
IGRint           num_OS;
GRspacenum       *p_OS;
IGRchar          *sd_name;
OM_S_OBJARRAY    *p_OBJARRAY;
GRspacenum       *p_loc_OS;
{
IGRlong  om_msg;

   om_msg = GRbtreelocate ( msg, num_OS, p_OS, GR_SD_BTREE_NAME,
            sd_name, p_OBJARRAY, p_loc_OS);

   return (om_msg & 1);
}

/****************************************************************/
IGRint GRsd_add ( msg, sl_osnum, sd_name, sd_objid)
IGRlong     *msg;
GRspacenum  sl_osnum;
IGRchar     *sd_name;
GRobjid     sd_objid;
{
IGRlong  om_msg;

   om_msg = GRbtreeadd ( msg, 1, &sl_osnum, GR_SD_BTREE_NAME, sd_name,
            &sd_objid);

   return (om_msg & 1);
}

/****************************************************************/
IGRint GRsd_remove ( msg, sl_osnum, sd_name, sd_objid)
IGRlong     *msg;
GRspacenum  sl_osnum;
IGRchar     *sd_name;
GRobjid     sd_objid;
{
IGRlong  om_msg;

   om_msg = GRbtreeremove ( msg, 1, &sl_osnum, GR_SD_BTREE_NAME, sd_name,
            &sd_objid);

   return (om_msg & 1);
}

