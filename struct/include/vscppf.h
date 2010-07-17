/*
	I/STRUCT

	Include file defining structure for plates used in creation of
	composite profile.

	Dependency: vsqryrdbdef.h
*/
#ifndef vscppf_include
#	define vscppf_include

struct VS_s_compProfPlateDef {
	int	Orientation ;		   /* Plate orientation ( Horizontal, */
					   /* Vertical )		      */
	double	thkVal, 		   /* Thickness value.		      */
		offVal, 		   /* Offset value.		      */
		whtVal ;		   /* Width / Height value.	      */
	char	thkType[VS_K_MAXDBNAME],   /* Thickness type.		      */
		ornType[VS_K_MAXDBNAME] ;  /* Orientation type. 	      */
} ;
typedef struct VS_s_compProfPlateDef VScompProfPlateDef ;

#endif
