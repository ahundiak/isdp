/*
/*---------------------------------------------------------------------------
/*  ACncpx.S
/*  robert patience
/*  24-auot-89
/*
/*  ABSTRACT
/*	 The abstact class ACcpx defines instance and methods required for 
/*	the correct behaviour of the navsea complex node entity. 
/*  	New complex node entities supports :
/*		-Graphic or assoc root objects for feet which are
/*		  attached to the to_components channel .
/*		  (expressions are transformed into Gexp) 
/*		-Only associative entities not dependent on changing
/*		   internal instance during compute.
/*---------------------------------------------------------------------------*/
class specification ACncpx (0:1) of IGRdir,ACcpx,ACdb_info;

#include "macro.h"

instance ACncpx 
{
};

/* Root management is a state in the ACncpx allowing modified indexing */
/*   and attributes to be supported by root entities */
override	NDcopy_to_root;   /* Copy and change to root state  	*/
override	NDcopy;		  /* Change serial number in db_info    */
override	NDmove_to_root;   /* Change macro to root state 	*/
override        GRxform;	  /* Transform go feet in root state    */

override	ACbecome_macro;   /* Don't allow nesting in symbol macro*/

override 	ACpass_up,ACbubble_up; /* Real implementation here.Defined at
				NDmacro level to allow pretend support */ 

override        NDdrawing_copy_attr, /* copy attr from data base if not   */
				     /* found in model			  */
		NDdrawing_copy_geom; /* hidden line removal		  */

override 	ACreturn_foot;		
override 	ACgive_path;		 

override	NDupdate;

override 	NDsleep;


/*---------------------------------------------------------------------------*/
/* Supports indexing with following feet types:- 
/*
/* 1/feet_in_graphic index using to_components channel for feet 	
/*   	connected by change_feet method called after compute of nci_macro
/*	or nmacro.
/*   Make source and ACgive_path understands these feet and therefore allows 
/*	associative connection after read only locate.
/*			       	    
/* 2/feet_in_template indexed using template channel works for		
/*	nci_macro,nmacro. ACreturn_foot can be overrided to give any object
/*	as one of these feet.
/* 	  
/* 3/feet_virtual not used by nci_macro or nmacro. ACgive_structure 	
/*	can be overriden to support pseudo feet.  		       	
/*---------------------------------------------------------------------------*/

override 	ACfree_rtn_str;	   /*ACcpx return struct caching disabled */  
override 	ACbuild_rtn_str;   /*ACcpx return struct caching disabled */
override 	ACtbuild_rtn_str;  /*ACcpx return struct caching disabled */


/*---------------------------------------------------------------------------
/*  Context management in assoc functions....
/*
/* Conceptually assoc functions preforms the following operations :-
/* (a) ACconstruct_feet generates associative feet.
/* (b) ACcontext_compute_feet performs a load_context (i.e extract context
/*	from old foot if it can be found by matching foot names) and 
/*	computes on each foot.
/* (c) ACchange_feet removes parents from feet and attaches them to the 
/*	resultant collection.
/* 
/* Hence
/* compute_node performs:-
/*	(a),(b)using feet of my_id, (c)
/* ACget_context_s_compute(i.e. a compute in an assoc function) performs:-
/*	ACget_context to load context if old object exits.
/*      (a),(b) using feet of context object given by parent, (c).
/* GRdrop performs :-
/*	(a),(b) with context object my_id, then dependent pretends attach
/*		their dependents to the real feet and my_id is deleted.
/* 
/* Note 1. Symbology management in this context is realized by :-
/*	ACget_context_s_compute for source graphics gets symbology and
/*	does nothing in compute.
/*
/* Note 2. Associative entities containing context dependent instance data 
/* 	should override ACget_context_s_compute method and transfer instance 
/*	if context obj exists.
/*
/*-------------------------------------------------------------------------*/
override        NDcompute_node; 	 /* see context management */
override	GRdrop; 	 	 /* see context management */

message ACcontext_compute( IGRlong *msg; IGRint cn_type;
			   int count ; struct GRid *root;
                           struct GRid *context_obj;
                           struct GRmd_env *md_env);

/* 
   Message used to implement reevaluation of a macro occurence 
   when an NDupdate or when a NDcompute_node is received
*/


message ACcontext_compute_feet(int count;
			struct GRid 	context_obj;
			struct GRid 	*feet_list;
			struct GRmd_env *mod_env);
/*---------------------------------------------------------------------------
/*    The routine does a context compute on all feet. The context object
/* if the matching old foot if it exists.
/*
/*      Argument description :
/*	int 	count	I : Number of feet can be less than the
/*						declared number.
/*	struct GRid 	context_obj	I : Object that has old feet
/*			for NDcompute_node it is allways my_GRid.
/*	struct GRid *feet_list		I : The new feet.
/*	struct GRmd_env *mod_env	I : 
/*
/*
/*---------------------------------------------------------------------------*/

message ACchange_feet(int count;
			struct GRid 	*feet_list;
			struct GRmd_env *mod_env);
/*---------------------------------------------------------------------------
/*    The message attaches new feet to the complex . The new feet are
/* striped of thier parents.
/*    A NULLOBJID or a short list in feet_list are considered as temporary 
/* missing feet. A corresponding error is given to give foot access.
/*
/*      Argument description :
/*	int 	count	I : Number of feet can be less than the
/*						declared number.
/*	struct GRid *feet_list		I : The new feet
/*	struct GRmd_env *mod_env	I : 
/*
/*
/*---------------------------------------------------------------------------*/


/** UTILITY MESSAGES TO OVERRIDE WHEN WRITING NEW ASSOC COMPLEX FUNCTIONS **/
override 	GRgetobjinfo;     /* New name and root name		*/


message ACconstruct_feet( IGRlong *msg; IGRint cn_type;
			   IGRint count; struct GRid list []; 
                           struct GRmd_env *md_env;
			   int *fcount; struct GRid  *feet_list);
/*---------------------------------------------------------------------------
/*    The message generates the resultant feet set, given the compute
/* parameters.
/*    A NULLOBJID or a short list in feet_list are considered as temporary 
/* missing feet. A corresponding error is given to give foot access.
/*
/*      Argument description :
/*	SEE NDcompute_node for first 5 parameters.
/*	IGRlong *msg    O : if not success then compute and change feet
/*			    are not preformed.
/*
/*	int 	fcount	O : Number of feet can be less than the
/*						declared number.
/*	struct GRid *feet_list	I/O: This array is initialized at input to
/*			the number of declared feet. The method fills
/*			the array.
/*
/*---------------------------------------------------------------------------*/


/* SEE NDmove_to_root for different behavior if parent is deleted. */
/* SEE ACreturn_foot and ACgive_structure for pseudo feet.           */
/* SEE NDdelete for  different delete behaviour.		   */
/* SEE NDcopy and NDconnect for  different copy behaviour.         */
/* SEE GRmodify for moving feet.         */


/** UTILITY MESSAGES IN FOR CREATING ASSOC COMPLEX FUNCTIONS  **/

message ACmplace(int *suc,prop     ;  char rep; char *macro_name;
		 int numb_obj;  struct GRid *uplist;struct GRmd_env *mod_env);

message ACmplace_from_def(int *suc,prop     ;  char rep; char *macro_name;
		 int numb_obj;  struct GRid *uplist,*def_occ;
		 struct GRmd_env *mod_env);
/*---------------------------------------------------------------------------
/* This message is used to place an occurence of a ACncpx 
/*	in the design file.  It find the definition attaches template and
/* 	optionally computes and displays.
/* If subclass or ci_macro containing instance data this must be loaded
/* 	with separate message.
/* If used to create an associative function that is a foot of another
/*	function it should be place without compute.
/*
/*      Argument description :
/*      --------------------
/*
/*	int *suc		O : 0 FAILED 1 SUCCESS
/*
/*	prop			I : see macro.h 
/*
/*	rep 			I : navsea representation 
/*
/*	char *macro_name	I : the macro to place
/*
/*	int numb_obj		I : the number of real template
/*
/*	struct GRid *def_occ	I : transfer context has to be performed 
				    from this default occurence
/*
/*	struct GRid *uplist	I : the list of templates
/*
/*---------------------------------------------------------------------------*/

message ACmroot_place(int *suc;                 char rep,*macro_name;
                      int numb_obj;             struct GRid  *ft_objs;
                      struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/*  Imediate creation of root object given feet_list.
/* If subclass or ci_macro containing instance data this must be loaded
/* with separate message.
/*
/*      Argument description :
/*      --------------------
/*
/*      int *suc                O : 0 FAILED 1 SUCCESS
/*
/*      rep                     I : navsea representation
/*
/*      char *macro_name        I : the macro definition to connect to
/*
/*      int numb_obj            I : the number of graphic objects
/*
/*      struct GRid  *rt_objs   I : the feet objects
/*
/*
/*---------------------------------------------------------------------------*/



/**UTILITY MESSAGES IN FOR ACCESSING AND MANIPULATING ASSOC COMPLEX FUNCTIONS**/

/* SEE ACreturn_foot,ACgive_path and ACgive_struct */

override 	ACconsume; /*The array of feet returned by consume are ordered
			     as in the feet definition. NULL_OBJID's are given 
			     for virtual and template feet */ 
override	ACunconsume;  
override 	ACntf_consume,ACntf_unconsume,ACtest_consumed;
/*************************************************************************/
/* Cache control :-
/* method ACconsume :-
/* If not root consume returns real feet and notes object is consumed.
/* If root consume hids feet and notes object is consumed.
/*
/* method ACchange_feet :- Hids feet if object is in consumed state.
/* method ACunconsume   :- Clears consume state and computes.
/* method ACreturn_foot   :- Calls compute if feet are consumed and missing.
/* method NDmove_to_root:- Call compute if their exists feet consumed 
/*			    and missing.
/*
/*************************************************************************/

 message  ACindex_in(char *foot_name;OM_S_MESSAGE *mess);
/*---------------------------------------------------------------------------*/
/* Support routines for consume. 
/*---------------------------------------------------------------------------*/

message ACset_NV_rep(unsigned char rep;struct GRmd_env *mod_env);
/*************************************************************************/
/*    This message is change representation. It changes the representation
/*	and does a wait batch to compute representation.
/*
/*     ARGUMENTS
/*	char prop		I : New representation
/*	SEE nmacro.h
/*************************************************************************/

message ACput_NV_rep(unsigned char rep);
/*************************************************************************/
/*    This message is change representation. It changes the representation
/*	and does not wait batch.
/*
/*     ARGUMENTS
/*	char prop		I : New representation
/*	SEE nmacro.h
/*************************************************************************/
message ACget_NV_rep(unsigned char *rep);
/*************************************************************************/
/*    This message is used to get navsea representation.
/*  
/*     ARGUMENTS
/*	char prop		O : Representation
/*	SEE nmacro.h
/*************************************************************************/

message ACput_rep(int rep,rep_mask);
/*************************************************************************/
/*    This message is change representation. It changes the representation
/*	and does not wait batch.
/*
/*     ARGUMENTS
/*	char prop		I : New representation
/*	SEE nmacro.h

/*************************************************************************/

message ACget_rep(int *rep);
/*************************************************************************/
/*    This message is used to get navsea representation.
/*  
/*     ARGUMENTS
/*	char prop		O : Representation
/*	SEE nmacro.h
/*************************************************************************/
message ACget_STATE(int *rep);
/*************************************************************************/
/*    This message is used to get ACcpx STATE.
/*  
/*     ARGUMENTS
/*	int  STATE		O : Representation
/*	SEE nmacro.h
/*************************************************************************/

message ACchg_STATE(int mask,new_state);
/*************************************************************************/
/*    This message is used to change  ACcpx STATE.
/*  
/*     ARGUMENTS
/*	int  mask      I : bit mask defining the bits to change in STATE
/*      int  new_state I : new value for the modified bits
/*	SEE nmacro.h for STATE meaning
/*************************************************************************/

message ACchange_node ( struct GRmd_env *no_longer_used );
/*************************************************************************/
/*    This message is the same as change node except if the assoc entity
/* is owned it is passed to the top owner before change node is executed.
/*  
/*************************************************************************/

message ACinstanciate_template_feet(long *msg;struct GRid *occurence;
				    int nb_to_instanciate;
				    int rtree_flag);

/* 
   This message instanciates template feet of a macro by copying the template
   and connecting it as member of the macro 

Arguments

msg       	  O : return code
occurence         I : macro occurence having the template connected on channel
		      NDfather can be != targetid in case of NDcopy_to_root
nb_to_instanciate I : number of feet to instanciate. OM_K_MAXINT for all
retree_flag	  I : 0 the created tfeet are not added to the Rtree
		      1 the created tfeet are added to the Rtree
*/


/*---------------------------------------------------------------------------
/*
/*  Naming capability
/*
/*---------------------------------------------------------------------------*/


override        translate,
                add,
                IGRdir.remove,
                dump;

override        GRgetname,
                GRputname,
                GRchgname;

override        delete;

override	GRanalyze_element;

  message DIgive_output( char *out_s);

  /* ABSTRACT

  This message is sent with a "make_message to the expression

  ARGUMENTS

  out_s   I  : The name of the expression
          O  : the name of the expression concatenated with its syntax
  */




/* no support of print */
reject NDprint,NDprint_root;

/* Abstract class */
reject ACconstruct_feet;

end specification ACncpx;
