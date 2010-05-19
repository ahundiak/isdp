/* $Id: compute.h,v 1.2 2001/01/12 14:47:06 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/compute.h
 *
 * Description: Collector Tree Object
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: compute.h,v $
 *      Revision 1.2  2001/01/12 14:47:06  art
 *      sp merge
 *
 * Revision 1.15  2000/07/12  11:17:44  pinnacle
 * pn
 *
 * Revision 1.13  2000/06/30  18:52:26  pinnacle
 * pn
 *
 * Revision 1.12  2000/06/06  14:57:16  pinnacle
 * ah
 *
 * Revision 1.11  2000/06/03  17:34:30  pinnacle
 * ah
 *
 * Revision 1.10  2000/05/31  13:26:44  pinnacle
 * Replaced: vds/vdct1/ppl/compute.h for:  by pnoel for Service Pack
 *
 * Revision 1.9  2000/05/17  15:57:46  pinnacle
 * Replaced: vds/vdct1/ppl/*.h for:  by jdsauby for Service Pack
 *
 *
 * Revision 1.0  2000/03/10  16:10:30  pinnacle
 * pn
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/10/00  pn      Set up to control PPL general functions not data dependent
 * 03/28/00  pn      Moved in getNodeAttrName() to allow visability to all PPLS in one
 *                   location with alteration of all locations at one time
 * 05/31/00  pn      set up some alterations of view of Outfit and Group
 * 06/06/00  ah      Moved node attributes to node_attrs.h
 * 06/30/00  pn      Made some more generic operations 
 ***************************************************************************/

/* -------------------------------------------------
 * Holds some routines shared by various trees
 */


/* --------------------------------------------------
 * Generic attribute setter
 */
IGRstat setAttribute(name,value)
  IGRchar *name;
  IGRchar *value;
{
  TVDfld fld;
  
  vdcol$GetAttr(objID = &NODE_ID, name = name, fld = &fld);
  if (*fld.name == 0) return 0;
  strcpy(fld.val.txt,value);
  vdcol$UpdAttrs(objID = &NODE_ID, cnt = 1, fld = &fld);      
  return 1;
}
/* --------------------------------------------------
 * Pull attribute means to go to a node and find its Attribute
 * and then copy it to another node
 * pulls from NODE_PARENT_ID attributes and 
 * gives the data to NODE_ID attributes
 */
IGRstat pullAttribute(attrName)
  IGRchar *attrName;
{
  IGRstat retFlag;
  IGRstat traceFlag;
  
  TVDfld  fld,fldx;
  
  // Init
  retFlag = 0;
  traceFlag = 0;
  
  // say hi 
  if(traceFlag) printf(">>> pullAttribute[ppl]\n");

  // args check
  if (attrName == 0) goto wrapup;

  // Make sure this node had the attribute
  vdcol$GetAttr(objID = &NODE_ID, name = attrName, fld = &fld);
  if (*fld.name == 0) goto wrapup;
 
  // Make sure it has a source and a place to go
  if (NODE_PARENT_ID.objid == NULL_OBJID) goto wrapup;
  if (NODE_ID.objid == NULL_OBJID) goto wrapup;
  
  // Get it's attribute
  vdcol$GetAttr(objID = &NODE_PARENT_ID, name = attrName, fld = &fldx);
  
  // Update
  strcpy(fld.val.txt,fldx.val.txt);
  vdcol$UpdAttrs(objID = &NODE_ID, cnt = 1, fld = &fld);
  if(traceFlag) printf("Attribute [%s] [%s]\n",attrName,fldx.val.txt);
  
  retFlag = 1;
  
wrapup:
  // say bye
  if(traceFlag) printf("<<< pullAttribute[%d]\n",retFlag);
  return retFlag;
}


/* --------------------------------------------------
 * Pull down means to go up the tree and find a parent
 * node with the attribute in question and grab it's value
 */
IGRstat pullDownAttribute(attrName)
  IGRchar *attrName;
{
  IGRstat retFlag;
  TVDfld  fld,fldx;

  TGRid   childID,parentID;
  
  // Init
  retFlag = 0;
  if (attrName == 0) goto wrapup;

  // Make sure this node had the attribute
  vdcol$GetAttr(objID = &NODE_ID, name = attrName, fld = &fld);
  if (*fld.name == 0) goto wrapup;
  
  // Go up the tree looking for a value
  childID = NODE_ID;
  
parent_loop:
  // get the parent
  vdct1$GetTree1Parent(objID = &childID, nth = 0, outID = &parentID);
  if (parentID.objid == NULL_OBJID) goto wrapup;
  
  // Get it's attribute
  vdcol$GetAttr(objID = &parentID, name = attrName, fld = &fldx);
  if (*fldx.name == 0) {
    childID = parentID;
    goto parent_loop;
  }
  
  // Update
  strcpy(fld.val.txt,fldx.val.txt);
  vdcol$UpdAttrs(objID = &NODE_ID, cnt = 1, fld = &fld);
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* --------------------------------------------------
 * Initialize the um to EA 
 */
IGRstat setAttributeUM()
{
  IGRstat retFlag;
  TVDfld  umFld;
  
  // Init
  retFlag = 0;
  
  // Get it
  vdcol$GetAttr(objID = &NODE_ID, name = VDCT1_ATTR_UM, fld = &umFld);
  if (*umFld.name == 0) goto wrapup;
  
  // Just set
  strcpy(umFld.val.txt,"EA");
  vdcol$UpdAttrs(objID = &NODE_ID, cnt = 1, fld = &umFld);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}


/* ------------------------------------------------------
 * Initialize the type to either 2 (FAB) or 4 (PURCHASED)
 */
IGRstat setAttributeType()
{
  IGRstat retFlag;
  TVDfld  typeFld;
  
  // Init
  retFlag = 0;
  
  // Get it
  vdcol$GetAttr(objID = &NODE_ID, name = VDCT1_ATTR_PART_TYPE, fld = &typeFld);
  if (*typeFld.name == 0) goto wrapup;
  
  // ASSY are fabricated
  if (!strcmp(BASE_INFO.nodeType,VDCT1_ENG_NODE_TYPE_ASSY)) strcpy(typeFld.val.txt,"2");
  if (!strcmp(BASE_INFO.nodeType,VDCT1_ENG_NODE_TYPE_PART)) strcpy(typeFld.val.txt,"4");
  
  // Update
  vdcol$UpdAttrs(objID = &NODE_ID, cnt = 1, fld = &typeFld);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}



/* --------------------------------------------------
 * Sets the date in question
 */
IGRstat computeDate(attrName)
IGRchar *attrName;
{
  IGRstat retFlag;
  TVDfld  dateFld;

  time_t current_time;
  struct tm *tm;
  
  // Make sure have the attribute
  retFlag = 0;
  if (attrName == NULL) goto wrapup;
  vdcol$GetAttr(objID = &NODE_ID, name = attrName, fld = &dateFld);
  if (*dateFld.name == 0) {
    //printf("Went wrapup in computeDate\n");
    goto wrapup;
  }
  
    
  // Date time stamp
  time(&current_time);
  tm = localtime(&current_time);
  sprintf(dateFld.val.txt,
	  "%4d-%02d-%02d %02d:%02d:%02d",
	  tm->tm_year+1900,tm->tm_mon+1,tm->tm_mday,
	  tm->tm_hour,tm->tm_min,tm->tm_sec);
  //printf("Date should be [%s]\n",dateFld.val.txt);
  

  // Update
  vdcol$UpdAttrs(objID = &NODE_ID, cnt = 1, fld = &dateFld);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}
#if 0
/* --------------------------------------------------
 * Sets the version in question
 */
IGRstat computeVersion(attrName)
IGRchar *attrName;
{
  IGRstat retFlag;
  TVDfld  dateFld;

  time_t current_time;
  struct tm *tm;
  
  // Make sure have the attribute
  retFlag = 0;
  if (attrName == NULL) goto wrapup;
  vdcol$GetAttr(objID = &NODE_ID, name = attrName, fld = &dateFld);
  if (*dateFld.name == 0) goto wrapup;
    
  // Date time stamp
  time(&current_time);
  tm = localtime(&current_time);
  sprintf(dateFld.val.txt,
	  "ACT %4d%02d%02d",
	  tm->tm_year+1900,tm->tm_mon+1,tm->tm_mday);

  // Update
  vdcol$UpdAttrs(objID = &NODE_ID, cnt = 1, fld = &dateFld);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}
#endif

extern VDct1SetNodeVersion();

/* --------------------------------------------------
 * Sets the version in question
 */
IGRstat computeVersion(attrName)
IGRchar *attrName;
{
  IGRstat retFlag;
  
  // Init
  retFlag = 0;

  // Done
  retFlag = VDct1SetNodeVersion(&NODE_ID, -1);
  
wrapup:
  return retFlag;
}


