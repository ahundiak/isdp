/* #######################    APOGEE COMPILED   ######################## */
/*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
*/ 


/* 
     
     GRSetRgTrans

*/

command_string  GRMSetActDir,"ARCDIR,0,1",GRCCrDr
synonym         GRMSetAD,"ARCDIR,0,1",GRCCrDr  
synonym         GRMSetBoreLoc,"BORELINE,0,1",GRTgBrLc
synonym         GRMSetAppProjOn,"APPFLGON,0,1",GRTrOnApPr
synonym         GRMSetAppProjOff,"APPFLGOFF,0,1",GRTrOfApPr
synonym	        GRMSetAbsMeaOn,"ABSFLGON,0,1",GRTrOnAbMs
synonym         GRMSetAbsMeaOff,"ABSFLGOFF,0,1",GRTrOfAbMs
synonym		GRMDynAllCur,"DYNALL,0,1",GRTgDyMdAl
synonym		GRMDynOnOff,"DYNON,0,1",GRTgDyMdIn
synonym		GRMTrOnRFLc,"RFLCON,0,1",GRTrOnRFLc
synonym		GRMTrOfRFLc,"RFLCOF,0,1",GRTrOfRFLc
class		COlocks
super_class	CEO
start_state	start
product_name	"$SOURCE"
options 	"SITC"

specification

/******************************************************************************

Description:

	This command provides the user interface for the following commands:

     1. apparent flag   
     2. arc direction         
     3. bore locate           
     4. absolute measurment flag
     5. text view independence on
     6. text view independence off
     7. dynamics on/off
     8. dynamics all windows/singl e window

Abstract class:		No.

Override methods:	None.

Messages:

	message toggle_lock();

History:	Jay Wallingford     11/23/87  Design and Implementation

Bugs:		No know bugs.

Algorithm:

Notes:

    COMMAND TABLE ENTRIES FOR GRSetTran:
   -----------------------------------------------------------------
    cmd_str                       cmd_t       cmd_key        cmd_class  
   --------------------------------------------------------------------        
    set arc direction             GRSetArcD   71              COlocks
   --------------------------------------------------------------------
    set borelocate                GRTgBrLc   72              COlocks
   --------------------------------------------------------------------
    set apparent flag on          GRTrOnApPr   73              COlocks
   --------------------------------------------------------------------
    set apparent flag off         GRTrOfApPr   74              COlocks
   --------------------------------------------------------------------
    set absolute measurment on    GRSetAbsMeaOn 75            COlocks
   --------------------------------------------------------------------
    set absolute measurment off   GRSetAbsMeaOn 76            COlocks
   --------------------------------------------------------------------

*******************************************************************************/

#include "coimport.h"
#include <stdio.h>
#include <ctype.h>
#include <msdef.h>
#include <ms.h>
#include <msmacros.h>
#include <igr.h>
#include <igrdp.h>
#include <grmessage.h>
#include <godef.h>
#include <gr.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>
#include <grmessage.h>
#include "COerr.h"
#include "COlocksdef.h"

implementation

#include "coimport.h"

state_table

#include "COlocksdef.h"
#include <grmessage.h>

state start 

     execute toggle_lock

on SUCCESS                                          state terminate
on ERROR            do status_key GR_E_ErrEncCmdTrm state terminate

action toggle_lock
{
     IGRboolean               flag = FALSE;
     IGRlong                  ok;                         
     IGRlong                  buffersize;
     IGRlong                  nret;
     IGRlong   	              l;
     IGRlong                  mask = DPB_LOCATE_ON, properties;
     struct GRdpb_text_symb   text_symb;

     *sts = OM_S_SUCCESS;

     switch (me->mytype)
     {
          case ARCDIR:

               /* 
                * Get current arc direction 
                */
               buffersize = sizeof(IGRboolean);
               status = gr$get_arc_direction( msg = &ok,
                                              sizbuf = &buffersize,
                                              buffer = &flag,
                                              nret = &nret);
               _error_ck2(status,ok,sts);
                /* 
                * Toggle the direction 
                */
               flag ^= 1;
          
               /* 
                * Update the direction 
                */
               status = gr$put_arc_direction( msg = &ok,
                                              sizbuf = &buffersize,
                                              buffer = &flag);
               _error_ck2(status,ok,sts);

               /* 
                * Construct the arc direction message.
                */
               l = (flag) ? GR_I_ArcDirCcw : GR_I_ArcDirCw;
              break;

#ifndef IDRAW
           case BORELINE:
                /* 
                * Get borelocate status 
                */
               buffersize = sizeof(IGRboolean);
               status = gr$get_bore_locate( msg = &ok,
                                            sizbuf = &buffersize,
                                            buffer = &flag,
                                            nret = &nret);
               _error_ck2(status,ok,sts);

               /* 
                * Toggle borelocate status 
                */
               flag ^= 1;

               /* 
                * Update borelocate status 
                */
               status = gr$put_bore_locate( msg = &ok,
                                            sizbuf = &buffersize,
                                            buffer = &flag);
               _error_ck2(status,ok,sts);

               /* 
                * Set the message.
                */
               l = (flag) ? GR_I_BorLocOn : GR_I_BorLocOff;

               break;

           case APPFLGON:
               flag = TRUE;

           case APPFLGOFF:
               /* 
                * Set apparent flag. 
                * NOTE: flag is initialize to FALSE so it is not 
                *       set here.
                */
               buffersize = sizeof(IGRboolean);
               gr$put_apparent_flag(msg = &ok,
                                    sizbuf = &buffersize,
                                    buffer = &flag);
               _error_ck2(status,ok,sts);

               /*
                * Set the message.
                */
               l = (flag) ? GR_I_AppFlgOn : GR_I_AppFlgOff;

               break;

           case ABSFLGON:
               flag = TRUE;
          
           case ABSFLGOFF:
               /* 
                * Set absolute flag.
                * NOTE: flag is initialized to FALSE so it is not
                *       set here.
                */
               buffersize = sizeof(IGRboolean);
               gr$put_local_abs_flag(msg = &ok,
                                    sizbuf = &buffersize,
                                    buffer = &flag);
               _error_ck2(status,ok,sts);

               /* 
                * Set the message.
                */
               l = (flag) ? GR_I_AbsFlgOn : GR_I_AbsFlgOff;

               break;
   
          case TXINDON:
               flag = TRUE;
 
          case TXINDOFF:

               /* 
                * Get the active text symbology. 
                */
               buffersize = sizeof(struct GRdpb_text_symb);
               status = gr$get_text_symb(msg = &ok,
                                         sizbuf = &buffersize,
                                         buffer = &text_symb,
                                         nret = &nret);
               _error_ck2(status,ok,sts);
          
               if ( flag ) text_symb.Active_flags |= 0x0001;
               else text_symb.Active_flags &= 0xfffe;

               status = gr$put_text_symb(msg = &ok,
                                         sizbuf = &buffersize,
                                         buffer = &text_symb );

               _error_ck2(status,ok,sts);

               /* 
                * Set the message.
                */
               l = (flag) ? GR_I_TxtIndOn : GR_I_TxtIndOff;

               break;

#endif /* IDRAW */

          case DYNON:

               buffersize = sizeof(IGRboolean);
               status = gr$get_dynamics_on(msg = &ok,
                                           sizbuf = &buffersize,
                                           buffer = &flag,
                                           nret = &nret );
               _error_ck2(status,ok,sts);

               flag ^= 1;

               status = gr$put_dynamics_on(msg = &ok,
                                           sizbuf = &buffersize,
                                           buffer = &flag );
               _error_ck2(status,ok,sts);

               l = flag ? GR_I_DynOn : GR_I_DynOff;
               break;

#ifndef IDRAW

          case DYNALL:

               buffersize = sizeof(IGRboolean);
               status = gr$get_dynamics_all_windows( msg = &ok,
                                                     sizbuf = &buffersize,
                                                     buffer = &flag,
                                                     nret = &nret );
               _error_ck2(status,ok,sts);

               flag ^= 1;

               status = gr$put_dynamics_all_windows( msg = &ok,
                                                     sizbuf = &buffersize,
                                                     buffer = &flag );
               _error_ck2(status,ok,sts);

               l = flag ? GR_I_DynAllWin : GR_I_DynSngWin;
               break;

#endif /* IDRAW */

          case RFLCOF:
               l = GR_I_RFLcOf;
               mask = ~DPB_LOCATE_ON;
          case RFLCON:
               {
               struct dpb_var_list var_list;
               IGRlong which_error;

               if ( mask == DPB_LOCATE_ON ) l = GR_I_RFLcOn;

               var_list.var = DPB_PROPERTIES;
               var_list.var_ptr = &properties;
               var_list.num_bytes = sizeof(IGRint);
               var_list.bytes_returned = &nret;

               status = gr$set_inq ( var_list = &var_list,
                                     which_error = &which_error, 
                                     ascii_key = "ref file header",
                                     msg = sts,
                                     count = 1 );

               if ( !(status & 1) ) 
               {
                    *sts = OM_E_ABORT;
                    goto quit;
               }

               if ( me->mytype == RFLCON )
                    properties |= mask;
               else
                    properties &= mask;

               status = gr$set_inq ( set_inq = DPB_SET,
                                     var_list = &var_list,
                                     which_error = &which_error, 
                                     ascii_key = "ref file header",
                                     msg = sts,
                                     count = 1 );

               if ( !(status & 1) ) 
               {
                    *sts = OM_E_ABORT;
                    goto quit;
               }
               }
               break;

          default:
               *sts = OM_E_ABORT;
               goto quit;
               break;
     }

     /* 
      * Construct and display the appropriate message.
      */
     ex$message(msgnumb = l,
		field = ERROR_FIELD,
                justification = CENTER_JUS,
                seconds = 25);
}


