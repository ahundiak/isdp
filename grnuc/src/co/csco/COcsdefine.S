/* #######################    APOGEE COMPILED   ######################## */



/*
Abstract
        This command object services all three of the define 
        coordinate system commands:
            o Define coordinate system by 3 points
            o Define coordinate system by view alignment
            o Define coordinate system by element plane

Notes
        COMMAND TABLE entries for COcsdefault
        -------------------------------------------------
        command                   str_ptr       cmd_flag
        =================================================
        def cs by 3 points      COcsdefine        1
        -------------------------------------------------
        def cs by view alignm   COcsdefine        2
        -------------------------------------------------
        def cs by elem plane    COcsdefine        3
        -------------------------------------------------

History 
        Kumar Talluri  10/15/86 : Design date and Implementation.
                       10/25/86 : added define cs by 3 pts command.
                       11/08/86 : added define cs by elem plane command.
*/

class specification COcsdefine (1:0) of COconst;

#include "igr.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "igr.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "DIdef.h"

instance COcsdefine
{
    IGRchar             csname[DI_PATH_MAX];   /* to hold the name of CS */
    IGRchar             csdesc[60];     /* description */
    IGRshort            mx_defined;     /* control flag */
    IGRdouble           point1[3];
    IGRdouble           point2[3];               
    IGRpoint            origin;         /* of coordinate system */
    IGRmatrix           matrix;         /* of coordinate system */

    /* the following variables are for "Define cs from element plane" */

    IGRlong             size;           /* size GRevent struct */
    struct GRevent      loc_event;      /* locate point struct */
    struct GRlc_locate  loc_attr;       /* locate attributes;class,levels */
    struct GRlc_stack   locate_stack;   /* stack structure */
};

override init, wakeup, execute;

end specification COcsdefine;
