#ifndef dsco_include
#define dsco_include

#include <ds.h>

struct default_data {
     IGRboolean          add_mod;
     IGRboolean          template;
     union {
          struct ds_standard  std;
          struct ds_sheet     sht;
     }data;
};

struct ret_data {
     IGRchar          * name;
     struct ds_sheet  * sheet;   
};

#endif
