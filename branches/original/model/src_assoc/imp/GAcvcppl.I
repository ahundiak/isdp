/* ###################   APOGEE COMPILED   ################## */
class implementation GAcurve;

#include "EMS.h"
# include <stdio.h>
# include "OMmacros.h"
# include "emsdef.h"
# include "EMcp.h"
# include "godef.h"
# include "gocmacros.h"

extern OMuword  OPP_GRinfline_class_id,
                OPP_GRlinear_class_id,
                OPP_GRconic_class_id,
                OPP_GRbspline_class_id,
                OPP_GRcurve_class_id;


method GRcpparallel(IGRlong *msg; IGRshort *mx_type;
                    IGRmatrix matrix; struct GRmd_env *offset_env;
                    struct IGRline *direction_boreline; 
                    struct IGRline *distance_boreline; 
                    IGRdouble *distance; IGRboolean *apparent_flag;
                    IGRmatrix projection_matrix; GRobjid *objid)

/*
Description
            This file contains the GRcpparallel method for the associative
            model-space counterparts root class GAcurve.  It clears the
            GRIS_ASSOCIATIVE and GRHAS_EXTERNAL_CONSTRAINT bits of the
            copied object since it will not be an associative object.
            It also changes the copied object's class from an associative
            class to the corresponding non-associative class.

Arguments

	IGRlong *msg; 			return message
	IGRshort *mx_type, 		matrix type of original object
	IGRmatrix matrix; 		matrix for original object
	struct GRmd_env *offset_env;	environment for offset
	struct IGRline *direction_boreline; 
					boreline to indicate direction
					of offset
	struct IGRline *distance_boreline; 
					boreline to indicate distance 
					for offset ( send NULL pointer
					if sending distance)
	IGRdouble *distance; 		distance for offset (send NULL
					if sending distance_boreline)	
	IGRboolean *apparent_flag;	flag to indicate if the offset 
					is to be apparent
					 1 - do apparant offset
					 0 - offset in plane of element
     	IGRmatrix projection_matrix;   matrix to use for apparent offset
			NOTE: non-planar elements will always be an
			      apparent offset
	GRobjid *objid   	      	offset object's id

Algorithm

Return Values
                Upon exit the completion code will be one of 

                - MSSUCC if successful
                - MSFAIL(severe) if failure

History
                WBC    05/14/93 : Creation date.
*/
                
{
    OM_S_MESSAGE cpparallel_msg;
    IGRlong      OM_stat,
                 mthd_stat;
    GRclassid    classid;
    IGRshort     action,
                 props;
    IGRchar      classname[OM_K_MAXCLASS_LEN];

    *msg = MSSUCC;
    OM_stat = OM_S_SUCCESS;

    /* determine which GRcpparallel method should be invoked based on this
     * object's class, then make the corresponding message and send it;
     * this is being done this way because most of the MSC classes are
     * subclassed off of GAbspline, not GAlinear or GAconic, so overrides
     * could not be created at the desired classes; this approach only needs
     * one override instead of overriding at virtually every MSC class
     */

    OM_stat = om$get_classid(objid = my_id,
                             p_classid = &classid);
    EMerr_hndlr(!(1 & OM_stat), *msg, MSFAIL, wrapup);

    if (om$is_ancestry_valid(superclassid = OPP_GRinfline_class_id,
                             subclassid = classid) == (OM_S_SUCCESS))
        strcpy(classname, "GRinfline");
    else if (om$is_ancestry_valid(superclassid = OPP_GRlinear_class_id,
                             subclassid = classid) == (OM_S_SUCCESS))
        strcpy(classname, "GRlinear");
    else if (om$is_ancestry_valid(superclassid = OPP_GRconic_class_id,
                                  subclassid = classid) == (OM_S_SUCCESS))
        strcpy(classname, "GRconic");
    else if (om$is_ancestry_valid(superclassid = OPP_GRbspline_class_id,
                                  subclassid = classid) == (OM_S_SUCCESS))
        strcpy(classname, "GRbspline");
    else
        strcpy(classname, "GRcurve");

    OM_stat = om$make_message(classname = classname,
                              methodname = "GRcpparallel",
                              size = OPPmargs->size,
                              p_arglist = OPPmargs->p_arglist,
                              p_msg = &cpparallel_msg);
    EMerr_hndlr(!(1 & OM_stat), *msg, MSFAIL, wrapup);

    /*
     * send a message to myself to perform the copy parallel process
     */

    OM_stat = om$send(mode = OM_e_wrt_message,
                      msg = &cpparallel_msg,
                      targetid = my_id);
    EMerr_hndlr(!(1 & OM_stat & *msg),*msg, MSFAIL, wrapup);

    /*
     * send GRchgprops to the copied object to clear the associative and
     * externally constrained bits since the new object will not be associative
     */

    action = 0;
    props = GRIS_ASSOCIATIVE | GRHAS_EXTERNAL_CONSTRAINT;

    OM_stat = om$send(msg = message GRgraphics.GRchgprops(&mthd_stat,
                                                          &action, &props),
                      targetid = *objid,
                      targetos = offset_env->md_id.osnum);
    EMerr_hndlr(!(1 & OM_stat & *msg),*msg, MSFAIL, wrapup);

    /* change the class of the copied object to be the corresponding
     * non-associative class since the copy is not associative and making
     * it non-associative will result in a smaller object
     */

    OM_stat = om$get_classname(osnum = offset_env->md_id.osnum,
                               objid = *objid,
                               classname = classname);
    EMerr_hndlr(!(1 & OM_stat),*msg, MSFAIL, wrapup);

    classname[1] = 'R';  /* changing from GAxxxx to GRxxxx */

    OM_stat = om$change_class(osnum = offset_env->md_id.osnum,
                              objid = *objid,
                              classname = classname);
    EMerr_hndlr(!(1 & OM_stat),*msg, MSFAIL, wrapup);

wrapup:

     EMWRAPUP (*msg, OM_stat, "In GAcurve.GRcopy");
     return(OM_stat);
}

end implementation GAcurve;
