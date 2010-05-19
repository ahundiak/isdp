/* $Id: VDCmdDirFrm.S,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdvisual/cmd / VDCmdDirFrm.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdDirFrm.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:32  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class specification VDCmdDirFrm (1:0) of VDS_LOCATE;

#include "OMminimum.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "VDCmdDirFrm.h"

instance VDCmdDirFrm
{
    struct FormPackInfo info;
    DIchar locked;
    DIint  max_depth	/* maximum search depth for finds */;
    DIint  last_icon	/* last icon that was poked	  */;
    DIchar rep_file[80];  /* output file for report directory command */
    DIchar start_dir[80]; /* starting directory for report dir command */
};

message update();

message lock();

message unlock();

message do_form(	IGRlong *msg;
			IGRint form_label;
			IGRint gadget_label;
			IGRdouble value);

message set_gadgets();

message report_dir( long * sts );

message display_default( long * sts );

message init_form();

end specification VDCmdDirFrm;
