/* $Id: VDintf.S,v 1.1.1.1 2001/01/04 21:08:52 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdintf/cmd / VDintf.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDintf.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:52  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/08/04  16:59:22  pinnacle
# Created: vdintf/cmd/VDintf.S by jwfrosch for vds
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	08/16/94	HF		Partial rewrite to COB (except for execute method)
 *					Added Options Form capability
 *
 * -------------------------------------------------------------------*/

class specification VDintf (1:0) of VDS_LOCATE;

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

instance VDintf
{
    IGRint			num_located;		/* total num elements	*/
    IGRint			num_ornted;
    IGRint			num_sets;
    variable IGRint		num_in_set[2];
    variable struct GRlc_info	set_info[2];
    struct GRlc_stack		locate_stack;		/* for locate purposes	*/
    struct GRevent		locate_event;		/* for locate purposes	*/
    variable struct GRlc_info	locate_info[2];		/* located eleinfo	*/
    variable IGRboolean		reversed[2];
    IGRchar			filename[MAX_CHAR],
				savefile[MAX_CHAR];
    IGRboolean			add_to_set,
				stdreportonly,
				nocurves,
				novol,
				noarea,
				plpts_input;
    IGRpoint			points[4];
    IGRpoint			plane_point;
    IGRvector			plane_normal;
    struct IGRplane		plane;

	    /* Instance variables added for VDS processing */

    int				my_action;
    int				tot_nr_fls;		/* Total number of Active + Ref. files	*/
    variable unsigned char	ac_rpr[2];		/* to save the VDS repr of objects	*/
    variable struct VDref_rep	ref_rpr[2];		/* VDS repr to be used with reffiles	*/

    variable IGRint		sav_nm_in_set[2];	/* saved num_in_set info	*/
    variable struct GRlc_info	sav_locat_info[2];	/* saved locate_info		*/
    IGRint			sav_nm_located;		/* saved total nr of elements	*/

    IGRboolean			remove_flag;
    IGRboolean			status_form_initialized;
};

override wakeup;
override sleep;
override delete;
override execute;
override form_notification;
override status_disp;

message VDintf_init               ( long * sts );
message VDintf_reset_repr         ( long * sts );
message VDintf_modif_repr         ( long * sts );
message VDintf_sav_locat_info     ( long * sts );
message VDintf_restore_locat_info ( long * sts );

end specification VDintf;
