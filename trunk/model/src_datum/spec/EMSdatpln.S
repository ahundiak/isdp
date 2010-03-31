/*
Name
  EMSdatpln

Abstract
 This class serves to provide message protocol/common
 functionality for datum/construction planes in EMS. 
Description

Notes

History
 07/04/91:PP:Creation.
 02/18/93:Carlos:Override NDcompute_node.
 02/13/95:Sudha:Override GRanalyze_element
*/
class specification EMSdatpln (2:0) of NDnodein,dim_plan,GRowner;

#include "msdef.h"
#include "asbox.h" /* For globals for channel selectors */
#include "EMSdatumdef.h"
#include "EMdtmacros.h"

instance EMSdatpln
{
 unsigned char props; /* As the name says, properties */
 double x_dir[3]; /* Xdirection of the datum plane */
 double y_dir[3]; /* Ydirection of the datum plane */
 double origin[3];/* Origin of the datum plane */
};

message EMget_pln_info (IGRlong *EMmsg;
                        unsigned int options;
                        struct GRmd_env *env;
                        double *xdir;
                        double *ydir;
                        double *zdir;
                        double *origin;
                        unsigned int *props);
/* *******************************************************************
Description
 This message gets the datum plane information stored.

Arguments
 EMmsg : completion message
 options : Ubiquitous options field. Currently not supported.
 env : Module environment
 xdir : if non-null xdirection of the datum plane is returned
 ydir : if non-null ydirection of the datum plane is returned
 zdir : if non-null zdirection of the datum plane is returned
 origin : if non-null origin of the datum plane is returned
 props : if non-null properties of the datum plane are returned.

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC : If all goes well.
 MSFAIL : If there is some form of failure
************************************************************************ */
override
/*
 * Return the origin and normal 
 */
         GRdetplane;

#ifndef BASE_EMS

message EMput_pln_info (IGRlong *EMmsg;
                        unsigned int options;
                        struct GRmd_env *env;
                        double xdir[3];
                        double ydir[3];
                        double zdir[3];
                        double origin[3];
                        unsigned int props);

/* ***********************************************************************
Description
 This message serves to be the counterpart to EMget_pln_info.

Arguments
 EMmsg : completion code
 options : Ubiquitous options field.
           EMS_OPT_SET_EXTERNAL_CONSTRAINT : Sets graphics properties to be
           GR_EXTERN_CONSTRAINED | GRIS_ASSOCIATIVE.
 env : Module environment
 xdir : xdirection of the datum plane
 ydir : ydirection
 zdir : zdirection
 origin : origin
 props : properties. Can currently be set to NULL

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC: If all goes well
 MSFAIL : If there is some form of failure

************************************************************************ */

message EMcreate_resize_handle (IGRlong *EMmsg;
                                unsigned int options;
                                struct GRmd_env *md_env;
                                struct GRvg_construct *construct_list;
                                IGRdouble x_size;
                                IGRdouble y_size;
                                GRobjid *handle_id);

/* *******************************************************************
Description
 This message can be used to create/resize the graphic handle of the
datum plane object.

Arguments
 EMmsg : Completion code
 options : Ubiquitous options field
           EMS_OPT_DISPLAY_HANDLE : Causes the handle to be displayable
 construct_list : construction information
 md_env : Module environment
 x_size : Size of the plane in x direction
 y_size : size of the plane in y direction
 handle_id : The graphic handle id that is constructed is optionally
             returned.

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC : If all goes well
 MSFAIL : If there is some form of failure

********************************************************************** */

message EMtoggle_on_off(IGRlong *EMmsg;
                        unsigned int options);

/* ********************************************************************
Description
 This message turns the properties of the datum plane either to be
 displayed or not or just toggled based on the options coming in.

Arguments
 EMmsg: Completion code
 options : EMS_OPT_ON : Turns the datum on.
           EMS_OPT_OFF : Turns the datum off.
           EMS_OPT_TOGGLE : Toggles the datum properties.

Related files:
 EMSdatumdef.h

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC : If successful.
 MSFAIL : If there is some form of failure.
************************************************************************ */

override GRgetobjinfo, 
/*
 * To not allow the location of the geometric handle for commands which
 * do not have any business locating them.
 */
         GRlocate_owner,

/*
 * Returns the type to be ref_generic and returns the matrix corresponding
 * to the plane.
 */

         NDgive_structure, 
/*
 * Returns itself.
 */
	 ASreturn_go,
/*
 * Xforms itself if the same is not externally constrained.
 */
         GRxform,
/*
 * Non-associatively copies itself.
 */
         GRcopy,
/*
 * Deletes itself and removes the entry from the datum plane
 * manager object.
 */
	 GRdelete,
/*
 * Performs a graph copy for macro creation/placement purposes.
 * If the element is an extern, then it essentialy copies itself
 * non-associatively. If the element is a body, then it returns
 * invalid arguments since the support for the same does not exist
 * yet.
 */
         NDcopy_graph,
/*
 * Returns dimension plane matrix.
 */
         give_plane,
/*
 * Override to create pretends etc
 */
         NDmake_source,
/*
 * Return my non-associative copy.
 */
         ACcopy_to_Groot,
/*
 * To further safeguard the integrity of the reference plane
 * sub-system.
 */
         delete,

/*
 * Display the datum plane
 */
         NDdisplay,
/*
 * Project the point onto the infinite definition of the ref. plane
 */
	GRptproject,
/*
 * Do nothing, return success.
 */
	 NDcompute_node;

override	GRanalyze_element;

#endif
end specification EMSdatpln;
