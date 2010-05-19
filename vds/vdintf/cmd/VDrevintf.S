/* $Id: VDrevintf.S,v 1.1.1.1 2001/01/04 21:08:52 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdintf/cmd / VDrevintf.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDrevintf.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:52  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/08/21  13:36:28  pinnacle
# Replaced: vdintf/cmd/VDrevintf*.[ISt] for:  by jwfrosch for vds
#
# Revision 1.1  1997/08/04  16:59:36  pinnacle
# Created: vdintf/cmd/VDrevintf.S by jwfrosch for vds
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	07/16/97	HF		Command to Review <Assoc> VDS Interferences
 *
 * -------------------------------------------------------------------*/

class specification VDrevintf (1:0) of VDS_LOCATE;

#include	<OMminimum.h>
#include	<OMlimits.h>
#include	<igetypedef.h>
#include	<igrtypedef.h>
#include	<igr.h>
#include	<godef.h>
#include	<gr.h>
#include	<igrdp.h>
#include	<go.h>
#include	<ex.h>
#include	<griodef.h>
#include	<grio.h>
#include	<dp.h>					/* for lc.h */
#include	<lcdef.h>				/* for lc.h */
#include	<lc.h>

#include	<VDintf_rpr.h>		/* struct for storing VDS representation info	*/
#include	<VDintf_rev.h>		/* struct for storing VDS representation info	*/

instance VDrevintf
{
    IGRboolean			stdreportonly;

    IGRint			num_located;		/* total num REAL  VDinterf_cvs macros	*/
    IGRint			num_empty;		/* total num EMPTY VDinterf_cvs macros	*/

    IGRint			curr_indx;		/* Currently selected Interference	*/
    IGRint			fit_check;
    IGRdouble			fit_ratio;

    struct GRid			windowId;

    variable struct VDintf_info	intf_info[1];		/* located eleinfo	*/
    variable struct VDintf_info	intf_copy[1];		/* located eleinfo	*/
};

override wakeup;
override sleep;
override delete;
override form_notification;
override status_disp;

message VDintf_init               ( long * sts );
message VDintf_collect_info       ( long * sts );

message getWindow		  ( long * sts );

end specification VDrevintf;
