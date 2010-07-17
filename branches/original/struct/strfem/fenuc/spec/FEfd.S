class specification FEfd (1:0) of GRlistener,Rootmsg,NMassoc;

#include	<stdio.h>
#include	"OMerrordef.h"
#include	"FDdef.h"
#include	"FDstruct.h"
#include	"APdef.h"
#include	"APerrmac.h"

/* *****************************H H H H H******************************* */
/* Doc: FEfd

   Abstract: Abstract class for feature descriptors. Not all
	fd's have a graphics help attached to them.  Uniformly distributed 
	fd's do not need graphics help but may have them if the user so wishes.
	See FEfddef.h for prop values.
	
   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      08-06-87	kk		Creation
      03-11-88	ahs		Implement FE_FD_INFO, get_fd_info
      07-23-88	kk		Upgraded to separate module
      09-19-88	ahs		Changed to_symbol chan to many_to_many
      04-12-89	ahs		Added message match_fd
      03-30-91	kk	2.0.0	Added to_desvar channel : DATABASE CHANGE
				Added desvar_mode argument to xpos_value
      04-27-91	kk	2.0.0	Subclassed from EMSassoc for associativity
      04-29-91	kk	2.0.0	Added init_associative_1d message
      10-12-91	kk	2.0.0	Added place_fd message
      10-28-91  raj	2.0.0	Added 'setup_smb_args' message.
      12-11-91  raj	2.0.0	Override 'NDupdate'.
      02-11-92	raj/kk	2.0.0	Added 'cs_grid' argument in fd_init message.
      02-22-92	raj	2.0.0	Changed one parent from 'EMSassoc' to 'NMassoc'.
      03-16-92	raj	2.0.0	Added argument 'cs_info' to method 'xpos_value'.
      03-20-92	raj	2.0.0	Added argument 'cs_info' to method 'get_coord_sys'.
      04-04-92	kk	2.0.0	Added FDxform, FDcopy, FDcptform messages.
      04/21/92	raj	2.0.0	Override 'NDparent_deleted'.
      09/29/92	bwh	2.1.0	added elem_refinement message.  
      04/15/93	raj	2.2.0	Added message 'inc_rsman_fd_count'.
*/
/* *****************************H H H H H******************************* */

channel to_owner	{(many_to_one)};
channel	to_mainsymbol	{(rel_ordered,many_to_many,initial=1,increment=5)
				GRnotify.notification;};
channel	to_nudef	{(abs_ordered,one_to_many,initial=1,increment=5)
				FEfdnudef.to_fd;};
channel to_desvar	{(abs_ordered,one_to_many,initial=1,increment=5)
				FEdesvar.to_dvqty;};
instance FEfd
{
	channel to_owner	to_owner;	/* to manager of fd's	*/
   	channel	to_mainsymbol	to_mainsymbol;	/* to feature symbol	*/
   	channel	to_nudef	to_nudef;	/* to non-unif definition*/
	channel to_desvar	to_desvar;	/* to design variables	*/
	channel	{}		to_any;		/* to any other object	*/
	variable char		unif_fd_data[];	/* cannot have graphics help*/
	variable double		var_fd_data[];	/* can have graphic helps */
	FD_INFO			info;		/* Parameters : FDstruct.h*/
};

/*
**  -------------------------------------------------------------------
**  fd_init:
**  -------------------------------------------------------------------
*/
message fd_init(
	long		*msg;		/* o - Return Status		*/
	FD_INFO		fd_inf;		/* i - fd info			*/
	char		unif_fd_data[]; /* i - data that cannot have
							graphics help	*/
	double		var_fd_data[];	/* i - data that can have
							graphics help	*/
	struct GRid	cs_grid;	/* i - Coord system used	*/
);

/*
**  -------------------------------------------------------------------
**  xpos_value:
**  -------------------------------------------------------------------
**	Exposes FD instance data.
**	Note: Parameter uv: parameter/s of point at which the value of feature
**		descriptor required.
**	Dimension : uv
**	  0	  : not applicable
**	  1	  : u parameter of b-spline curve
**	  2	  : uv[0,1] = u,v parameters of b-spline surface
**	  3	  : uv[0,1,2] = x,y,z coordinates of point within solid
*/
message xpos_value (
	long		*msg;		/* o - Return Status		*/
	double		*uv;		/* i - Point at which data reqd	*/
	long		unif_data_size;	/* i - size of unif data in bytes */
	long		max_var_data;	/* i - max number of var data	*/
	char		desvar_mode;	/* i - TRUE: return value defined by design variable
					       FALSE : return values stored in FEfd instance */
	FD_INFO		*fd_inf;	/* o - fd info			*/
	char		unif_fd_data[]; /* o - Non-varying data		*/
	double		var_fd_data[];	/* o - Spatially varying data	*/
	struct APcs_info *cs_info;	/* o - Coord system data	*/
);

/*
**  -------------------------------------------------------------------
**  update:
**  -------------------------------------------------------------------
*/
message  update (
	long		*msg;		/* o - Return Status		*/
	FD_INFO		fd_inf;		/* i - fd info			*/
	char		unif_fd_data[]; /* i - data that cannot have
							graphics help	*/
	double		var_fd_data[];	/* i - data that can have
							graphics help	*/
	OM_S_OBJID	nudef_objid;	/* i - objid of graphic help	*/
);

/*
**  -------------------------------------------------------------------
**  connect_gxhsym_feature:
**  -------------------------------------------------------------------
*/
message connect_gxhsym_feature(
	long		*msg;		/* o - Return Status		*/
	struct GRid	feature_grid;	/* i- Geometric feature		*/
	struct GRid	gxhsymbol_grids[];/* i - nudef symbol		*/
	struct GRid	nudef_grids[];	/* i - grids of graphic helps	*/
	long		num_gxh_objects;/* i - number of graphic help objects*/
	struct GRid	mainsymbol_grid;/* i - grid of main symbol
						may be NULL		*/
);

/*
**  -------------------------------------------------------------------
**  connect_feature: 
**  -------------------------------------------------------------------
*/
message connect_feature(
	long		*msg;		/* o- Return Status		*/
	struct GRid	feature_grid;	/* i- Geometric feature		*/
	struct GRid	symbol_grid; 	/* i- Main symbol		*/
);

/*
**  -------------------------------------------------------------------
**  disconnect_feature: 
**  -------------------------------------------------------------------
*/
message disconnect_feature(
	long		*msg;		/* o- Return Status		*/
					/* Only one of the following needed */
					/* The other should be NULL_grid*/
	struct GRid	*feature_grid;	/* i- Geometric feature		*/
	struct GRid	*symbol_grid; 	/* i- Main symbol		*/
);

/*
**  -------------------------------------------------------------------
**  init_defaults: 
**  -------------------------------------------------------------------
*/
message init_defaults(
	long		*msg;		/* o - Return Status		*/
	char		fd_type;	/* i - FORCE_TYPE,ISOMAT_TYPE,..*/
);

/*
**  -------------------------------------------------------------------
**  get_fd_info: 
**  -------------------------------------------------------------------
*/
message get_fd_info(
	long		*msg;		/* o - Return Status		*/
	FD_INFO		*fd_inf;	/* o - Feature descriptor info	*/
);

/*
**  -------------------------------------------------------------------
**  verify_consistency: 
**  -------------------------------------------------------------------
*/
message verify_consistency(
	long		*msg;		/* o - Return Status		*/
	long		flags;		/* i - 0x1 : delete if failure	*/
);	

/*
**  -------------------------------------------------------------------
**  match_fd: 
**  -------------------------------------------------------------------
*/
message match_fd(
	long		*msg;		/* o- Method return status	*/
	unsigned long	match_mask;	/* i- Bit flag (see FEfddef.h)	*/
	FD_INFO		*fd_inf;	/* i- FD info must be provided	*/
	char		*unif;		/* i- Can be NULL or valid addr	*/
	double		*var;		/* i- Can be NULL or valid addr	*/
	char		*match;		/* o- TRUE if a match is made	*/
	struct GRid	*match_grid;	/* o- Valid only if match=TRUE	*/
);

/*
**  -------------------------------------------------------------------
**  connect_fd_to_owner: 
**  -------------------------------------------------------------------
*/
message connect_fd_to_owner (
	IGRlong		*msg;		/* o - Return Status		*/
	struct	GRid	owner_grid;	/* i - owner to connect to	*/
	OM_S_CHANSELECT *owner_chan_sel;/* i - owner's channel select	*/
);

/*
**  -------------------------------------------------------------------
**  find_sym: 
**  -------------------------------------------------------------------
*/
message find_sym(
	long		*msg;		/* o - Return Status		*/
	long		gf_objid;	/* i - object id of graphic feat*/
	long		*sym_objid;	/* o - object id of symbol	*/
);	

/*
**  -------------------------------------------------------------------
**  init_associative_1d: 
**  -------------------------------------------------------------------
*/
message	init_associative_1d (
	long			*msg;		/* o - Return status		*/
	struct GRid		edge_grid;	/* i - Edge connected to	*/
);

/*
**  -------------------------------------------------------------------
**  setup_smb_args: This message sets up FD related symbol parameters
**		    and symbology
**  -------------------------------------------------------------------
*/
message setup_smb_args(
	long		*msg;		/* o - Return Status			*/
	char		*(*smb_args);	/* o - Info for symbol construction	*/
);

/*
**  -------------------------------------------------------------------
**  place_fd: This message constructs symbol, sends symbol's init message,
**	      connects domains to FD, connects FD to owner and connects
**	      to parents for associativity
**  -------------------------------------------------------------------
*/
message	place_fd(
	long		*msg;		/* o - return status		*/
	struct GRid	domain[];	/* i - features to connect to	*/
	long		num_domains;	/* i - number of domain		*/
	long		domain_type;	/* i - See FDdef.h		*/
	char		dimension;	/* i - Dimension of feature	*/
	char		gflag;		/* i - Geometry Based==0	*/
	OMuword		symbol_classid;	/* i - symbol to construct	*/
	char		supersede;	/* i - TRUE: override existing fd
					      FALSE: don't override
					        -1 : don't even check	*/
	struct GRid	exex_fd_grid[];/* i - NULL_OBJID : no fd	*/
					/*  not used if supersede == -1	*/
	struct GRid	owner_grid;	/* i - owner of fd ( structure) */
	OM_S_CHANSELECT	owner_cs;	/* i - channel to connect fd	*/
	struct GRid	*coordsys_grid;	/* i - Coord system : Optional	*/
					/*     Used if FEfd.info has	*/
					/*     FD_COORD_SYS_USED bit set*/
);

/*
**  -------------------------------------------------------------------
**  get_coord_sys: Gets cs.  NULL_OBJID if it does not exist
**  -------------------------------------------------------------------
*/
message get_coord_sys (
	struct GRid	 *cs_grid;	/* o - Coordinate system on FD	*/
	struct APcs_info *cs_info;	/* o - Coord system data	*/
);

/*
**  -------------------------------------------------------------------
**  FDxform : When the symbol gets a GRxform , this is sent to the FD
**  -------------------------------------------------------------------
*/
message FDxform (
	IGRlong 	*msg;		/* o - completion code		*/
	struct GRmd_env *md_env;	/* i - md_env structure 	*/
	IGRshort 	*matrix_type;	/* i - type of the matrix:MAtypemx() */ 
	IGRmatrix 	matrix;		/* i - transformation matrix	*/
);

/*
**  -------------------------------------------------------------------
**  FDcopy : When the symbol gets a GRcopy, this is sent to the FD
**  -------------------------------------------------------------------
*/
message FDcopy (
	IGRlong 	*msg;		/* o - completion code		*/
	struct GRmd_env *obj_dsenv;	/* i - present md_env structure */
	struct GRmd_env *new_dsenv;	/* i - copy's md_env structure */
);

/*
**  -------------------------------------------------------------------
**  FDcptform : When the symbol gets a GRcptform, this is sent to the FD
**  -------------------------------------------------------------------
*/
message FDcptform (
	IGRlong 	*msg;		/* o - completion code		*/
	struct GRmd_env *md_env;	/* i - present md_env structure */
	IGRmatrix 	matrix;		/* i - transformation matrix	*/
	struct GRmd_env *new_env;	/* i - copy's md_env structure 	*/
);

/*
**  -------------------------------------------------------------------
**  set_var_value:
**  -------------------------------------------------------------------
*/
message set_var_value(
	long		*msg;		/* o - Return Status		*/
	double		var_value;	/* i - value to be set		*/
	long		index;		/* i - var data array index	*/
);

/*
**  -------------------------------------------------------------------
**  get_var_value:
**  -------------------------------------------------------------------
*/
message get_var_value(
	long		*msg;		/* o - Return Status		*/
	double		*var_value;	/* o - value to be returned	*/
	long		index;		/* i - var data array index	*/
);

/*
**  --------------------------------------------------------------------
**  elem_refinement
**  --------------------------------------------------------------------
*/
message elem_refinement(
	long		*msg;		/* o - Return Status		*/
	struct GRid	orig_elgrid;	/* i - original elem grid	*/
	struct GRid	new_elgrids[];	/* i - grids of refined elems	*/
	long		num_newel;	/* i - num of refined elems	*/
);

/*
**  -------------------------------------------------------------------
**  inc_rsman_fd_count: This message increments the fd count in rsman,
**			when a new FD is created, when copying domain.
**  -------------------------------------------------------------------
*/
message inc_rsman_fd_count(
	long		*msg;		/* o - Return Status		*/
);

/*
**  -------------------------------------------------------------------
**  Overrides:
**  -------------------------------------------------------------------
*/
override delete,
	 GRnotifylis,
	 debug,
	 NDupdate,
	 NDparent_deleted,
	 NDconnect_graph,
	 NDcopy_graph;

/*
**  -------------------------------------------------------------------
**  Reject:
**  -------------------------------------------------------------------
*/
reject	init_defaults,
	setup_smb_args,
	inc_rsman_fd_count;

end specification FEfd;
