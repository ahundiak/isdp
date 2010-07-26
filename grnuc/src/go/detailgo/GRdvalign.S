/* #######################    APOGEE COMPILED   ######################## */
/*\
Abstract
   This class associates two drawing views.  The drawing views are
   associated through a line which defines the alignment of the drawing
   view origins.

History
   Gray Winn   06/20/88    Design and Coding Date.
\*/

class specification GRdvalign (1:0) of GRlistener;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"

instance GRdvalign
{
   IGRint      properties;       /* Alignment properties                */
   IGRpoint    vector;           /* Direction vector used for alignment */
   channel
   {
      (many_to_many,
       rel_ordered,
       initial=2,
       increment=2)
    } to_notify;                 /* Associates the drawing views        */
};

override GRnotifylis;

/*\
Name
   GRdvalign_init

Description
   This method initialize the connections between the two drawing
   views.

Arguments
   *msg        IGRlong        o   return code
   *dv_id1     struct GRid    i   drawing view one
   *dv_id2     struct GRid    i   drawing view two
   vector      IGRpoint       i   vector defining the alignment of the two
                                  drawing views.

Return Values
   MSSUCC   -  if success
   MSFAIL   -  if failure
\*/
message GRdvalign_init (IGRlong *msg; struct GRid *dv_id1; 
                        struct GRid *dv_id2; IGRpoint vector);

/*\
Name
   GRdvalign_pass_msg

Description
   This method passes a message to a drawing view.  The method passes
   the message to the drawing view that did not send the original
   pass message.

Arguments
   *msg        IGRlong        o   return code
   pass_msg    OM_p_MESSAGE   i   pass message

Return Values
   MSSUCC   -  if success
   MSFAIL   -  if failure
\*/
message GRdvalign_pass_msg (IGRlong *msg; OM_p_MESSAGE pass_msg);

/*\
Name
   GRdvalign_mark

Description
   This method marks a drawing view alignment object so that only
   messages from the given drawing view will be passed.

Arguments
   *msg        IGRlong        o   return code
   *da_id      struct GRid    i   drawing attachment id

Return Values
   MSSUCC   -  if success
   MSFAIL   -  if failure
\*/
message GRdvalign_mark (IGRlong *msg; struct GRid *da_id);

/*\
Name
   GRdvalign_drop_alignment

Description
   This method drops the drawing view alignment.

Arguments
   *msg        IGRlong        o   return code

Return Values
   MSSUCC   -  if success
   MSFAIL   -  if failure
\*/
message GRdvalign_drop_alignment (IGRlong *msg);

end specification GRdvalign;
