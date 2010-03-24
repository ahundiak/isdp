#include  <stdio.h>
#include  "OMobjectcomm.h"

extern	char	*optarg;
char            quota[32], priority[32];
char            *initArgs[2] = {quota, priority};

OMuint		OM_Gi_number_of_defns = 0;
OM_p_FUNCPTR	OM_GA_class_definitions[] = {0};

main(argc,argv)
int     argc;
char    *argv[];

{
  int           sts, ii;
  char          option;
  int           gotquota =        0;
  int           gotprio =         0;
  
  strcpy (quota, "CCCPQUOTA_DESIRE=");
  strcpy (priority, "CCCPQUOTA_PRIORITY=");
  
  while (EOF != (option = getopt (argc,argv,"q:p:")))
  {
    switch (option)
    {
    case 'q':
      strcat (quota, optarg);
      gotquota = 1;
      break;
    case 'p':
      strcat (priority, optarg);
      gotprio = 1;
      break;
    case '?':
    default:
      printf ("usage: -q <quota> -p <priority>\n");
      exit ();
    }
  }

  if (!gotquota) strcat (quota, "614400");
  if (!gotprio) strcat (priority, "4");
  printf ("Initializing with %s & %s\n", quota, priority);
  sts = om$runtime_init(paramc = 2, param_list = initArgs);
  if (!(sts&1))
  {
    printf (" error in om$runtime_init : %x \n", sts );
    om$report_error(sts = sts);
    exit();
  }
  while (1)
  {
    printf ("[well?] ");
    scanf ("%s", quota);
    if (!(strcmp (quota,"q"))) exit ();
  }
}


