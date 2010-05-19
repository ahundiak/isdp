/* $Id: VDatFld.I,v 1.7 2002/01/04 16:27:48 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/imp/VDatFld.I
 *
 * Description: VDatFld Processing Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatFld.I,v $
 *      Revision 1.7  2002/01/04 16:27:48  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/10/19 20:52:39  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/10/19 18:27:38  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/03/22 20:50:54  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/02/06 20:48:57  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/11 20:37:26  art
 *      sp merge
 *
# Revision 1.1  2000/11/27  19:10:00  pinnacle
# ah
#
# Revision 1.2  1998/10/11  13:53:52  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/25/97  ah      creation
 * 10/10/98  ah      Took out all vla stuff
 * 03/22/01  ah      Added VDatFldValidateTxt
 * 09/17/01
 ***************************************************************************/

class implementation VDatBase;

#include "sys/types.h"
#include "sys/stat.h"

static IGRint invalidAttributeFlag;

/* ----------------------------------------------------
 * Ensures that the text data is valid for VDat objects
 * Filter out control codes
 * Trunc the length to 72 characters
 * Filter single quotes (posting issue)
 *
 * 17 Sep 2001 Deal with cases where the strlen might be invalid
 */
void VDatFldValidateTxt(IGRchar *buf)
{
  IGRchar *p;
  
  // First do no harm
  if (buf == NULL) return;
  
  // Check codes
  for(p = buf; (*p) && ((p - buf) < 72); p++) {
    if (*p < ' ')   {
      printf("*** Attribute had control code in it '%s'\n",buf);
      *p = ' ';
      invalidAttributeFlag = 1;
    }
    if (*p > '~')   {
      printf("*** Attribute had control code(%d) > ~ in it '%s'\n",*p,buf);
      *p = ' ';
      invalidAttributeFlag = 1;
    }
    
    if (*p == '\'') *p = ' ';

  }
  if (*p != 0) {
    printf("*** Truncated attribute '%s'\n",buf);
    invalidAttributeFlag = 1;
  }
  
  *p = 0;
  
  return;
}
/* -----------------------------------------------
 * Check that the field is valid
 */
void VDatFldValidateFld(TVDatFld *fld)
{
  if (fld == NULL) goto wrapup;
  switch(fld->type) {
    case VDAT_FLD_TYPE_CHAR :
      VDatFldValidateTxt(fld->valueTxt);
      break;
      
    case VDAT_FLD_TYPE_DOUBLE:
    case VDAT_FLD_TYPE_INT:
      if (*fld->valueTxt != 0) {
	printf("*** Have an integer/double attribute %s %d with non-blank text data\n",
	       fld->name,fld->type);
	*fld->valueTxt = 0;
	invalidAttributeFlag = 1;
      }
      break;
	
    default:
      printf("*** Unknown field type %s %d\n",fld->name,fld->type);
  }
  
 wrapup:
  return;
}

/* ----------------------------------------------------
 * Find the attr with the given name then set the value
 */
IGRstat VDatFldSetIntByName(
  TVDatFld *flds, 
  IGRint    cnt, 
  IGRchar  *name, 
  IGRint    value
)
{
  IGRint  i;

  for(i = 0; i < cnt; i++) {
    if (!strcmp(name,flds[i].name)) {
      flds[i].valueInt = value;
      return 1;
    }
  }

  return 0;
}

/* ----------------------------------------------------
 * Find the attr with the given name then get the value
 */
IGRstat VDatFldGetIntByName(
  TVDatFld *flds, 
  IGRint    cnt, 
  IGRchar  *name, 
  IGRint   *value
)
{
  IGRint  i;

  for(i = 0; i < cnt; i++) {
    if (!strcmp(name,flds[i].name)) {
      *value = flds[i].valueInt;
      return 1;
    }
  }

  *value = 0;
  return 0;
}

/* ----------------------------------------------------
 * Find the attr with the given name then set the value
 */
IGRstat VDatFldSetDblByName(
  TVDatFld *flds, 
  IGRint    cnt, 
  IGRchar  *name, 
  IGRdouble value
)
{
  IGRint  i;

  for(i = 0; i < cnt; i++) {
    if (!strcmp(name,flds[i].name)) {
      flds[i].valueDbl = value;
      return 1;
    }
  }

  return 0;
}

/* ----------------------------------------------------
 * Find the attr with the given name then get the value
 */
IGRstat VDatFldGetDblByName(
  TVDatFld  *flds, 
  IGRint     cnt, 
  IGRchar   *name, 
  IGRdouble *value
)
{
  IGRint  i;

  for(i = 0; i < cnt; i++) {
    if (!strcmp(name,flds[i].name)) {
      *value = flds[i].valueDbl;
      return 1;
    }
  }
  *value = 0.0;
  return 0;

}

/* ----------------------------------------------------
 * Find the attr with the given name then set the value
 * Filter out invalid characters
 */
IGRstat VDatFldSetTxtByName(
  TVDatFld *flds, 
  IGRint    cnt, 
  IGRchar  *name, 
  IGRchar  *value
)
{
  IGRint  i;
  IGRchar buf[1024];
  
  strcpy(buf,value);
  VDatFldValidateTxt(buf);
  
  for(i = 0; i < cnt; i++) {
    if (!strcmp(name,flds[i].name)) {
      strcpy(flds[i].valueTxt,buf);
      return 1;
    }
  }

  return 0;
}

/* ----------------------------------------------------
 * Find the attr with the given name then get the value
 */
IGRstat VDatFldGetTxtByName(
  TVDatFld *flds, 
  IGRint    cnt, 
  IGRchar  *name, 
  IGRchar  *value
)
{
  IGRint  i;
  IGRchar buf[1024];
  
  for(i = 0; i < cnt; i++) {
    if (!strcmp(name,flds[i].name)) {
      strcpy(buf,flds[i].valueTxt);
      VDatFldValidateTxt(buf);      
      strcpy(value,buf);
      return 1;
    }
  }
  *value = 0;

  return 0;
}

/* ----------------------------------------------------
 * Copies one field from array
 */
IGRstat VDatFldCopy(
  TVDatFld *flds, 
  IGRint    cnt, 
  TVDatFld *fld
)
{
  IGRstat retFlag = 0;
  IGRint  i;
  TVDatFld *fldx;

  VDatFldValidateFld(fld);
  
  for(i = 0; i < cnt; i++) {
    if (!strcmp(fld->name,flds[i].name)) {
      fldx = &flds[i];

      fldx->valueInt = fld->valueInt;
      fldx->valueDbl = fld->valueDbl;
      strcpy(fldx->valueTxt,fld->valueTxt);

      VDatFldValidateTxt(fldx->valueTxt);
      
      retFlag = 1;
      goto wrapup;
    }
  }
wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * Sets a field by index, inc counter if not null
 */
IGRstat VDatFldSetIntByIndex(TVDatFld *fld, IGRint *ind, IGRint index, IGRlong value)
{
  // Basically ignore if null
  if (value == 0) return 0;

  VDatFldSetInt(fld,NULL,value);
  fld->index = index;

  if (ind) *ind = *ind + 1;

  return 1;
}

IGRstat VDatFldSetDblByIndex(TVDatFld *fld, IGRint *ind, IGRint index, IGRdouble value)
{
  // Basically ignore if null
  if (fabs(value) <.0001) return 0;

  VDatFldSetDbl(fld,NULL,value);
  fld->index = index;

  if (ind) *ind = *ind + 1;

  return 1;
}

IGRstat VDatFldSetTxtByIndex(TVDatFld *fld, IGRint *ind, IGRint index, IGRchar *value)
{
  // Basically ignore if null
  if (*value == 0) return 0;

  VDatFldSetTxt(fld,NULL,value);
  fld->index = index;

  if (ind) *ind = *ind + 1;

  return 1;
}

/* ------------------------------------------------
 * Gets a field by index from a list
 * Returns 1 if found
 * Returns 0 and clears if not found
 */
IGRstat VDatFldGetIntByIndex(TVDatFld *fld, IGRint cnt, IGRint index, IGRlong *value)
{
  IGRint  i;

  for(i = 0; i < cnt; i++) {
    if (index == fld[i].index) {
      *value = fld[i].valueInt;
      return 1;
    }
  }
  *value = 0;

  return 0;
}

IGRstat VDatFldGetDblByIndex(TVDatFld *fld, IGRint cnt, IGRint index, IGRdouble *value)
{
  IGRint  i;

  for(i = 0; i < cnt; i++) {
    if (index == fld[i].index) {
      *value = fld[i].valueDbl;
      return 1;
    }
  }
  *value = 0.0;

  return 0;
}

IGRstat VDatFldGetTxtByIndex(TVDatFld *fld, IGRint cnt, IGRint index, IGRchar *value)
{
  IGRint  i;
  IGRchar buf[1024];
  
  for(i = 0; i < cnt; i++) {
    if (index == fld[i].index) {
      strcpy(buf,fld[i].valueTxt);
      VDatFldValidateTxt(buf);
      strcpy(value,buf);
      return 1;
    }
  }
  *value = 0;

  return 0;
}

/* ------------------------------------------------
 * Sets a given fld structure
 * Assume most commonly use by name
 */
IGRstat VDatFldSetInt(TVDatFld *fld, IGRchar *name, IGRlong value)
{
  memset(fld,0,sizeof(TVDatFld));

  fld->type = VDAT_FLD_TYPE_INT;
  fld->valueInt = value;
  if (name) strcpy(fld->name,name);
  return 1;
}
IGRstat VDatFldSetDbl(TVDatFld *fld, IGRchar *name, IGRdouble value)
{
  memset(fld,0,sizeof(TVDatFld));

  fld->type = VDAT_FLD_TYPE_DOUBLE;
  fld->valueDbl = value;
  if (name) strcpy(fld->name,name);
  return 1;
}
IGRstat VDatFldSetTxt(TVDatFld *fld, IGRchar *name, IGRchar *value)
{
  IGRchar buf[1024];

  IGRchar *p;
  
  memset(fld,0,sizeof(TVDatFld));

  for(p = buf; (*p) && ((p - buf) < 72); p++);
  *p = 0;
  
  strcpy(buf,value);
  VDatFldValidateTxt(buf);
  
  fld->type = VDAT_FLD_TYPE_CHAR;
  strcpy(fld->valueTxt,buf);
  if (name) strcpy(fld->name,name);
  return 1;
}

/* -------------------------------------------------------
 * Function to get list of attributes
 */
IGRstat VDatFldGetAllAttrs(TGRid *objID, TVDatFld *flds, IGRint *a_cnt)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRlong l_cnt;

  IGRint i;
  
  *a_cnt = 0;

  sts = om$send(
    msg = message VDatBase.getAttrs(flds,&l_cnt),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum
  );
  if (!(sts & 1)) goto wrapup;

  for(i = 0; i < l_cnt; i++) {
    VDatFldValidateFld(&flds[i]);
  }
  
  *a_cnt = l_cnt;
  retFlag = 1;

wrapup:
  return retFlag;
}

static IGRint dontLogAttrs;

/* -------------------------------------------------------
 * Function to log list of attributes
 */
IGRstat VDatFldLogAttrs(TGRid *objID, TVDatFld *flds, IGRint cnt)
{
  IGRstat retFlag = 1;
  IGRstat sts;

  IGRchar setName[128];
  IGRchar setType[128];
  IGRchar prefix [128];
  
  FILE *file;
  IGRint i;
  TVDatFld *fld;

  IGRchar buf[1024];
  
  // Skip if logging turned off
  if (dontLogAttrs) goto wrapup;
  
  // Skip for zero or less
  if (cnt <= 0) goto wrapup;

  /* ---------------------------------------------
   * Having a bunch of trouble with trees crasing on updates
   * Save a history of all updates
   */
  VDatGetSetName(objID,setName);
  VDatGetSetType(objID,setType);
  file = fopen("attr.log","a+t");
  if (file == NULL) goto wrapup;

  // Cycle through
  for(i = 0; i < cnt; i++) {
    fld = &flds[i];

    // Only log user attributes
    if (*fld->name == 'u') {
      
      // Standard prefix
      sprintf(prefix,"%s %s %d %-8d %d %-15s|",
	      setType,setName,
	      objID->osnum,objID->objid,
	      fld->type,fld->name);
    
      switch(fld->type) {
	
	case VDAT_FLD_TYPE_CHAR: 
	  strcpy(buf,fld->valueTxt);
	  VDatFldValidateTxt(buf);
	  fprintf(file,"%s%s\n",prefix,buf);
	  break;

	case VDAT_FLD_TYPE_DOUBLE:
	  fprintf(file,"%s%f\n",prefix,fld->valueDbl);
	  break;

	case VDAT_FLD_TYPE_INT:
	  fprintf(file,"%s%d\n",prefix,fld->valueInt);
	  break;
      
	default:
	  fprintf(file,"%sUNKNOWN TYPE\n",prefix);
      }
    }
  }
  fclose(file);
  
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * Function to set list of attributes
 */
IGRstat VDatFldSetAllAttrs(TGRid *objID, TVDatFld *flds, IGRint a_cnt)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRlong l_cnt = a_cnt;

  IGRint i;

  for(i = 0; i < a_cnt; i++) {
    VDatFldValidateFld(&flds[i]);
  }
  
  sts = om$send(
    msg = message VDatBase.setAttrs(flds,l_cnt),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum
  );
  if (!(sts & 1)) goto wrapup;

  VDatFldLogAttrs(objID,flds,a_cnt);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * Function to update list of attributes
 *
 * This is the main function for setting one or more attribute values
 *
 * 17 Sep 2001 - Add an additional validation checl
 */
IGRstat VDatFldUpdAllAttrs(TGRid *objID, TVDatFld *flds, IGRint a_cnt)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRlong l_cnt = a_cnt;
  
  IGRint i;
  
  // Skip for zero or less
  if (l_cnt <= 0) {
    retFlag = 1;
    goto wrapup;
  }

  // Validate
  for(i = 0; i < a_cnt; i++) {
    VDatFldValidateFld(&flds[i]);
  }
  
  // Update them
  sts = om$send(
    msg = message VDatBase.updAttrs(flds,l_cnt),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum
  );
  if (!(sts & 1)) goto wrapup;

  /* ---------------------------------------------
   * Having a bunch of trouble with trees crasing on updates
   * Save a history of all updates
   */
  VDatFldLogAttrs(objID,flds,a_cnt);
    
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * Function to get attribute by prefix
 */
IGRstat VDatFldGetAttrsByPrefix(
  TGRid    *objID, 
  IGRchar  *prefix, 
  TVDatFld *a_flds, 
  IGRint   *a_cnt
)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRint   l_cnt;
  TVDatFld l_flds[VDAT_FLD_MAX];

  IGRint i,len;

  *a_cnt = 0;

  l_cnt = 0;
  sts = VDatFldGetAllAttrs(objID,l_flds,&l_cnt);
  if (!(sts & 1)) goto wrapup;

  if (prefix) len = strlen(prefix);
  else        len = 0;

  for(i = 0; i < l_cnt; i++) {
    if ((len == 0) || (memcmp(prefix,l_flds[i].name,len) == 0)) {
       a_flds[*a_cnt] = l_flds[i];
      *a_cnt = *a_cnt + 1;
    }
  }
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * Function to get attribute by name
 */
IGRstat VDatFldGetAttrByName(TGRid *objID, IGRchar *name, TVDatFld *fld)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  memset(fld,0,sizeof(TVDatFld));

  sts = om$send(
    msg = message VDatBase.getAttrByName(name,fld),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum
  );
  if (!(sts & 1)) goto wrapup;

  VDatFldValidateFld(fld);
  
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Pulls the next attribute from buf
 */
IGRstat VDatCheckAttributeGetFld(IGRchar *buf, IGRchar *fld)
{
  IGRstat retFlag = 0;
  
  IGRchar *p;
  
  // Verify
  if (fld == NULL) goto wrapup;
  *fld = 0;
  if (buf == NULL) goto wrapup;
  
  // Find space
  p = strchr(buf,' ');
  if (p == NULL) goto wrapup;
  
  // Extract it
  *p = 0;
  strcpy(fld,buf);
  
  // Shift buf over
  for(p++; *p == ' '; p++);
  strcpy(buf,p);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Validates a single attribute
 */
IGRstat VDatCheckBaseAttribute(TGRid   *a_setID,
			       IGRchar *a_setType,
			       IGRchar *a_setName,
			       TGRid   *a_nodeID,
			       IGRint  *uCnt,
			       IGRint  *xCnt,
			       IGRchar *buf)
{
  IGRstat retFlag = 1;
  IGRstat sts;
  
  IGRchar setType[64];
  IGRchar setName[64];
  IGRchar work[128];
  
  TGRid nodeID;
  TGRid setID;

  IGRint  type;
  IGRchar name[64];
  IGRchar *p;

  TVDatFld fld;
  IGRdouble d1;
  IGRint    i1;
  
  // Local routine, dont arg check

  // First match set type and name
  VDatCheckAttributeGetFld(buf,setType);
  VDatCheckAttributeGetFld(buf,setName);
  
  if (strcmp(a_setType,setType)) goto wrapup;
  if (strcmp(a_setName,setName)) goto wrapup;
  
  // Get the node id
  VDatCheckAttributeGetFld(buf,work);
  nodeID.osnum = atoi(work);
  VDatCheckAttributeGetFld(buf,work);
  nodeID.objid = atoi(work);
  if ((nodeID.objid != a_nodeID->objid) ||
      (nodeID.osnum != a_nodeID->osnum)) {
    
    // Make sure it's in the desired set
    VDatGetSet(&nodeID,&setID);
    if ((setID.objid != a_setID->objid) ||
	(setID.osnum != a_setID->osnum)) {
      // printf("Node not in set %d\n",nodeID.objid);
      goto wrapup;
    }
    // Skip set check later
    *a_nodeID = nodeID;
  }

  // Need attr type and name
  VDatCheckAttributeGetFld(buf,work);
  type = atoi(work);
  VDatCheckAttributeGetFld(buf,name);

  // Only want user attributes for now I think
  if (*name != 'u') goto wrapup;
  
  // Buffer should contain the actual value
  if (*buf != '|') {
    // printf("Bad Buf %s %s\n",name,buf);
    goto wrapup;
  }
  strcpy(buf,buf+1);
  
  // New line at the very end
  if (strlen(buf) < 1) {
    // printf("Bad Buf Length %s %s\n",name,buf);
    goto wrapup;
  }
    
  p = buf + strlen(buf) - 1;
  if (*p != '\n') {
    // printf("Bad Buf Terminator %s %s\n",name,buf);
    goto wrapup;
  }
  *p = 0;
  
  // Look for codes
  VDatFldValidateTxt(buf);

  // Find the attribute in the object
  VDatFldGetAttrByName(&nodeID,name,&fld);
  if (*fld.name == 0) {
    // printf("Node does not have attribute of given name %s\n",name);
    goto wrapup;
  }
  
  // Check type
  if (type != fld.type) {
    // printf("Attribute type has changed %s\n",name);
    goto wrapup;
  }
  
  // Compare the values
  retFlag = 1;
  switch(type) {

  case VDAT_FLD_TYPE_CHAR: 
    if (!strcmp(buf,fld.valueTxt)) goto wrapup;
#if 0
    printf("Value Changed %s '%s'\n"
	   "              %s '%s'\n",
	   name,buf,name,fld.valueTxt);
#endif
    strcpy(fld.valueTxt,buf);
    break;
    
  case VDAT_FLD_TYPE_DOUBLE:
    d1 = atof(buf);
    if (fabs(d1 - fld.valueDbl) < .1) goto wrapup;
    // printf("Value Changed %s %f %f\n",name,d1,fld.valueDbl);
    fld.valueDbl = d1;
    break;

  case VDAT_FLD_TYPE_INT:
    i1 = atoi(buf);
    if (i1 == fld.valueInt) goto wrapup;
    // printf("Value Changed %s %d %d\n",name,i1,fld.valueInt);
    fld.valueDbl = d1;
    break;
    
  default:
    goto wrapup;
  }
  
  // And update it
  VDatFldUpdAllAttrs(&nodeID,&fld,1);
  // *uCnt = *uCnt + 1;
  // printf("Updated %s\n",fld.name);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Deletes the file if it was last used on the
 * preceding day
 */
static IGRstat emptyFile(IGRchar *fileName)
{
  IGRstat retFlag = 1;

  struct stat fileStat;
  time_t current_time;

  IGRchar buf[128];
  
  // Check the status, return if it's empty
  fileStat.st_size = 0;
  stat(fileName,&fileStat);
  if (fileStat.st_size < 1) goto wrapup;

  // Current time
  time(&current_time);

  // Set the cutoff at 4 hours
  if ((current_time - fileStat.st_mtime) > 14400) {
    sprintf(buf,"/bin/rm %s",fileName);
    system (buf);
    goto wrapup;
  }

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

  
/* -----------------------------------------------
 * Validation check of the attributes when
 * a set is first made active
 */
IGRstat VDatCheckBaseAttributes(TGRid *setID)
{
  IGRstat retFlag = 1;
  IGRstat sts;
  
  IGRchar setName[64];
  IGRchar setType[64];
  TGRid   nodeID;
  
  IGRint  uCnt = 0;
  IGRint  xCnt = 0;

  IGRchar buf[256];
  
  FILE *file;
  
  VDosnum osnum;
  
  // Arg check
  if (setID == NULL) goto wrapup;
  VDatGetSetType(setID,setType);
  VDatGetSetName(setID,setName);
  if ((*setType == 0) || (*setName == 0)) goto wrapup;

  // Empty file if required
  emptyFile("attr.log");
  
  // Only check sets in the active files
  ex$get_cur_mod(osnum = &osnum);
  if (setID->osnum != osnum) goto wrapup;
  
  // Any attr file
  file = fopen("attr.log","rt");
  if (file == NULL) goto wrapup;
  
  // Turn off logging
  dontLogAttrs = 1;

  // Speed up things a bit by skipping node checks
  nodeID.objid == NULL_OBJID;
  
  // Cycle through
  while(fgets(buf,sizeof(buf),file)) {
    VDatCheckBaseAttribute(setID,setType,setName,&nodeID,&uCnt,&xCnt,buf);
  }
  fclose(file);
  
  // Turn logging back on
  dontLogAttrs = 0;
  
  // Status
  if ((uCnt) || (xCnt)) {  
    sprintf(buf,"User Attrs %d, System Attrs %d",uCnt,xCnt);
    UI_status(buf);
    fprintf(stdout,"%s\n",buf);
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Just recurse through and see if any nodes
 * have invalid attributes
 *
 * Fix any invalid attributes
 *
 * It's assumed that this is called when an active set
 * is selected
 */
void VDatCheckBaseAttrs(TGRid *baseID)
{
  TVDatFld flds[VDAT_FLD_MAX];
  IGRint   cnt;
  IGRint   i;
  
  TGRid childID;
  
  // Arg check
  if ((baseID == NULL) || (baseID->objid == NULL_OBJID)) goto wrapup;

  // Flags
  invalidAttributeFlag = 0;
  dontLogAttrs = 1;

  VDatFldGetAllAttrs(baseID,flds,&cnt);

  if (invalidAttributeFlag) {
    VDatFldUpdAllAttrs(baseID,flds,cnt);
  }
  
  // Check kids
  for(i = 0; VDatGetChildObject(baseID,i,&childID); i++) {
    VDatCheckBaseAttrs(&childID);
  }
  
 wrapup:
  dontLogAttrs = 0;
  return;
}

end implementation VDatBase;






