class implementation  Root;
/* -------------------------------------------------------------------------
   Doc : SFis_reffile_writable

   Description : This function determines if a given reference file is
		 attached as updatable.

   Return Status :  1 - Success

   History :
   05-30-1994	Raju	Creation
------------------------------------------------------------------------- */
#include  "OMminimum.h"
#include  "OMprimitives.h"
#include  "OMerrordef.h"
#include  "OMindex.h"
#include  "msdef.h"
#include  "igrtypedef.h"
#include  "igetypedef.h"
#include  "gr.h"
#include  "igr.h"
#include  "ref.h"
#include  "refdef.h"

#include  "grdpbdef.h"
#include  "grdpbmacros.h"

#include "vderrmacros.h"


from   GRreffile   import   GRgetosnum;
from   GRreffile   import   GRinquireref;


long   SFis_reffile_writable (
  long		*msg,			/* O - return status */
  GRspacenum 	RefOsnum,		/* I - reference osnum */
  char		RefFileName[],		/* O - ref, filename.  Memory should
					 *      be allocated by caller
					 *	= NULL, not needed */	
  char		*reffile_writable	/* O - whether ref os is writable */
)
{

long			sts, ii;
struct  GRid   		rfmgr;
OM_S_CHANSELECT		refmgrTOreffile;
int			count;
GRspacenum		TmpOsnum;
long                    sizbuf, nret;
struct GRinquire_list   inquire_requests[3] ;
int                     which_error ;
IGRboolean              pass_to_other_spaces,
                                reference_file_found ;
struct GRmd_env         md_env;
char			tmpRefFileName[15];



    __DBGpr_com("Entered SFis_reffile_writable");


    *msg = MSSUCC;
    *reffile_writable = FALSE;

    om$make_chanselect (    channame	  = "Super_rfmgr.mgr",
			    p_chanselect  = &refmgrTOreffile );
  

    /*  get the context Super */
    sts = GRgetctxsuper( msg, &rfmgr );
    VDS_ERR_HNDLR ( "GRgetctxsuper", sts, *msg, VD_VERBOSE, wrapup);

    sts = om$get_channel_count(     osnum           = rfmgr.osnum,
				    objid           = rfmgr.objid,
				    p_chanselect    = &refmgrTOreffile,
				    count           = (OMuint *) &count ) ;
    VDS_ERR_HNDLR ( "refmgrTOreffile count", sts, MSSUCC, VD_VERBOSE, wrapup);

    __DBGpr_int("No. of ref. files attached", count );

    if ( count == 0 )
    {
	/* No. reference files found on the channel */
	*msg = MSFAIL;
	goto wrapup;
    }

    /*
     * Loop on ref files
     */
    for( ii = 0 ; ii < count ; ++ii ) {

        sts = om$send(          msg     = message GRreffile.GRgetosnum(
                                                        msg,
                                                        &TmpOsnum ),
                        senderid        = rfmgr.objid,
                        targetos        = rfmgr.osnum,
                        p_chanselect    = &refmgrTOreffile,
                        to              = ii,
                        from            = ii ) ;

		if ( !( sts & *msg & 1 ) )  continue;

		if ( RefOsnum == TmpOsnum ) break;
    }
    if ( ii == count )
    {
	/* Could not find RefOsnum */
	*msg = MSFAIL;
	goto wrapup;
    }

    sizbuf = sizeof(struct GRmd_env );
    gr$get_module_env(  msg      = msg,
                        sizbuf   = &sizbuf,
                        buffer   = &md_env,
                        nret     = &nret);

    pass_to_other_spaces = FALSE ;

    inquire_requests[0].var                 = REFERENCE_FILE_NAME ;
    inquire_requests[0].var_ptr             = tmpRefFileName ;
    inquire_requests[0].num_requested       = 14 ;
    inquire_requests[1].var                 = REFERENCE_FILE_FOUND ;
    inquire_requests[1].var_ptr             = (char *)&reference_file_found ;
    inquire_requests[1].num_requested       = sizeof reference_file_found ;
    inquire_requests[2].var                 = END_REPORT_REQUEST ;

    sts = om$send(  msg     = message GRreffile.GRinquireref(
							msg,
							&md_env,
							inquire_requests,
							&which_error,
							&pass_to_other_spaces,
							NULL ),
			senderid        = rfmgr.objid,
			targetos        = rfmgr.osnum,
			p_chanselect    = &refmgrTOreffile,
			to              = ii,
			from            = ii ) ;
    VDS_ERR_HNDLR ( "GRreffile.GRinquireref", sts, *msg, VD_VERBOSE, wrapup );


    __DBGpr_int("reference_file_found", reference_file_found );
    __DBGpr_str("tmpRefFileName", tmpRefFileName );

    if (  reference_file_found )
    {
	GRis_writable( msg, tmpRefFileName, 0, md_env.md_id.osnum );
	if ( *msg == MSSUCC )  *reffile_writable = TRUE;
	if ( RefFileName ) strcpy( RefFileName, tmpRefFileName );
	*msg = MSSUCC;
    }

wrapup:
    return  sts;

}

end implementation  Root;
