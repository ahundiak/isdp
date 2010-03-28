/* #######################    APOGEE COMPILED   ######################## */





 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS NAME:              GRfm 
     METHOD NAME:             GRget_font_info
 
     Abstract:

              This routine returns the instance data contained
              in the virtual font entry of the requested font.
-----
%SC%

    VALUE = GRget_font_info(IGRlong *msg, IGRshort *font_num, struct GRid
                            *fontmgr, struct vfont_entry *font_info)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    -----------   ---------------   -----------------------------------
    *font_num     IGRshort          # of which font to get info about
    *fontmgr      struct GRid       font manager object
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                    DESCRIPTION
     ----------     ---------------     --------------------------------
     *msg           IGRlong             completion code
     *fontmgr       struct GRid         font manager object id will be returned
                                        if it was set to NULL_OBJID on entry
     *font_info     struct vfont_entry  font information returned

     VALUE (IGRlong) =    MSSUCC   - if successful
                          MSFAIL   - if failure
-----
%MD%

     MODULES AND METHODS INVOKED:

     modules:

     methods:   GRfm.GRfm_retdata

-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        DEK  12/23/88 : Design date.
        DEK  12/23/88 : Creation date.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
    This routine returns the instance data contained in the virtual 
font entry of the requested font.

----*/
/*EH*/

class implementation GRfm;

#include "grimport.h"
#include "gr.h"
#include "exmacros.h"

IGRint GRget_font_info(msg,font_num,fontmgr,font_info)

IGRlong             *msg;              /* completion code                   */
IGRshort            *font_num;         /* # of which font to get info about */
struct GRid         *fontmgr;          /* font manager object               */
struct vfont_entry  *font_info;        /* font information returned         */

{
   OM_S_OBJID       mod_id;            /* module id                         */
   OMuword          mod_osnum;         /* module os number                  */
   struct GRid      fontmgr_obj;       /* font manager object               */

   *msg = MSSUCC;

   if ((fontmgr == NULL) ||
       (fontmgr->objid == NULL_OBJID))
   {
       if (fontmgr == NULL)
       {
           ex$get_cur_mod(id = &mod_id,
                          osnum = &mod_osnum);
       }
       else
       {
           mod_osnum = fontmgr->osnum;

           ex$get_modid(mod_osnum = fontmgr->osnum,
                        mod_id = &mod_id);
       }

       ex$get_super(mod_id = mod_id,
                    mod_osnum = mod_osnum,
                    super_name = FONTMGR_NO_NAME,
                    create = TRUE,
                    super_class = "GRfm",
                    super_id = &fontmgr_obj.objid,
                    super_osnum = &fontmgr_obj.osnum);

       if (fontmgr)
          fontmgr->objid = fontmgr_obj.objid;
   }
   else
   {
      fontmgr_obj.objid = fontmgr->objid;
      fontmgr_obj.osnum = fontmgr->osnum;
   }

   om$send(mode = OM_e_wrt_object,
           msg = message GRfm.GRfm_retdata(msg,font_num,font_info),
           senderid = NULL_OBJID,
           targetid = fontmgr_obj.objid,
           targetos = fontmgr_obj.osnum);

   return(TRUE);
}
end implementation GRfm;
