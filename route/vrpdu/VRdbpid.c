/* $Id: VRdbpid.c,v 1.1.1.1 2001/01/04 21:13:01 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpdu / VRdbpid.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRdbpid.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.2  1997/08/15  19:34:34  pinnacle
 * Replaced: vrpdu for:  by hverstee for route
 *
 * Revision 1.1  1996/07/25  18:25:44  pinnacle
 * Creation of Route 241 project
 *
 * Revision 1.4  1996/04/22  13:58:22  pinnacle
 * Replaced: vrpdu/VRdbpid.c for:  by hverstee for route240
 *
 * Revision 1.3  1996/04/04  21:47:34  pinnacle
 * Replaced: vrpdu/VRdbpid.c for:  by ashankar for route240
 *
 * Revision 1.2  1996/01/17  17:30:50  pinnacle
 * Replaced: vrpdu/VRdbpid.c for:  by r240_int for route240
 *
 *
 * History:
 *	01/15/96	tlb	Add prototypes, 
 *				Make VRdbCachePidTbl a static function
 *				Change VRdbGetPidSym to ANSII style
 *
 *************************************************************************/
#include <stdio.h>
#include <string.h>
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "VRdef.h"
#include "VRDbStruct.h"
#include "VRmsg.h"
#include "VRDbTbl.h"
#include "vrpdu_pto.h"
#include "VDmem.h"

#if 0

struct  VRDbPidSymTbl 
        {
           char   comp_code[10];
           char   macro_name[20];

#ifdef	MANAGE_IDS
	   int	  id_category;
	   int	  id_behaviour;
#endif
        };


/**************************************************************/
/*   these static externals to be initialized at DB change    */
static int    DbPidSymFirst=1;
static short  DbPidArrNum = 0;

static struct VRDbPidSymTbl *DbPidSym = NULL;
/**************************************************************/
/*    clear cache function                                    */

void VR_DbC_Clpid ()

{
  DbPidSymFirst = 1;
  DbPidArrNum   = 0;

  _FREE (DbPidSym);

  return;
}

/* ---------------------------------------------*/
static IGRint 
VRdbCachePidTbl ( msg, application, numrows, pidsym, err_ptr)
      IGRlong     *msg;        /* Message                           (O) */
      IGRshort    application; /* Piping only                       (I) */
      short       *numrows;    /* Num of structures                 (O) */
      struct VRDbPidSymTbl  **pidsym; 
      IGRchar     *err_ptr;    /* Error message buffer              (O) */
{
  /*********************************************************************/
  /*                                                                   */
  /* This routine caches the PID table                                 */
  /*                                                                   */
  /*********************************************************************/       

  int		sts, i,j;
  struct VRrisdat      outdata[500];
  int           rows;
  int           cols;
  char		*table=NULL;		/* table name */
  char		*select=NULL;    	/* select list */
  char		search[MAX_WHERE_SIZE];		/* where clause of a select */
  char          ris_str[MAX_RIS_STR_SIZE];
  int           par_cnt;


  *pidsym = NULL;
	
  if ( application == VR_PIPING )
  {
      table = VRDB_PIDSYM_TBL;

#ifdef	MANAGE_IDS
       select = "comp_code, macro_name, id_category, id_behaviour";
#else
       select = "comp_code, macro_name";
#endif

      sprintf( ris_str,"SELECT %s FROM %s", select, table);
      sts = RISexecute_query( ris_str, outdata, &rows, &cols, &par_cnt);
      if (sts != 1 || rows == 0)
      {
         printf("Failed accessing %s for caching.\n",table);
         printf("SELECT <%s>\nFROM <%s>\n%s\n ", select, table, search);
         VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row","");
         *msg = VR_E_DbShortErrMsg;  
         return(OM_E_ABORT);
      }
      *pidsym = ( struct VRDbPidSymTbl *) _MALLOC ( rows, struct VRDbPidSymTbl );
      if(!(*pidsym))
      {
          printf("VRdbCachePidTbl: Cannot allocate memory for pidsym\n");
          *msg = VR_E_DbShortErrMsg;  
          return(OM_E_ABORT);
      }
      j = 0;
      for(i = 0; i < rows ; i++)
      {

#ifdef	MANAGE_IDS
	(*pidsym)[i].id_category = outdata[j+2].data.val.attr_int; 
	(*pidsym)[i].id_behaviour = outdata[j+3].data.val.attr_int; 
        j=j+4;
#else
        strcpy((*pidsym)[i].comp_code, outdata[j].data.val.attr_c);
        strcpy((*pidsym)[i].macro_name, outdata[j+1].data.val.attr_c);
	j=j+2;
#endif

      }
      *numrows = rows;
      return(OM_S_SUCCESS);
  }
  else
      return OM_E_INVARG;
}

/*----------------------------------------------------*/
IGRint VRdbGetPidSym ( 
      IGRlong     *msg,        /* Message                           (O) */
      IGRshort    application, /* Piping only                       (I) */
      IGRshort    free_flg,    /* flag to indicate to free buffers  (I) */
      IGRchar     *code,       /* component codes                   (I) */
      IGRchar     *macro,      /* macro names                       (O) */  
      IGRchar     *err_ptr     /* Error message buffer              (O) */
	)
{

  int		sts, i;

  if( free_flg )
  {
      if(DbPidSym) _FREE(DbPidSym);
      DbPidSymFirst = 1;
      return(OM_S_SUCCESS);
  }

  macro[0] = '\0';

  if(VdsRisAttach() != OM_S_SUCCESS) 
  {
       VRdb_err_msg(VR_E_RisInitFailed, err_ptr,NULL,NULL,NULL);
       *msg = VR_E_RisInitFailed;
       return(OM_E_ABORT);
  }


  if(DbPidSymFirst)
  {
    sts = VRdbCachePidTbl( msg,application,&DbPidArrNum,&DbPidSym,err_ptr);
    if (sts != 1 )
    {
       *msg = VR_E_DbShortErrMsg;  
       return(OM_E_ABORT);
    }
    DbPidSymFirst = 0;
  }
  for(i=0; i < DbPidArrNum; i++ )
  {
     if(strcmp(DbPidSym[i].comp_code, code ) == 0 )
     {
         strcpy(macro, DbPidSym[i].macro_name);
         break;
     }
  }

  return (OM_S_SUCCESS);

}



#ifdef	MANAGE_IDS

IGRint VRdbGetCompCat( msg, application, comp_code, 
					comp_cat, comp_behvr, err_ptr )

      IGRlong     *msg;        /* Message                           (O) */
      IGRshort    application; /* PIPING only                       (I) */
      IGRchar     *comp_code;  /* AABBCC code		            (I) */
      IGRint	  *comp_cat;   /* Comp Category			    (O) */
      IGRint	  *comp_behvr; /* Comp Behavior			    (O) */
      IGRchar     *err_ptr;    /* Error message buffer              (O) */
{
	int	sts, i;

	if(VdsRisAttach() != OM_S_SUCCESS) 
	{
       		VRdb_err_msg(VR_E_RisInitFailed, err_ptr,NULL,NULL,NULL);
		*msg = VR_E_RisInitFailed;
		return(OM_E_ABORT);
	}

	if(DbPidSymFirst)
	{
		sts = 
		VRdbCachePidTbl( msg,application,&DbPidArrNum,
				&DbPidSym,err_ptr);
		if (sts != 1 )
		{
			*msg = VR_E_DbShortErrMsg;  
       			return(OM_E_ABORT);
		}
		DbPidSymFirst = 0;
	}

	for(i=0; i < DbPidArrNum; i++ )
	{
		if(strcmp(DbPidSym[i].comp_code, comp_code ) == 0 )
		{
			if ( comp_cat) 
				*comp_cat =  DbPidSym[i].id_category;
			if ( comp_behvr )
				*comp_behvr =  DbPidSym[i].id_behaviour;
			break;
     		}
	}

	return (OM_S_SUCCESS);
}

#endif

#endif
