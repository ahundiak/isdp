/*
	I/STRUCT
*/
class specification VSshellExp(0:0) of VShelper ;

#ifndef OM_D_TYPES
#	include "OMtypes.h"
#endif

instance VSshellExp {
	OMbyte		flagAttr ;
} ;

/*+c
	Class for a shell expansion.

	Parent #0	: a shell (hull) surface.
	Parent #1	: a XY plane defining the base line (Z-coordinate).
	Parent #2	: a YZ plane defining the beginning of the expansion
			  (X-coordinate).
	Parent #3	: a YZ plane defining the end of the expansion
			  (X-coordinate).



		---------------------------------------------  <- Hull surface.
		|					    /
		|					   /
    base line.	|					  /
	|	|					 /
	v	|					/
       ---	|					\
		|					 \
		|					 /
	Z	|					/
	^	----------------------------------------
	|
	---> X		|		    |

			^		    ^
			|		    |
		   Begin plane. 	 End plane.

				 |
				 |
				 V

			---------------------
			|		    |
			|		    |
			|		    |
			|		    |  <- Shell expansion (surface).
			|		    |
			|		    |
			|		    |
			 \		   /
			  \		  /
			   \		 /
			    -------------


	The surface constructed is the unfolding of the shell with respect
	to the base line along the Z-axis ( between begin and end plane ).

	Notes :
	=======
		- Parent #1 is optional, thus in this case the XY plane
		  defining the base line will be the XY plane at Z=0.

		- Parent #2 and Parent #3 are optionals, thus in this case
		  the entire shell will be process.


	How to construct the shell expansion :
	======================================

	struct GRvg_construct	cstargs ;	<Construction list>
	struct VScnst_list	vsargs ;

	Fill

	cstargs.msg,
	cstargs.display,
	cstargs.level,
	cstargs.properties,

	cstargs.env_info	= <module environment of design file>
	cstargs.name		= <full name of object, NULL if unnamed>
	cstargs.geometry	= NULL ; <this field is ignored>
	cstargs.newflag 	= FALSE ;
	cstargs.class_attr	= (char *)  &vsargs ;


	1) Only 'shell' defined.

		parents[0]	    = <shell> ; 	<id and module env>
		vsargs.parent_count = 1 ;


	2) 'shell' and 'baseline' defined.

		parents[0]	    = <shell> ; 	<id and module env>
		parents[1]	    = <baseline> ;	<id and module env>
		vsargs.parent_count = 2 ;


	3) 'shell', 'begin plane' and 'end plane' defined.

		parents[0]	    = <shell> ; 	<id and module env>
		parents[1]	    = <begin plane> ;	<id and module env>
		parents[2]	    = <end plane> ;	<id and module env>
		vsargs.parent_count = 3 ;


	4) All parents defined.

		parents[0]	    = <shell> ; 	<id and module env>
		parents[1]	    = <baseline> ;	<id and module env>
		parents[2]	    = <begin plane> ;	<id and module env>
		parents[3]	    = <end plane> ;	<id and module env>
		vsargs.parent_count = 4 ;


	Then use

	sts = om$construct(	msg = message GRgraphics.GRconstruct( &cstarg ),
				... ) ;

-c*/

override
	ACconstruct_feet,
	NDdelete,
	VSgetObjDef ;

/*+d
Message VSget_baseline_point

Abstract
	Returns the baseline point of the shell expansion.

Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRmd_env 	*myEnv		My module environment.
	OUT	double			*baseline	Baseline point.
-d*/
message VSget_baseline_point( long		*msg ;
			      struct GRmd_env	*myEnv ;
			      double		*baseline ) ;

/*+d
Message VSget_limiting_points

Abstract
	Returns begin and end points of limiting planes of the shell expansion.

Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRmd_env 	*myEnv		My module environment.
	OUT	double			*beginPoint	Begin point.
	OUT	double			*endPoint	End point.
-d*/
message VSget_limiting_points( long		*msg ;
			       struct GRmd_env	*myEnv ;
			       double		*beginPoint ;
			       double		*endPoint ) ;

/*+d
Message VSstore_y_translation

Abstract
	Store the y translation. this translation is used such that the minimum
	y value of the shell expansion should be at y=0.

Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRmd_env 	*myEnv		My module environment.
	IN	double			yTrans		Y translation.
-d*/
message VSstore_y_translation( long		*msg ;
			       struct GRmd_env	*myEnv ;
			       double		yTrans ) ;

/*+d
Message VSget_y_translation

Abstract
	Returns the y translation.

Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRmd_env 	*myEnv		My module environment.
	OUT	double			*yTrans 	Y translation.
-d*/
message VSget_y_translation( long		*msg ;
			     struct GRmd_env	*myEnv ;
			     double		*yTrans ) ;

/*+d
Message VSget_expanded_curves

Abstract
	Returns the expanded curves attached to the shell expansion.

Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRmd_env 	*myEnv		My module environment.
	OUT	int			*count		Count of expanded
							curves.
	OUT	struct GRobj_env	*list[] 	List of expanded curves.

Notes
	- '*list' can be NULL, the message returns only the number of expanded
	  curves attached to the shell expansion.

	- '*list' is malloced, it is up to the caller to free it.
-d*/
message VSget_expanded_curves( long		*msg ;
			       struct GRmd_env	*myEnv ;
			       int		*count ;
			       struct GRobj_env *list[] ) ;

end specification VSshellExp ;
