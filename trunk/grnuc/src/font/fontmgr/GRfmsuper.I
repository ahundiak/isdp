/* #######################    APOGEE COMPILED   ######################## */




class implementation GRfm;

#include  "OMerrordef.h"
#include  "exdef.h"
#include  "exmacros.h"
#include  "gr.h"

from GRmodule import GRdel_fnt_tbl;

/***************************** delete *******************************/

method delete (int f_defer_flag)
{
#if debug
   printf ("GR_gra_delete: commencing ...\n");
#endif

   printf("Sorry the font manager cannot be deleted\n");
   return(OM_S_SUCCESS);
 }

/***************************** sleep *******************************/

method global_class.sleep (IGRint sleep_type)
{
   IGRshort i;
   IGRlong  msg;
   struct GRid       mod_id;

   if (sleep_type == EX_REAL_SLEEP)
   {
      for (i = 0; i < me^^GRfm.num_entries; ++i)
      {
         if (me^^GRfm.vfont[i].def_flag == defined)
         {
            om$send(mode = OM_e_wrt_object,
                    msg = message GRfm.GRclean_up(&msg,&i),
                    senderid = my_id,
                    targetid = my_id);
         }
      }

      /*
       * delete display's font table
       */

      mod_id.osnum = OM_Gw_current_OS;
      ex$get_modid (mod_osnum = OM_Gw_current_OS, mod_id = &mod_id.objid);

      om$send(mode = OM_e_wrt_object,
              msg = message GRmodule.GRdel_fnt_tbl(&msg),
              senderid = my_id,
              targetid = mod_id.objid);
   }

   return(OM_S_SUCCESS);
}

end implementation GRfm;
