/*
$Log: create.c,v $
Revision 1.1.1.1  2001/12/17 22:39:13  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:16:08  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:30:24  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.1  1995/09/22  07:02:41  samuel
 * COMMENT : Checking in font.flb for Create Font cmd etc.
 *
 * Revision 320.0  1994/12/12  17:59:20  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:53:02  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:31:11  root
 * COMMENT : Corresponds to Rel201.3 in 2.0.1 RCS
 *
 * Revision 201.3  1992/07/13  19:17:02  tim
 * COMMENT : added Log variable
 *
*/

/*************
Hisotry:

	22 Sept 95	Samuel	Added calls to get the path of $GRNUC/config
				to copy font.flb and chmod to rw for owner.

*************/

#include  "flib_common.h"
#include  "struct.h"
#include  <stdio.h>
#include  <sys/types.h>
#include  <time.h>
#include  "EXproduct.h"
#include  "exproto.h"

bool create_flib (flib_name)

char *flib_name;
{
#define LH_BUFSIZ 512

 library_header  *lh_n_ptr;
 FILE            *flib_cb,*fopen();	/* font library file control block */
 struct tm       *clock;
 long            secs;
 short           blk_lh = 1;		/* block # at beg of library header */
 buf_union       buffer;
 bool            status = FALSE;
 char            cpstring[128];
 char            chmod_string[128];
 char            prod_string[128];
 char            *p_string = NULL;

    p_string = prod_string;
    if(!EX_read_product_data ())
	return (1);
    if(!EX_get_prod_info("Grnuc",EXPROD_GET_CONFIG_BY_RUNNAME,(char **)&p_string)) 
	return (1);
    strcpy(cpstring,"cp " );
    strcat(cpstring,p_string);
    strcat(cpstring,"/config/font.flb ");
    strcat(cpstring,flib_name);
    system(cpstring);  /* Copy basic FONTLIB file to new file */
    strcpy(chmod_string,"chmod 644 "); 
    strcat(chmod_string,flib_name); 
    system(chmod_string); 
    flib_cb=fopen(flib_name,"r+"); /* open new FONTLIB file */

    status = readblk ( flib_cb, blk_lh, LH_BUFSIZ, buffer.flib_buf );
    if ( !status )
    	{
        lh_n_ptr = ( library_header *)&buffer.flib_buf[0]; /* set header */
        time(&secs);             /* Get Time */
        clock=localtime(&secs);
     /**** insert creation date & time dmb:2/23/90 */
        lh_n_ptr -> cre_date.year =(short)(1900+clock->tm_year);
        lh_n_ptr -> cre_date.month =(char)clock->tm_mon;
        lh_n_ptr -> cre_date.day = (char)clock->tm_mday;
        lh_n_ptr -> cre_time.hour = (char)clock->tm_hour;
        lh_n_ptr -> cre_time.min = (char)clock->tm_min;
        lh_n_ptr -> cre_time.sec = (char)clock->tm_sec;
        lh_n_ptr -> cre_time.sec_100th =0;

     /**** insert modification date & time dmb:2/23/90 */
        lh_n_ptr -> mod_date.year = (short)(1900+clock->tm_year);
        lh_n_ptr -> mod_date.month = (char)clock->tm_mon;
        lh_n_ptr -> mod_date.day = (char)clock->tm_mday;
        lh_n_ptr -> mod_time.hour = (char)clock->tm_hour;
        lh_n_ptr -> mod_time.min = (char)clock->tm_min;
        lh_n_ptr -> mod_time.sec = (char)clock->tm_sec;
        lh_n_ptr -> mod_time.sec_100th = 0;
     } /* End of if read is OK */
	status = writeblk ( flib_cb, blk_lh, LH_BUFSIZ, buffer.flib_buf );
   
    /* dmb:2/25/90 */
    fclose ( flib_cb );
    return (status);
}
