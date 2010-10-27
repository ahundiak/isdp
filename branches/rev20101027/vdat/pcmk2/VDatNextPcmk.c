/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk2/VDatNextPcmk.c
 *
 * Description: Next Available Piece Marks
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatNextPcmk.c,v $
 *      Revision 1.2  2001/10/19 18:22:34  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/04/12 19:12:27  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/12/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"

#include "VDlog.h"
#include "VDrisc.h"

VDASSERT_FFN("VDatNextPcmk.c");

#define VDRIS_TBLN_NEXT_PCMK       "next_pcmk"
#define VDRIS_FLDN_NEXT_PCMK_UNIT  "unit"
#define VDRIS_FLDN_NEXT_PCMK_PCMK  "pcmk"

/* -----------------------------------------------
 * Gets the next available piece mark for
 * a given unit from the next_pcmk table
 *
 * Returns 0 if no entry exists
 * Or not logged in
 */
void VDat2RisGetNextPcmk(IGRchar *unit, IGRint *pcmk)
{
  VDASSERT_FN("VDat2RisGetNextPcmk");
  
  TVDrisInfo ris;

  // Init
  VDrisInitInfo(&ris);

  // Arg check
  VDASSERTW(pcmk); *pcmk = 0;
  VDASSERTW(unit && *unit);

  // Make sure logged in
  if (VDrisIsSchemaOpen() == 0) goto wrapup;
  
  // Query it
  sprintf(ris.sql,
	  "Select %s from %s where %s = %s;",
	  VDRIS_FLDN_NEXT_PCMK_PCMK,
	  VDRIS_TBLN_NEXT_PCMK,
	  VDRIS_FLDN_NEXT_PCMK_UNIT,
	  unit);

  VDrisQuery(&ris,NULL);
  if (ris.rows < 1) goto wrapup;
  
  // Got it
  *pcmk = atoi(ris.buf[0]);

 wrapup:
  VDrisFreeInfo(&ris);
  return;
}

/* -----------------------------------------------
 * Sets the next available piece mark
 */
void VDat2RisSetNextPcmk(IGRchar *unit, IGRint pcmk)
{
  VDASSERT_FN("VDat2RisSetNextPcmk");
  
  TVDrisInfo ris;
  IGRint pcmkx;
  
  // Init
  VDrisInitInfo(&ris);

  // Arg check
  VDASSERTW(unit && *unit);

  // Make sure logged in
  if (VDrisIsSchemaOpen() == 0) goto wrapup;
  
  // Query it to see if have an entry or not
  sprintf(ris.sql,
	  "Select %s from %s where %s = %s;",
	  VDRIS_FLDN_NEXT_PCMK_PCMK,
	  VDRIS_TBLN_NEXT_PCMK,
	  VDRIS_FLDN_NEXT_PCMK_UNIT,
	  unit);

  VDrisQuery(&ris,NULL);
  if (ris.rows < 1) {
    sprintf(ris.sql,
	    "Insert into %s values (%s,%d);",
	    VDRIS_TBLN_NEXT_PCMK,
	    unit,pcmk);
    VDrisExecute(ris.sql);
    goto wrapup;
  }
  
  // Check for a change
  pcmkx = atoi(ris.buf[0]);
  if (pcmk == pcmkx) goto wrapup;
  
  // Update
  sprintf(ris.sql,
	  "Update %s set %s=%d where %s=%s;",
	  VDRIS_TBLN_NEXT_PCMK,
	  VDRIS_FLDN_NEXT_PCMK_PCMK,pcmk,
	  VDRIS_FLDN_NEXT_PCMK_UNIT,unit);
  VDrisExecute(ris.sql);
  	  
 wrapup:
  VDrisFreeInfo(&ris);
  return;
}

