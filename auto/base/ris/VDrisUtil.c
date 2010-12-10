/* $Id: VDrisUtil.c,v 1.2 2001/02/11 17:59:46 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdris/c/VDrisUtil.c
 *
 * Description: Ris utility routines
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDrisUtil.c,v $
 * Revision 1.2  2001/02/11 17:59:46  ahundiak
 * Renamed VDris2 to VDrisc
 *
 * Revision 1.1  2001/02/01 21:58:19  ahundiak
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/01/01  ah      Header
 *
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDrisc.h"
#include "VDnfmc.h"

#include "risapp.h"

/* -----------------------------------------------
 * Initialize info structure
 */
int VDrisInitInfo(TVDrisInfo *info) 
{
  if (info) memset(info,0,sizeof(TVDrisInfo));
  return 1;
}

/* -----------------------------------------------
 * Free info structure
 */
int VDrisFreeInfo(TVDrisInfo *info) 
{
  int i,j;
  
  if (info == NULL)      return 0;
  if (info->buf == NULL) return 1;
  
  j = info->rows * info->cols;
  for(i = 0; i < j; i++) {
    if (info->buf[i]) free(info->buf[i]);
  }
  free(info->buf);
  
  memset(info,0,sizeof(TVDrisInfo));
  return 1;
}

/* -----------------------------------------------
 * Close a schema, not really sure what to do yet
 */
int VDrisCloseSchema()
{
  return 1;
}

/* -----------------------------------------------
 * If a schema is open, return the name
 */
int VDrisGetOpenSchema(char *schema)
{
  int retFlag = 0;
  
  if (schema == NULL) goto wrapup;
  *schema = 0;
  
  RISget_default_schema_name(schema);
  if (*schema == 0) goto wrapup;
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * True if the user is logged
 * Optional warning in UI_status
 */
IGRint VDrisIsLoggedIn(IGRint warn, IGRint *flag)
{
  IGRint sts;

  // Actually check for open schema
  sts = VDrisIsSchemaOpen();

  if (flag) *flag = sts;
  
  if (warn & 1) {
    if (!(sts & 1)) {
//      UI_status("User is NOT logged into PDM");
    }
  }  
  return sts;
}

/* -----------------------------------------------
 * Get the schema to use if none is available
 */
int VDrisGetLazySchema(char *schema)
{
  int retFlag = 0;
  char *p;
  
  // Arg check
  if (schema == NULL) goto wrapup;
  *schema = 0;
  
  // Try env
  p = getenv("ISDP_SCHEMA");
  if (p) {
    strcpy(schema,p);
    retFlag = 1;
    goto wrapup;
  }
  
  // None

 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Given a schema name and password, open it
 */
int VDrisOpenSchema(char *a_schema)
{
  int retFlag = 0;
  
  int  sts;
  char sql[128];

  char schema  [128];
  char schemax [128];
  char password[128];
  char *p;
  
  char buf[128];
  
  int i;
  
  // Passed or use isdp schema
  *schema = 0;
  if (a_schema) strcpy(schema,a_schema);
  else          VDrisGetLazySchema(schema);

  // Need someting
  if (*schema == 0) goto wrapup;

  // Drop any password
  p = strchr(schema,'.');
  if (p) *p = 0;

  // See if already opened
  VDrisGetOpenSchema(schemax);
  if (!strcmp(schema,schemax)) {
    retFlag = 1;
    goto wrapup;
  }

  // Grab the password
  //VDnfmGetSchemaPassword(schema,password);
  if (*password == 0) {
    sprintf(buf,"Invalid schema name %s",schema);
   // UI_status(buf);
    goto wrapup;
  }

  // Build it
  sprintf(sql,"default schema %s.%s",schema,password);
  sprintf(buf,"Opening Schema %s...",schema);
  // UI_status(buf);
  
  // Try as many as three times
  for(i = 0; i < 3; i++) {
    sts = VDrisExecuteSilent(sql);
    if (sts & 1) {

      // Done
      sprintf(buf,"Opened  Schema %s",schema);
      // UI_status(buf);
      retFlag = 1;
      goto wrapup;
    }
  }
  
  // Give up
  sprintf(buf,"Could Not Open Schema %s",schema);
  // UI_status(buf);

 wrapup:
  return retFlag;
}
