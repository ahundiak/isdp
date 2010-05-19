
/* $Id: VDahFrm.I,v 1.3 2001/01/11 16:34:31 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/
 *
 * Description: forms toolit
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDahFrm.I,v $
 *      Revision 1.3  2001/01/11 16:34:31  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 16:20:58  art
 *      s merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1998/02/20  23:55:02  pinnacle
# AssyTree
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/25/97  ah      creation
 * 02/20/98  ah      use VI wrappers
 ***************************************************************************/

class implementation Root;

#include "VDmaster.h"
#include "VDahFrm.h"

/* ------------------------------------------
 * Gets the form's position from a file
 */
IGRstat VDahFrmLoadPositionFromFile(Form form)
{
  IGRstat retFlag = 0;
  
  IGRchar name[128],*pnt;
  IGRint  x,y;

  FILE   *file = NULL;
  IGRchar buf[128];

  // Arg check
  if (form == NULL) goto wrapup;

  // Form information
  *name = 0;
  VIf_get_name(form,name);
  if (*name == 0) goto wrapup;

  // Open file
  file = fopen(".VDahFrmMgr","r");
  if (file == NULL) goto wrapup;

  // Find the attribute
  while(fgets(buf,sizeof(buf),file)) {
    pnt = strchr(buf,' ');
    if (pnt) *pnt = 0;
    if ((strcmp(name,buf) == 0) && (pnt)) {
      pnt++;
      x = atoi(pnt);
      y = 0;
      pnt = strchr(pnt,',');
      if (pnt) y = atoi(pnt+1);
      VIf_set_location(form,x,y);
      retFlag = 1;
      goto wrapup;
    }
  }

wrapup:
  if (file) fclose(file);
  return retFlag;
}

/* ----------------------------------------
 * Saves the form's position in a file
 */
IGRstat VDahFrmSavePositionInFile(Form form)
{
  IGRstat retFlag = 0;

  IGRchar name[128];
  IGRint  x,y,found;

  FILE    *fileIn  = NULL;
  FILE    *fileOut = NULL;
  IGRchar  buf[128],*pnt;

  // Arg check
  if (form == NULL) goto wrapup;

  // Form information
  *name = 0;
  VIf_get_name(form,name);
  if (*name == 0) goto wrapup;
  
  x = y = 0;
  VIf_get_location(form,&x,&y);

  // Open files
  fileIn  = fopen(".VDahFrmMgr", "r");
  fileOut = fopen(".VDahFrmMgrX","w");
  if (fileOut == NULL) goto wrapup;
  
  // Cycle through
  found = 0;
  while((fileIn != NULL) && (fgets(buf,sizeof(buf),fileIn))) {

    pnt = strchr(buf,' ');
    if (pnt) {
      *pnt = 0;
      if (strcmp(name,buf) == 0) {

        // Got a match
        found = 1;
        sprintf(buf,"%s %d,%d\n",name,x,y);
      }
      else *pnt = ' ';
    }
    fputs(buf,fileOut);
  }

  // Append if not found
  if (found == 0) {
    fprintf(fileOut,"%s %d,%d\n",name,x,y);
  }

  // Close up
  if (fileIn) fclose(fileIn);
  fclose(fileOut);
  
  // Rename
  remove(".VDahFrmMgr");
  rename(".VDahFrmMgrX",".VDahFrmMgr");

  retFlag = 1;
wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Finds all selected ids in gadget
 * col is the selected column
 * col +1 containd the id's
 */
IGRstat VDahFrmGetIDvla(
  Form      form,
  IGRint    gadget,
  IGRint    col,
  TVDvlaID *objVLA
)
{
  IGRstat retFlag = 0;
  IGRint  row,rowMax,sel;
  TGRid   rowID;

  rowMax = -1;
  VIfld_get_num_rows(form,gadget,&rowMax);

  for(row = 0; row < rowMax; row++) {

    VIfld_get_select(form,gadget,row,col,&sel);
    if (sel == 1) {

      rowID.objid = NULL_OBJID;
      VDahFrmGetGRid(form,gadget,row,col+1,&rowID);
      if (rowID.objid != NULL_OBJID) {
        VDvlaID_Append(objVLA,&rowID);
        // VDbroPrintObj(&rowID);
      }
    }
  }

  retFlag = 1;

  return retFlag;
}

IGRstat VDahFrmSetTextRC(
  Form     form, 
  IGRint   gadget, 
  IGRint   row,
  IGRint   col,
  IGRchar *text
)
{
  VIfld_set_text(form,gadget,row,col,text,0);
  return 1;
}

IGRstat VDahFrmGetTextRC(
  Form     form, 
  IGRint   gadget, 
  IGRint   row,
  IGRint   col,
  IGRchar *text
)
{
  IGRint  sel,pos;
  IGRchar buf[256];

  *buf = 0;

  VIfld_get_text(form,gadget,row,col,256,buf,&sel,&pos);

  strcpy(text,buf);

  return 1;
}

IGRstat VDahFrmSetStatus(Form form, IGRchar *text)
{
  VIg_set_text(form,10,text);
  return 1;
}

IGRstat VDahFrmGRidToString(TGRid *objID, IGRchar *str)
{
  sprintf(str,"%d-%d",objID->osnum,objID->objid);
  return 1;
}

IGRstat VDahFrmStringToGRid(IGRchar *str, TGRid *objID)
{
  IGRstat retFlag = 0;
  
  objID->objid = NULL_OBJID;
  objID->osnum = atoi(str);

  str = strchr(str,'-');
  if (str == NULL) goto wrapup;

  objID->objid = atoi(str+1);

  retFlag = 1;

wrapup:
  return retFlag;
}

IGRstat VDahFrmSetGRid(
  Form   form, 
  IGRint gadget, 
  IGRint row, 
  IGRint col, 
  TGRid *objID
)
{
  IGRstat retFlag = 0;
  IGRchar buf[128];

  *buf = 0;
  VDahFrmGRidToString(objID,buf);
  VIfld_set_text(form,gadget,row,col,buf,0);
 
  retFlag = 1;

  return retFlag;
}

IGRstat VDahFrmGetGRid(
  Form   form, 
  IGRint gadget, 
  IGRint row, 
  IGRint col, 
  TGRid *objID
)
{
  IGRstat retFlag = 0;
  IGRchar buf[256];
  IGRint  sel,pos;

  objID->objid = NULL_OBJID;

  *buf = 0;
  VIfld_get_text(form,gadget,row,col,256,buf,&sel,&pos);
  if (*buf == 0) goto wrapup;

  VDahFrmStringToGRid(buf,objID);
 
  retFlag = 1;

wrapup:
  return retFlag;
}

end implementation Root;













