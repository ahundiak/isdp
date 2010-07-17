/*
	I/STRUCT
	"Generate ... Report" commands.
*/
command_string	VSC_M_VSGnWlRpMd,0,VSGnWlRpMd
synonym		VSC_M_VSGnBmRpMd,1,VSGnBmRpMd
synonym		VSC_M_VSGnPlRpMd,2,VSGnPlRpMd
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSreportCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "lcdef.h"
#include "VSmsg.h"
#include "vsdef.h"
#include "vscmddef.h"

#define	VS_JN_REPORT	0	/* Reports on joints	*/
#define	VS_BM_REPORT	1	/* Reports on beams	*/
#define	VS_PL_REPORT	2	/* Reports on plates	*/

state start
	on CMD_TYPE = VS_JN_REPORT
		do message_key		VS_M_VSGnWlRpMd
		state			main
	on CMD_TYPE = VS_BM_REPORT
		do message_key		VS_M_VSGnBmRpMd
		state			main
	on CMD_TYPE = VS_PL_REPORT
		do message_key		VS_M_VSGnPlRpMd
		state			main

state main
	execute		createFileForm( &me->ret )
				on ERROR	
					do status_key VS_E_ErrEncCmdTrm
					state terminate
				on ELSE		state KeyInFileName

state KeyInFileName
	prompt_key	VS_P_KyRpFlNm
	filter		get_event
		on GR_UNKNOWN_TYPE.VS_K_FILE_ACCEPTED
			do fileFormDismissed( VS_K_FILE_ACCEPTED )
			state setupFilter

		on GR_UNKNOWN_TYPE.VS_K_FILE_CANCELED
			do fileFormDismissed( VS_K_FILE_CANCELED )
			state terminate

		on ELSE	state .

state setupFilter
	on CMD_TYPE = VS_JN_REPORT
		do prompt_key		VS_P_IdJnOrGr
		do setupActionHandler(	&me->ret,
					VS_K_filterFeature_LCAH,
					VS_m_JOINT )
		state			getObjects
	on CMD_TYPE = VS_BM_REPORT
		do prompt_key		VS_P_IdBmOrGr
		do setupActionHandler(	&me->ret,
					VS_K_filterFeature_LCAH,
					VS_m_BEAM )
		state			getObjects
	on CMD_TYPE = VS_PL_REPORT
		do prompt_key		VS_P_IdPlOrGr
		do setupActionHandler(	&me->ret,
					VS_K_filterFeature_LCAH,
					VS_m_PLATE )
		state			getObjects

state getObjects
	locate_class		"+VSfeature"
	accept_key		VS_P_AccRej
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	/*
	 * Rigid component will be not located by a fence without the
	 * flag LC_RIGID_COMP_PRISM.
	 */
	locate_owner		"  LC_RIGID_COMP
				 | LC_RIGID_COMP_PRISM
				 | LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_REF_OBJECTS"
	/*
	 * Accept locate by name.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
	filter			locate_noauto
		on EX_DATA
			do store_operand( &me->ret, 0 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do operation( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do discard_all_input( &me->ret )
			state main

		on EX_OBJID
			do process_fence( &me->ret, VS_K_OPRND )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do operation( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do discard_all_input( &me->ret )
			state main

		on EX_BACK_UP
			do discard_all_input( &me->ret )	  state main

at wakeup	do fileFormOnOffOut( 1 )
at sleep	do fileFormOnOffOut( 0 )
at delete	do fileFormOnOffOut( 2 )
/*----------------------------------------------------------------------------*/
