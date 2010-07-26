#include <exdef.h>
#include <exproto.h>
#include <FI.h>
#include <msmacros.h>

extern int EX_batch_mode;



UI_error(msg)
char *msg;
{

   if (EX_batch_mode != EX_INTERACT)     return(1);

   EX_error_box(FI_CURRENT_SCREEN, msg,"ERROR BOX");   

   return(1);
}










