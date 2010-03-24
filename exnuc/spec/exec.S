class specification exec (1:0) of Root;

#include <igrtypedef.h>
#include <exdef.h>
#include <ex.h>
#include <exmacros.h>

instance exec
{
  channel { (rel_ordered,many_to_many, initial=1,increment=1)} hw_win;
  channel { (rel_ordered,one_to_many,initial=1,increment=1) } to_kbd_processor;
  channel { (rel_ordered,one_to_many,initial=1,increment=1) } to_listener;
  channel { (rel_ordered,one_to_many,initial=1,increment=1) } to_generator;
};

message wake_up();

message passon(OM_p_MESSAGE pass_msg; IGRchar *chan; IGRint strt_index;
                IGRint end_index);

message wait_for_input( int *response; char *response_data; int mode; 
                int *num_bytes );

end specification exec;
