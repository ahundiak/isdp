/*
/*---------------------------------------------------------------------------
/*
/*  nci_macro.S
/*  Robert Patience
/*  24_aout_89
/*
/*  ABSTRACT :
/*		Non functional class allowing overriding of many
/*	ov_ci_mac methods as ci functions.
/*
/*	-overridable messages become function in ci with same
/*	  parameters.
/*---------------------------------------------------------------------------
/* */

class specification nci_macro (0:1) of ov_ci_mac;


/* OVERRIDABLE messages look in ci_file for function with same name
	as message if it exists then it is called. The ci_function
	can resend to the nci_macro method if it require default
	processing.
*/

/* Graph behaviour */
  override NDdelete;			/*OVERRIDABLE */
  override NDmove_to_root;		/*OVERRIDABLE */
  override NDcopy;			/*OVERRIDABLE */
  override NDgive_structure;		/*OVERRIDABLE */
  override NDmake_source;		/*OVERRIDABLE (PRIVATE USE ONLY) */
  override NDdrawing_copy_geom;
  
/* Graphic behavior */
  override 	GRxform;		/*OVERRIDABLE */
  override 	GRmodify;		/*OVERRIDABLE */
  override 	GRlocate_owner; 	/*OVERRIDABLE */

/* Controll of indexing inherited from ACncpx */
  override 	ACreturn_foot;		/*OVERRIDABLE */
  override 	ACgive_path;		/*OVERRIDABLE */
  override 	ACgive_structure;		/*OVERRIDABLE */

/* 
 * Overrides for PDM copy and delete hooks.
 *
 * History: Jay Wallingford 10/15/93 Added override for PDM Hooks.
 */
override    GRdelete,                /* overriden from ASnode      */
            GRcopy,                  /* overriden from ACcpx       */
            GRcptform,               /* overriden from GRgraphics  */
            ACdrop,                  /* overriden from AScpx       */
            GRdrop,                  /* overriden from ov_ci_macro */
            GRchgname,               /* overriden from ASncpx     */
            GRflexconn;              /* overriden from GRconnector*/


message user_func( 
			IGRchar			*entry;
			struct GRmd_env		*mod_env;
			char   			*user_data;
		       );
/*---------------------------------------------------------------------------
/*      This message is used to activate the execution of a function
/*	wich is implemented in the ci file.
/*
/*      Argument description :
/*      --------------------
/*
/*
/*      IGRchar *entry   I : the function name defined in the PPL file.
/*
/*      calls function in ci file of form :-
/*	 entry(struct GRmd_env *mod_env;char   *user_data)
/*
/*---------------------------------------------------------------------------
/* */

end specification nci_macro;
