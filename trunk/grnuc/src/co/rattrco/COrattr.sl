/* #######################    APOGEE COMPILED   ######################## */

/******************************************************************************

Description:		This class implements commands to change any of the 
			following attributes:
	
			     1. raster foreground color
			     2. raster background color

Abstract class:		No.

Override methods:	from CEO_LOCATE

			wakeup

Messages:
	
	message show_attribute();
	message set_attribute(int * sts);

History:	jay wallingford	11/21/87	Design and implementation
						Added commands for setting 
						raster attributes.
                scott walters   07/14/92        Ansi conversion
                eddie pike      02/12/93        integrate WL

Bugs:		No know bugs.

Algorithm:	

Notes:

    COMMAND TABLE ENTRIES FOR COrattr:
   -----------------------------------------------------------------
    cmd_str                            cmd_key        cmd_class  
   -----------------------------------------------------------------
    set raster composite memory        1                COrattr
   -----------------------------------------------------------------
    set raster foreground color        2                COrattr
   -----------------------------------------------------------------
    set raster background color        3                COrattr
   -----------------------------------------------------------------
   
*******************************************************************************/

class          COrattr
product_name   "$SOURCE"
super_class    CEO_LOCATE
path           "."
start_state    terminate
options	       "SItc"
 
specification

implementation

#include "coimport.h"
#include <griomacros.h>
#include <COerr.h>
#include <ctype.h>
#include <ODE.h>
#include <msdef.h>
#include <msmacros.h>
#include <grmessage.h>
#include <igrdef.h>
#include <igrdp.h>
#include <godef.h>
#include <go.h>
#include <griodef.h>
#include <grio.h>
#include <griomacros.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>
#ifndef MAXLONG
#define MAXLONG 2147483647
#endif
#include <bsvalues.h>
#include <dpdef.h>
#include <wl.h>
#include <igecolor.h>
#include <igecolmacros.h>
#include <OMerrordef.h>
/*#include <fidef.h>*/
#include <drawparam.h>
#include <exmacros.h>
#include <fontdef.h>
/*#include <fi.h>*/
/*#include <fidef.h>*/
#include <lcdef.h>
#include <lc.h>
#include <cotxmacros.h>
#include "COrattrdef.h"

action wakeup
{

     /* 
      * Send wakeup to parent.
      */
     status = om$send (targetid = my_id,
                       msg = message CEO_LOCATE.wakeup ( pos ),
                       mode = OM_e_wrt_message );

     /* 
      * If the command is being reentered. 
      * NOTE: All COrattr commands have a message displaying the current 
      *       command except when a command is entered with an argument.
      */
     if ( me->msg[0] != NULL ) 
     {
          /*
           * Show the attribute in the message field.
           * NOTE: This should only be done when a command doesn't have
           *       a form and doesn't have a argument on the queue.
           */
          status = om$send (targetid = my_id,
                            msg = message COrattr.show_attribute ());
     }
}

action show_attribute()
{
     /* temporary attribute variables */
     struct GRrgdpb           raster_symb;

     /* temporary flags and macros arguments */
     IGRboolean               flag=FALSE;
     IGRlong                  ok;                         
     IGRlong                  buffersize;
     IGRlong                  l = 0, nret;
     IGRushort                su = 0;
     IGRchar                  str[80];

     /* 
      * Get the active raster symbology.
      */
     buffersize = sizeof( struct GRrgdpb );
     status = gr$get_raster_graphics( msg = &ok,
                                      sizbuf = &buffersize,
                                      buffer = &raster_symb,
                                      nret = &nret);
     _err_ck2(status,ok);

     flag = FALSE;
     switch ( me->mytype )
     {

          case RGREFMEMLIM:
               /* Construct the composite raster memory message */
               ex$message(msgnumb = GR_I_ActRgMem,
                          buff = me->status,
                          type = "ld",
                          var = `raster_symb.comprast_memory`);
               break; 

           case RGFORECOLOR:
               flag = TRUE;
               su = raster_symb.fg;
               l = GR_I_RgActForCo;

           case RGBACKCOLOR: /* Not Implemented */
               if ( !flag )
               {
                    su = raster_symb.bg;
                    l = GR_I_RgActBacCo;
               }
              
               if ( su == 0 )
               {
                     strcpy(str,"background");
               }
               else
               {
                    /* 
                     * Get name of Active Color if one exits.
                     */
                    ige$get_name_from_color(color = ( su - 1),
                                            name = str,
                                            mod_id = me->ModuleInfo.md_id.objid,
                                            mod_osnum = me->ModuleInfo.md_id.osnum);
               }
               /* 
                * Construct the Active Color (and it's name) message.
                */
               ex$message(msgnumb = l,
                          buff = me->status,
                          type = "%u%s",
                          var = `su ,str`);
               break;
     } 

     /* 
      * Update the status field.
      */
     ex$message(justification = CENTER_JUS,
                field = ERROR_FIELD,
                in_buff = me->status,
                seconds = 25);
}
     
action set_attribute
{
     /* temporary attribute variables */
     struct GRrgdpb           raster_symb;

     /* temporary flags and macros arguments */
     IGRboolean               error=FALSE;
     IGRlong                  ok;                         
     IGRlong                  buffersize;
     IGRlong                  nret;
     IGRushort                su;

     /* 
      * Get the active raster symb.
      */
     buffersize = sizeof( struct GRrgdpb );
     status = gr$get_raster_graphics( msg = &ok,
                                      sizbuf = &buffersize,
                                      buffer = &raster_symb,
                                      nret = &nret);
     _error_ck2(status,ok,sts);

     switch ( me->mytype )
     {
           case RGREFMEMLIM:
               if ( me->event1.response == EX_VALUE )
               {
                    /* 
                     * See if memory size is in range 
                     */
                    if ( (me->event1.event.value > 0) && 
                         (me->event1.event.value <= MAXLONG) )
                    { 
                         raster_symb.comprast_memory = (IGRlong) me->event1.event.value;
                    }	
                    else
                    {
                         *sts = COATTR_INVINP;
                         error = TRUE;
                    }
               }
               else
               {
                    *sts = OM_E_ABORT;
                    error = TRUE;
               }
               break;
               
          case RGBACKCOLOR: 
          case RGFORECOLOR:
               /*
                * Note: Raster color numbers are 1 greater than vector color numbers. 
                */
               switch ( me->event1.response )
               {

                    case EX_VALUE:
                         /* 
                          * See if the input color is legal 
                          */
                         if ( (me->event1.event.value >= LO_COLOR) &&
                              (me->event1.event.value <= (HI_COLOR+1)) ) 
                         {
                              su = (IGRushort) (me->event1.event.value);
                         }
                         else
                         {
                              *sts = COATTR_INVINP;
                              error = TRUE;
                         }
                         break;

                    case EX_STRING:
                         if ( !strcmp(me->event1.event.keyin, "background") || 
                              !strcmp(me->event1.event.keyin, "bg"))
                         {
                              su = 0;
                         }
                         else
                         {
                              /* 
                               * Attempt to get a number from the color name 
                               */
                              ok = ige$get_color_from_name(name = me->event1.event.keyin,
                                                      color = (IGRshort *) &su,
                                                      mod_id = me->ModuleInfo.md_id.objid,
                                                      mod_osnum = me->ModuleInfo.md_id.osnum);
                              if ( !(ok&1) ) 
                              {
                                   *sts = COATTR_INVINP;
                                   error = TRUE;     
                              }
                              else
                              {
                                   su++;
                              }
                          }
                          break;

                     default:
                         *sts=OM_E_ABORT;
                         error = TRUE;
                         break;
                    
               }
          
               /* 
                * If no error occured and input was a legal color 
                */
               if ( !error )
               { 
                    /* 
                     * Update Active Color locally 
                     */
                    if ( me->mytype == RGFORECOLOR ) raster_symb.fg = su;
                    else raster_symb.bg = su;
               }
               break;
     }         

     /* 
      * If no error occured update raster graphics 
      */
     if ( !error )
     {
          buffersize = sizeof( struct GRrgdpb );
           status = gr$put_raster_graphics( msg = &ok,
                                           sizbuf = &buffersize,
                                           buffer = &raster_symb);
          _error_ck2(status,ok,sts);
     }
}

