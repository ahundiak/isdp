/* $Id: VRppfrrpCmd.sl,v 1.1.1.1 2001/01/04 21:12:58 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrnetworkco/VRppfrrpCmd.sl
 *
 * Description:
	 "Piping From To Report" command.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRppfrrpCmd.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:58  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.3  1997/03/05  20:05:44  pinnacle
# Replaced: vrnetworkco/VRppfrrpCmd.sl for:  by lawaddel for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1995/12/08  21:22:54  pinnacle
# Replaced: vrnetworkco/VRppfrrpCmd.sl for:  by r240_int for route240
#
 *
 * History:
 *	12/06/95	tlb		Remove VRcmd.h
 *      03/05/97        law     TR#179603615-change prompt for from-to report.
 *
 *************************************************************************/

command_string	VRC_M_GnPpFTRp,0,VRGnPpFTRp
class		VRppfrrpCmd
super_class	VRGenRepCmd
product_name	"$ROUTE"
command_table	"route.cmd"

specification

instance 
{
}

implementation

#include "OMmacros.h"
#include "OMprimitives.h"
#include "msmacros.h"
#include "VRparamdef.h"
#include "VRmsg.h"
#include "VRreports.h"
#include "AS_status.h"

extern	som_vla_set_dimension();

#define AS_DEBUG

state_table

#include "VRmsg.h"

#define TRUE  1
#define FALSE 0

#define VR_K_FileIsDirectory	0x01
#define VR_K_FileExist		0x02
#define VR_K_CantCreateFile	0x04

/* TR#179603615-change prompt for from-to report. */
state start
	execute 		init_cmd( &me->ret )
	message_key		VR_M_GnPpFTRp
	prompt_key		VR_P_SelTipNetWrk
	locate_class		"VRPComp | VRPCComp"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_COMP
				 | LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_REF_OBJECTS"
	/*
	 * Accept locate by name.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
	filter			locate

		on EX_DATA or
		   EX_OBJID   do store_component	       state getFileName


state getFileName
	prompt_key		VR_P_KeyOutFile
	filter			get_event

		on EX_BACK_UP				       state start

		on EX_STRING  do store_file_name( &me->ret )
					on RETURN_CODE = VR_K_FileIsDirectory
					do status_key VR_E_InvFileIsDir
							       state .
					on RETURN_CODE = VR_K_FileExist
							       state OverFile
							       state DoOperation

state OverFile
	prompt_key		VR_P_OverFile
	filter			get_event

		on EX_STRING  do check_response( &me->ret )
					on RETURN_CODE = FALSE state -
							       state DoOperation


state DoOperation

		on ELSE       do open_file( &me->ret )
					on RETURN_CODE = VR_K_CantCreateFile
					do status_key VR_E_CantCreateFile
							       state getFileName
			      do fill_file		       state start


/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/
action init_cmd {
	/*
	 * Initialize instances data.
	 */
	me->file_ptr		= NULL ;
	me->component._objid	= NULL_OBJID ;
	me->component_number	= 1 ;
	me->page_number 	= 1 ;
	me->nb_of_rows		= 0 ;

  ex$message( msgnumb	= VR_I_Piping,
		buff	= me->RepMesName );
  /*" MesName: <%s>\n", me->RepMesName */

  /* set systen name type */
  me->RepSysName[0] = '\0';

  /* layout 
   *                   WIDTH WIDTH INSUL INSUL HEAT  FLUID      
   *   ITEM COMP CLASS GREEN RED   TYPE  THK   TRACE CODE   
   */   

  /* set header lines */
  sprintf(me->RepParName1, "%*c", strlen( VRstrcatMsg(  VR_I_Item, 
							VR_I_Comp, 
							VR_I_Class,
							VR_I_Zone, -1)),' ');

  strcat( me->RepParName1, VRstrcatMsg( VR_I_Seq, 
					VR_I_Diam,
					VR_I_Diam,
					VR_I_Insul,
					VR_I_Insul,
					VR_I_Heat,
					VR_I_Fluid, -1 ) ) ;

  strcpy( me->RepParName2, VRstrcatMsg( VR_I_Item,
					VR_I_Comp,
					VR_I_Class,
					VR_I_Zone,
					VR_I_Number,
					VR_I_Green,
					VR_I_Red,
					VR_I_Type,
					VR_I_Thk,
					VR_I_Trace,
					VR_I_Code, -1 ) ) ;


  /* set the attributes */
  strcpy( me->RepValue[0].att_txt,  VR_N_AABBCC_AN );
  strcpy( me->RepValue[1].att_txt,  VR_N_CLASS_AN );
  strcpy( me->RepValue[2].att_txt,  VR_N_ZONE_AN );
  strcpy( me->RepValue[3].att_txt,  VR_N_SEQ_NUMBER_AN );
  strcpy( me->RepValue[4].att_txt,  VR_N_GDIAMETER_DB );
  strcpy( me->RepValue[5].att_txt,  VR_N_RDIAMETER_DB );
  strcpy( me->RepValue[6].att_txt,  VR_N_INSUL_TYPE_AN );
  strcpy( me->RepValue[7].att_txt,  VR_N_INSUL_THK_DB );
  strcpy( me->RepValue[8].att_txt,  VR_N_TRACING_CODE_AN );
  strcpy( me->RepValue[9].att_txt,  VR_N_FLUID_CODE_AN );

  me->RepValue[0].type =  VR_REP_STR;
  me->RepValue[1].type =  VR_REP_STR;
  me->RepValue[2].type =  VR_REP_STR;
  me->RepValue[3].type =  VR_REP_STR;
  me->RepValue[4].type =  VR_REP_FLO_4_1_INCH;
  me->RepValue[5].type =  VR_REP_FLO_4_1_INCH;
  me->RepValue[6].type =  VR_REP_STR;
  me->RepValue[7].type =  VR_REP_FLO_4_1_INCH;
  me->RepValue[8].type =  VR_REP_STR;
  me->RepValue[9].type =  VR_REP_STR;
  me->RepValue[10].type =  VR_REP_NOT_DEF;


  status = om$vla_set_dimension( varray = me->IdLoop,
				 size   = 0 ) ;

  as$status() ;

} /* init_cmd */
/*----------------------------------------------------------------------------*/
/* end of file								      */
/*----------------------------------------------------------------------------*/
 

