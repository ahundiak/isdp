
/* $Id: VRgnpdlst.c,v 1.1.1.1 2001/01/04 21:13:02 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpdu / VRgnpdlst.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRgnpdlst.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:02  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.2  1997/08/15  19:34:34  pinnacle
 * Replaced: vrpdu for:  by hverstee for route
 *
 * Revision 1.1  1996/04/22  15:01:54  pinnacle
 * Created: vrpdu/VRgnpdlst.c by hverstee for route240
 *
 * Revision 1.2  1996/01/17  17:30:56  pinnacle
 * Replaced: vrpdu/getnpdlst.c for:  by r240_int for route240
 *
 *
 * History:
 *	01/17/96   tlb		Add prototypes, 
 *				Change check_spec, VRget_npd_list to ANSII style
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

/*          REPLACED BY VRXnpdlist.I          */

#if   0


extern int	prj_units_set;

/*********************************************************/
/*     these externals controlled by VRdbCheckCacheIndx  */
int noz_npd_tblno;
int noz_eqvnpd_flag;
/*********************************************************/
/*     int noz_npd_flg;               NOT USED           */
/*********************************************************/

/**************************************************************/
/*   these static externals to be initialized at DB change    */
  static  double    npdlst[VR_MAX_NPDLIST_SIZE];
  static  double    zero_npdlst[VR_MAX_NPDLIST_SIZE];
  static  short     zero_npdlst_flag;
  static  short     old_zero_npdlstsize;    
  static  short     old_npdlstsize;    
  static  int       npdlst_prj_units;
/**************************************************************/
/*    clear cache function                                    */

void VR_DbC_Clnpd ()
{
  int     i;

  for (i=0; i<VR_MAX_NPDLIST_SIZE; i++)
  {
    npdlst[i]      = 0.0;
    zero_npdlst[i] = 0.0;
  }

  zero_npdlst_flag    = 0;
  old_zero_npdlstsize = 0;
  old_npdlstsize      = 0;
  npdlst_prj_units    = 0;

  return;
}
/**************************************************************/


/********************************************************************* 
 *                                                                   * 
 * This routine extracts the list of allowable npds when             * 
 * spec name is given.                                               * 
 *                                                                   * 
 *********************************************************************/
IGRint VRget_npd_list ( 
      IGRlong     *msg,        /* Message                           (O) */
      IGRshort    application, /* Piping only                       (I) */
      IGRchar     *specname,   /* Piping spec name (or "NOZZLE")    (I) */
      IGRshort    *listsize,   /* No of elements in npd list        (O) */
      IGRdouble   **npdlist,   /* List of allowable npds            (O) */
      IGRchar     *err_ptr     /* Error buffer                      (O) */
      )
{

  int		sts, i;
  struct VRrisdat      outdata[VR_MAX_NPDLIST_SIZE];
  int           rows;
  int           cols;
  int           par_cnt;
  char		*table=NULL;		/* table name */
  char		*select=NULL;    	/* select list */
  char		search[MAX_WHERE_SIZE];		/* where clause of a select */
  char		order[MAX_WHERE_SIZE];		/* order clause of a select */
  char          ris_str[MAX_RIS_STR_SIZE];
  int       npdlst_spec_units_set;
  int       npdlst_spec_units;
  int               EQ_flag=0;
  char              disp_err[100];
  IGRlong       sp_msg;
  int           proj_no;


  /* Initialize */
  *listsize = 0;

  if(VdsRisAttach() != OM_S_SUCCESS)
  {
     VRdb_err_msg(VR_E_RisInitFailed, err_ptr,NULL,NULL,NULL);
     *msg = VR_E_RisInitFailed;
     return(OM_E_ABORT);
  }
  
  /* Get project no */
  sts = VdsGetPrjNo( &proj_no);
  if(!sts)
  {
     *msg = VR_E_DbShortErrMsg;
     return(OM_E_ABORT);
  }

  VRdbCheckCacheIndx ( VRDB_PRJ_IDX1, &proj_no, (char *) NULL );

  if ( application == VR_PIPING )
  {
      
      sts = check_spec(&sp_msg, application, specname,err_ptr);
      if( sts == OM_E_ABORT) 
      {
        printf("Failed accessing speclist for check_spec()\n");
        *msg = sp_msg;
        return (OM_E_ABORT);
      }
      if(sts == 0) 
      {
         if(!zero_npdlst_flag)
         {

            table = VRDB_PIPNPDALL_TBL;
            select = "npd";
            sprintf( search, "WHERE tblno = 0");
	    sprintf(order,"ORDER by npd" );
 
            sprintf( ris_str,"SELECT %s FROM %s %s %s", select, table, search, order);
            sts = RISexecute_query( ris_str, outdata, &rows, &cols, &par_cnt);
            if (sts != 1 || rows == 0)
            {
               printf("Failed accessing %s for zero npdlist.\n",table);
               printf("SELECT <%s>\nFROM <%s>\n%s\n%s\n ", select, table, search,order);
               sprintf(disp_err,"%s","tblno 0");
               VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr, table,"Row", disp_err);
               *msg = VR_E_DbShortErrMsg;
               return(OM_E_ABORT);
            }

            for(i = 0; i < par_cnt && i < VR_MAX_NPDLIST_SIZE; i++)
            {
              zero_npdlst[i] = outdata[i].data.val.attr_dbl;
            }
            *npdlist = zero_npdlst;
            if ( par_cnt <= VR_MAX_NPDLIST_SIZE )
            {
              old_zero_npdlstsize = (short) par_cnt;
              *listsize = old_zero_npdlstsize;    

            }
            else
            {
              printf(" VRget_npd_list: Cache Overflow \n");
              *listsize = VR_MAX_NPDLIST_SIZE;    
              old_zero_npdlstsize = *listsize;
            }
            zero_npdlst_flag = 1;
            return OM_S_SUCCESS;
         }
         else
         {
            *npdlist = zero_npdlst;
            *listsize = old_zero_npdlstsize;
            return OM_S_SUCCESS;
         }
      }      

      if( !(sts = VRdbCheckCacheIndx( VRDB_NPD_IDX4, NULL, specname ) ))
      {
          *npdlist = npdlst;
          *listsize = old_npdlstsize; 
      }
      else
      {

           if( (strcmp( specname, "NOZZLE" ) == 0) ||
               (strcmp( specname, "nozzle" ) == 0)  )
           {

               if ( (sts = VRdbCheckCacheIndx( VRDB_NOZ_IDX3, NULL, (char *) NULL ) ))
               {
                 /* Access piping project to get the nozzle npd list data */

                 table = VRDB_PIPPROJ_TBL;
                 select = "noz_npd_tblno, noz_eqvnpd_flg";
                 sprintf( search, "WHERE prj_no = %d", proj_no);
 
                 sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );
                 sts = RISexecute_query( ris_str, outdata, &rows, &cols, &par_cnt);
                 if (sts != 1 || rows == 0)
                 {
                    printf("Failed accessing %s for nozzle npd data.\n",table);
                    printf("SELECT <%s>\nFROM <%s>\n%s\n ", select, table, search);
                    sprintf(disp_err,"%s","prj_no %d", proj_no);
                    VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr, table,"Row", disp_err);
                    *msg = VR_E_DbShortErrMsg;
                    return(OM_E_ABORT);
                 }
                 noz_npd_tblno = outdata[0].data.val.attr_int;
                 noz_eqvnpd_flag = outdata[1].data.val.attr_int;
               }

               table = VRDB_PIPNPDALL_TBL;
               select = "npd";
               sprintf( search, "WHERE tblno = %d", noz_npd_tblno);
	       sprintf( order, "ORDER by npd" );
           }
           else
           {
        
             /* Get the project units set to determine the units of npd */
             sts = VdsGetProjectUnits( &prj_units_set );
             if(!sts)
             {
               *msg = VR_E_DbShortErrMsg;
               return(OM_E_ABORT);
             }

             /* Get piping spec units set  */
             table  = VRDB_PIPSPEC_TBL;
             select = "units_set";
             sprintf( search, "WHERE spec_name = '%s' and prj_no = %d", specname, proj_no);
 
             sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );
             sts = RISexecute_query( ris_str, outdata, &rows, &cols, &par_cnt);
             if (sts != 1 || rows == 0)
             {
                printf("Failed accessing %s for spec_units_set.\n",table);
                printf("SELECT <%s>\nFROM <%s>\n%s\n ", select, table, search);
                sprintf(disp_err,"spec_name '%s',prj_no %d",specname,proj_no);
                VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr, table,"Row", disp_err);
                *msg = VR_E_DbShortErrMsg;
                return(OM_E_ABORT);
             }
             npdlst_spec_units_set = outdata[0].data.val.attr_int;

             if( prj_units_set == npdlst_spec_units_set )            
                   EQ_flag = 1;
             else
             {
                /* Check if the units of measure match */

                if( (sts = VRdbCheckCacheIndx( VRDB_NPD_IDX5, NULL, (char *) NULL) ) )
                {
                   /* Find units of measure for "npd_g" from VDS_UNITS */

                   table = VRDB_VDSUNITS_TBL;
                   select = "units_code";
                   sprintf( search, "WHERE param_name = 'npd_g' and units_set = %d", prj_units_set);
 
                   sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );
                   sts = RISexecute_query( ris_str, outdata, &rows, &cols, &par_cnt);
                   if (sts != 1 || rows == 0)
                   {
                       printf("Failed accessing %s for units_code.\n",table);
                       printf("SELECT <%s>\nFROM <%s>\n%s\n ", select, table, search);
                       sprintf(disp_err,"param_name '%s',units_set %d","npd_g",prj_units_set);
                       VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr, table,"Row", disp_err);
                       *msg = VR_E_DbShortErrMsg;
                       return(OM_E_ABORT);
                   }
                   npdlst_prj_units = outdata[0].data.val.attr_int;
                }
         
            
                /* Find units of measure for "npd_g" from VDS_UNITS */

                table = VRDB_VDSUNITS_TBL;
                select = "units_code";
                sprintf( search, "WHERE param_name = 'npd_g' and units_set = %d", npdlst_spec_units_set);
 
                sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );
                sts = RISexecute_query( ris_str, outdata, &rows, &cols, &par_cnt);
                if (sts != 1 || rows == 0)
                {
                  printf("Failed accessing %s for units_code.\n",table);
                  printf("SELECT <%s>\nFROM <%s>\n%s\n ", select, table, search);
                  sprintf(disp_err,"param_name '%s',units_set %d","npd_g",npdlst_spec_units_set);
                  VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr, table,"Row", disp_err);
                  *msg = VR_E_DbShortErrMsg;
                  return(OM_E_ABORT);
                }
                npdlst_spec_units = outdata[0].data.val.attr_int;

                if( npdlst_prj_units == npdlst_spec_units )            
                     EQ_flag = 1;
             }

             if( EQ_flag == 1 )
             {
                    
                table = VRDB_PIPNPDALL_TBL;
                select = "npd";
                sprintf( search, "WHERE tblno in (select npd_tblno from piping_spec where spec_name = '%s' and prj_no = %d)", specname, proj_no);
	        sprintf( order, "ORDER by npd" );
             }          
             else
             {
                table = VRDB_PIPNPDALL_TBL;
                select =  "npd_equiv";
                sprintf( search, "WHERE tblno in (select npd_tblno from piping_spec where spec_name = '%s' and prj_no = %d)", specname, proj_no);
	        sprintf( order, "ORDER by npd_equiv" );
             }
           }
           sprintf( ris_str,"SELECT %s FROM %s %s %s", select, table, search, order );
           sts = RISexecute_query( ris_str, outdata, &rows, &cols, &par_cnt);
           if (sts != 1 || rows == 0)
           {
             printf("Failed accessing %s for npdlist.\n",table);
             printf("SELECT <%s>\nFROM <%s>\n%s\n%s\n ", select, table, search,order);
             sprintf(disp_err,"spec_name '%s',prj_no %d",specname, proj_no);
             VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr, table,"Row", disp_err);
             *msg = VR_E_DbShortErrMsg;
             return(OM_E_ABORT);
           }
           for(i = 0; i < par_cnt && i < VR_MAX_NPDLIST_SIZE; i++)
           {
              npdlst[i] = outdata[i].data.val.attr_dbl;
           }
           *npdlist = npdlst;
           if ( par_cnt <= VR_MAX_NPDLIST_SIZE )
           {
             old_npdlstsize = (short) par_cnt;
             *listsize = old_npdlstsize;    

           }
           else
           {
             printf(" VRget_npd_list: Cache Overflow \n");
             *listsize = VR_MAX_NPDLIST_SIZE;    
             old_npdlstsize = *listsize;
           }
      }
      *msg = ACC_S_SUCCESS;
      return OM_S_SUCCESS;
  }
  else
      return OM_E_INVARG;
}


/*------------------------------------------------------------------*/
IGRint check_spec( 	IGRlong   *msg,
			IGRshort  app,
			IGRchar   *spec,
			IGRchar   *err_ptr)
{
   
     IGRint   ret_code, i,j;
     IGRshort size;
     IGRchar  *list;
     IGRchar  tmp[20];
     IGRlong  sp_msg; 

#ifdef DEBUG 
    printf("check_spec: spec name %s\n",spec);
#endif
     if ( (strcmp (spec, "nozzle")==0) || (strcmp (spec, "NOZZLE") == 0) )
        return 1;
     if( spec[0] == 0 || (strcmp(spec, " " ) == 0) )
         return 0;
     ret_code = VRget_spec_list(&sp_msg, app,&size, &list, err_ptr);
     if(ret_code == OM_S_SUCCESS)
     {
        for(i=0,j=0;;i++)
        {
          if (j==size)break;
          if (list [i]) 
          {
            strcpy(tmp,  &list[i]);       
            if(strcmp(tmp, spec ) == 0 )
              return 1;
            i += strlen (&list[i]) - 1;
            j++;    
          }
        }
  
     }
     if(ret_code == OM_E_ABORT)
     {
       *msg = sp_msg;
       return (ret_code);
     }
     *msg = ACC_S_SUCCESS;
     return 0;

}
       

#endif
