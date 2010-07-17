/*
	I/STRUCT
*/
#ifndef vsxsfrpldef_include
#	define vsxsfrpldef_include

#define VS_K_HORIZONTAL 0
#define VS_K_VERTICAL	1

#define VS_K_LEFT	0
#define VS_K_RIGHT	1
#define VS_K_BOTTOM	2
#define VS_K_TOP	3

/*
 * The values of the following 4 are important:
 *		      top
 *		TL ----<---- TR
 *		|	      |
 *	left	V	      ^ right
 *		|	      |
 *		BL ---->---- BR
 *		    bottom
 * They define an order among points, plus their are used as indices in arrays.
 */
#define VS_K_BL 	0
#define VS_K_BR 	1
#define VS_K_TR 	2
#define VS_K_TL 	3

#define VS_K_NBCORNERS		4
#define VS_K_MAX_XSPLATES	4
#define VS_K_MIN_XSPLATES	1
#define VS_K_MAXCNTPTS		(VS_K_NBCORNERS*VS_K_MAX_XSPLATES)

#define VS_K_I_SHAPE		0
#define VS_K_L_SHAPE		1
#define VS_K_T_SHAPE		2
#define VS_K_GAMMA_SHAPE	3
#define VS_K_H_SHAPE		4
#define VS_K_C_SHAPE		6
#define VS_K_BAR_SHAPE		7
#define VS_K_SQUARE_SHAPE	8
#define VS_K_UNKNOWN_SHAPE	9

#define VS_K_ppParentCS 	"cs"

#endif
