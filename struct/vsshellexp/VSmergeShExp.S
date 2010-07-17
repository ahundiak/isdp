/*
	I/STRUCT
*/
class specification VSmergeShExp(0:0) of VSshellExp ;

instance VSmergeShExp {
	double		yTranslation ;	/* Translation used for the "from"    */
					/* shell expansion.		      */
} ;

/*+c
	Class for a merged shell expansion.

	Parent #0	: The "from" shell expansion.
	Parent #1	: The "to" shell expansion.

	The merged shell expansion translate the "from" shell expansion to the
	"to" shell expansion as following :


	  ----------------
	 /		 |
	/		 |
	|		 |
	|		 |-------------
	|	s1	 |	       \
	|		 |		\		Y
	|		 |		|		^
	|		 |	s2	|		|
	-----------------.ps1		|		---> X
			 |		|
			 |		|
			 |ps2		|
			 .---------------

	|		 |		|

	F1		 F2		F3

	s1 : The "to" shell expansion.
	s2 : the "from" shell expansion.

	ps1 : The point of the "to" shell expansion at minimum Y value and
	      for X value the X value of the plane F2 ( Begin plane or
	      End plane of the shell expansion ).
	ps2 : The point of the "from" shell expansion at minimum Y value and
	      for X value the X value of the plane F2 ( Begin plane or
	      End plane of the shell expansion ).

	The merged shell expansion find the two points ps1 and ps2 and translate
	the "from" shell expansion with the vector (ps1->ps2).
	The result is :

	  -----------------------------
	 /			       \
	/				\
	|				|
	|				|
	|	s1		s2	|
	|				|		Y
	|				|		^
	|				|		|
	---------------------------------		---> X

	|		 |		|

	F1		 F2		F3


	How to construct the shell expansion :
	======================================

	struct GRvg_construct	cstargs ;	<Construction list>
	struct VScnst_list	vsargs ;
	struct GRobj_env	parents[2] ;

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

	parents[0]		= <"from" shell expansion> ; <id and module env>
	parents[1]		= <"to"   shell expansion> ; <id and module env>
	vsargs.parent_list	= parents ;
	vsargs.parent_count	= 2 ;

	Then use

	sts = om$construct(	msg = message GRgraphics.GRconstruct( &cstarg ),
				... ) ;

-c*/

override
	ACconstruct_feet,
	VSgetObjDef,

/*+o
Message NDdelete

Abstract
	Unconsume my shell expansion parents and delete myself.
-o*/
	NDdelete,

/*+o
Message VSevaluate

Abstract
	Performs the regular VSevalute but takes "to" shell expansion's
	symbology.

Arguments
	See message VSevaluate of class VScpx.
-o*/
	VSevaluate,

/*+o
Message VSget_limiting_points

Abstract
	Returns begin and end points of limiting planes of the merged shell
	expansion.

Arguments
	See message VSget_limiting_points of class VSshellExp.
-o*/
	VSget_limiting_points,

/*+o
Message VSget_y_translation

Abstract
	Returns the y translation used for translating the "from" shell
	expansion.

Arguments
	See message VSget_y_translation of class VSshellExp.
-o*/
	VSget_y_translation ;

/*+d
Message VSget_shell_exp_parents

Abstract
	Returns the "from" and "to" shell expansion parents.

Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRmd_env 	*myEnv		My module environment.
	OUT	struct GRobj_env	*frShell	"from" shell exp parent.
	OUT	struct GRobj_env	*toShell	"to" shell exp parent.

Note
	'*frShell' or '*toShell' can be NULL.
-d*/
message VSget_shell_exp_parents( long			*msg ;
				 struct GRmd_env	*myEnv ;
				 struct GRobj_env	*frShell ;
				 struct GRobj_env	*toShell ) ;

/*+d
Message VSget_all_original_shell_exp

Abstract
	Returns all the original shell expansions used to generate the merge
	shell expansion.

Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRmd_env 	*myEnv		My module environment.
	OUT	int			*count		Count of shell exp.
	OUT	struct GRobj_env	*list[] 	List of shell exp.

Notes
	- WARNING : '*count' should be equal to 0 before sending the message.

	- '*list' can be NULL, the message returns only the number of original
	  shell expansion.

	- '*list' is malloced, it is up to the caller to free it.
-d*/
message VSget_all_original_shell_exp( long		*msg ;
				      struct GRmd_env	*myEnv ;
				      int		*count ;
				      struct GRobj_env	*list[] ) ;

reject	VSget_baseline_point,
	VSstore_y_translation ;

end specification VSmergeShExp ;
