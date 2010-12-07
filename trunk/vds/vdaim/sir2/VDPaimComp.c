/***************************************************************************
 * I/AIM
 *
 * File:        sir2/VDPaimComp.c
 *
 * Description: Compartment Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDPaimComp.c,v $
 *      Revision 1.1.2.3  2004/02/27 15:00:07  ahundiak
 *      ah
 *
 *      Revision 1.1.2.2  2003/06/11 13:31:19  ahundiak
 *      ah
 *
 *      Revision 1.1.2.1  2003/06/06 20:44:19  ahundiak
 *      ah
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/06/03  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDtest.h"
#include "VDpdm.h"
#include "VDrisc.h"
#include "VDobj2.h"
#include "VDdom2.h"

#include "VDPdef.h"
#include "VDPaimUtil.h"
#include "VDPaimPostMan.h"

VDASSERT_FFN("VDPaimGroup.c");


/* ----------------------------------------------
 * Validate compartment if have one
 */
IGRstat VDPaimValidateComptNumber(domNode objNode)
{
  IGRstat    retFlag = 1;
  IGRchar    compt_number[32];
  TVDrisInfo ris;

  /* Init */
  VDrisInitInfo(&ris);

  /* Make sure have one */
  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_COMPT_NUMBER,compt_number);
  if (*compt_number == 0) goto wrapup;

  /* Query */
  sprintf(ris.sql,
          "SELECT comp_num FROM compartment WHERE comp_num = '%s'",
          compt_number);
  VDrisQueryCache(VDRIS_CACHE_VDS,&ris,NULL);
  if (ris.rows) goto wrapup;
  
  /* Not valid */
  retFlag = 0;

wrapup:
  VDrisFreeInfo(&ris);
  return retFlag;
}

/* ----------------------------------------------
 * Lookup a compartment
 */
IGRstat VDPaimGetComptNumberForObject(TGRid *objID, IGRchar *compt_number)
{
  IGRstat retFlag = 0;

  TVDpdmInfo pdmInfo;
  TVDrisInfo ris;

  /* Init */
  VDrisInitInfo(&ris);
  *compt_number = 0;

  /* Need to have a schema open */
  if (!VDrisIsSchemaOpen()) goto wrapup;

  /* Need the file key */
  VDpdmGetPdmInfo(objID->osnum,&pdmInfo);
  if (pdmInfo.filekey == 0) goto wrapup;

  /* Query */
  sprintf(ris.sql,
    "SELECT compt_number FROM compt_dattr WHERE file_key=%d AND comp_seqno = %d",
    pdmInfo.filekey,objID->objid);

  /* Query */
  VDrisQueryCache(VDRIS_CACHE_VDS,&ris,NULL);
  if (ris.rows == 0) goto wrapup;
  strcpy(compt_number,ris.buf[0]);

  /* Done */
  retFlag = 1;

wrapup:
  VDrisFreeInfo(&ris);

  return retFlag;
}

