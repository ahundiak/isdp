/*
	I/STRUCT
*/
class specification VSvrsnStamp(0:0) of global_class ;

#ifndef igetypedef_include
#	include "igetypedef.h"		/* IGE typedefs GR*		*/
#endif
#ifndef igrtypedef_include
#	include "igrtypedef.h"		/* Typedef IGR*			*/
#endif
#ifndef gr_include
#	include "gr.h"			/* Typedef GR*			*/
#endif
#ifndef vspart_include
#	include "vspart.h"
#endif
#ifndef vsdpb_include
#	include "vsdpb.h"
#endif

instance VSvrsnStamp {
/*
 * Version of I/STRUCT with which design file was made.
 */
	VSfileVersion		version ;
} ;

override sleep ;

end specification VSvrsnStamp ;

