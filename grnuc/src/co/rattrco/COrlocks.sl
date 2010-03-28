/* #######################    APOGEE COMPILED   ######################## */
command_string	GRMSetRasTranOn,"RGTRANSON,0,1",GRSetTrnOn
synonym   	GRMSetRasTranOff,"RGTRANSOFF,0,1",GRSetTrnOf
synonym 	GRMSetRasFastOn,"RGFASTDISP,0,1",RSSCnDsPTF
synonym 	GRMSetRasFastOff,"RGREGDISP,0,1",RSSCnDsPTR
synonym         GRMSetRasBordOn,"RGBORDDISPON,0,1",RSTOnCBDP
synonym         GRMSetRasBordOff,"RGBORDDISPOFF,0,1",RSTOfCBDP
synonym         GRMSetRasGridOn,"RGGRIDLINEON,0,1",RSTrOnCnGr
synonym         GRMSetRasGridOff,"RGGRIDLINEOFF,0,1",RSTOnCGLDP
synonym         GRMSetRasAutoDefOn,"RGAUTODEFON,0,1",RSTrOnAtCn
synonym         GRMSetRasAutoDefOff,"RGAUTODEFOFF,0,1",RSTrOfAtCn
synonym         GRMSetRasFillModOn,"RGFILLON,0,1",RSTrOnCnFl
synonym         GRMSetRasFillModOff,"RGFILLOFF,0,1",RSTrOfCnFl
class          COrlocks
product_name   "$SOURCE"
super_class    CEO
path           "."
start_state    start
options	       "SITC"

specification

/******************************************************************************

Description:		This command provides the user interface for the 
			following commands:

		1. set raster transparency on  
		2. set raster transparency off
		3. set raster fast display 
		4. set raster regular display
		5. set raster border display on
		6. set raster border display off
		7. set raster grid line on
		8. set raster grid line off
		9. set auto define on
		10.set auto define off
		11.set fill mode on
		12.set fill mode off

Abstract class:		No.

Messages:
	
	message toggle_lock(int * sts);

History:	jay wallingford	11/21/87	Design and implementation
                scott walters   07/14/92        Ansi conversion

Bugs:		No know bugs.

Algorithm:	

Notes:

    COMMAND TABLE ENTRIES FOR GRSetTran:
   -----------------------------------------------------------------
    cmd_str                       cmd_t       cmd_key        cmd_class  
   --------------------------------------------------------------------        
    set raster transparency on    GRSetTrnOn  1              COattr
   --------------------------------------------------------------------
    set raster transparency off   GRSetTrnOf  2              COattr
   --------------------------------------------------------------------
    set raster fast display       RSSCnDsPTF  3              COattr
   --------------------------------------------------------------------
    set raster regular display    RSSCnDsPTR  4              COattr
   --------------------------------------------------------------------
    set raster border display on  RSTOnCBDP  5              COattr
   --------------------------------------------------------------------
    set raster border display off RSTOfCBDP  6              COattr
   --------------------------------------------------------------------
    set raster grid line on       RSTrOnCnGr  7              COattr
   --------------------------------------------------------------------
    set raster grid line off      RSTOnCGLDP  8              COattr
   --------------------------------------------------------------------
    set auto define on            RSTrOnAtCn  9              COattr
   --------------------------------------------------------------------
    set auto define off           RSTrOfAtCn  10             COattr
   --------------------------------------------------------------------
    set fill mode on              RSTrOnCnFl  11             COattr
   --------------------------------------------------------------------
    set fill mode off             RSTrOfCnFl  12             COattr
   --------------------------------------------------------------------
   
*******************************************************************************/

#include <grmessage.h>
#include <ctype.h>
#include <ODE.h>
#include <msdef.h>
#include <msmacros.h>
#include <igrdef.h>
#include <igrdp.h>
#include <gr.h>
#include <godef.h>
#include <go.h>
#include <griodef.h>
#include <grio.h>
#include <griomacros.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>
#include <bsvalues.h>
#include <dpdef.h>
#include <wl.h>
#include <igecolor.h>
#include <igecolmacros.h>
#include <OMerrordef.h>
#include <exmacros.h>
#include <COerr.h>
#include "COrlocksdef.h"

implementation

#include "coimport.h"

state_table

#include <grmessage.h>
#include "COrlocksdef.h"

state start 

     execute toggle_lock

on SUCCESS                                          state terminate
on ERROR            do status_key GR_E_ErrEncCmdTrm state terminate

action toggle_lock
{
     /* temporary attribute variables */
     struct GRrgdpb           raster_symb;

     IGRlong                  ok;                         
     IGRlong                  buffersize;
     IGRlong                  nret;
     IGRlong   	              l = 0;

     /* 
      * Get the active raster symbology.
      */
     buffersize = sizeof( struct GRrgdpb );
     status = gr$get_raster_graphics( msg = &ok,
                                      sizbuf = &buffersize,
                                      buffer = &raster_symb,
                                      nret = &nret);
     _error_ck2(status,ok,sts);

     switch (me->mytype)
     {
          case RGTRANSON:
               raster_symb.rg_props |= GRIS_TRANSPARENT;
               l = GR_I_RgBckTran;
               break;

          case RGTRANSOFF:
               raster_symb.rg_props &= (~GRIS_TRANSPARENT);
               l = GR_I_RgBckNTran;
               break;

          case RGFASTDISP:
               raster_symb.rg_props |= GRIS_FASTDIS;
               l = GR_I_RgFastDisp;
               break;

          case RGREGDISP:
               raster_symb.rg_props &= (~GRIS_FASTDIS);
               l = GR_I_RgRegDisp;
               break;

          case RGBORDDISPON:
               raster_symb.rg_props |= GRIS_BORDDIS;
               l = GR_I_RgBorDisp;
               break;

          case RGBORDDISPOFF:
               raster_symb.rg_props &= (~GRIS_BORDDIS);
               l = GR_I_RgNBorDisp;
               break;

          case RGGRIDLINEON:
               raster_symb.rg_props |= GRIS_PARTDIS;
               l = GR_I_RgGridOn;
               break;

          case RGGRIDLINEOFF:
               raster_symb.rg_props &= (~GRIS_PARTDIS);
               l = GR_I_RgGridOff;
               break;

          case RGAUTODEFON:
               raster_symb.auto_def = TRUE;
               l = GR_I_RgADefOn;
               break;

          case RGAUTODEFOFF:
               raster_symb.auto_def = FALSE;
               l = GR_I_RgADefOff;
               break;

          case RGFILLON:
               raster_symb.fill_mode = TRUE;
               l = GR_I_RgFillOn;
               break;

          case RGFILLOFF:
               raster_symb.fill_mode = FALSE;
               l = GR_I_RgFillOff;
               break;

     }

     /*
      * Update the raster data parameter block.
      */
     buffersize = sizeof( struct GRrgdpb );
     status = gr$put_raster_graphics( msg = &ok,
                                      sizbuf = &buffersize,
                                      buffer = &raster_symb);
     _error_ck2(status,ok,sts);

     /* Construct the appropriate raster toggle message */
     ex$message(msgnumb = l,
		field = ERROR_FIELD,
                justification = CENTER_JUS,
                seconds = 25);
}


