
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:41 $
$Locker:  $
*/

class specification HStex_table (1:0) of global_class;

#include "stdio.h"
#include "igrtypedef.h"
#include "hstex_table.h"

instance HStex_table
{
     variable   IGRchar                filenames[20];
     variable   struct offset_ref_ct   tex_file_index[8];
     IGRint                            last_offset;
     unsigned short                    last_index;


};


override super_construct,wake_up, sleep,debug;


message  add_texture_file(IGRchar *filename; IGRint active; unsigned short  *index);

message  add_tex_file(IGRchar *filename;  unsigned short  *index; unsigned short  actindex);


message add_ref_ct (unsigned short  index);

message retrieve_texture_file (unsigned short  index; IGRchar *filename);

message delete_texture_file (unsigned short   index);

message inquire_texture_file (IGRchar *filename; IGRint *status);


message review_texture_file (IGRchar *filename; IGRint *rec_ct; IGRint first_time);

message validate_index(unsigned short  index; IGRint *valid_index);
end specification HStex_table;
