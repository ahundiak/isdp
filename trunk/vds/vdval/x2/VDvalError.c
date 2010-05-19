/* $Id: VDvalError.c,v 1.1 2001/06/22 15:18:31 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdval/x2/VDvalError.c
 *
 * Description:	Error handling routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvalError.c,v $
 *      Revision 1.1  2001/06/22 15:18:31  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/14/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDgeomc.h"
#include "VDctx.h"
#include "VDval.h"
#include "stdarg.h"
#include "glib.h"

VDASSERT_FFN("VDvalError.c");

typedef struct 
{
  TGRid  pieceID;
  TGRid  stageID;
  IGRint hdr;
  IGRint cnt;
} TlogErrorData;

static TlogErrorData *logErrorData;


/* -----------------------------------------------
 * Reset master data
 */
void VDvalResetLogErrorData()
{
  if (logErrorData == NULL) {
    logErrorData = g_new(TlogErrorData,1);
  }
  memset(logErrorData,0,sizeof(TlogErrorData));
  logErrorData->pieceID.objid = NULL_OBJID;
  logErrorData->stageID.objid = NULL_OBJID;
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Setup for piece
 */
void VDvalSetPieceError(TGRid *pieceID) 
{
  VDvalResetLogErrorData();
  logErrorData->pieceID = *pieceID;
  return;
}
void VDvalSetStageError(TGRid *stageID) 
{
  VDvalResetLogErrorData();
  logErrorData->stageID = *stageID;
  return;
}

/* -----------------------------------------------
 * General purpose logger
 */
void VDvalLogError(IGRchar *fmt, ...)
{  
  IGRchab buf;
  IGRchab pcmk;
  IGRchab nodeType;
  IGRchab nodeName;
  
  va_list ap;

  // Print piece header
  if ((logErrorData) && 
      (logErrorData->hdr == 0) && 
      (logErrorData->pieceID.objid != NULL_OBJID)) {
    VDctzGetPieceMark(&logErrorData->pieceID,pcmk);
    sprintf(buf,"\nPiece %s",pcmk);
    VDlogPrintBuf(VDLOG_ERROR,1,buf);
    logErrorData->hdr = 1;
  }
  // Print stage header
  if ((logErrorData) &&
      (logErrorData->hdr == 0) && 
      (logErrorData->stageID.objid != NULL_OBJID)) {
    VDctzGetStagingType(&logErrorData->stageID,nodeType);
    VDctzGetStagingName(&logErrorData->stageID,nodeName);
    sprintf(buf,"\nStage %s %s",nodeType,nodeName);
    VDlogPrintBuf(VDLOG_ERROR,1,buf);
    logErrorData->hdr = 1;
  }

  // Print the message
  va_start(ap, fmt);
  vsprintf(buf,fmt,ap);  
  va_end(ap);
  VDlogPrintBuf(VDLOG_ERROR,1,buf);
  
  // Inc counter
  if (logErrorData) logErrorData->cnt++;
  
wrapup:
  return;
}
