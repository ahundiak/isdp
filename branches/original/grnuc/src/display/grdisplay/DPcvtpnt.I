/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
     CLASS  NAME  IGEgragad

     METHOD NAME  convert_pnt
 
     Abstract:  This method converts a data point from screen dit to
                world coordinate system.
-----
%SC%

        convert_pnt (&pnt)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        *pnt    struct GRbigpoint Address of a data point in IGDS format.

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

----
%MD%
     MODULES AND METHODS INVOKED:

     Modules:

     Methods:

-----
%RL%

     RELATIONS REFERENCED :
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:

        czn  03/28/86  : Creation date.
        czn  04/25/86  : change to add the resulting data point to 
                         the event queue.
        mrm  10/02/91    Took out the $*!# beep and sleep
-----
%PD%
--------------------------------------------------------------------
              M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

class implementation IGEgragad;

#include "grimport.h"
#include "OMmacros.h"
#include "exdef.h"
#include "ex.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "execmsg.h"

/* prototype files */
%safe
#include "dpcvrtpnt.h"
#include "exproto.h"
%endsafe

method convert_pnt (long *msg; int *response; struct EX_button *inpnt)
{
    IGRdouble   point[3];
    IGRboolean  valid_point;
    IGRlong     status;
    IGRlong	byte_count;
    IGRint	dit_point[3];

    if (((inpnt->x > ME.IGEgadget->max_x_dep) ||
         (inpnt->x < ME.IGEgadget->min_x_dep)) ||
        ((inpnt->y > ME.IGEgadget->max_y_dep) ||
         (inpnt->y < ME.IGEgadget->min_y_dep)))
    {
        return(OM_S_SUCCESS);
    }   

    point[0] = inpnt->x;
    point[1] = inpnt->y;
    point[2] = ME.IGEgragad->gragad.act_z_screen;

    if (!(status = DPconv_pnt(msg,&ME.IGEgragad->gragad,point,dit_point,
                              &valid_point,OM_Gw_current_OS)))
    {
        status = OM_E_ABORT;
        goto finish;
    }

    if (valid_point)
    {
        /*
         *  Format a data point.
         */

        inpnt->x = point[0];
        inpnt->y = point[1];
        inpnt->z = point[2];

        inpnt->window = ME.IGEgadget->win_no;
        inpnt->objid = my_id;
        inpnt->osnum = OM_Gw_current_OS;

        byte_count = sizeof (struct EX_button);
        *response |= EX_HARDWARE_GENERATED;
        EXputq_back (msg, response, &byte_count, (IGRchar *)inpnt);
    }
    else
    {
#ifdef BEEP
        EX_bell();
#endif
        ex$message (msgnumb = GR_E_PtOutVwVol);
#ifdef BEEP
        sleep(3);
        ex$message (msgnumb = EX_S_Clear);
#endif
    }

    status = OM_I_STOP_SENDING;

finish:
    return (status);
}

end implementation IGEgragad;
