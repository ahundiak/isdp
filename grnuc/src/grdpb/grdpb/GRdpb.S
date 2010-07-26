/*
  DESCRIPTION

  This class defines the Default Parameter Block, which is used
  to store system defaults for many types of data. The messages
  defined here are used to communicate with the Default Parameter
  Block.  It is recommended that applications use the macros
  provided in grdpbmacros.h rather than these messages.


  HISTORY

  pth     03/01/86    design date
  mrm     05/01/91    Redesigned for extensibility.  Also removed
                      IGEcolsup as parent, since the only apparent
                      need was to override color_table_changed to
                      update the old rgb value in data.display to
                      reflect the new color table.
*/

class specification GRdpb (2:0) of global_class;

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "gr.h"
#include "ex.h"
#include "grdpbdef.h"
#include "grdpb.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

instance GRdpb
{
    IGRlong layer[32];
    variable unsigned char data[];
    variable struct GRelclass elclass[];
    variable OMuword classids[];
};


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

message GRget
(
  IGRint *msg;
  IGRint parameter;
  IGRchar *buffer;
);

#ifndef BASE_EMS

message GRput
(
  IGRint *msg;
  IGRint parameter;
  IGRchar *buffer;
);

message GRputname
(
  IGRlong *msg;
  struct var_list *var_list;
);

message GRgetname
(
  IGRlong *msg;
  struct var_list *var_list;
);

message GRcheckclass
(
  IGRlong *msg;
  OMuword classid;
);

message atp_debug
(
);

override
  super_construct,   
  wake_up,           
  sleep,             
  delete,            
  debug;             

#endif

end specification GRdpb;
