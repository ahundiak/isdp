class implementation EMSsfcapsf;


# include "EMS.h"
# include "OMmacros.h"


/*

DESCRIPTION

  This method fills the EMSdbssi_size structure so that EMgetSSibuffer
  may be called to malloc the exact size of the buffer.

Return values
  size - pointer to the structure
  EMmsg - EMS_S_Success for success in evaluating the size of a
            consistent SSI table
          EMS_I_Success for success in evaluating the size of an
            inconsistent SSI table for a boolean with wholly
            removed operands.
          EMS_E_InvalidArg if this boolean's type is unknown
          EMS_E_Fail if analyzing the type fails entirely

Notes
  This method assumes that the referenced instance data has valid values.

HISTORY

  11/10/1992  :  AMD  :  Creation


*/


method EMgetSSIsize(IGRlong *EMmsg; union EMSssiSizeData *size)

{
  struct EMScapssi_size    *my_size;
  *EMmsg = EMS_S_Success;

  my_size = &size->cap_info;

  my_size->num_edges = ME.EMSsfcapsf->num_edges;

 return (OM_S_SUCCESS);

}

end implementation EMSsfcapsf;
