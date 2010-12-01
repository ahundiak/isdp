#include <stdio.h>
#include <igrtypedef.h>
#include <ma2ptdis.h>

#include "version.h"
#include "OMminimum.h"
#include "OMspecify.h"

#if 0
int test1()
{
  IGRlong  sts;
  IGRpoint pt1,pt2;
  IGRdouble distance;

  pt1[0] = 1.0; pt1[1] = 1.0; pt1[2] = 1.0;
  pt2[0] = 2.0; pt2[1] = 2.0; pt2[2] = 2.0;
  sts = 1;
  distance = 0.0;

  MA2ptdis(&sts,pt1,pt2,&distance);

  printf("Distance: %.2f\n",distance);

  return 1;
}
#endif
/* ===============================================
 * Some pdu stubs
 */
int pull_main() {}
int PALlist_notify_routine() {}
int PALgetassocpos() {}
int PALasfmwinevent;
int PALasfmbntevent;

extern INGR_S_PRODUCT_DEF PDU_appl_version_id;
extern OM_p_FUNCPTR       Pdu_class_definitions[];
extern OM_p_FUNCPTR       OM_GA_class_definitions[];

int main(int argc, char *argv[])
{
  int i;

  printf("Hello from main %s %s\n",argv[0],PDU_appl_version_id.curr_version);

  for(i = 0; i < 2; i++)
  {
    OM_p_CREATECLASS_ARGS cca = (OM_p_CREATECLASS_ARGS)
                                   OM_GA_class_definitions[i]();

    printf("Class %4d %-20s %4d %4d\n",i,cca->s_name,cca->InstanceSize,cca->NewInstanceSize);
    
  }

  for(i = 0; Pdu_class_definitions[i]; i++)
  {
    OM_p_CREATECLASS_ARGS cca = (OM_p_CREATECLASS_ARGS)
                                   Pdu_class_definitions[i]();

    printf("Class %4d %-20s %4d %4d\n",i,cca->s_name,cca->InstanceSize,cca->NewInstanceSize);

  }
  printf("PDU Class Defn Count: %d\n",i);
}