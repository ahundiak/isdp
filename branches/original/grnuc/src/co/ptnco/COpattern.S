class specification COpattern (1:0) of CEO_LOCATE;



#include "grsymdef.h"
#include "grsym.h"
#include "grptn.h"


instance COpattern
{
    IGRdouble                   range[6];   /* of master element */
    struct GRid                 ptn;        /* constructed object */
    struct GRevent              events[3];  /* input events */
    struct GRmd_env             const_env;  /* construct environment */
    struct GRactive_symbol_def  symbol;     /* symbol to pattern with */
};


message store_event (int f, t);

message get_symbol (int terminate_cmd);

message check_closure (int n);

message generate_pattern (int type);

message delete_pattern ();

end specification COpattern;
