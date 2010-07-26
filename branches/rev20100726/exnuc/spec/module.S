class specification module (1:1) of Root;

#include <igrtypedef.h>
#include <OMerrordef.h>
#include <OMminimum.h>
#include <igetypedef.h>
#include <ex.h>

#ifndef NT
#include <exmacros.h>
#endif /* NT */

#ifdef SUNOS5
%undef sleep
#endif

typedef unsigned int uint;

channel chan_decl
{
   ( one_to_many, initial=1, increment=1)
};

instance module 
 {
  struct module_instance_data mod_data;
  channel chan_decl super;
  channel { (one_to_many,initial=1,increment=1) IGEwsys;  } windows;
  channel chan_decl extra;
  channel chan_decl primary;
  channel chan_decl cmdsvr;
  variable char version[8];
  variable char application[8];
 };

override delete;

message mod_init (int   mod_type;
              char  *cmdsvr;  
              int   numof_supers;
              char  *listof_supers;
	      int   vis_flag);


message wake_up (int   vis_flag);

message execute_mod (int      *response;
                     char     *response_data);

message sleep (int   temp_sleep);


message get_chan_cnt (OM_S_OBJID     owner_id;
                      char           *chan_name;
                      uint           *count);

message get_chan_obj (OM_S_OBJID      owner_id;
                      char            *chan_name;
                      OM_S_OBJECT_LINKAGE  *list;
                      uint            size;
                      uint            *count);

message GRmod_passon  (IGRlong          *msg;
                       OM_S_MESSAGE     *pass_msg;
                       IGRchar          *chan;
                       IGRint           *begin;
                       IGRint           *fin);

message GRmd_deactive(IGRint flag);
message GRmd_active();

/*   input super_name 
/*   output super_id 
*/
 message GRmd_add_super (IGRchar *super_name;
                       OM_S_OBJID *super_id; int wakeup_flag);


/*    mode = EX_INQ or EX_SET  in exdef.h */
message mod_info( int mode ; IGRchar *ver; int verlen;
                             IGRchar *app; int applen );


end specification module;
