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

/*\
Abstract	

    This command provides the user interface for the toggle locks commands.

Notes

History

     Jay Wallingford     11/23/87  Design and Implementation


\*/
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
synonym		GRMCFlMdFl,"FILMOD,0,1",GRCFlMdFl
synonym         GRMCTxFlMdF,"TXFILMOD,0,1",GRCTxFlMdF
class		COattr
super_class	COtools
super_class	COdpb
super_class	CEO_LOCATE
spec_path       "$GRNUC/co/spec"
start_state	start
product_name	"$SOURCE"
options 	"siTC"

state_table

#include "attrco.h"
#include <grmessage.h>

state start 

     execute toggle_lock

on SUCCESS                                          state terminate
on ERROR            do status_key GR_E_ErrEncCmdTrm state terminate

