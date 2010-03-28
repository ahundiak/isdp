
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:34 $
$Locker:  $
*/

class specification DPusrlnstl (1:0) of global_class;

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "dpdls.h"

instance DPusrlnstl
	{
	unsigned short patterns[(MAX_STYLES - BUILTIN_STYLES)];
	};

override super_construct, wake_up, sleep;

end specification DPusrlnstl;
