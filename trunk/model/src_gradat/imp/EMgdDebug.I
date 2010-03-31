/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgradata;
/* HISTORY

    msm   03 Oct 1992        ANSI-C conversion

*/

#include "EMS.h"
# include <stdio.h>

# ifndef EMSfrtdef_include
# include "EMSfrtdef.h"
# endif

extern IGRchar  EMSrltBuffer[RLT_BUFFER_SIZE];

method debug()
{
  IGRint            i, j;
  IGRlong           sts, EMmsg;
  struct IGResqbs   *rlt;

  rlt = (struct IGResqbs *) EMSrltBuffer;

  fprintf(stderr, "\n\n\tFRT DEBUG\n\n");
  fprintf(stderr, "My props: %x\n", ME.EMShelper->props);
  sts = om$send(msg = message EMSgradata.EMgetRLT(&EMmsg, EMSrltBuffer,
                RLT_BUFFER_SIZE, &rlt), targetid = my_id);
  if(! (1 & EMmsg & sts)) goto wrapup;

  fprintf(stderr, "Number of rules -- u: %d\tv: %d\n",
          rlt->u_rules, rlt->v_rules);
  if(rlt->u_rules)
  {
    fprintf(stderr, "\nU rules:\n");
    for(i = 0; i < rlt->u_rules; i ++)
    {
      fprintf(stderr, "%lf\n", rlt->u_rule_values[i]);
      if(rlt->u_num_bound[i])
      {
        fprintf(stderr, "\t%d boundaries:\n", rlt->u_num_bound[i]);
        for(j = 0; j < rlt->u_num_bound[i] * 2; j ++)
        {
          fprintf(stderr, "\t%lf", rlt->u_bdrys[i][j ++]);
          fprintf(stderr, "\t%lf\n", rlt->u_bdrys[i][j]);
        }
      }
    }
  }

  if(rlt->v_rules)
  {
    fprintf(stderr, "\nU rules:\n");
    for(i = 0; i < rlt->v_rules; i ++)
    {
      fprintf(stderr, "%lf\n", rlt->v_rule_values[i]);
      if(rlt->v_num_bound[i])
      {
        fprintf(stderr, "\t%d boundaries:\n", rlt->v_num_bound[i]);
        for(j = 0; j < rlt->v_num_bound[i] * 2; j ++)
        {
          fprintf(stderr, "\t%lf", rlt->v_bdrys[i][j ++]);
          fprintf(stderr, "\t%lf\n", rlt->v_bdrys[i][j]);
        }
      }
    }
  }

wrapup:
  if(rlt != (struct IGResqbs *)EMSrltBuffer) om$dealloc(ptr = rlt);
  return(OM_S_SUCCESS);
}

end implementation EMSgradata;
