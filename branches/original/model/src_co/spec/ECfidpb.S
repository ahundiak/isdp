/* ###################   APOGEE COMPILED   ################## */
class specification ECfidpb (1:0) of super_cmd ;

# include "OMminimum.h"
# include "OMerrordef.h"
# include "igrtypedef.h"

/* ******************************************************************

 Description
    This command object class is responsible for communicating
 with the form related to accessing ems dpb parameters

 History
     PP : 04/29/88              Redesigned the command object to allow
                                for the form to be converted to a window
                                and be active when the form disappears
     PP : 02/22/88              Added code to disenable writing to
                                the message fields, to fix the 
                                whitening of the fields during exit
     PP : 10/19/87              Creation

   ****************************************************************** */


instance ECfidpb
{
};


override
 execute, sleep, wakeup;

end specification ECfidpb;
