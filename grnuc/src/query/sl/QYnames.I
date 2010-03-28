class implementation QYnpt;

#include <memory.h>
#include <malloc.h>
#include <string.h>
#ifndef NT
#include <sys/param.h>
#else
#include <stdlib.h>
#define MAXPATHLEN _MAX_PATH
#endif
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "OMspecify.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"

%safe
/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static int my_strcmp __((char **p_st1, char **p_st2));

#if defined(__cplusplus)
}
#endif
#undef __
%endsafe


from ACmacro_defn import ACgive_feet_desc;

QYget_class_names ( names, count )
                    char ***names	/* The class names		OUT */;
                    int  *count		/* The number of classes	OUT */;
/*
   This function returns the valid classes of the system.
*/
{
  static char **class_names = 0;
  static int  nb_classes = 0;
  
  if (!nb_classes)
  {
    int                 i, status;
    OMuword             graphics_clid;
    extern OM_p_FUNCPTR OM_GA_class_definitions [];
    extern int          OM_Gi_number_of_defns;
    
    /* we need to fill out our list */

    class_names = (char **)malloc ( OM_Gi_number_of_defns * sizeof ( char * ) );
    if (!class_names)
      return OM_E_NODYNMEM;

    status = om$get_classid ( classname = "GRgraphics", 
                              p_classid = &graphics_clid );
    if (status != OM_S_SUCCESS)
      return status;

    for (i = 0; i < OM_Gi_number_of_defns; i++)
    {
      char         class_name [OM_K_MAXCLASS_LEN];
      OM_p_FUNCPTR p = OM_GA_class_definitions [i];
      

      /* get the class name */
      strcpy ( class_name, ((OM_S_CREATECLASS_ARGS *) (p ()))->s_name );
      
      /* it must be a sub class of GRgraphics */
      if (om$is_ancestry_valid ( subclassname = class_name,
                                 superclassid = graphics_clid ) == OM_S_SUCCESS)
      {
        class_names [nb_classes] = (char *)malloc ( OM_K_MAXCLASS_LEN + 1);
        if (!class_names [nb_classes])
          return OM_E_NODYNMEM;
          
        strcpy ( class_names [nb_classes++], class_name );
      }
    }

    /* let's sort the list */
    qsort ( (char *)class_names, (unsigned)nb_classes, sizeof ( char * ), strcmp );
  }

  *names = class_names;
  *count = nb_classes;
  
  return OM_S_SUCCESS;
}


static my_strcmp ( p_st1, p_st2 )
                   char **p_st1, **p_st2;
{
  return strcmp ( *p_st1, *p_st2 );
}


QYget_macro_names ( names, count )
                    char ***names	/* The macro names		OUT */;
                    int  *count		/* The number of macros		OUT */;
/*
   This function returns the valid macros of the current design file.
*/
{
  OM_S_CLASSLIST     class_list;
  int                i, status;
  OMuword            macro_def_clid;
  static char        **macro_names = 0;
  static int         nb_macros = 0;
  
  /* free the previous list */
  if (nb_macros)
  {
    for (i = 0; i < nb_macros; i++)
      free ( macro_names [i] );
    free ( macro_names );
    nb_macros = 0;
  }
  
  /* get the list of valid macros */
  class_list.w_flags = OM_CLST_subclass;
  class_list.w_count = 1;
  status = om$get_classid ( classname = "ACcpx_defn", 
                            p_classid = &macro_def_clid );
  if (status != OM_S_SUCCESS)
    return status;
  class_list.p_classes = &macro_def_clid;
  status = di$dump ( regexp = ":*:constructs:*",
                     lines = &macro_names,
                     ptr = &nb_macros,
                     p_classes = &class_list,
                     options = 0 );
  if (status != OM_S_SUCCESS)
    return status;

  for (i = 0; i < nb_macros; i++)
    di$split ( pathname = macro_names [i], name = macro_names [i] );
    
  /* let's sort the list */
  qsort ( (char *)macro_names, (unsigned)nb_macros, sizeof ( char * ), my_strcmp );

  *names = macro_names;
  *count = nb_macros;
  
  return OM_S_SUCCESS;
}


QYget_feet ( feet_names, count, names, mac_count )
             char ***feet_names	/* The feet				OUT */;
             int  *count	/* The number of feet			OUT */;
             char **names	/* The macro names			IN  */;
             int  mac_count	/* The number of macro names		IN  */;
/*
   This function returns the feet of the macros passed as arguments.
*/
{
  OM_S_CLASSLIST     class_list;
  OMuword            macro_def_clid;
  int                i, j, l, status, nb_macros;
  char               reg_exp [MAXPATHLEN];
  DIgrid             *macros;
  static char        **feet = 0;
  static int         nb_feet = 0;
  
  /* free the previous list */
  if (nb_feet)
  {
    for (i = 0; i < nb_feet; i++)
      free ( feet [i] );
    free ( feet );
    nb_feet = 0;
  }

  /* get the macro name */
  class_list.w_flags = OM_CLST_subclass;
  class_list.w_count = 1;
  status = om$get_classid ( classname = "ACcpx_defn", 
                            p_classid = &macro_def_clid );
  if (status != OM_S_SUCCESS)
    return status;
  class_list.p_classes = &macro_def_clid;
  for (l = 0; l < mac_count; l++)
  {
    DIstmcpy ( reg_exp, "", "*", "constructs", names [l], 0 );
    status = di$dump ( regexp = reg_exp,
                       ptr = &nb_macros,
                       grids = &macros,
                       p_classes = &class_list,
                       options = 0 );
    if (status != OM_S_SUCCESS)
      return status;

    for (i = 0; i < nb_macros; i++)
    {
      int           count;
      struct myfeet *myfeet;

      status = om$send ( msg = message ACmacro_defn.ACgive_feet_desc ( &count, &myfeet ),
                         senderid = NULL_OBJID,
                         targetid = macros [i].objid,
                         targetos = macros [i].osnum );
      if (status != OM_S_SUCCESS)
      {
        free ( macros );
        return status;
      }

      if (nb_feet)
        feet = (char **)realloc ( feet, 
                                  (1 + ((nb_feet + count) / 64)) * 64  * sizeof ( char * ) );
      else
        feet = (char **)malloc ( (1 + ((nb_feet + count) / 64)) * 64  * sizeof ( char * ) );
    
      if (!feet)
      {
        free ( macros );
        return OM_E_NODYNMEM;
      }
      for (j = 0; j < count; j++)
      {
        feet [j + nb_feet] = (char *)malloc ( (1 + (strlen ( myfeet [j].name ) / 32)) * 32  );
        if (!feet [j + nb_feet])
        {
          free ( macros );
          return OM_E_NODYNMEM;
        }
        strcpy ( feet [j + nb_feet], myfeet [j].name );
      }
      nb_feet += count;
    }
  
    free ( macros );
  }

  /* let's sort the list */
  qsort ( (char *)feet, (unsigned)nb_feet, sizeof ( char * ), my_strcmp );
  *feet_names = feet;
  *count = nb_feet;
  
  return OM_S_SUCCESS;
}


end implementation QYnpt;
