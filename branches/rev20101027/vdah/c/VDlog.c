/* $Id: VDlog.c,v 1.9 2002/05/06 20:51:41 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDlog.c
 *
 * Description:	Logging routines
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDlog.c,v $
 * Revision 1.9  2002/05/06 20:51:41  ahundiak
 * ah
 *
 * Revision 1.8  2002/05/01 19:51:46  ahundiak
 * ah
 *
 * Revision 1.7  2002/04/24 15:13:11  ahundiak
 * ah
 *
 * Revision 1.6  2001/03/22 14:42:34  ahundiak
 * ah
 *
 * Revision 1.5  2001/03/11 18:34:04  ahundiak
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/11/01  ah      Added header
 *                   Moved static data to VDgbl.c
 * 03/22/01  ah      Check stdOutFlag == 1 for back screen printing
 *                   And commented out unused VDlogPrintX functions
 ***************************************************************************/

/* -----------------------------------------------
 * For now, avoid using assert stuff here as
 * this is very low level stuff and the assert code
 * itself will end up using this stuff
 *
 * Important, avoid using this system during initial startup, there is no
 * provision to allow for changing the size of the cat structure as a 
 * result of a service pack change.  
 *
 * If it's really necessary to use during startup,
 * validate the revFlag
 */
#include "VDtypedefc.h"
#include "VDobj2.h"
#include "VDlog.h"
#include "VDgbl.h"
#include "VDassert.h"

#include "stdarg.h"

// Private catalog of logs structure
typedef struct VDlogCat
{
  struct VDlogCat *next;
  IGRint  revFlag;
  IGRchar cat_name  [32];
  IGRchar file_name[128];
  FILE   *file;
  IGRint  inUse;
  IGRint  priority;
  void (*callback)(IGRint type, IGRchar *buf);
} TVDlogCat;

extern IGRstat VDlogGetNextFreeCat __((TVDlogCat **a_cat));
extern IGRstat VDlogFreeCat        __((TVDlogCat  *a_cat));

/* -----------------------------------------------
 * The global static data (linked list of cats)
 * is stored in vdGblStaticData00
 */

/* -----------------------------------------------
 * Close all categories
 */
IGRstat VDlogCloseAllCats()
{
  IGRstat retFlag = 0;
  TVDlogCat *cat;

  TVDlogCat *cat_list = vdGblStaticData00;
  
  // Cycle through
  for(cat = cat_list; cat; cat = cat->next) {
    VDlogFreeCat(cat);
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Close a category
 */
IGRstat VDlogCloseCat(IGRchar *cat_name)
{
  IGRstat retFlag = 0;
  TVDlogCat *cat;
  TVDlogCat *cat_list = vdGblStaticData00;

  // Arg check
  if ((cat_name == NULL) || (*cat_name == 0)) goto wrapup;

  // Find it
  for(cat = cat_list; cat; cat = cat->next) {
    if (!strcmp(cat->cat_name,cat_name)) {

      // Free it which also closes
      VDlogFreeCat(cat);
      
      // Done
      retFlag = 1;
      goto wrapup;
    }
  }

  // Oops

 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Opens a category for logging
 */
IGRstat VDlogOpenCat(IGRchar *cat_name)
{
  IGRstat retFlag = 0;
  TVDlogCat *cat;
  TVDlogCat *cat_list = vdGblStaticData00;
  
  FILE *file;
  
  // Arg check
  if ((cat_name == NULL) || (*cat_name == 0)) goto wrapup;

  // Make sure not already opened
  for(cat = cat_list; cat; cat = cat->next) {
    if (!strcmp(cat->cat_name,cat_name)) {
      retFlag = 1;
      goto wrapup;
    }
  }

  // Make sure it can be opened
  file = fopen(cat_name,"wt");
  if (file == NULL) goto wrapup;
  
  // Get the next free cat
  VDlogGetNextFreeCat(&cat);
  if (cat == NULL) goto wrapup;
  
  // Set it up
  strcpy(cat->cat_name,cat_name);
  cat->file = file;
  cat->inUse = 1;
  
  // Done
  retFlag = 1;
  
  wrapup:
  return retFlag;
}
/* -----------------------------------------------
 * Opens a category for callback logging
 */
IGRstat VDlogOpenCatCallback(IGRchar *cat_name, void (*callback)(IGRint type, IGRchar *buf))
{
  IGRstat retFlag = 0;
  TVDlogCat *cat;
  TVDlogCat *cat_list = vdGblStaticData00;
  
  FILE *file;
  
  // Arg check
  if ((cat_name == NULL) || (*cat_name == 0)) goto wrapup;
  if (callback == NULL) goto wrapup;
  
  // Make sure not already opened
  for(cat = cat_list; cat; cat = cat->next) {
    if (!strcmp(cat->cat_name,cat_name)) {
      retFlag = 1;
      goto wrapup;
    }
  }

  // Get the next free cat
  VDlogGetNextFreeCat(&cat);
  if (cat == NULL) goto wrapup;
  
  // Set it up
  strcpy(cat->cat_name,cat_name);
  cat->callback = callback;
  cat->inUse = 1;
  
  // Done
  retFlag = 1;
  
  wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Pops the given file up in an editor
 * Update to use direct path to the editor
 */
IGRstat VDlogShowCat(IGRchar *cat_name)
{
  IGRstat retFlag = 0;
  IGRchar edit[ 32];
  IGRchar path[128];
  IGRchar cmd [256];
  IGRchar *p;
  
  // Arg check
  if ((cat_name == NULL) || (*cat_name == 0)) goto wrapup;
  *path = 0;

  // Find the editor
  p = getenv("ISDP_EDIT");
  if (p) strcpy(edit,p);
  else   strcpy(edit,"dtpad");

  if (!strchr(edit,'/')) {
    VDsysFindExeFile(edit,path);
  }
  if (*path == 0) strcpy(path,edit);

  // Do it
  snprintf(cmd,sizeof(cmd),"%s %s &",path,cat_name);
  system  (cmd);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Log an object
 */
IGRstat VDlogPrintObject(IGRint     type, 
			 IGRint     stdOutFlag, 
			 IGRchar    *pre, 
			 TGRobj_env *objOE, 
			 TGRid      *objID)
{
  IGRstat retFlag = 1;
  IGRstat msg;
  
  TGRid theID;

  IGRchar buf[256];
  IGRchar path[128];
  IGRchar *p;
  IGRchar className[32];
  IGRchar macroName[32];
  
  // Pull out the object
  theID.objid = NULL_OBJID;
  if (objOE) theID =  objOE->obj_id;
  if (objID) theID = *objID;
  if (theID.objid == NULL_OBJID) {
    strcpy(buf,"NULL OBJECT");
    goto doit;
  }
  
  // Get some info
  VDobjGetClassName(NULL,&theID,className);
  VDobjGetMacroName(NULL,&theID,macroName);
  VDobjGetPath(     NULL,&theID,path);

  // Start putting together
  snprintf(buf,sizeof(buf),"%d,%d %s",theID.osnum,theID.objid,className);
	    
  // Add macro name
  if ((*macroName) && (strcmp(className,macroName))) {
    strcat(buf," ");
    strcat(buf,macroName);
  }
  
  // Strip ref from the path
  p = strstr(path,":ref:");
  if (p) p += 4;
  else   p = path;
  if (*p) {
    strcat(buf," ");
    strcat(buf,p);
  }
  
doit:
  if (pre) VDlogPrintFmt(type,stdOutFlag,"%s %s",pre,buf);
  else     VDlogPrintFmt(type,stdOutFlag,"%s",buf);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * General purpose logger for buffer
 */
IGRstat VDlogPrintBuf(IGRint type, IGRint stdOutFlag, IGRchar *buf)
{
  IGRstat retFlag = 0;

  TVDlogCat *cat;
  TVDlogCat *cat_list = vdGblStaticData00;
  
  // Arg check
  if (buf == NULL) goto wrapup;

  // Dump to back screen
  if ((stdOutFlag == 1) && (type != VDLOG_STAT))  fprintf(stdout,"%s\n",buf);
  
  // Cycle through
  for(cat = cat_list; cat; cat = cat->next) {
    if (cat->file) {
      if (type != VDLOG_STAT) fprintf(cat->file,"%s\n",buf);
    }
    if (cat->callback) {
      (*cat->callback)(type,buf);
    }
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * General purpose logger
 */
IGRstat VDlogPrintFmt(IGRint type, IGRint stdOutFlag, IGRchar *fmt, ...)
{
  IGRstat retFlag = 0;
   
  IGRchar buf[256];

  TVDlogCat *cat;
  
  va_list ap;
  
  // Buf the message
  va_start(ap,fmt);
  vsnprintf(buf,sizeof(buf),fmt,ap);  
  va_end(ap);

  // Print it
  VDlogPrintBuf(type,stdOutFlag,buf);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}
 
/* -----------------------------------------------
 * Gets the next free catalog structure
 */
IGRstat VDlogGetNextFreeCat(TVDlogCat **a_cat)
{
  IGRstat retFlag = 0;
  TVDlogCat *cat;
  TVDlogCat *cat_list = vdGblStaticData00;
  
  // Arg check
  if (a_cat == NULL) goto wrapup;
  *a_cat = NULL;
    
  // Cycle through list
  for(cat = cat_list; cat; cat = cat->next) {
    if (cat->inUse == 0) {
      *a_cat = cat;
      retFlag = 1;
      goto wrapup;
    }
  }

  // Alloc new one
  cat = calloc(1,sizeof(TVDlogCat));
  if (cat == NULL) {
    printf("*** Unable to allocate new catalog structure\n");
    goto wrapup;
  }

  // Debug
  if (cat_list == NULL) {
    // printf("Allocated first category structure\n");
  }
  
  // Add to list
  cat->next = cat_list;
  vdGblStaticData00 = cat;
  
  // Done
  *a_cat = cat;
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Makes the catalog structure available for reuse
 */
IGRstat VDlogFreeCat(TVDlogCat *a_cat)
{
  IGRstat retFlag = 0;
  TVDlogCat *cat;
  
  // Arg check
  if (a_cat == NULL) goto wrapup;
  
  // Close if open
  if (a_cat->file) fclose(a_cat->file);

  // Hang onto link pointer
  cat = a_cat->next;
  
  // Cleat it
  memset(a_cat,0,sizeof(TVDlogCat));
  a_cat->next = cat;
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

