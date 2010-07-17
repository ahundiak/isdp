#ifndef mhfdsymstruct_def
#define mhfdsymstruct_def

#include	"igetypedef.h"
#include	"igrtypedef.h"
#include	"godef.h"
#include	"gr.h"
#include	"igr.h"
#include	"igrdp.h"
#include	"go.h"

/* *****************************H H H H H******************************* */
/* Doc: MHfdsymbols.h

   Abstract: This file defines data types used for the mesh FD symbols.
	
   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      03-17-92	bwh	2.0.0	Creation

*/
/* *****************************H H H H H******************************* */

/*	The index on which APparam objects on the FEfddpb.to_param channel
 *	are connected.
 */

#define	MH_MSDENS_PAR		0	/* msdens_parms	*/

/*	-----------------------------------------------------------------
 *	struct definitions
 */

struct	msdens_parms {
   	struct GRsymbology symbology;	/* Symbology to use 		*/
	double		symbol_size;	/* symbol parms	*/
	};

/*
 *	(IMPORTANT) Union All Possible Symbol Parameters
*/

union MHsmb_params {
	struct	msdens_parms	msdens;
	};

/*
 *	Structures Used in FEgenfdsym.init_geom() message argument arg_list
 */

struct msdens_init_args {
   	double			origin[3];	/* Point wrt which symbol defined*/
	struct msdens_parms	*params;	/* Symbol active param (OPTIONAL)*/
	};
	
/*
 *	(IMPORTANT) Union All Possible Symbol Creation Arguments
*/

union MHsmb_init_args {
	struct msdens_init_args	msdens;
	};

#endif
