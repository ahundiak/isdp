class implementation COsvtxasfl;



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



#define _start 0
#define _overwrite_file 1
#define _get_filename 2

method init ( int type ; char * str_ptr )
{
  int		  status = OM_S_SUCCESS;

    me^^COsvtxasfl.text_string = NULL;

    om$send(mode = OM_e_wrt_message,
            msg = message CEO_LOCATE.init(type,str_ptr),
            targetid = my_id);
quit:
  return OM_S_SUCCESS;
}

method delete ( int f_defer_flag )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method get_text (int strip_string)
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method check_file ()
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method write_text_to_file ()
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

end implementation COsvtxasfl;
