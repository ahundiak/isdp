/* #######################    APOGEE COMPILED   ######################## */

command_string  GRMSvTxTAsF,1,GRSvTxTAsF
class           COsvtxasfl
super_class     CEO_LOCATE
start_state     start
product_name    "$SOURCE"
options         "SITC"

specification

#ifdef SUNOS 
#include "sunlimits.h"
#endif

#include <limits.h>

/******************************************************************************

Description:

    This command writes the text from an existing text element to an
ascii file.


Abstract class:      No.

Override methods:    None.

Messages:


History:  Bill Cecil     08/24/89  Design and Implementation

Algorithm:

Notes:

******************************************************************************/

instance
{
    struct IGRestx      text_attr;
    IGRuchar            *text_string;
    IGRchar             file_name[DI_PATH_MAX];
}

implementation

#include "coimport.h"
%safe
#include <sys/types.h>
#include <sys/stat.h>
%endsafe
#include <errno.h>
#include <fcntl.h>
#include "igr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grmessage.h"
#include "exmacros.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "exdef.h"
#include "execmsg.h"
#include "dp.h"
#include "cotxmacros.h"
#include "gotextdef.h"
#include "fontdef.h"
#include "font.h"
#include "fontmacros.h"

from GRtext     import GRgettxattr;

#define CREATE_MODE  0644  /* RW for owner, R otherwise */


state_table

#include <sys/errno.h>
#include "execmsg.h"
#include "grmessage.h"

state *

on EX_RESTART
   state start

state start 
      message_key        GRC_M_SvTxTAsF
      prompt_key         GR_P_IdEle
      locate_mask        "GRm_DATA | GRm_TEXT_VALUE | GRm_OBJID"
      accept_key         GR_P_AccFlNm
      relocate_key       GR_E_EleNotFnd
      locate_eligible    "+GRtext"
      locate_owner       "LC_RIGID_COMP | LC_FLEX_COMP | LC_REF_OBJECTS"
      unhilight_mode     GRhe
      filter             locate

on EX_STRING          do get_text(me->mytype)
                         on RETURN_CODE = "MSFAIL"
                            do status_key  GR_E_ErrEncCmdRst
                            state .

                         on RETURN_CODE = "MSINARG"
                            do status_key  GR_E_EmptTxElFlNotCrt
                            state .

                         on ELSE
                            do check_file()
                               on RETURN_CODE = "ENOTDIR"
                                  do status_key EX_S_NotDir
                                  state get_filename

                               on RETURN_CODE = "EACCES"
                                  do status_key EX_S_Access
                                  state get_filename

                               on RETURN_CODE = "MSFAIL"
                                  state overwrite_file

                               on ELSE
                                  do write_text_to_file()
                                     on RETURN_CODE = "MSFAIL"
                                        do status_key EX_S_NotDir
                                        state get_filename

                                     on RETURN_CODE = "MSINARG"
                                        do status_key GR_E_ErrFlCrt
                                        state get_filename

                                     on ELSE
                                        state .
                                  state .
                            state .
   state .

on EX_OBJID     do get_text(me->mytype)
                   on RETURN_CODE = "MSFAIL"
                      do status_key  GR_E_ErrEncCmdRst
                      state .

                   on RETURN_CODE = "MSINARG"
                      do status_key  GR_E_EmptTxElFlNotCrt
                      state .

   state get_filename

on EX_BACK_UP
   state .


state overwrite_file
      prompt_key         GR_P_FlExOv
      filter             get_event

on EX_STRING = "y" or EX_STRING = "Y"
   do write_text_to_file()
      on RETURN_CODE = "MSFAIL"
         do status_key EX_S_NotDir
         state get_filename

      on RETURN_CODE = "MSINARG"
         do status_key GR_E_ErrFlCrt
         state get_filename

      on ELSE
         state start
   state get_filename

on ELSE
   state get_filename


state get_filename
      prompt_key         GR_P_EntFlNme
      filter             get_event

on EX_STRING          do check_file()
                         on RETURN_CODE = "ENOTDIR"
                            do status_key EX_S_NotDir
                            state get_filename

                         on RETURN_CODE = "EACCES"
                            do status_key EX_S_Access
                            state get_filename

                         on RETURN_CODE = "MSFAIL"
                            state overwrite_file

                         on ELSE
                            do write_text_to_file()
                               on RETURN_CODE = "MSFAIL"
                                  do status_key EX_S_NotDir
                                  state .

                               on RETURN_CODE = "MSINARG"
                                  do status_key GR_E_ErrFlCrt
                                  state .

                               on ELSE
                                  state start
                            state start
   state start

on EX_BACK_UP
   state start


action init
{
    me^^COsvtxasfl.text_string = NULL;

    om$send(mode = OM_e_wrt_message,
            msg = message CEO_LOCATE.init(type,str_ptr),
            targetid = my_id);
}

action delete
{
    /*
     *  if memory has been allocated for a text string, deallocate it
     */

    if (me^^COsvtxasfl.text_string)
    {
        om$dealloc(ptr = me^^COsvtxasfl.text_string);
    }

    om$send(mode = OM_e_wrt_message,
            msg = message CEO_LOCATE.delete(f_defer_flag),
            targetid = my_id);
}

/*
 * If strip_string = 1, strip the escape sequences from the text string.
 * If strip_string = 0, don't strip the text string.
 */

action get_text(int strip_string)
{
    IGRlong             temp_msg, om_msg;
    struct vfont_entry  font_info;

    me->ret = MSSUCC;

    /*
     * if a text string had previously been allocated, deallocate the memory
     * for it
     */

    if (me^^COsvtxasfl.text_string)
    {
        om$dealloc(ptr = me^^COsvtxasfl.text_string);
        me^^COsvtxasfl.text_string = NULL;
    }

    /*
     * get the selected text object's text attributes and text string
     */

    om_msg = om$send(msg = message GRtext.GRgettxattr
                                                (&temp_msg,
                                                 &me^^COsvtxasfl.text_attr,
                                                 NULL,
                                                 &me^^COsvtxasfl.text_string),
                     targetid = me->event1.located_object[0].located_obj.objid,
                     targetos = me->event1.located_object[0].located_obj.osnum);

    if (om_msg & temp_msg & 1)
    {
        if (me^^COsvtxasfl.text_attr.text_length)
        {
            /*
             * strip the escape sequences from the text string if requested
             */

            if (strip_string)
            {
                font$get_info(msg = &temp_msg,
                              font_num = &me^^COsvtxasfl.text_attr.font,
                              font_info = &font_info);

                co$rm_esc_seqs(msg = &temp_msg,
                               font_num = me^^COsvtxasfl.text_attr.font,
                               font_flags = font_info.flags,
                               text_string = me^^COsvtxasfl.text_string,
                               text_length = &me^^COsvtxasfl.text_attr.text_length);
            }
        }
        else  /* empty text string */
        {
            me->ret = MSINARG;
        }
    }
    else
    {
        me->ret = MSFAIL;
    }
}

action check_file()
{
    IGRint    fd;   /* file descriptor */

    /*
     * try to open the file to see if it exists and we have write permission
     */

    if ((fd = open(me->event1.event.keyin,1)) == -1)
    {
        /*
         * the specified file could not be accessed; find out why
         */

        if (errno == ENOENT)
        {
            /*
             * the named file does not exist; it's o.k. to create a file
             * using this file name
             */

            strcpy(me^^COsvtxasfl.file_name,me->event1.event.keyin);
        }

        me->ret = errno;
    }
    else  /* file exists and is not write protected */
    {
        me->ret = MSFAIL;
        strcpy(me^^COsvtxasfl.file_name,me->event1.event.keyin);
        close(fd);
    }
}

action write_text_to_file()
{
    IGRint              fd;          /* file descriptor               */

    /*
     * write the text string to the specified file
     */

    if ((fd = creat(me^^COsvtxasfl.file_name,CREATE_MODE)) == -1)
    {
        me->ret = MSFAIL;  /* a component of the path name is incorrect */
    }
    else  /* successfully created file; write to it */
    {
        if (write(fd,me^^COsvtxasfl.text_string,
                      (IGRuint)me^^COsvtxasfl.text_attr.text_length) == me^^COsvtxasfl.text_attr.text_length)
        {
            /*
             * successfully wrote the file
             */

            me->ret = MSSUCC;
        }
        else  /* error writing file */
        {
            me->ret = MSINARG;
        }
        close(fd);
    }
}
