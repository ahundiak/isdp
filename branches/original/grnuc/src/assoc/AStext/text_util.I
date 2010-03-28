class implementation ASsrctext;
#include "OMmacros.h"
#include "fontdef.h"
#include "font.h"
#include "fontmacros.h"
#include "exmacros.h"
#define AS_DEBUG

extern struct GRid ASfont_mgr;

from GRfm import GRphy_search,GRvirt_search,GRfm_retdata ;

ASfind_font_info(font,font_info)

IGRshort font;
struct vfont_entry *font_info;
/*.ASfind_font_info*/
{
 GRspacenum cur_mod_osnum;
 IGRint rc;
 IGRlong temp_msg;
        /*
         *  find the current module's object space number
         */

        ex$get_cur_mod(osnum = &cur_mod_osnum);

        /*
         *  get the objid of the font manager using its named object
         */

	if(ASfont_mgr.osnum != cur_mod_osnum)
          {
	   /*| call get_objif for FONTMGR */
           ex$get_objid_from_NOD(NODname = FONTMGR_NOD,
                              objname = FONTMGR_NO_NAME,
                              pobjid = &ASfont_mgr.objid,
                              mod_osnum = cur_mod_osnum);
	    ASfont_mgr.osnum = cur_mod_osnum;
          }
	else
          {
	   /*|DOES NOT call get_objif for FONTMGR */
	  }

        /*
         * get specified font information
         */

        rc = om$send(mode = OM_e_wrt_object,
                     msg = message GRfm.GRfm_retdata
                               (&temp_msg,&font,
                                font_info),
                     senderid = NULL_OBJID,
                     targetid = ASfont_mgr.objid,
                     targetos = ASfont_mgr.osnum);

        if (!(rc&1))
        {
           printf("find_fon_info err: GRfm.GRfm_retdata rc = %d\n",rc);
           om$report_error(sts = rc);
           return rc;
        }
        else if (temp_msg != MSSUCC)
        {
           printf("find_font_info err: GRfm_retdata temp_msg = %x\n",temp_msg);
	   return(OM_S_SUCCESS);
        }
    return(OM_S_SUCCESS);
   
}

end implementation ASsrctext;
