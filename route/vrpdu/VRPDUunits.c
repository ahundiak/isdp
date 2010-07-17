
/* $Id: VRPDUunits.c,v 1.2 2002/04/10 19:55:31 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpdu / VRPDUunits.c
 *
 * Description:
 *	All units accessing functions  
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRPDUunits.c,v $
 *	Revision 1.2  2002/04/10 19:55:31  louis
 *	TR5649-standardize tolerances
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
 * Revision 1.1  1996/04/22  15:03:24  pinnacle
 * Created: vrpdu/VRPDUunits.c by hverstee for route240
 *
 * Revision 1.2  1996/01/17  17:32:18  pinnacle
 * Replaced: vrpdu/units.c for:  by r240_int for route240
 *
 *
 * History:
 *	01/17/96   tlb	       Add prototypes
 *      04/05/02   law         TR5649-standardize tolerance with VRGetTol
 *
 *************************************************************************/

#include 	<stdio.h>
#include 	<math.h>
#include	<stdlib.h>
#include 	"VRDbStruct.h"
#include        "VRmsg.h"
#include        "VRDbTbl.h"
#include	"VRMath.h"
#include 	"vrpdu_pto.h"

/*          REPLACED BY VRXunits.I          */

#if   0

int  prj_units_set;
int  pip_spec_units;
int  part_units;

/**************************************************************/
/*   these static externals to be initialized at DB change    */
static  int  OldProjNo = -1;
static  char OldPipSpecNm[10]="";
static  int  OldPipSpUnitSet;

static  int  vds_unit_cnt;
static
struct VDSunits	   vds_units[MAX_VDS_UNITS_PARAMS];
static  int  vds_cnv_cnt;
static
struct VDSconvert  vds_convert[MAX_VDS_CONVERT_COLS];
static  int  npd_cnt;
static
struct pipe_npd_allowed   npd_allowed[VR_MAX_NPDLIST_SIZE];
/**************************************************************/
/*    clear cache function                                    */

void VR_DbC_Clunt ()
{
  int      i;

  OldProjNo       = -1;
  OldPipSpecNm[0] = '\0';
  OldPipSpUnitSet = -1;

  vds_unit_cnt    = 0;
  for (i=0; i<MAX_VDS_UNITS_PARAMS; i++)
  {
    vds_units[i].param_name[0] = '\0';
    vds_units[i].units_set     = 0;
    vds_units[i].units_code    = 0;
    vds_units[i].resolution    = 0;
  }

  vds_cnv_cnt     = 0;
  for (i=0; i<MAX_VDS_CONVERT_COLS; i++)
  {
    vds_convert[i].units_in    = 0;
    vds_convert[i].units_out   = 0;
    vds_convert[i].cnvr_fctr   = 0;
    vds_convert[i].cnvr_offset = 0;
    vds_convert[i].rnd_off_fctr= 0;
  }

  npd_cnt         = 0;
  for (i=0; i<VR_MAX_NPDLIST_SIZE; i++)
  {
    npd_allowed[i].prj_no       = 0;
    npd_allowed[i].npd          = 0;
    npd_allowed[i].npd_equiv    = 0;
    npd_allowed[i].spec_name[0] = '\0';
  }

  /*   NOTE, also reset globals......   */

  prj_units_set  = 0;
  pip_spec_units = 0;
  part_units     = 0;

  return;
}
/**************************************************************/

int	Get_piping_spec_units(int      proj_no,
                              char    *name,          /*  spec name  */
                              char    *err_ptr)
{
        char    *table=NULL;
        char    *select=NULL;
        char    search[MAX_WHERE_SIZE];
        char    ris_str[MAX_RIS_STR_SIZE];
        int     rows, cols, par_cnt;
        int     sts;
        char   disp_err[100];
     
        struct VRrisdat         outdata[MAX_RIS_QUERY_PAR];

        /* If the Spec units already set */

        if( proj_no == OldProjNo && !strcmp(name,OldPipSpecNm) )
        {
           pip_spec_units = OldPipSpUnitSet;
           return 1;
        }   

	table = VRDB_PIPSPEC_TBL;
	select = "units_set";
        sprintf( search, "WHERE %s = '%s' and prj_no = %d",
                           "spec_name", name, proj_no);
        sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );

        sts = RISexecute_query(  ris_str, outdata, &rows, &cols,
                &par_cnt);

        if (sts !=1 || rows == 0)
        {
          printf("Failed accessing PIPING SPEC. \n");
	  printf("SELECT <%s> FROM <%s> %s\n", select, table,search );
          sprintf(disp_err,"spec_name '%s',prj_no %d",name, proj_no);
          VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
	  return sts;
        }
 
	pip_spec_units = outdata[0].data.val.attr_int;
        strcpy( OldPipSpecNm, name );
        OldPipSpUnitSet = pip_spec_units;    
        OldProjNo = proj_no;
	return  1;
}

int	Get_part_units(char    *name,          /*  family name  */
                       char    *p_partnum,
                       char    *err_ptr)

{
        char    table[MAX_ATTR_LEN];
        char    *select=NULL;
        char    search[MAX_WHERE_SIZE];
        char    ris_str[MAX_RIS_STR_SIZE];
        int     rows, cols, par_cnt;
        int     sts;
        char    disp_err[100];

        struct VRrisdat         outdata[MAX_RIS_QUERY_PAR];

	sprintf(table, "%s", name);
	select = "units_set";
        sprintf( search, "WHERE %s = '%s' ", "p_partnum", p_partnum);
        sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );

        sts = RISexecute_query(  ris_str, outdata, &rows, &cols,
                &par_cnt);

        if (sts !=1 || rows == 0)
        {
          printf("Failed accessing %s . \n, name");
	  printf("SELECT <%s> FROM <%s> %s\n", select, table,search );
          sprintf(disp_err,"p_partnum '%s'",p_partnum);
          VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
	  return sts;
        }

	part_units = outdata[0].data.val.attr_int;

	return  1;
}

double  converted_to_vds (char    *par_name,
                          int      units_set_in,
                          int      units_set_out,
                          double   old_value,
                          char    *err_ptr)

{
	double	new_value1, new_value;

	char    *table=NULL;
        char    *select=NULL;
        char    search[MAX_WHERE_SIZE];
        char    ris_str[MAX_RIS_STR_SIZE];
        int     rows, cols, par_cnt;
        int     sts, i;
        int     units_in, units_out;
	double	cnvr_fctr, cnvr_offset, rnd_off_fctr, resolution;

	int	in_cache;
        char    disp_err[100];

        struct VRrisdat         outdata[MAX_RIS_QUERY_PAR];

	in_cache     = 0;
        units_in     = 0;
        units_out    = 0;
        cnvr_fctr    = 0;
        cnvr_offset  = 0;
        rnd_off_fctr = 0;
        resolution   = 0;

	if((!strcmp(par_name,"thickness")))
	    units_in = units_set_in;
	else
	{
	   for( i = 0; i < vds_unit_cnt; i++ )
	   {
		if((strcmp(vds_units[i].param_name, par_name) == 0 ) &&
			(vds_units[i].units_set == units_set_in ))
		{
		    units_in = vds_units[i].units_code;
	/*	    resolution = vds_units[i].resolution;  */
		    in_cache = 1;
		}
	   } 
	   if( !in_cache )
	   {
		table = VRDB_VDSUNITS_TBL;
		select = "units_code, resolution";
		sprintf( search, "WHERE param_name = '%s' and units_set = %d ",
				par_name, units_set_in);
		sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );

        	sts = RISexecute_query(  ris_str, outdata, &rows, &cols,
                	&par_cnt);

		if(sts != 1 || rows == 0)
		{
/*
	   	printf("Failed accessing VDS_UNITS. \n");
	   	printf("SELECT <%s> FROM <%s> %s\n", select, table,search );
*/
	   	return old_value;
        	}
		units_in = outdata[0].data.val.attr_int;

		strcpy(vds_units[vds_unit_cnt].param_name,par_name);
		vds_units[vds_unit_cnt].units_set = units_set_in;
		vds_units[vds_unit_cnt].units_code = units_in;
		vds_units[vds_unit_cnt].resolution = outdata[1].data.val.attr_dbl;
		vds_unit_cnt++;
	   }
	}

	in_cache = 0;
	for( i = 0; i < vds_unit_cnt; i++ )
	{
		if ((strcmp(vds_units[i].param_name, par_name) == 0 ) &&
			(vds_units[i].units_set == units_set_out ))
		{
		    units_out = vds_units[i].units_code;
		    resolution = vds_units[i].resolution;
		    in_cache = 1;
		}
	} 

	if(!in_cache)
	{
		table = VRDB_VDSUNITS_TBL;
		select = "units_code, resolution";
		sprintf( search, "WHERE param_name = '%s' and units_set = %d ",
				par_name, units_set_out );
		sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );

        	sts = RISexecute_query(  ris_str, outdata, &rows, &cols,
                	&par_cnt);

		if(sts != 1 || rows == 0)
		{
/*
	   	printf("Failed accessing VDS_UNITS. \n");
	   	printf("SELECT <%s> FROM <%s> %s\n", select, table,search );
*/
	   	return old_value;
        	}
		units_out = outdata[0].data.val.attr_int;
		resolution = outdata[1].data.val.attr_dbl;

		strcpy(vds_units[vds_unit_cnt].param_name,par_name);
		vds_units[vds_unit_cnt].units_set = units_set_out;
		vds_units[vds_unit_cnt].units_code = units_out;
		vds_units[vds_unit_cnt].resolution = resolution;
		vds_unit_cnt++;
	}
	if( units_in == units_out )
	{
		return old_value;
	}	
	else
	{

	in_cache = 0;
	for( i=0; i < vds_cnv_cnt; i++ )
	{
		if(( vds_convert[i].units_in == units_in ) && (vds_convert[i].units_out == units_out ))
		{
			cnvr_fctr = vds_convert[i].cnvr_fctr; 
			cnvr_offset = vds_convert[i].cnvr_offset;
			rnd_off_fctr = vds_convert[i].rnd_off_fctr; 
			in_cache = 1;
		}
	}
	if(!in_cache)
	{
        	table = VRDB_VDSCONVERT_TBL;
		select = "*";
		sprintf( search, "WHERE units_in = %d and units_out = %d", units_in,
					units_out);
		sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );

        	sts = RISexecute_query(  ris_str, outdata, &rows, &cols,
                	&par_cnt);

        	if(sts != 1 || rows == 0)
        	{
           		printf("Failed accessing VDS_CONVERT. \n");
	   		printf("SELECT <%s> FROM <%s> %s\n", select, table,search );
                        sprintf(disp_err,"units_in %d,units_out %d",units_in,units_out);
                        VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
           		return old_value;
		}
		cnvr_fctr = outdata[2].data.val.attr_dbl;
		cnvr_offset = outdata[3].data.val.attr_dbl;
		rnd_off_fctr = outdata[4].data.val.attr_dbl;

		vds_convert[vds_cnv_cnt].cnvr_fctr = cnvr_fctr; 
		vds_convert[vds_cnv_cnt].cnvr_offset = cnvr_offset;
		vds_convert[vds_cnv_cnt].rnd_off_fctr = rnd_off_fctr; 
		vds_cnv_cnt++;
	}

	new_value1 = old_value * cnvr_fctr + cnvr_offset;
	if( fabs(new_value1) < VRGetTol(VR_DIST_TOL))
		new_value = new_value1;
	else
		correct_wrt_resol( new_value1, resolution, &new_value );
	return	new_value;

	}

}

double  get_allowed_npd (int      prj_units_set,
                         int      pip_spec_units,
                         double   old_value,
                         char    *spec_name,
                         int      proj_no,
                         char    *err_ptr)

{
	
	char    *table=NULL;
        char    *select=NULL;
        char    search[MAX_WHERE_SIZE];
        char    ris_str[MAX_RIS_STR_SIZE];
        int     rows, cols, par_cnt;
        int     sts, i;
	int	units_in,units_out;
	int	in_cache;

	double	new_value;
        char    disp_err[100];

        struct VRrisdat         outdata[MAX_RIS_QUERY_PAR];

        units_in     = 0;
        units_out    = 0;
        new_value    = 0;
	in_cache     = 0;

	for( i = 0; i < vds_unit_cnt; i++ )
	{
		if((strcmp(vds_units[i].param_name, "npd_g") == 0 ) &&
			(vds_units[i].units_set == prj_units_set ))
		{
		    units_in = vds_units[i].units_code;
		    in_cache = 1;
		}
	} 
	if( !in_cache )
	{
		table = VRDB_VDSUNITS_TBL;
		select = "units_code";
		sprintf( search, "WHERE param_name = '%s' and units_set = %d ",
				"npd_g", prj_units_set);
		sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );

        	sts = RISexecute_query(  ris_str, outdata, &rows, &cols,
                	&par_cnt);

		if(sts != 1 || rows == 0)
		{
	   	printf("Failed accessing VDS_UNITS. \n");
	   	printf("SELECT <%s> FROM <%s> %s\n", select, table,search );
                sprintf(disp_err,"param_name '%s',units_set %d","npd_g",prj_units_set);
                VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
                return 0;
        	}
		units_in = outdata[0].data.val.attr_int;

		strcpy(vds_units[vds_unit_cnt].param_name,"npd_g");
		vds_units[vds_unit_cnt].units_set = prj_units_set;
		vds_units[vds_unit_cnt].units_code = units_in;
		vds_unit_cnt++;
	}

	in_cache = 0;
	for( i = 0; i < vds_unit_cnt; i++ )
	{
		if((strcmp(vds_units[i].param_name, "npd_g") == 0 ) &&
			(vds_units[i].units_set == pip_spec_units ))
		{
		    units_out = vds_units[i].units_code;
		    in_cache = 1;
		}
	} 
	if( !in_cache )
	{
		table = VRDB_VDSUNITS_TBL;
		select = "units_code";
		sprintf( search, "WHERE param_name = '%s' and units_set = %d ",
				"npd_g", pip_spec_units);
		sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );

        	sts = RISexecute_query(  ris_str, outdata, &rows, &cols,
                	&par_cnt);

		if(sts != 1 || rows == 0)
		{
	   	printf("Failed accessing VDS_UNITS. \n");
	   	printf("SELECT <%s> FROM <%s> %s\n", select, table,search );
                sprintf(disp_err,"param_name '%s',units_set %d","npd_g",pip_spec_units);
                VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
                return 0;
        	}
		units_out = outdata[0].data.val.attr_int;

		strcpy(vds_units[vds_unit_cnt].param_name,"npd_g");
		vds_units[vds_unit_cnt].units_set = pip_spec_units;
		vds_units[vds_unit_cnt].units_code = units_out;
		vds_unit_cnt++;
	}

	if(units_in != units_out )
	{
		if( units_out == 11 )
		{
		    in_cache = 0;
		    for( i= 0; i < npd_cnt; i++ )
		    {
			if((npd_allowed[i].npd == old_value)             && 
                           (!strcmp(npd_allowed[i].spec_name,spec_name)) &&
                           npd_allowed[i].prj_no == proj_no )
                              
			{
			     new_value = npd_allowed[i].npd_equiv;
			     in_cache = 1;
/*
			  printf("########  IN CACHE #######");
		printf("Old Value= %f   New Value: %f  \n", old_value, new_value);
*/
			}
		    }
		    if( !in_cache )
		    {
			table = VRDB_PIPNPDALL_TBL;
			select = "npd_equiv";
			sprintf( search, "WHERE npd = %f and tblno in (select npd_tblno from piping_spec where spec_name='%s' and prj_no = %d)", old_value, spec_name, proj_no );
			sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );

        		sts = RISexecute_query(  ris_str, outdata, &rows, &cols,
                	&par_cnt);

			if(sts != 1 || rows == 0)
			{
	   			printf("Failed accessing PIPING_NPD_ALLOWED. \n");
	   			printf("SELECT <%s> FROM <%s> %s\n", select, table,search );
                                sprintf(disp_err,"npd %f,spec_name '%s',prj_no %d",old_value,spec_name, proj_no);
                                VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
				return 0;
			}
			new_value = outdata[0].data.val.attr_dbl;
			npd_allowed[npd_cnt].npd_equiv = new_value;
			npd_allowed[npd_cnt].npd = old_value;
			strcpy(npd_allowed[npd_cnt].spec_name,spec_name);
			npd_allowed[npd_cnt].prj_no = proj_no;
			npd_cnt++;
/*
		printf("####### NOT IN CACHE  ###########");
		printf("Old Value= %f   New Value: %f  \n", old_value, new_value);
*/
		    }
		}
		if( units_out == 1 )
		{
		    in_cache = 0;
		    for( i= 0; i < npd_cnt; i++ )
		    {
			if((npd_allowed[i].npd_equiv == old_value)       && 
                           (!strcmp(npd_allowed[i].spec_name,spec_name)) &&
                           npd_allowed[i].prj_no == proj_no )
			{
			     new_value = npd_allowed[i].npd;
			     in_cache = 1;
/*
			  printf("########  IN CACHE #######");
		printf("Old Value= %f   New Value: %f  \n", old_value, new_value);
*/
			}
		    }
		    if( !in_cache )
		    {
			table = VRDB_PIPNPDALL_TBL;
			select = "npd";
			sprintf( search, "WHERE npd_equiv = %f and tblno in (select npd_tblno from piping_spec where spec_name='%s' and prj_no = %d)", old_value, spec_name,proj_no );
			sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );

        		sts = RISexecute_query(  ris_str, outdata, &rows, &cols,
                	&par_cnt);

			if(sts != 1 || rows == 0)
			{
	   			printf("Failed accessing PIPING_NPD_ALLOWED. \n");
	   			printf("SELECT <%s> FROM <%s> %s\n", select, table,search );
                                sprintf(disp_err,"npd_equiv %f,spec_name '%s',prj_no %d",old_value,spec_name, proj_no);
                                VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
				return 0;
			}
			new_value = outdata[0].data.val.attr_dbl;
			npd_allowed[npd_cnt].npd_equiv = old_value;
			npd_allowed[npd_cnt].npd = new_value;
			strcpy(npd_allowed[npd_cnt].spec_name,spec_name);
			npd_allowed[npd_cnt].prj_no = proj_no;
			npd_cnt++;
/*
		printf("####### NOT IN CACHE  ###########");
		printf("Old Value= %f   New Value: %f  \n", old_value, new_value);
*/
		    }
		}
/*
		printf("proj units: %d  spec_units: %d \n", prj_units_set, pip_spec_units );
		printf("Units_in = %d   Units_out: %d  \n", units_in, units_out);
*/
		return new_value;
	}
	else 
		return old_value;
}

int correct_wrt_resol (double   new_value1,
                       double   resolution,
                       double  *new_value)

{
	double 	coeff;
	int	val1, val2, i=0;
	char	str_val[20], str1[6], str2[2];

	for(i=0; i < 6; i++)
		str1[i] = 0;
	i = 0;

	if( resolution <= 0.00001  || new_value1 < 0.00001)
		*new_value = new_value1;
	else
	{
		coeff = new_value1 / resolution;
		sprintf(str_val,"%f",coeff);
		while(str_val[i] != '.' )
		{
			str1[i] = str_val[i];
			i++;
		}
		i++;
		strncpy(str2,&str_val[i],1);
		val1 = atoi(str1);
		val2 = atoi(str2);
		if(val2 >= 5)
			coeff = (double)( val1 +1 );
		else
			coeff = (double) val1;	
		*new_value = (double)(coeff * resolution);
	}
	return 0;
}

int  VRenq_proj_units()
{
        int  sts;
	/* -- Verify connection to server -- */
	if( !(VdsRisAttach()&1) ) 
	{
           return -1;
	}
	sts = VdsGetProjectUnits( &prj_units_set );
        if(!sts)
            return -1;

	if( prj_units_set > 0 && prj_units_set < 10 )
		return	VR_IMPERIAL_UNITS;
	else
	if(prj_units_set >= 10 && prj_units_set < 20)
		return  VR_MIXED_UNITS;
	else
	if( prj_units_set >=20 && prj_units_set < 30 )
		return  VR_METRIC_UNITS;

        return -1;
}
#endif

