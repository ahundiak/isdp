/* #######################    APOGEE COMPILED   ######################## */

/******************************************************************************

Description:

    These methods support the text justification status display form.

Methods:

    set_gadgets

Overrides:

    from CEO form_notification

History:

    jay wallingford     03/15/89    creation date

******************************************************************************/
class implementation COattr;
 
#include <coimport.h>
#include <FI.h>
#include <exdef.h>

#define LO_JUST           0
#define HI_JUST          14

#define JUST_0      13
#define JUST_1      14
#define JUST_2      15
#define JUST_3      16
#define JUST_4      17
#define JUST_5      18
#define JUST_6      19
#define JUST_7      20
#define JUST_8      21
#define JUST_9      22
#define JUST_10     23
#define JUST_11     24
#define JUST_12     25
#define JUST_13     26
#define JUST_14     27

method set_gadgets()
{
    IGRint status = OM_S_SUCCESS, just;

    status = om$send ( msg = message COdpb.get ( (int *)&me->ret,
                                                 CO_just,
                                                 (char *)&just,
                                                 CO_integer ),
                       targetid = my_id );
    _err_ck2(status,me->ret);

    FIg_set_state_on ( me->status_display_form_ptr, JUST_0 + just);

quit:

    return ( status );
}

method form_notification (int form_label; int gadget_label; double value; char * form_ptr  ) 
{
     IGRint                   status;
     IGRint                   response;
     IGRlong                  buffersize, ok;
     IGRdouble                d;

     switch ( gadget_label ) 
     {
     case JUST_0:   case JUST_1:   case JUST_2:
     case JUST_3:   case JUST_4:   case JUST_5:
     case JUST_6:   case JUST_7:   case JUST_8:
     case JUST_9:   case JUST_10:  case JUST_11:
     case JUST_12:  case JUST_13:  case JUST_14:
         
          /*
           * Set the text justification.
           */
          d = gadget_label - JUST_0;
          buffersize = sizeof(IGRdouble);
          response = EX_VALUE;

          ex$putque ( msg = &ok,
                      response = &response,
                      byte = &buffersize,
                      buffer = (char *)&d );
          break;
     }

     /*
      * Erase the status display form.
      */                                            
     status = om$send ( msg = message CEO.erase_form_by_label(form_label,0,(int *)&ok),
                        targetid = my_id );
     _err_ck2(status,ok);

quit:         
     return ( OM_S_SUCCESS );
}

end implementation COattr;
