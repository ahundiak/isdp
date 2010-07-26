class implementation Root;

#include <stdio.h>
#include <time.h>

#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#define AS_DEBUG

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"

#define NB_CASE 10

from DIbstob import retrieve_index;


vlock ()
{
  printf ( "vlock\n" );
}

vunlock ()
{
  printf ( "vunlock\n" );
}

vfork()
{
  printf ( "vfork\n" );
}


#include "stdio.h"


entry ()
/*.entry */
{
  FILE    *fet;
  char    lines [150] [20];
  DIint   i, j, nb_lines, sts;
  DIobjid dirid, objid;
  
  extern long clock ();
  
  sts = om$construct ( classname = "DIstorage", p_objid = &objid );
  if (sts != OM_S_SUCCESS)
    om$report_error ( sts = sts );

  printf ( "clock : %lf\n", clock () * 0.000001 );
  for (i = 0; i < 10000; i++)
  {
    sts = di$add_index (  objid = objid );
    if (sts != DIR_S_SUCCESS)
      di$report_error ( sts = sts, comment = "add_index" );
  }
  printf ( "clock : %lf\n", clock () * 0.000001 );

return 1;

  fet = fopen ( "list", "r" );
  if (fet)
  {
    DIint   sts;

    di$mkdir ( dirname = ":transient:test" );
    di$cd ( dirname = ":transient:test", p_dirid = &dirid );

    i = 0;
    while (read_line ( fet, lines [i] ))
    {
      sts = om$construct ( classname = "DIstorage", p_objid = &objid );
      if (sts != OM_S_SUCCESS)
        om$report_error ( sts = sts );

      if (i < 5) printf ( "%s - %d\n", lines [i], objid );
      
      sts = di$add_name ( objname = lines [i], objid = objid );
      if (sts != DIR_S_SUCCESS)
        di$report_error ( sts = sts, comment = "add_name" );
      i++;
    }
    
    fclose ( fet );

    nb_lines = i;
    {
      long b, e, l_tm, tm;

      printf ( "clock : %lf\n", clock () * 0.000001 );
      b = clock ();

      for (j = 0; j < 50; j++)
        for (i = 0; i < nb_lines; i++)
          ;

      e = clock ();
      printf ( "clock : %lf\n", clock () * 0.000001 );
      l_tm = e - b;
      printf ( "time: %lf\n", l_tm * 0.000001 );

      b = clock ();
      for (j = 0; j < 50; j++)
        for (i = 0; i < nb_lines; i++)
        {
          om$send ( msg = message DIbstob.retrieve_index ( &sts, i, NULL, &objid ),
                    senderid = NULL_OBJID,
                    targetid = dirid );
        }
      e = clock ();
      tm = e - b - l_tm;
      printf ( "average time : %lf\n", tm * 0.000001 / (50 * nb_lines) );
    }
  }
  else
    fprintf ( stderr, "CANNOT open list\n" );

  return 1;
}


end implementation Root;
