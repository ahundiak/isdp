/* $Id: VDequistr.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / VDequistr.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDequistr.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
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

#ifndef VDequistr_include
#define VDequistr_include

/****************************************************************************


		File:	VDequistr.h
		Type:   c include file
		Use:	Defines structure for Equipment Parameters
		Date:	17 April 1990
		
***************************************************************************/


struct VDequip_attr
{
	short		quantity;
	char		source[4];
	char		approval[6];
	char		zone[6];
	double		true_weight;
	char		entity_name[10];
/*	char		entity_type[20]; */
	char		entity_number[20];
	char		remarks[45];
	char		description[80];
};

/***************************************************************************

	Kludge to get Equipment working, as it uses functions in I/ROUTE

***************************************************/
#define 	VD_EQUIP	3

#endif
