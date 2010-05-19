/* $Id: VDNewEquiDef.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDNewEquiDef.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDNewEquiDef.h,v $
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

#ifndef VDNewEquiDef_include
#define VDNewEquiDef_include


/* The goal of this include is to add a new structure used by the equipment.
 * Unfortunatly, it is not add to the VDSequipdef.h because it requests that
 * the include file VDScheckdef.h be also include. Therefore to avoid to 
 * modify all the files including VDSequipdef.h a new include has been added.
 */
 

/* Depend on the include "VDScheckdef" */


struct VDConInfo
  {
   struct VDConnEntity	Entity;
   IGRshort		MatrixType;
   IGRdouble		Matrix[16];
  };


#endif
