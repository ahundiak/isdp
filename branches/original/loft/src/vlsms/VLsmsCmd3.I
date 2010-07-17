/* $Id: VLsmsCmd3.I,v 1.4 2002/04/24 15:12:51 ahundiak Exp $  */

/***************************************************************************
 * I/EFP
 *
 * File:        vlsms/VLextCmd3.I
 *
 * Description: Extract For Production
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLsmsCmd3.I,v $
 *      Revision 1.4  2002/04/24 15:12:51  ahundiak
 *      ah
 *
 *      Revision 1.3  2002/04/09 20:54:13  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/09/14 13:42:56  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/01/18 17:55:32  art
 *      ah
 *
# Revision 1.2  2000/12/15  20:03:00  pinnacle
# ah
#
# Revision 1.1  2000/11/27  20:25:38  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/17/00  ah      Creation
 *
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"

#include "VDfrmMacros.h"
#include "VDobj.h"
#include "VDvla.h"
#include "VDsa.h"

#include "VDat.h"
#include "VDxml.h"
#include "VDcvg.h"
#include "VLsms.h"
#include "VLsmsCmd.h"

#include "VDassert.h"

VDASSERT_FFN("src/vlsms/VLsmsCmd3.I");

/* -----------------------------------------------
 * Fills in set and other stuff from the form
 */
IGRstat VLsmsCmdGetInfoFromForm(Form form, TVLsmsCmdInfo  *info)
{
  VDASSERT_FN("VLsmsCmdGetInfoFromForm");
  
  IGRstat retFlag = 0;
  
  // Arg check
  VDASSERTW(info);
  info->setID.objid = NULL_OBJID;
  VDASSERTW(form);

  // Various gadgets
  vdfrm$GetText(form = form, gadget = VLEXT_FORM_G_UNIT, txt = info->unitReal);
  vdfrm$GetText(form = form, gadget = VLEXT_FORM_G_HULL, txt = info->hull);

  vdfrm$GetState(form = form, gadget = VLEXT_FORM_G_MAP, state = &info->mapLabels);
  vdfrm$GetState(form = form, gadget = VLEXT_FORM_G_PRE, state = &info->preTranslate);

  // Get the actual set object
  strcpy(info->unitTest,info->unitReal);
  VLsmsCmdGetSetToWrite(info->unitReal, 
			&info->setID,
			&info->setIDu,
			&info->setIDm);
  if (info->setID.objid == NULL_OBJID) {
    VLsmsLog1(1,1,"Could not find staging tree for '%s'\n",info->unitReal);
    goto wrapup;
  }
  
  // Hardcode for now
  strcpy(info->fileStatus,"0 - Open");
  strcpy(info->fileWhat,  "All");

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Consistent means of writing header objects
 */
IGRstat VLsmsCmdWriteHeader(TVLsmsCmdInfo *info)
{
  VDASSERT_FN("VLsmsCmdWriteHeader");
  
  IGRstat retFlag = 0;
  
  // Arg check
  VDASSERTW(info);
  VDASSERTW(info->setID.objid != NULL_OBJID);

  // Get spades file name
  VLsmsExtGenFileName(&info->setID,
		      info->hull,
		      info->fileWhat,
		      info->timeStamp,
		      info->spadesFileName);

  // Write the setup information
  VLsmsExtExtractSetup(&info->file.cvg.xml,
		       info->timeStamp,
		       info->spadesFileName,
		       info->fileStatus,
		       info->preTranslate);

  // Write the ship information
  VLsmsExtExtractShip(&info->file.cvg.xml,
		       info->hull);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Write out a set using info pulled from the form
 * Allow a quick scan for errors or a full
 * extraction
 */
IGRstat VLsmsCmdWriteSetUsingForm(Form form, IGRint type)
{
  VDASSERT_FN("VLsmsCmdWriteSetUsingForm");
  IGRstat retFlag;
  IGRstat sts;
  
  TVLsmsCmdInfo  infox;
  TVLsmsCmdInfo *info;
  
  IGRchar buf[256];
  
  // Init 
  info = &infox;
  memset(info,0,sizeof(TVLsmsCmdInfo));
  UI_status("Production Extraction ...");

  // Open the log files
  sts = VLsmsInitLogFiles();
  if (!(sts & 1)) goto wrapup;

  // Open the main file
  sts = VLsmsOpenOutputFile(&info->file,"SmsData.xml");
  if (!(sts & 1)) goto wrapup;

  // Fill in some info
  VLsmsCmdGetInfoFromForm(form,info);
  if (info->setID.objid == NULL_OBJID) goto wrapup;
  
  // Header stuff
  VLsmsCmdWriteHeader(info);

  // Write the tree
  info->writeTree = 1;
  VLsmsCmdWriteTree(info);

  // Check plates
  VLsmsCmdCheckPlates(info);
  
  // Write the plates
  // if (writePlates) VLsmsCmdWritePlates(info);

  // Done
  retFlag = 1;
  
wrapup:

  // Free the plate info
  if (info->plateItems) free(info->plateItems);

  // Close the output file
  VLsmsCloseOutputFile(&info->file,1);
  UI_status("Production Extraction Complete, See extract.log");

  // Close the log files
  VLsmsCloseLogFiles();
  VDlogShowCat("extract.log");
  
  // Really done
  return retFlag;
}

/* -----------------------------------------------
 * See if the tree was changed since it was last posted
 * and if so, repost it
 */
IGRstat VLsmsCmdWriteTreeRev(Form form, IGRint type)
{
  VDASSERT_FN("VLsmsCmdWriteTreeRev");
  IGRstat retFlag;
  IGRstat sts;
  
  TVLsmsCmdInfo  infox;
  TVLsmsCmdInfo *info;
  
  IGRchar buf[256];

  IGRint  results;
  IGRint  gadget = VLEXT_FORM_G_TREE_STATUS;
  
  TVDatBlob blob;
  
  // Init 
  info = &infox;
  memset(info,0,sizeof(TVLsmsCmdInfo));

  // Fill in some info
  VLsmsCmdGetInfoFromForm(form,info);
  if (info->setID.objid == NULL_OBJID) goto wrapup;
  
  // Make sure logged in
  VDrisOpenSchema(NULL);
  
  // Purpose and set type
  memset(&blob,0,sizeof(TVDatBlob));
  strcpy(blob.purpose, "SPADES");
  strcpy(blob.set_type,"StagingTree");
  strcpy(blob.set_name,info->unitReal);
  strcpy(blob.hull,info->hull);

  // See if tree has changed
  vdfrm$SetText(form = form, gadget = gadget, row = 0,
		txt = "Checking for staging tree changes ...");

  VDatHasBlobChanged(&blob,&results);
  if (results == 0) results = 3;
  
  switch(results) {
    case 1:
      vdfrm$SetText(form = form, gadget = gadget, row = 0,
		    txt = "Staging tree has NOT changed.");

      vdfrm$SetText(form = form, gadget = gadget, row = 1,
		    txt = "It was last posted on:");

      sprintf(buf,"%s Revision %d\n",blob.post_date,blob.set_ver);

      vdfrm$SetText(form = form, gadget = gadget, row = 2,
		    txt = buf);

      break;

    case 3:
      vdfrm$SetText(form = form, gadget = gadget, row = 0,
		    txt = "Staging tree has not yet been posted.");

      vdfrm$SetText(form = form, gadget = gadget, row = 1,
		    txt = "Posting the staging tree ...");

      VDatPostBlob(&blob);

      vdfrm$SetText(form = form, gadget = gadget, row = 1,
		    txt = "Staging tree has been posted.");

      sprintf(buf,"%s Revision %d\n",blob.post_date,blob.set_ver);

      vdfrm$SetText(form = form, gadget = gadget, row = 2,
		    txt = buf);
      
      break;

    case 5:
      vdfrm$SetText(form = form, gadget = gadget, row = 0,
		    txt = "Staging tree HAS changed since");

      sprintf(buf,"%s Revision %d\n",blob.post_date,blob.set_ver);

      vdfrm$SetText(form = form, gadget = gadget, row = 1,
		    txt = buf);

      vdfrm$SetText(form = form, gadget = gadget, row = 2,
		    txt = "Re-Posting the staging tree ...");

      VDatPostBlob(&blob);

      vdfrm$SetText(form = form, gadget = gadget, row = 2,
		    txt = "Staging tree has been reposted.");

      sprintf(buf,"%s Revision %d\n",blob.post_date,blob.set_ver);

      vdfrm$SetText(form = form, gadget = gadget, row = 3,
		    txt = buf);

      break;
  
    default: 
      vdfrm$SetText(form = form, gadget = gadget, row = 3,
		    txt = "Problem getting posted Staging Tree");
      break;
  }

  // Enable spades translation
  VIg_enable(form,VLEXT_FORM_B_EXTRACT);
  

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

end implementation Root;
