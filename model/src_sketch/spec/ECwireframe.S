/*

Name
    ECwireframe

Abstract
    (required)
  
Synopsis
    (required)

Description
    (required)

Return Values
    (required if not void)

Notes

Index

Keywords
  class specification wireframe place profile composite

History 
    01/07/93 : Shelley R. Heard : created

 */

class specification ECwireframe (1:0) of COnpt;
instance ECwireframe
{
  IGRint prev_ref_lock_state;
};


override convert_to_profile, 
         show_assoc_mode, 
         wakeup_form,
         construct_polygon,
	 delete;

end specification ECwireframe;

