#ifndef PDMexec_h
#define PDMexec_h

#include "MEMstruct.h"
/***********************************************************************
 *                                                                     *
 *  PDM Executive structure -                                          *
 *                                                                     *
 *  This structure is how PDMmain communicates with other PDM          *
 *  subsystems.  PDMmain is responsible for allocating any space for   *
 *  the structure or its fields, loading the information, and freeing  *
 *  up any dynamically allocated memory.                               *
 *                                                                     *
 ***********************************************************************/

typedef struct PDMexec_st
  {
	long	NFMstatus;
	long	SQLstatus;
	long	MEMstatus;
	long	user_id;
	long	operation;
	long	entity;
	char	*project;
	char	*catalog;
	char	*part_num;
	char	*revision;
	char	*dcatalog;
	char	*drawing;
	char	*drevision;
	MEMptr	ws_buffer;
	MEMptr	return_buffer;
  } *PDMexec_ptr;

/**********************************************************************
 *                                                                    *
 * PDM Part Information  structure -  CACHING       8/23/91           *
 *                                                                    * 
 * This structure is a global structure which contains the info       *
 * of the part which is under processing from all the relavant        *
 * tables so as to avoid frequent queries and multiple queries to     *
 * the database.                                                      *
 *                                                                    *
 ***********************************************************************/

typedef struct PDMpart_st
  {
   int        n_itemno;
   char       n_creator[15];
   char       n_creationdate[11];
   char       n_creationtime[9];
   char       n_updatedate[11];
   char       n_updatetime[9];
   char       n_status[3];
   char       n_setindicator[3];
   char       n_archivestate[3];
   int        n_stateno;
   char       n_itemlock[3];
   int        n_versionlimit;
   int        n_fileno;
   int        n_fileversion;
   char       n_fileco[3];
   char       n_pendingflag[3];
   int        n_cisano;
   char       n_cifilename[15];
   char       n_ciuser[15];
   char       n_cidate[11];
   char       n_citime[9];
   int        n_cosano;
   char       n_cofilename[15];
   char       n_couser[15];
   char       n_codate[11];
   char       n_cotime[9];
   char       p_explode[3];
   int        p_maxlevel;
   char       p_parttype[3];
   char       p_incpartrpt[2];
   int        n_catalogno;
   int        f_catalogno;
   int        n_itemnum;
   int        n_aclno;
   char       n_itemname[60];
  
  } PDMpart_ptr ;

/**********************************************************************
 *                                                                    *
 * PDM Child Information  structure -  CACHING       8/23/91           *
 *                                                                    * 
 * This structure is a global structure which contains the info       *
 * of the child which is under processing from all the relavant        *
 * tables so as to avoid frequent queries and multiple queries to     *
 * the database.                                                      *
 *                                                                    *
 ***********************************************************************/

typedef struct PDMchild_st
  {
   int        n_itemno;
   int        n_itemnum;
   char       n_creator[15];
   char       n_creationdate[11];
   char       n_creationtime[9];
   char       n_updatedate[11];
   char       n_updatetime[9];
   char       n_status[3];
   char       n_setindicator[3];
   char       n_archivestate[3];
   int        n_stateno;
   char       n_itemlock[3];
   int        n_versionlimit;
   int        n_fileno;
   int        n_fileversion;
   char       n_fileco[3];
   char       n_pendingflag[3];
   int        n_cisano;
   char       n_cifilename[15];
   char       n_ciuser[15];
   char       n_cidate[11];
   char       n_citime[9];
   int        n_cosano;
   char       n_cofilename[15];
   char       n_couser[15];
   char       n_codate[11];
   char       n_cotime[9];
   char       p_explode[3];
   int        p_maxlevel;
   char       p_parttype[3];
   int        n_catalogno;
   int        f_catalogno;
   int        n_aclno;
   char       n_itemname[60];
  
  } PDMchild_ptr ;
#endif
