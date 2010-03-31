class specification HScraform (1:0) of HSsaraform;



#include <FI.h>
#include "wl.h"
#include "igecolor.h"

#define RGB_XMAX 128
#define RGB_YMAX 128 


instance HScraform
{
	IGRboolean to_other_elements, to_original_element, to_active_parms;

	IGRint MsgNum;
	
	OM_S_OBJID	objid_orig;
	OMuword		osnum_orig;

	/* To which places to copy the current symbology parameters */
		
	/* Whether or not each of the corresponding sliders will be copied  */
	/* to the destination */
	IGRboolean DiffuseToggle, TransToggle, SpecToggle, FinishToggle;
	IGRboolean TextureToggle, ColorToggle;
	};


message write_msg ( long * sts );

message write_msg_fast ( long * sts );

message delete_highlight ( long * sts );

message get_active_sym ( long * sts );

message set_active_sym ( long * sts );

message get_element_sym ( long * sts );

message chain_locate ( long * sts );

message copy_to_element ( OM_S_OBJID elem_id; OMuword elem_os );

message process_elements ( long * sts );

override set_form_defaults;

override adjust_form_buttons;

override form_notification;

end specification HScraform;
