/* $Id: VDatAttr.I,v 1.2 2001/03/23 21:42:50 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        $VDS/vdat/set/VDatAttr.I
 *
 * Description:
 *		The file contains the implementation of some 
 *		vdat macros involving review attributes.
 *
 * Revision History:
 *      $Log: VDatAttr.I,v $
 *      Revision 1.2  2001/03/23 21:42:50  ahundiak
 *      ah
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:43  cvs
 *      Initial import to CVS
 *
# Revision 1.6  1999/01/27  22:28:50  pinnacle
# Replaced: vdat/set/VDatAttr.I for:  by vsrivast for vds
#
# Revision 1.5  1999/01/27  22:06:26  pinnacle
# Replaced: vdat/set/VDatAttr.I for:  by vsrivast for vds
#
# Revision 1.3  1999/01/25  21:24:52  pinnacle
# Replaced: vdat/set/VDatAttr.I for:  by vsrivast for vds
#
# Revision 1.1  1999/01/12  15:20:50  pinnacle
# initial revision
#
 *
 * History:
 * MM/DD/YY  AUTHOR          DESCRIPTION
 * 01/12/99  vinit	     Creation  
 * 01/19/99  vinit	     Modified to handle Extract for Review
 * 01/23/01  ah              TR4982 Screwed up piece of crap
 *                           Two functions, one for just getting the count
 *                           No checking to see if the attributes were actually obtained
 *                           Calling routines failing because of count of 2 was being returned
 *                           but no attributes when a leaf was not actually staged
 *                           Hacked around that, replace the entire routine for 2.6.3
 ***************************************************************************/
class implementation VDatBase;

#include "VDmem.h"
#include "VDppl1.h"
#include "VDatparmacros.h"
#include "v_dbgmacros.h"

IGRint VDatgetParams (
  IGRlong    *sts,
  TGRid      *object,
  IGRint     *count,
  struct ACrg_coll	**plist,
  IGRchar    *i_setType,
  IGRint     type	)
{
  
  TGRid   pplID;
  IGRint  pplRET;
  IGRchar data[64];
  IGRint  datai;
  IGRlong  status;
  IGRint  stat;
  IGRint  retFlag;
  struct ACrg_coll *list;
  
  
  //Init
  datai = type;
  retFlag = 0;
  *sts = 0;
  list = NULL;
  
  if(plist) *plist = NULL;
  if(count) *count = 0;
  
  // Args Check
  if(i_setType == NULL) goto wrapup;
  if(object->objid == NULL_OBJID) goto wrapup;
  if(plist == NULL) goto wrapup;
  
    
    // Load the ppl
  vdppl$Load (name = i_setType, pplID = &pplID);
  if(pplID.objid == NULL_OBJID)
  {
    printf(" Unable to load %s.e in VDatAttr\n", i_setType);
    goto wrapup;
  }
  
  /* Set the NODE_ID, TYPE, NB_ATTRS from the input to 
   * to the function
   */
  vdppl$SetData (
    pplID = &pplID,
    name  = "NODE_ID",
    size  = sizeof (TGRid),
    data  = (IGRchar*) object
  );
  vdppl$SetData (
    pplID = &pplID,
    name  = "TYPE",
    size  = sizeof (IGRint),
    data  = (IGRchar*) &datai
  );
  
  stat = vdat$get_parameters(
    	  sts	= &status,
        count	= count,
    i_setType   = i_setType,
    	 type   = type
  );

  if(!(status & 1))
  {
    vdppl$Delete(pplID = &pplID);
    goto wrapup;
  }
  
  vdppl$SetData (
    pplID = &pplID,
    name  = "NB_ATTRS",
    size  = sizeof (IGRint),
    data  = (IGRchar*) count 
  );
  //Run the function and get the relevent attributes.
  
  vdppl$Run (pplID = &pplID, name = "getReviewAttributes", ret = &pplRET);
  
  if(!(pplRET & 1)) 
  {
    vdppl$Delete(pplID = &pplID);
    goto wrapup;
  }
  
  vdppl$GetData (
    pplID = &pplID,
    name  = "COLL",
    size  = sizeof (struct ACrg_coll *),
    data  = (IGRchar*) plist
  );
  vdppl$Delete(pplID = &pplID);

  
  *sts = 1;
  retFlag = 1;
 wrapup:

  // Just make sure actually got the parameters
  // If an item is not staged then the parameters are not given
  if (plist) {  
    if (*plist == NULL) {
      *sts    = 0;
      if (count) *count  = 0;
      retFlag = 0;
    }
  }
  
  return retFlag;
	
}
/*  Function for macro vdat$get_params
 */
IGRint VDatget_Params( IGRlong  	*sts,
		       TGRid 		*object,
		       IGRint 		*count,
		       struct ACrg_coll **plist,
		       IGRint		type    )
  
{
  IGRint    retFlag;
  TGRid     setID;
  TGRid     leafID;
  IGRchar   setType[128];
  TVDvlaID  leafVLA;
  IGRint    i, j;
  IGRint    stat;
  IGRlong   status;
  IGRint    countx[5];
  struct ACrg_coll *plistx, *plisty;



  // Args Check
  if(count) *count = 0;
  if(plist) *plist = NULL;
  
  
  // Init
  retFlag = 0;
  *sts = 0;
  plistx = NULL;
  VDvlaID_Construct(&leafVLA);

  if(object->objid == NULL_OBJID) goto wrapup;
  if(plist == NULL) goto wrapup;
  
  if(VDatIsBaseType (object, VDAT_CLASSI_LEAF))
  {
    VDatGetSet(object, &setID);
    if(setID.objid == NULL_OBJID) goto wrapup;
    
    VDatGetSetType(&setID, setType);
    VDatgetParams( sts, object, count, plist, setType, type);
    
    *sts = 1;
    retFlag = 1;
    goto wrapup;
  }
  
  // Object not a leaf. Get all sets it belongs to
  
  // Construct the leafvla
  
  
  VDatGetObjectLeafsVLA(object, &leafVLA);
  VDvlaID_GetAt(&leafVLA,&leafID,0);	
  
  VDatGetSet(&leafID,&setID);
  if (setID.objid != NULL_OBJID)
  {
    VDatGetSetType(&setID, setType);
    VDatgetParams( sts, &leafID, &countx[0], &plistx, setType, type);
    *count = countx[0];
    *plist = plistx;
  }
  
  for(i = 1; VDvlaID_GetAt(&leafVLA,&leafID,i); i=i+1) 
  {
    VDatGetSet(&leafID,&setID);
    if (setID.objid != NULL_OBJID)
    {
      
      VDatGetSetType(&setID, setType);
      VDatgetParams( sts, &leafID, &countx[i], &plisty, setType, type);
      plistx = realloc(plistx, (*count+countx[i])*sizeof(struct ACrg_coll));
      *plist = plistx;
      memcpy(plistx+*count, plisty, countx[i]*sizeof(struct ACrg_coll));
      *count+=countx[i];
      free(plisty);
      
    }
  }
  *sts = 1;
  retFlag = 1;
 wrapup:
  VDvlaID_Delete(&leafVLA);
  return retFlag;
}





/* 	Function for macro vdat$get_parameters
 */
IGRint VDatGetParameters( 
  IGRlong 	*sts,
  IGRint        *count,
  IGRchar       *i_setType,
  IGRint        type   )
{

  TGRid   pplID;
  IGRint  pplRET;
  IGRint  retFlag;
  IGRint  datai;
  
  //Init
  *sts = 0;
  retFlag = 0;
  datai = type;
  
  if(count) *count = 0;
  if(i_setType == NULL) goto wrapup;
  
  vdppl$Load (name = i_setType, pplID = &pplID);
  if(pplID.objid == NULL_OBJID) 
  {
    printf(" Unable to load %s.e in VDatAttr\n", i_setType);
    goto wrapup;
  }
  vdppl$SetData (
    pplID = &pplID,
    name  = "TYPE",
    size  = sizeof (IGRint),
    data  = (IGRchar*) &datai
  );
  vdppl$Run (pplID = &pplID, name = "getNumofAttributes", ret = &pplRET);
  
  if(!(pplRET & 1))
    {
      vdppl$Delete(pplID = &pplID);
      goto wrapup;
    }
  
  vdppl$GetData (
    pplID = &pplID,
    name  = "NB_ATTRS",
    size  = sizeof (IGRint),
    data  = (IGRchar*) count 
  );
  vdppl$Delete(pplID = &pplID);
  
  *sts = 1;
  retFlag = 1;
 wrapup:
  return retFlag;
}
end implementation VDatBase;











