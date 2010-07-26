#include <search.h>
#include <stdio.h>
#include <memory.h>
#include <string.h>
#include "OMminimum.h"
#include "OMerrordef.h"

#define DEBUG
#include "DIomac.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIuntree.h"


DIundebug ( os )
            DIspacenum os;
{
  DIint i, j;

  printf ( "table for os %d:\n", os );
  if (DIuntrees [os])
    for (i = 0; i < DIusizes [os]; i++)
    { printf ( "untree [%d]: %d, %d", i, DIuntrees [os] [i].objid, DIuntrees [os] [i].count );
      for (j = 0; j < 2 * (DIuntrees [os] [i].count); j += 2 )
        printf ( " ('%s':'%s')", DIuntrees [os] [i].names [j], DIuntrees [os] [i].names [j + 1] );
      printf ( "\n" ); }
  else
    printf ( "This os has no untranslate tree\n" );
  return(1);
}


DIunall ( os, objid, dirname, objname, delete, p_unode, del )
          DIspacenum os		/* The untree id (os number)		 IN */;
          DIobjid    objid	/* The objid that is in a directory	 IN */;
          DIchar     *dirname	/* The directory name			 IN */;
          DIchar     *objname	/* The object name			 IN */;
          DIint      delete	/* Do we want to delete the entry ?	 IN */;
          DIunode    *p_unode   /* Pointer to the node			OUT */;
          DIint      *del	/* Has the node been deleted ?		OUT */;
{
  DIint   status = DIR_S_SUCCESS, i;
  DIunode *ptr;
  extern OMuword OM_Gw_maxOS;
  
  if (os > OM_Gw_maxOS) return DIR_E_INVARG;
  
  /* is it already in the untree ? */
  ptr = DIgetunode( os, objid );
  if (p_unode)
    if (ptr) *p_unode = *ptr; else status = DIR_W_NAME_NOT_FOUND;
  else
    if (delete)
      for (status = DIR_W_NAME_NOT_FOUND, (del) ? *del = 0 : 0, i = 0; ptr && (i < 2 * ptr->count); i += 2 )
      { if (!strcmp ( dirname, ptr->names [i] ) && !strcmp ( objname, ptr->names [i + 1] ))
        { status = DIR_S_SUCCESS;
          DIfree ( ptr->names [i] );
          DIfree ( ptr->names [i + 1]);
          if (ptr->count == 1)
          { /* last one->get rid of the node */
            DIfree ( ptr->names );
            /* move the other nodes */
            memcpy ( (char *) ptr, (char *) ((DIint) ptr + DIusize),
               (int) ((DIint)(DIusizes [os] - (DIint)(ptr - DIuntrees [os]) - 1) *
               DIusize) );
            DIusizes [os]--;
            (del) ? *del = 1 : 0; }
          else
          { /* not the last one -> move the names */
            memcpy ( (char *) &ptr->names [i],
               (char *) &ptr->names [i + 2],
               (int) ((2 * (ptr->count - 1) - i) * sizeof ( DIchar * )) );
            DIrealloc ( ptr->names, DIchar **, ptr->count-- * 2 * sizeof ( DIchar * ) ); }
          break; } }
    else
    {
      if (ptr)
        DIrealloc ( ptr->names, DIchar **, (ptr->count + 1) * 2 * sizeof ( DIint ) )
      else
      { 
#define INCREMENT 1024

        if (!DIusizes [os])
          DIrealloc ( DIuntrees [os], DIunode *, DIusize * INCREMENT )
        else
          if (!((DIusizes [os] + 1) % INCREMENT))
            DIrealloc ( DIuntrees [os], DIunode *, (DIusizes [os] + INCREMENT) * DIusize )
          
        for (i = DIusizes [os] - 1; (i >= 0) && (objid < DIuntrees [os] [i].objid); i--)
          DIuntrees [os] [i + 1] = DIuntrees [os] [i];
        DIusizes [os]++;
        (ptr = &DIuntrees [os] [i + 1])->objid = objid;
        DImalloc ( ptr->names, DIchar **, 2 * sizeof ( DIint ) );
        ptr->count = 0; }
      { DIchar *dirname1 = (DIchar *)malloc ( strlen ( dirname ) + 1 ),
               *objname1 = (DIchar *)malloc ( strlen ( objname ) + 1 );
        /* kludge: we are looking for a better solution */
        strcpy ( dirname1, dirname );
        strcpy ( objname1, objname );
        ptr->names [2 * ptr->count] = dirname1;
        ptr->names [2 * ptr->count++ + 1] = objname1; }}

  return status;
}


DIcreate_untree ( os )
                  DIspacenum os	/* os the table is created for	 	IN */;
{
  if (!DIuntrees [os])
  { DImalloc ( DIuntrees [os], DIunode *, sizeof ( DIunode ) );
    DIusizes [os] = 0; }
  return 1;
}


DIdelete_untree ( os )
DIspacenum os	/* os the table is created for	 	IN */;
/*
 * This routine deletes the untree for the specified os. The untree
 * is supposed to be empty when this routine is called.
 */
{
  if (DIuntrees [os])
  {      
    DIfree ( DIuntrees [os] );
  }
  
  return 1;
}


DIquick_delete_untree ( os )
DIspacenum os	/* os the table is created for	 	IN */;
/*
 * This routine deletes the untree and all the associated names
 */
{
  int i, j;
  
  if (DIuntrees [os])
  {
    for (i = 0; i < DIusizes [os]; i++)
    {
      for (j = 0; j < DIuntrees [os] [i].count; j++)
      {
        DIfree ( DIuntrees [os] [i].names [j * 2] );
        DIfree ( DIuntrees [os] [i].names [j * 2 + 1] );
      }
      DIfree ( DIuntrees [os] [i].names );
    }
      
    DIfree ( DIuntrees [os] );
  }
  
  return 1;
}


DIBinit ()
{
  OMuword i;
  extern OMuword OM_Gw_maxOS;

  DImalloc ( DIuntrees, DIunode **, (OM_Gw_maxOS + 2) * sizeof ( DIunode * ) );
  DImalloc ( DIusizes, DIint *, (OM_Gw_maxOS + 2) * sizeof ( DIint ) );
  for (i = 0; i <= (OM_Gw_maxOS); i++)
  { DIusizes [i] = 0;
    DIuntrees [i] = NULL; }
  return(1);
}
