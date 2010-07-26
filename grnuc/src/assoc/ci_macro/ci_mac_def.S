/*
/*---------------------------------------------------------------------------
/*
/*  ci_mac_def.S
/*  Serge Frezefond ( ISDC Paris )
/*  21_jul_87
/*
/*  ABSTRACT
/* 		This class implement the methods necessary for 
/*	a ci macro definition.	A full documentation on how to use ci_macro 
/*	can be found in PPL(parametric programing langage, ci) 
/*	documentation().
/*		Examples of various ci macro can be found in the
/*	$DRAFT/ppl directory for those who have the I/Draft 
/*	developement platform .
/* 
/*---------------------------------------------------------------------------*/
class specification ci_mac_def (0:1) of ACmacro_defn;

#include "igrtypedef.h"
#include "ci_macro.h"

  instance ci_mac_def 

  {
    struct   	ci_mac_st  desc;/* data structure description in ci_macro.h */
				/* struct ci_mac_st
				/* {
				/*   The name of the ci file	*/
  				/*   IGRchar  ci_name [15];	*/
				/*   The Internal data name 	*/	
  				/*   IGRchar  int_name [16];	*/
				/*   The Internal data size 	*/
  				/*   IGRshort int_size;		*/
				/* }				*/

    IGRint	temp_feet_num;
    IGRint	intern_feet_num;
    IGRint 	extern_feet_num;
  };

  override ACunmap_hdr;
  override NDprint_root; 

  message ACplace ( 
	IGRint   *status;		
	IGRint prop;			IGRchar  *cpx_name;
	IGRchar  *int_name;		IGRint int_size;
	IGRint temp_num;		IGRchar **temp_names;	
	IGRint *temp_types;
	IGRint temp_feet_num;   
	IGRint *temp_feet_index;	IGRchar **temp_feet_names;
	IGRint intern_feet_num; 	IGRchar **intern_feet_names;
	IGRint *intern_feet_types;	    	
	IGRint extern_feet_num; 	IGRchar **extern_feet_names;
	IGRint *extern_feet_types;	
	IGRint *feet_order );
/*---------------------------------------------------------------------------
/*      This message is used to place the ci_mac_def. It is
/*	the only message nessary to create a macro definition
/*	The user does not need to do an edit template if no special
/*	mapping is necessary between the definition templates and
/*	the one that will be required at placement of an ocurence.
/*
/*      Argument description :
/*      --------------------
/*
/*      IGRint *status       	O  : the returned status
/*                                      OM_S_SUCCESS : successfull operation
/*                                      OM_E_ABORT   : fatal error
/*
/*	IGRint prop		I :
/*		
/*      IGRchar  *cpx_name	I : by default a file with .u(or .e if allready 
/*				compiled) suffix is used to dynamic load. 
/*				the name of the ci file implementing the macro
/*				can be changed by the message ACchange_ci_name.
/*				this ci file must at least implement the
/*				functions :
/*
/*					place ()
/*					compute()
/*
/*				it can too implements :
/*
/*					NDdelete()
/*					GRxform()
/*					NDmove_to_root()
/*
/*    	IGRchar  *int_name 	I : name of the internal structure variable
/*				that will be declared in the ci file 
/*				implementing the macro.This variable can
/*				be used to save flag or non graphic information
/*				that will be used for the internal computation
/*				and not be referenced by other macros 
/*				connecting to this one.
/*
/*	IGRint int_size 	I : size of the internal structure in bytes.
/*
/*	IGRint temp_num 	I : number of templates.
/*
/*	IGRchar **temp_name 	I : templates names
/*
/*	IGRint temp_feet_num 	I : number of templates that are also named feet.
/*
/*	IGRint temp_types 	I : define the type of object accepted
/*				at the placement of an occurence
/*				(line_generic..). These types are defined in
/*				parametric.h
/*				if NULL means any type is OK.
/*
/*	IGRint temp_feet_index  I : index in the templates of the templates
/*				that are also named feet.
/*
/*	IGRchar **temp_feet_names : their names as feet
/*
/*	IGRint intern_feet_num 	I : feet stored in the ci as pointer 
/*				to returned structure	.
/*
/*	IGRchar **intern_feet_name 
/*				I : their names
/*
/*	IGRint *intern_feet_types 
/*				I : define the type of internal feet
/*   	
/*
/*      IGRint extern_feet_num 	I : number of feet existing as real objects
/*				on the to components channels. All objects
/*				on this channel are named feet.
/*
/*	IGRchar **extern_feet_name 
/*				I : their name
/*
/*	IGRint *extern_types 	I : define the type of external feet
/*
/*	IGRint *feet_order 	I :
/*
/*      FOR SIMPLICITY :
/*      ================
/*
/*      There exist a macro ac$macdef() in the 
/*	$GRNUC/ppl/include/ci_mac_def.h file
/* 	this macro defines default values for most of these arguments.
/*
/*---------------------------------------------------------------------------
/* */


 message ACgive_cim_desc ( 	IGRint  *status;
                       		struct  ci_mac_st **p_desc;
				IGRint	*temp_feet_num, 
					*intern_feet_num, *extern_feet_num
                         );
/*---------------------------------------------------------------------------
/*
/*      This message is used to give the data associated with the definition.
/*	to obtain more specific information the user can send the messages :
/*
/*	ACcpx_defn.ACgive_name( char **name );
/*	ACcpx_defn.ACgive_temp_desc( int *temp_num; struct stemp  **temp_defn );
/*	ACcpx_defn.ACgive_feet_desc( int *feet_num; struct myfeet **myfeet) ;
/*
/*	ACmacro_defn.ACgive_upscan( int *tot_up,*prop;struct sup **xdup);
/*
/*      Argument description :
/*      --------------------
/*
/*      IGRint *status  	O : the returned status
/*                              OM_S_SUCCESS : successfull operation
/*                              OM_E_ABORT   : fatal error
/*
/*      struct ci_mac_st **p_desc  
/*				O : the data description structure (ci_mac_st
/*				is defined in ci_macro.h)
/*
/*	IGRint	*temp_feet_num	O : number of template feet
/*
/*	IGRint *intern_feet_num	O : number of internal feet
/*
/*	IGRint *extern_feet_num	O : number of external feet
/*
/*---------------------------------------------------------------------------
/* */

 message ACchange_ci_name ( 	IGRint  *status;
                       		IGRchar *new_ci_name );
/*---------------------------------------------------------------------------
/*
/*        	This message is used to change the ci that will implement 
/*	the function except the main creating the definition .
/*		This allow the user to have a different ci
/*	file for the definition creation and the place compute and 
/* 	user functions.
/*
/*      Argument description :
/*      --------------------
/*
/*      IGRchar *new_ci_name	I : name of the ci file 
/*
/*---------------------------------------------------------------------------*/
end specification ci_mac_def;
