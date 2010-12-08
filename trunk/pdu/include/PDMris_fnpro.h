#include "PDUris_incl.h"

/* "sql.h" renamed "ris.h" in RIS V5. 28/Feb/95 - raj. */
#if defined ( RISV4 )
#include "sql.h"
#elif defined ( RISV5 )
#include "ris.h"
#include "RISprototype.h"
#else
#error "RIS version must be defined"
#endif
