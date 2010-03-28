class implementation Root;


#include <stdio.h>
#include <time.h>

#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#define DEBUG

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"

main8 ()
{
  /* dummy test routine for this on */
  system ( "cp output/masterout output/newout" );
  
  return 1;
}



tst_index ( dirname, bad )
            DIchar *dirname					/* IN  */;
     	    DIint bad                                           /* IN  */;
/*
   This routine is supposed to test the index feature.
*/
/*.tst_index */
{
  DIint      i, status, count;
  DIobjid    dirid;
  DIspacenum osnum;
  DIchar     **lines;
  DIgrid     *grids;

  if (bad == 0)      /*   Good input from index.in   */
  {
    /*- */
    status = di$cd ( dirname = ":transient" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_index : di$cd is wrong", sts = status );

    for ( i=0; i<5; ++i )
    {
      status=di$mkdir(dirname = dirname, p_dirid = &dirid, p_osnum = &osnum  );
      if (status != DIR_S_SUCCESS)
        di$report_error(comment = "tst_index : di$mkdir is wrong", sts = status );

      status = di$ls ( lines = &lines, ptr = &count, options = OPT_ALL );
      if (status != DIR_S_SUCCESS)
        di$report_error ( comment = "tst_index : ls is wrong", sts = status );
      else
      {
        DIint  i;
        DIchar name [DI_PATH_MAX];

        for (i = 0; i < count; i++)
        {
          status = di$index ( index = i, name = name );
          if (status == DIR_S_SUCCESS)
          {
            DIchar basename [DI_PATH_MAX];
            DIint  index;

            di$split ( pathname = lines [i], name = basename );
            if (strcmp ( basename, name ))
              printf ( "index - ls problem : '%s' - '%s'\n", basename, name );

            status = di$unindex ( p_index = &index, name = name );
            if (status != DIR_S_SUCCESS)
              di$report_error ( sts = status, comment = "unindex problem" );
            else
              if (index != i)
                printf ( "unindex problem : %d - %d, '%s'\n", i, index, name );
          }
          else
            di$report_error ( sts = status, comment = "index problem" );
        }

        strcpy ( name, "not in there" );
        for (i = count; i < 2 * count; i++)
        {
          DIint index;

          status = di$index ( index = i, name = name );
          if (status != DIR_E_OVFLOW)
            di$report_error ( sts = status,
                              comment = "Index was supposed to fail" );
          status = di$unindex ( p_index = &index, name = name );
          if (status == DIR_S_SUCCESS)
            di$report_error ( sts = status, comment = "unindex supposed to fail" );
        }

        di$free ( lines = lines, count = count );
      }

      status = di$dump ( lines = &lines, grids = &grids, 
                         options = OPT_ALL, ptr = &count );
      if (status != DIR_S_SUCCESS)
        di$report_error(comment = "tst_dump : di$dump is wrong",sts=status);
      else
      {
        DIint      i;
        DIchar     name [DI_PATH_MAX];
        DIobjid    objid;
        DIspacenum osnum;

        for (i = 0; i < count; i++)
        {
          DIint index;

          status = di$index ( index   = i,
                              name    = name,
                              p_objid = &objid,
                              p_osnum = &osnum );
          if (status == DIR_S_SUCCESS)
          {
            DIchar basename [DI_PATH_MAX];

            di$split ( pathname = lines [i], name = basename );
            if ((objid != grids [i].objid) || (osnum != grids [i].osnum))
              printf ( "index - ls problem : (%d, %d) - (%d, %d)\n",
                       grids [i].osnum, grids [i].objid, osnum, objid );
            if (strcmp ( basename, name ))
              printf ( "index - ls problem : '%s' - '%s'\n", basename, name );
          }
          else
            di$report_error ( sts = status, comment = "index problem" );

          status = di$unindex ( p_index = &index, name = name );
          if (status != DIR_S_SUCCESS)
            di$report_error ( sts = status, comment = "unindex problem" );
          else
            if (index != i)
              printf ( "unindex problem : %d - %d, '%s'\n", i, index, name );

          status = di$unindex ( p_index = &index, objid = grids [i].objid );
          if (status != DIR_S_SUCCESS)
            di$report_error ( sts = status, comment = "unindex problem" );
          else
            if (index != i)
              printf ( "unindex problem : %d - %d, objid : %d, name : '%s'\n",
                       i, index, objid, name );
        }

        for (i = count; i < 2 * count; i++)
        {
          status = di$index ( index = i, name = name, p_objid = &objid,
                              p_osnum = &osnum );
          if (status != DIR_E_OVFLOW)
            di$report_error ( sts = status,
                              comment = "Index was supposed to fail" );
        }

        DIfree ( grids );
        di$free ( lines = lines, count = count );
      }

      status = di$cd ( dirname = "option1" );
      if (status != DIR_S_SUCCESS)
        di$report_error ( comment = "tst_index : di$cd is wrong", sts = status );
    }
  }

  else          /*  Bad input from index_bad.in   */
  {

  }

  return DIR_S_SUCCESS;
}

end implementation Root;
