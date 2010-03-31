/* ###################   APOGEE COMPILED   ################## */
class specification EMSagrp (2:0) of EMSassoc,EMScreator,EMScomposite;

#include "REagrp.h"

/* ************************************************************************
Description
 This class provides implementation for common functionality with regards
 to support of associative objects which group entities.

History
 07/13/91 : PP  : Creation
 07/22/93 : WBC : Overrode GRdisyourself to create pointers for component
                  objects if the dpb flag indicates pointers are to be
                  created in order to enable read-only detailing.
   ************************************************************************ */

override EMconstruct_associative,
         GRlocate_owner,
         GRgetobjinfo,
         GRcopy,
         EMtranslate_id_key,
	 NDselect_copy,
         NDmake_source,
         EMget_parent_type,
         GRdisyourself;

end specification EMSagrp;
