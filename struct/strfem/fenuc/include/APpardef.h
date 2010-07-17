#ifndef		APpardef_include
#define		APpardef_include

/* *****************************H H H H H******************************* */
/* Doc:  APpardef.h

   Abstract:
	
   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      ?? ??? ??	???	x.x.x	Creation
      15 Mar 93 ret     2.2.0   Added midside node coef to element parameters.
*/
/* *****************************H H H H H******************************* */

#ifndef go_include /* include go.h and dependencies */
#include "godef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "go.h"
#endif /* end ifndef go_include */

/* define the software modules - these #defines are used by the parameter
   objects (APparameter) to store which dpb they are connected to */
#define APP	0
#define FD	1
#define PRE	2
#define POST	3
#define ISAS	4
#define IFEMP	5
#define ITP	6
#define PREFD	7

/* number of parameter objects connected to APdpb
   NOTE: This must be modified if any parameters are added to APP */
#define NUMPARS	2
   
/* define parameter types at the APP level
   NOTE: these are also used as channel indices for parameter types */
#define NDPAR	0
#define ELPAR	1

/* toggles for either getting or putting default parameters */

#define GET	0
#define PUT	1

/* define data structures for active parameters */
struct	APnd_par {
	struct GRsymbology 	sym;		/* dispaly parameters */
	IGRchar			tol_onoff;	/* 0-no check,1-check */
	IGRdouble		tol;		/* node tolerance     */
	};

struct	APel_par {
	struct GRsymbology 	sym;		/* display parameters        */
	double			ar_warn;	/* aspect ratio warning      */
	double			ar_err;		/* aspect ratio error        */
	double			warp_warn;	/* warping factor warning    */
	double			warp_err;	/* warping factor error      */
	double			skew_warn;	/* skew factor warning       */
	double			skew_err;	/* skew factor error         */
	double			mid_warn;	/* midside node coef warning */
	double			mid_err;	/* midside node coef error   */
	long			elprops;	/* see APelprops.h           */
	char			shrink;		/* active shrink factor      */
	char			check_shape;	/* element shape checks flag */
	};

/* Need this old copy for forward conversion in database. */

struct	APel_par_v0 {
	struct GRsymbology 	sym;		/* display parameters        */
	double			ar_warn;	/* aspect ratio warning      */
	double			ar_err;		/* aspect ratio error        */
	double			warp_warn;	/* warping factor warning    */
	double			warp_err;	/* warping factor error      */
	double			skew_warn;	/* skew factor warning       */
	double			skew_err;	/* skew factor error         */
	long			elprops;	/* see APelprops.h           */
	char			shrink;		/* active shrink factor      */
	char			check_shape;	/* element shape checks flag */
	};

#endif /* close ifndef APpardef_include */
