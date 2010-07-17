#ifndef FEanalmac_defined
#define	FEanalmac_defined

#include "FEanaldef.h"
#include "FErsstruct.h"

extern long FEorient_postive_z();
extern long FEverify_model ();
extern long FEreport_resultant();
extern long FErun_ifem_analysis ();

/* *****************************H H H H H******************************* */
/* Doc: fe$orient_postive_z

   Abstract:
   	This macro orients the positive z axis.

   Return Status:
	1	-	SUCCESS

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
       05-XX-92	kk/ak	2.0.1	Creation
       01-20-93 ret     2.2.0   extern all functions

*/
/* *****************************H H H H H******************************* */


#omdef	fe$orient_postive_z ()

	FEorient_postive_z()

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$verify_model 

   Abstract:
   	This macro verifies the model for analysis.

   Arguments:
   	char	analysis_engine		i - The analysis engine ( see FErsstruct.h )

   Return Status:
	1	-	SUCCESS

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
       05-XX-92	kk/ak	2.0.1	Creation
       01-20-93 ret     2.2.0   extern all functions
       01-01-93	jc	2.2	add analysis engine argument

*/
/* *****************************H H H H H******************************* */

#omdef	fe$verify_model ( analysis_engine = FE_INTERNAL )

	FEverify_model ( analysis_engine )

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$report_resultant

   Abstract:
   	This macro reports the resultants into the stat file.

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
       05-XX-92	kk/ak	2.0.1	Creation
       01-20-93 ret     2.2.0   extern all functions

*/
/* *****************************H H H H H******************************* */

#omdef  fe$report_resultant()

	FEreport_resultant( FE_RESULTANT )

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$run_ifem_analysis

   Abstract:
   	This macro runs the internal (I/FEM) analysis.

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
       01-01-93	jc	2.2	Creation

*/
/* *****************************H H H H H******************************* */

#omdef	fe$run_ifem_analysis ()

	FErun_ifem_analysis ()

#endomdef

#endif
