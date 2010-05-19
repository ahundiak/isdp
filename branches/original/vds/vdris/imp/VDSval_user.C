/* $Id: VDSval_user.C,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdris/imp / VDSval_user.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSval_user.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:12  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.2  1996/04/21  23:27:24  pinnacle
 * Replaced: vdris/imp/*.C for:  by v240_int for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	04/19/96   tlb		Add prototypes
 *
 * -------------------------------------------------------------------*/


#include 	<stdio.h>
#include	<string.h>

#include "NFMerrordef.h"
#include "vdbmacros.h" 
#include	"v_risproto.h"

#define  MAX_WORD  81  /* 81 because 80 + \0 = 81 */

/*-----------------------------------------------------------------*/
int VDSvalid_user ( username, password, ret_msg)

    char  username[];       /* User name     (I) */
    char  password[];       /* Password      (I) */
    char  ret_msg[80];      /* Return message(O) */

/* Returns 1 if OK
           0 if error
*/

{
  int   sts;
  char  search[MAX_WORD];
  char  n_passwd[MAX_WORD];
  char  temp_str[MAX_WORD];
  int   num;
  char  **buf;
  int   n_attr;

  strcpy(ret_msg,"");

  /* ---- Get password from nfmusers */

  sprintf ( search, "n_username = '%s'", username);
  n_attr = 1;

  sts = 
  vdb$RisSelect(  select      =       "n_passwd",
                  table_name  =       "nfmusers",
                  where       =        search,
                  order       =        NULL,
                  group       =        NULL,
                  numselect   =        n_attr,
                  p_numrows   =        &num,
                  p_buffer    =        &buf );


  if(sts != 1)
  {
     strcpy(ret_msg,"Failed to get password from database");
     return 0;
  }
  if (num == 0)
  {
    sprintf(ret_msg,"Invalid Username/Password Combination");
    return 0;
  }

  vdb$RisExtractValue (  nbrows      =     num,
                         nbcolumns   =     n_attr, 
                         buffer      =     buf,
                         row         =     0,
                         column      =     0,
                         value       =     n_passwd );

  vdb$RisFreeBuffer (  buffer =   buf,
                       size   =   n_attr*num);

  sprintf( temp_str, "%*.*s", 25, 25, n_passwd);
  sts = NFMdecrypt ( temp_str, n_passwd);
  if(sts != NFM_S_SUCCESS)
  {
    strcpy(ret_msg,"Error Decrypt: NFM PASSWD");
    return 0;
  }

  if(strcmp(password, n_passwd))
  {
    strcpy(ret_msg,"Invalid Username/Password Combination");
    return(0);
  }
  return 1;
}
