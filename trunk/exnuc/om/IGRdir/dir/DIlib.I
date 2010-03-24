/*
   ABSTRACT :
   --------

   This file contains the routines used to manage the directories.
*/
class implementation DIrectory;

#include <string.h> 
#include <stdio.h> 

#include "DIomac.h"
#include "DIdef.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMlimits.h"
#include "DIprims.h"


void DIfrees( arg_list, arg_num )
              DIchar **arg_list	/* List of pointers to char	IN  */;
              DIint  arg_num	/* Number of items in the list	IN  */;
/*
   This method frees the memory allocated during the memory-based ls.
*/
{ 
  DIint i ;

  if (arg_list && arg_num)
  {
    for (i = 0 ; i < arg_num ; i++ )
      if (arg_list [i])
        free( ( DIchar * ) arg_list[i] );

    DIfree( arg_list )
  }

} /* DIfrees */


DIexpand ( str )
           DIchar *str	/* String to be expanded		IN  */;
/* 
   This function suppress '.' and '..' in the given string.
*/
{
  DIint  i, j;
  DIchar dot [3], dotdot [4];

  strcat ( strcpy ( dotdot, strcat ( strcpy ( dot, DIR_G_str_dir ), "." ) ), "." );
  for (i = 0; str [i]; i++)
  {
/*    if (!strncmp ( dotdot, &str [i], 3 ))*/
    if((dotdot[0]==str[i]) && (dotdot[1]==str[i+1]) && (dotdot[2]==str[i+2]))
    {
      if ((!str [i + 3]) || (str [i + 3] == DIR_G_car_dir))
      {
        for (j = i - 1; j > 0; j--) if (str [j] == DIR_G_car_dir) break;
        if (j < 0) return DIR_E_SYNTAX;
        strcpy ( &str [j], &str [i + 3] );
        i = j - 1;
      }
    }
    else
      if (!strncmp ( dot, &str [i], 2 ))
/*      if( (dot[0]==str[i]) && (dot[1]==str[i+1]) )      */
        if ((!str [i + 2]) || (str [i + 2] == DIR_G_car_dir))
        {
          strcpy ( &str [i], &str [i + 2] );
          i--;
        }
  }
  /* get rid of '::' */
  for (i = 0; str [i]; i++)
    if ((str [i] == DIR_G_car_dir) && (str [i + 1] == DIR_G_car_dir))
      strcpy ( &str [i], &str [i + 1] );

  return 1;
} /* end DIexpand */



DIstrcmp ( name1, name2 )
           DIchar *name1	/* First directory name		IN  */,
                  *name2  	/* Second directory name	IN  */;
/*
   This function is used to compare name1 and name2.  The size is limited
   to DI_PATH_MAX.
*/
{
  return strncmp ( name1, name2, DI_PATH_MAX );
}



DIstrcpy ( name1, name2 )
           DIchar *name1	/* Target of copy	IN/OUT */,
                  *name2  	/* Source of copy	IN     */;
/*
   This function is used to copy name2 into name1.  The size is limited
   to DI_PATH_MAX.
*/
{
  DIint status = DIR_S_SUCCESS;

  if (strlen ( name2 ) >= DI_PATH_MAX)
    status = DIR_E_OVFLOW;
  else
    strcpy ( name1, name2 );

  return status;
}



DIstrcat ( name1, name2 )
           DIchar *name1	/* Source and target of cat	IN/OUT */,
                  *name2     	/* Source of cat		IN     */;
/*
   This function is used to concatenate name1 and name2 into name1.  The size
   is limited to DI_PATH_MAX and the terminator of name1 is forced to
   DIR_G_car_dir.
*/
{
  DIint status = DIR_S_SUCCESS, length1;

  if ((length1 = strlen ( name1 )) + strlen ( name2 ) >= DI_PATH_MAX)
    status = DIR_E_OVFLOW;
  else
  {
    if (length1)
    {
      if (name1 [length1 - 1] != DIR_G_car_dir)
        strcat ( name1, DIR_G_str_dir );
    }
    else
      strcpy ( name1, DIR_G_str_dir );

    strcat ( name1, name2 );
  }

  return status;
}


DIfrtcat ( name1, name2 )
           DIchar *name1	/* Source and target of cat	IN/OUT */,
                  *name2  	/* Source of cat		IN     */;
/*
   This function is used to concatenate name1 and name2 into name2.  The size
   is limited to DI_PATH_MAX and the terminator of name1 is forced to
   DIR_G_car_dir.  This function puts name2 before name1 in name1.
*/
{
  DIint  status;
  DIchar tmp [DI_PATH_MAX];

  status = DIstrcpy ( tmp, name2 );
  if (status == DIR_S_SUCCESS)
  {
    status = DIstrcat ( tmp, name1 );
    if (status == DIR_S_SUCCESS)
      status = DIstrcpy ( name1, tmp );
  }

  return status;
}


DIadd_pwd ( base )
            DIchar *base	/* Name to be modified		IN/OUT */;
/*
   This function adds the current directory name at the beginning of
   the string.
*/
{
  DIint status = DIR_S_SUCCESS;

  if (*base != DIR_G_car_dir)
  {
    DIchar tmp [DI_PATH_MAX];

    if ((status = DIstrcpy ( tmp, base )) == DIR_S_SUCCESS) 
      if ((status = DIstrcpy ( base, DIR_G_cur_dir_name )) == DIR_S_SUCCESS)
        status = DIstrcat ( base, tmp );
  }

  return status;
}


DIexpanse( dir_name1, dir_name2 )
           DIchar *dir_name1	/* Name to be expansed			IN  */,
                  *dir_name2	/* Name to put the result in		OUT */;
/*
   This procedure will transform a logical dir name in a full path name
   for example : "dir1" -> ":dirmain:subdir1:dir1:"
*/
{
  DIint status = DIR_S_SUCCESS;

  if (strlen ( dir_name1 ) >= DI_PATH_MAX)
    return DIR_E_OVFLOW;

  if (dir_name1 [0] == DIR_TILDA)
  {
    strcpy ( dir_name2, DIR_G_home_name );
    strcat ( dir_name2, &(dir_name1 [1]) );
  }
  else
  {
    strcpy ( dir_name2, dir_name1 );
    status = DIadd_pwd ( dir_name2 );
  }
  
  if (status == DIR_S_SUCCESS)
  {
    status = DIexpand ( dir_name2 );

    /* last character may not be a DIR_G_car_dir */
    DIterminator ( dir_name2 );
  }

  return status;
}/* DIexpanse */



DIterminator ( string )
               DIchar *string	/* Name to be checked		IN/OUT */;
/*
   This functions checks that the terminator is NOT DIR_G_car_dir.  If so,
   the string is truncated.
*/
{
  DIint status = DIR_S_SUCCESS, length;

  for ( length = strlen ( string ); 
        (length > 0) && (string [length - 1] == DIR_G_car_dir); length--)
    string [length - 1] = '\0';

  return status;
}



DIget_level ( path_name )
              DIchar *path_name	/* Name to be checked		IN  */;
/*
   This function returns the number of directory separators that are in
   the path name.
*/
{
  DIchar *tmp;
  DIint  level = 0;

  if (path_name)
    for (level = 0, tmp = path_name; *tmp; )
      if (*tmp++ == ':') level++;

  return level;
}


DIparse_dir ( dir_name, arg, arg_num )
              DIchar *dir_name	/* Directory name to parse		IN  */,
                     ***arg	/* Names of each directory		OUT */;
              DIint  *arg_num	/* Number of levels			OUT */;
/*
  This function is used to parse the directory name 
  a full path name is split into its components
  for example : ":dirmain:subdir1:subdir2:"
        arg  -> "dirmain"
	     	"subdir1"
	     	"subdir2"
	argnum =3
*/
{
  DIint  length, i, lst;
  DIchar ok;

  *arg_num = 0;
  *arg = (char **)malloc ( sizeof ( char * ) );
  ok = arg != 0;
  
  for (i = 0, lst = 0, length = strlen ( dir_name );
       (i < length) && ok; i++)
    if (dir_name [i] == DIR_G_car_dir)
    {
      ok = (dir_name [i + 1] != DIR_G_car_dir);
      if (ok && (i > 0))
      {
        *arg = (DIchar **) realloc ( (DIchar **) *arg, 
                                     (*arg_num + 1) * sizeof ( DIchar * ) );
        (*arg) [(*arg_num)++] = (DIchar *)malloc ( (i - lst)  * sizeof ( DIchar ) );

        strncpy ( (*arg) [*arg_num - 1], &(dir_name [lst + 1]), i - lst - 1 );
        (*arg) [*arg_num - 1] [i - lst - 1] = '\0';
        lst = i;
      }
    }
                
  return ok;
}


DIobjid DIconstruct ( DIchar *classname, DIspacenum osnum )
/*
   This entry point constructs a subclass of DIbtree in osnum and return
   the objid.
*/
{
  DIint   om_status, status;
  DIobjid objid = NULL_OBJID;

  om_status = om$construct( osnum = osnum, classname = classname, p_objid = &objid, 
                            msg = message IGRdir.init ( &status ) );
  return objid;
}



DIcreate_dir ( classname, fullname, basename, parent, dir )
               DIchar *classname	/* Directory to be created  	IN  */;
               DIchar fullname []	/* Full path name	    	IN  */;
               DIchar basename [] 	/* Base name			IN  */;
               DIgrid parent		/* Parent directory		IN  */;
               DIgrid *dir		/* Directory grid		OUT */;
/*
   This entry point is used to create a directory, to put it in the parent,
   in the master directory and in the reverse access directory.
*/
{
  DIint  status;

  dir->objid = DIconstruct ( classname, parent.osnum );
  if (dir->objid != NULL_OBJID)
  {
    dir->osnum = parent.osnum;
    status = DIadd_name ( fullname, 0, parent, basename, dir->objid, 0, 0, 0);
    if (status != DIR_S_SUCCESS)
    {
      /* problem : delete it */
      om_send_for ( Root.delete (1), NULL_OBJID, dir->objid, dir->osnum );
    }
  }
  else
    status = DIR_E_ABORT;

  return (status == DIR_E_NAME_DUP) ? DIR_E_DIR_DUP : status;
}


DIadd_grid_line ( lines, grids, full_path, grid, count )
                  DIchar ***lines	/* The lines               OUT */;
		  DIgrid **grids	/* The grids               OUT */;
                  DIchar *full_path	/* The full path for lines IN  */;
                  DIgrid grid	        /* The grid for grids      IN  */;
                  DIint  count		/* Number of elements      IN  */;
/*
   This procedure fills out lines and grids if not NULL.
*/
{
  if (lines) DIadd_line ( lines, count, full_path );
  if (grids) DIadd_grid ( grids, count, grid );
  return DIR_S_SUCCESS;
}


DIancestry_valid ( DIspacenum osnum, DIobjid objid, DIclassid class_id )
/*
   This entry point checks that the (osnum, objid) object is an instance
   of a subclass of class_id (including class_id itself).
*/
{
  DIclassid ob_class_id;
  DIint     status;

  status = om$get_classid ( osnum = osnum, objid = objid, p_classid = &ob_class_id );
  if (status != OM_S_SUCCESS)
    return 0;

  status = om$is_ancestry_valid ( subclassid = ob_class_id, superclassid = class_id );
  if (status != OM_S_SUCCESS)
    return 0;
  else
    return 1;
}


DIclean ( string )
          DIchar *string;
/* remove the blanks */
{
  DIint length, i, j;

  for (length = strlen ( string ), i = 0, j = 0; i <= length; i++)
      if (string [i] != ' ') string [j++] = string [i];  

  return DIR_S_SUCCESS;
}


DIchstr ( string, old, new )
          DIchar *string	/* The string to be modified	      IN/OUT */,
                 *old		/* The string to be replaced	      IN     */,
                 *new		/* The replacement string	      IN     */;
/* 
   This procedure will replace all old strings by new strings within
   string.
*/
{
  DIint  length_old = strlen ( old );
  DIchar tmp [DI_PATH_MAX], *index = string, 
         *mark_new = &(new [strlen ( new )]),
         *index_new, *index_tmp = tmp, *mark = &(string [strlen ( string )]),
         *mark_tmp = &(tmp [DI_PATH_MAX - 1]);

  for (; (index != mark) && (mark_tmp != index_tmp); )
    if (!strncmp ( old, index, length_old ))
    {
      for (index_new = new; (mark_tmp != index_tmp) && (index_new != mark_new); )
        *index_tmp++ = *index_new++;
      index += length_old;
    }
    else
      *index_tmp++ = *index++;
      
  *index_tmp = '\0';
  strcpy ( string, tmp );

  return (mark_tmp != index_tmp) ? 1 : index == mark;
}


DIint DIcheck_class ( OM_p_CLASSLIST class_list, DIspacenum osnum,
   DIobjid objid )
/*
   This function checks if the object given by (osnum, objid) is in the
   class_list.
*/
{
  DIchar ok;

  if (class_list)
  {
    DIchar  neg;
    DIint   i;
    OMuword classid;

    neg = class_list->w_flags & OM_CLST_negation;
    if (class_list->w_count)
    {
      om$get_classid ( osnum = osnum, objid = objid, p_classid = &classid );
      for (i = 0, ok = 0; (i < (DIint) class_list->w_count) && (!ok); i++)
        if (class_list->w_flags & OM_CLST_subclass)
          ok = om$is_ancestry_valid ( subclassid = classid,
                     superclassid = class_list->p_classes [i] ) == OM_S_SUCCESS;
        else
          ok = classid == class_list->p_classes [i];
      if (neg) ok = !ok;
    }
    else
      ok = neg;
  }
  else
    ok = 1;
  return ( ok );
}

#argsused
DIfind_dir ( dirname, p_osnum, p_objid, name, path )
             DIchar     *dirname /* The directory 			OUT */;
             DIspacenum *p_osnum /* The object space number		OUT */;
             DIobjid    *p_objid /* The object id			OUT */;
             DIchar     *name    /* The directory to be accessed	IN  */;
             DIchar     *path	 /* The search path			IN  */;
/* This procedure is used to find a directory using the master directory */
{
  DIint status;

  if (name)
  {
    DIgrid grid;

    DIexpanse ( name, dirname );
    DImasterRetrieve ( &status, dirname, 0, (DIchar *) &grid, NULL, NULL );
    *p_objid = grid.objid; *p_osnum = grid.osnum;
  }
  else
    status = di$pwd ( dirname = dirname, p_dirid = p_objid, p_osnum = p_osnum );

  return status;
}


DIsplit ( pathname, dirname, name )
          DIchar *pathname	/* Full path name to split		IN  */,
                 *dirname       /* Directory name			OUT */, 
                 *name		/* Base name				OUT */;
/*
  This entry point is used to split a full path name into a directory
  name and the name within the IGRdir.
*/
{
  DIint status = DIR_S_SUCCESS, i, length = strlen ( pathname );

  for (i = length - 2; (pathname [i] != DIR_G_car_dir) && (i >= 0); i-- );
  if (i >= 0)
  {
    if (dirname)
    {
      /* get the directory name */
      strncpy ( dirname, pathname, i );
      dirname [i] = '\0';
    }
    if (name) strcpy ( name, &(pathname [i+1]) );
  }
  else
  {
    /* the directory name is the current one */
    if (dirname)
      if ((status = di$pwd ( dirname = dirname )) == DIR_S_SUCCESS) DIterminator ( dirname );
    if (name)
       strcpy ( name, pathname );
  }

  return status;
}



DIis_regexp ( string )
              DIchar *string	/* Name to be analyzed			IN  */;
/*
   This entry point is used to define if the string is just a name or a
   regular expression.
*/
{
  DIchar *ptr;

  for (ptr = string; *ptr; ptr++)
    if (*ptr == '\\')
      ptr++;
    else
      if ((*ptr == '|') || (*ptr == '*') || (*ptr == '[') || (*ptr == '?'))
        return 1;

  return 0;
}

            
DIreport_error ( status, comment, out_s )
                 DIint  status		/* Error status			IN  */;
                 DIchar *comment	/* Comment to be printed	IN  */;
                 DIchar *out_s		/* Output string 		OUT */;
/*	
   This function prints an error message corresponding to the error ststus.
*/
{
  DIchar tmp [DI_PATH_MAX], tmp1 [DI_PATH_MAX];
  
  if (comment) sprintf ( tmp, "%s\n", comment ); else *tmp = '\0';
  sprintf ( tmp1, "Directory Report Error (%d) ", status );
  strcat ( tmp, tmp1 );

  if (!(status & 0x7)) strcat ( tmp, "WARNING " );
  if (status & SEVE) strcat ( tmp, "SEVERE " );
  if (status & ERRO) strcat ( tmp, "ERROR " );
  if (status & SUCC) strcat ( tmp, "SUCCESS " );
  strcat ( tmp, ": " );

  switch ( status)
  {
    case  DIR_S_SUCCESS        : strcat ( tmp, "Operation Succesfully Completed\n" );
                                 break;
    case  DIR_E_ABORT          : strcat ( tmp, "Operation Aborted\n" );
                                 break;
    case  DIR_E_INVARG         : strcat ( tmp, "Invalid Argument\n" );
                                 break;
    case  DIR_E_DIR_DUP        : strcat ( tmp, "Directory Name Duplicated\n" );
                                 break;
    case  DIR_E_NAME_DUP       : strcat ( tmp, "Object Name Duplicated\n" );
                                 break;
    case  DIR_E_SYNTAX         : strcat ( tmp, "Directory Syntax Error\n" );
                                 break;
    case  DIR_E_OVFLOW         : strcat ( tmp, "Overflow in Name or in Index\n" );
                                 break;
    case  DIR_W_NAME_NOT_FOUND : strcat ( tmp, "Object Name NOT Found\n" );
                                 break;
    case  DIR_W_DIR_NOT_FOUND  : strcat ( tmp, "Directory Name NOT Found\n" );
                                 break;
    case  DIR_W_NOT_IMPL       : strcat ( tmp, "Feature NOT Implemented\n" );
                                 break;
    case  DIR_W_NO_NAME        : strcat ( tmp, "This Object has NO Name\n" );
                                 break;
    case  DIR_E_NO_NAME        : strcat ( tmp, "This Object has NO Name\n" );
                                 break;
    case  DIR_I_DIR_EMPTY      : strcat ( tmp, "Directory Empty\n" );
                                 break;
    case  DIR_E_PERMISSION     : strcat ( tmp, "Permission Violation\n" );
                                 break;
    case  DIR_E_PRIVATE        : strcat ( tmp, "Directory is Private\n" );
                                 break;
    case  DIR_E_READ_ONLY      : strcat ( tmp, "Directory is Read Only\n" );
                                 break;
    case  DIR_E_ILL_LINK       : strcat ( tmp, "Link Accross Object Spaces\n" );
                                 break;
    case  DIR_E_ILL_NAME       : strcat ( tmp, "Illegal Name\n" );
                                 break;
    case  DIR_E_DIR_NOT_EMPTY  : strcat ( tmp, "Directory is NOT empty\n" );
                                 break;
    case  DIR_I_REORG          : strcat ( tmp, "Directory has been re-organized\n" );
                                 break;
    default                    : if (status & (OM_FACILITY_CODE << 16))
                                   om$report_error ( sts = status );
                                 else
	                           strcat ( tmp, "Unknown Error Status\n" );
  }

  if (out_s)
    strcpy ( out_s, tmp );
  else
    fprintf ( stderr, "%s", tmp );

  return DIR_S_SUCCESS;
}


end implementation DIrectory;
