/* $Id: VDdbgAssert.h,v 1.1 2001/07/16 13:32:33 jdsauby Exp $  */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/include/VDdbgAssert.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      07/06/01        jds		File Creation.
 * -------------------------------------------------------------------*/

#define DBG_PROD_NAME  "Vds"

#define DBG_PROD	0x0000001

extern long  DBG_Gb_dbg;
extern FILE *DBG_Gb_Fp;

extern long  VDdbg_Gb_Set();
extern long  VDdbg_Gb_Unset();

