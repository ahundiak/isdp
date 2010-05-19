/* $Id: VDPalDef.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDPalDef.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDPalDef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
	I/STRUCT
	Miscellaneous utility macros.
*/

#ifndef VDPalDef_include
#define VDPalDef_include

#include <standards.h>



/*
	Is everybody not redefining those ?
*/

#define _MALLOC( nelem, type )	\
	(type *) malloc( (unsigned) ( (nelem) * sizeof( type ) ) )

#define _FREE( pointer )	if( (pointer) ) free( (char *) (pointer) )

/*
 * Infix of macro library names         <PREFIX><INFIX>* (ed. "ETclib2")
 */
#define VD_K_ifxPalFil  "pal"

/*
 * Standard directory in search path where palettes and macro libraries are
 * search for. The "%s" in VS_K_stdPalDir is to be replaced by the local
 * language used.
 */
#define VD_K_stdMacDir  "ppl/bin"
#define VD_K_stdPalDir  "config/%s/palettes"

/*
 *	Standard prefixes
 */

	/* PIPING */

#define	VD_K_pfxPump	"PMP"	/* Pump 		*/
#define	VD_K_pfxCompr	"CMP"	/* Compressor 		*/
#define	VD_K_pfxEngine	"ENG"	/* engine 		*/
#define	VD_K_pfxTurbine	"TRB"	/* turbine 		*/
#define	VD_K_pfxHeatEx	"HEX"	/* heat ex 		*/
#define	VD_K_pfxBoiler	"BLR"	/* boiler 		*/
#define	VD_K_pfxMotor	"MTR"	/* motor 		*/
#define	VD_K_pfxReactor	"RCT"	/* reactor 		*/
#define	VD_K_pfxJet	"JET"	/* jet apparat 		*/
#define	VD_K_pfxJack	"JCK"	/* jack 		*/
#define	VD_K_pfxTank	"TNK"	/* tank 		*/
#define	VD_K_pfxWeapon	"WPN"	/* weapon 		*/
#define	VD_K_pfxPipPnt	"PPT"	/* penetration 		*/
#define	VD_K_pfxPipU1	"PU1"	/* user 		*/
#define	VD_K_pfxPipU2	"PU2"	/* user 		*/
#define	VD_K_pfxPipU3	"PU3"	/* user 		*/
#define	VD_K_pfxPipU4	"PU4"	/* user 		*/


	/* HVAC */

#define	VD_K_pfxHvUnit	"HAU"	/* Air unit		*/
#define	VD_K_pfxHvHeat	"HHT"	/* Heater		*/
#define	VD_K_pfxHvConds	"HCN"	/* Condenser		*/
#define	VD_K_pfxHvComps	"HCM"	/* Compressor		*/
#define	VD_K_pfxHvEvap	"HEV"	/* Evaporator		*/
#define	VD_K_pfxHvPnt	"HPT"	/* Penetration 		*/
#define	VD_K_pfxHvU1	"HU1"	/* User			*/
#define	VD_K_pfxHvU2	"HU2"	/* User			*/
#define	VD_K_pfxHvU3	"HU3"	/* User			*/
#define	VD_K_pfxHvU4	"HU4"	/* User			*/
#define	VD_K_pfxHvAiCln "HAC"	/* Air cleaner		*/
#define	VD_K_pfxHvFan	"HFN"	/* fan 			*/
#define	VD_K_pfxHvHumid "HHM"	/* Humidifier		*/
#define	VD_K_pfxHvCool  "HCL"	/* Cooler		*/
#define	VD_K_pfxHvBoil	"HBL"	/* Boiler		*/
#define	VD_K_pfxHvFurn	"HFR"	/* Furnace		*/
#define	VD_K_pfxHvRefrg	"HRF"	/* refrigerator		*/



	/* ELECTRICAL */

#define	VD_K_pfxElJnBox	"EJB"	/* junction		*/
#define	VD_K_pfxElTrnsf	"ETR"	/* transformer		*/
#define	VD_K_pfxElMotor	"EMT"	/* motor		*/
#define	VD_K_pfxElPnt	"EPT"	/* penetration		*/
#define	VD_K_pfxElU1	"EU1"	/* User			*/
#define	VD_K_pfxElU2	"EU2"	/* User			*/
#define	VD_K_pfxElU3	"EU3"	/* User			*/
#define	VD_K_pfxElU4	"EU4"	/* User			*/
#define	VD_K_pfxElPanl	"EPN"	/* panel		*/
#define	VD_K_pfxElSwtBr	"ESW"	/* switchboard		*/
#define	VD_K_pfxElGenrt	"EGN"	/* Generator		*/
#define	VD_K_pfxElCtrDv "ECD"	/* control device 	*/
#define	VD_K_pfxElBrk	"EBR"	/* breaker		*/



/*
 *	Standard indices 
 */

	/* PIPING */


#define	VD_K_pfxPmp	0	
#define	VD_K_pfxCmp	1	
#define	VD_K_pfxEng	2	
#define	VD_K_pfxTrb	3	
#define	VD_K_pfxHex	4	
#define	VD_K_pfxBlr	5	
#define	VD_K_pfxMtr	6
#define	VD_K_pfxRct	7
#define	VD_K_pfxJt	8
#define	VD_K_pfxJk	9
#define	VD_K_pfxTk	10
#define	VD_K_pfxWpn	11
#define	VD_K_pfxPpt	12
#define	VD_K_pfxPu1	13
#define	VD_K_pfxPu2	14
#define	VD_K_pfxPu3	15
#define	VD_K_pfxPu4	16


	/* HVAC */

#define	VD_K_pfxHvAu	21
#define	VD_K_pfxHvHt	22
#define	VD_K_pfxHvCn	23
#define	VD_K_pfxHvCp	24
#define	VD_K_pfxHvEv	25
#define	VD_K_pfxHvPn	26
#define	VD_K_pfxHvu1	27
#define	VD_K_pfxHvu2	28
#define	VD_K_pfxHvu3	29
#define	VD_K_pfxHvu4	30
#define	VD_K_pfxHvAc	31
#define	VD_K_pfxHvFn	32
#define	VD_K_pfxHvHm	33
#define	VD_K_pfxHvCl	34
#define	VD_K_pfxHvBl	35
#define	VD_K_pfxHvFr	36
#define	VD_K_pfxHvRf	37







	/* ELECTRICAL */

#define	VD_K_pfxElJb	41
#define	VD_K_pfxElTr	42
#define	VD_K_pfxElMt	43
#define	VD_K_pfxElPn	44
#define	VD_K_pfxElu1	45
#define	VD_K_pfxElu2	46
#define	VD_K_pfxElu3	47
#define	VD_K_pfxElu4	48
#define	VD_K_pfxElPl	49
#define	VD_K_pfxElSw	50
#define	VD_K_pfxElGn	51
#define	VD_K_pfxElCd 	52
#define	VD_K_pfxElBr	53





#endif
