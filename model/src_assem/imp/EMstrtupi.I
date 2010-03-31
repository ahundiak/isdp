
class implementation EMstrtup;

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <FI.h>
#include "igrtypedef.h"
#include "igetypedef.h"
#include "exmacros.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "grlicense.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acdef.h"
#include "acmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"

#include "ECmsg.h"
/*
 * Includes of function prototypes.
 */
%safe
#ifndef X11
#include <FIproto_pub.h>
#else
#include <XFIproto_pub.h>
#endif
%endsafe

#define EM_SESSION_STARTUP	0
#define EM_DGNFILE_STARTUP	1

/*
 * "Update dependency of reference files" form.
 */
#define EM_UPDREFILES_FORM	"EMupdRefDep"
#define EM_TEXT1		12
#define EM_TEXT2		13
#define EM_TEXT3		14
#define EM_TEXT4		15
#define EM_REFFILES_FIELD	16

extern int	UI_error			__(( char * )) ;
extern long	ASsuper_construct		__(( void )) ;

IGRint EMchkRefFilesNotification( form_label, gadget, value, form )
IGRint	        form_label ;
IGRint  	gadget ;
IGRdouble	value ;
IGRchar 	*form ; 
{
IGRlong	msg ;
IGRint	resp;
 
    switch( gadget ) 
    {
    case FI_ACCEPT:
	EMcheckRefFilesDependency( &msg, TRUE, NULL, NULL ) ;
			/* No break on purpose */

    case FI_CANCEL	:
	FIf_delete( form ) ;
	resp =  EX_FORM_FINISHED ;
        ex$putque(msg	= &msg,
		response= &resp ) ;
	break ;

    default:
         break ;
    }

    return FI_SUCCESS ;

} /* EMchkRefFilesNotification */

IGRint EMupdChkRefFilesForm( refCount, refList )
IGRint	refCount ;
OMuword *refList ; 
{
IGRchar		*form ;
IGRint		rc, i;
IGRchar		osname[OM_K_MAXOSNAME_LEN];
IGRchar		msg_buff[81] ;

    rc = FIf_new( 1,
        	EM_UPDREFILES_FORM,
		EMchkRefFilesNotification,
		&form ) ;

    if( rc != FI_SUCCESS ) 
        goto wrapup ;

    ex$message ( msgnumb = EMS_I_UpdRff_Tx1, buff = msg_buff );
    FIg_set_text( form, EM_TEXT1, msg_buff ) ;

    ex$message ( msgnumb = EMS_I_UpdRff_Tx2, buff = msg_buff );
    FIg_set_text( form, EM_TEXT2, msg_buff ) ;

    ex$message ( msgnumb = EMS_I_UpdRff_Tx3, buff = msg_buff );
    FIg_set_text( form, EM_TEXT3, msg_buff ) ;

    ex$message ( msgnumb = EMS_I_UpdRff_Tx4, buff = msg_buff );
    FIg_set_text( form, EM_TEXT4, msg_buff ) ;

    rc = FIfld_set_num_rows( form, EM_REFFILES_FIELD, refCount ) ;
    if( rc != FI_SUCCESS ) goto wrapup ;

    for( i = 0 ; i < refCount ; i++ ) 
    {
	om$os_number_to_name(	osnum   = refList[i],
       				osname  = osname ) ;

       	FIfld_set_text( form, EM_REFFILES_FIELD, i, 0, osname, FALSE ) ;
    }
    rc = FIf_display( form ) ;

wrapup :
    if( rc != FI_SUCCESS ) 
    {
	if( form ) 
            FIf_delete( form ) ;
	rc = FALSE ;
    } 
    else	rc = TRUE ;

    return rc;
} 

method init( int type ; char *s ) 
{
    me->mytype = type ;
    return OM_S_SUCCESS ;
}

method execute(	int *response ; char *response_data ; int pos ) 
{
IGRlong	msg, sts ;

    nd$mod_broadcast(	request     = ND_SET,
			req_mode    = ND_NO_BROAD_DEL ) ;

    if( me->mytype == EM_SESSION_STARTUP ) 
    {
	goto wrapup;
    } 
    else if( me->mytype == EM_DGNFILE_STARTUP ) 
    {
    int		nbModRef ;
    OMuword	*modRefList = NULL;

	ASsuper_construct() ;

		/*
		 * Should this file reference other files, see if this file
		 * has structural elements depending upon objects in the other
		 * files; if so perform update of dependent elements in this
		 * file if parent objects in the reference files have been
		 * modified. Also if objects in this file consume elements
		 * in reference files, reconsume them since they come up
		 * as not consumed.
		 */
	nbModRef = 0 ;
	if( !ex$is_batch() ) 
        {
		/*
		 * `EX_MAX_INVIS_MODULE' is not a constant but a
		 * global, hence we must allocate the memory.
		 */
		modRefList = (OMuword *) 
				malloc(EX_MAX_INVIS_MODULES * sizeof(OMuword));

		if( modRefList ) 
                {
			sts = EMcheckRefFilesDependency(&msg,
						FALSE,
						&nbModRef,
						modRefList ) ;
			if( !( sts & msg & 1 ) )
			{
				goto wrapup;
			}
		}
	}

	if( nbModRef ) 
        {
	int rc ;

		rc = EMupdChkRefFilesForm( nbModRef, modRefList ) ;
		if( !rc ) 
                {
			/*
			 * Form creation failed: force update anyway.
			 */
			EMcheckRefFilesDependency( &msg, TRUE,
						   NULL, NULL ) ;
		} 
                else 
                {
			do
			{
				ex$wait_for_input(
						response= response,
						buffer	= response_data,
						mode	= EX_ALL_ASCII_MODE,
						byte	= &rc ) ;
			} while( *response != EX_FORM_FINISHED ) ;
		}
	}
	if ( modRefList )  free ( modRefList );

    } /* Else any other type may be used to have some .o file
         dynamically loaded.
        */

wrapup:
    *response = TERMINATE ;

    return OM_S_SUCCESS ;

} 

end implementation EMstrtup ;
