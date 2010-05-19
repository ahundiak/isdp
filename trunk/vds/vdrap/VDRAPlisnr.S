/* $Id: VDRAPlisnr.S,v 1.1 2001/03/02 22:55:47 hans Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdrap / VDRAPlisnr.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDRAPlisnr.S,v $
 *	Revision 1.1  2001/03/02 22:55:47  hans
 *	Created
 *	
 *
 * History:
 *	MM/DD/YYYY	AUTHOR		DESCRIPTION
 *	03/02/2001	HF		Creation
 *					Adapted from GRNUC "start and record"
 *
 * -------------------------------------------------------------------*/

class specification VDRAPlisnr (1:0) of IGEinlisnr;

#include <stdio.h>
#include "exfi.h"

instance VDRAPlisnr
{
  FILE *file_ptr;
  int   last_n;		/* number of bytes of last event */
};

override listen;

message init_new_file (FILE *file_ptr);

message append_to_file (FILE *file_ptr);

message formListen (char *formName; struct EXFI_data_st *formData);

message dataListen (char *character; int count; int *response);

message remove_last_command ();

message finish ();

end specification VDRAPlisnr;
