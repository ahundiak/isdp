/******************************************************************************

Class: COdpb

Description:    

    This class provides methods for setting and fetching dpb attributes 
    from a command's state table. It also provides methods for  extracting
    and changing non geometric attributes in graphic objects on a channel.

    There are several methods for allocating stacks of temporary dpb
    structures. This provides a way of storing the "state" of dpb attributes
    without changing the global dpb object. Currently only the copy symbology
    and copy text parameter commmands use this capability. In the future
    all change attribute commands should subclass from COdpb and use the
    extract and change methods. 

    Another use is to provide a mechanism for storing sets of dpb attributes.
    Currently a class called COlvsym of COdpb and global_class is being 
    developed which will allow active symbology to be changed based on the
    current level.

    The COdpb supports the setting and fetching of the following attributes:

        1. color                10. text font          
        2. weight               11. fraction font
        3. style                12. ascii font
        4. level                13. symbol font
        5. angle                14. text justification
        6. x-scale              15. text height
	7. y-scale              16. text width
	8. z-scale              17. text character spacing
        9. text size            18. text line spacing

Abstract class: In Most Instances (huh huh)

Messages:   active
	    alloc 
            dealloc
            get_dpb
            put_dpb
            get
            put
            extract
            change

History:    jay wallingford     04/10/89    creation date
						  
Bugs:       There are no known bugs.

Notes:

******************************************************************************/

class specification COdpb (1:0) of Root;

#include <coimport.h>
#include <stdio.h>
#include <ctype.h>
#include <OMprimitives.h>
#include <OMminimum.h>
#include <OMmacros.h>
#include <OMerrordef.h>
#include <igetypedef.h>
#include <igrtypedef.h>
#include <igrdef.h>
#include <igrdp.h>
#include <exdef.h>
#include <ex.h>
#include <exmacros.h>
#include <ODE.h>
#include <godef.h>
#include <go.h>
#include <gr.h>
#include <griodef.h>
#include <grio.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>
#include <dp.h>
#include <dpdef.h>
#include <dpmacros.h>
#include <wl.h>
#include <igecolor.h>
#include <igecolmacros.h>
#include <griomacros.h>
#include <bsvalues.h>
#include <msdef.h>
#include <msmacros.h>
#include <grmessage.h>
#include <fontdef.h>
#include <growner.h>
#include <grgsdef.h>
#include <grgsmacros.h>
#include <COerr.h>
#include "dpbco.h"

instance COdpb
{
    IGRshort                    Active;
    variable struct COdpb_attr  Attr[];
};

/*
 * active :   Sets the active attribute structure by index into the 
 *            variable length attribute structure. 
 */
message active ( IGRint * msg;
                 IGRint index );

/*
 * alloc :    Allocates an attributes struct. The index into the attribute
 *            structure will be returned. The allocated structure will be 
 *            seeded by the current dpb parameters. The active index will
 *            NOT be set to this new structure. Use the active message to
 *            set the active dpb structure.
 */
message alloc ( IGRint * msg;
                IGRint * index );

/*
 * dealloc :  Deallocates the attribute structure at the specified index. 
 *            If an attribute structure was active and it's index was greater
 *            than the deleted structure's index the active index will be 
 *            adjusted. If the deleted structure was active the active index
 *            will be set to -1 (no active structure).
 */
message dealloc ( IGRint * msg;
                  IGRint index );

/* 
 * get_dpb : Gets specified attributes from the dpb and assigns them
 *           to either the COdpb_attr structure specified or to the
 *           COdpb object's instance data if it is allocated and active.
 *                
 */
message get_dpb ( IGRint * msg;
                  IGRuint mask;
                  struct COdpb_attr * attr_p );

/* 
 * put_dpb : Sets the specified dpb attributes according to either the 
 *           attributes in the specified COdpb_attr structure or 
 *           the COdpb object's instance data.
 */
message put_dpb ( IGRint * msg;
                  IGRuint mask;
                  struct COdpb_attr * attr_p );

/* 
 * put : Puts the specified attribute data to either this object's 
 *       instance data (if it has been allocated and is active) or to 
 *       the dpb. A check will be performed for a valid value for the 
 *       specified attribute.
 *
 * NOTE: One of the following value pointers should be passed
 *       in with the type set as specified :
 *   
 *             struct GRdisplay *            type = CO_disp_struct
 *             struct GRdpb_scale *          type = CO_scale_struct
 *             struct GRdpb_text_symb *      type = CO_text_struct
 *             char *                        type = CO_string
 *             int *                         type = CO_integer
 *             double *                      type = CO_double
 *             (attributes default type) *   type = CO_default
 */
message put ( IGRint * msg; 
              IGRuint mask;
              IGRchar * value;
              IGRint type); 

/*
 * get :  Returns the value of the specified attribute. This value reflects
 *        the dpb if a attribute struct has not been allocated.
 *
 * NOTE: One of the following value pointers should be passed
 *       in with the type set as specified :
 *   
 *             struct GRdisplay *            type = CO_disp_struct
 *             struct GRdpb_scale *          type = CO_scale_struct
 *             struct GRdpb_text_symb *      type = CO_text_struct
 *             char *                        type = CO_string
 *             int *                         type = CO_integer
 *             double *                      type = CO_double
 *             (attributes default type) *   type = CO_default
 */
message get ( IGRint * msg;
              IGRuint mask;
              IGRchar * value;
              IGRint type );
/* 
 * extract : Extracts attributes from the first object on the 
 *           specified chanselect and sets the COdpb 
 *           instance data if it has been allocated otherwise the
 *           the dpb will be set.
 *                
 */
message extract ( IGRint * msg; 
                  IGRuint mask;
                  OM_S_CHANSELECT * chansel);

/* 
 * change :  Changes graphic objects' attributes from the specified 
 *           COdpb instance data if it has been allocated, otherwise
 *           the dpb will be used. 
 *                
 */
message change ( IGRint * msg;
                 IGRuint mask;
                 OM_S_CHANSELECT * chansel);

end specification COdpb;
