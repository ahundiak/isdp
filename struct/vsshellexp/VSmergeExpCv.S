/*
	I/STRUCT
*/
class specification VSmergeExpCv(0:0) of VSexpandedCv ;

/*+c
	Class for an expanded curve placed onto a merged shell expansion.

	Parent #0	: a merged shell expansion.
	Parent #1	: an expanded curve placed onto the "from" or "to"
			  shell expansion of the merged shell expansion parent
			  #0.
	Parent #2	: an expanded curve placed onto the "to" or "from"
			  shell expansion of the merged shell expansion parent
			  #0.

	The curve constructed is the merge of the expanded curve parent #1
	and the expanded curve parent #2.
	If the expanded curve parent is placed onto the "from" shell expansion,
	it will be translated with the translation vector used to create the
	merged shell expansion.

	Note :
	======
		- Parent #2 is optional, thus in this case the expanded
		  curve constructed is the copy of the parent #1 ( translated
		  with the translation vector used in the merged shell
		  expansion, if the expanded curve parent #1 is placed onto
		  the "from" shell expansion ).

	How to construct the curve.

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


	1) Parent #2 defined :

	struct GRobj_env	parents[3] ;

	parents[0]		= <merged shell expansion> ; <id and module env>
	parents[1]		= <expanded curve> ;	     <id and module env>
	parents[2]		= <expanded curve> ;	     <id and module env>

	vsargs.parent_count	= 3 ;


	2) Parent #2 not defined :

		struct GRobj_env	parents[2] ;

		parents[0]	= <merged shell expansion> ; <id and module env>
		parents[1]	= <expanded curve> ;	     <id and module env>

		vsargs.parent_count	= 2 ;


	vsargs.parent_list	= parents ;
	vsargs.representation	= NULL ;
	vsargs.feature_att	= NULL ;

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
	Unconsume my expanded curves parents and delete myself.
-o*/
	NDdelete,

/*+o
Message NDparent_deleted

Abstract
	If the merged shell expansion parent #0 is deleted, unconsume my
	expanded curves parents and delete myself. Otherwise, forward the
	message to the parent class.
-o*/
	NDparent_deleted,

/*+o
Message VSevaluate

Abstract
	Performs the regular VSevalute but takes first parent's symbology.

Arguments
	See message VSevaluate of class VScpx.
-o*/
	VSevaluate ;

reject	VSget_hull_surface ;

end specification VSmergeExpCv ;
