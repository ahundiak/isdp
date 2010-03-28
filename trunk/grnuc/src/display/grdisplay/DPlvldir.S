




 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 


class specification DPlvldir (1:0) of global_class;
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"


instance DPlvldir
{
    IGRlong init_flag;
    variable IGRchar lvldir[];
    variable IGRchar back_up[];
};


message init_lvldir ();

message translate_number_to_name (IGRint *msg; 
			 IGRchar one_to_all_flag;
			 IGRshort level;
			 IGRchar **ptr_to_next;
 			 IGRshort *ret_nlev;
			 IGRlong *size_name;
			 IGRchar  *level_name);


message translate_name_to_number (IGRint *msg; 
			 IGRchar  *level_name;
			 IGRshort *nlevels;
			 IGRshort *level;
			 IGRlong *levels);


message convert_lev_string (IGRint *msg;
				 IGRchar *buffer;
				 IGRshort *nlevels;
				 IGRshort *level;
				 IGRlong *levels);

message translate_level_to_number (IGRint *msg;
				 IGRchar *buffer;
				 IGRshort *nlevels;
				 IGRshort *level);

message translate_level_to_mask (IGRint *msg;
				 IGRchar *buffer;
				 IGRlong *levels);


message add_name_to_lvldir (IGRint *msg;
				 IGRchar *buffer);

message get_lvl_def (IGRint *msg;
				 IGRchar **ptr_to_next;
				 IGRshort size_col1;
				 IGRchar *col1;
				 IGRshort size_col2;
				 IGRchar *col2);

message create_temp();
message verify(IGRint *msg; IGRint *line);

override  wake_up,super_construct,sleep,delete,place;

end specification DPlvldir;
