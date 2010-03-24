#include <OMerrordef.h>
#include <OMminimum.h>
#include <OMmacros.h>
#include <OMprimitives.h>

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"

#define DEBUG
#include "DIomac.h"

#include <stdio.h>

/* ---------------------------------------------------------------------------*/


/* This macro is used to find the names that match the regular expression.
    If lines is specified (DIchar ***), it is filled out with the results.
   This macro is intended to be used by the directory sub-system only.

        o  deep returns the maximum layer number 
        o  max_level may be used to restrict the deep of the search (-1 means
           no restriction)

    return status :
                    DIR_S_SUCCESS : successful operation
                    DIR_E_OVFLOW  : overflow error
                    DIR_E_ABORT   : directory error

      Argument description :
      --------------------

        DIchar *regexp          : only the names that match this 	(IN)
				  regular expression are given.

        DIchar ***lines         : if specified, the entries are 	(OUT)
		                  listed in this array

        DIint *ptr              : the number of listed entry;		(OUT)

        DIint  max_level        : the maximum level of search 		(IN)
				  (< 0 means no limit)

        DIint  *deep            : the effective deep of the 		(OUT)
				  search (<= max_level)
*/

#omdef di$form_find ( regexp = "*",
                      lines = NULL,
                      ptr, 
                      max_level = -1,
                      deep = NULL )
       DIform_find ( (regexp), (lines), (ptr), (max_level), (deep) )
#endomdef

/* ---------------------------------------------------------------------------*/

/* This macro is used to fetch the good name in the list displayed by a form.

    return status :
                    DIR_S_SUCCESS : successful operation
                    DIR_E_OVFLOW  : overflow error
                    DIR_E_ABORT   : directory error

      Argument description :
      --------------------

        DIchar line [PATH_MAX]  : the full path name		 	(OUT)

        DIint  index            : the index of the name			(IN)
*/

#omdef di$fetch_form_find ( line, index )
       DIfetch_form_find ( (line), (index) )
#endomdef
/* ---------------------------------------------------------------------------*/


static DIint  form_find_done = 0;
static DIchar form_find_regexp [PATH_MAX];
static DIint  form_find_max_level;


DIform_find( regexp, lines, ptr, max_level, deep )
  	     DIchar *regexp	/* The regular expression		IN  */,
                    ***lines	/* The buffer to put the names in 	OUT */;
  	     DIint  *ptr	/* The number of lines			OUT */,
	            max_level	/* The maximum level of the find	IN  */,
                    *deep	/* The effective level of the find	OUT */;
/*
   This function calls di$find for the form of the directory sub-system.
*/
/*.DIform_find */
{
  DIint i, status;

  /*|set up static variables */
  form_find_done = 0;
  DIstrcpy ( form_find_regexp, regexp );
  form_find_max_level = max_level;

  /*|call find */
  status = di$find ( regexp = regexp, lines = lines, ptr = ptr,
                     options = OPT_TRAILER | OPT_LEVEL,
                     max_level = max_level, deep = deep );

  return status;
}


DIfetch_form_find( line, index )
  	           DIchar line [PATH_MAX]	/* The name		OUT */;
    	           DIint  index			/* The name index	IN  */;
/*
   This function returns a full path name corresponding to a selected entry
   in the form.
*/
/*.DIfetch_form_find */
{
  DIint  i, status;
  static DIchar **lines = 0;
  static DIint  count = 0;

  if (!form_find_done)
  {
    if (lines)
      di$free ( lines = lines, count = count );
    form_find_done = 1;
    status = di$find ( regexp = form_find_regexp, lines = &lines,
                       ptr = &count, max_level = form_find_max_level );
  }
  else
    status = DIR_S_SUCCESS;

  if (status == DIR_S_SUCCESS)
    status = DIstrcpy ( line, lines [index] );

  return status;
}


test_form ( regexp )
            DIchar *regexp;
{
  DIint  i, status, count;
  DIchar **lines, line [PATH_MAX];

  status = di$form_find ( lines = &lines, regexp = regexp, ptr = &count );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "di$form_find" );
  else
  {
    for (i = 0; i < count; i++)
    {
      status = di$fetch_form_find ( index = i, line = line );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "di$fetch_form_find" );
      else
        printf ( "%4d: '%s'	-	'%s'\n", i, lines [i], line );
    }

    di$free ( lines = lines, count = count );
  }

  return 1;
}


DIfwrite ( file_name, lines, grids, count )
	   DIchar *file_name	/* The file name			IN  */,
                  **lines	/* The lines to be dumped		IN  */;
	   DIgrid *grids	/* The grids to be dumped		IN  */;
	   DIint  count		/* The number of lines/grids		IN  */;
/*
   This function writes lines and grids to the file called file_name (lines
and/or grids may be NULL in order to turn their dump off)

   Return Code :	DIR_S_SUCCESS : Operation sucessfuly completed
			DIR_E_ABORT   : Cannot open file
*/
/*.DIfwrite */
{
  DIint i, status;
  FILE  *fet;

  fet = fopen ( file_name, "w" );
  if (fet)
  {
    for (i = 0; i < count; i++)
    {
      fprintf ( fet, "%4d: ", i );
      if (lines)
        fprintf ( fet, "'%s' ", lines [i] );
      if (grids)
        fprintf ( fet, "(%d, %d)", grids [i].osnum, grids [i].objid );
      fprintf ( fet, "\n" );
    }
    fclose ( fet );
  }
  else
    status = DIR_E_ABORT;

  return status;
}




DIffetch_find ( file_name, line_on, grid_on )
	        DIchar *file_name /* The file name			IN  */;
                DIint  line_on	  /* If not zero then print names	IN  */,
                       grid_on	  /* If not zero then print grids	IN  */;
/*
   This function writes the result of a find to the file called file_name.

   Return Code :	DIR_S_SUCCESS : Operation sucessfuly completed
			DIR_E_ABORT   : Cannot open file
*/
/*.DIffetch_find */
{
  DIint  i, status = DIR_S_SUCCESS, st;
  FILE   *fet;
  DIchar line [PATH_MAX];
  DIgrid grid;

  fet = fopen ( file_name, "w" );
  if (fet)
  {
    for (i = 0, status = DIR_S_SUCCESS; status == DIR_S_SUCCESS; i++)
    {
      status = di$fetch_find ( line = line, p_grid = &grid, index = i );
      if (status == DIR_S_SUCCESS)
      {
        fprintf ( fet, "%4d: ", i );
        if (line_on)
          fprintf ( fet, "'%s' ", line );
        if (grid_on)
          fprintf ( fet, "(%d, %d)", grid.osnum, grid.objid );
        fprintf ( fet, "\n" );
      }
    }
    fclose ( fet );
  }
  else
    status = DIR_E_ABORT;

  return status;
}
