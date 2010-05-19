/* $Id: VDSver_part.C,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdris/imp / VDSver_part.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSver_part.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:12  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.2  1996/04/21  23:27:24  pinnacle
 * Replaced: vdris/imp/*.C for:  by v240_int for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	04/19/96   tlb		Add prototypes
 *
 * -------------------------------------------------------------------*/


#include <string.h>
#include <stdio.h>
#include "vdbmacros.h"
#include "v_risproto.h"

#define  MAX_WORD  81  /* 81 because 80 + \0 = 81 */

/*------------------------------------------------------------------*/
int VDSverify_part ( catalog, part_id, revision)

    char  catalog[];       /* Catalog name   (I) */
    char  part_id[];       /* Part id        (I) */
    char  revision[];       /* Revision       (I) */

{
  int   sts;
  char  search[MAX_WORD];
  int   num;
  char  **buf;
  int   n_attr;

  /* ---- Get itemno from table <catalog> */

  sprintf ( search, "n_itemname = '%s' and n_itemrev = '%s'", part_id,revision);
  n_attr = 1;
  sts =
  vdb$RisSelect(  select      =     "n_itemno",
                  table_name  =      catalog,
                  where       =      search,
                  order       =      NULL,
                  group       =      NULL,
                  numselect   =      n_attr,
                  p_numrows   =      &num,
                  p_buffer    =      &buf );
 
  if(sts != 1 || num == 0) return 0;
  vdb$RisFreeBuffer (  buffer  =    buf,
                       size    =    n_attr*num);
  return 1;
}
