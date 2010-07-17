// -----------------------------------------------------------------------------
//      Class    :      VLseaLine.S
//
//      Abstract :      Store Data corresponding to seam line;
//
//      History  :      Created 01-OCT-1992     Ludovic Le CORVEC
//                      Updated 11-APR-1994     Marc FOURNIER
// -----------------------------------------------------------------------------

class specification VLseaLine(0:0) of VLgenLine;

override NDcheck_cmpt_level;

/* ------- compute next seam with respect of witdh length along butt and
	virtual butt 							*/
message ACconstruct_feet10( IGRlong *msg; IGRint cn_type;
			 IGRint count; struct GRid list [];
			 struct GRmd_env *md_env;
			 int *fcount; struct GRid  *feet_list );


/* -------- compute next seam with respect of max plate ---------------	*/
message ACconstruct_feet11( IGRlong *msg; IGRint cn_type;
			 IGRint count; struct GRid list [];
			 struct GRmd_env *md_env;
			 int *fcount; struct GRid  *feet_list );

override VLgetLoftProps;

override VDgetObjDef;

end specification VLseaLine;

