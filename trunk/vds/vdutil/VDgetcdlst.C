
/* $Id: VDgetcdlst.C,v 1.2 2001/01/19 20:25:08 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdutil / VDgetcdlst.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VDgetcdlst.C,v $
 *        Revision 1.2  2001/01/19 20:25:08  ramarao
 *        Louis Changes.
 *
 * Revision 1.1  2000/12/13  17:03:58  pinnacle
 * Created: vds/vdutil/VDgetcdlst.C by lawaddel for Service Pack
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
 * Revision 1.3  1995/06/05  19:13:36  pinnacle
 * Replace: vdutil/VDgetcdlst.C by hverstee for OPE
 *
 * Revision 1.2  1995/06/02  15:11:04  pinnacle
 * Replace: vdutil/VDgetcdlst.C by hverstee for OPE
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *        MM/DD/YY        AUTHOR                DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/* modification : This file has been changed from a .c to a .C due to the
 * inclusion of new macros from vdbmacros.h. Also this change has been made in 
 * the .m file
 */ 

#include <stdio.h>
#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "go.h"
#include "ASmatrix.h"
#include "asdef.h"
#include "asmacros.h"
#include "acmacros.h"
#include "asbox.h"
#include "AS_status.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "nddef.h"
#include "acrepdef.h"
#include "exdef.h"
#include "exmacros.h"

#include "PDUerror.h"
#include "VDmacdef.h"
#include "vdbmacros.h"
#include "vdsmacros.h"

#define          MAX_WORD 81   /* 81 because 80 +\0 =81 */

IGRint  VDget_codelist_attr (IGRlong  *msg,
                             IGRint    product,
                             IGRint    list_num,
                             IGRint    req,
                             IGRint    i_code,
                             IGRchar  *i_sname,
                             IGRchar  *i_lname,
                             IGRint   *o_code,
                             IGRchar  *o_sname,
                             IGRchar  *o_lname,
                             IGRchar  *p_error)

{
  char      *table;
  char      *sel;
  int        n_attr,sts;
  int        num;
  char     **buf;
  char       search[MAX_WORD];

  *msg   = MSFAIL;
  buf    = NULL;
  sts    = OM_E_ABORT;
  n_attr = 1;

  /***  NO TR initialize output character strings to NULL before processing ***/
  if(o_sname) o_sname[0] = '\0';
  if(o_lname) o_lname[0] = '\0'; 

  if( VDSverify_login() != PDM_S_SUCCESS )
  {
  /**** NO TR p_error > 29 char causes problems in route ***/
     p_error = "User not logged into Database";
     goto WRAPUP;
  }

  sts  = OM_E_INVARG;

  switch ( product )
  {
    case VDS:       table = "VDS_CODELIST";             break;
    case PIPING:    table = "PIPING_CODELIST";          break;
    case HVAC:      table = "HVAC_CODELIST";            break;
    case CABLING:   table = "RWAY_CODELIST";            break;
    case STRUCT:    table = "STRUCT_CODELIST";          break;
    default :       goto WRAPUP;
  }

  switch ( req )
  {
    case VD_ALIAS_CD_TO_ST:
      sel = "short_txt";
      sprintf(search,"list_num = %d and code_num = %d", list_num,i_code);
      break;
    case VD_ALIAS_CD_TO_LT:
      sel = "long_txt";
      sprintf(search,"list_num = %d and code_num = %d", list_num,i_code);
      break;
    case VD_ALIAS_ST_TO_CD:
      sel  = "code_num";
      sprintf(search,"list_num = %d and short_txt ='%s'", list_num,i_sname);
      break;
    case VD_ALIAS_ST_TO_LT:
      sel = "long_txt";
      sprintf(search,"list_num = %d and short_txt ='%s'", list_num,i_sname);
      break;
    case VD_ALIAS_LT_TO_CD:
      sel  = "code_num";
      sprintf(search,"list_num = %d and long_txt ='%s'", list_num,i_lname);
      break;
    case VD_ALIAS_LT_TO_ST:
      sel = "short_txt";
      sprintf(search,"list_num = %d and long_txt ='%s'", list_num,i_lname);
      break;

    default:     goto WRAPUP;
  }

  *msg   = MSSUCC;

  sts =
  vdb$RisSelect(  select        =  sel,
                  table_name    =  table,
                  where         =  search,
                  numselect     =  n_attr,
                  p_numrows     =  &num,
                  p_buffer      =  &buf );
  if (!( sts & OM_S_SUCCESS))
  {
     p_error = "Error selecting Ris";
     goto WRAPUP;
  }
  if( num == 0)
  {
     p_error = "No values found";
     sts = OM_E_ABORT;
     goto WRAPUP;
  }

  switch ( req )
  {
    case VD_ALIAS_CD_TO_ST:
      strcpy(o_sname,buf[0]);
      break;
    case VD_ALIAS_CD_TO_LT:
      strcpy(o_lname,buf[0]);
      break;
    case VD_ALIAS_ST_TO_CD:
      sscanf(buf[0],"%d",o_code);
      break;
    case VD_ALIAS_ST_TO_LT:
      strcpy(o_lname,buf[0]);
      break;
    case VD_ALIAS_LT_TO_CD:
      sscanf(buf[0],"%d",o_code);
      break;
    case VD_ALIAS_LT_TO_ST:
      strcpy(o_sname,buf[0]);
      break;
 }

 sts = OM_S_SUCCESS;

 WRAPUP:
 if (buf != NULL)    VdsRisFreeBuffer (buf, n_attr * num);

 return (sts);
}
