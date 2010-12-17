/*RIS*.h files are used in the 2.1 build.*/
#ifdef bld21
#include "RISdbs_err.h"
#include "RIStrn_err.h"
#include "RISdic_err.h"
#include "RISerror.h"
#include "RISlimits.h"
#define RIS_E_DUPLICATE_VALUE	RISdbs_DUPLICATE_VALUE
#define RIS_E_TABVIEW_ALREADY_EXISTS	RISdbs_TABVIEW_ALREADY_EXISTS
#define RIS_E_DUP_ATTR_NAME	RIStrn_DUP_ATTR_NAME
#define RIS_E_UNKNOWN_RELATION	RISdic_UNKNOWN_RELATION
#define RIS_E_ATTR_NOT_FOUND    RISdbs_ATTR_NOT_FOUND
#else
#include "ris_err.h"
#include "net_err.h"
#include "utl_err.h"
#include "rislimit.h"
#endif
