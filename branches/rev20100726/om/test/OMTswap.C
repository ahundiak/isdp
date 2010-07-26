#include	"OMminimum.h"
#include	"OMprimitives.h"
#include	"OMerrordef.h"
#include	"OMparameters.h"
#include	<string.h>

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ error */
/* check status - exit if bad */
 error(str,sts)
 char *str;
 int sts;
 {
  if (1&sts)
    return;
  printf("!!!!!!!!!!!!! test failed in %s\n",str);
  om$report_error(sts=sts);
  exit(0);
 }

main()
{
int		sts, i;
 static char *OMparams[] = {"GETSTATISTICS=1",NULL};

if(!(1&(sts = om$runtime_init(paramc=1,param_list=OMparams) )))
  {
    error("Error from runtime_init",sts);
  }

/*=======================================================*/
/* call maini to gain advantages of opp for rest of test */
/*=======================================================*/
maini();

#ifdef	DEBUG
	printf("end of test\n");
#endif

exit();
};
