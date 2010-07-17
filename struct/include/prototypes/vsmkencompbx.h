/*
	I/STRUCT
*/

#ifndef vsmkencompbx_include
#	define vsmkencompbx_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef OM_D_MINIMUM
#	include "OMminimum.h"
#endif
#ifndef igetypedef_include
#	include "igetypedef.h"
#endif
#ifndef igrtypedef_include
#	include "igrtypedef.h"
#endif
#ifndef gr_include
#	include "gr.h"
#endif
#ifndef igr_include
#	include "igr.h"
#endif
#ifndef igrdp_include
#	include "igrdp.h"
#endif
#ifndef godef_include
#	include "godef.h"
#endif
#ifndef go_include
#	include "go.h"
#endif

/*+f
Function VSmakeEncompassingBox

Abstract
	Creates a box encompassing two range boxes, optionally enlarged by
	a scale factor.
Arguments
	OUT long	  *msg   Completion code.
	IN  const GRrange inBox1 First  input box.
	IN  const GRrange inBox2 Second input box.
	IN  double	  scale  Safety factor.
	OUT GRrange	  outBox Box encompassing the input boxes.
Keywords
	#box#encompass#
-f*/
extern void
VSmakeEncompassingBox		__((	GRrange			inBox1,
					GRrange			inBox2,
					double			scale,
					GRrange			outBox )) ;

#endif
