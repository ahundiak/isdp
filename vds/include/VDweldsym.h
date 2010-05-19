/* $Id: VDweldsym.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include/VDweldsym.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDweldsym.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/11/21  17:16:58  pinnacle
 * Created: include/VDweldsym.h by impd for vds
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	11/21/97	  HF		Used by vds/vdweld/ functionality
 *					Override at VDS level of some COweld methods :
 *						init, execute, LC_selection
 *					Cooperates with file $VDS/config/weld_symbols in order
 *					to make placement of Welding Symbols user customizable
 * -------------------------------------------------------------------*/

#ifndef VDweldsym_include
#define VDweldsym_include

# define	DESC_SIZE		(40)
# define	MAX_WLD_SYM_SZ		(20)

struct VDweld_gadget_sym
{
  IGRshort	index, bezel, symbol, fill, type[4], snr[2];
  IGRchar	desc[DESC_SIZE];
};

#endif
