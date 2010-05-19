/* $Id: VDatLike.c,v 1.3 2002/04/18 16:33:32 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk2/VDatLike.c
 *
 * Description: Like Piece Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatLike.c,v $
 *      Revision 1.3  2002/04/18 16:33:32  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/10/19 18:22:34  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/04/02 20:56:03  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/03/22 14:42:19  ahundiak
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/13/01  ah      Creation
 * 04/02/01  ah      Moved the Like code from VDatStd.c
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"

#include "VDlog.h"
#include "VDrisc.h"
#include "VDctx.h"
#include "VDss.h"
#include "VDat.h"
#include "VDat2Pcmk.h"

VDASSERT_FFN("vdat/pcmk2/VDatLike.c");

#define VDAT_PCMK_MAX_LIKE_PLATE_AREA  300000
#define VDAT_PCMK_MAX_LIKE_BEAM_HEIGHT    250

/* -----------------------------------------------
 * These are pieces which cannot be declared like
 *
 * This flag can be very confusing, pieces whose notLike
 * flag is set are skipped during the like part processing
 * This includes standard pieces, non-planar plates, big plates
 * and tall beams
 *
 * Just because notLike = 0 doesnot mean it's alike part, just that it
 * could be.
 *
 * Might be better to have an attribute called 
 * "piece_could_be_lk"
 * "piece_test_like"   This one I like
 * "piece_skip_like"   This one I like
 * "piece_maybe_lk"
 */
static void setNotLikeFlag(TGRid *nodeID)
{
  VDASSERT_FN("setNotLikeFlag");
  
  IGRchab   buf;
  IGRchab   pieceType;
  IGRdouble area;
  IGRdouble height;
  
  IGRchar notLike[4];

  // Init to being true
  strcpy(notLike,"1");
  
  // Standards are not like
  VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_PIECE_PCMK_KEY,buf);
  if (*buf) goto wrapup;

  // Plate or beam
  VDctxGetNodeTypeSuffix(nodeID,pieceType);

  // Plates
  if (!strcmp(pieceType,VDCTX_NODE_TYPE_PLATE)) {
    
    // Must be planar
    VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_PLATE_IS_PLANAR,buf);
    if (*buf != '1') goto wrapup;

    // Check the min area
    VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_PLATE_AREA,buf);
    area = atof(buf);
    if (area > VDAT_PCMK_MAX_LIKE_PLATE_AREA) goto wrapup;

    // Might be like
    *notLike = '0';
    goto wrapup;    
  }  

  // Beams
  if (!strcmp(pieceType,VDCTX_NODE_TYPE_BEAM)) {

    /* -------------------------------------------
     * Imposing this restriction will cause some of the
     * pcmk1 assigned likes to fail
     * Turn back on and research later to see why
     *
     * Maybe webs really are planar
     * Or maybe it's ok
     */
    // Must be planar
    VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_BEAM_IS_PLANAR,buf);
    // if (*buf != '1') goto set_it;

    // Height restriction
    VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_BEAM_HEIGHT,buf);
    height = atof(buf);
    if (height > VDAT_PCMK_MAX_LIKE_BEAM_HEIGHT) goto wrapup;

    // Might be like
    *notLike = '0';
    goto wrapup;
    
  }
  
  // It might be like
  VDASSERTW(0);

 wrapup:
  VDctxAppTxtAtr(nodeID,VDCTX_ATR_SS_PIECE_NOT_LIKE,notLike);
  return;  
}

/* -----------------------------------------------
 * Given a list of pieces, fill in the not like part flag
 * Full attributes must have already been added
 */
void VDat2SetNotLikeFlags(TVDctxNodeList *listPM)
{
  VDASSERT_FN("VDat2SetNotLikeFlags");
  
  IGRint i;
  TGRid *nodeID;
  
  // Arg check
  VDASSERTW(listPM && listPM->listIDs);
  
  // Cycle through
  for(i = 0; i < listPM->cnt; i++) {

    // Status
    if (!(i % 100)) {
      VDlogPrintFmt(VDLOG_STAT,0,"Setting not_like flags for %d of %d",i+1,listPM->cnt);
    }

    nodeID = &listPM->listIDs[i];
    setNotLikeFlag(nodeID);

  }
  VDlogPrintFmt(VDLOG_STAT,0,"Done setting not_like flags");
  
  // Done
 wrapup:
  return;
}
