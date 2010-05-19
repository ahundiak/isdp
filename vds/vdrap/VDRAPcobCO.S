/* $Id: VDRAPcobCO.S,v 1.1 2001/03/02 22:55:41 hans Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdrap / VDRAPcobCO.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDRAPcobCO.S,v $
 *	Revision 1.1  2001/03/02 22:55:41  hans
 *	Created
 *	
 *
 * History:
 *	MM/DD/YYYY	AUTHOR		DESCRIPTION
 *	03/02/2001	HF		Creation
 *					Adapted from GRNUC "start and record"
 *
 * -------------------------------------------------------------------*/

class specification VDRAPcobCO (1:0) of CEO_LOCATE;

override init;

message does_listener_exist ( long * sts );

message remove_last_command ( long * sts );

message have_filename (int *sts;  int  file_flag);

message stop_record ( long * sts );

end specification VDRAPcobCO;
