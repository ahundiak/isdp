/* $Id: VDrisTable.c,v 1.3 2002/05/09 17:45:23 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDris.I
 *
 * Description:	RIS Interface
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDrisTable.c,v $
 * Revision 1.3  2002/05/09 17:45:23  ahundiak
 * ah
 *
 * Revision 1.2  2001/02/11 17:59:46  ahundiak
 * Renamed VDris2 to VDrisc
 *
 * Revision 1.1  2001/02/01 21:58:19  ahundiak
 * ah
 *
 * Revision 1.3  2001/01/11 16:34:30  art
 * sp merge
 *
 * Revision 1.1  2001/01/11 16:20:58  art
 * s merge
 *
 * Revision 1.1  2000/12/06  16:29:54  pinnacle
 * ah
 *
# Revision 1.1  2000/12/06  14:53:10  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/28/00  ah      Creation
 * 12/06/00  ah      Use VDrsx interface
 ***************************************************************************/
/* -----------------------------------------------
 * Swap out the calls to the VDS routines to use the
 * new standalone VDrsx routines.
 *
 * If this works ok then eventually migrate all code to
 * VDrsx system.
 *
 * If it blows up, the go back to VDris.I in the om directory
 */
#include "VDtypedefc.h"
#include "VDrisc.h"
#include "VDnfmc.h"
#include "VDassert.h"

VDASSERT_FFN("vdah/c/VDris.c");

/* -----------------------------------------------
 * RIS Query for column names and types
 * Does not init ris, maybe it should???
 */
IGRstat VDrisQryTableColumns(TVDrisInfo *ris, IGRchar *table_name)
{
  VDASSERT_FN("VDrisQryTableColumns");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  VDASSERTW(ris); ris->rows = 0;
  VDASSERTW(table_name && *table_name);

  // Try the database
  sprintf(ris->sql,
	  "Select %s,%s,%s,%s,%s from %s where %s='%s' order by %s;",
	  VDRIS_COLN_COLUMNS_NAME,
	  VDRIS_COLN_COLUMNS_TYPE,
	  VDRIS_COLN_COLUMNS_TYPES,
	  VDRIS_COLN_COLUMNS_LEN,
	  VDRIS_COLN_COLUMNS_POS,
	  VDRIS_TBLN_COLUMNS,
	  VDRIS_COLN_COLUMNS_TABLE,
	  table_name,
	  VDRIS_COLN_COLUMNS_POS);
  
	  
  // retFlag = VDrisQuery(ris,NULL);
  VDrisQueryCache(VDRIS_CACHE_VDS,ris,NULL);

  retFlag = 1;

 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Utility routine to just list the columns in a table
 */
IGRstat VDrisListTableColumns(IGRchar *table_name)
{
  VDASSERT_FN("VDrisListTableColumns");
  IGRstat retFlag = 0;
  TVDrisInfo ris;
  
  VDASSERTW(table_name && *table_name);
  
  printf("----- Table %s ------\n",table_name);
  
  VDrisInitInfo(&ris);
  VDrisQryTableColumns(&ris,table_name);

  for(ris.i = 0; ris.i < ris.rows; ris.i++) {
    ris.j = ris.i * ris.cols;
    printf("%2d %-19s %s %-9s %-3s\n",ris.i,
	   ris.buf[ris.j+VDRIS_COLI_COLUMNS_NAME],
	   ris.buf[ris.j+VDRIS_COLI_COLUMNS_TYPE],
	   ris.buf[ris.j+VDRIS_COLI_COLUMNS_TYPES],
	   ris.buf[ris.j+VDRIS_COLI_COLUMNS_LEN]);
  }
  
  VDrisFreeInfo(&ris);

  retFlag = 1;
  
 wrapup:
  return retFlag;
}







