#include <stdio.h>

omdef  om$get_channel_count ( osnum=OM_Gw_current_OS,
                               objid=NULL_OBJID ^ object=(OM_p_OBJECTHDR)NULL,
                               p_chanselect,
                               count )

    som_get_channel_count(     (osnum), (objid), (object),
                               (p_chanselect), (count))
endomdef

                                       
int main(int argc, char *argv[])
{
  printf("Hello from test01\n");
  om$send(msg = 1);
}