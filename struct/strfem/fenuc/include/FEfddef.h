#ifndef FEfddef_included
#define FEfddef_included

/* *****************************H H H H H******************************* */
/* Doc: FEfddef.h

   Abstract: This header file defines various ISAS parameters.
	
   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      11-01-91	kk	2.0.0	Creation ( Moved from FEisasdef.h 1.4 )
      01-31-92  smt	2.0.0   Added AXIPROP_TYPE
      06-30-92	smt	2.0.1	Added NLISOMAT_TYPE (NAVAIR).
      07-20-92  ak	2.0.1   Added HEAT_SRC_TYPE,CONVEC_TYPE,RADI_TYPE
      09/14/92	raj	2.0.1	Added Injection point type.
      09/16/92	raj	2.0.1	Added Material Orientation type.
      09/25/92	smt	2.1.0	Added RUNPROP_TYPE.
      11/06/92	smt	2.1.0	Added DIMPROP_TYPE for dimension beam.
      02-04-93  ak	2.2.0   Added INITTEMP_TYPE
      03-19-93	jc	2.2.0	Added SACRIF_TYPE
      08-16-93	smt	2.4.0	Added NPBPROP_TYPE for non-prismatic beam.
*/
/* *****************************H H H H H******************************* */

/*	----------------------------------------------------------
 *	Feature Descriptor Categories
 */
#define	MAT_CATEGORY	101		/* Material type category	*/
#define	PROP_CATEGORY	102		/* Property type category	*/
#define	NONMP_CATEGORY	103		/* Not material or property	*/

/*	----------------------------------------------------------
 *	Feature Descriptor Types Under MAT_CATEGORY
 */

#define	ANYMP_TYPE     -1		/* Any of mats/props types below*/
#define	ANYMAT_TYPE     ANYMP_TYPE	/* Any of mats/props types below*/
#define	ISOMAT_TYPE	0		/* Isotropic material		*/
#define	ORTHOMAT_TYPE	1		/* Orthotropic material		*/
#define	ANISOMAT_TYPE	2		/* Anisotropic material		*/
#define	NLISOMAT_TYPE	3		/* Nonlinear Isotropic material	*/

/*	----------------------------------------------------------
 *	Feature Descriptor Types Under PROP_CATEGORY
 */

#define	ANYPROP_TYPE    ANYMP_TYPE	/* Any of mats/props types below*/
#define	BMPROP_TYPE	0		/* Beam property		*/
#define	PANPROP_TYPE	1		/* Plate property		*/
#define	SOLPROP_TYPE	2		/* Solid property		*/
#define	RODPROP_TYPE	3		/* Rod property			*/
#define	SPGPROP_TYPE	4		/* Spring property		*/
#define	GAPPROP_TYPE	5		/* Hook/Gap property		*/
#define	RIGPROP_TYPE	6		/* Rigid Bar property		*/
#define	AXIPROP_TYPE	7		/* Axisymetric plate property	*/
#define	LAMPROP_TYPE	8		/* Laminate property	        */
#define DAMPROP_TYPE	9		/* Damper element property	*/
#define	RUNPROP_TYPE	10		/* Runner property		*/
#define	DIMPROP_TYPE	11		/* Dimension beam property	*/
#define	NPBPROP_TYPE	12		/* non-prismatic beam property	*/
#define TPBPROP_TYPE    13              /* Tapered beam property        */

/*	----------------------------------------------------------
 *	Feature Descriptor Types Under NONMP_CATEGORY
 */

#define	ANYFD_TYPE	ANYMP_TYPE	/* Any of fd types below	*/
#define	FORCE_TYPE	0		/* Nodal Force			*/
#define	CONSTRAINT_TYPE	1		/* Nodal constraint		*/
#define	ORIENT_TYPE	2		/* Orientation vector		*/
#define	BMREL_TYPE	3		/* Beam end releases		*/
#define	SPECDISP_TYPE	4		/* Nodal specified displacement	*/
#define	MASS_TYPE	5		/* Element Temperature		*/
#define	TEMP_TYPE	6		/* Element Temperature		*/
#define	INITSTRAIN_TYPE	7		/* Element initial strain	*/
#define	BMOFS_TYPE	8		/* Beam end offset		*/
#define	DYNAM_TYPE	9		/* Transient Dynamic load	*/
#define	HEAT_SRC_TYPE	10		/* Heat Source			*/
#define	CONVEC_TYPE	11		/* Convection			*/
#define	RADI_TYPE	12		/* Radiation			*/
#define	INJPT_TYPE	13		/* Injection Point (I/FLOW)	*/
#define	MATORNT_TYPE	14		/* Material ornt vector(s)	*/
#define	INITTEMP_TYPE	15		/* Initial Temperature		*/
#define SACRIF_TYPE	16		/* Sacrificial Elements		*/

#endif
