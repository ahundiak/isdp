class implementation tst_dir;

#include <stdio.h>

#include "OMminimum.h"
#include "OMerrordef.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"

method test_pass ( int *Count )
{
  *Count = *Count + 1;
  return OM_S_SUCCESS;
}


end implementation tst_dir;

