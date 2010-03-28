/* #######################    APOGEE COMPILED   ######################## */
class specification RAPinlisnr (1:0) of IGEinlisnr;

/* 
--------------------------------------------------------------------
	File  :       RAPinlisnr.S
	Author:       Terry McIntyre
	Date  :       02-dec-1986
	
DESCRIPTION:
         
--------------------------------------------------------------------
*/

#include <stdio.h>
#include "exfi.h"

instance RAPinlisnr
  {
    FILE *file_ptr;
    int last_n;		/* number of bytes of last event */
  };

override listen;

message init_new_file (FILE *file_ptr);

message append_to_file (FILE *file_ptr);

message formListen (char *formName; struct EXFI_data_st *formData);

message dataListen (char *character; int count; int *response);

message remove_last_command ();

message finish ();

end specification RAPinlisnr;
