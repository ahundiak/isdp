/*
/*---------------------------------------------------------------------------
/*
/*  ov_ci_mac.S
/*  Robert Patience
/*  24_aout_89
/*
/*  ABSTRACT :
/*		Slightly simplified ci_macro.
/*
/*	-only supports the me pointer for automatic loading of
/*		internal data. Therefore the user is free to 
/*		change size of internal data;
/*	-doesn't support automatic template loading if names
/*	  exist in ci file.
/*	-supports on feet objects. These cannot be reread but
/*	 can have a variable length
/*---------------------------------------------------------------------------
/* */

class specification ov_ci_mac (0:1) of ACncpx,ci_macro;

from ACncpx inherit 	
			NDcopy,
		    	NDcopy_to_root,
			NDmove_to_root,
		    	GRxform,
			ACbecome_macro,
		    	NDdelete,
			NDmake_source,
		    	ACgive_structure,
			ACreturn_foot,
			ACgive_path,
			ACtbuild_rtn_str,
			ACbuild_rtn_str,
		    	ACfree_rtn_str,
		    	GRgetobjinfo,
		    	ACconsume,
			ACunconsume,
			ACtest_consumed,
		 	NDupdate,
			NDcompute_node;
from ACncpx inherit 	
		GRgetname,
                GRputname,
                GRchgname,
	        NDsleep,
                NDdelete,
		delete;

/* to place ov_ci_mac uses message ci_macro.init or ACmplace */

/* NDcompute_node uses the context management defined in ACncpx but to
allow the same ci code support existing ci macros and nci_macros the ci
call to set_all_extern_feet calls ACncpx.ACcontext_compute_feet and 
ACcpx.ACchange_feet context */

override ACconstruct_feet;

/* 				Internal data is a data storage for each 
/*				occurence of a ov_ci_mac. It is accessed by
/*				declaring a me pointer in the ci code or
/*				the message  give_internal_ptr.
/*				The size is default size is assigned in the
/*				by int_size at creation of macro defn and
/*				can be changed by the update_int_data 
/*				message. */

/*				If char NAVSEA is declared this is 
/*			        automatically load with this occurences
/*				default NAVSEA representation.
/*				SEE nmacro.h */
 
  override 	update_int_data; /* allow changes in size of instance data */  
  reject 	store_internal,	 /* NOT supported */
		give_internal;   /* NOT supported */



/*				Feet objects can be graphic objects or
/*				other root assoc objects. Note for feet
/*				expressions use Gexp. The message
/*				set_all_extern_feet should be used to
/*				create and replace feet.
/*				For variable length feet leave null objects
/*				at end of list.*/
 override 	set_all_extern_feet; 	/* Allows variable feet */

 override 	GRdrop;

 reject		get_extern_feet,	/* NOT supported */
		chang_extern_feet,	/* NOT supported */
 		set_all_intern_feet;	/* NOT supported */



message ci_kl_user_func( 
			IGRchar			*entry;
			struct GRmd_env		*mod_env;
			char   			*user_data;
		       );


message ci_kl_ACget_context_s_compute( IGRlong *msg; IGRint cn_type;
			   struct GRmd_env *md_env;
			   struct GRid context_obj);


message ci_kl_ACgive_structure(int *suc,*direct_index;char *footname;
                struct ret_struct *ptr_rst;struct GRmd_env *md_env);


message ci_kl_NDcompute_node ( IGRlong *msg; IGRint cn_type;
			   IGRint count; struct GRid list []; 
                           struct GRmd_env *md_env);



end specification ov_ci_mac;
