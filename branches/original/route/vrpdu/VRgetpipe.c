
/* $Id: VRgetpipe.c,v 1.1.1.1 2001/01/04 21:13:01 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpdu / VRgetpipe.c
 *
 * Description:
 *	Access VDS database for piping component codes    
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRgetpipe.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.2  1997/08/15  19:34:34  pinnacle
 * Replaced: vrpdu for:  by hverstee for route
 *
 * Revision 1.1  1996/04/22  15:02:32  pinnacle
 * Created: vrpdu/VRgetpipe.c by hverstee for route240
 *
 * Revision 1.2  1996/01/17  17:31:58  pinnacle
 * Replaced: vrpdu/getpipe.c for:  by r240_int for route240
 *
 *
 * History:
 *	01/17/96   tlb	Add prototypes
 *
 *************************************************************************/

#include         <stdio.h>
#include         <stdlib.h>
#include         "igrtypedef.h"
#include         "ACattrib.h"
#include         "ACrg_collect.h"
#include         "VRDbStruct.h"
#include         "VRmsg.h"
#include         "VRDbTbl.h"
#include         "VRDbCache.h"

#include 	"vrpdu_pto.h"

#if 0

struct brtable
       {
          int     prj_no;
          char    spec_name[10];
          double  hdr_size;
          double  br_size;
          double  br_angle;
          char    comp_code[10];
       };

struct adpt_table
       { 
          int     prj_no;
          char    spec_name[10];
          int     gprep_1;
          int     gprep_2;
          char    comp_code[10];
       };

/**************************************************************/
/*   these static externals to be initialized at DB change    */
static int    curr_br_tab_size = 0;
static int    slot_num = 0;
static struct brtable br_tab[MAX_BR_TABLE_SIZE];
static int    curr_adpt_tab_size=0;
static int    adpt_slot_num=0;
static struct adpt_table adpt_tab[MAX_ADPT_TABLE_SIZE]; 
/**************************************************************/
/*    clear cache function                                    */

void VR_DbC_Cltab ()
{
  int      i;

  curr_br_tab_size = 0;
  slot_num         = 0;

  for (i=0; i<MAX_BR_TABLE_SIZE; i++)
  {
    br_tab[i].prj_no             = 0;
    br_tab[i].hdr_size           = 0;
    br_tab[i].br_size            = 0;
    br_tab[i].br_angle           = 0;
    br_tab[i].spec_name[0]       = '\0';
    br_tab[i].comp_code[0]       = '\0';
  }

  curr_adpt_tab_size = 0;
  adpt_slot_num      = 0;

  for (i=0; i<MAX_ADPT_TABLE_SIZE; i++)
  {
    adpt_tab[i].prj_no             = 0;
    adpt_tab[i].gprep_1            = 0;
    adpt_tab[i].gprep_2            = 0;
    adpt_tab[i].spec_name[0]       = '\0';
    adpt_tab[i].comp_code[0]       = '\0';
  }

  return;
}
/**************************************************************/
 
int get_piping_br_comp_code (char    *spec_name,/* spec name                 */
                             double   siz_1,    /* npd 1 - green dia         */
                             double   siz_2,    /* npd 2 - red dia           */
                             double   angle,    /* branch angle              */
                             char    *comp_code,/* AABBCC code of the branch */
                             char    *err_ptr)  /* Error Message buffer      */

{
/***************************************************************************/
/*                                                                         */
/* This routine extracts the AABBCC code of the branch whose spec name     */
/* size 1, size 2 and angle have been specified.                           */
/*                                                                         */
/***************************************************************************/

  int		sts, i;
  struct VRrisdat       outdata[MAX_RIS_QUERY_PAR];
  int           rows;
  int           cols;
  int           par_cnt;
  char		*table=NULL;		/* table name */
  char		*select=NULL;    	/* select list */
  char		search[MAX_WHERE_SIZE];		/* where clause of a select */
  char          ris_str[MAX_RIS_STR_SIZE];
  char          disp_err[100];     
  int           proj_no;


     /* Get the project no */

     sts = VdsGetPrjNo( &proj_no );
     if( sts != 1)
        return(0);

     VRdbCheckCacheIndx ( VRDB_PRJ_IDX1, &proj_no, (char *) NULL );

     /* IF IN CACHE */
     /*-------------*/
     for(i = 0; i < curr_br_tab_size; ++i)
     {
        if( proj_no == br_tab[i].prj_no                 &&
            strcmp(spec_name, br_tab[i].spec_name) == 0 &&
            siz_1 == br_tab[i].hdr_size                 &&
            siz_2 == br_tab[i].br_size                  &&
            angle == br_tab[i].br_angle)
        {
#ifdef DEBUG
printf(" Retrieving from cache\n");
#endif
          strcpy(comp_code, br_tab[i].comp_code);
          return (1);
        }
     }
     /* GET THE COMP CODE FROM PIPING BR SELECT TABLE */
     /*-----------------------------------------------*/
#ifdef DEBUG
printf(" Accessing piping br table\n");
#endif
     table = VRDB_PIPBRSEL_TBL;
     select =  "*";
     sprintf( search, "WHERE npd_high = %lf and npd_low = %lf and %lf between angle_low and angle_high and tblno in (select branch_tblno from piping_spec where spec_name = '%s' and prj_no = %d)",siz_1,siz_2,angle,spec_name,proj_no );
     sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );

     sts = RISexecute_query( ris_str, outdata,&rows,&cols,&par_cnt);
     if (sts != 1 || rows == 0)
     {
        printf("Failed accessing piping br select.\n");
        printf("SELECT <%s>\nFROM <%s>\n%s\n ", select, table, search);
        sprintf(disp_err,"npd_high %f,npd_low %f,angle %f,spec_name '%s',prj_no %d",
                          siz_1,siz_2,angle,spec_name, proj_no);
        VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
        return(0);
     }

     /* CACHE THE EXTRACTED ROW */
     /*-------------------------*/
#ifdef DEBUG
printf(" Current br tab size:%d\n",curr_br_tab_size);
#endif
     if(curr_br_tab_size <= MAX_BR_TABLE_SIZE - 1)
     {
       br_tab[curr_br_tab_size].prj_no = proj_no;
       strcpy(br_tab[curr_br_tab_size].spec_name, spec_name);
       br_tab[curr_br_tab_size].hdr_size = outdata[1].data.val.attr_dbl;
       br_tab[curr_br_tab_size].br_size = outdata[2].data.val.attr_dbl;  
       br_tab[curr_br_tab_size].br_angle = angle;
       strcpy (br_tab[curr_br_tab_size].comp_code, outdata[6].data.val.attr_c);
       curr_br_tab_size++;
     }
     else
     {
       if( slot_num > MAX_BR_TABLE_SIZE - 1)
       {
         slot_num = 0;
       }
#ifdef DEBUG
printf(" Current slot_num:%d\n",slot_num);
#endif
       br_tab[slot_num].prj_no = proj_no;
       strcpy(br_tab[slot_num].spec_name, spec_name);
       br_tab[slot_num].hdr_size = outdata[1].data.val.attr_dbl;
       br_tab[slot_num].br_size = outdata[2].data.val.attr_dbl;  
       br_tab[slot_num].br_angle = angle;
       strcpy (br_tab[slot_num].comp_code, outdata[6].data.val.attr_c);
       slot_num++;
     } 
     strcpy(comp_code, outdata[6].data.val.attr_c);
     return(1);
}


int get_adapter (char   *spec_name,  /* spec name              */
                 int     prep_1,     /* first end prep         */
                 int     prep_2,     /* second end prep        */
                 char   *comp_code,  /* AABBCC code of adapter */
                 char   *err_ptr)    /* Error message buffer   */

{
/**************************************************************************/
/*                                                                        */
/* This routine extracts default adapter AABBCC code for piping from      */
/* reference database.                                                    */
/*                                                                        */
/**************************************************************************/

  int		sts, tmp, i;
  struct VRrisdat        outdata[MAX_RIS_QUERY_PAR];
  int           rows;
  int           cols;
  int           par_cnt;
  char		*table=NULL;		/* table name */
  char		*select=NULL;    	/* select list */
  char		search[MAX_WHERE_SIZE];		/* where clause of a select */
  char          ris_str[MAX_RIS_STR_SIZE];
  char          disp_err[100];
  int           proj_no;

     /* Get the project no */

     sts = VdsGetPrjNo( &proj_no );
     if( sts != 1)
       return(0);
    
     VRdbCheckCacheIndx ( VRDB_PRJ_IDX1, &proj_no, (char *) NULL );
     
     /* Switch end preps if prep_2 < prep_1 */
     if ( prep_1 > prep_2 )
     {
       tmp = prep_1;
       prep_1 = prep_2; 
       prep_2 = tmp;
     }
     /* Convert end preps into generic termination types */
     /* always round down to nearest multiple of 10      */

       prep_1 = (prep_1/10)*10;
       prep_2 = (prep_2/10)*10;


     /* IF IN CACHE  */
     /*--------------*/
     for (i=0; i< curr_adpt_tab_size; i++)
     {
        if( proj_no == adpt_tab[i].prj_no                 &&
            strcmp(spec_name, adpt_tab[i].spec_name) == 0 &&
            prep_1 == adpt_tab[i].gprep_1                 &&
            prep_2 == adpt_tab[i].gprep_2 )
        {
#ifdef DEBUG
printf(" Retrieving from cache\n");
#endif
          strcpy(comp_code, adpt_tab[i].comp_code);
          return (1);
        }
     }

     /* GET COMPCODE FROM PIPING ADPT SELECT TABLE */
     /*--------------------------------------------*/
#ifdef DEBUG
printf(" Accessing piping adpt select table\n");
#endif
       table = VRDB_PIPADPTSEL_TBL;
       select = "comp_code";
       sprintf( search, "WHERE gprep_1 = %d and gprep_2 = %d and tblno in (select adaptr_tblno from piping_spec where spec_name = '%s' and prj_no = %d)",prep_1, prep_2,spec_name,proj_no );
       sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );

       sts = RISexecute_query( ris_str, outdata,&rows,&cols,&par_cnt);
       if (sts != 1)
       {
         printf("Failed accessing piping adpt select.\n");
         printf("SELECT <%s>\nFROM <%s>\n%s\n ", select, table, search);
         sprintf(disp_err,"gprep_1 %d,gprep_2 %d,spec_name '%s',prj_no %d",spec_name, proj_no);
         VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
         return(0);
       }
       if(rows == 0 )
       {
           comp_code[0] = 0;
           return(1);
       }

       /* CACHE THE EXTRACTED ROW  */
       /*--------------------------*/
       if (curr_adpt_tab_size <=  MAX_ADPT_TABLE_SIZE - 1)
       {
          adpt_tab[curr_adpt_tab_size].prj_no = proj_no;
          strcpy(adpt_tab[curr_adpt_tab_size].spec_name,spec_name);
          adpt_tab[curr_adpt_tab_size].gprep_1 = prep_1;
          adpt_tab[curr_adpt_tab_size].gprep_2 = prep_2;
          strcpy(adpt_tab[curr_adpt_tab_size].comp_code,outdata[0].data.val.attr_c);          
          curr_adpt_tab_size++;
       }
       else
       {
         if( adpt_slot_num > MAX_ADPT_TABLE_SIZE -1)
         {
            adpt_slot_num = 0;
         }
#ifdef DEBUG
printf(" Current slot_num:%d\n",adpt_slot_num);
#endif
          adpt_tab[adpt_slot_num].prj_no = proj_no;
          strcpy(adpt_tab[adpt_slot_num].spec_name,spec_name);
          adpt_tab[adpt_slot_num].gprep_1 = prep_1;
          adpt_tab[adpt_slot_num].gprep_2 = prep_2;
          strcpy(adpt_tab[adpt_slot_num].comp_code,outdata[0].data.val.attr_c);          
          adpt_slot_num++;
       }
       strcpy(comp_code, outdata[0].data.val.attr_c);
       return(1);
}

#endif

