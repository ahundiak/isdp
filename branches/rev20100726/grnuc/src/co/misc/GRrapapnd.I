class implementation Root;

#include <string.h>
#include "exdef.h"
#include "exmacros.h"
#include "journal.h"
#include "RAPdefs.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "journal.h"

#ifdef X11
#include "X11/Xlib.h"
#endif

#define  RECORDING    ( JNL_journal  () )

from RAPinlisnr  import remove_last_command, listen;

/*

Name
  GRrap_and_jnl_append

Abstract
  Converts the response/response_data into a RAP record and writes it to
  the RAP file if RAP is enabled.  Adds an entry SSpoint to the journal log.

Synopsis
  int GRrap_and_jnl_append(
    int    flag,
    int   *response,
    char  *response_data,
    int   *response_data_size )
 flag                 IN  flag: 0 - just add new event
                                1 - replace last event with new event
 response             IN  response type of event to be recorded
 response_data        IN  event to be recorded
 response_data_size   IN  size of event data
 
Description
  Support for RAP and Journaling for Smart Sketch.  First release is
  for RAP support only. 
  For journaling the actual smart sketch point (global x,y,z) coordinates are
  added as an JNL_INFO_EVENT.
  
Return Value
  MSSUCC - successful
  MSFAIL - failure
  
Notes
  Rajiv Agrawal: 02/18/94
  Adding a journal entry to the journal log differs on ENV5 and X11 platforms.
  Both use the JNL_INFO_EVENT record.  On the ENV5 side, we can use the JNL_CHAR
  kind of event, but on the X11 we need to use a special JNL_WINDOW_CHANGE.  
  This is due to the fact that on X11, the JNL_CHAR events get eaten up by
  journaling if they follow button events.  Best option would be get our
  own code in journaling so that this messup can be avoided in the future.

Index

Keywords
  RAP,replace

History
  10/11/93 : Shelley R. Heard : created
  01/01/94 : Shelley R. Heard : overhauled the X11 code to support journaling
  02/17/94 : Rajiv Agrawal : rewrote the journaling part completely to write an
                             info event to the journal file.(TR119417282)
 */

int GRrap_and_jnl_append( flag, response, response_data, response_data_size )
  int    flag;
  int   *response;
  char  *response_data;
  int   *response_data_size;
{
  int                rc = MSSUCC;
  long               status;
  OM_S_OBJID         listner_id;
  extern int	     JNL_journal();
  
  /*
   *  RAP SUPPORT
   */
  status = ex$get_objid_from_NOD ( 
             NODname = NOD_NAME,        /* "RAPnod"      */
             objname = LISTENER_NAME,   /* "RAPlistener" */
             pobjid = &listner_id,
             modid = OM_GO_TransOS_0,
             mod_osnum = OM_Gw_TransOSnum_0);
  if (status == OM_S_SUCCESS)           /* RAP is on */
  {
    if (flag == 1)
    {
      /*
       * remove old event if requested (flag == 1)
       */
      om$send( msg = message RAPinlisnr.remove_last_command(),
               targetos = OM_Gw_TransOSnum_0,
               targetid = listner_id,
               senderid = NULL_OBJID);
    }
    /*
     * record specified event 
     */
    status = om$send( msg = message RAPinlisnr.listen( response, 
                                                       response_data, 
                                                       response_data_size),
                      targetos = OM_Gw_TransOSnum_0,
                      targetid = listner_id,
                      senderid = NULL_OBJID );
                       
    if (!(status&1)) { rc =  MSFAIL; goto quit; }
  }

  /*
   * Now do the same for journaling if it is turned on.
   */
  if ( RECORDING )
  {
    IGRpoint             wld_button_pt;
    struct EX_button     *p_new_button;
    int                  type, num_bytes, *lastpt_int;
    char                 string[80];
#ifdef X11
    XEvent               xevent;
#endif
    
    p_new_button = ( struct EX_button * ) response_data;
    wld_button_pt[0] = p_new_button->x;
    wld_button_pt[1] = p_new_button->y;
    wld_button_pt[2] = p_new_button->z;
   
    lastpt_int = (int *) &wld_button_pt[0];
    sprintf(string, "%s %x %x %x %x %x %x", "SSpoint",
            lastpt_int[0], lastpt_int[1], lastpt_int[2],
            lastpt_int[3], lastpt_int[4], lastpt_int[5]);
    num_bytes = strlen(string) + 1;   /* Want it NULL terminated */

#if defined (ENV5)
    type = JNL_CHAR;
    JNL_record_info_event(type, num_bytes, string);
#elif defined ( X11 )
    xevent.type = JNL_INFO_EVENT;
    xevent.xany.serial = JNL_WINDOW_CHANGE;
    xevent.xbutton.x = num_bytes;
    JNL_record_input (sizeof(XEvent), (char *)&xevent);
    JNL_record_input (num_bytes, string);
#endif
  }

quit:
  return rc;
}

end implementation Root;

