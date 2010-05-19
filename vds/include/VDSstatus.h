/* $Id: VDSstatus.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / VDSstatus.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSstatus.h,v $
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

/*

	This file contain macro definition vds$show_advance

	History :
*/

#ifndef vdsstatusinclude
#define vdsstatusinclude

#include "msdef.h"

/*
Name
	vds$show_advance

Description

	this macro calls fct VDSshow_advance, which displays in EMS status
	field the advancement of a sequential work.
	
	ARG	IN
	----------

	IGRchar		what[]		string describing action being 
					processed

	IGRchar		unit[]		string describing processed objects
	
	IGRlong		current		current index
	
	IGRlong		max		maximal index
	
	IGRdouble	rel_step	display status every <step>% of work
	
	IGRlong		abs_step	step is in number of elements
					in this case, max need not be specified
	
	IGRshort	dp_type		display mode : dot or number
	
        IGRint          just            justification in the status field

	ARG	IN/OUT
	--------------
	
	IGRlong		*previous	last index where display was done

	
Return Values	NULL
	
*/

#define	VDSDP_BY_NB	0	/* display as absolute number */
#define	VDSDP_BY_PC	1	/* display as percentage */
#define	VDSDP_BY_DOT	2	/* display as dots (one dot per step) */

extern	VDSshow_rel_advance() ;
extern	VDSshow_abs_advance() ;	

#omdef	vds$show_advance (
		what		= "",
		unit		= "",
		previous,
		current,
		max		= 0,
		dp_type		= VDSDP_BY_NB,
		rel_step	= 0.0 ^
		abs_step	= 0 ,
                just            = CENTER_JUS ) ;

#if om$specified(rel_step)
#if om$specified(max)
  VDSshow_rel_advance( what, unit, current, max, rel_step, dp_type, previous, just ) ;
#else
  printf("\nvds\$show_advance : max number of elements not specified\n");
#endif			
#else
  VDSshow_abs_advance( what, unit, current, abs_step, dp_type, previous, just) ;
#endif

#endomdef


#endif
