class implementation IGEgragad;

#include "grimport.h"

method DPshading_allowed( IGRboolean *flag )

{	
	*flag = TRUE;
	return( OM_S_SUCCESS );
}

method DPhidden_line_allowed( IGRboolean *flag )

{	
	*flag = TRUE;
	return( OM_S_SUCCESS );
}

end implementation IGEgragad;
