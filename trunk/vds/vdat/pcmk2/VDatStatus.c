/* $Id: VDatStatus.c,v 1.2 2001/10/19 18:22:34 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk2/VDatStatus.c
 *
 * Description: Common Status Processor
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatStatus.c,v $
 *      Revision 1.2  2001/10/19 18:22:34  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/03/18 22:49:45  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/03/16 17:10:45  ahundiak
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/13/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"

#include "VDlog.h"
#include "VDctx.h"
#include "VDss.h"
#include "VDat.h"
#include "VDfrmc.h"

VDASSERT_FFN("vdat/pcmk2/VDatStatus.c");

static Form s_form;

void VDat2SetCmdStatusForm(Form form)
{
  s_form = form;
}

/* -----------------------------------------------
 * Little status routine
 */
void VDat2SetCmdStatus(IGRint flag, IGRchar *msg)
{
  VDASSERT_FN("VDat2SetCmdStatus");
    
  // Status Bar
  switch(flag) {
    case VDLOG_INFO:
    case VDLOG_STAT:
      if (s_form) VDfrmSetStatus(s_form,10,msg);
      break;
  }

  // Message box
  switch(flag) {
    case VDLOG_ERROR:
    case VDLOG_WARN:
    case VDLOG_INFO:
      // VDfrmSetfText(s->form,VDRRV_FORM_CREATE_G_STAT,s->statusRow,0,msg);
      // VDfrmShowRow (s->form,VDRRV_FORM_CREATE_G_STAT,s->statusRow);
      // s->statusRow++;
      break;
  }

  // UI_status
  switch(flag) {
    case VDLOG_INFO:
    case VDLOG_STAT:
      UI_status(msg);
      break;
  }

  // Done
 wrapup:
  return;
}
