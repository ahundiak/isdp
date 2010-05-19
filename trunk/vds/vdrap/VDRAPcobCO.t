/* $Id: VDRAPcobCO.t,v 1.3 2002/02/28 20:57:25 ad Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdrap / VDRAPcobCO.t
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDRAPcobCO.t,v $
 *	Revision 1.3  2002/02/28 20:57:25  ad
 *	Changes VDS into VDS_PATH
 *	
 *	Revision 1.2  2001/03/05 15:45:20  hans
 *	*** empty log message ***
 *	
 *	Revision 1.1  2001/03/02 22:55:43  hans
 *	Created
 *	
 *
 * History:
 *	MM/DD/YYYY	AUTHOR		DESCRIPTION
 *	03/02/2001	HF		Creation
 *					Adapted from GRNUC "start and record"
 *
 * -------------------------------------------------------------------*/

/*
 * Command object for: VDS journalling
 */

class           VDRAPcobCO
super_class     CEO_LOCATE

command_string  "ISDP Journaling", 0, VDRAPcobCO
product_name    "$VDS_PATH"
command_table   "vds.cmd"
options         "isTC"

start_state     start

state start

  on ELSE state terminate
