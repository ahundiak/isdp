/* $Id: VDCmdPlPts.S,v 1.1.1.1 2001/01/04 21:09:05 cvs Exp $  */
 
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdpts/ VDCmdPlPts.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCmdPlPts.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:05  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/30  09:07:00  pinnacle
# .
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *	05/30/97	Sundar		Creation Date
 * -------------------------------------------------------------------*/

class specification VDCmdPlPts (0:1) of VDS_LOCATE;

#include "DIdef.h"
#include "v_cmd.h"
 
instance VDCmdPlPts
{
	IGRchar fileName[DI_PATH_MAX];
	char            *fileForm ;
	VD_fileFormInfo fileInfo;
};
 
override    wakeup;

message store_cs (long *sts);
message store_active_cs (long *sts);
message store_file_name (long *sts);
message createFileForm (long *sts);
message fileFormDismissed( int dismissType );
message fileFormOnOffOut( int Switch /* 0=off, 1=on, 2=out */ );
message VDSplace_points (long *sts);
message VDSwrite_points (long *sts);
message dehilite (long *sts);
 
end specification VDCmdPlPts;
