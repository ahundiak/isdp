/*
/*---------------------------------------------------------------------------
/*  ACrg_collect.S
/*  ludovic Le Corvec
/*  5_oct_90
/*
/*  Abstract
/*	Object of this class store a list of attributes.
/*	This object can be root of an associative graph.
/*	Attribute is an expression of following type :
/*
/*			- Integer
/*			- Double
/*			- Text
/*
/*  History
/*
/*---------------------------------------------------------------------------*/
class specification ACrg_collect (0:0) of ACdiowner, NDnodein;

instance ACrg_collect 
{
 variable	IGRshort	attr_type[];  /* list of type for attribut */
 variable	IGRdouble	attr_exp[];   /* list of expexpression values */
 variable	IGRchar		attr_txt[];   /* list of text values */
 IGRshort			prop_mgr;     /* internal data to store props */
};


/*  PRIVATE MESSAGES */
message ACshow_data ( IGRlong	*msg );

message ACconnect_pretend( int *rc; char *foot_name; struct GRid *pret_GRid );

message ACconnect_pretendin( int *rc; char *foot_name;
                            struct GRid *pret_GRid,*context );



/* PUBLIC MESSAGES */

/* **** ACCES TO ATTRIBUT **** */

/* ********************************************************************	*/
/*  AClist_attribute
/*
/*	This message return the description list of all attribut store in 
/*	Object.
/*
/* --------------------------------------------------------------------	*/

message	AClist_attribute( IGRlong *msg; IGRint list_len; 
				struct ACrg_coll *list_att; IGRint *nb_attr );

/* ********************************************************************	*/
/*  ACget_named_attribut
/*
/*	This message return the description of the named attribute.
/*	attribute name is passed in attrib.name field
/*
/*	If attribute  exist msg	= TRUE else msg = FALSE
/*
/* --------------------------------------------------------------------	*/

message ACget_named_attribute( IGRlong *msg; struct ACrg_coll *attrib );

/* ********************************************************************	*/
/*  ACget_attribute_at_index
/*
/*	This message return the description of index th attribute.
/*
/*	If attribute existe at index msg = TRUE else msg = FALSE
/*
/* --------------------------------------------------------------------	*/

message ACget_attribute_at_index( IGRlong *msg; IGRint index; 
						struct ACrg_coll *attrib );

/* ********************************************************************	*/
/*  ACadd_list_attribute
/*
/*	This message add all attributes define in the list who are not
/*	already store in the ACrg_collection.
/*
/*	If one attribute already exist msg = FALSE else msg = TRUE
/*
/* --------------------------------------------------------------------	*/

message ACadd_list_attribute( IGRlong *msg; IGRint list_len; 
						struct ACrg_coll *list_att );

/* ********************************************************************	*/
/*  ACmod_list_attribute
/*
/*	This message modify each attribute stored in the ACrg_collection
/*	who have same name and same type that one of the list
/*
/*	If one attribute of the list can be modify 
/*					msg = FALSE else msg = TRUE
/*
/* --------------------------------------------------------------------	*/

message ACmod_list_attribute( IGRlong *msg; IGRint list_len;
						struct ACrg_coll *list_att );

/* ********************************************************************	*/
/*  ACset_list_attribute
/*
/*	Kill all existing attributes of the ACrg_collection and set the
/*	ACrg_collection with the new list
/*
/* --------------------------------------------------------------------	*/

message ACset_list_attribute( IGRlong *msg; IGRint list_len;
						struct ACrg_coll *list_att );

/* ********************************************************************	*/
/*  ACget_prop_mgr
/*
/*	Get the global properties of an ACrg_collection 
/*
/* --------------------------------------------------------------------	*/

message ACget_prop_mgr(	IGRshort *prop_mgr );

/* ********************************************************************	*/
/*  ACchg_prop_mgr
/*
/*	Change the current global properties for an ACrg_collection
/*
/* --------------------------------------------------------------------	*/

message ACchg_prop_mgr( IGRshort mask; IGRshort prop_mgr );



/* ************************ OVERRIDE MESSAGE **************************	*/

/* from ACdiowner */
override	ACadd_attribute_by_type,
		ACrem_attribute,
		ACrem_att_at_index,
		ACmod_attribute;

/* from NDmacro */
override	ACgive_structure,
		ACreturn_foot;

/* from NDnode */
override	NDgive_structure,
		NDdelete,	  /* remove name from directory */
		NDcompute_node,	  /* do nothing */
		NDmake_source,	  /* when a expression has been instanciated  */
				  /* as a member			      */
		NDsleep;	  /* delete members created by ACreturn_foot  */
		

/* from IGRdir */
override	dump,
		translate;

/* from ACdiowner */
override	GRdelete,
		GRcopy,
		GRgetobjinfo;

  message DIgive_output( char *out_s);

  /* ABSTRACT

  This message is sent with a "make_message to the expression

  ARGUMENTS

  out_s   I  : The name of the expression
          O  : the name of the expression concatenated with its syntax
  */


end specification ACrg_collect;
