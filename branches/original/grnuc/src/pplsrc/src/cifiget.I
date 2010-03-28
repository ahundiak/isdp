/* -- This module handles putting and getting data from forms.
   -- */
class implementation ci ;

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "exdef.h"
#include "exmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "FI.h"
#include "stdio.h"
#include "exmacros.h"
#include "exfi.h"

%safe
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

static int CIform_id __((char *name, Form *id));

#if defined(__cplusplus)
}
#endif
#undef __
%endsafe



/*----------------------------------------------------------------------------*/
static int CIform_id( name, id ) char *name ; Form *id ; {

int rc;

rc = FI_get_form_by_name (name, id);
return (rc == FI_SUCCESS);

} /* CIform_id */
/*----------------------------------------------------------------------------*/
#argsused
int CIgetform( stat, form, data )	long			*stat	;
					char			*form	;
					struct EXFI_data_st	*data	; {

/* -- Gets "data" in "form".
      IN  : form, name of form.
	    data, data to get.
      OUT : completion code (to be examined if function returns FALSE).
      RET : TRUE if OK, else FALSE.
   -- */
	Form		formid;		/* Id of form		*/
	int		rc;		/* Return code	*/

	if( CIform_id( form, &formid ) ) {
		rc = CIfm_get( formid, data ) ;
	} else {
		rc = FALSE ;
	}
	return rc ;

} /* CIgetform */
/*----------------------------------------------------------------------------*/

end implementation ci ;

