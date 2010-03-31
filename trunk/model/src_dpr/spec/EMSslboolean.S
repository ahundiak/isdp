/*
  ABSTRACT

  This is constructed class which represents a boolean operation on
  solids.


  HISTORY

  09/08/88 DLB :  Removed left hand inheritance of EMsfsfint.  Can do this 
                  since EMsfsfint override at EMSsfboolean has been removed.
  19-May-1988 jBk Added EMsolidFromNonIntersectingClosedSurfaces.
  11-May-1988 SM  inherit the EMScompsurf implementation of
                  EMsfsfint.  The implementation at EMSsfboolean,
                  if the node is save side, sends the message down
                  only to index 0. We do not want that for a solid
                  because in case of a solid, the save side plane
                  is also part of the result.
  22-Sep-1987 DLB 1.1.0 class conversion
  13-May-1987 jBk Added EMget_operation_type message.
  05-Apr-1987 AIC Modified ancestry.
  09-Mar-1987 AIC Creation Date
*/

class specification EMSslboolean (1:0) of EMSsldpr, EMSsfboolean;

/*------------------ INSTANCE DATA SECTION -------------------*/

override 
  GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMsolidFromNonIntersectingClosedSurfaces
(
  IGRlong *rc;
  struct GRmd_env env[1];
  OM_S_OBJID surf1;
  OM_S_OBJID surf2;
  struct GRvg_construct constructList[1];
  IGRushort booleanOptions;
);

from EMSsldpr inherit 
  GRgeomprops, 
  GRreport, 
  GRreport_defaults,
  GRupdate_gadgets;

override
   EMoperandChanged,
   EMgetRI;         

reject 
  EMadd;   

#endif

end specification EMSslboolean;
