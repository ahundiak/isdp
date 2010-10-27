/* $Id: VDEqSetUp.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDEqSetUp.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDEqSetUp.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
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
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/* File to use with set up of equipment */

#ifndef VDeqSetUp_include
#define VDeqSetUp_include

#define EQUIP_SET_UP_NAME ":IGENOD:EquipSetUp"   /* Where is compart object */
#define TAG_ATT_STR     "AttDriveTag"       /* Name of attribute driving symb*/
#define TAGNUMB_STR     "EquiTagNb"
#define SETUP_FILE_NAME  "EquipSetup"
#define SAVESTAT_STR     "SaveStatic"

/* Gadget of the form*/

#define G_TAGATT      44
#define G_TAG         12
#define G_DB_LIST     13
#define G_PPL_ATT     16
#define G_SAVE_STATIC 19

#endif
