#ifndef FDstruct_included
#define FDstruct_included

#include	"OMtypes.h"
#include	"OMminimum.h"
#include	"igetypedef.h"
#include	"igrtypedef.h"
#include	"gr.h"

/* *****************************H H H H H****************************** */
/* Doc: FDstruct.h

   Abstract: This header file contains data structures for
   	     feature descriptors.
	
   Notes:	Feature Descriptor Data Classification

   		VAR-DATA is data that can potentially use graphic help in
   	its definition,i.e., quantities that could vary spatially.
   		UNIF-DATA is data for which graphic help is not applicable
   	to its definition,i.e., quantities that cannot vary spatially.

   History:

	Date		Who	Version	Why
	---------	------	-------	----------------------------------
	07-23-87	kk	?	Creation
	11-15-92	kk/raj	2.2.0	Added structs for non-uniform definition
*/
/* *****************************H H H H H****************************** */

/*	------------------------------------------
 *	Feature Descriptor Info Data Type
 */

typedef struct fd_info
{
	char	category;	/* fd category; NONMP, MAT, PROP,...	*/
	char	type;		/* fd type; FORCE, ISO, BMPROP,...	*/
	char	dimension;	/* Dimension of graphic feature described*/
	long	lcase_id;	/* Load case number			*/
	long	props;		/* Property bits			*/
	long	unif_count;	/* Uniform data 'byte' count		*/
	long	var_count;	/* Spatially varying data 'double' count*/

} FD_INFO;

/*
**  -------------------------------------------------------------
**  Non-uniform definition
**  -------------------------------------------------------------
*/

struct	fd_curve_def
{
	char		mode;		/* FD_NORMAL_PLANE,.. FDdef.h	*/
	char		direction;	/* FD_FORWARD, FD_BACKWARD	*/
};

struct	fd_table_def
{
	char		mode;		/* FD_RELATIVE,.. FDdef.h	*/
};

struct	fd_expr_def
{
	char		mode;		/* FD_RELATIVE,.. FDdef.h	*/
};

struct	fd_surf_def
{
	char		mode;		/* FD_NORMAL_LINE,.. FDdef.h	*/
	IGRvector	parl_line;	/* Vector representing parallel
					   line				*/
};

typedef struct fd_nudef
{
    	char		dimension;	/* 1,2,3			*/
	char		nudef_mode;	/* FD_TABLE,..	See FDdef.h	*/
	struct GRid	domain_grid;	/* Domain GRid			*/

	union
	{
	   struct fd_curve_def	crv_def;
	   struct fd_table_def	tbl_def;
	   struct fd_expr_def	expr_def;
	   struct fd_surf_def	surf_def;
    	} nudef;

} FD_NUDEF;

#endif
