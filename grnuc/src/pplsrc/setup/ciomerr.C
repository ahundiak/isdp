/* -- Object Manager error handler.
   -- */
#include "OMminimum.h"
#define	 OM_DEFINE_ERRMSG 
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "ex.h"
#include "godef.h"
#include "codef.h"
#include "grerr.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "msdef.h"
#include "msmacros.h"
#include "cidef.h"
#include "citypedef.h"
#include "cimsg.h"
#include <stdio.h>
#include <string.h>
#include <limits.h>

/*----------------------------------------------------------------------------*/
extern char *CIexmessage() ;

/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static char *OMerrtext __((long code, char *severity));

#if defined(__cplusplus)
}
#endif
#undef __


/*----------------------------------------------------------------------------*/
int CIomerr( coev, run, file, line, OMcode, class,
	     mess, objid, channame, osnum, osname )

	CIco_resp	*coev					 ;
	CIruntime	*run					 ;
	char		*file, *class, *mess, *osname, *channame ;
	long		OMcode					 ;
	OMuword		osnum					 ;
	OM_S_OBJID	objid					 ; {

/* -- Displays OM error on CI Runtime Error form.
      INPUT  : coev	, event data of ci object running PPL file.
	       run	, runtime parameters of above-mentioned ci object.
	       file	, executing PPL file name.
               line	, line number where error occured.
               OMcode	, OM error code ( OM_?_blablabla ).
               class	, class name ( NULL if not specified ).
               mess	, message name ( NULL if not specified ).
               objid	, object id ( INT_MAX if not specified ).
               channame	, channel name ( NULL if not specified ).
               osnum	, object space number ( -1 if not specified ).
               osname	, object space name ( NULL if not specified ).
      RETURNS: TRUE if execution can continue else FALSE.
   -- */

	char severity, buf[5][80], *ln[5], *OMerrtext() ; int u ;

#ifdef DEBUG
  printf( "CIomerr: ENTER" ) ; fflush( stdout ) ;
#endif
	for( u = 0 ; u < 5 ; u++ ) ln[u] = NULL ;

	u = 0 ;
	/* Line 1 */
	if( objid != INT_MAX ) {
		ln[u] = buf[u] ;
		ex$message(	msgnumb	= CI_I_omOBJTID	,
				buff	= ln[u]		,
				type	= "%d"		,
				var	= `objid`	) ;
		u++ ;
	} else if( channame != NULL ) {
		ln[u] = buf[u] ;
		ex$message(	msgnumb	= CI_I_omCHNNAM	,
				buff	= ln[u]		,
				type	= "%s"		,
				var	= `channame`	) ;
		u++ ;
	}

	/* Line 2 */
	if( osnum != (OMuword) (-1) ) {
		ln[u] = buf[u] ;
		ex$message(	msgnumb	= CI_I_omOSPNUM	,
				buff	= ln[u]		,
				type	= "%d"		,
				var	= `osnum`	) ;
		u++ ;
	} else if( osname != NULL ) {
		ln[u] = buf[u] ;
		ex$message(	msgnumb	= CI_I_omOSPNAM	,
				buff	= ln[u]		,
				type	= "%s"		,
				var	= `osname`	) ;
		u++ ;
	}

	/* Line 3 */
	if( class != NULL ) {
		ln[u] = buf[u] ;
		ex$message(	msgnumb	= CI_I_omCLSNAM	,
				buff	= ln[u]		,
				type	= "%s"		,
				var	= `class`	) ;
		u++ ;
	}

	/* Line 4 */
	if( mess != NULL ) {
		ln[u] = buf[u] ;
		ex$message(	msgnumb	= CI_I_omMSGNAM	,
				buff	= ln[u]		,
				type	= "%s"		,
				var	= `mess`	) ;
		u++ ;
	}

	/* Line 5 */
	ln[u] = strcpy( buf[u], OMerrtext( OMcode, &severity ) ) ;

#ifdef DEBUG
  printf( "CIomerr: b4 CIerror" ) ; fflush( stdout ) ;
#endif
	CIerror( &u, coev, run, file, line, severity,
		 CIexmessage( CI_I_omFTITLE ),
		 ln[0], ln[1], ln[2], ln[3], ln[4] ) ;

#ifdef DEBUG
  printf( "CIomerr: EXIT" ) ; fflush( stdout ) ;
#endif
	return u ;
}
/*----------------------------------------------------------------------------*/
/* -- Texts of OM error messages ( there is no other way that I know to get
      them ). WARNING: this list is ordered. Should be modified if the order
      in "OMerrordef.h" changes.
   -- */
static char *OMerrmsgs[] = { 0
/*
		OM_erm_OBJECT_LOCKED		,
		OM_erm_UNKNOWN_MSG		,
		OM_E_erm_OBJECT_OVERSIZED	,
		OM_erm_STOP_SENDING		,
		OM_erm_NO_RELATION		,
		OM_erm_BUGCHECK			,
		OM_erm_NOTIMPL			,
		OM_erm_NODYNMEM			,
		OM_erm_CLASS_EXISTS		,
		OM_erm_NOPARENT			,
		OM_erm_BADCLASSNAME		,
		OM_erm_TOOMANYCLASSES		,
		OM_erm_NO_OBJECT_SPACE		,
		OM_erm_NOSUCHCLASS		,
		OM_erm_REL_MISMATCH		,
		OM_erm_CHAN_OVERFLOW		,
		OM_erm_INVCHAN			,
		OM_erm_NOSUCHOBJ		,
		OM_erm_CHAN_NOTEMPTY		,
		OM_erm_CHAN_EMPTY		,
		OM_erm_NOTONCHAN		,
		OM_erm_LISTOVFLOW		,
		OM_erm_INVARG			,
		OM_erm_OBJONCHAN		,
		OM_erm_RELVANISHED		,
		OM_erm_VERSION_MISMATCH		,
		OM_erm_OBJSPACE_EXISTS		,
		OM_erm_NO_OS_AVAIL		,
		OM_erm_DEFER_SUCCESS		,
		OM_erm_INVALIDRANGE		,
		OM_erm_NOSUCHOS			,
		OM_erm_IOERR			,
		OM_erm_INCONOIDS		,
		OM_erm_INCONOPSYS		,
		OM_erm_INCONCPUS		,
		OM_erm_INVOSHDR			,
		OM_erm_NOSUCHREL		,
		OM_erm_BADSTATE			,
		OM_erm_ADDEDATEND		,
		OM_E_erm_NO_RDSK_PARTITIONS	,
		OM_E_erm_MSGNOTSUPP		,
		OM_E_erm_NOEXTEND		,
		OM_W_erm_NOTORDERED		,
		OM_E_erm_NAMETOOLONG		,
		OM_W_erm_WARNING		,
		OM_E_erm_ERROR			,
		OM_E_erm_BADCLASS		,
		OM_W_erm_INDEXEMPTY		,
		OM_I_erm_FILEOVRWRTN		,
		OM_W_erm_ISODIRONOS		,
		OM_E_erm_NOEXTEND_OS		,
		OM_E_erm_OS_ALLOC		,
		OM_I_erm_INVANCESTRY		,
		OM_I_erm_NOPARENT		,
		OM_E_erm_FILEEXISTS		,
		OM_W_erm_OSNOTACTIVE		,
		OM_W_erm_USE_ISO_IF		,
		OM_E_erm_DIREXISTS		,
		OM_E_erm_NODIREXISTS		,
		OM_E_erm_INDEXERROR		,
		OM_E_erm_OIDNAMEINUSE		,
		OM_E_erm_TOOMANYNAMES		,
		OM_W_erm_NAMENOTFOUND		,
		OM_E_erm_NOINDEXEXISTS		,
		OM_E_erm_OIDNOTNAMED		,
		OM_E_erm_INDEXNOTEMPTY		,
		OM_F_erm_SEVERE			,
		OM_E_erm_CHNSELTYPINV		,
		OM_E_erm_EXCEEDFANOUT		,
		OM_E_erm_CLASSNOTANCESTOR	,
		OM_E_erm_CHANNOTFOUND		,
		OM_I_erm_ISAUNION		,
		OM_W_erm_CLASS_CHKSUM_MISMATCH	,
		OM_E_erm_INVINDEX		,
		OM_E_erm_INVCLUSTERID		,
		OM_E_erm_NOEXTEND_CLUSTER	,
		OM_E_erm_MAX_CLUSTERS_ALLOWED	,
		OM_E_erm_CLASS_CONFLICT		,
		OM_I_erm_NO_FREE_OIDS		,
		OM_E_erm_NO_EXTEND_GROUP	,
		OM_E_erm_NOTTREEROOT		,
		OM_E_erm_NO_DELETE_GROUP	,
		OM_E_erm_NO_DELETE_CLUSTER	,
		OM_E_erm_AMBIGUOUS_CHANNAME	,
		OM_E_erm_NOPASSPASS		,
		OM_E_erm_INVSTSTYPE		,
		OM_E_erm_OBJSIZE_TOOBIG		,
		OM_E_erm_CLUSTEXT_TOOBIG	,
		OM_E_erm_NOEXTEND_GROUP		,	
		OM_E_erm_ILLEGAL_GROUP0		,
		OM_E_erm_DUPGRPNAME		,
		OM_E_erm_DUPCLUSTNAME		,
		OM_E_erm_WRITE_ERROR		,
		OM_E_erm_READ_ERROR		,
		OM_W_erm_SIZE_TOO_SMALL		,
		OM_E_erm_NULL_STRING		,
		OM_I_erm_READ_FROM_FILE		,
		OM_W_erm_OS_NOT_IN_MOSD		,
		OM_E_erm_NO_DISK_SPACE		,
		OM_E_erm_MOSDOS_OS		,
		OM_E_erm_TRANS_OS		,
		OM_I_erm_LOGICAL_DISCONNECT	,
		OM_E_erm_DUPSYMNAME		,
		OM_I_erm_UNABLE_TO_CONNECT	,
		OM_E_erm_BADCHAN_TYPE		,
		OM_I_erm_NOMATCH		,
		OM_E_erm_SYMBOLNOTFOUND		,
		OM_E_erm_SPECIAL_FILE		,
		OM_E_erm_INACCESSABLE_FILE	,
		OM_I_erm_NOEXIST_WRITEABLE_FILE	,
		OM_I_erm_EXIST_READONLY_FILE	,
		OM_I_erm_EXIST_READ_WRITE_FILE	,
		OM_I_erm_READ_FROM_RO_FILE	,
		OM_E_erm_FILEISDIR		,
		OM_E_erm_INVSWAPMARKS		,
		OM_E_erm_INV_CLUSTEXT		,
		OM_E_erm_INTERNALS_CORRUPT	,
		OM_E_erm_NOTTAGGED		,
		OM_E_erm_TAGEXISTS		,
		OM_W_erm_NOTTAGGED		,
		OM_E_erm_NOSUCHTAG		,
		OM_E_erm_NOAVAILABLETAG		,
		OM_E_erm_BADSENDDEPTH		,
		OM_E_erm_BADPROMCLASS		,
		OM_E_erm_INTERCEPTED		,
		OM_W_erm_NOINTERCEPT		,
		OM_W_erm_NODYNLOAD		,
		OM_E_erm_NOSUCHMSG		,
		OM_E_erm_OVERSPAWN		,
		OM_W_erm_REJECTED_METHOD	,
		OM_E_erm_SWAP_PARTITION_SIZE_MISSING,
		OM_E_erm_ABORT			,
		OM_W_erm_ABORT			,
		OM_F_erm_OUT_OF_SWAP_SPACE	,
		OM_E_erm_FROM_RTREE		,
		OM_E_erm_NO_RECLUST_FUNC	,
		OM_E_erm_RECLUSTFUNCERR		,
		OM_E_erm_CYCLEINSUPGROUP	,
		OM_W_erm_NOSUCHMEMBER		,
		OM_W_erm_NOTTAGGABLE		,
		OM_W_erm_TAGDISABLED		,
		OM_I_erm_OBJNOTTAGGED		,
*/		
} ;
/*----------------------------------------------------------------------------*/
static char *OMerrtext( code, severity )  long code ; char *severity ; {

	int sever, index ;

  sever = code & SEVE ;
  index	= ( code - (OM_FACILITY_CODE << 16 ) - 0X8000 - sever ) >> 3 ;
 
  switch( sever ) {
  	case WARN : *severity = 'W' ; break ;
  	case ERRO : *severity = 'F' ; break ;
  	case SEVE : *severity = 'S' ; break ;
  	case INFO : *severity = 'W' ; break ;
  	case SUCC : fprintf( stderr, "CIomerr: SUCCESS\n" ) ;
  }
  return OMerrmsgs[index-1] ;
}
/*----------------------------------------------------------------------------*/

