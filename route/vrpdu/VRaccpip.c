/* $Id: VRaccpip.c,v 1.2 2002/04/15 20:01:46 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpdu / VRaccpip.c
 *
 * Description:
 *	Access VDS database for piping parameters             
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRaccpip.c,v $
 *	Revision 1.2  2002/04/15 20:01:46  anand
 *	Removed version.h and associated dependencies. version.h is
 *	an include file in $EXNUC.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.2  1997/08/15  19:34:34  pinnacle
 * Replaced: vrpdu for:  by hverstee for route
 *
 * Revision 1.1  1996/04/22  14:59:32  pinnacle
 * Created: vrpdu/VRaccpip.c by hverstee for route240
 *
 * Revision 1.5  1996/04/10  22:15:16  pinnacle
 * Replaced: vrpdu/accpip.c for:  by hverstee for route240
 *
 * Revision 1.3  1996/01/17  17:31:36  pinnacle
 * Replaced: vrpdu/accpip.c for:  by r240_int for route240
 *
 *
 * History:
 *	01/17/96   tlb	Add prototypes
 *
 *************************************************************************/

#include	<stdio.h>
#include        <stdlib.h>
#include        <ctype.h>
#include 	"vrpdu_pto.h"
#include        "ACattrib.h"
#include        "dberror.h"
#include        "VRDbParamDef.h"
#include        "VRDbStruct.h"
#include        "VRmsg.h"
#include        "VRDbTbl.h"
#include        "VRDbCache.h"

#include        "VRPDBdef.h"

extern	      UI_status();
#define   VERSION   "2.0.0"

/*
#define MY_DEBUG
*/

#if 0

extern int 	prj_units_set;
extern int	pip_spec_units;

/**************************************************************/
/*   these static externals to be initialized at DB change    */
static
struct pip_spec  VRPIP_SPEC[MAX_PIP_SPEC_TABS];
static int	 spec_cnt;
/**************************************************************/
/*    clear cache function                                    */

void VR_DbC_Clpip ()
{
  int   i;

  for (i=0; i<MAX_PIP_SPEC_TABS; i++)
  {
     VRPIP_SPEC[i].spec_name[0] = '\0';
     VRPIP_SPEC[i].prj_no       = 0;
     VRPIP_SPEC[i].gask_sep     = 0;
     VRPIP_SPEC[i].units_set    = 0;
     VRPIP_SPEC[i].spec_no      = 0;
  }

  spec_cnt = 0;

  return;
}
/**************************************************************/

int access_piping ( name,compname, siz_1, siz_2, option,
                    fam_name, partnum, topology, type, 
                    comp_numcp, comp_seccp, mac_pm, pm_no, err_ptr)

  char		*name;       /*  spec name                          (I)   */
  char          *compname;   /*  AABBCC code of the component       (I)   */
  double        siz_1;       /*  Green diameter of component        (I)   */
  double        siz_2;       /*  Red diameter of component          (I)   */
  short         option;      /*  option code                        (I)   */
  char          *fam_name;   /*  family  or macro name              (O)   */
  char		*partnum;    /*  Part number of the component       (O)   */
  short         *topology;   /*  Component topology                 (O)   */
  short         *type;       /*  Component reporting category       (O)   */
  int           *comp_numcp; /*  Number of connect points           (O)   */
  int           *comp_seccp; /*  Red connect point identifier       (O)   */
  struct ACrg_coll mac_pm[]; /*  macro parameters                   (O)   */
  int		*pm_no;	     /*  Number of params in mac_pm         (O)   */
  char          *err_ptr;    /*  error message buffer               (O)   */
 {
  /************************************************************************/
  /*                                                                      */
  /* This routine extracts family name, part number, topology and         */
  /* reporting category of the component from the Spec database           */
  /*                                                                      */
  /* Algoritm :                                                           */
  /*          1)Access PIPING_SPEC table with spec_name and prj_no        */
  /*            to extract SPEC_NO and GASK_SEP                           */ 
  /*          2)Access PIPING_COMPS table with spec_no, comp_name,        */
  /*            sizes and option code to extract a component record.      */
  /*          3)Access PIPING_COMMOD_CODE table with part no. prefix,     */
  /*            sizes and, optionally sch thk, to extract PDM_PART_NUM.   */
  /*          4)Access PIPING_COMP_TYPE table with comp_code to extract   */
  /*            COMP_TOPO and COMP_CAT.                                   */
  /*                                                                      */
  /*  Routines :                                                          */
  /*              RISexecute_query                                        */
  /*              extract_num                                             */
  /*                                                                      */
  /************************************************************************/
  
  int		        sts, i;
  struct VRrisdat 	outdata[MAX_RIS_QUERY_PAR];
  struct VRrisdat       opt_data[10];       /* optional buffer */
  int           rows;                       /* no. of rows     */
  int           cols;                       /* no. of columns  */
  int           par_cnt;                    /* no. of params   */
  char		*table=NULL;		/* table name */
  char		*select=NULL;    	/* select list */
  char		search[MAX_WHERE_SIZE];		/* where clause of a select */
  char		pr_search[MAX_WHERE_SIZE];
  char          ris_str[MAX_RIS_STR_SIZE];
  char		number[MAX_ATTR_LEN]; 
  char          thk1[MAX_ATTR_LEN];		/* sched thk */
  char          thk2[MAX_ATTR_LEN];
  char          thk_match[MAX_ATTR_LEN];        /* MATCH sched thk value */
  char          short_code[MAX_ATTR_LEN];       /* Short code */
  int           flag;                           /* Flag */
  char          tmp1[MAX_ATTR_LEN];
  int           spec_no, prep_g, prep_r, end_std_g, end_std_r, cnt;
  int 		thick_units;
  double        range_1, range_2, gask_sep;                          
  double	SIZE_1, SIZE_2;
  char		buffer[10][20];
  int		in_cache;
  int           comp_count;
  char          disp_err[100];
  int           proj_no;
  int           iLENN1,iLENN2;

  extern int VdsRisSelect();
  extern int VdsRisFreeBuffer();

  /* security init, get rid of warnings  */

  spec_no = 0;
  range_1 = range_2 = gask_sep = 0.0;

#ifdef MY_DEBUG
printf("  access_piping of version: %s\n", VERSION);
#endif

    /* Get project no */

     sts = VdsGetPrjNo( &proj_no );
     if( sts != 1)
        return(0);
     VRdbCheckCacheIndx ( VRDB_PRJ_IDX1, &proj_no, (char *) NULL );

    /* GET THE SPEC NO AND GASK SEP FROM PIPING SPEC TABLE */
    /*-----------------------------------------------------*/

	in_cache = 0;
	for( i = 0; i < spec_cnt; i++ )
	{
		if((!strcmp(VRPIP_SPEC[i].spec_name, name)) &&
				(VRPIP_SPEC[i].prj_no == proj_no))
		{
		    spec_no = VRPIP_SPEC[i].spec_no;
		    pip_spec_units = VRPIP_SPEC[i].units_set;
		    gask_sep = VRPIP_SPEC[i].gask_sep;
		    in_cache = 1;
		}
	}

	if(!in_cache)
	{
    		table = VRDB_PIPSPEC_TBL;
    		select = "spec_no,gask_sep,units_set";
    		sprintf( search, "WHERE %s = '%s' and prj_no = %d", "spec_name", name, proj_no);
    		sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );

      		sts = RISexecute_query( ris_str,outdata,&rows,&cols, &par_cnt);
      		if (sts != 1 || rows == 0)
      		{
       		    printf("Failed accessing piping spec.\n");
       		    printf("SELECT <%s>\nFROM <%s>\n%s\n ", select, table, search);
                    sprintf(disp_err,"spec_name '%s',prj_no %d", name,proj_no);
                    VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
       		    return( ACC_E_PIPING_SPEC );
      		}
		spec_no = outdata[0].data.val.attr_int;
		gask_sep = outdata[1].data.val.attr_dbl;
		pip_spec_units = outdata[2].data.val.attr_int;
   
                if(spec_cnt == MAX_PIP_SPEC_TABS)
                   spec_cnt = 0;
		strcpy(VRPIP_SPEC[spec_cnt].spec_name, name);
		VRPIP_SPEC[spec_cnt].prj_no = proj_no;
		VRPIP_SPEC[spec_cnt].spec_no = spec_no;
		VRPIP_SPEC[spec_cnt].gask_sep = gask_sep;
		VRPIP_SPEC[spec_cnt].units_set = pip_spec_units;
		spec_cnt++;
	}

#ifdef MY_DEBUG
printf("  Fetching parameters from VRrisdat structure\n");
#endif

    /* Convert the npd_units so that the access is dictated by the SPEC units */


    if( prj_units_set != pip_spec_units ) 
    {
	SIZE_1 = get_allowed_npd( prj_units_set,pip_spec_units,siz_1,name,
                                  proj_no,err_ptr);
	SIZE_2 = get_allowed_npd( prj_units_set,pip_spec_units, siz_2,name,
                                  proj_no,err_ptr);
    }
    else
    {
	SIZE_1 = siz_1;
	SIZE_2 = siz_2;
    }

    UI_status("Processing.         ");


    /* Copy gasket seperation into the mac_pm structure */

    strcpy(mac_pm[*pm_no].name,VR_N_GASK_SEP_DB);
    mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
    if( prj_units_set != pip_spec_units )
	mac_pm[*pm_no].desc.value.att_exp =converted_to_vds(mac_pm[*pm_no].name,pip_spec_units,prj_units_set,gask_sep,err_ptr); 
    else
    	mac_pm[*pm_no].desc.value.att_exp = gask_sep;
    *pm_no += 1;     
    

    /* ACCESS PIPING COMPS TABLE */
    /*---------------------------*/

#ifdef MY_DEBUG
printf("  Accessing PIPING_COMPS\n");
#endif

    table = VRDB_PIPCOMPS_TBL;
    select =  "*";
    if((SIZE_1 == SIZE_2) || (SIZE_2 == 0))
    {
    	sprintf( search, " WHERE spec_no = ? and comp_code = ? and size_g_low <= ? and size_g_high >= ? and size_r_low <= ? and size_r_high >= ? and opt_code = ?");
	sprintf( pr_search, " WHERE spec_no = %d and comp_code = '%s' and size_g_low <= %lf and size_g_high >= %lf and size_r_low <= 0.0 and size_r_high >= 0.0 and opt_code = %d", spec_no, compname, SIZE_1, SIZE_1, option);
	sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );
	sprintf(buffer[0],"%d",spec_no);
	sprintf(buffer[1],"%s",compname);
	sprintf(buffer[2],"%lf",SIZE_1);
	sprintf(buffer[3],"%lf",SIZE_1);
	sprintf(buffer[4],"%lf",0.0);
	sprintf(buffer[5],"%lf",0.0);
	sprintf(buffer[6],"%d",option);

        sprintf(disp_err, "spec_no %d,comp_code '%s',size %f,opt_code %d",
                                spec_no,compname,SIZE_1,option);
	sts = RISprepare_query(ris_str, PIP_COMPS1_PREP_ID2 );
        if(sts != 1 )
        {
           printf("Error in preparing query for PIPING_COMPS :%d\n",PIP_COMPS1_PREP_ID2);
           printf("%s\n", ris_str );
           VRdb_err_msg(VR_E_DbErrPrepQuery,err_ptr,NULL,NULL,NULL);
           return(0);
        }
        
	sts = RISexecute_query1( PIP_COMPS1_PREP_ID2, buffer,7,outdata, &rows, &cols, &par_cnt);
    }
    else
    {
	sprintf( search, " WHERE spec_no = ? and comp_code = ? and size_g_low <= ? and size_g_high >= ? and size_r_low <= ? and size_r_high >= ? and opt_code = ?");
	sprintf( pr_search, " WHERE spec_no = %d and comp_code = '%s' and size_g_low <= %lf and size_g_high >= %lf and size_r_low <= %lf and size_r_high >= %lf and opt_code = %d",spec_no, compname, SIZE_1, SIZE_1, SIZE_2, SIZE_2, option);
        sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );

	sprintf(buffer[0],"%d",spec_no);
	sprintf(buffer[1],"%s",compname);
	sprintf(buffer[2],"%lf",SIZE_1);
	sprintf(buffer[3],"%lf",SIZE_1);
	sprintf(buffer[4],"%lf",SIZE_2);
	sprintf(buffer[5],"%lf",SIZE_2);
	sprintf(buffer[6],"%d",option);

        sprintf(disp_err, "spec_no %d,comp_code '%s',size_g %f,size_r %f,opt_code %d",
                           spec_no, compname, SIZE_1, SIZE_2, option);

	sts = RISprepare_query(ris_str, PIP_COMPS1_PREP_ID2 );
        if(sts != 1 )
        {
           printf("Error in preparing query for PIPING_COMPS :%d\n",PIP_COMPS1_PREP_ID2);
           printf("%s\n", ris_str );
           VRdb_err_msg(VR_E_DbErrPrepQuery,err_ptr,NULL,NULL,NULL);
           return(0);
        }
	sts = RISexecute_query1( PIP_COMPS1_PREP_ID2, buffer,7,outdata, &rows, &cols, &par_cnt);	
    } 
    
    if (sts != 1 || rows == 0)
     {
       printf("Failed accessing piping spec component table.\n");
       printf("SELECT <%s>\nFROM <%s>\n%s\n", select, table, pr_search);
       VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
       return( ACC_E_PIPING_COMPS );
     }

#ifdef MY_DEBUG
printf("  Fetching parameters from VRrisdat structure\n");
#endif

    comp_count = par_cnt;  /* store param count */

    for(i = 0; strcmp( outdata[i].name,"family_name") != NULL
               && i < comp_count; ++i){}

    strcpy (fam_name, outdata[i].data.val.attr_c);   /* family name */
    i += 1;
    strcpy (number,outdata[i].data.val.attr_c);      /* part number prfx */

    /* Copy spec param values in to the structures */
    /*---------------------------------------------*/

     /* Macro or family name */

     strcpy(mac_pm[*pm_no].name,VR_N_MACRO_NAME_AN);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_TEXT;
     strcpy(mac_pm[*pm_no].desc.value.att_txt, fam_name);
     *pm_no += 1;     

     for( i = 0;strcmp( outdata[i].name,"short_code") != NULL
                         && i < comp_count; ++i){}
     /* Short code */
     strcpy(mac_pm[*pm_no].name,VR_N_SHORT_CODE_AN);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_TEXT;
     strcpy(short_code,outdata[i].data.val.attr_c);
     strcpy(mac_pm[*pm_no].desc.value.att_txt, short_code);
     *pm_no += 1;     
     i += 1;
   
     /* Max temp */
     strcpy(mac_pm[*pm_no].name,VR_N_MAX_TEMP_DB);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
     if(( prj_units_set != pip_spec_units ) && (outdata[i].data.val.attr_dbl != -9999.0 ))
	mac_pm[*pm_no].desc.value.att_exp =converted_to_vds(mac_pm[*pm_no].name,
			pip_spec_units,prj_units_set, outdata[i].data.val.attr_dbl,err_ptr );
     else
     	mac_pm[*pm_no].desc.value.att_exp = outdata[i].data.val.attr_dbl;
     *pm_no += 1;     
     i += 1;

     /* Prep G */

     strcpy(mac_pm[*pm_no].name,VR_N_PREP_G_IN);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
     mac_pm[*pm_no].desc.value.att_exp = 0.0;
     prep_g = 0;
     if (outdata[i].data.val.attr_int > 0) 
     {
        mac_pm[*pm_no].desc.value.att_exp = (double)outdata[i].data.val.attr_int;
        prep_g = outdata[i].data.val.attr_int;
     }
     *pm_no += 1;
     i += 1;

     /* Prep R */

     strcpy(mac_pm[*pm_no].name,VR_N_PREP_R_IN);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
     /* if prep_r is undefined or zero */
     if (outdata[i].data.val.attr_int == 0) 
     {
        mac_pm[*pm_no].desc.value.att_exp = mac_pm[*pm_no-1].desc.value.att_exp;
        prep_r = prep_g;
     }
     else
     {
        mac_pm[*pm_no].desc.value.att_exp =(double)outdata[i].data.val.attr_int;
        prep_r = outdata[i].data.val.attr_int;
     }
     *pm_no += 1;
     i += 1;

     /* Rating G */

     strcpy(mac_pm[*pm_no].name,VR_N_RATING_G_DB);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
     /* Change the rating strings into doubles */
     mac_pm[*pm_no].desc.value.att_exp = 0.;
     if (strlen(outdata[i].data.val.attr_c) > 0)
     {
       sts = extract_num( outdata[i].data.val.attr_c, tmp1);
       if (sts ==  1)
       {
         mac_pm[*pm_no].desc.value.att_exp = atof(tmp1);
       }
     }
     *pm_no += 1;
     i += 1;

     /* Rating R */

     strcpy(mac_pm[*pm_no].name,VR_N_RATING_R_DB);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
     mac_pm[*pm_no].desc.value.att_exp = 0.;
     if (strlen(outdata[i].data.val.attr_c) == 0 || 
        (strcmp(outdata[i].data.val.attr_c,"0") == 0)) 
     {
        mac_pm[*pm_no].desc.value.att_exp = mac_pm[*pm_no-1].desc.value.att_exp;
     }
     else
     {
       sts = extract_num(outdata[i].data.val.attr_c,tmp1);
       if (sts ==  1)
       {
          mac_pm[*pm_no].desc.value.att_exp = atof(tmp1);
       }
      }
      *pm_no += 1;
      i += 1;

     /* Sch thk G */

     strcpy(mac_pm[*pm_no].name,VR_N_SCH_THK_G_AN);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_TEXT;
     strcpy (mac_pm[*pm_no].desc.value.att_txt,outdata[i].data.val.attr_c);
     if (strcmp(outdata[i].data.val.attr_c,"NREQD") == 0)
     {
       strcpy (mac_pm[*pm_no].desc.value.att_txt,"");
     }
     flag = 0;
     if (strcmp(outdata[i].data.val.attr_c,"MATCH") == 0)
     {
       /* Set flag for sched thk MATCH */
       flag = 1;
       /* Reaccess piping comps with comp code set to PIPING */

#ifdef MY_DEBUG
printf("  Retrieving schedule-thickness\n");
#endif
        table = VRDB_PIPCOMPS_TBL;
        select = "sch_thk_g, size_g_low, size_g_high";
    	sprintf( pr_search, " WHERE spec_no = %d and comp_code = %s and size_g_low <= %lf and size_g_high >= %lf and opt_code = %d", spec_no, "PIPING", SIZE_1, SIZE_1, 1);
    	sprintf( search, " WHERE spec_no = ? and comp_code = ? and size_g_low <= ? and size_g_high >= ? and opt_code = ?");
	sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );
	sprintf(buffer[0],"%d",spec_no);
	sprintf(buffer[1],"%s","PIPING");
	sprintf(buffer[2],"%lf",SIZE_1);
	sprintf(buffer[3],"%lf",SIZE_1);
	sprintf(buffer[4],"%d",1);


	sts = RISprepare_query(ris_str, PIP_COMPS2_PREP_ID6 );
        if(sts != 1 )
        {
           printf("Error in preparing query for PIPING_COMPS :%d\n",PIP_COMPS2_PREP_ID6);
           printf("%s\n", ris_str );
           VRdb_err_msg( VR_E_DbErrPrepQuery,err_ptr,NULL,NULL,NULL);
           return(0);
        }

	sts = RISexecute_query1( PIP_COMPS2_PREP_ID6, buffer,5,opt_data, &rows, &cols, &par_cnt);
       if (sts != 1 || rows == 0)
       {
         printf("Failed accessing piping component table for match sch thk green.\n");
         printf("SELECT <%s>\nFROM <%s>\n%s\n", select, table, pr_search);
         sprintf(disp_err,"spec_no %d,comp_code '%s',size %f,opt_code %d",
                             spec_no, "PIPING", SIZE_1, 1);
         VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
         return( ACC_E_PIPING_COMPS );
       }          

       UI_status("Processing..        ");

#ifdef MY_DEBUG
printf("  Fetching parameters from opt VRrisdat structure\n");
#endif
       strcpy(mac_pm[*pm_no].desc.value.att_txt, opt_data[0].data.val.attr_c);
       strcpy(thk_match,mac_pm[*pm_no].desc.value.att_txt);
       range_1 = opt_data[1].data.val.attr_dbl;
       range_2 = opt_data[2].data.val.attr_dbl;
     }
     strcpy(thk1, mac_pm[*pm_no].desc.value.att_txt); /* save thickness 1 */
     *pm_no += 1;
     i += 1;

     /* Sch thk R*/

     strcpy(mac_pm[*pm_no].name,VR_N_SCH_THK_R_AN);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_TEXT;
     strcpy (thk2, outdata[i].data.val.attr_c );         
     strcpy (mac_pm[*pm_no].desc.value.att_txt,thk2);
#ifdef MY_DEBUG
printf("  Set thk2 %x, %s\n",thk2,thk2);
#endif

     if (strcmp(thk2,"NREQD") == 0)
     {
       strcpy (mac_pm[*pm_no].desc.value.att_txt,"");

     }
     else if (strlen(thk2) == 0)
     {
       strcpy (mac_pm[*pm_no].desc.value.att_txt,mac_pm[*pm_no-1].desc.value.att_txt);
     }
     else if (strcmp(thk2,"MATCH") == 0)
     {
       if((range_1 <= SIZE_2 && range_2 >= SIZE_2) && (flag == 1))
       {
         strcpy(mac_pm[*pm_no].desc.value.att_txt,thk_match);
         strcpy(thk2,thk_match);
       }
       else
       {
         /* Reaccess piping comps with comp code PIPING */
#ifdef MY_DEBUG
printf("  Accessing 2nd schedule/thickness\n");
#endif
        table = VRDB_PIPCOMPS_TBL;
        select = "sch_thk_g, size_g_low, size_g_high";
    	if((SIZE_1 == SIZE_2) || (SIZE_2 == 0))
    	{
    	sprintf( search, " WHERE spec_no = ? and comp_code = ? and size_g_low <= ? and size_g_high >= ? and opt_code = ?");
    	sprintf( pr_search, " WHERE spec_no = %d and comp_code = '%s' and size_g_low <= %lf and size_g_high >= %lf and opt_code = %d", spec_no, "PIPING", SIZE_1, SIZE_1, 1);
	sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );
	sprintf(buffer[0],"%d\0",spec_no);
	sprintf(buffer[1],"%s\0","PIPING");
	sprintf(buffer[2],"%lf\0",SIZE_1);
	sprintf(buffer[3],"%lf\0",SIZE_1);
	sprintf(buffer[4],"%d", 1);
        sprintf(disp_err, "spec_no %d,comp_code '%s',size %f,opt_code %d",
                           spec_no, "PIPING", SIZE_1, 1);

	sts = RISprepare_query(ris_str, PIP_COMPS2_PREP_ID6 );
        if(sts != 1 )
        {
           printf("Error in preparing query for PIPING_COMPS :%d\n",PIP_COMPS2_PREP_ID6);
           printf("%s\n", ris_str );
           VRdb_err_msg(VR_E_DbErrPrepQuery,err_ptr,NULL,NULL,NULL);
           return(0);
        }
	sts = RISexecute_query1( PIP_COMPS2_PREP_ID6, buffer,5,opt_data, &rows, &cols, &par_cnt);
    	}
    	else
    	{
	sprintf( search, " WHERE spec_no = ? and comp_code = ? and size_g_low <= ? and size_g_high >= ? and opt_code = ?");
	sprintf( pr_search, " WHERE spec_no = %d and comp_code = '%s' and size_g_low <= %lf and size_g_high >= %lf and opt_code = %d",spec_no,"PIPING", SIZE_2, SIZE_2, 1);
    	sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );

	sprintf(buffer[0],"%d",spec_no);
	sprintf(buffer[1],"%s","PIPING");
	sprintf(buffer[2],"%lf",SIZE_2);
	sprintf(buffer[3],"%lf",SIZE_2);
	sprintf(buffer[4],"%d", 1);
        sprintf(disp_err, "spec_no %d,comp_code '%s',size %f,opt_code %d",
                           spec_no, "PIPING", SIZE_2, 1);
	sts = RISprepare_query(ris_str, PIP_COMPS2_PREP_ID6 );
        if(sts != 1 )
        {
           printf("Error in preparing query for PIPING_COMPS :%d\n",PIP_COMPS2_PREP_ID6);
           printf("%s\n", ris_str );
           VRdb_err_msg(VR_E_DbErrPrepQuery,err_ptr,NULL,NULL,NULL);
           return(0);
        }
	sts = RISexecute_query1( PIP_COMPS2_PREP_ID6, buffer,5,opt_data, &rows, &cols, &par_cnt);	
    	} 
         if (sts != 1 || rows == 0)
         { 
           printf("Failed accessing piping component table for match sch thk red.\n");
           printf("SELECT <%s>\nFROM <%s>\n%s\n", select, table, pr_search);
           VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
           return( ACC_E_PIPING_COMPS );
         }          
#ifdef MY_DEBUG
printf("  Fetching parameters from opt VRrisdat structure\n");
#endif
         strcpy(thk2, opt_data[0].data.val.attr_c);
         strcpy(mac_pm[*pm_no].desc.value.att_txt, thk2);
       }

     }
     *pm_no += 1;
     i += 1;


#ifdef MY_DEBUG
printf("  Fetching remaining parameters from VRrisdat structure\n");
#endif

     /* Geom std */

     strcpy(mac_pm[*pm_no].name,VR_N_GEOM_STD_IN);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
     mac_pm[*pm_no].desc.value.att_exp = 0.0;
     if (outdata[i].data.val.attr_int > 0)
     {
        mac_pm[*pm_no].desc.value.att_exp = (double)outdata[i].data.val.attr_int;
     }
     *pm_no += 1;
     i += 1;

     /* End std G */

     strcpy(mac_pm[*pm_no].name,VR_N_END_STD_G_IN);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
     mac_pm[*pm_no].desc.value.att_exp = 0.0;
     end_std_g = 0;
     if (outdata[i].data.val.attr_int > 0)
     {
        mac_pm[*pm_no].desc.value.att_exp = (double)outdata[i].data.val.attr_int;
        end_std_g = outdata[i].data.val.attr_int;
     }
     *pm_no += 1;
     i += 1;

     /* End std R */

     strcpy(mac_pm[*pm_no].name,VR_N_END_STD_R_IN);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
     if (outdata[i].data.val.attr_int == 0 )
     {
        mac_pm[*pm_no].desc.value.att_exp = mac_pm[*pm_no-1].desc.value.att_exp;
        end_std_r = end_std_g;
     }
     else
     {
        mac_pm[*pm_no].desc.value.att_exp = (double)outdata[i].data.val.attr_int;
        end_std_r = outdata[i].data.val.attr_int;
     }
     *pm_no += 1;
     i += 1;

UI_status("Processing...       ");

     /* Thk G */
     
     strcpy(mac_pm[*pm_no].name,VR_N_THK_G_DB);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
     mac_pm[*pm_no].desc.value.att_exp = atof(thk1);
     if((!atof(thk1)) && (thk1[0] != 0))
     {
       get_gtt(prep_g, &flag);
       if ( flag == 2 )       /* If prep g is male */     
       {
#ifdef MY_DEBUG
printf("  Accessing PIPING SCH THK for THK G\n");
#endif

         /* Access PIPING SCH THK  */
         table = VRDB_PIPSCHTHK_TBL;
         select = "thickness,thick_units";
         sprintf( search, " WHERE npd = ? and sched = ? and gentyp = ? and end_std = ?");
         sprintf( pr_search, " WHERE npd = %lf and sched = '%s' and gentyp = %d and end_std = %d", SIZE_1, thk1, 300, end_std_g);
         sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );
	 sprintf(buffer[0],"%lf",SIZE_1);
	 sprintf(buffer[1],"%s",thk1);
	 sprintf(buffer[2],"%d",300);
	 sprintf(buffer[3],"%d",end_std_g);

	 sts = RISprepare_query( ris_str, PIP_SCHTHK_PREP_ID4 );
         if(sts != 1 )
         {
           printf("Error in preparing query for PIPING_SCH_THK :%d\n",PIP_SCHTHK_PREP_ID4);
           printf("%s\n", ris_str );
           VRdb_err_msg(VR_E_DbErrPrepQuery,err_ptr,NULL,NULL,NULL);
           return(0);
         }        
	 
         sts = RISexecute_query1( PIP_SCHTHK_PREP_ID4,buffer,4, opt_data, &rows, &cols, &cnt);
         if (sts != 1 || rows == 0)
         { 
           printf("Failed accessing piping sch thk table for thk green.\n");
           printf("SELECT <%s>\nFROM <%s>\n%s\n", select, table, pr_search);
           sprintf(disp_err,"npd %f,sched '%s',gentyp %d,end_std %d",
                               SIZE_1, thk1, 300, end_std_g);
           VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
           return(ACC_E_PIPING_SCH_THK);
         }  
         else
         {
	   thick_units = opt_data[1].data.val.attr_int;
	   if( prj_units_set != pip_spec_units )
		mac_pm[*pm_no].desc.value.att_exp =converted_to_vds("thickness",	 	     thick_units,prj_units_set, opt_data[0].data.val.attr_dbl,err_ptr);
	   else
           	mac_pm[*pm_no].desc.value.att_exp = opt_data[0].data.val.attr_dbl; 
         }
       }
     }
     *pm_no += 1;


     /* Thk R */
     strcpy(mac_pm[*pm_no].name,VR_N_THK_R_DB);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
     mac_pm[*pm_no].desc.value.att_exp = atof(thk2);
     if(thk2[0] == 0) 
     {
       mac_pm[*pm_no].desc.value.att_exp = mac_pm[*pm_no -1].desc.value.att_exp;
     }
     if((strcmp(thk2, "NREQD") == 0) || (thk2[0] ==' '))
     {
       strcpy(thk2, "");
     }
     if((!atof(thk2)) && (thk2[0] != 0))
     {
       get_gtt(prep_r, &flag);
       if ( flag == 2 )       /* If prep r is male */     
       {
#ifdef MY_DEBUG
printf("   Accessing PIPING SCH THK for THK R\n");
#endif
         /* Access PIPING SCH THK  */
         table = VRDB_PIPSCHTHK_TBL;
         select = "thickness,thick_units";
         if( SIZE_2 == 0 )
	 {
         	sprintf( search, " WHERE npd = ? and sched = ? and gentyp = ? and end_std = ?");
         	sprintf( pr_search, " WHERE npd = %lf and sched = '%s' and gentyp = %d and end_std = %d",SIZE_1, thk2, 300, end_std_r);
	 	sprintf(buffer[0],"%lf",SIZE_1);
	 	sprintf(buffer[1],"%s",thk2);
	 	sprintf(buffer[2],"%d",300);
	 	sprintf(buffer[3],"%d",end_std_r);
                sprintf(disp_err,"npd %f,sched '%s',gen_typ %d,end_std %d",
                                  SIZE_1, thk2, 300, end_std_r);
	 }
	 else
	 {
         	sprintf( search, " WHERE npd = ? and sched = ? and gentyp = ? and end_std = ?");
         	sprintf( pr_search, " WHERE npd = %lf and sched = '%s' and gentyp = %d and end_std = %d", SIZE_2, thk2, 300, end_std_r);
	 	sprintf(buffer[0],"%lf",SIZE_2);
	 	sprintf(buffer[1],"%s",thk2);
	 	sprintf(buffer[2],"%d",300);
	 	sprintf(buffer[3],"%d",end_std_r);
                sprintf(disp_err,"npd %f,sched '%s',gen_typ %d,end_std %d",
                                 SIZE_2,thk2,300,end_std_r);
	 }

         sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );
	 sts = RISprepare_query( ris_str, PIP_SCHTHK_PREP_ID4 );
         if(sts != 1 )
         {
           printf("Error in preparing query for PIPING_SCH_THK :%d\n",PIP_SCHTHK_PREP_ID4);
           printf("%s\n", ris_str );
           VRdb_err_msg(VR_E_DbErrPrepQuery,err_ptr, NULL,NULL,NULL);
           return(0);
         }        
         sts = RISexecute_query1( PIP_SCHTHK_PREP_ID4,buffer,4, opt_data, &rows, &cols, &cnt);

         if (sts != 1 || rows== 0)
         { 
           printf("Failed accessing piping sch thk table for thk red.\n");
           printf("SELECT <%s>\nFROM <%s>\n%s\n", select, table, pr_search);
           VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err); 
           return(ACC_E_PIPING_SCH_THK);
         }          
         else
         {
	   thick_units = opt_data[1].data.val.attr_int;
	   if( prj_units_set != pip_spec_units )
		mac_pm[*pm_no].desc.value.att_exp =converted_to_vds("thickness",			thick_units,prj_units_set, opt_data[0].data.val.attr_dbl,err_ptr);
	   else
           	mac_pm[*pm_no].desc.value.att_exp = opt_data[0].data.val.attr_dbl; 
         }
       }
     }
     *pm_no += 1;

     while ( i < comp_count && i < MAX_MACRO_PARAMS)
     {
        strcpy(mac_pm[*pm_no].name, outdata[i].name );
        if( outdata[i].data.type == VR_RISDB_TEXT )
        {
           mac_pm[*pm_no].desc.type = AC_ATTRIB_TEXT;
           strcpy(mac_pm[*pm_no].desc.value.att_txt, outdata[i].data.val.attr_c);
        }
        else if( outdata[i].data.type == VR_RISDB_INT ) 
        {
           mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
           mac_pm[*pm_no].desc.value.att_exp = (double) outdata[i].data.val.attr_int;
        }
        else if( outdata[i].data.type == VR_RISDB_DOUBLE ) 
        {
           mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
           mac_pm[*pm_no].desc.value.att_exp = outdata[i].data.val.attr_dbl;
        }
        else
        {
           printf("Error: Unknown datatype for column in PIPING_COMPS\n");
        }
        *pm_no += 1;
        i += 1;
     }



    /* ACCESS PIPING COMM CODE TABLE FOR PDM PART NUM */
    /*------------------------------------------------*/

UI_status("Processing....      ");

#ifdef MY_DEBUG
printf("  Accessing PIPING_COMMOD_CODE\n");
printf ("thk2... %x %s\n",thk2, thk2);
#endif
    table = VRDB_PIPCOMMCOD_TBL;
    select = "pdm_part_num";

    if(thk1[0] == 0 ) strcpy(thk1," ");
    if(thk2[0] == 0 ) strcpy(thk2," ");

    sprintf(search, "where si_comm_code = ? and size_g = ? and size_r = ? and sch_thk_g = ? and sch_thk_r = ?");
    sprintf(pr_search, "where si_comm_code = '%s' and size_g = %lf and size_r = %lf and sch_thk_g = '%s' and sch_thk_r = '%s'",number, SIZE_1, 0.0, thk1, thk2);

    sprintf( ris_str,"SELECT %s FROM %s %s",select, table, search);

    sprintf(buffer[0],"%s",number );
    sprintf(buffer[1],"%lf",SIZE_1);
    strcpy(buffer[3],thk1 );
    strcpy(buffer[4],thk2 );

    if(SIZE_2 == SIZE_1)
      sprintf(buffer[2],"%lf",0.0);
    else
      sprintf(buffer[2],"%lf",SIZE_2);

    sprintf(disp_err,
      "si_comm_code '%s',size_g %s,size_r %s,sch_thk_g '%s',sch_thk_r '%s'",
         buffer[0], buffer[1], buffer[2], buffer[3], buffer[4]);

    sts = RISprepare_query( ris_str, PIP_COMCOD_PREP_ID3 );

    if(sts != 1 )
    {
      printf("Error in preparing query for PIPING_COMMOD_CODE :%d\n",
                                      PIP_COMCOD_PREP_ID3);
      printf("%s\n", ris_str );
      VRdb_err_msg(VR_E_DbErrPrepQuery,err_ptr,NULL,NULL,NULL);
      return(0);
    }        

    sts = RISexecute_query1( PIP_COMCOD_PREP_ID3,buffer,5,outdata,
                                     &rows, &cols, &par_cnt);
#ifdef MY_DEBUG
    printf (" first execute query, sts,rows,thk %d %d %d\n",sts,rows,thk2[0]);
#endif

    iLENN1 = strlen(thk2);;
    iLENN2 = strlen(thk2);;

    if ((sts == 1) && (rows == 0))
      /*   check for all permutations.... */

    { /*  special for NULL string in second schedule thickness  */
      /*    AMENDED 4/10/96... EITHER can be dropped            */
      /*   TR # 179525438                                       */
      int      iStatus;
      IGRchar **DBio = NULL;
      IGRchar   DBwhere[200];
      IGRchar   DBrtg[40];


      sprintf(DBwhere, "si_comm_code = '%s' and size_g = %s and size_r = %s ",
               buffer[0], buffer[1], buffer[2]);

      if ((iLENN1 > 0) && (thk1[0] != '\0') && (thk1[0] != ' '))
      {
        sprintf(DBrtg," and sch_thk_g = '%s'",buffer[3]);
        strcat (DBwhere, DBrtg);
      }

      if ((iLENN2 > 0) && (thk2[0] != '\0') && (thk2[0] != ' '))
      {
        sprintf(DBrtg," and sch_thk_r = '%s'",buffer[4]);
        strcat (DBwhere, DBrtg);
      }

#ifdef MY_DEBUG
    printf (" to second query select %s where %s\n",select, DBwhere);
#endif

      iStatus =
      VdsRisSelect (select, VRDB_PIPCOMMCOD_TBL, DBwhere, NULL, NULL, NULL,
                     1, &rows, &DBio);

#ifdef MY_DEBUG
    printf (" second execute query, rows %d \n",rows);
#endif

       if (!(iStatus & 1) || (rows == 0))
       {
         if ((DBio != NULL) && (rows > 0)) VdsRisFreeBuffer (DBio, rows);

         printf("Failed retrieving PDM part number.\n");
         printf("SELECT %s\nFROM %s\nwhere %s\n",
                  select, VRDB_PIPCOMMCOD_TBL, DBwhere);

         VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
         return( ACC_E_PIPING_COMMOD_CODE );
       }

       strcpy (partnum,DBio[0]);

       VdsRisFreeBuffer (DBio, rows);
       goto BYPASS;
    }

    if (sts != 1 || rows == 0)
    {
       printf("Failed retrieving PDM part number.\n");
       printf("SELECT %s\nFROM %s\n%s\n", select, table, pr_search);
       VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
       return( ACC_E_PIPING_COMMOD_CODE );
    }

#ifdef MY_DEBUG
printf("  Fetching PDM part number from VRrisdat structure\n");
#endif
    strcpy (partnum, outdata[0].data.val.attr_c);

    BYPASS:
    strcpy(mac_pm[*pm_no].name,VR_N_PDM_PART_NUM_AN);
    mac_pm[*pm_no].desc.type = AC_ATTRIB_TEXT;
    strcpy(mac_pm[*pm_no].desc.value.att_txt, partnum);
    *pm_no += 1;

UI_status("Processing.....     ");

     /* ACCESS THE PIPING COMP TYPE TABLE */
     /*-----------------------------------*/
 
#ifdef MY_DEBUG
printf("  Accessing PIPING_COMP_TYPE\n");
#endif
    sprintf( number,"");
    table = VRDB_PIPCOMPTYP_TBL;
    select = "comp_topo, comp_cat, comp_rptcat, comp_numcp, comp_2nd_cp";
    sprintf( search, "where comp_code = ? and comp_shcode = ?");
    sprintf( pr_search, "where comp_code = '%s' and comp_shcode = '%s'", compname, short_code);
    sprintf(buffer[0],"%s",compname);
    sprintf(buffer[1],"%s",short_code);
    sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );

    sts = RISprepare_query(ris_str, PIP_COMPTYP_PREP_ID5);
    if(sts != 1 )
    {
        printf("Error in preparing query for PIPING_COMP_TYPE :%d\n",PIP_COMPTYP_PREP_ID5);
        printf("%s\n", ris_str );
        VRdb_err_msg(VR_E_DbErrPrepQuery,err_ptr,NULL,NULL,NULL);
        return(0);
    }        
    sts = RISexecute_query1( PIP_COMPTYP_PREP_ID5,buffer,2, outdata, &rows, &cols, &par_cnt);
    if (sts != 1 || rows== 0)
    {
      printf("Failed retrieving component topology\n");
      printf("SELECT %s\nFROM %s\n%s\n", select, table, pr_search);
      sprintf(disp_err,"comp_code '%s',comp_shcode '%s'",compname,short_code);
      VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
      return(ACC_E_PIPING_COMP_TYPE );
    }

#ifdef MY_DEBUG
printf("  Fetching component params from VRrisdat structure\n");
#endif
    *topology = (short)outdata[0].data.val.attr_int;
    strcpy(mac_pm[*pm_no].name,VR_N_COMP_TOPO_IN);
    mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
    mac_pm[*pm_no].desc.value.att_exp = (double)outdata[0].data.val.attr_int;
    *pm_no += 1;

    *type = (short)outdata[1].data.val.attr_int;
    strcpy(mac_pm[*pm_no].name,VR_N_COMP_TYPE_IN);
    mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
    mac_pm[*pm_no].desc.value.att_exp = (double)outdata[1].data.val.attr_int;
    *pm_no += 1;

    strcpy(mac_pm[*pm_no].name,VR_N_COMP_RPTCAT_IN);
    mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
    mac_pm[*pm_no].desc.value.att_exp = (double)outdata[2].data.val.attr_int;
    *pm_no += 1;

    *comp_numcp =outdata[3].data.val.attr_int ;
    strcpy(mac_pm[*pm_no].name,VR_N_COMP_NUMCP_IN);
    mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
    mac_pm[*pm_no].desc.value.att_exp =(double)outdata[3].data.val.attr_int ;
    *pm_no += 1;

    *comp_seccp =outdata[4].data.val.attr_int;
    strcpy(mac_pm[*pm_no].name,VR_N_COMP_2ND_CP_IN);
    mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
    mac_pm[*pm_no].desc.value.att_exp =(double)outdata[4].data.val.attr_int;
    *pm_no += 1;

UI_status (" ");
  return(1);
 }



int extract_num (str1,str2)
char *str1;
char *str2;
{
  int i, k=0;

  str2[0] = 0;
  for(i=0;i<strlen(str1);++i)
  {
    if(isdigit(str1[i]) || str1[i] == '.')
    {
        str2[k]=str1[i];
        k = k+1;
    }
  }
  str2[k]= 0;
  return 1;
}

#endif
 
