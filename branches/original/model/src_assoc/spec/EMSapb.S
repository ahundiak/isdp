/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This class is intended to be the super governing certain global
    characteristics and variables dealing with associativity in EMS.

    The following are the uses of this DPB so far:
    1) Holds running indices for 5 categories of nameable items. These
       derive their system names using these numbers.

  HISTORY

    SS  :  03/16/91  :  Creation
*/

class specification EMSapb (2:0) of global_class;

#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "exdef.h"
#include "ex.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "igrdp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "EMSerrordef.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"

instance EMSapb
  {
  IGRuint running_index[5];
  };

message EMgetrunindex (IGRint type; IGRint *index);

override 
  super_construct, delete;

end specification EMSapb;
 

