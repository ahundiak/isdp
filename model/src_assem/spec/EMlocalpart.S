/*
 * Class :
 *
 *      EMlocalpart
 *
 * Abstract :
 *
 *      This class defines a part which represents either the file defined
 *      as a part or a subdivision of that file into parts. A local part
 *      is defined graphically by a set of layers. One local part may be
 *      nested within another local part but the layers which are available
 *      to each level in the nesting is restricted to the layers that the
 *      parent part has. At least one layer must be assigned to each part.
 *      
 *      Since the graphics that this class describes are defined by the 
 *      layers that are in the part, The notify stuff doesn't make sense
 *      so the EMget_notify, EMadd_notify and EMrem_notify are rejected. 
 *
 *      This class of parts can have one of two possible EMdescribe types
 *      set in it's properties word, EM_FILE_PART is reserved to the top 
 *      level part in the hierarchy while EM_LOCAL_PART is used for the 
 *      rest.
 *
 * History :
 *
 *      Jay Wallingford     6/19/93  Creation date.
 *      Gang                7/4/94   Override EMupdate_display.
 *
 */
class specification EMlocalpart (1:1) of EMpart;

#include <assemdef.h>
#include <assem.h>
#include <assempriv.h>

instance EMlocalpart
{
    IGRint   active_layer;     /* Last active layer. */
    IGRint   active_display;   /* Element display when active. */
    IGRlong  layers[32];       /* Assigned layers. */
    IGRlong  active_on[32];    /* Layers display when active. */
    IGRlong  nonactive_on[32]; /* Layers display when nonactive */
};

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMget_layers                                                     |
 |                                                                           |
 | This method returns the layers that are assigned to this part as well as  |
 | the layers that will be turned on when this part is active and the layers |
 | that are turned on when this part is deactivated. The returned buffers    |
 | are 128 byte bit masks representing all 1024 layers.                      |
 |                                                                           |
 | Output:  IGRlong         * msg           Return code.                     |
 |          IGRlong         * layers        Layer buffer, 32 IGRlongs.       |
 |          IGRlong         * active_on     Layer buffer, 32 IGRlongs.       |
 |          IGRlong         * nonactive_on  Layer buffer, 32 IGRlongs.       |
 |                                                                           |
 | Return:  ASM_S_SUCCESS   Constructed sucessfully.                         |
 |          ASM_E_ABORT     Catostrophic error.                              |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMget_layers (IGRlong * msg;
                      IGRlong * layers;
                      IGRlong * active_on;
                      IGRlong * nonactive_on);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMset_layers                                                     |
 |                                                                           |
 | This method sets the layers that are assigned to this part as well as     |
 | setting the layers that will be turned on when this part is active and the|
 | layers that are turned on when this part is deactivated. The returned     |
 | buffers are 128 byte bit masks representing all 1024 layers.              |
 |                                                                           |
 | Input:   IGRlong         * msg           Return code.                     |
 |          IGRlong         * layers        Layers.                          |
 |          IGRlong         * active_on     Layer buffer, 32 IGRlongs.       |
 |          IGRlong         * nonactive_on  Layer buffer, 32 IGRlongs.       |
 |                                                                           |
 | Return:  ASM_S_SUCCESS   Constructed sucessfully.                         |
 |          ASM_E_ABORT     Catostrophic error.                              |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMset_layers (IGRlong * msg;
                      IGRlong * layers;
                      IGRlong * active_on;
                      IGRlong * nonactive_on);


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMget_active_layer                                               |
 |                                                                           |
 | This method returns the active layer for this part.                       |
 |                                                                           |
 | Output:  IGRlong         * msg          Return code.                      |
 |          IGRint          * active_layer Active layer.                     |
 |                                                                           |
 | Return:  ASM_S_SUCCESS   Constructed sucessfully.                         |
 |          ASM_E_ABORT     Catostrophic error.                              |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMget_active_layer (IGRlong * msg;
                            IGRint  * active_layer);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMset_active_layer                                               |
 |                                                                           |
 | This method returns sets the active layer for this part.                  |
 |                                                                           |
 | Output:  IGRlong         * msg        Return code.                        |
 |          IGRint            layer      Active layer.                       |
 |                                                                           |
 | Return:  ASM_S_SUCCESS   Constructed sucessfully.                         |
 |          ASM_E_ABORT     Catostrophic error.                              |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMset_active_layer (IGRlong * msg;
                            IGRint    active_layer);


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMget_active_local_part                                          |
 |                                                                           |
 | This method returns the active local part.                                |
 |                                                                           |
 | Output:  IGRlong         * msg          Return code.                      |
 |          struct GRid     * part_id      Active part.                      |
 |                                                                           |
 | Return:  ASM_S_SUCCESS   Constructed sucessfully.                         |
 |          ASM_E_ABORT     Catostrophic error.                              |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMget_active_local_part (IGRlong     * msg;
                                 struct GRid * active_part);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Private Message: EMuse_layers                                             |
 |                                                                           |
 | This method is sent by a local part to the file part when it is created or|
 | when it's layer assignment is changed using the EMset_layers message. The |
 | file part will make sure that the specified layers are a valid subset of  |
 | the file part and will take them out of it's list of available layers and |
 | displayed layers.                                                         |
 |                                                                           |
 | Input:   IGRlong * layers         Layer array, 32 IGRlong.                |
 |                                                                           |
 | Output:  IGRlong * msg            Return code.                            |
 |          IGRlong * active_on      Active on layers for set.               |
 |          IGRlong * nonactive_on   Nonactive on layers for set.            |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Constructed sucessfully.                     |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMuse_layers (IGRlong * msg;
                      IGRlong * layers;
                      IGRlong * active_on;
                      IGRlong * nonactive_on);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Private Message: EMreuse_layers                                           |
 |                                                                           |
 | This method is sent by a local part to the file part when it is deleted   |
 | or when it's layer assignment is changed using the EMset_layers message.  |
 | The file part will add these assigned and displayed layers to it's list   |
 | of available layers.                                                      |
 |                                                                           |
 | Input:   IGRlong * layers       Layer array, 32 IGRlong.                  |
 |          IGRlong * active_on    Active on layers.                         |
 |          IGRlong * nonactive_on NonActive on layers.                      |
 |                                                                           |
 | Output:  IGRlong * msg          Return code.                              |
 |                                                                           |
 | Return:  ASM_S_SUCCESS   Constructed sucessfully.                         |
 |          ASM_E_ABORT     Catostrophic error.                              |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMreuse_layers (IGRlong * msg;
                        IGRlong * layers;
                        IGRlong * active_on;
                        IGRlong * nonactive_on);

/*
 * Root overrides.
 */
override debug;         /* Print out layer info. */

/*
 * Listener Rejections
 */
reject   GRnotifylis;

/*
 * Describe Overrides/Rejections
 */
override EMconstruct,
         EMdelete,
         EMget_display,
         EMset_display,
         EMset_active,
         EMget_active,
         EMpass,
         EMget_props,
         EMmod_attr,
         EMupdate,
	 EMupdate_display;

reject   EMadd_notify,
         EMget_notify,
         EMrem_notify;

end specification EMlocalpart;



