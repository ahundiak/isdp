/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   levels.h  $
|   $Revision: 1.1 $  $Date: 1995/10/17 23:24:04 $
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
| Copyright (C) 1986-90   Bentley Systems, Inc., All rights reserved.	|
|									|
| "MicroStation", "MDL", and "MicroCSL" are trademarks of Bentley	|
|  Systems, Inc.							|
|									|
| Limited permission is hereby granted to reproduce and modify this	|
| copyrighted material provided that the resulting code is used only in	|
| conjunction with Bentley Systems products under the terms of the	|
| license agreement provided therein, and that this notice is retained	|
| in its entirety in any such reproduction or modification.		|
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
|   levels.h -- Named Levels						|
|									|
+----------------------------------------------------------------------*/
#if !defined (__levelsH__)
#define __levelsH__

#if !defined (__basedefsH__)
#include "basedefs.h"
#endif
#if !defined (__basetypeH__)
#include "basetype.h"
#endif
#if !defined (__msdefsH__)
#include "msdefs.h"
#endif

/*----------------------------------------------------------------------+
|									|
|   Type definitions							|
|									|
+----------------------------------------------------------------------*/
#if !defined (resource)
typedef struct levelGroup
    {
    char    *name;	    /* name of group */
    int	     groupID;	    /* unique ID for this group */
    int	     parentID;	    /* groupID of parent group */
    } LevelGroup;

typedef struct namedLevel
    {
    int	     level;	    /* IGDS level number */
    char    *name;	    /* name of this level */
    char    *comment;	    /* comment for this level */
    int	     groupID;	    /* ID of group */
    } NamedLevel;

typedef struct
    {
    int		 numGroups;  /* number of LevelGroups */
    LevelGroup  *groups;     /* array of LevelGroups */
    int		 numLevels;  /* number of NamedLevels */
    NamedLevel  *levels;     /* array of NamedLevels */
    } DesignLevels;

typedef struct
    {
    int	    count;	/* number of levels in set */
    int	   *indexArray;	/* array of indices into designLevels */
    } LevelSet;
    
typedef struct
    {
    int	    count;	/* number of groups in set */
    int	   *indexArray;	/* array of indices into designLevels.groups */
    } GroupSet;
#endif

/*----------------------------------------------------------------------+
|									|
|   Defines								|
|									|
+----------------------------------------------------------------------*/
#define MAX_LEVELS		128
#define LEVEL_SEPARATOR		':'
#define LEVEL_ROOT		":"
						
#define GROUP_NAME_WIDTH	16	/* size of group name	    */
#define LEVEL_NAME_WIDTH	16	/* size of level name	    */
#define LEVEL_COMMENT_WIDTH	32	/* size of level comment    */

#define LEVEL_COLUMNS		3	/* columns in dialog box    */
#define NAMEDLEVEL_LEVEL	0	/* Type 66 subtypes	    */
#define NAMEDLEVEL_GROUP	1

/*----------------------------------------------------------------------+
|									|
|   Dialog box constants						|
|									|
+----------------------------------------------------------------------*/
/* dialog box item indices */
#define NAMEDLEVELS_LevelsList			0
#define NAMEDLEVELS_GroupList			1
#define NAMEDLEVELS_SortButton			8
#define NAMEDLEVELS_PathLabel			10
				
#define LEVELEDIT_LevelNumberField		0
#define LEVELEDIT_LevelNameField		1
#define LEVELEDIT_LevelCommentField		2
    
#define GROUPEDIT_GroupNameField		0
#endif
				