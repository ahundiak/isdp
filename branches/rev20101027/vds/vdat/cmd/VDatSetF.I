/* $Id: VDatSetF.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/cmd/VDatSetF.I
 *
 * Description: Aux Set Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatSetF.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:42  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1998/10/11  13:53:52  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/10/97  ah      creation
 *
 ***************************************************************************/
class implementation VDatBase;

#include "VDatCmd.h"

/* ----------------------------------------
 * Fill in list of sets, return id of first one
 */
IGRstat VDatFormFillSets(Form form, IGRint gadget)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid setsID;
  TGRid  setID;

  IGRchar setName[128];

  IGRuint i,row;

  // Clear Field
  VIg_set_text(form,gadget,"");
  VIfld_set_list_num_rows(form,gadget,0,0);

  // get list of set
  VDatFormGetSetsID(form,&setsID);
  if (setsID.objid == NULL_OBJID) goto wrapup;

  // Cycle Through
  row = 0;
  for(i = 0; VDatGetChildObject(&setsID,i,&setID); i++) {

    // Show name for now
    *setName = 0;
    sts = VDatGetBaseName(&setID,setName);

    // Just to make sure
    if (sts & 1) {
      VIfld_set_list_text(form,gadget,row,0,setName,0);
      row++;
    }
  }

  // Text Box Itself
  VDatFormGetSetID(form,&setID);
  if (setID.objid == NULL_OBJID) goto wrapup;

  *setName = 0;
  VDatGetBaseName(&setID,setName);
  VIg_set_text(form,gadget,setName);

  retFlag = 1;

wrapup:
  return retFlag;
}

end implementation VDatBase;

