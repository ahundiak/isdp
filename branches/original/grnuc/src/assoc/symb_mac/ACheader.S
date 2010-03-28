/*
Name
        ACheader

Abstract
	New class for occurence of symbol macro.

History
        ludovic Le Corvec 15_sept_90  created
        mrm     02/22/93    Changed to inherit GRclip from GRsmhdr; it was 
                            being rejected, which caused plot from reference
                            file or by fence to drop the symbol macro.  See
                            TR119301229.
*/

class specification ACheader (0:0) of GRsmhdr,ACconst;

#include "ACheader.h"

from GRsmhdr inherit
			GRgenabsg,
			GRpostabsg,
			GRgetsize,
			GRgetgeom,
			GRgenabsg,
			GRgetrang,

			GRaddwrng,
			GRremwrng,
			GRownaddwrng,
			GRownremwrng,

			GRget_owner_properties,
			GRchg_owner_properties,

			GRchgprops,
			GRgetprops,
			GRchglevel,
			GRchgprops,
			GRchgcolor,
			GRchgdp,
			GRchgstyle,
			GRchgweight,
			GRputsymb,
			GRgetsymb,

			GRget_matrix,
			GRget_context,
		
			GRprismrel,
			GRclip,

			GRplotyourself;


reject	GRconstruct,
	GRmv_sh_to_new_sdh,
	GRcp_symbol_to_cell;


/* modify associative message */
override	ACmplace_from_def,      /* use occ symb */
		ACreturn_foot,		/* modify matrix */
		ACgive_path,		/* give path of tf_foot */
		ACgive_structure,	/* ask to model */
		NDdelete,		/* disconnect from model and delete */
		NDsleep,		/* clean tf_foot */
		NDcopy,			/* place a new header */
		NDrm_assoc;

override	ACcontext_compute,
		ACconsume,
		ACunconsume;

/* modify graphic message */
override	GRdrop,			/* replace header by graph of 
								dependency */
		GRdisyourself,
		GRlocate,		/* select share feet */
		GRlocate_processing,	/* send GRvg locate processing */
		GRgetobjinfo,		/* add symb in path */
		GRxform,		/* up date inst data with */
					/* STATE ncpx_root */
		GRptproject,		/* check share feet */
		GRlnproject,		/* check share feet */
		GRptprocess,		/* check share feet */
		GRlnprocess,		/* check share feet */
		GRdelete;

/* ********* PRIVATE MESSAGES ************** */
/* print instance data */
message ACshow_data ( IGRlong	*msg );

/* store temporaty id and name of true false foot */
message ACstore_tf_foot( IGRlong *msg; struct tf_foot *temp_foot );

/* retrieve name of tf_foot coresponding to the given id */
message ACget_name_of_tf_foot( IGRlong *msg; struct tf_foot *temp_foot );

/* modif an existing tf_foot */
message ACmod_tf_foot( IGRlong *msg; struct tf_foot *tf_foot );

/* clean ACheader of tf_feet create by locate. If del_flag delete tf_foot */
/* objects else clean only tf_feet array */
message ACclean_tf_foot( IGRlong *msg; struct GRmd_env *md_env;
							IGRboolean del_flag );


/* ********* PUBLIC MESSAGES ********** */

/* *******************************************************************	*/
/*  ACget_share_feet_list
/*
/*	get count of feet and feet list if specify 
/*
/*	*msg		IGRlong		return code 
/*	size_list	IGRint		size of list to return feet
/*	*feet_list	struct	GRid	list of Grid of the shared feet 
/*	*count_feet	IGRint		get the number of feet for header
/*
/*	if size_list = 0 or feet_list = NULL, no Grid are set in feet_list
/*
/* --------------------------------------------------------------------	*/

message ACget_share_feet_list( 	IGRlong *msg; IGRint size_list; 
				struct GRid *feet_list; IGRint	*count_feet );

/* ********************************************************************	*/
/*  ACfind_model
/*
/*	get GRid of model with respect of template values and representation
/*	data
/*
/*	*msg	IGRlong		return code 
/*	*model	struct	GRid	GRid of model for current header
/*
/*	if objid of model = NULL_OBJID, no model has be find 
/*
/* --------------------------------------------------------------------	*/

message ACfind_model( IGRlong *msg; struct GRid *model );

/* ********************************************************************	*/
/*  ACget_model_mgr
/*
/*	get GRid of model_mgr. If is not found, build one 
/*	
/*	*msg	IGRlong		return code 
/*	*model	struct	GRid	GRid of model_mgr for current header
/*
/* --------------------------------------------------------------------	*/

message ACget_model_mgr( IGRlong *msg; struct GRid *model_mgr );


end specification ACheader;


