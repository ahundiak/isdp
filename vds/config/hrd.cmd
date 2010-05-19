/* $Id: hrd.cmd,v 1.2 2001/01/24 22:53:52 build Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:        vds/config/hrd.cmd
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: hrd.cmd,v $
 *      Revision 1.2  2001/01/24 22:53:52  build
 *      *** empty log message ***
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:23  cvs
 *      Initial import to CVS
 *
:: Revision 1.1  1998/04/29  16:27:20  pinnacle
:: VDS 2.5.1
::
:: Revision 1.4  1997/12/31  17:55:18  pinnacle
:: Replaced: config/hrd.cmd for:  by jwfrosch for vds
::
:: Revision 1.3  1997/11/26  16:36:40  pinnacle
:: Replaced: config/hrd.cmd for:  by v250_int for vds
::
:: Revision 1.2  1997/10/07  14:29:54  pinnacle
:: Replaced: config/hrd.cmd for:  by yzhu for vds
::
:: Revision 1.1  1997/05/08  13:20:44  pinnacle
:: New project VDS 250
::
:: Revision 1.1  1996/07/19  20:33:52  pinnacle
:: Create VDS 241 project
::
:: Revision 1.1  1995/12/06  15:42:52  pinnacle
:: Created: config/hrd.cmd by jwfrosch for vds.240
::
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *************************************************************************/

/*
 * I/VDS Command Table gathering all the commands that do not come
 * from a slic (ie hard coded command table)
 * 
 * 
 *      VDCmdupdbox ->  VDCmdupdbox,0,512,,,VDS.o
 *      VDCmdUpdbEq ->  VDCmdUpdEq,0,512,,,VDS.o
 *      SMCmdCvtFrm ->  SMCmdCvtFrm,0,512,,,VDS.o
 *      SMCmdCvtCmp ->  SMCmdCvtCmp,0,512,,,VDS.o
 *
 */

#include "SMcmd.h"
#include "VDcmd.h"
#include "AScmd.h"

/*
 * Override of I/EMS "Review / Define Macro Library" command
 */

AC_M_RvMcLb,VDRvMcLb,VDm_lib,0

/*
 * Startup and switchprod/swaptask pulldown menu.
 */
^"Vds",IMTkInit,COci,0,0,,"BLANK"
^"Vds",IMTkVd,COci,0,0,,"VDswaptask IMTkVd IMVDS BAR_VDS POCKET_MODEL"
^"Sman",IMTkSm,COci,0,0,,"VDswaptask IMTkSm IMSMAN BAR_VDS POCKET_MODEL"

/*
 * Inherited command from I/EMS.
 */
"Modify Macro Definition",VDMdMcDf,COm_modif,0	

/*
 * Startup checking routines.
 */
VDC_M_CvtFrmTxt,VDCnTxLd,VDCmdupdbox,0,512,,,VDS.o
VDC_M_CvtRtCmp,VDChRtDsFs,VDrtupdcls,0,512,,,VDS.o
SMC_M_CvtCmpDB,SMCnCmFrDB,SMCmdCvtCmp,0,512,,,VDS.o
SMC_M_CvtPlnSys,SMCnPlSs,SMCmdCvtFrm,0,512,,,VDS.o

/*
 * Supported SMAN commands.
 */


SMC_M_PlBndSf2,VDPlBnSr,VDCmdBound,0
SMC_M_PlHoleSf,VDPlBnOp,VDCmdHole,0
SMC_M_MdHoleSf,VDMdBnOp,VDCmdHole,1

/*
 * Supported VDS commands
 */
VDC_M_AuPlFrTx,VDAuPlForTx,VDCmdAutxt,20
VDC_M_CrEdTbPr,VDCrEdTbPr,VDCmdTable,0
VDC_M_ExDr,VDExDr,VDm_drawing,0
VDC_M_ExDrFr,VDExDrFr,VDCmdDrwFr,0
VDC_M_UptDra,VDUpDw,VDm_rextrac,0
VDC_M_PlFrLdLn,VDPlFrLdLn,VDCmdtxldr,20
VDC_M_PlItNm,VDPlItNm,VDCmditem,21
VDC_M_PlEq,VDPlEquip,VDm_place,0
VDC_M_RpDr,VDRpDr,VDCmdDirFrm,0
VDC_M_PlWlSy,VDPlWlSy,VDweld,25
"Modify Drawing Frame",VDMdDrFr,VDCmdDrwFr,1
"Elements in Current File",GRSlAlF,COgrpevent,0
"Elements in All Files",GRSlAlE,COgrpevent,100
