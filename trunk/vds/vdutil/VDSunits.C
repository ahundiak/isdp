/* $Id: VDSunits.C,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdutil / VDSunits.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VDSunits.C,v $
 *        Revision 1.1.1.1  2001/01/04 21:09:32  cvs
 *        Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.2  1995/12/15  23:31:06  pinnacle
 * Replaced: vdutil/VDSunits.C for:  by hverstee for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *        MM/DD/YY      AUTHOR                DESCRIPTION
 *
 * -------------------------------------------------------------------*/

                /***************************************************/
                /*   VDSunits.c    All units accessing functions   */
                /***************************************************/

#include   <stdio.h>
#include   <math.h>
#include   <stdlib.h>

#include   "OMerrordef.h"
#include   "OMprimitives.h"
#include   "igrtypedef.h"

#include   "exproto.h"
#include   "exmacros.h"

#include   "ms.h"
#include   "msdef.h"
#include   "msmacros.h"
#include   "vdbmacros.h"
#include   "PDUerror.h"

#include   "VDDbDef.h"
#include   "VDmsg.h"

double  VDconv_to_vdsunits( family,par_name,units_set_in,
                              units_set_out, old_value)

char      *family;
char      *par_name;
int        units_set_in;
int        units_set_out;
IGRdouble     old_value;
{
  double      new_value1, new_value;

  char      *table=NULL;
  char      *select=NULL;
  char       search[MAX_WHERE_SIZE];
  int        rows, cols ;
  int        i,ret_msg;
  int        units_in=0, units_out=0;
  double     cnvr_fctr=0, cnvr_offset=0, rnd_off_fctr=0, resolution=0;
  char     **buffer;

  static  int   in_cache=0;
  static  int   vds_cnv_cnt;
  static  int   vds_unit_cnt;
  static struct VDSparam_units     VDS_param_units[MAX_VDS_UNITS_PARAMS];
  static struct VDS_convert        VDS_convert[MAX_VDS_CONVERT_COLS];

  if ( VDSverify_login() != PDM_S_SUCCESS )
  {
      ex$message(msgnumb = VD_E_PrUsNotLog);
      return 0;
  }

  if( !in_cache )
  {
    /***** First time get all the data from VDS_PARAM_UNITS &
           VDS_CONVERT into the cache                *******/

    table = "VDS_PARAM_UNITS";
    select = "family_name, param_name, units_set, units_code, resolution";
    search[0] = '\0';
    cols = 5;
    ret_msg =  
    vdb$RisSelect(  select        =     select,
                    table_name    =     table,
                    where         =     NULL,
                    order         =     NULL,
                    group         =     NULL,
                    numselect     =     cols,
                    p_numrows     =     &rows,
                    p_buffer      =     &buffer );
    if( ret_msg != 1) 
    {
      printf("Table VDS_PARAM_UNITS not found\n");
      vdb$RisFreeBuffer(  buffer     =    buffer, 
                          size       =    cols*rows);
      return 0;
    }
    /* fill VDS_param_units with the data */

    for ( i = 0; i < rows; i++ )
    {
      strcpy(VDS_param_units[i].family_name, buffer[0+i*cols]);
      strcpy(VDS_param_units[i].param_name, buffer[1+i*cols]);
      sscanf(buffer[2+i*cols],"%d",&(VDS_param_units[i].units_set));
      sscanf(buffer[3+i*cols],"%d",&(VDS_param_units[i].units_code));
      sscanf(buffer[4+i*cols],"%lf",&(VDS_param_units[i].resolution));

    }
    vds_unit_cnt = rows;


    table = "VDS_CONVERT";
    select = "units_in, units_out, cnvr_fctr, cnvr_offset, rndoff_fctr";
    search[0] = '\0';
    cols = 5;
    ret_msg   = 
    vdb$RisSelect(  select        =       select,
                    table_name    =       table,
                    where         =       NULL,
                    order         =       NULL,
                    group         =       NULL,
                    numselect     =       cols,
                    p_numrows     =       &rows,
                    p_buffer      =       &buffer );
    if(  ret_msg != 1)
    {
      printf("Table VDS_CONVERT not found\n");
      vdb$RisFreeBuffer( buffer   =    buffer,
                         size     =    cols*rows);
      return 0;
    } 
    /* fill VDS_CONVERT with the data */

    for ( i = 0; i < rows; i++ )
    {
      sscanf(buffer[0+i*cols],"%d",&(VDS_convert[i].units_in));
      sscanf(buffer[1+i*cols],"%d",&(VDS_convert[i].units_out));
      sscanf(buffer[2+i*cols],"%lf",&(VDS_convert[i].cnvr_fctr));
      sscanf(buffer[3+i*cols],"%lf",&(VDS_convert[i].cnvr_offset));
      sscanf(buffer[4+i*cols],"%lf",&(VDS_convert[i].rnd_off_fctr));
    }
    vds_cnv_cnt = rows;

    in_cache = 1;
    vdb$RisFreeBuffer( buffer   =      buffer,
                       size     =      cols*rows);
  }

  for( i = 0; i < vds_unit_cnt; i++ )
  {

    if((strcmp(VDS_param_units[i].param_name, par_name) == 0 ) &&
            (VDS_param_units[i].units_set == units_set_in ) && 
            (strcmp(VDS_param_units[i].family_name, family)==0))
    {
        units_in = VDS_param_units[i].units_code;
        resolution = VDS_param_units[i].resolution;
        break;
    }
  }
  if( units_in == 0 ) return old_value;

  for( i = 0; i < vds_unit_cnt; i++ )
  {
    if ((strcmp(VDS_param_units[i].param_name, par_name) == 0 ) &&
            (VDS_param_units[i].units_set == units_set_out ) &&
            (strcmp(VDS_param_units[i].family_name, family)==0))
    {
        units_out = VDS_param_units[i].units_code;
        resolution = VDS_param_units[i].resolution;
        break;
    }
  }
  if( units_out == 0 ) return old_value;


  /* Verify if the units are in FT^2 or M^2 etc and convert */
  /* them to base units. ie in mm or inches.                   */
  /* The units are codified in VDS_CODELIST                  */

  if( units_in == units_out )
  {
     if( units_in == 502 )
          return old_value*144; /* Area in In^2 */
     else if( units_in == 512 )
          return old_value*100; /* Area in MM^2 */
     else if( units_in == 513 )
          return old_value*1000*1000; /* Area in MM^2 */
     if( units_in == 602 )
          return old_value*12*12*12; /* Volume in In^3 */
     else if( units_in == 612 )
          return old_value*1000; /* Volume in MM^3 */
     else if( units_in == 613 )
          return old_value*1000*1000*1000; /* Volume in MM^3 */
     else
          return old_value;
  }
  else
  {
    for( i=0; i < vds_cnv_cnt; i++ )
    {
      if(( VDS_convert[i].units_in == units_in ) && 
         (VDS_convert[i].units_out == units_out ))
      {
        cnvr_fctr = VDS_convert[i].cnvr_fctr; 
        cnvr_offset = VDS_convert[i].cnvr_offset;
        rnd_off_fctr = VDS_convert[i].rnd_off_fctr; 
        break;
      }
    }

    new_value1 = old_value * cnvr_fctr + cnvr_offset;
    if( fabs(new_value1) < 0.00001)
      new_value = new_value1;
    else
      VDcorr_wrt_resol( new_value1, resolution, &new_value );

  /* Verify if the units are in FT^2 or M^2 etc and convert */
  /* them to base units. ie in mm or inches.                   */

     if( units_out == 502 )
          return new_value*144; /* Area in In^2 */
     else if( units_out == 512 )
          return new_value*100; /* Area in MM^2 */
     else if( units_out == 513 )
          return new_value*1000*1000; /* Area in MM^2 */
     else if( units_out == 602 )
          return new_value*12*12*12; /* Volume in In^3 */
     else if( units_out == 612 )
          return new_value*1000; /* Volume in MM^3 */
     else if( units_out == 613 )
          return new_value*1000*1000*1000; /* Volume in MM^3 */
     else
          return new_value;

  }
}

VDcorr_wrt_resol( new_value1, resolution, new_value )

IGRdouble        new_value1;
IGRdouble        resolution;
IGRdouble       *new_value;
{
  double    coeff;
  int       val1, val2, i=0;
  char      str_val[20], str1[6], str2[2];

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


int VdsGetPartUnits(family,n_itemname,n_itemrev,part_units)

char       *family;            /* Family Name to search   (I) */
char       *n_itemname;        /* Part Number                    (I) */
char       *n_itemrev;         /* Part Revision    (I) */
int        *part_units;        /* Units of the part    (O) */
{
  char     search[200];
  int      num, n_attr;
  char   **buf;
  int      i,len = 0,ret_msg;
  char     tmp_family[20];

  /* Added: 4-14-94 by mallik */
  /* The attributes stored in pdmparameters are upper case & lower case. */
  /* While attributes in nfmattributes are all lower case.               */

  strcpy( tmp_family, family );

  len = strlen( tmp_family );
  for( i = 0; i < len; i++ )
       tmp_family[i] = tolower( tmp_family[i] );

  /* Get n_tableno for table <family> from nfmtables */

  sprintf ( search, 
      "nfmattributes.n_tableno = nfmtables.n_tableno and nfmtables.n_tablename = '%s' and n_name = 'units_set' ",
                  tmp_family);

  n_attr = 2;
  ret_msg = 
  vdb$RisSelect(  select        =       "n_name,n_datatype", 
                  table_name    =       "nfmattributes,nfmtables",
                  where         =       search,
                  order         =       NULL,
                  group         =       NULL,
                  numselect     =       n_attr,
                  p_numrows     =       &num,
                  p_buffer      =       &buf );
  if(  ret_msg != 1) return 0;

  if ( num != 0 )  /* Means that units_set exists */
  {
    vdb$RisFreeBuffer (    buffer    =     buf,
                           size      =     n_attr*num);
    sprintf(search,"n_itemname='%s' and n_itemrev='%s'",n_itemname,n_itemrev);
    num = 0; n_attr=1;
    ret_msg =
    vdb$RisSelect(  select        =       "units_set",
                    table_name    =       tmp_family, 
                    where         =       search,
                    order         =       NULL,
                    group         =       NULL,
                    numselect     =       n_attr,
                    p_numrows     =       &num,
                    p_buffer      =       &buf );
    if(  ret_msg != 1) return 0;

    if (num != 0)
    {
      sscanf(buf[0],"%d", part_units );
      vdb$RisFreeBuffer ( buffer  =      buf,
                          size    =      n_attr*num);
    }
  }
  else 
    /*default part units = project units*/
  {
     VdsGetProjectUnits( part_units );
  }

  return 1;
}

int        VdsGetProjectUnits( project_units )

int        *project_units;

{
  IGRchar     project_num[21];
  IGRchar     project_rev[12];
  IGRint      prj_no;
  IGRboolean  found,inref;
  IGRint      sts;
  OMuword     osnum;

  if(VDSverify_project() != OM_S_SUCCESS) return 0;

  ex$get_cur_mod( osnum = &osnum );

  sts = VDCheckProjectNum(osnum,project_num,project_rev,
                          project_units, &prj_no,&found,&inref );
  if(sts != 1 )
     return 0;

  return 1;
}

int        VdsGetPrjNo( prj_no )

int        *prj_no;

{
  IGRchar     project_num[21];
  IGRchar     project_rev[12];
  IGRint      prj_units;
  IGRboolean  found,inref;
  IGRint      sts;
  OMuword     osnum;

  if(VDSverify_project() != OM_S_SUCCESS) return 0;

  ex$get_cur_mod( osnum = &osnum );

  sts = VDCheckProjectNum(osnum,project_num, project_rev,
                          &prj_units, prj_no,&found,&inref );
  if(sts != 1 )
     return 0;

  return 1;
}

int     VdsGetShipNum( ship_desc, ship_no )

char       *ship_desc;
int        *ship_no;
{
  char    search[200];
  int     num, n_attr,ret_msg;
  char  **buf;

  sprintf ( search, "ship_descr = '%s'", ship_desc);
  n_attr = 1;
  ret_msg =
  vdb$RisSelect(  select        =       "ship_no",
                  table_name    =       "ship_type",
                  where         =       search,
                  order         =       NULL,
                  group         =       NULL,
                  numselect     =       n_attr,
                  p_numrows     =       &num,
                  p_buffer      =       &buf );
  if (  ret_msg != 1) return 0;

  if (num == 0)
  {
    printf("ship number for %s not found\n", ship_desc );
    return(0);
  }
  else
    sscanf(buf[0],"%d", ship_no );
  return 1;
}

