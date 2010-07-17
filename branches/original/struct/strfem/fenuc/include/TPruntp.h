#ifndef TPruntp_included
#define	TPruntp_included

/* *****************************H H H H H******************************* */

/*
   Abstract: TPruntp.h is the include file for third party interface
             product. 
	
   History:

        Date            Who             Why
	---------       ------          ----------------------------------
        12-10-92        ckc             Creation
*/

/* *****************************H H H H H******************************* */

/*  Execution mode  */

#define  INTERACTIVE_MODE    0
#define  BATCH_MODE          1

/*  Host Type  */

#define	LOCAL_HOST           0
#define	REMOTE_HOST          1

/* analysis_type  */

#define LINEAR_STATIC        0
#define MODAL_DYNAMIC        1
#define NONLINEAR_STATIC     2
#define LINEAR_TRANSIENT     3
#define NONLINEAR_TRANSIENT  4
#define FREQUENCY_RESPONSE   5
#define HEAT_TRANSFER        6
#define BUCKLING             7
#define COMPLEX_EIGENVALUE   8
#define TRANSIENT_HEAT       9
#define CREEP               10
#define VISCO_PLASTIC       11
#define VISCO_ELASTIC       12
#define CONTACT             13

#endif
