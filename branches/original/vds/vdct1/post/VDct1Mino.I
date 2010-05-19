 /* $Id: VDct1Mino.I,v 1.3 2001/02/11 17:46:16 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/set/VDct1Mino.I
 *
 * Description: Set Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Mino.I,v $
 *      Revision 1.3  2001/02/11 17:46:16  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.2  2001/01/12 14:42:54  art
 *      sp merge
 *
# Revision 1.2  2000/08/16  21:00:02  pinnacle
# ah
#
# Revision 1.1  2000/04/20  18:50:16  pinnacle
# Created: vds/vdct1/post/VDct1Mino.I by pnoel for Service Pack
#
# Revision 1.3  2000/03/28  16:13:40  pinnacle
# pn.
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/28/00  pn      Creation/added DB lookup for tree number
 * 08/15/00  ah      These needs to use standard ris query routines
 *                   Convert them for sp15
 *                   For now use vdris$IsLoggedIn() to test
 ***************************************************************************/

class implementation VDct1Base;

#include "VDris.h"
#include "VDrisc.h"

#define VDCT1_RDB_TBL_OST_MINO_INDEX "ost_mino_index"
#define VDCT1_RDB_TBL_TM_TREE_INDEX  "TM_TREE_INDEX"
#define VDCT1_RDB_TBL_TM_CODE_LIST   "TM_CODE_LIST"
#define VDCT1_RDB_FLD_LOCKED         "locked"
#define VDCT1_RDB_FLD_HULL_NUM       "hull_num"
#define VDCT1_RDB_FLD_UNIT_NUM       "unit_num"
#define VDCT1_RDB_FLD_GROUP_CODE     "group_code"
#define VDCT1_RDB_FLD_MINO_INDEX     "mino_index"
#define VDCT1_RDB_FLD_TREE_NUM       "TREE_NUM"


static int traceFlag;
/* ------------------------------------------
 * Updates an existing row in the mino index table
 * Up to calling routine to make sure that a row
 * already exists
 */
IGRstat VDct1GetNextTreeNumber(IGRint *Index)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  num, nextNum;
  IGRchar sql[256];
  IGRchar **buf = NULL;
  IGRint  rows,cols;
  IGRint traceFlag = 0;
 
  // Say hi
  if (traceFlag) {
    printf(">>> VDct1GetNextTreeNumber \n");
  }

  // Arg check
  if (Index == NULL) goto wrapup;
  *Index = 0;
  
  // Make sure logged in
  sts = vdris$IsLoggedIn();
  if (!(sts & 1)) goto wrapup;

  strcpy(sql,"select tree_num from tm_tree_index;");
  rows = cols = 0; buf = NULL;

  sts = VDSsql_query(sql, &cols, &rows, &buf);
  if (rows != 1) {
    printf("*** Invlaid number of rows in tm_tree_index\n");
    goto wrapup;
  }
  
  //num = atoi(buf[0]);
  num = atoi(buf[0]);
  

  nextNum = num + 1;
  *Index = num;
 
  
  // Update statement
  

  sprintf(sql,"update tm_tree_index set tree_num = %d;\n",nextNum); 
  sts = VDSexecute_sql_stmt(sql);
  if (!(sts & 1)) goto wrapup;
  
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< VDct1GetNextTreeNumber %d\n",retFlag);
  }
  // clean up everything
  if (buf) VdsRisFreeBuffer(buf, rows * cols);
  return retFlag;
}
/* ------------------------------------------
 * Updates an existing row in the mino index table
 * Up to calling routine to make sure that a row
 * already exists
 */
IGRstat VDct1PostUpdateMinoIndex(IGRchar *hullNum,
				 IGRchar *unitNum,
				 IGRchar *groupCode,
				 IGRint   minoIndex)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar sql[256];
  
  // Arg check
  if ((hullNum == NULL) || (unitNum == NULL) || (groupCode == NULL)) goto wrapup;

  // Say hi
  if (traceFlag) {
    printf(">>> VDct1PostUpdateMinoIndex %s,%s,%s,%d\n",hullNum,unitNum,groupCode,minoIndex);
  }

  // Make sure logged in
  sts = VDSverify_login();
  if (!(sts & 1)) goto wrapup;
   
  // Update statement
  sprintf(sql,
	  "Update %s set %s = %d where\n"
	  "%s = '%s' and %s = '%s' and %s = '%s';\n",
	  VDCT1_RDB_TBL_OST_MINO_INDEX,
	  VDCT1_RDB_FLD_MINO_INDEX,
	  minoIndex,
	  VDCT1_RDB_FLD_HULL_NUM,  hullNum,
	  VDCT1_RDB_FLD_UNIT_NUM,  unitNum,
	  VDCT1_RDB_FLD_GROUP_CODE,groupCode);
  sts = VDSexecute_sql_stmt(sql);
  if (!(sts & 1)) goto wrapup;
  
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< VDct1PostUpdateMinoIndex %d\n",retFlag);
  }
  return retFlag;
}
/* ------------------------------------------
 * Inserts new row into the mino index table
 * Up to calling routine to make sure that a row
 * does not already exist
 */
IGRstat VDct1PostInsertMinoIndex(IGRchar *hullNum,
				 IGRchar *unitNum,
				 IGRchar *groupCode,
				 IGRint   minoIndex)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar sql[256];
  
  // Arg check
  if ((hullNum == NULL) || (unitNum == NULL) || (groupCode == NULL)) goto wrapup;

  // Say hi
  if (traceFlag) {
    printf(">>> VDct1PostInsertMinoIndex %s,%s,%s,%d\n",hullNum,unitNum,groupCode,minoIndex);
  }

  // Make sure logged in
  sts = VDSverify_login();
  if (!(sts & 1)) goto wrapup;

  // Insert statement
  sprintf(sql,
	  "insert into %s values (0,'%s','%s','%s',%d);",
	  VDCT1_RDB_TBL_OST_MINO_INDEX,
	  hullNum,unitNum,groupCode,minoIndex);
  sts = VDSexecute_sql_stmt(sql);
  if (!(sts & 1)) goto wrapup;
  
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< VDct1PostInsertMinoIndex %d\n",retFlag);
  }
  return retFlag;
}

/* ------------------------------------------
 * Wrapper to get current mino index
 * A row in the table is created if none exists
 */
IGRstat VDct1PostGetMinoIndex(IGRchar *hullNum,
			      IGRchar *unitNum,
			      IGRchar *groupCode,
			      IGRint  *a_minoIndex,
			      IGRint  *a_locked)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar sql[256];

  IGRchar **buf = NULL;
  IGRint  rows,cols;

  IGRint  minoIndex = 0;
  IGRint  locked = 0;
  
  // Arg check
  if (a_minoIndex) *a_minoIndex = 0;
  if (a_locked)    *a_locked = 0;
  
  if ((hullNum == NULL) || (unitNum == NULL) || (groupCode == NULL)) goto wrapup;

  // Say hi
  if (traceFlag) {
    printf(">>> VDct1PostGetMinoIndex %s,%s,%s\n",hullNum,unitNum,groupCode);
  }

  // Make sure logged in
  sts = VDSverify_login();
  if (!(sts & 1)) goto wrapup;

  // Query
  sprintf(sql,
	  "Select %s,%s from %s where\n"
	  "%s = '%s' and %s = '%s' and %s = '%s';\n",
	  VDCT1_RDB_FLD_LOCKED,
	  VDCT1_RDB_FLD_MINO_INDEX,
	  VDCT1_RDB_TBL_OST_MINO_INDEX,
	  VDCT1_RDB_FLD_HULL_NUM,  hullNum,
	  VDCT1_RDB_FLD_UNIT_NUM,  unitNum,
	  VDCT1_RDB_FLD_GROUP_CODE,groupCode);

  rows = cols = 0; buf = NULL;
  sts = VDSsql_query(sql, &cols, &rows, &buf);

  switch(rows) {

  case 0: 
    VDct1PostInsertMinoIndex(hullNum,unitNum,groupCode,0);
    break;

  case 1: 
    locked    = atoi(buf[0]);
    if (a_locked) *a_locked = locked;
    
    minoIndex = atoi(buf[1]);
    if (a_minoIndex) *a_minoIndex = minoIndex;

    break;

  default:
    printf("*** Multiple mino index rows for %s,%s,%s\n",hullNum,unitNum,groupCode);
    goto wrapup;
  }
  
  retFlag = 1;
  
wrapup:
  if (buf) VdsRisFreeBuffer(buf, rows * cols);
  if (traceFlag) {
    printf("<<< VDct1PostGetMinoIndex %d,%d,%d\n",minoIndex,locked,retFlag);
  }
  return retFlag;
}

/* ------------------------------------------
 * Dump the mino index table for debugging
 */
IGRstat VDct1PostDumpMinoIndex()
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar sql[256];

  IGRchar **buf = NULL;
  IGRint  rows,cols,i,j;

  // Say hi
  if (traceFlag) {
    printf(">>> VDct1PostDumpMinoIndex\n");
  }
  // Make sure logged in
  sts = VDSverify_login();
  if (!(sts & 1)) goto wrapup;

  // Query
  sprintf(sql,
	  "Select %s,%s,%s,%s,%s from %s order by %s,%s,%s;\n",
	  VDCT1_RDB_FLD_LOCKED,
	  VDCT1_RDB_FLD_HULL_NUM,
	  VDCT1_RDB_FLD_UNIT_NUM,
	  VDCT1_RDB_FLD_GROUP_CODE,
	  VDCT1_RDB_FLD_MINO_INDEX,

	  VDCT1_RDB_TBL_OST_MINO_INDEX,

	  VDCT1_RDB_FLD_HULL_NUM,
	  VDCT1_RDB_FLD_UNIT_NUM,
	  VDCT1_RDB_FLD_GROUP_CODE);
  
  rows = cols = 0; buf = NULL;
  sts = VDSsql_query(sql, &cols, &rows, &buf);

  if (cols < 5) {
    printf("*** %s table does not have 5 columns\n",
	   VDCT1_RDB_TBL_OST_MINO_INDEX);
    goto wrapup;
  }
  printf("-------- %s %d ----------\n",VDCT1_RDB_TBL_OST_MINO_INDEX,rows);
  for(i = 0; i < rows; i++) {
    j = (i*cols);
    printf("%d %s %-8s %-8s %-8s %3s\n",
	   i,buf[j+0],buf[j+1],buf[j+2],buf[j+3],buf[j+4]);
    
  }

  // Done
  retFlag = 1;
  
wrapup:
  if (buf) VdsRisFreeBuffer(buf, rows * cols);
  if (traceFlag) {
    printf("<<< VDct1PostDumpMinoIndex\n");
  }
  return retFlag;
}

/* ------------------------------------------
 * Wrapper to get next mino index
 * Updates the table
 */
IGRstat VDct1PostGetNextMinoIndex(IGRchar *hullNum,
				  IGRchar *unitNum,
				  IGRchar *groupCode,
				  IGRint  *a_minoIndex)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRint  minoIndex = 0;
  IGRint  locked = 0;
  
  traceFlag = 0;
  
  // Arg check
  if (a_minoIndex == NULL) goto wrapup;
  *a_minoIndex = 0;
  if ((hullNum == NULL) || (unitNum == NULL) || (groupCode == NULL)) goto wrapup;

  // Get the current number
  sts = VDct1PostGetMinoIndex(hullNum,unitNum,groupCode,&minoIndex,&locked);
  if (!(sts & 1)) goto wrapup;
  
  // Make sure it is not locked
  if (locked) goto wrapup;
  
  // Inc it
  minoIndex = minoIndex + 1;
  sts = VDct1PostUpdateMinoIndex(hullNum,unitNum,groupCode,minoIndex);
  if (!(sts & 1)) goto wrapup;
  
  // Done
  *a_minoIndex = minoIndex;
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------
 * Wrapper to free mino index if it is the
 * Last number used
 */
IGRstat VDct1PostFreeMinoIndex(IGRchar *hullNum,
			       IGRchar *unitNum,
			       IGRchar *groupCode,
			       IGRint   a_minoIndex)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint minoIndex;
  IGRint locked;
  
  // Arg check
  if ((hullNum == NULL) || (unitNum == NULL) || (groupCode == NULL)) goto wrapup;

  // Get the current number
  sts = VDct1PostGetMinoIndex(hullNum,unitNum,groupCode,&minoIndex,&locked);
  if (!(sts & 1)) goto wrapup;
  
  // Only free if it is the same
  if (minoIndex != a_minoIndex) goto wrapup;
  if (minoIndex < 1) goto wrapup;
  if (locked) goto wrapup;
  
  // Come off one
  minoIndex--;
  sts = VDct1PostUpdateMinoIndex(hullNum,unitNum,groupCode,minoIndex);
  if (!(sts & 1)) goto wrapup;
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

end implementation VDct1Base;





