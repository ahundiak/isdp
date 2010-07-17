/*
	vlsdl.h : Definition of the Strudel context for LOFT commands 
*/

#ifndef	vlsdl_include
#define	vlsdl_include


struct	VL_s_SdlText
{
	char		row[1024];	/* Final row			*/ 
	char		txt[80];	/* Current row			*/
	int		col;		/* Current column		*/
	int		jst;		/* Current justification	*/
	int		ini;		/* 0 | 1 (first | following)	*/
	FILE		*out;		/* Output file pointer		*/
};
typedef	struct	VL_s_SdlText	VLsdlText;

struct	VL_s_SdlContext 
{
	VLsdlText	systTxt;	/* Text attributes		*/
	struct	GRid	systCol;	/* System attributes collection	*/
	struct	GRid	userCol;	/* User	attributes collection	*/
	void		*stateArgs;	/* Cmd defined structure	*/
};
typedef	struct	VL_s_SdlContext	VLsdlContext;

#endif
