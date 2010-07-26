/* #######################    APOGEE COMPILED   ######################## */
class implementation GRbspline;

#include "grerr.h"


method EMcvradcrv (IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
                    struct GRvg_construct *const_args; IGRlong numpars;
		    struct GRparms *p1,*p2,*p3;
                    IGRdouble maxrad; 
                    IGRdouble *crvtr_val; IGRdouble *radii_val; 
                    IGRdouble *radii_poly; GRobjid *radii_obj;
		    IGRdouble *crv_poly; GRobjid *crv_obj)
{
 *msg = GRINVMSG;
 return(OM_E_ABORT);
}


method EMcvtanorm (IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
                   struct GRvg_construct *const_args; IGRlong numpars;
		   struct GRparms *p1,*p2,*p3;			
                   IGRdouble displen; IGRdouble *dirpt;
                   IGRboolean comp_tangent; IGRboolean comp_normal;
                   IGRdouble *outpoly; GRobjid *outobj)
{
 *msg = GRINVMSG;
 return(OM_E_ABORT);
}

method EMcvoffset (IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
        struct GRvg_construct *const_args; IGRdouble *offdist;
	IGRvector vector; IGRboolean right_side; IGRboolean uniform;
	IGRint *off_code; IGRboolean fillet, remove_loops;
        struct GRid *offcvid; IGRlong *num_loops; 
	struct IGRbsp_curve ***loops; IGRlong **loop_table)
{
 *msg = GRINVMSG;
 return(OM_E_ABORT);
}


method EMpartofcv (IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
                   struct GRvg_construct *const_args; 
		   struct GRparms *p1,*p2,*p3;	GRobjid *partcvid)
{
 *msg = GRINVMSG;
 return(OM_E_ABORT);
}

method EMbctobz ( struct GRvg_construct *construct_list;
		  GRobjid **bz_objid; IGRint *nbezier; IGRlong *msg )
{
 *msg = GRINVMSG;
 return(OM_E_ABORT);
}

method EMgetbcdef (IGRlong *msg; struct IGRbsp_curve *crv)
{
 *msg = GRINVMSG;
 return(OM_E_ABORT);
}

method EMptatpr (IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
                  IGRdouble point_parametric[]; IGRint num_parameters;
                  IGRpoint wpoint_xyz)
{
 *msg = GRINVMSG;
 return(OM_E_ABORT);
}

method EMintplane(struct GRvg_construct *construct_list;
                   struct IGRplane *plane;
                   struct GRlc_info *located_object;
                   int *number_of_intersections;
                   struct GRid **pointer_to_resulting_intersections;
                   int *msg)
{
 *msg = GRINVMSG;
 return(OM_E_ABORT);
}

method EMpratpt (IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
                  IGRpoint wpoint_xyz; IGRdouble point_parametric[]; 
                  IGRint *num_parameters)
{
 *msg = GRINVMSG;
 return(OM_E_ABORT);
}

method EMgetpoles (IGRlong *msg; IGRshort *mat_type; IGRmatrix mat;
                    IGRlong *frominx; IGRlong *offset; IGRdouble *buff;
                    IGRlong buff_size; IGRlong *ret_num; IGRboolean *is_reg)
{
 *msg = GRINVMSG;
 return(OM_E_ABORT);
}

method EMcrvcrvint( IGRlong		  *msg;
		    struct GRvg_construct *crv_cnst;
		    struct GRmdenv_info   *my_objenv;
		    struct IGRbsp_curve   *other_curve_in;
		    struct GRid		  *other_obj;
		    struct GRmdenv_info   *other_objenv;
		    IGRboolean		   end_inter_valid;

		    IGRlong		  *pnt_slots;
		    IGRlong		  *grand_num_pnt;
		    struct GRid		  **pnt_ids;
		    struct GRparms	  **my_pnt_inters;
		    struct GRparms	  **other_pnt_inters;
		    IGRdouble		  **inter_pnts_xyz;

		    IGRlong		  *crv_slots;
		    IGRlong		  *grand_num_crv;
		    struct GRid		  **crv_ids;
		    struct GRparms	  **my_crv_inters;
		    struct GRparms	  **other_crv_inters)


{
 *msg = GRINVMSG;
 return(OM_E_ABORT);
}


method EMcrvslfint(IGRlong *msg;
		    struct GRvg_construct *crv_cnst;
		    struct GRmdenv_info *my_objenv;

		    IGRlong		*pnt_slots;  
		    IGRlong 		*grand_num_pnt;
		    struct GRid 	**pnt_ids;
		    struct GRparms 	**my_pnt_inters;
		    IGRdouble      	**inter_pnts_xyz;

		    IGRlong		*crv_slots;
		    IGRlong 		*grand_num_crv;
		    struct GRid 	**crv_ids;
		    struct GRparms 	**my_crv_inters)

{
 *msg = GRINVMSG;
 return(OM_E_ABORT);
}

		
end implementation GRbspline;
