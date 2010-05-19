/* $Id: VDgetQryList.I,v 1.1.1.1 2001/01/04 21:08:56 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vdmdlv/func / VDgetQryList.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDgetQryList.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:56  cvs
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
# Revision 1.2  1995/08/23  23:39:18  pinnacle
# Replaced: vdmdlv/func/*.I for:  by tlbriggs for vds.240
#
 *
 * History:
 *	11-20-1994  Raju   	Creation
 *    	08/23/95    tlb		Modified to use _MALLOC, _FREE
 *
 *************************************************************************/
class implementation Root;

/*+fe
Internal Function	VDget_qry_list

Abstract
  This function gets list of queries defined in active and reference files.

Algorithm
  NA

Arguments
 long			*msg,		   O - return message
 int			*NbQry,		   I - no. of queries found
 struct GRid		**qry_list	   I - List of query ids
					     = NULL, if not needed
 struct GRmd_env	**qry_env_list,    I - List of query envs
					     = NULL, if not needed
 char			***qry_name_list,  I - list of query names
					     = NULL, if not needed
 char			***qry_comm_list   I - list of query desc
					     = NULL, if not needed
Memory
 Memory for qry_list, qry_env_list, qry_name_list and qry_comm_list
 is allocated ny this function. It should be freed by the caller.

 _FREE ( qry_list );
 _FREE ( qry_env_list );
 if ( qry_name_list ) VDfree_str_list ( qry_name_list, NbQry );
 if ( qry_comm_list ) VDfree_str_list ( qry_comm_list, NbQry );

Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failure

History
   11-20-1994  Raju   Creation
-fe*/
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "ACattrib.h"
#include "ACrg_collect.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "growner.h"
#include "vdparmacros.h"
#include "vdqrydef.h"

#include "vdmemmacros.h"
#include "vderrmacros.h"
#include "vdmdlvwdef.h"   /* for only MAX_QRY_NAME_LEN, MAX_QRY_COMM_LEN */
#include "VDmem.h"

from ACrg_collect  import ACget_named_attribute;

long VDget_qry_list(
 long			*msg,
 int			*NbQry,
 struct GRid		**qry_list,
 struct GRmd_env	**qry_env_list,
 char			***qry_name_list,
 char			***qry_comm_list
)
{
 IGRlong		sts;
 IGRint			count, ii;
 struct GRid		*loc_qry_list = NULL;
 struct ACrg_coll	att;

  *msg = MSSUCC;
  sts = OM_S_SUCCESS;

  sts = vd$qry_get_id_list( msg		= msg,
			    count	= &count,
			    ref_file	= TRUE   );
  *NbQry = count;
  VDS_ERR_HNDLR("vd$qry_get_id_list", sts, *msg, VD_VERBOSE, wrapup);
  if ( count == 0 ) goto wrapup;

  __DBGpr_int("No. of queries", count );

  loc_qry_list =  _MALLOC( count, struct GRid);
  _CheckMem (loc_qry_list, sts, *msg, wrapup);

  if ( qry_env_list ) {
	*qry_env_list = _MALLOC( count,  struct GRmd_env);
	_CheckMem (*qry_env_list, sts, *msg, wrapup);
	}

  sts = vd$qry_get_id_list( msg		= msg,
			    list_size	= count,
			    list	= loc_qry_list,
			    count	= &count,
			    ref_file	= TRUE   );
  VDS_ERR_HNDLR("vd$qry_get_id_list", sts, *msg, VD_VERBOSE, wrapup);
  __DBGpr_objlist ( "query object list", count, loc_qry_list );

  if ( qry_env_list )
  {
     int  size, nret;
     struct GRmd_env  mod_env;

     size = sizeof( struct GRmd_env );
     sts = gr$get_module_env (	msg = msg,
				sizbuf = &size,
				buffer  = &mod_env,
				nret    = &nret );
     for(ii=0; ii<count; ii++)
     {
	(*qry_env_list)[ii] = mod_env;
	(*qry_env_list)[ii].md_id.osnum = loc_qry_list[ii].osnum;
     }
  }


  if ( qry_name_list )
  {
     sts = vd$malloc_str_list ( str_list  = qry_name_list,
				num_str   = count,
				str_size  = VD_MAX_QRY_NAME_LEN );
     if ( !sts )
     {
	printf("%s[line:%d] : can not allocate memory\n", __FILE__, __LINE__);
	goto wrapup;
     }
  }

  if ( qry_comm_list )
  {
     sts = vd$malloc_str_list ( str_list  = qry_comm_list,
				num_str   = count,
				str_size  = VD_MAX_QRY_DESC_LEN );
     if ( !sts )
     {
	printf("%s[line:%d] : can not allocate memory\n", __FILE__, __LINE__);
	goto wrapup;
     }
  }

  for( ii=0; ii<count; ii++)
  {
    strcpy( att.name, VD_qry_nmName );
    sts = om$send(msg = message ACrg_collect.ACget_named_attribute
					( msg, &att ),
		  senderid = NULL_OBJID,
		  targetid = loc_qry_list[ii].objid,
		  targetos = loc_qry_list[ii].osnum);
    VDS_ERR_HNDLR("ACrg_collect.ACget_named_attribute",
					sts, *msg, VD_VERBOSE, wrapup );

    if( att.desc.type == AC_ATTRIB_TEXT )
	strcpy( (*qry_name_list)[ii], att.desc.value.att_txt );
    else
	printf("VDget_qry_list: Error getting query name\n");

    strcpy( att.name, VD_qry_nmComment );
    sts = om$send(msg = message ACrg_collect.ACget_named_attribute
					( msg, &att ),
		  senderid = NULL_OBJID,
		  targetid = loc_qry_list[ii].objid,
		  targetos = loc_qry_list[ii].osnum);
    if ( !( sts & *msg & 1 ) )
    {
      /* there is no comment for this query */
      sts = OM_S_SUCCESS;
      *msg = MSSUCC;
      continue;
    }

    if( att.desc.type == AC_ATTRIB_TEXT )
	strcpy( (*qry_comm_list)[ii], att.desc.value.att_txt );
    else
	printf("VDget_qry_list: Error getting query comment\n");
  }

wrapup:
  if ( qry_list )
	*qry_list = loc_qry_list;
  else
	_FREE ( loc_qry_list );
  return sts;
}

#if 0
void tmp_qry_call()
{

 long		msg, sts,ii;
 int		NbQry;
 struct GRid	*qry_list = NULL;
 char		**qry_name_list = NULL;
 char		**qry_desc_list = NULL;


 sts = VDget_qry_list ( &msg, &NbQry, &qry_list, &qry_name_list,
			&qry_desc_list );

 for ( ii=0; ii<NbQry; ii++)
 {
   printf("qry obj=[%d,%d]\n", qry_list[ii].objid, qry_list[ii].osnum );
   printf("qry name=[%s]\n", qry_name_list[ii] );
   printf("qry desc=[%s]\n", qry_desc_list[ii] );
 }

 _FREE (qry_list);
 if ( qry_name_list ) VDfree_str_list ( qry_name_list, NbQry );
 if ( qry_desc_list ) VDfree_str_list ( qry_desc_list, NbQry );

}
#endif

end implementation Root;

