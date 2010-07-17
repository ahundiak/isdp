class implementation Root;

#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dpdef.h"
#include "dp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "refdef.h"

#include "vderrmacros.h"

from  GRgraphics  import GRdisplay;
from  GRcontext   import GRgetinstance;



long  SFdispModObj()
{

long			sts, ii, jj, msg;
OMuint			misCon,
			count;
OMuword			RefOsnum = 7;
OM_S_TAG_CON_INFO       *tags = NULL;
int			numberOfBytes,
			BytesReceived;
struct GRmd_env		mod_env,
		  	ctxEnv;
enum  GRdpmode		dpmode = GRhd;
OM_S_CHANSELECT		rfmgrTOctx;
struct GRid		rfmgr,
			ctxId;
short			flag;
char 			osname[OM_K_MAXOSNAME_LEN];



	numberOfBytes = sizeof ( struct GRmd_env );
	gr$get_module_env(   msg     = &msg,
                             sizbuf  = &numberOfBytes,
                             buffer  = &mod_env,
                             nret    = &BytesReceived );


	/*
	 * Get all attached reference files and process mismatched connections
	 * in all of them.
	 */
	sts = om$make_chanselect(	
				channame	= "Super_rfmgr.to_context",
				p_chanselect	= &rfmgrTOctx ) ;
	if( !( sts & 1 ) ) goto wrapup ;

	/*
	 * Get the context Super.
	 */
	sts = GRgetctxsuper( &msg, &rfmgr ) ;
	if( !( sts & 1 & msg ) ) goto wrapup ;

	sts = om$get_channel_count(	osnum		= rfmgr.osnum,
					objid		= rfmgr.objid,
					p_chanselect	= &rfmgrTOctx,
					count		= (OMuint *) &count ) ;
	if( !( sts & 1 ) ) goto wrapup ;

	/*
	 * Loop on contexts.
	 */
	for( ii = 0 ; ii < count ; ++ii ) {

		sts = om$send(
			msg	= message GRcontext.GRgetinstance(
							&msg,
							&ctxEnv.md_env.matrix_type,
							ctxEnv.md_env.matrix,
							&RefOsnum,
							&flag,
							&ctxId ),
			senderid	= rfmgr.objid,
			targetos	= rfmgr.osnum,
			p_chanselect	= &rfmgrTOctx,
			to		= ii,
			from		= ii ) ;

		if( !( 1 & sts & msg ) ) continue ;

		if( flag & GREMPTY_CONTEXT ) continue ;

		/*
		 * See if this object space is active before
		 * trying to use this context object.
		 */
		 sts = om$os_number_to_name(	osnum	= RefOsnum,
						osname	= osname ) ;
		__DBGpr_int( "Osnum", RefOsnum ) ;
		__DBGpr_str( "Osname", osname ) ;

		if( !( 1 & sts ) ) {
			/*
			 * Skip this osnum.
			 */
			__DBGpr_int( "No OS name for", RefOsnum ) ;

			continue ;
		}

		if( !( flag & GRACTIVATED_CONTEXT ) ) {
			/*
			 * This is the master file. Skip it.
			 */

			__DBGpr_str( "Context not active for", osname ) ;

			continue ;
		}


		sts = om$mismatched_connections(
                                        osnum           = mod_env.md_id.osnum,
                                        tagged_osnum    = RefOsnum,
                                        p_count         = (OMuint *) &misCon ) ;

		__DBGpr_int("No. of missing connections", misCon );

		tags = (OM_S_TAG_CON_INFO *) malloc( misCon * sizeof *tags ) ;



		sts = om$mismatched_connections(
                                        osnum           = mod_env.md_id.osnum,
                                        tagged_osnum    = RefOsnum,
                                        p_count         = &misCon,
                                        size            = misCon,
                                        p_tag_con_info  = tags ) ;

        	for( jj = 0 ; jj < misCon ; jj++ )
		{
		    __DBGpr_int("missing connection number", jj );
		    __DBGpr_int("missing connection object", tags[jj].objid);

		    sts = om$send ( msg = message GRgraphics.GRdisplay (
						&msg,
						&mod_env.md_env.matrix_type,
						mod_env.md_env.matrix,
						&dpmode,
						&mod_env.md_id ),
				targetid = tags[jj].objid,
				targetos = mod_env.md_id.osnum,
				senderid = NULL_OBJID );
		}
	}

wrapup:
   return 1;
}

end implementation Root;

