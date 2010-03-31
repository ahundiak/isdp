/* ###################   APOGEE COMPILED   ################## */
class implementation GAcompcurve;

#include "EMS.h"
# include <stdio.h>
# include "OMmacros.h"
# include "emsdef.h"
# include "EMcp.h"
# include "godef.h"
# include "gocmacros.h"


method GRcpparallel(IGRlong *msg; IGRshort *mx_type;
                    IGRmatrix matrix; struct GRmd_env *offset_env;
                    struct IGRline *direction_boreline; 
                    struct IGRline *distance_boreline; 
                    IGRdouble *distance; IGRboolean *apparent_flag;
                    IGRmatrix projection_matrix; GRobjid *objid)

/*
Description
            This file contains the GRcpparallel method for the associative
            model-space counterparts root class GAcompcurve.  It clears the
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
    IGRlong     OM_stat,
                mthd_stat;
    IGRshort    action,
                props;
    IGRchar     classname[OM_K_MAXCLASS_LEN];

    *msg = MSSUCC;
    OM_stat = OM_S_SUCCESS;

    /*
     * send a message to myself to perform the copy parallel process
     */

    OM_stat = om$send(mode = OM_e_wrt_parent,
                      msg = message GAcompcurve.GRcpparallel(msg, mx_type,
                                                      matrix, offset_env,
                                                      direction_boreline,
                                                      distance_boreline,
                                                      distance, apparent_flag,
                                                      projection_matrix,
                                                      objid),
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

     EMWRAPUP (*msg, OM_stat, "In GAcompcurve.GRcopy");
     return(OM_stat);
}

end implementation GAcompcurve;
