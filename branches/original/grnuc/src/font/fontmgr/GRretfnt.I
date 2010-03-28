/* #######################    APOGEE COMPILED   ######################## */


/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME   GRretrieve_font

     Abstract:    This module will download a font given the logical name
                of a font and a font name to use in the local list. If
                the specified font exists and is not already in the local
                list, it will be downloaded and an entry will be made in
                the local list for this font.  The font name to be used in
                the local list must be unique to the local list.
-----
%SC%

-----
%EN%
 
     ON ENTRY:

          NAME           DATA TYPE                  DESCRIPTION
    ----------------  ----------------  ---------------------------------------
    *fontfile         IGRuchar  logical name of font to down load
    *local_font_name  IGRuchar  local font name for the downloaded font
    font_flags        IGRshort          flag identifying type of font
    *fontmgr          struct GRid       font manager object
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   ---------------------------------------------
     *message       IGRlong         Completion code
                                    - MSSUCC           if successful
                                    - MSFAIL (severe)  if failure
                                    - GR_E_MxNoFtLdd   if local list is full
                                    - GR_E_FtNotFnd    font not found
                                    - GR_E_FtNmeLdd    font name isn't unique
                                    - GR_E_FtLdd       font already downloaded
     *fontmgr         struct GRid  font manager object id will be returned if
                                   it was set to NULL_OBJID on entry
     *position        IGRshort     position (index) in the local font list
                                   into which the font was downloaded

     VALUE (IGRboolean) = TRUE            - if successful
                          FALSE           - if failure
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:    

         strlen:                 - A standard C function to find the
                                   length of a character string.

     Methods:

         GRfm.GRphy_search:      - This message will return the local
                                   list name of the font if it has
                                   already been down loaded.

         GRfm.GRvirt_search:     - This message will return the position
                                   of the font in the local list if it
                                   exists in the list.

         GRfm.GRmake_entry:      - This message will down load a specified
                                   font if it exists.
-----
%RL%

     RELATIONS REFERENCED:

-----
%UI%

     USER INTERFACE DESCRIPTION:

-----
%NB%

     NOTES:  if the requested font has alredy been downloaded, its position
             in the local font list will be returned
-----
%CH%
     CHANGE HISTORY:
        
        DEK  11/12/87 : Design date.
        DEK  11/12/87 : Creation date.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

class implementation COretfnt;

#include  "grimport.h"
#include  "grmessage.h"
#include  "OMerrordef.h"
#include  "exmacros.h"
#include  "msdef.h"
#include  "codef.h"
#include  "fontdef.h"

from GRfm   import GRphy_search, GRvirt_search, GRmake_entry;

/*
 *#define DEBUG
 */

IGRint GRretrieve_font(msg,fontfile,local_font_name,font_flags,fontmgr,position)

IGRlong           *msg;             /* return message                        */
IGRuchar  *fontfile;        /* logical name of font to down load     */
IGRuchar  *local_font_name; /* local name for the downloaded font    */
IGRshort          font_flags;       /* flag identifying what type of font    */
struct GRid       *fontmgr;         /* (optional) font manager osnum and id; */
                                    /* pointer may be set to NULL if not     */
                                    /* known; if it is specified and objid is*/
                                    /* set to NULL_OBJID, it will be returned*/
IGRshort          *position;        /* position to put font in local list    */

{
    struct GRid      fontmgr_obj;           /* objid of font manager  */
    IGRlong          OMmsg;                 /* OM return code         */
    IGRlong          temp_msg;
    IGRint           num_chars;
    IGRint           status;                /* return status          */
    IGRshort         vfont_num;             /* virtual font number    */
    GRspacenum       mod_osnum;             /* module's osnum         */
    OM_S_OBJID       mod_id;                /* module's objid         */
    IGRuchar tmp_font_name[FONT_NAME];

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;
    status = 1;

    /*
     *  call routine to determine if the input file is a font
     */

    num_chars = strlen((char *)fontfile);

    if (GRisitfnt(&temp_msg,fontfile,&num_chars,NULL))
    {
       /*
        *  Find the object id of the font manager using its named object name.
        */

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

       /*
        *  Call GRphy_search to see if the specified font is
        *  already in the local list.
        */

       OMmsg = om$send(mode = OM_e_wrt_object,
                       msg =  message GRfm.GRphy_search(&temp_msg,
                              fontfile,tmp_font_name),
                       senderid = NULL_OBJID,
                       targetid = fontmgr_obj.objid,
                       targetos = fontmgr_obj.osnum);

       if ((temp_msg != MSSUCC) && (!COERROR(OMmsg)))
       {
          /*
           *  Call GRvirt_search to insure the local list name
           *  is unique.
           */

          vfont_num = -1;

          OMmsg = om$send(mode = OM_e_wrt_object,
                          msg = message GRfm.GRvirt_search(&temp_msg,
                                local_font_name,&vfont_num),
                          senderid = NULL_OBJID,
                          targetid = fontmgr_obj.objid,
                          targetos = fontmgr_obj.osnum);

          if ((temp_msg != MSSUCC) && (!COERROR(OMmsg)))
          {
             /*
              *  Call GRmake_entry to down load the font.
              */

             *position = -1;

             OMmsg = om$send(mode = OM_e_wrt_object, 
                             msg = message GRfm.GRmake_entry(&temp_msg,
                                   fontfile,local_font_name,font_flags,
                                   position),
                             senderid = NULL_OBJID,
                             targetid = fontmgr_obj.objid,
                             targetos = fontmgr_obj.osnum);

             if (COERROR(OMmsg))
             {
#ifdef DEBUG
                printf("GRretfnti.I err: GRfm.GRmake_entry");
#endif
                status = 0;
             }
             else if (! (1 & temp_msg) ||
                      (temp_msg < 0))
             {
#ifdef DEBUG
                printf("GRretfnti.I err: GRfm.GRmake_entry");
#endif
               if (temp_msg < 0)
                   *msg = MSFAIL;
               else
                   *msg = temp_msg;
               status = 0;
             }
          }
          else
          {
             if (temp_msg == MSSUCC)
             {
                *msg = GR_E_FtNmeLdd;
             }
             else
             {
#ifdef DEBUG
                printf("GRretfnti.I err: GRfm.GRvirt_search");
#endif  
             }
             status= 0;
          }
       }
       else
       {
          if (temp_msg == MSSUCC)
          {
             /*
              * The specified font has already been retrieved; find the font's
              * index to be returned
              */

             vfont_num = -1;

             OMmsg = om$send(mode = OM_e_wrt_object,
                             msg = message GRfm.GRvirt_search(&temp_msg,
                                                              tmp_font_name,
                                                              &vfont_num),
                             senderid = NULL_OBJID,
                             targetid = fontmgr_obj.objid,
                             targetos = fontmgr_obj.osnum);

             if (OMmsg & temp_msg & 1)
             {
                *position = vfont_num;
                *msg = GR_E_FtLdd;
             }
             else
             {
                *msg = MSFAIL;
             }
          }
          else
          {
             *msg = MSFAIL;
#ifdef DEBUG
             printf("GRretfnti.I err: GRfm.GRphy_search");
#endif
          }
          status = 0;
       }
    }
    else
    {
       *msg = GR_E_FtNotFnd;
       status = 0;
    }
    return(status);
}

end implementation COretfnt;
