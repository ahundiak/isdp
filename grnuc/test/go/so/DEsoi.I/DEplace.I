class implementation DEso;
#include <stdio.h>
#include <memory.h>
#include <limits.h>
#include <sys/types.h>
#include <alloca.h>
#include "msdef.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include <tools.h>
#include "DEso.h"
#include "DEglob.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "madef.h"

#include "DEsomacros.h"

#define MIN_X -1300.0
#define MIN_Y -1000.0

#define MAX_X 1300.0
#define MAX_Y 1000.0

from GRcontext import GRgetmodule_env;

main ()
/*
   Call all the test routines for symbology override.
*/
{
  FILE *fet;
  int  master = 0;
  
  /* test in the module */
  DEtst_place ( 200 );
  DEtst_linestr ( 200 );
  DEtst_arc ( 200 );
  DEtst_modify ();
  DEtst_retrieve ( 200 );
  
  /* as a final test, we dump the SO table into masterout/newout */
  if (fet = fopen ( "output/masterout", "r" ))
  {
    fclose ( fet );
    fet = fopen ( "output/newout", "w" );
  }
  else
  {
    fet = fopen ( "output/masterout", "w" );
    master = 1;
  }
  
  if (!fet)
    fprintf ( stderr, "CANNOT open masterout/newout\n" );
  else
  {
    struct GRid soo;
    int         i, osnum, count;
    DEsoe       *soes;
    
    for (osnum = 2; osnum < (int)OM_Gw_maxOS; osnum++)
    {
      DEget_soo ( &soo.objid, &soo.osnum, osnum );

      om$send ( msg = message DEso.DEdump ( &count, &soes, 1 ),
                senderid = NULL_OBJID, 
                targetos = soo.osnum,
                targetid = soo.objid );
      for (i = 0; i < count; i++)
        if (soes [i].type != DE_DELETED && soes [i].type != DE_EMPTY)
          fprintf ( fet, "%d - %d - %d - %lf - %lf - %d - %d - %d\n",
                    soes [i].type, soes [i].view, soes [i].context,
                    soes [i].u1, soes [i].u2, soes [i].osymb.color, 
                    soes [i].osymb.style, soes [i].osymb.weight );
        else
          fprintf ( fet, "%d\n", soes [i].type );
    }

    fclose ( fet );
  }

  return OM_S_SUCCESS;
}


DEtst_place ( max )
              int max	/* number of objects to add		IN */;
/*
   This function tests the placement of SO in the master file.
*/
{
  int               i, status, count, *types;
  double            *parms;
  long              msg;
  char              window_name [DI_PATH_MAX];
  GRspacenum        osnum;
  GRobjid           soo, *objids, md_id, objid;
  struct GRid       window, *grids, old_grid, new_grid;
  struct IGRdisplay symb, *symbs;
  struct GRmd_env   md_env;
    
  _DEinit ();
  objids = (GRobjid *)alloca ( sizeof ( GRobjid ) * max );
  ex$get_cur_mod ( id = &md_id, osnum = &osnum );
  /* let's find the window */
  DIstmocpy ( window_name, "views", "regviews", "GRviews", "*", 0, osnum );
  status = di$dump ( regexp = window_name, grids = (DIgrid **)&grids, 
                     options = 0, ptr = &count );
  if (!(status & 1))
    di$report_error ( sts = status, 
                      comment = "cannot dump windows" );
  window = grids [0];

  /* let's create the soo for that space */
  de$create_soo ( msg = &status, osnum = osnum, p_objid = &soo );
  if (!(status & 1))
  {
    fprintf ( stderr, "%s at %d: error in soo construction\n", __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }  

  /* let's add max objects */
  md_env.md_id.osnum = osnum;
  md_env.md_id.objid = md_id;
  md_env.md_env.matrix_type = MAIDMX;
  for (i = 0; i < max; i++)
  {
    DEplace_line ( &msg, &objids [i], &window,
                   MIN_X + i * (MAX_X - MIN_X) / max, MIN_Y, 0.0,
                   MIN_X + (i + 1) * (MAX_X - MIN_X) / max, MAX_Y, 0.0,
                   &md_env );
    if (!(status & 1))
    {
      fprintf ( stderr, "%s at %d: error in GRlineseg construction\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  

    symb.color = i % 5;
    symb.style = i % 10;
    symb.weight = i % 10;
    status = om$send ( msg = message DEso.DEadd 
                             ( &msg, i % 2 ? DE_SOE | DE_HIDDEN : DE_SOE, 
                               objids [i], 0.1 + (0.6 / max) * i, 
                               0.4 + (0.6 / max) * i, &symb, &window, 
                               NULL_INDEX, &md_env, NULL_INDEX ),
                       targetid = soo,
                       targetos = osnum,
                       senderid = NULL_OBJID );
    if (!(status & 1))
    {
      fprintf ( stderr, "%s at %d: error in soo add\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  
  }

  /* get the manual/automatic soo's */
  for (i = 0; i < max; i++)
  {
    int type = i % 2 ? DE_SOE | DE_HIDDEN : DE_SOE;
    
    symb.color = i % 5;
    symb.style = i % 10;
    symb.weight = i % 10;
    status = om$send ( msg = message DEso.DEget ( &msg, &types, &parms, &count,
                                                  &symbs, &symb, objids [i],
                                                  window.objid, 
                                                  &md_env.md_env.matrix_type,
                                                  md_env.md_env.matrix, 0, 0 ),
                       targetid = soo,
                       targetos = osnum,
                       senderid = NULL_OBJID );
    if (!(status & 1))
    {
      fprintf ( stderr, "%s at %d: error in soo get\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  

    if (count != 1)
      fprintf ( stderr, "%s at %d: error in count\n", __FILE__, __LINE__ );
    if (types [0] != type)
      fprintf ( stderr, "%s at %d: error in type\n", __FILE__, __LINE__ );
    if (!(type & DE_HIDDEN))
      if (symbs [0].color != symb.color ||
          symbs [0].style != symb.style ||
          symbs [0].weight != symb.weight)
        fprintf ( stderr, "%s at %d: error in symbology\n", __FILE__, __LINE__ );
  }

  /* get the manual soo's */
  for (i = 0; i < max; i++)
  {
    int type = i % 2 ? DE_SOE | DE_HIDDEN : DE_SOE;
    
    symb.color = i % 5;
    symb.style = i % 10;
    symb.weight = i % 10;
    status = om$send ( msg = message DEso.DEget ( &msg, &types, &parms, &count,
                                                  &symbs, &symb, objids [i],
                                                  window.objid, 
                                                  &md_env.md_env.matrix_type,
                                                  md_env.md_env.matrix, 2, 0 ),
                       targetid = soo,
                       targetos = osnum,
                       senderid = NULL_OBJID );
    if (!(status & 1))
    {
      fprintf ( stderr, "%s at %d: error in soo get (manual)\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  

    if (count != 1)
      fprintf ( stderr, "%s at %d: error in count (manual)\n", __FILE__, __LINE__ );
    if (types [0] != type)
      fprintf ( stderr, "%s at %d: error in type (manual)\n", __FILE__, __LINE__ );
    if (!(type & DE_HIDDEN))
      if (symbs [0].color != symb.color ||
          symbs [0].style != symb.style ||
          symbs [0].weight != symb.weight)
        fprintf ( stderr, "%s at %d: error in symbology (manual)\n", __FILE__, __LINE__ );
  }

  /* replace the first one */  
  DEplace_line ( &msg, &objid, &window, MIN_X, MIN_Y, 0.0, 
                 MIN_X + (MAX_X - MIN_X) / max, MAX_Y, 0.0, &md_env );
  if (!(status & 1))
  {
    fprintf ( stderr, "%s at %d: error in GRlineseg construction\n", __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }  

  old_grid.osnum = osnum;
  old_grid.objid = objids [0];
  new_grid.osnum = osnum;
  new_grid.objid = objid;
  status = de$objid_changed ( msg = &msg, old = &old_grid, new = &new_grid );
  if (!(status & 1))
  {
    fprintf ( stderr, "%s at %d: error in soo change\n", __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }
  
  /* replace the objid */
  objids [0] = objid;

  /* add multiple overrides */
  for (i = 1; i < max / 8; i++)
  {
    struct GRid grid;
    
    grid.osnum = osnum;
    grid.objid = objids [i];
    
    symb.color = 2;
    symb.style = 0;
    symb.weight = 0;
    status = de$place_override ( msg = &msg,
                                 symbology = &symb,
                                 u1 = 0.2 - i / max,
                                 u2 = 0.6 + i / max,
                                 go_grid = &grid,
                                 window_grid = &window,
                                 module = &md_env );
    if (!(status & 1))
    {
      fprintf ( stderr, "%s at %d: error in soo add\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  
  }

  /* add multiple overrides */
  for (i = max / 2; i < 7 * max / 8; i++)
  {
    struct GRid grid;
    
    grid.osnum = osnum;
    grid.objid = objids [i];
    
    symb.color = 0;
    symb.style = 0;
    symb.weight = 10.0;
    status = de$place_override ( msg = &msg,
                                 symbology = &symb,
                                 u1 = 0.4 - i / max,
                                 u2 = 0.6 + i / max,
                                 go_grid = &grid,
                                 window_grid = &window,
                                 module = &md_env );
    if (!(status & 1))
    {
      fprintf ( stderr, "%s at %d: error in soo add\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  
  }

  /* let's remove of few of the ones we put */
  for (i = 0; i < max; i += 2)
  {
    if (i < 7 * max / 8)
    {
      status = de$delete_by_objid ( msg = &msg, osnum = osnum, objid = objids [i] );
      if (!(status & 1))
      {
        fprintf ( stderr, "%s at %d: error in soo remove_by_objid\n", 
                 __FILE__, __LINE__ );
        om$report_error ( sts = status );
      }  
      if (msg != MSSUCC)
        fprintf ( stderr, "%s at %d: error in soo remove_by_objid\n", 
                 __FILE__, __LINE__ );
    }
    else
    {
      struct GRid grid;
      
      grid.osnum = osnum;
      grid.objid = objids [i];
      symb.color = i % 5;
      symb.style = i % 10;
      symb.weight = i % 10;
    
      status = de$delete_override ( msg = &msg, 
                                    go_grid = &grid,
                                    u1 = 0.1 + (0.6 / max) * i, 
                                    u2 = 0.4 + (0.6 / max) * i,
                                    symbology = &symb,
                                    window_grid = &window, 
                                    module = &md_env  );
      if (!(status & 1))
      {
        fprintf ( stderr, "%s at %d: error in soo remove\n", 
                 __FILE__, __LINE__ );
        om$report_error ( sts = status );
      }  
      if (msg != MSSUCC)
        fprintf ( stderr, "%s at %d: error in soo remove\n", 
                 __FILE__, __LINE__ );
    }
  }
  
  status = om$send ( msg = message DEso.DEremove_by_objid ( &msg, objids [0] ),
                     targetid = soo,
                     targetos = osnum,
                     senderid = NULL_OBJID );
  if (!(status & 1))
  {
    fprintf ( stderr, "%s at %d: error in soo remove_by_objid\n", 
             __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }
  else
    if (msg == MSSUCC)
      fprintf ( stderr, "%s at %d: remove_by_objid was supposed to fail\n", 
               __FILE__, __LINE__ );

  status = om$send ( msg = message DEso.DEremove 
                           ( &msg, 1 % 2 ? DE_SOE | DE_HIDDEN : DE_SOE, 
                             objids [1], 0.0, 0.0, &symb, &window, &md_env  ),
                     targetid = soo,
                     targetos = osnum,
                     senderid = NULL_OBJID );
  if (!(status & 1))
  {
    fprintf ( stderr, "%s at %d: error in soo remove\n", 
             __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }
  else
    if (msg == MSSUCC)
      fprintf ( stderr, "%s at %d: remove was supposed to fail\n", 
               __FILE__, __LINE__ );

  status = om$send ( msg = message DEso.DEremove 
                           ( &msg, 0 % 2 ? DE_SOE | DE_HIDDEN : DE_SOE, 
                             objids [0], 0.5, 1.0 / (max - 1), 
                             &symb, &window, &md_env  ),
                     targetid = soo,
                     targetos = osnum,
                     senderid = NULL_OBJID );
  if (!(status & 1))
  {
    fprintf ( stderr, "%s at %d: error in soo remove\n", 
             __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }
  else
    if (msg == MSSUCC)
      fprintf ( stderr, "%s at %d: remove was supposed to fail\n", 
               __FILE__, __LINE__ );

  /* delete the window
  status = om$send ( msg = message Root.delete ( 1 ),
                     senderid = NULL_OBJID,
                     targetid = window.objid,
                     targetos = window.osnum );
  */
  
  return OM_S_SUCCESS;
}


DEtst_linestr ( max )
                int max	/* number of objects to add		IN */;
/*
   This function tests the placement of SO in the soo.
*/
{
  int               i, j, status, count;
  long              msg;
  char              window_name [DI_PATH_MAX];
  GRspacenum        osnum;
  GRobjid           soo, objid, mod_id;
  struct GRid       window, *grids;
  struct GRid       grid;
  double            *points;
  struct IGRdisplay symb;
  struct GRmd_env   md_env;
    

  _DEinit ();
  points = (double *)alloca ( sizeof ( double ) * max * 6 );
  ex$get_cur_mod ( id = &mod_id, osnum = &osnum );
  /* let's find the window */
  DIstmocpy ( window_name, "views", "regviews", "GRviews", "*", 0, osnum );
  status = di$dump ( regexp = window_name, grids = (DIgrid **)&grids, 
                     options = 0, ptr = &count );
  if (!(status & 1))
    di$report_error ( sts = status, 
                      comment = "cannot dump windows" );
  window = grids [0];

  /* let's create the soo for that space */
  de$create_soo ( msg = &status, osnum = osnum, p_objid = &soo );
  if (!(status & 1))
  {
    fprintf ( stderr, "%s at %d: error in soo construction\n", __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }  

  /* let's add max objects */
  md_env.md_id.osnum = osnum;
  md_env.md_id.objid = mod_id;
  md_env.md_env.matrix_type = MAIDMX;
  for (i = 0, j = 0; i < max; j += 6, i++)
  {
    points [j] = MIN_X + i * (MAX_X - MIN_X) / max;
    points [j + 1] = MIN_Y;
    points [j + 2] = 0.0;
    points [j + 3] = MIN_X + (i + 1) * (MAX_X - MIN_X) / max;
    points [j + 4] = MAX_Y;
    points [j + 5] = 0.0;
  }
  
  DEplace_line_str ( &msg, &objid, &window, max, points, &md_env );
  if (!(status & 1))
  {
    fprintf ( stderr, "%s at %d: error in GRlineseg construction\n", __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }  

  symb.color = 2;
  symb.style = 0;
  symb.weight = 0;
  grid.osnum = osnum;
  grid.objid = objid;
  for (i = 0; i < max; i += 2)
  {
    status = de$place_override ( msg = &msg,
                                 symbology = &symb,
                                 u1 = 0.2 + i * 0.7 / max, 
                                 u2 = 0.8 + i * 0.15 / max,
                                 go_grid = &grid,
                                 window_grid = &window,
                                 module = &md_env );
    if (!(status & 1))
    {
      fprintf ( stderr, "%s at %d: error in soo add\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  
  }
  
  /* add multiple overrides */
  symb.color = 2;
  symb.style = 0;
  symb.weight = 10;

  for (i = 1; i < max / 4; i++)
  {
    status = de$place_override ( msg = &msg,
                                 symbology = &symb,
                                 u1 = 0.4 - i / max,
                                 u2 = 0.6 + i / max,
                                 go_grid = &grid,
                                 window_grid = &window,
                                 module = &md_env );
    if (!(status & 1))
    {
      fprintf ( stderr, "%s at %d: error in soo add\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  
  }

  /* add multiple overrides */
  symb.color = 3;
  status = de$place_override ( msg = &msg,
                               symbology = &symb,
                               u1 = 0.1,
                               u2 = 0.2,
                               go_grid = &grid,
                               window_grid = &window,
                               module = &md_env );
  if (!(status & 1))
  {
    fprintf ( stderr, "%s at %d: error in soo add\n", __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }  

  symb.color = 3;
  status = de$place_override ( msg = &msg,
                               symbology = &symb,
                               u1 = 0.8,
                               u2 = 1.0,
                               go_grid = &grid,
                               window_grid = &window,
                               module = &md_env );
  if (!(status & 1))
  {
    fprintf ( stderr, "%s at %d: error in soo add\n", __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }  

  status = om$send ( msg = message DEso.DEremove_by_objid ( &msg, -1 ),
                     targetid = soo,
                     targetos = osnum,
                     senderid = NULL_OBJID );
  if (!(status & 1))
  {
    fprintf ( stderr, "%s at %d: error in soo remove_by_objid\n", 
             __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }
  else
    if (msg == MSSUCC)
      fprintf ( stderr, "%s at %d: remove_by_objid was supposed to fail\n", 
               __FILE__, __LINE__ );

  status = om$send ( msg = message DEso.DEremove ( &msg, DE_SOE, objid, 
                                                    0.0, 0.0, &symb, &window, 
                                                    &md_env ),
                     targetid = soo,
                     targetos = osnum,
                     senderid = NULL_OBJID );
  if (!(status & 1))
  {
    fprintf ( stderr, "%s at %d: error in soo remove\n", 
             __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }
  else
    if (msg == MSSUCC)
      fprintf ( stderr, "%s at %d: remove was supposed to fail\n", 
               __FILE__, __LINE__ );

  status = om$send ( msg = message DEso.DEremove ( &msg, DE_SOE, objid, 
                                                    0.5, 1.0 / (max - 1), 
                                                    &symb, &window, &md_env  ),
                     targetid = soo,
                     targetos = osnum,
                     senderid = NULL_OBJID );
  if (!(status & 1))
  {
    fprintf ( stderr, "%s at %d: error in soo remove\n", 
             __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }
  else
    if (msg == MSSUCC)
      fprintf ( stderr, "%s at %d: remove was supposed to fail\n", 
               __FILE__, __LINE__ );

  return OM_S_SUCCESS;
}


DEtst_modify ()
/*
   This function tests the modify capability by changing the weight
   of all existing overrides.
*/
{
  GRobjid           soo, md_id;
  DEsoe             *buffer, *tmp;
  int               i, j, count, status;
  long              msg;
  uword             osnum;
  struct GRmd_env   md_env;
  struct IGRdisplay symb;
  
  _DEinit ();
  ex$get_cur_mod ( id = &md_id, osnum = &osnum );
  de$create_soo ( msg = &status, osnum = osnum, p_objid = &soo );
  if (!(status & 1))
  {
    fprintf ( stderr, "%s at %d: error in soo construction\n", __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }  

  /* get all the soo entries */
  status = om$send ( msg = message DEso.DEdump ( &count, &tmp, 0 ),
                     senderid = NULL_OBJID,
                     targetid = soo,
                     targetos = osnum );
  
  /* move temp memory into secure area */
  buffer = (DEsoe *)alloca ( count * sizeof ( DEsoe ) );
  memcpy ( buffer, tmp, count * sizeof ( DEsoe ) );
           
  /* modify each soo entry */
  md_env.md_id.osnum = osnum;
  md_env.md_id.objid = md_id;
  md_env.md_env.matrix_type = MAIDMX;
  for (i = 0; i < count; i++)
  {
    struct                 GRid window;
    extern OM_S_CHANSELECT DEso_to_windows_chanselect;
    
    /* increase the weight */
    symb = buffer [i].osymb;
    symb.weight++;
    om$get_objid_at_index ( objid = soo,
                            osnum = osnum,
                            p_chanselect = &DEso_to_windows_chanselect,
                            index = buffer [i].view,
                            objidaddr = &window.objid,
                            osnumaddr = &window.osnum );
    
    status = om$send ( msg = message DEso.DEmodify ( &msg, buffer [i].type,
                                               &buffer [i].osymb, 
                                               buffer [i].u1, 
                                               buffer [i].u2, 
                                               &window, 
                                               &md_env, 
                                               buffer [i].type, 
                                               &symb,
                                               buffer [i].u1,
                                               buffer [i].u2,
                                               buffer [i].objid,
                                               &window, 
                                               &md_env,
                                               1 ),
                       targetid = soo,
                       targetos = osnum,
                       senderid = NULL_OBJID );
    if (!(status & 1))
    {
      fprintf ( stderr, "%s at %d: DEmodify problem (%d)\n", __FILE__, __LINE__, i );
      om$report_error ( sts = status );
    }

    if (msg != MSSUCC)
      fprintf ( stderr, "%s at %d: DEmodify problem (%d)\n", __FILE__, __LINE__, i );      
  }
  
  /* get all the soo entries */
  status = om$send ( msg = message DEso.DEdump ( &count, &tmp, 0 ),
                     senderid = NULL_OBJID,
                     targetid = soo,
                     targetos = osnum );
  if (!(status & 1))
    fprintf ( stderr, "%s at %d: dump problem\n", __FILE__, __LINE__ );
  
  /* make sure that's what it is supposed to */
  if (i != count)
    fprintf ( stderr, "%s at %d: bad count (%d-%d)\n", __FILE__, __LINE__, i, count );
      
  for (i = 0; i < count; i++)
  {
    for (j = 0; j < count; j++)
      if (buffer [i].type == tmp [j].type &&
          buffer [i].view == tmp [j].view &&
          buffer [i].osymb.color != tmp [j].osymb.color &&
          buffer [i].osymb.weight != tmp [j].osymb.weight &&
          buffer [i].osymb.style != tmp [j].osymb.style &&
          buffer [i].u1 == tmp [j].u1 &&
          buffer [i].u2 == tmp [j].u2)
        continue;
      else
        break;
    if (j == count)
      fprintf ( stderr, "%s at %d: entry is missing\n", __FILE__, __LINE__ );
  }
  
  return OM_S_SUCCESS;
}


DEtst_arc ( max )
            int max	/* number of objects to add		IN */;
/*
   This function tests the placement of SO in the soo.
*/
{
  int               i, status, count;
  long              msg;
  char              window_name [DI_PATH_MAX];
  GRspacenum        osnum;
  GRobjid           soo, *arcs, md_id;
  struct GRid       window, *grids;
  struct IGRdisplay symb;
  struct GRmd_env   md_env;
    
  _DEinit ();
  arcs = (GRobjid *)alloca ( sizeof ( GRobjid ) * max );
  ex$get_cur_mod ( id = &md_id, osnum = &osnum );
  /* let's find the window */
  DIstmocpy ( window_name, "views", "regviews", "GRviews", "*", 0, osnum );
  status = di$dump ( regexp = window_name, grids = (DIgrid **)&grids, 
                     options = 0, ptr = &count );
  if (!(status & 1))
    di$report_error ( sts = status, 
                      comment = "cannot dump windows" );
  window = grids [0];

  /* let's create the soo for that space */
  de$create_soo ( msg = &status, osnum = osnum, p_objid = &soo );
  if (!(status & 1))
  {
    fprintf ( stderr, "%s at %d: error in soo construction\n", __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }  

  /* let's add max objects */
  md_env.md_id.osnum = osnum;
  md_env.md_id.objid = md_id;
  md_env.md_env.matrix_type = MAIDMX;
  for (i = 0; i < max; i++)
  {
    struct GRid grid;
    
    DEplace_arc ( &msg, &arcs [i], &window, 0.0, 6.27, 300.0 + i * 20.0, 
                  0.0, 0.0, 0.0, &md_env );
    grid.osnum = osnum;
    grid.objid = arcs [i];
    
    symb.color = 2;
    symb.style = 0;
    symb.weight = 4;

    status = de$place_override ( msg = &msg,
                                 symbology = &symb,
                                 u1 = 0.25,
                                 u2 = 0.75,
                                 go_grid = &grid,
                                 window_grid = &window,
                                 module = &md_env );
    if (!(status & 1))
    {
      fprintf ( stderr, "%s at %d: error in soo add\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  
  }

  for (i = 0; i < max; i++)
  {
    struct GRid grid;
    
    grid.osnum = osnum;
    grid.objid = arcs [i];
    
    symb.color = 2;
    symb.style = 0;
    symb.weight = 8;

    status = de$place_override ( msg = &msg,
                                 symbology = &symb,
                                 u1 = 0.4,
                                 u2 = 0.6,
                                 go_grid = &grid,
                                 window_grid = &window,
                                 module = &md_env );
    if (!(status & 1))
    {
      fprintf ( stderr, "%s at %d: error in soo add\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  
    status = de$place_override ( msg = &msg,
                                 symbology = &symb,
                                 u1 = 0.0,
                                 u2 = 0.1,
                                 go_grid = &grid,
                                 window_grid = &window,
                                 module = &md_env );
    if (!(status & 1))
    {
      fprintf ( stderr, "%s at %d: error in soo add\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  
    status = de$place_override ( msg = &msg,
                                 symbology = &symb,
                                 u1 = 0.9,
                                 u2 = 1.0,
                                 go_grid = &grid,
                                 window_grid = &window,
                                 module = &md_env );
    if (!(status & 1))
    {
      fprintf ( stderr, "%s at %d: error in soo add\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  
  }
  
  return OM_S_SUCCESS;
}


DEtst_retrieve ( max )
                 int max	/* number of objects to add		IN */;
/*
   This function tests the retrieval of symbology overrides.
*/
{
  int               i, status, count;
  long              msg;
  char              window_name [DI_PATH_MAX];
  GRspacenum        osnum;
  GRobjid           soo, *arcs, md_id;
  struct GRid       window, *grids;
  struct IGRdisplay symb;
  struct GRmd_env   md_env;
    
  _DEinit ();
  arcs = (GRobjid *)alloca ( sizeof ( GRobjid ) * max );
  ex$get_cur_mod ( id = &md_id, osnum = &osnum );
  /* let's find the window */
  DIstmocpy ( window_name, "views", "regviews", "GRviews", "*", 0, osnum );
  status = di$dump ( regexp = window_name, grids = (DIgrid **)&grids, options = 0, ptr = &count );
  if (!(status & 1))
    di$report_error ( sts = status, 
                      comment = "cannot dump windows" );
  window = grids [0];

  /* let's create the soo for that space */
  de$create_soo ( msg = &status, osnum = osnum, p_objid = &soo );
  if (!(status & 1))
  {
    fprintf ( stderr, "%s at %d: error in soo construction\n", __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }  

  /* let's add max objects */
  md_env.md_id.osnum = osnum;
  md_env.md_id.objid = md_id;
  md_env.md_env.matrix_type = MAIDMX;
  for (i = 0; i < max; i++)
  {
    struct GRid grid;
    
    DEplace_arc ( &msg, &arcs [i], &window, 0.0, 6.27, 300.0 + i * 20.0, 
                  300.0, 0.0, 0.0, &md_env );
    grid.osnum = osnum;
    grid.objid = arcs [i];
    
    symb.color = 2;
    symb.style = 0;
    symb.weight = 4;

    status = de$place_override ( msg = &msg,
                                 symbology = &symb,
                                 u1 = 0.25,
                                 u2 = 0.75,
                                 go_grid = &grid,
                                 window_grid = &window,
                                 module = &md_env );
    if (!(status & 1))
    {
      fprintf ( stderr, "%s at %d: error in soo add\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  
  }

  /* let's make sure we can retrieve them */
  for (i = 0; i < max; i++)
  {
    struct GRid grid;
    int         type;
    double      u1, u2;

    grid.osnum = osnum;
    grid.objid = arcs [i];
    status = de$retrieve_override ( msg = &msg,
                                    p_type = &type,
                                    p_u1 = &u1,
                                    p_u2 = &u2,
                                    go_grid = &grid,
                                    window_grid = &window,
                                    module = &md_env,
                                    u = 0.5 );
    if (!(status & 1))
    {
      fprintf ( stderr, "%s at %d: error in soo retrieve\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }
    if (msg != MSSUCC)
      fprintf ( stderr, "%s at %d: bad msg in soo retrieve\n", __FILE__, __LINE__ );
    if (u1 > 0.5 || u2 < 0.5 || type != DE_SOE)
      fprintf ( stderr, "%s at %d: inconsistency in soo retrieve\n", __FILE__, __LINE__ );

    status = de$delete_by_objid ( msg = &msg, osnum = osnum, objid = arcs [i] );
    if (!(status & 1))
    {
      fprintf ( stderr, "%s at %d: error in soo remove_by_objid\n", 
               __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  
    if (msg != MSSUCC)
      fprintf ( stderr, "%s at %d: error in soo remove_by_objid\n", 
               __FILE__, __LINE__ );

    status = de$retrieve_override ( msg = &msg,
                                    p_type = &type,
                                    p_u1 = &u1,
                                    p_u2 = &u2,
                                    go_grid = &grid,
                                    window_grid = &window,
                                    module = &md_env,
                                    u = 0.5 );
    if (msg == MSSUCC)
    {
      fprintf ( stderr, "%s at %d: soo retrieve should have failed\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }
  }
  
  /* let's try a few total overrides */
  for (i = 0; i < max; i++)
  {
    struct GRid grid;
    
    grid.osnum = osnum;
    grid.objid = arcs [i];
    symb.color = 2;
    symb.style = 0;
    symb.weight = 4;

    status = de$place_override ( msg = &msg,
                                 symbology = &symb,
                                 type = DE_SOE | DE_OVERLAP,
                                 u1 = 0.75,
                                 u2 = 1.0,
                                 go_grid = &grid,
                                 window_grid = &window,
                                 module = &md_env );
    if (!(status & 1))
    {
      fprintf ( stderr, "%s at %d: error in soo add\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  

    status = de$place_override ( msg = &msg,
                                 symbology = &symb,
                                 type = DE_SOE | DE_OVERLAP,
                                 u1 = 0.0,
                                 u2 = 0.25,
                                 go_grid = &grid,
                                 window_grid = &window,
                                 module = &md_env );
    if (!(status & 1))
    {
      fprintf ( stderr, "%s at %d: error in soo add\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  
  }

  /* let's make sure we can retrieve them */
  for (i = 0; i < max; i++)
  {
    struct GRid grid;
    int         type;
    double      u1, u2;

    grid.osnum = osnum;
    grid.objid = arcs [i];
    status = de$retrieve_override ( msg = &msg,
                                    p_type = &type,
                                    p_u1 = &u1,
                                    p_u2 = &u2,
                                    go_grid = &grid,
                                    window_grid = &window,
                                    module = &md_env,
                                    u = i % 2 ? 0.0 : 1.0 );
    if (!(status & 1))
    {
      fprintf ( stderr, "%s at %d: error in soo retrieve\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }
    if (msg != MSSUCC)
      fprintf ( stderr, "%s at %d: bad msg in soo retrieve\n", __FILE__, __LINE__ );
    if (i % 2)
    {
      if (u1 != 0.0 || u2 != 0.25 || type != (DE_SOE | DE_OVERLAP))
        fprintf ( stderr, "%s at %d: inconsistency in soo retrieve\n", __FILE__, __LINE__ );
    }
    else
      if (u1 != 0.75 || u2 != 1.0 || type != (DE_SOE | DE_OVERLAP))
        fprintf ( stderr, "%s at %d: inconsistency in soo retrieve\n", __FILE__, __LINE__ );

    status = de$next_override ( msg = &msg,
                                p_type = &type,
                                p_u1 = &u1,
                                p_u2 = &u2 );
    if (!(status & 1))
    {
      fprintf ( stderr, "%s at %d: error in soo next\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }
    if (msg != MSSUCC)
      fprintf ( stderr, "%s at %d: bad msg in soo next\n", __FILE__, __LINE__ );
    if (i % 2)
    {
      if (u1 != 0.75 || u2 != 1.0 || type != (DE_SOE | DE_OVERLAP))
        fprintf ( stderr, "%s at %d: inconsistency in soo retrieve\n", __FILE__, __LINE__ );
    }
    else
      if (u1 != 0.0 || u2 != 0.25 || type != (DE_SOE | DE_OVERLAP))
        fprintf ( stderr, "%s at %d: inconsistency in soo retrieve\n", __FILE__, __LINE__ );

    status = om$send ( msg = message GRgraphics.GRdelete ( &msg, &md_env ),
                       senderid = NULL_OBJID,
                       targetid = arcs [i],
                       targetos = osnum );
    if (!(status & 1))
    {
      fprintf ( stderr, "%s at %d: error in GRdelete\n", 
               __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  
    if (msg != MSSUCC)
      fprintf ( stderr, "%s at %d: error in NDdelete\n", 
               __FILE__, __LINE__ );

    status = de$retrieve_override ( msg = &msg,
                                    p_type = &type,
                                    p_u1 = &u1,
                                    p_u2 = &u2,
                                    go_grid = &grid,
                                    window_grid = &window,
                                    module = &md_env,
                                    u = 0.0 );
    if (msg == MSSUCC)
    {
      fprintf ( stderr, "%s at %d: soo retrieve should have failed\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }
  }

  return OM_S_SUCCESS;
}


DEplace_line ( msg, p_objid, window_grid, p1x, p1y, p1z, p2x, p2y, p2z, md_env )
               IGRlong         *msg;
               GRobjid         *p_objid;
               struct GRid     *window_grid;
               double          p1x, p1y, p1z, p2x, p2y, p2z;
               struct GRmd_env *md_env;
{
  long                  status;
  double                points [6];
  struct GRvg_construct ConstructList;
  struct IGRbsp_curve   curve;
  struct IGRdisplay     symb;
  
  status = OM_S_SUCCESS;
  *msg = MSSUCC;

  /* init. varables for construct */
  ConstructList.msg = msg;
  ConstructList.env_info = md_env;
  symb.color = 1;
  symb.style = 0;
  symb.weight = 0;
  ConstructList.display = &symb;
  curve.poles = &points [0];
  curve.num_poles = 2;
  ConstructList.geometry = (IGRchar *)&curve;
  ConstructList.newflag = FALSE;
  ConstructList.level = 0;
  ConstructList.class_attr = NULL;
  ConstructList.name = NULL;
  ConstructList.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE | GRIS_PLANAR;

  points [0] = p1x;
  points [1] = p1y;
  points [2] = p1z;
  points [3] = p2x;
  points [4] = p2y;
  points [5] = p2z;

  status = om$construct( msg       = message GRgraphics.GRconstruct( &ConstructList ),
                         osnum     = md_env->md_id.osnum,
                         classname = "GR3dlineseg",
                         p_objid   = p_objid );

  return status;
}


DEplace_line_str ( msg, p_objid, window, nb_points, points, md_env )
                   long            *msg;
                   GRobjid         *p_objid;
                   struct GRid     *window;
                   int             nb_points;
                   double          *points;
                   struct GRmd_env *md_env;
{
  long                  status;
  struct GRvg_construct ConstructList;
  struct IGRbsp_curve   curve;
  struct IGRdisplay     symb;

  status = OM_S_SUCCESS;
  *msg = MSSUCC;

   /* init. varables for construct */
  ConstructList.msg = msg;
  ConstructList.env_info = md_env;
  symb.color = 1;
  symb.style = 0;
  symb.weight = 0;
  ConstructList.display = &symb;
  curve.poles = &points [0];
  curve.num_poles = nb_points;
  ConstructList.geometry = (IGRchar *)&curve;
  ConstructList.newflag = FALSE;
  ConstructList.level = 0;
  ConstructList.class_attr = NULL;
  ConstructList.name = NULL;
  ConstructList.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE | GRIS_PLANAR;

  status = om$construct ( msg       = message GRgraphics.GRconstruct( &ConstructList ),
                          osnum     = md_env->md_id.osnum,
                          classname = "GR3dlinestr",
                          p_objid   = p_objid );

  return status;
}



DEplace_arc ( msg, p_objid, window_grid, start_angle, sweep_angle, radius, 
              x, y, z, md_env )
              long            *msg;
              GRobjid         *p_objid;
              struct GRid     *window_grid;
              double          start_angle, sweep_angle, radius, x, y, z;
              struct GRmd_env *md_env;
{
  long                  status;
  struct GRvg_construct ConstructList;
  struct IGRarc         arc;
  struct IGRdisplay     symb;
  
  status = OM_S_SUCCESS;
  *msg = MSSUCC;

  /* init. varables for construct */
  ConstructList.msg = msg;
  ConstructList.env_info = md_env;
  symb.color = 1;
  symb.style = 0;
  symb.weight = 0;
  ConstructList.display = &symb;
  ConstructList.geometry = (IGRchar *)&arc;
  ConstructList.newflag = FALSE;
  ConstructList.level = 0;
  ConstructList.class_attr = NULL;
  ConstructList.name = NULL;
  ConstructList.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE | GRIS_PLANAR;

  arc.rot_matrix [0] = 1.0;
  arc.rot_matrix [1] = 0.0;
  arc.rot_matrix [2] = 0.0;
  arc.rot_matrix [3] = 0.0;
  arc.rot_matrix [4] = 0.0;
  arc.rot_matrix [5] = 1.0;
  arc.rot_matrix [6] = 0.0;
  arc.rot_matrix [7] = 0.0;
  arc.rot_matrix [8] = 0.0;
  arc.rot_matrix [9] = 0.0;
  arc.rot_matrix [10] = 1.0;
  arc.rot_matrix [11] = 0.0;
  arc.rot_matrix [12] = 0.0;
  arc.rot_matrix [13] = 0.0;
  arc.rot_matrix [14] = 0.0;
  arc.rot_matrix [15] = 1.0;
  arc.prim_axis = radius;
  arc.sec_axis = radius;
  arc.origin [0] = x;
  arc.origin [1] = y;
  arc.origin [2] = z;
  arc.start_angle = start_angle;
  arc.sweep_angle = sweep_angle;

  status = om$construct( msg       = message GRgraphics.GRaltconstruct( &ConstructList ),
                         osnum     = md_env->md_id.osnum,
                         classname = "GR3dcirarc",
                         p_objid   = p_objid );

  return status;
}

end implementation DEso;
