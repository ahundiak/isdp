/*
/*---------------------------------------------------------------------------
/*  ACdyn_col.S
/*  ludovic Le Corvec
/*  18_feb_92
/*
/*  Abstract
/*	Object of this class store a list of attributes.
/*	At placement and update time occurrence execute user
/*	define functions.
/*	Attribute have properties management (cf ACdyn_col.h)
/*
/*  History
/*
/*---------------------------------------------------------------------------*/
class specification ACdyn_col (0:0) of GRnotify,ACrg_collect;

#include "ACrg_collect.h"

struct ACusr_fct 
{ 
	int	select;		/* index of message selector in fct_text */
	int	fct_name;	/* index of function name in fct_text	*/
	int	fct_add; 	/* address of function during session	*/
};

instance ACdyn_col 
{

	variable	struct	ACusr_fct	fct_def[];
	variable	char			fct_txt[];

};

override	ACshow_data,			/* use ACshow_attribute	*/
		ACgive_structure;		/* eval attribute	*/

override	NDupdate,			/* OVERRIDABLE */
		NDplace;			/* OVERRIDABLE */

override	NDsleep;			/* set to NULL fct_ptr	*/

override	dump;				/* private attributes are
						   not visible for dir	*/

/* ********** PRIVATE MESSAGES ******************** */

/* ******************** MSG ACshow_attribute () **********************	*/
/* Print on standart output attrib structure 				*/
/*	IN :	*msg							*/
/*		*attrib		attribute structure			*/
/* --------------------------------------------------------------------	*/

message ACshow_attribute( IGRlong *msg; struct ACrg_coll *attrib );

/* ******************** MSG ACeval_attributes () **********************	*/
/* Apply evaluations function for the given list of attribute
/*
/*	IN :	list_len	length of the given list
/*		*list_attr	list of attribute to evaluate
/*		*md_env		module environment
/*
/*	OUT :	*msg		return code
/*		*list_attr	set result of evaluation on field value
/* --------------------------------------------------------------------	*/

message ACeval_attributes( IGRlong *msg; IGRint list_len;
		struct ACrg_coll *list_attr; struct GRmd_env *md_env );

/* *********************** MSG ACadd_fct () ***************************	*/
/* add a new internal user function on the stored list
/*
/*	IN :	fct_attr	description of function
/*				  - name is the selector
/*				  - desc.value.att_txt is the function name
/*
/*	OUT :	*msg		return code
/* --------------------------------------------------------------------	*/

message ACadd_fct( IGRlong *msg; struct ACrg_coll fct_attr );

/* *********************** MSG ACrm_fct () ****************************	*/
/* delete an internal function description stored
/*
/*	IN :	*fct_select	name of selector
/*
/*	OUT : 	*msg		return code
/* --------------------------------------------------------------------	*/

message ACrm_fct( IGRlong *msg; IGRchar *fct_select );

/* *********************** MSG ACget_fct () ***************************	*/
/* get description of an internal function stored
/*
/*	IN :	*fct_attrib	fill selector name if index is not used
/*		*index		index of the function description 
/*				can be set to NULL or -1 if unknown
/*
/*	OUT :	*msg		return code
/*		*fct_ptr	address of the internal function
/*				valid only during a session
/*		*index		internal index of function definition
/*				(can be set to NULL)
/*		*fct_atrib	definition of function
/*				  - name is the selector
/*				  = desc.value.att_txt is the function name
/* --------------------------------------------------------------------	*/

message ACget_fct( IGRlong *msg; struct ACrg_coll *fct_attrib; IGRint *index;
				IGRint *fct_ptr );

/* *********************** MSG ACset_fct_ptr () ***********************	*/
/* set address of function (valid during a session)
/*
/*	IN :	*index		internal index of function definition
/*				if unknown set NULL or *index = -1
/*		fct_attrib	if index is not used fill name with 
/*				selector
/*		fct_ptr		address of the user function
/*
/*	OUT :	*msg		return code
/* --------------------------------------------------------------------	*/

message ACset_fct_ptr( IGRlong *msg; struct ACrg_coll fct_attrib; IGRint *index;
				IGRint fct_ptr );


/* ********** PUBLIC MESSAGES ******************** */


/* **************** MSG AClist_attribute_by_type () *******************	*/
/* list stored attributes with respect of the given properties 
/*
/*	Attribute have 3 different properties :
/*		- type	of attribute value	(cf ACattrib.h)
/*		- internal properties		(cf ACdyn_col.h)
/*		- user properties 
/*
/*	Each properties can be test independently where condition is given
/*	with char *test_XXX (see ACdyn_col.h).
/*	
/*	An attribute is listed if the 3 tests are TRUE
/*
/*	IN :	list_len	length of the given list
/*		att_type	select mask for type
/*		*test_type	test on type
/*		int_prop	select mask for internal properties
/*		*test_int	test on internal properties
/*		user_prop	select mask for user properties
/*		*test_user	test on user properties
/*
/*	OUT :	*msg		return code
/*		*list_att	list of selected attributes
/*		*nb_attr	total number of selected attributes
/* --------------------------------------------------------------------	*/

message AClist_attributes_by_type( IGRlong *msg; IGRint list_len;
				struct ACrg_coll *list_att; IGRint *nb_attr;
				IGRshort att_type;
				IGRchar	*test_type;
				IGRshort int_prop;
				IGRchar	*test_int;
				IGRshort user_prop;
				IGRchar	*test_user );

/* ******************* MSG ACget_att_prop () ************************** */
/* get internal and user properties stored for the given attribute	*/
/*									*/
/*	IN :	*att_name 	name of the attribute			*/
/*	OUT :	*msg		return code				*/
/*		*int_prop	internal properties			*/
/*		*user_prop	user properties				*/
/*									*/
/* --------------------------------------------------------------------	*/

message ACget_att_prop( IGRlong *msg; IGRchar *att_name; 
				IGRshort *int_prop; IGRshort *user_prop );

/* ******************* MSG ACset_att_prop () ************************** */
/* set internal and user_properties for the given attribute		*/
/*									*/
/*	IN :	*att_name 	name of the attribute			*/
/*		int_prop	internal properties			*/
/*		user_prop	user properties				*/
/*	OUT :	*msg		return code				*/
/*									*/
/* --------------------------------------------------------------------	*/

message ACset_att_prop( IGRlong *msg; IGRchar *att_name; 
				IGRshort int_prop; IGRshort user_prop );

end specification ACdyn_col;

