#ifndef FEanaldef_included
#define FEanaldef_included

/* Doc: FEanaldef.h

   Abstract: This header file defines various analysis parameters.
	
   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      01-05-87	kk	1.0	Creation
      08-10-88	kk		Added element types
      11-13-88	kk		Added modes for mat & prop verification
      10-25-89	kk		Added beam end offset type
      10-26-91	kk	2.0.0	2.0 upgrade
      01-04-92	kk	2.0.0	Added Stress PDD indexes
      09-22-92	ak	2.1.0	Add FE_OPERATE mode
*/
/* *****************************H H H H H******************************* */

/*	----------------------------------------------------------
 *	Analysis Types
 */

#define STATIC		101
#define	DYNAMIC		102

/*	----------------------------------------------------------
 *	Special #defines
 */

#define STRUCTURE	20
#define NODE		21

/*	----------------------------------------------------------
 *	Define bits for modification indicators
 */

#define S_bit (1<<6)	/* Structure modified		*/
#define M_bit (1<<5)	/* Matreial modified		*/
#define P_bit (1<<4)	/* Property modified		*/
#define W_bit (1<<3)	/* Masses (weight) modified	*/
#define D_bit (1<<2)	/* Damping modified		*/
#define L_bit (1<<1)	/* Loading modified		*/
#define C_bit (1)	/* Constraints modified		*/

/*	----------------------------------------------------------
 *	Used in verification of materials and properties
 */

#define	INIT_MGR	 101
#define	MP_USED		 102
#define	REPORT_AND_RESET 103

#define FAILED_SET_NAME	"failed_verif"

/*	----------------------------------------------------------
 *	Modes with which FEstprep, FEsninit can be called
 */

#define	FE_MEMREQ_MODE	101
#define	FE_ANALYZE_MODE	102
#define	FE_COMPRES_MODE	103

/*	----------------------------------------------------------
 *	Used for merging displacements ...
 */

#define	FE_RHSV	1
#define	FE_RSDV	2

/*	----------------------------------------------------------
 *	Panel element structural stiffness types
 */

#define MEMBRANE	1
#define BENDING		2
#define BEND_MEMBRANE	3

/*	----------------------------------------------------------
 *	Analysis errors
 */

#define MASS_ZERO	1
#define INSTABILITY	2
#define MODAL_ERROR	3

/*	----------------------------------------------------------
 *	May be used for any process
 */
#define FE_BEGIN	1
#define FE_END		2
#define FE_OPERATE	3

#define FE_GET		1
#define FE_PUT		2

/*	----------------------------------------------------------
 *	Stress PDD indexes for array : See FEpmldstrs.I
 */

#define FE_MAX_STRESS_PDDS	14

/*  3D analysis */

#define BEAM_FORCES		0
#define ROD_FORCES		1
#define BEAM_STRS		2
#define ROD_STRS		3
#define SHELL_TOP_STRS		4  /* Next two PDDs assumed to be mid, bot in FEpmldstrs.I */
#define SHELL_MID_STRS		5
#define SHELL_BOT_STRS		6
#define SHELL_SED		7
#define SHELL_HVM_STRS		8
#define SHELL_PRIN_STRS		9
#define SLD_STRS		10
#define SLD_SED			11
#define SLD_HVM_STRS		12
#define SLD_PRIN_STRS		13

#define NUM_3D_STRS_PDDS	14

/*  Axisymmetric analysis  */

#define AXISHELL_TOP_STRS	0  /* Next two PDDs assumed to be mid, bot in FEpmldstrs.I */
#define AXISHELL_MID_STRS	1
#define AXISHELL_BOT_STRS	2
#define AXISHELL_SED		3
#define AXISHELL_HVM_STRS	4
#define AXISHELL_PRIN_STRS	5
#define AXISLD_STRS		6
#define AXISLD_SED		7
#define AXISLD_HVM_STRS		8
#define AXISLD_PRIN_STRS	9

#define NUM_AXI_STRS_PDDS	10

/* Used for FEreport_resultant function */

#define FE_RESULTANT		1
#define FE_LOADMERGE		2

#endif
