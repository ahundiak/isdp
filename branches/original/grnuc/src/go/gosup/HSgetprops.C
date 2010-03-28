/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

IGRint HSgetprops( properties )

IGRuint *properties;

/*
DESCRIPTION
	Get properties word from dpb
*/

{

   IGRint            msg;
   IGRint            nbytes_in_buffer;
   IGRint            nbytes_transfered;

   nbytes_in_buffer = sizeof( IGRint );
				/* get properties from dpb	*/
   gr$get_hidden_surf_sym(msg =  &msg,
                           sizbuf = &nbytes_in_buffer,
                           buffer = properties,
                           nret = &nbytes_transfered );

   return( 1 & msg);
}
