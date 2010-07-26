/*
/*---------------------------------------------------------------------------
/*  Robert Patience
/*  macro used to create a simplified ci macro definition
/*---------------------------------------------------------------------------
*/


/* */
/*---------------------------------------------------------------------------
/*      This macro  is used to create a ci_macro definition. It is
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
/*				this ci file must at least implement the
/*				functions :
/*
/*					place ()
/*					compute()
/*				and can override many other messages
/*
/*
/* 				Internal data is a data storage for each 
/*				occurence of a nci_macro. It is accessed by
/*				declaring a me pointer in the ci code or
/*				the message  give_internal_ptr.
/*				The size is default size is assigned in the
/*				by int_size at creation of macro defn and
/*				can be changed by the update_int_data 
/*				message.
/*				
/*	IGRint int_size 	I : size of the internal structure in bytes.
/*
/*	IGRint temp_num 	I : maxium number of templates.
/*
/*	IGRchar **temp_name 	I : templates names. To vary length of template
/*				    drop objct from end of template.
/*
/*				Feet objects can be graphic objects or
/*				other root assoc objects. Note for feet
/*				expressions use Gexp. The message
/*				set_all_extern_feet should be used to
/*				create and replace feet.
/*				For variable length feet leave null objects
/*				at end of list.
/*
/*      IGRint extern_feet_num 	I : max number of feet existing as real objects
/*				on the to components channels. All objects
/*				on this channel are named feet.
/*
/*	IGRchar **extern_feet_name 
/*				I : their name
/*
/*
/*      FOR SIMPLICITY :
/*      ================
/*
/*
/*---------------------------------------------------------------------------
/* */

extern struct GRid 	AC_construct_id;
#omdef ac$cimacdef( cimacdef,
		status, 		
		prop=0,			name,
		int_size=0,
		temp_num, 		temp_names,
		temp_types=0,	
		extern_feet_num=0,	extern_feet_names=0)
{
	ci$send( msg = message ci_mac_def.ACplace(
			(status), 		
			(prop),			(name),
			(""),			(int_size),
			(temp_num), 		(temp_names),
			(temp_types),	
			(0),	
			(0),			(0),
			(0),			(0),
			(0),
			(extern_feet_num),	(extern_feet_names),
			(0),
			(0) ),
		 targetid = (cimacdef) ,targetos=AC_construct_id.osnum);
}
	
#endomdef

/* 
   ABSTRACT
   ARGUMENTS
*/


