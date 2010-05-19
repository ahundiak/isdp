/* $Id: VDSFilter.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / VDSFilter.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSFilter.h,v $
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


/****************************************************************************


                File:   VDSFilter.h
                Type:   c include file
                Use:    Defines constants for I/VDS form filter interface
                Date:   07 December 1992 - Genesis -
                Autr:   adz - isdc

 History :

                   R. Manem     Added filter vds_get_event_with_dynamics

***************************************************************************/

#ifndef VDSFilter_include

#define VDSFilter_include

  /*
   * VDS filters are:
   *	_vds_get_event		11	(1)	_get_event
   *	_vds_wfi		12	(2)	_wfi
   *	_vds_locate		13	(3)	_gr_locate
   *	_vds_locate_noauto	14	(4)	_gr_locate_noauto
   *	_vds_gs_locate		15	(5)	_gs_locate
   *	_vds_locate_event3	16	(6)	_gr_locate_event3
   *	_vds_menu		17	(7)	_menu
   *	_vds_locate_noauto_event3 18	(8)	_gr_locate_noauto_event3
   *	_vds_gs_locate_noauto	19	(9)	_gs_locate_noauto
   *    _vds_get_event_with_dynamics 20
   */

/*
 * constants to be used in the filter method command
 */

#define		_vds_get_event		11
#define		_vds_wfi		12
#define		_vds_locate		13
#define		_vds_locate_noauto	14
#define		_vds_gs_locate		15
#define		_vds_locate_event3	16
#define		_vds_menu		17
#define		_vds_locate_noauto_event3 18
#define		_vds_gs_locate_noauto	19
#define		_vds_get_event_with_dynamics	20


/*
 * constants to be used in the command object files
 */

#define		vds_get_event		11
#define		vds_wfi			12
#define		vds_locate		13
#define		vds_locate_noauto	14
#define		vds_gs_locate		15
#define		vds_locate_event3	16
#define		vds_menu		17
#define		vds_locate_noauto_event3 18
#define		vds_gs_locate_noauto	19
#define		vds_get_event_with_dynamics	20


#endif
