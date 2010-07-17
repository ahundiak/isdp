/*
 *	I/STRUCT
 */

#ifndef vsplate_include
#	define vsplate_include

struct VS_s_plateAttr {
	int	orientation ;
	double	thickness,
		cut_off,
		offset ;	/* Of plate w/ resp. to support	*/
} ;
typedef	struct VS_s_plateAttr VSplateAttr ;
#define VS_K_PwP	"VSplaWpla"

#endif /* vsplate_include */

