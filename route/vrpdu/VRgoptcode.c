
/* $Id: VRgoptcode.c,v 1.1.1.1 2001/01/04 21:13:02 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpdu / VRgoptcode.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRgoptcode.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:02  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.2  1997/08/15  19:34:34  pinnacle
 * Replaced: vrpdu for:  by hverstee for route
 *
 * Revision 1.1  1996/04/22  15:02:18  pinnacle
 * Created: vrpdu/VRgoptcode.c by hverstee for route240
 *
 * Revision 1.3  1996/02/07  10:06:38  pinnacle
 * Replaced: vrpdu/getoptcode.c for:  by ashankar for route240
 *
 * Revision 1.2  1996/01/17  17:30:38  pinnacle
 * Replaced: vrpdu/getoptcode.c for:  by r240_int for route240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	01/17/96   tlb		Add prototypes
 *				Change VRget_opt_code_txt to ANSII style
 *
 *************************************************************************/
#include <stdio.h>
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "VRdef.h"
#include "VRDbStruct.h"
#include "dberror.h"
#include "VRmsg.h"
#include "VRDbTbl.h"
#include "VRDbCache.h"
#include "vrpdu_pto.h"

/*          REPLACED BY VRXoptcode.I          */

#if   0


extern int	prj_units_set;
extern int	pip_spec_units;

#define VR_OPTCODE_LIST_NUM  400
#define VR_MAX_OPTCODE_SIZE  30

/*   no cache, refilled at each call     */
static
short         VROptCodes[VR_MAX_OPTCODE_SIZE];

/*********************************************************************/
/*                                                                   */
/* This routine extracts the list of possible option codes and       */
/* code texts for given component.                                   */
/*                                                                   */
/*********************************************************************/       
IGRint VRget_opt_code_txt ( 
      IGRlong     *msg,        /* Message                           (O) */
      IGRshort    application, /* Piping only                       (I) */
      IGRchar     *comp_code,  /* Piping component code             (I) */
      IGRchar     *specname,   /* Piping spec name                  (I) */
      IGRdouble   size_g,      /* green dia                         (I) */
      IGRdouble   size_r,      /* red dia                           (I) */
      IGRshort    **opt_codes, /* code numbers                      (O) */
      IGRchar     **opt_txt,   /* code text                         (O) */
      IGRshort    *opt_cnt,    /* number of optcodes                (O) */
      IGRchar     *err_ptr     /* Error message buffer              (O) */
	)
{

  int		sts, i;
  struct VRrisdat      outdata[VR_MAX_OPTCODE_SIZE];
  int           rows;
  int           cols;
  char		*table=NULL;		/* table name */
  char		*select=NULL;    	/* select list */
  char		search[MAX_WHERE_SIZE];		/* where clause of a select */
  char          ris_str[MAX_RIS_STR_SIZE];
  int           par_cnt;
  char          disp_err[100];
  double  	SIZE_1, SIZE_2;
  int           proj_no;

   /* Initialize */

   *opt_cnt = 0;

   if(VdsRisAttach() != OM_S_SUCCESS) 
   {
       VRdb_err_msg(VR_E_RisInitFailed, err_ptr,NULL,NULL,NULL);
       *msg = VR_E_RisInitFailed;
       return(OM_E_ABORT);
   }

   UI_status("Processing          ");


  if ( application == VR_PIPING )
  {
      sts = VdsGetPrjNo( &proj_no );
      if(!sts)
      {
         *msg = VR_E_DbShortErrMsg;
         return (OM_E_ABORT);
      }
      VRdbCheckCacheIndx ( VRDB_PRJ_IDX1, &proj_no, (char *) NULL );
      sts = VdsGetProjectUnits( &prj_units_set );
      if(!sts)
      {
         *msg = VR_E_DbShortErrMsg;
         return (OM_E_ABORT);
      }
      sts = Get_piping_spec_units( proj_no, specname,err_ptr);
      if(sts != 1)
      {
           *msg = VR_E_DbShortErrMsg;
           return (OM_E_ABORT);
      }

      if( prj_units_set != pip_spec_units )
      {
	  SIZE_1 = get_allowed_npd(prj_units_set,pip_spec_units,size_g,
                                   specname,proj_no,err_ptr);
	  SIZE_2 = get_allowed_npd(prj_units_set,pip_spec_units,size_r,
                                   specname,proj_no,err_ptr);      
      }
      else
      {
	SIZE_1 = size_g;
	SIZE_2 = size_r;
      }
       
      table = VRDB_PIPCOMPS_TBL;
      select = "opt_code";
      if ( SIZE_1 == SIZE_2 || SIZE_2 == 0)
      {
       sprintf( search, "WHERE comp_code = '%s' and size_g_low <= %f and size_g_high >= %f and spec_no in ( select spec_no from piping_spec where spec_name = '%s'and prj_no = %d)",comp_code,SIZE_1, SIZE_1, specname, proj_no );
       sprintf(disp_err,"comp_code '%s',size_g %f,spec_name '%s',prj_no %d", comp_code,SIZE_1, specname, proj_no);
      }
      else
      {
       sprintf( search, "WHERE comp_code = '%s' and size_g_low <= %f and size_g_high >= %f and size_r_low <= %f and size_r_high >= %f and spec_no in ( select spec_no from piping_spec where spec_name = '%s' and prj_no = %d)",comp_code, SIZE_1, SIZE_1, SIZE_2, SIZE_2, specname, proj_no );
       sprintf(disp_err,"comp_code '%s',size_g %f,size_r %f,spec_name '%s',prj_no %d", comp_code,SIZE_1,SIZE_2,specname,proj_no);
      }

      sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );
      sts = RISexecute_query( ris_str, outdata, &rows, &cols, &par_cnt);
      if (sts != 1 || rows == 0)
      {
         VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
         *msg = VR_E_DbShortErrMsg;  
         return(OM_E_ABORT);
      }


      for(i = 0; i < par_cnt && i < VR_MAX_OPTCODE_SIZE; i++)
      {
		VROptCodes[i] = outdata[i].data.val.attr_int;
      }
      if ( par_cnt <= VR_MAX_OPTCODE_SIZE )
          *opt_cnt = par_cnt;
      else
      {
          printf(" VRget_opt_code_txt: Cache Overflow \n");
          *opt_cnt = VR_MAX_OPTCODE_SIZE;    
      }

      *opt_codes = VROptCodes;
      *opt_txt = (char *)NULL;
      return OM_S_SUCCESS ;

  }
  else
      return OM_E_INVARG;
}


#endif
