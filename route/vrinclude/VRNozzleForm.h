/* $Id: VRNozzleForm.h,v 1.2 2001/01/12 20:48:46 anand Exp $ */

/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:        vrinclude/VRNozzleForm.h
 *
 * Description:
 *
 *  Include file for Nozzle 
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VRNozzleForm.h,v $
 *     Revision 1.2  2001/01/12 20:48:46  anand
 *     SP merge
 *
 * Revision 1.5  2000/09/06  23:19:06  pinnacle
 * Replaced: route/vrinclude/VRNozzleForm.h for:  by apazhani for Service Pack
 *
 * Revision 1.4  2000/08/17  18:47:54  pinnacle
 * Replaced: route/vrinclude/VRNozzleForm.h for:  by apazhani for Service Pack
 *
 * Revision 1.3  2000/07/13  23:03:06  pinnacle
 * Replaced: route/vrinclude/VRNozzleForm.h for:  by apazhani for Service Pack
 *
 * Revision 1.2  2000/07/10  19:02:42  pinnacle
 * Replaced: route/vrinclude/VRNozzleForm.h for:  by apazhani for Service Pack
 *
 * Revision 1.1  2000/05/11  21:56:56  pinnacle
 * Created: route/vrinclude/VRNozzleForm.h by apazhani for Service Pack
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      05/10/2000       Alwin        Added Acoustic Insulation gadgets
 *      05/11/2000       Alwin        Added Button to copy params from duct
 *      07/10/2000       Alwin        Added few gadgets related to Rway Nozzle
 *      07/13/2000       Alwin        Added ACST in HVAC Nozzle Attr. form
 *      08/17/2000       Alwin        Added NOZ_UNIT_NUMBER in Nozzle Attr. form
 *				      for both PIPING & HVAC
 *      09/06/2000       Alwin        Changed the gadget number of COPY Params 
 *				      to 100 to use the same gadget for both
 *				      PIPING and HVAC.
 *
 * -------------------------------------------------------------------*/

#define	TAG_NUMBER	15
#define	SERVICE		31
#define	NOMINAL_SIZE	16
#define	END_COND	17
#define PRESSURE_CLASS	18
#define	SCHDL_THK	19
#define	END_STAND	20
#define	APPRV_STS	21
#define	CONST_STS	22
#define	NOZZLE_ATTR	11
#define SPEC_NAME	60
#define	SYSTEM_NAME	23
#define	SEQ_NUMBER	24
#define	FLUID   	25
#define	ZONE_NB		26
#define SCHDL_THK_OVRD	27
#define	INSUL_TYPE	28
#define	INSUL_THIK	29
#define	TRACING_TYPE	30
#define	PAINT_TYPE	31
#define	RESET_BTN	54           /* cr179528329 */
#define	PLC_PIPING_NOZ	70
#define	MOD_PIPING_NOZ	53
#define	COPY_PARAMS_BTN	100		/* added for CR179900995 */


/* Hvac added karine */
#define	WIDTH		16
#define	DEPTH		17
#define	NOZZLE_AIRFLOW	18
#define	END_PREP	20
#define	HPRESSURE_CLASS	23
#define	SIZING_METHOD	24
#define	AIR_FLOW	25
#define	MAX_VELOCITY	26
#define	MAX_DEPTH	27
#define	DUCT_MATERIAL	28
#define	DUCT_THICK	29
#define	INSUL_MATERIAL	30
#define	HINSUL_THICK	31
#define	ACST		148

/* following gadgets added for acoustical insulation. CR179901312 */
#define	ACOUSTICAL_MATERIAL	22
#define	ACOUSTICAL_THICK	34

#define	ZONE		41
#define	EXP_WIDTH	37
#define	EXP_DEPTH	38
#define	EXP_AIR_FLOW	39
#define	EXP_END_PREP	19
#define	PLC_HVAC_NOZ	70
#define	MOD_HVAC_NOZ	40

/****** Fields added to get the expressions names  ******/

#define	EXP_TAG_NUMBER	34
#define	EXP_SERVICE	36
#define	EXP_NOM_SIZE	37
#define	EXP_END_COND	38
#define	EXP_PRESSURE	39
#define	EXP_SCH_THK	40
#define	EXP_END_STAND	41
#define EXP_GROUP	111

#define	OPER_TEMP	41
#define	OPER_PRESSURE	42
#define	DGN_TEMP	43
#define	DGN_PRESS	44
#define	SPECIFIC_GRAV	45
#define APPRO_STS	46
#define	CONSTR_STS	47
#define	WEIGHT_GRP	48
#define	CHANGE_NO	49
#define	USER_ATTR	67
#define TYPE		72
#define NOZ_PID_SCALE       49
#define NOZ_PID_SCALE_TXT   48

#define RWAY_NOZ_SHAPE	29
#define RWAY_NOZ_MACRONAME 23
#define RWAY_NOZ_WIDTH   160
#define RWAY_NOZ_DEPTH   170
#define	RWAY_NOZ_TRAY_MATERIAL	28
#define	RWAY_NOZ_TRAY_THICK	11
#define	RWAY_NOZ_THROAT_RAD	27
#define	RWAY_NOZ_TRANS_LEN	15
#define	RWAY_NOZ_CORN_RAD	31
#define	RWAY_NOZ_UNIT		41
#define	RWAY_NOZ_ZONE		19
#define PLC_RWAY_NOZ	 111
#define MOD_RWAY_NOZ	 161

/* defining UNI_NUMBER gadget for both PIPING and HVAC */
#define	NOZ_UNIT_NUMBER		37
