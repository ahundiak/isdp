#include "ECmsg.h"
#include "ECcmd.h"

class implementation ECmisc;

%safe
IGRint _debug_jacobian = 0;
IGRint _debug_jacobian_file = 0;
IGRint _debug_graph_decompose = 1;
%endsafe

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  if (me->mytype == 100)
    {
      ex$message ( msgnumb = EMS_S_GraphAnalysisOn);
      /* SKgraph_on (); */
      _debug_graph_decompose = 1;
    }
  else if (me->mytype == 101)
    {
      ex$message ( msgnumb = EMS_S_GraphAnalysisOff);
      /*  SKgraph_off ();  */
      _debug_graph_decompose = 0;
    }
  else if (me->mytype == 102)
    {
      if (_debug_jacobian)
      {
        ex$message ( msgnumb = EMS_S_DebugJacobianOff);
        _debug_jacobian = 0;
      }
      else
      {
        ex$message ( msgnumb = EMS_S_DebugJacobianOn);
        _debug_jacobian = 1;
      }
    }
  else if (me->mytype == 103)
    {
      if (_debug_jacobian_file)
      {
        ex$message ( msgnumb = EMS_S_DebugJacfileOff);
        _debug_jacobian_file = 0;
      }
      else
      {
        ex$message ( msgnumb = EMS_S_DebugJacfileOn);
        _debug_jacobian_file = 1;
      }
    }

  *response = TERMINATE;
  return (OM_S_SUCCESS);
}

end implementation ECmisc;
