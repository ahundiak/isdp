/* $Id: VRdbcodlst.h,v 1.2 2001/01/12 20:48:54 anand Exp $ */

/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:        route/vrinclude/VRdbcodlst.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VRdbcodlst.h,v $
 *      Revision 1.2  2001/01/12 20:48:54  anand
 *      SP merge
 *
 * Revision 1.2  2000/07/20  16:26:08  pinnacle
 * Replaced: route/vrinclude/VRdbcodlst.h for:  by apazhani for Service Pack
 *
 * Revision 1.1  2000/07/10  19:03:16  pinnacle
 * Created: route/vrinclude/VRdbcodlst.h by apazhani for Service Pack
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      07/10/2000      Alwin           Added code list 145 for material list
 *      07/20/2000      Alwin           Added code list 221 for Piping 
 *					insulation thickness list. CR179901615
 * -------------------------------------------------------------------*/

#ifndef vrdbcodlst_include

#define vrdbcodlst_include

/* This file defines the codelist numbers used by ROUTE */

/* PIPING */

#define      VR_P_NOZ_SRV_LSTNUM         316
#define      VR_P_END_COND_LSTNUM        331
#define      VR_P_PRES_CLASS_LSTNUM      321
#define      VR_P_SCHED_THK_LSTNUM       325
#define      VR_P_END_STD_LSTNUM         579
#define      VR_P_APP_STS_LSTNUM         35
#define      VR_P_CONST_STS_LSTNUM       130
#define      VR_P_TRACE_TYPE_LSTNUM      200
#define      VR_P_PAINT_TYPE_LSTNUM      190
#define      VR_P_WEIGHT_GRP_LSTNUM      1520
#define      VR_P_CHANGE_NO_LSTNUM       1510
#define      VR_P_FLUID_CODE_LSTNUM      125
#define      VR_P_INSUL_TYPE_LSTNUM      220
#define      VR_P_INSUL_THICK_LSTNUM     221

/* RACEWAY */

#define	     VR_R_SYSTEM_CLASS_LSTNUM	 125 /* Added for CR179900853 */
#define	     VR_R_MATERIAL_CLASS_LSTNUM	 145 /* Added for Raceway Nozzle */

#endif
