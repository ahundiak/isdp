/* $Id: VDref_util.I,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdutil / VDref_util.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDref_util.I,v $
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

/*
 * Implement of functions for ref files
 *
 * ADZ  2/10/94	Test Super context object to about sending to invalid channel
 */

class implementation Root;

#include <stdio.h>
#include "igetypedef.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "msdef.h"
#include "refdef.h"
#include "madef.h"
#include "AS_status.h"

from	GRreffile	import GRinquireref;
from	GRcontext	import GRgetinstance;

extern	GRclassid	OPP_VDcontext_class_id;

/*
 * This function finds all active reference files in a design session.
 */
VDfind_ref_files( ref, max_ref, nb_ref)
GRspacenum *ref;
int max_ref,*nb_ref;
{
IGRint		status = OM_S_SUCCESS;
IGRlong		loc_msg;
IGRchar 	osname[OM_K_MAXOSNAME_LEN];
IGRshort	mx_type, flag;
OMuint  	count;
IGRlong 	i,j;			/* loop index			*/
GRspacenum	ref_osnum;
OM_S_CHANSELECT super_chan, ref_chan;
struct GRid	Super, ctx_id;
IGRmatrix	ctx_matrix;

  /*
   * initialisation.
   */
  *nb_ref = 0;
  if( ref == NULL ) return( OM_E_ABORT );

  status =
  om$make_chanselect(channame = "Super_rfmgr.to_context",
		    p_chanselect = &super_chan);
  as$status(action = RET_STATUS);

  status =
  om$make_chanselect(channame = "GRcontext.to_reffile",
		    p_chanselect = &ref_chan);
  as$status(action = RET_STATUS);

  /*
   * get the context Super
   */
  Super.objid = NULL_OBJID;
  status = GRgetctxsuper( &loc_msg, &Super );
  if( !( status&loc_msg&1 )) return OM_E_ABORT;
  status =
  om$is_objid_valid(	objid	= Super.objid,
			osnum	= Super.osnum );
  if( !( status&1 )) return OM_E_ABORT;

  count = 0;
  status =
  om$get_channel_count(	osnum = Super.osnum,
			objid = Super.objid,
			p_chanselect = &super_chan,
			count = &count);
  if( !(status & 1) ) return status;

  for( i=0; i<count; ++i){
    /*
     * get each context object
     */
    status =
    om$send(msg = message GRcontext.GRgetinstance(&loc_msg,
						&mx_type,
						ctx_matrix,
						&ref_osnum,
						&flag,
						&ctx_id),
	    senderid = Super.objid,
            targetos = Super.osnum,
            p_chanselect = &super_chan,
    	    to = i, from = i);
    if(!(status&loc_msg&1)) continue;
	
    /*
     * see if this object space is active before
     * trying to use this context object.
     */

    status =
    om$os_number_to_name(osnum=ref_osnum, osname = osname);
    if(!(status&1)) continue;
    if(!(flag & GRACTIVATED_CONTEXT)) continue;

    /*
     * check if object spacenum is stored in list.
     */
    for(j=0; j<*nb_ref;j++) if(ref_osnum == ref[j]) break;
    if( j >= *nb_ref){
      if( *nb_ref < max_ref ) ref[*nb_ref] = ref_osnum;
      *nb_ref = *nb_ref + 1;
    }
  }
  return( OM_S_SUCCESS );
}


VDattach_missing_ref( ref, max_ref, nb_ref)
GRspacenum *ref;
int max_ref,*nb_ref;
{
IGRint		status = OM_S_SUCCESS;
IGRlong		loc_msg;
IGRchar 	osname[OM_K_MAXOSNAME_LEN];
IGRshort	mx_type, flag;
OMuint  	count;
IGRlong 	i,j;			/* loop index			*/
GRspacenum	ref_osnum;
GRclassid obj_class;
OM_S_CHANSELECT super_chan, ref_chan;
struct GRid Super, ctx_id;
IGRmatrix	ctx_matrix;

  *nb_ref = 0;

  status =
  om$make_chanselect(channame = "Super_rfmgr.to_context",
		    p_chanselect = &super_chan);
  as$status(action = RET_STATUS);

  status =
  om$make_chanselect(channame = "GRcontext.to_reffile",
		    p_chanselect = &ref_chan);
  as$status(action = RET_STATUS);

  /*
   * get the context Super
   */
  Super.objid = NULL_OBJID;
  status = GRgetctxsuper(&loc_msg,&Super);
  if( !( status&loc_msg&1 )) return OM_E_ABORT;
  status =
  om$is_objid_valid(	objid	= Super.objid,
			osnum	= Super.osnum );
  if( !( status&1 )) return OM_E_ABORT;

  count = 0;
  status =
  om$get_channel_count( osnum = Super.osnum,
		       objid = Super.objid,
		       p_chanselect = &super_chan,
		       count = &count);
  if( !( status&1 )) return status;

  for( i=0; i<count; ++i){
    /*
     * get each context object
     */
    status =
    om$send( msg = message GRcontext.GRgetinstance(&loc_msg,
						&mx_type,
						ctx_matrix,
						&ref_osnum,
						&flag,
						&ctx_id),
		senderid = Super.objid,
		targetos = Super.osnum,
		p_chanselect = &super_chan,
		to = i, from = i);
    if(!(status&loc_msg&1)) continue;

    /*
     * Check if the context if changed class (GRcontext->VDcontext)
     */
    status =
    om$get_classid(objid = ctx_id.objid,
		   osnum = ctx_id.osnum,
		   p_classid = &obj_class);
    if(om$is_ancestry_valid(superclassid = OPP_VDcontext_class_id,
			   subclassid = obj_class) != OM_S_SUCCESS) continue;
	
    /*
     * see if this object space is active before
     * trying to use this context object.
     */

    status = om$os_number_to_name(osnum=ref_osnum, osname = osname);
    if(!(status&1)) continue;
    if ( !( flag & GRACTIVATED_CONTEXT)) continue;

    for(j=0;j<*nb_ref;j++) if(ref_osnum = ref[j]) break;
    if( j >= *nb_ref ){
      if(*nb_ref < max_ref) ref[*nb_ref] = ref_osnum;
      *nb_ref = *nb_ref + 1;
    }
  }
  return( OM_S_SUCCESS );
}

end implementation Root;
