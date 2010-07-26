class specification FIlstform (1:0) of COroot;

#include "OMminimum.h"
#include "DItypedef.h"
#include "DIdef.h"

#define EXIT_BUTTON            1
#define HELP_BUTTON           10
#define EVENT_BUTTON          16
#define COMMAND_FIELD         14
#define DISPLAY_FIELD         15

struct FormPackInfo
{
  int  count;
  char command [DI_PATH_MAX], **list;
};


instance FIlstform
{
  int                 ls;
  struct FormPackInfo info;
};


message set_gadgets ();
message form_find ( char *input; int pos );
message set_defaults ( char *data; char *back );

override init, execute;


end specification FIlstform;
