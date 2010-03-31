/* #######################    APOGEE COMPILED   ######################## */
/*\
Abstract
   This class represents a drawing view that will be used as a parent of
   a section view.  This class of drawing view does not allow itself to
   be rotated.

History
   WBC :  02/13/92 :  Create Date
\*/

class specification EMSdrawview (2:0) of GRdrawview;

override
   GRxform_owner;               /* GRowner -  class specific          */

end specification EMSdrawview;
