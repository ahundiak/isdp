/*
/*---------------------------------------------------------------------------
/*
/*  ci_macro.S
/*  Serge Frezefond ( ISDC Paris )
/*  21_jul_87
/*
/*  ABSTRACT :
/*
/*	This class is the one that corresponds to an occurence of a ci_macro.
/*	It defines all the messages necessary to create an occurence,
/*	set it external or internal feet, set and get its internal data.
/*
/*	the variables that the user must declared and that are automaticly set
/*	previous to the execution of the ci file.
/*	
/*	struct GRmd_env MOD_ENV;
/*	struct GRid	CI_MACRO_ID;
/*
/*	and if he wants to do a specific treatement for GRxform
/*
/*	short 		MATRIX_TYPE;
/*	double		MATRIX[16];
/*
/*	to simplify the access to the template the user can declare 
/*	the following variables :
/*
/*		struct GRid	<template_name>_GRid;
/*
/*	where template_name is the name of one of its templates.
/*	In the same way he can declare :
/*
/*		struct ret_struct	<template_name>_ret_struct;
/*
/*		for example if LINE1 and POINT1 are 2 templates of 
/*	a ci_macro and if the user overides the message GRxform
/*	the header of the file looks like :
/*
/*		struct GRmd_env 	MOD_ENV;
/*		struct GRid		CI_MACRO_ID;
/*		short 			MATRIX_TYPE;
/*		double			MATRIX[16];
/*		struct GRid		LINE1_GRid;
/*		struct ret_struct	LINE1_ret_struct;
/*		struct GRid		POINT1_GRid;
/*		struct ret_struct	POINT1_ret_struct;
/*
/*	function in the PPL file:
/*	-------------------------
/*
/*	main() : it is the one that create the definition
/*
/*	place () which is activated at placement of the occurence
/*		 when arriving at this point the template are allready
/*		 connected but none of the feet is there.
/*
/*	compute() which is activated whenever one of the parent(template ) 
/*		  of the occurence has been modified.
/*
/*	it can too implements :
/*
/*	NDdelete() which is activated whenever someone try to delete 
/*		   the occurence . This allows the ci_macro to do 
/*		   some cleanup. For example the ci_macro can retroact on its
/*		   template to delete them.
/*
/*	GRxform() which is activated whenever someone tries to move 
/*		  the ci_macro. If the funtion is declared the user 
/*		  must declare too the following variable.
/*
/*		short 		MATRIX_TYPE;
/*		double		MATRIX[16];
/*
/*	NDmove_to_root() wich is activated whenever one of 
/*		         the parent(template ) of the ci_macro 
/*			 has been deleted.
/*
/*	internal data fast access :
/*	---------------------------
/*		when the user has declared an internal data
/*	for a ci_macro each execution will result in a copy of 
/*	the structure from the ci_macro occurence to the
/*	ci code. if this structure is big the user might want to 
/*	have a direct access to this structure through a pointer.
/*	In the case th user need only declare
/*
/*		struct  xxx *ME;
/*	
/*	where 
/*---------------------------------------------------------------------------
/* */

class specification ci_macro (0:1) of ACcpx;

#include "igrtypedef.h"

  instance ci_macro 
  {
    variable IGRchar    	internal_buffer[0];	/* contains internal */
  };

  message obj_init  ( 
			IGRint 	*status; 
                  	IGRchar *cpx_name;
                  	OMuint 	count; OM_S_OBJID *list;
                  	IGRchar *internal );

/*---------------------------------------------------------------------------
/*     This message is used to place an occurenceof a ci_macro
/*
/*      Argument description :
/*      --------------------
/*	IGRint 	*status 	O : 0 failed 1 success
/* 
/*     	IGRchar *cpx_name 	I : the name of the ci macro to place
/*				this is the name found in :constructs
/*
/*     	OMuint 	count 		I : the number of elements in list
/*
/* 	OM_S_OBJID *list 	I : the list of real template ( there can be 
/*				symbol macro, ci_macro, expanded macro or
/*				simple objects depending if an edition
/*				of the template has occured on 
/*				the macro definition
/*
/*     	IGRchar *internal 	I : a pointer to the internal structure
/*			        (it allows initialisation of internals.)
/*				this structure must be of the same size as 
/*				the one defined in the ci implementing
/*				the place and compute functions.
/*
/*---------------------------------------------------------------------------
/* */


  message init  ( 
			IGRint 	*status; 
			IGRint	prop;
                  	IGRchar *cpx_name;
                  	OMuint 	count; struct GRid *list;
                  	IGRchar *internal;
			struct GRmd_env	*md_env
                );
/*---------------------------------------------------------------------------
/*     This message is used to place an occurenceof a ci_macro
/*
/*      Argument description :
/*      --------------------
/*	IGRint 	*status 	O : 0 failed 1 success
/* 
/*	IGRint	prop		I : the following values are the possible
/*				  ones. AChdr_nobuild and AChdr_nocompute 
/*				  give the same behaviour. This flag are
/*				  the same as the ones for the
/*				  ACsym.ACplace message.
/*
/* 	#define AChdr_nobuild   	1  exit before rebuild  	*/
/* 	#define AChdr_nocompute 	2  exit before compute 		*/
/* 	#define AChdr_nodisplay 	4  exit before display  	*/
/* 	#define AChdr_noprotect 	8  do not do make_source  	*/
/* 	#define AChdr_norange        	16 exit before adding in range  */
/*
/*
/*     	IGRchar *cpx_name 	I : the name of the ci macro to place
/*				this is the name found in :constructs
/*
/*     	OMuint 	count 		I : the number of elements in list
/*
/* 	struct GRid *list 	I : the list of real template ( there can be 
/*				symbol macro, ci_macro, expanded macro or
/*				simple objects depending if an edition
/*				of the template has occured on 
/*				the macro definition
/*
/*     	IGRchar *internal 	I : a pointer to the internal structure
/*			        (it allows initialisation of internals.)
/*				this structure must be of the same size as 
/*				the one defined in the ci implementing
/*				the place and compute functions.
/*
/*	struct GRmd_env	*md_env	I :
/*
/*---------------------------------------------------------------------------
/*  */


  message store_internal ( IGRint *status; IGRchar *p_internal );
/*---------------------------------------------------------------------------
/*      This message is used to load the internal data. usualy p_internal
/* 	is pointing to a structure defined in the PPL file.
/*      Only works on sizes defined in definition.
/*      Argument description :
/*     --------------------
/*
/*        IGRint *status          O : the returned status
/*                                      OM_S_SUCCESS : successfull operation
/*                                      OM_E_ABORT   : fatal error
/*
/*        IGRchar *internal       I : the internal data
/*
/*---------------------------------------------------------------------------
/* */


  message give_internal ( IGRint *status; IGRchar *p_internal );
/*---------------------------------------------------------------------------
/*      This message is used to return the internal data
/*      Usualy p_internal is pointing to a structure defined in the PPL file.
/*      Only works on sizes defined in definition.
/*
/*      Argument description :
/*      --------------------
/*
/*        IGRint *status          O : the returned status
/*                                      OM_S_SUCCESS : successfull operation
/*                                      OM_E_ABORT   : fatal error
/*
/*        IGRchar *internal       O : the internal data. the user must give
/*				  a pointer to an area of suffisant space(
/*				  the one given at the creation of 
/*				  the definition).
/*
/*---------------------------------------------------------------------------
/* */

  message update_int_data( int *status, size);
/*---------------------------------------------------------------------------
/* This will change the storage size of the ci_macro occurence only if
/* the definition size was defined as 0  
/*---------------------------------------------------------------------------
/* */

  message give_internal_ptr ( IGRint *status; IGRchar **p_internal_ptr );
/*---------------------------------------------------------------------------
/*      This message is used to return a pointer the internal data.
/*	This avoid a copy of the structure. 
/*	the user must be very confident in what he is doing because 
/*	what he get is a pointer in the instance data.
/*
/*      Argument description :
/*      --------------------
/*
/*        IGRint *status          O : the returned status
/*                                      OM_S_SUCCESS : successfull operation
/*                                      OM_E_ABORT   : fatal error
/*
/*        IGRchar **p_internal_ptr O : a pointer to the internal data. 
/*
/*---------------------------------------------------------------------------
/* */

message set_all_extern_feet( 	
			IGRint 		*status;
			IGRint		nbobj;
			struct GRid 	*grobj_ids;
			struct GRmd_env	*mod_env;
		           );
/*---------------------------------------------------------------------------
/*      This message is used to set an objid to all the external feet
/*	at once(nbobj must be equal to the number of external 
/*	feet declared at macro definition). To allow the user to handle
/*	variable number of feet some of the elements given in the grobj_ids
/*	can be NULL_OBJIDs;
/*		The user must notice that order of the feet must be
/*	the one of the definition declaration.
/*
/*      Argument description :
/*      --------------------
/*
/*      IGRint *status          O : the returned status
/*                                      OM_S_SUCCESS : successfull operation
/*                                      OM_E_ABORT   : fatal error
/*
/*      IGRint nbobj          	I : number of extern feet to set
/*
/*	struct GRid *grobj_ids	I : the associated objid of the feet to be set
/*
/*---------------------------------------------------------------------------
/* */

message get_extern_feet( 	
			IGRint 		*status;
			IGRint		nb_extern;
			IGRchar		**foot_name;
			struct GRid 	*grobj_old
		);
message get_exp_extern_feet( 	
			IGRint 		*status;
			IGRint		nb_extern;
			IGRchar		**foot_name;
			IGRint		*direct_ext_feet_index;
			struct GRid 	*grobj_old
		);
/*---------------------------------------------------------------------------
/*
/*      This message is used to obtain one or a list of external feet.
/*	The returned objects are GRid of graphic object 
/*	not associative objects.
/*
/*      Argument description :
/*      --------------------
/*
/*      IGRint *status          O : the returned status
/*                                OM_S_SUCCESS : successfull operation
/*                                OM_E_ABORT   : fatal error
/*
/*	IGRint nb_extern	I : number of extern feet to find
/*
/*      IGRchar **foot_names   	I : the array of foot names
/*
/*	IGRint *direct_ext_feet_index
/*				I : list of the index of the extern feet
/*				    relative to the order of their declaration;
/*				    Should be put to NULL if foot_names used.
/*
/*	struct GRid *grobj	O : the objids of the objects found
/*
/*---------------------------------------------------------------------------
/* */
     

message chang_extern_feet( 	
			IGRint 		*status;
			IGRint		nb_extern;
			IGRchar		**foot_names;
			struct GRid 	*grob_news;
			struct GRmd_env	*mod_env;
			);
message chang_exp_extern_feet( 	
			IGRint 		*status;
			IGRint		nb_extern;
			IGRchar		**foot_names;
			IGRint 		*direct_ext_feet_index;
			struct GRid 	*grob_news;
			struct GRmd_env	*mod_env;
			);
/*---------------------------------------------------------------------------
/*
/*      This message is used to to change one or more of the external foot
/*	by another object. This operation respect the objects that were
/*	depending on this one.
/*
/*      Argument description :
/*      --------------------
/*
/*      IGRint *status          O : the returned status
/*                                1 : successfull operation
/*                                0 : fatal error
/*
/*	IGRint nb_extern	I : number of external feet you want to change
/*
/*      IGRchar **foot_names   	I : the foot names of the objects to change
/*
/*	IGRint *direct_ext_feet_index
/*				I : list of the index of the extern feet
/*				    relative to the order of their declaration;
/*				    Should be put to NULL if foot_names used.
/*
/*	struct GRid *grob_news 	I : the objid of the new object 
/*
/*---------------------------------------------------------------------------
/* */

message set_all_intern_feet( 	
			IGRint 			*status;
			struct ret_struct 	**intern_struct
		       );
/*---------------------------------------------------------------------------
/*      This message is used to set all the internal feet at once.
/*	the returned structures must be given in the same order 
/*	the internal feet were declared. This is the fastest way for the user
/*	to set or change all the internal feet at once.
/*
/*      Argument description :
/*      --------------------
/*
/*      IGRint *status          O : the returned status
/*                                      OM_S_SUCCESS : successfull operation
/*                                      OM_E_ABORT   : fatal error
/*
/*	struct ret_struc **intern_struct:
/*				I : the returned structure of the feet in
/*				    the correct order.
/*
/*---------------------------------------------------------------------------
/* */


message set_intern_feet( 	
			IGRint 			*status;
			IGRint			nbobj;
			IGRchar			**feet_names;
			struct ret_struct 	**intern_struct
		       );
message set_exp_intern_feet( 	
			IGRint 			*status;
			IGRint			nbobj;
			IGRchar			**feet_names;
			IGRint 			*direct_ext_feet_index;
			struct ret_struct 	**intern_struct
		       );
/*---------------------------------------------------------------------------
/*      This message is used to set or change the returned structure 
/*	asociated with an internal feet.
/*
/*      Argument description :
/*      --------------------
/*
/*      IGRint *status          O : the returned status
/*                                      OM_S_SUCCESS : successfull operation
/*                                      OM_E_ABORT   : fatal error
/*
/*	IGRint nbobj		I : number of internal feet to set
/*
/*      IGRchar **feet_names    I : the internal foot names to be set
/*
/*	IGRint *direct_ext_feet_index
/*				I : list of the index of the extern feet
/*				    relative to the order of their declaration;
/*				    Should be put to NULL if foot_names used.
/*
/*	struct ret_struc        I : **intern_struct:
/*
/*---------------------------------------------------------------------------
/* */


message execute_func( 	
			IGRint 			*status;
			IGRchar			*entry;
			struct GRmd_env		*mod_env;
		       );
/*---------------------------------------------------------------------------
/*      This message is used to activate the execution of a function
/*	wich is implemented in the ci file.
/*
/*      Argument description :
/*      --------------------
/*
/*      IGRint *status          O : the returned status
/*                                      OM_S_SUCCESS : successfull operation
/*                                      OM_E_ABORT   : fatal error
/*
/*      IGRchar *entry   	I : the function name defined in the PPL file.
/*
/*---------------------------------------------------------------------------
/* */

  message print_struct ( struct ret_struct *rst );
  /*
     Debug purpose only : print the returned structure.
  */

  override NDcompute_node;  
  override ACgive_structure;
  override debug;
  override NDprint;	
  override ACreturn_foot;
  override ACgive_path;

/*---------------------------------------------------------------------------
/*     		This message is overriden to activate the execution of 
/*	the GRxform function defined in the implementation file
/*	This function is not mandatory in the PPL file.
/*	If he overide this function the user must have declared the variables
/*
/*		short 	MATRIX_TYPE;
/*		double 	MATRIX[16];
/*
/*---------------------------------------------------------------------------*/
  override GRxform;

/*---------------------------------------------------------------------------
/*     This message is overriden to activate the execution of the NDdelete
/*     function defined in the implementation file
/*	This function is not mandatory in the PPL file.
/*	This function is activated whenever someone tries to delete the 
/*	ci_macro.
/*		If the function is not defined in the PPL file the usual
/*	behaviour of associative object will occur. That means the graphic
/*	objects and the ci_macro will be deleted.
/*	
/*---------------------------------------------------------------------------*/
  override NDdelete;

/*---------------------------------------------------------------------------
/*     		This message is overriden to activate the execution of 
/*	the NDmove_to_root function defined in the implementation file
/*	This function is not mandatory in the PPL file.
/*		This function is activated whenever one of the parent
/*	(template) of this ci_macro is deleted.
/*
/*---------------------------------------------------------------------------*/
  override NDmove_to_root;

/*---------------------------------------------------------------------------
/* 
/* 
/*---------------------------------------------------------------------------*/
/*  wait for it to be in  ACcpx.S */
/*  override ACchange;	 to be able to replace a ci macro by another one */

/*---------------------------------------------------------------------------
/* 
/* 
/*---------------------------------------------------------------------------*/
 message ACreplace(struct GRmd_env *md_env);

end specification ci_macro;
