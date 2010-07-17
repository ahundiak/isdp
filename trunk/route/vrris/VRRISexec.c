/* $Id: VRRISexec.c,v 1.1.1.1 2001/01/04 21:13:06 cvs Exp $  */

/***************************************************************************
 * I/ROUTE
 *
 * File:  vrpdu/VRRISexec.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRRISexec.c,v $
 *  Revision 1.1.1.1  2001/01/04 21:13:06  cvs
 *  Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/07/17  18:30:54  pinnacle
 * route 2.5
 *
 * Revision 1.1  1996/07/25  18:25:44  pinnacle
 * Creation of Route 241 project
 *
 * Revision 1.1  1996/04/24  20:29:14  pinnacle
 * Created: vrris/VRRISexec.c by hverstee for route240
 *
# Revision 1.3  1996/04/05  17:14:40  pinnacle
# Replaced: vrris/RISexec.rc for:  by ashankar for route240
#
# Revision 1.2  1996/04/05  17:10:14  pinnacle
# Replaced: vrris/RISexec.rc for:  by ashankar for route240
#
# Revision 1.1  1996/03/06  18:24:42  pinnacle
# Created: vrris/RISexec.rc by azuurhou for route240
#
 *
 * History:
 *  MM/DD/YY  AUTHOR    DESCRIPTION
 *  06/17/91   mman     creation date
 *  03/06/95   adz      Correction in initialization
 *                      TR 179528263 ;
 *  04/19/96   hv       created from RISexec.rc to correctly
 *                      handle re-initialization of statics
 ***************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include "PDUuser.h"
#include "PDUerror.h"
#include "VRDbStruct.h"
#include "VDmem.h"
#include "ris.h"

/***********************************************************/
/*  static externals to be cleared at DB logout            */

static short RIScpp_stmt_id0 = -1;
static short RIScpp_stmt_id1 = -1;
static short RIScpp_stmt_id2 = -1;
static short RIScpp_stmt_id3 = -1;
static short RIScpp_stmt_id4 = -1;
static short RIScpp_stmt_id5 = -1;
static short RIScpp_stmt_id6 = -1;
static short RIScpp_stmt_id7 = -1;
static short RIScpp_stmt_id8 = -1;

static int first_pipcomps_one;
static int first_pipcomcod;
static int first_pipschthk;
static int first_pipcomptyp;
static int first_pipcomps_two;
static int first_hvaccomps;
static int first_hvaccomptyp;
static int first_pipcodlst;

static  short   *stmt_idptr;
static  int     *swtc_ptr;

/**************************************************************/
/*    clear cache function                                    */

void VR_DbC_ClRIS ()
{

  /*     first see if we are still logged in    */

  if (VDSverify_login() == PDM_S_SUCCESS)
  {   /*   clear all open queries so we can start cleanly again   */
    if (first_pipcomps_one)
      RISint_clear(&RIScpp_stmt_id1, 0, 7);
    if (first_pipcomcod)
      RISint_clear(&RIScpp_stmt_id2, 0, 7);
    if (first_pipschthk)
      RISint_clear(&RIScpp_stmt_id3, 0, 7);
    if (first_pipcomptyp)
      RISint_clear(&RIScpp_stmt_id4, 0, 7);
    if (first_pipcomps_two)
      RISint_clear(&RIScpp_stmt_id5, 0, 7);
    if (first_hvaccomps)
      RISint_clear(&RIScpp_stmt_id6, 0, 7);
    if (first_hvaccomptyp)
      RISint_clear(&RIScpp_stmt_id7, 0, 7);
    if (first_pipcodlst)
      RISint_clear(&RIScpp_stmt_id8, 0, 7);
  }

  RIScpp_stmt_id0 = -1;
  RIScpp_stmt_id1 = -1;
  RIScpp_stmt_id2 = -1;
  RIScpp_stmt_id3 = -1;
  RIScpp_stmt_id4 = -1;
  RIScpp_stmt_id5 = -1;
  RIScpp_stmt_id6 = -1;
  RIScpp_stmt_id7 = -1;
  RIScpp_stmt_id8 = -1;

  first_pipcomps_one = 0;
  first_pipcomcod    = 0;
  first_pipschthk    = 0;
  first_pipcomptyp   = 0;
  first_pipcomps_two = 0;
  first_hvaccomps    = 0;
  first_hvaccomptyp  = 0;
  first_pipcodlst    = 0;

  return;
}


int    VRRIS_setstatic (int   stmt_id)
{
  int     errcd;

  errcd = 0;

  switch(stmt_id)
  {
    case PIP_COMPS1_PREP_ID2:
      stmt_idptr = &RIScpp_stmt_id1;
      swtc_ptr   = &first_pipcomps_one;
      break;

    case PIP_COMCOD_PREP_ID3:
      stmt_idptr = &RIScpp_stmt_id2;
      swtc_ptr   = &first_pipcomcod;
      break;

    case PIP_SCHTHK_PREP_ID4:
      stmt_idptr = &RIScpp_stmt_id3;
      swtc_ptr   = &first_pipschthk;
      break;

    case PIP_COMPTYP_PREP_ID5:
      stmt_idptr = &RIScpp_stmt_id4;
      swtc_ptr   = &first_pipcomptyp;
      break;

    case PIP_COMPS2_PREP_ID6:
      stmt_idptr = &RIScpp_stmt_id5;
      swtc_ptr   = &first_pipcomps_two;
      break;

    case HVAC_COMPS_PREP_ID7:
      stmt_idptr = &RIScpp_stmt_id6;
      swtc_ptr   = &first_hvaccomps;
      break;

    case HVAC_COMPTYP_PREP_ID8:
      stmt_idptr = &RIScpp_stmt_id7;
      swtc_ptr   = &first_hvaccomptyp;
      break;

    case PIP_CODLST_PREP_ID9:
      stmt_idptr = &RIScpp_stmt_id8;
      swtc_ptr   = &first_pipcodlst;
      break;

    default:
      printf("VRRISexec  Invalid statement id %d\n",stmt_id);
      stmt_idptr = NULL;
      swtc_ptr   = NULL;
      errcd = 1;
      break;
  }

  return (errcd);
}


int
RISexecute_query (char     *ris_string, /* RIS command string        */
           struct VRrisdat  out_data[], /* output data if any        */
                  int      *rows,       /* no. of rows retrieved     */
                  int      *cols,       /* no. of columns            */
                  int      *dat_cnt)    /* count of output structs   */
{
/*******************************************************************/
/*                                                                 */
/* This routines executes any RIS command and returns data incase  */
/* there is any output.                                            */
/*                                                                 */
/*******************************************************************/

  int          i,  j;
  int          SqlError;
  char         buffer[100];
  sqlda        in_desc;
  sqlda        out_desc;
  int          count;
  char       * err_ptr;

        /* Initialize structures */

  *rows    = 0 ;
  *dat_cnt  = 0 ;
  
  j  = 0 ;
  count  = 0 ;

  in_desc.sqld = 0;
  in_desc.sqln = 0;
  in_desc.sqlvar = 0;

  out_desc.sqld = 0;
  out_desc.sqln = 0;
  out_desc.sqlvar = 0;

  RISint_prepare(&RIScpp_stmt_id0,ris_string,1,0);
  if (RISget_sqlcode() != RIS_SUCCESS) goto error;
  
  RISint_describe(RIScpp_stmt_id0,&in_desc,0);
  if (RISget_sqlcode() != RIS_SUCCESS) goto error;

#ifdef RISQUERY_INPUT

  if (in_desc.sqld)
  {
    in_desc.sqlvar = _MALLOC(in_desc.sqld, sqlvar );

    for ( i = 0; i < in_desc.sqld; ++i )
    {
      in_desc.sqlvar[i].sqldata = NULL ;
      in_desc.sqlvar[i].sqlind  = NULL ;
      in_desc.sqlvar[i].sqlnull = 0;
    }

    in_desc.sqln = in_desc.sqld;
  
    RISint_describe(RIScpp_stmt_id0,&in_desc,0);
    if (RISget_sqlcode() != RIS_SUCCESS) goto error;

    for( i = 0; i < in_desc.sqld; ++i)
    {
      gets(buffer);

      in_desc.sqlvar[i].sqldata = _MALLOC(in_desc.sqlvar[i].sqllen, char);
  
      if (buffer[0] == '\0')
      {
        *in_desc.sqlvar[i].sqldata = '\0';
        in_desc.sqlvar[i].sqlnull = 1;
        in_desc.sqlvar[i].sqlind = _MALLOC(1, long );
        *in_desc.sqlvar[i].sqlind = -1;
      }
      else
      {
        in_desc.sqlvar[i].sqlnull = 0;
        switch(in_desc.sqlvar[i].sqltype)
        {
          case RIS_CHARACTER:
            strncpy(in_desc.sqlvar[i].sqldata, buffer,
            in_desc.sqlvar[i].sqllen);
            break;

          case RIS_SMALLINT:
            sscanf(buffer, "%hd", in_desc.sqlvar[i].sqldata);
            break;

          case RIS_INTEGER:
            sscanf(buffer, "%d", in_desc.sqlvar[i].sqldata);
            break;

          case RIS_REAL:
            sscanf(buffer, "%f", in_desc.sqlvar[i].sqldata);
            break;

          case RIS_DOUBLE:
            sscanf(buffer, "%lf", in_desc.sqlvar[i].sqldata);
            break;

          default:
            printf("VRRISexec - Invalid data type found\n");
            exit(0);
        }
      }
    }
  }
#endif

  RISint_describe(RIScpp_stmt_id0,&out_desc,1);
  if (RISget_sqlcode() != RIS_SUCCESS) goto error;

  if (out_desc.sqld == 0)
  {
    RISint_execute(&RIScpp_stmt_id0,0,&in_desc,7,1,0);
    if (RISget_sqlcode() == END_OF_DATA) goto not_found;
    else
    if (RISget_sqlcode() != RIS_SUCCESS) goto error;

    RISint_clear(&RIScpp_stmt_id0, 0, 7);
    if (RISget_sqlcode() != RIS_SUCCESS) goto error;

    return 1;
  }
  
  /* declare for statement id requires no work just return success */
  RISint_set_sqlcode(RIS_SUCCESS);

  RISint_execute(&RIScpp_stmt_id0,0,&in_desc,7,1,0);
  if (RISget_sqlcode() != RIS_SUCCESS) goto error;

  out_desc.sqlvar = _MALLOC(out_desc.sqld, sqlvar );
  out_desc.sqln = out_desc.sqld;

  for ( i = 0 ; i < out_desc.sqld; ++i )
  {
    out_desc.sqlvar[i].sqldata = NULL ;
    out_desc.sqlvar[i].sqlind  = NULL ;
    out_desc.sqlvar[i].sqlnull = 0;
  }
  
  RISint_describe(RIScpp_stmt_id0,&out_desc,1);
  if (RISget_sqlcode() != RIS_SUCCESS) goto error;

  *cols = out_desc.sqld;

  for ( i = 0; i < out_desc.sqld; ++i )
  {
    out_desc.sqlvar[i].sqldata = _MALLOC(out_desc.sqlvar[i].sqllen, char);
    out_desc.sqlvar[i].sqlind  = _MALLOC(1, long );
    out_desc.sqlvar[i].sqlnull = 1;
  }

  for (j=0, count=0;;)
  {
    RISint_fetch(RIScpp_stmt_id0,0,&out_desc,0,7);
    SqlError = RISget_sqlcode();

    if (SqlError == END_OF_DATA) goto not_found;

    if (SqlError != RIS_SUCCESS) goto error;

    count++;

    for (i = 0; i < out_desc.sqld; ++i)
    {
      strncpy( out_data[j].name, out_desc.sqlvar[i].sqlname.sqlnamec,
                                   out_desc.sqlvar[i].sqlname.sqlnamel );
      out_data[j].name[out_desc.sqlvar[i].sqlname.sqlnamel] = 0;

      switch(out_desc.sqlvar[i].sqltype)
      {
        case RIS_CHARACTER:
          out_data[j].data.type = VR_RISDB_TEXT;
          take_trailing_blanks_off( out_desc.sqlvar[i].sqldata,
                                    out_desc.sqlvar[i].sqllen);
/*        strncpy(out_data[j].data.val.attr_c, out_desc.sqlvar[i].sqldata,
                                                out_desc.sqlvar[i].sqllen); */
          strcpy(out_data[j].data.val.attr_c, out_desc.sqlvar[i].sqldata); 
          out_data[j].data.val.attr_c[out_desc.sqlvar[i].sqllen] = 0;
          break;

        case RIS_INTEGER:
          out_data[j].data.type = VR_RISDB_INT;
          sprintf(buffer,"%d", *(int*)out_desc.sqlvar[i].sqldata);
          out_data[j].data.val.attr_int = atoi(buffer);
          break;

        case RIS_SMALLINT:
          out_data[j].data.type = VR_RISDB_INT;
          sprintf(buffer, "%hd", *(short*)out_desc.sqlvar[i].sqldata);
          out_data[j].data.val.attr_int = atoi(buffer);
          break;

        case RIS_DOUBLE:
          out_data[j].data.type = VR_RISDB_DOUBLE;
          sprintf(buffer,"%lf", *(double*)out_desc.sqlvar[i].sqldata);
          out_data[j].data.val.attr_dbl = atof(buffer);
          break;

        case RIS_REAL:
          out_data[j].data.type = VR_RISDB_DOUBLE;
          sprintf(buffer,"%f", *(float*)out_desc.sqlvar[i].sqldata);
          out_data[j].data.val.attr_dbl = atof(buffer);
          break;

        default:
          break;
      }

      j++;
    }  
  }

  not_found:

  RISint_close(RIScpp_stmt_id0, 0, 7);
  if (RISget_sqlcode() != RIS_SUCCESS) goto error;

  /*        exec sql clear cursor curs1;*/
  RISint_clear(&RIScpp_stmt_id0, 0, 7);
  if (RISget_sqlcode() != RIS_SUCCESS) goto error;

  RIScpp_stmt_id0 = -1;

  if( in_desc.sqlvar )
  {
    for(i=0; i< in_desc.sqld; i++)
    {
        _FREE(in_desc.sqlvar[i].sqldata);
        _FREE(in_desc.sqlvar[i].sqlind);          
    }
    _FREE(in_desc.sqlvar);
  }

  if( out_desc.sqlvar )
  {
    for(i=0; i< out_desc.sqld; i++)
    {
        _FREE(out_desc.sqlvar[i].sqldata);
        _FREE(out_desc.sqlvar[i].sqlind);          
    }
    _FREE(out_desc.sqlvar);
  }

  *rows = count;
  *dat_cnt = j;
  return 1;
  
  error:

  RISint_close(RIScpp_stmt_id0, 0, 7);

  /*        exec sql clear cursor curs1; */
  RISint_clear(&RIScpp_stmt_id0, 0, 7);

  RIScpp_stmt_id0 = -1;

  RISint_report_error(0,&err_ptr);

  puts(err_ptr);

  if( in_desc.sqlvar )
  {
    for(i=0; i< in_desc.sqld; i++)
    {
        _FREE(in_desc.sqlvar[i].sqldata);
        _FREE(in_desc.sqlvar[i].sqlind);          
    }
    _FREE(in_desc.sqlvar);
  }

  if( out_desc.sqlvar )
  {
    for(i=0; i< out_desc.sqld; i++)
    {
         _FREE(out_desc.sqlvar[i].sqldata);
         _FREE(out_desc.sqlvar[i].sqlind);          
    }
    _FREE(out_desc.sqlvar);
  }

  return 0;
}


int RISprepare_query(char    *ris_string, /* RIS command string        */
                     int      stmt_id)
{
  char * err_ptr;
  int    dberr;

  if (VRRIS_setstatic (stmt_id) != 0) return 1;

  /* prepare a dynamic SQL statement */
       
  if (*swtc_ptr == 0)
  {
    RISint_prepare(stmt_idptr, ris_string, 1, 0);

    dberr = RISget_sqlcode();

    if (dberr != RIS_SUCCESS)
    {
      RISint_report_error(0,&err_ptr);
      puts(err_ptr);

      return 0;
    }

    *swtc_ptr = 1;
  }

  return 1;
}


int
RISexecute_query1 (

     int              stmt_idx,
     char             inp_buf[10][20], /* buffer for input data     */
     int              inp_cnt,     /* no of elements in buffer  */
     struct VRrisdat  out_data[],  /* output data if any        */
     int              *rows,       /* no. of rows retrieved     */
     int              *cols,       /* no. of columns            */
     int              *dat_cnt)    /* count of output structs   */
{
/*******************************************************************/
/*                                                                 */
/* This routines executes ONLY SELECT statements and returns data  */
/* incase there is any output.                                     */
/*                                                                 */
/*******************************************************************/

  int     i,  j;
  int     count;
  int     SqlError;
  sqlda   in_desc;
  sqlda   out_desc;
  char    buffer[100];
  char   *err_ptr;

  /* Initialize structures */

  *rows    = 0 ;
  *dat_cnt  = 0 ;
  
  j  = 0 ;
  count  = 0 ;

  in_desc.sqld    = 0;
  in_desc.sqln    = 0;
  in_desc.sqlvar  = NULL;
  
  out_desc.sqld   = 0;
  out_desc.sqln   = 0;
  out_desc.sqlvar = NULL;

  if (VRRIS_setstatic (stmt_idx) != 0) return 1;

  /* see if there are any input parameters */
  
  RISint_describe(*stmt_idptr, &in_desc, 0);

  if (in_desc.sqld)
  {
    /* allocate input buffers for any input parameters */

    in_desc.sqlvar = _MALLOC(in_desc.sqld, sqlvar );
    in_desc.sqln = in_desc.sqld;
    for ( j = 0; j < in_desc.sqld; j++ )
    {
      in_desc.sqlvar[j].sqldata = NULL ;
      in_desc.sqlvar[j].sqlind  = NULL ;
      in_desc.sqlvar[j].sqlnull = 0;
    }
  
    /* get information about the input parameters */
  
    RISint_describe(*stmt_idptr, &in_desc, 0);
    if (RISget_sqlcode() != RIS_SUCCESS) goto error;

    if(inp_cnt != in_desc.sqld )
    { 
      printf
      ("RISexecute_query1:Invalid no of input parameters in input buffer\n");
    }

    for (i = 0; i < in_desc.sqld; ++i)
    {
      /* set up the program address, and (optional) indicator */
      in_desc.sqlvar[i].sqldata = _MALLOC(in_desc.sqlvar[i].sqllen, char);
  
      in_desc.sqlvar[i].sqlnull = 0;
      switch(in_desc.sqlvar[i].sqltype)
      {
        case RIS_CHARACTER:
          strncpy(in_desc.sqlvar[i].sqldata, inp_buf[i],
                 in_desc.sqlvar[i].sqllen);
          break;

        case RIS_SMALLINT:
          sscanf(inp_buf[i], "%hd", in_desc.sqlvar[i].sqldata);
          break;

        case RIS_INTEGER:
          sscanf(inp_buf[i], "%d", in_desc.sqlvar[i].sqldata);
          break;

        case RIS_REAL:
          sscanf(inp_buf[i], "%f", in_desc.sqlvar[i].sqldata);
          break;

        case RIS_DOUBLE:
          sscanf(inp_buf[i], "%lf", in_desc.sqlvar[i].sqldata);
          break;

        default:
          printf("RISexecute_query1:Invalid data type in input buffer\n");
          break;
      }
    }
  }

  /*
  **  if the statement is not a SELECT statement (sqld == 0),
  **    execute the statement.
  **  else
  **    declare a cursor for, open, and fetch from the statement.
  */

  /* get the count of output */

  RISint_describe(*stmt_idptr, &out_desc, 1);
  if (RISget_sqlcode() != RIS_SUCCESS) goto error;

  RISint_set_sqlcode(RIS_SUCCESS);

  /* open the SELECT statement */

  RISint_execute (stmt_idptr,0,&in_desc,7,1,0);
  if (RISget_sqlcode() != RIS_SUCCESS) goto error;

  /*
  **  allocate a sqlvar struct for each column and call describe
  **  again to get information about each result column.
  */

  out_desc.sqlvar = _MALLOC(out_desc.sqld, sqlvar );
  out_desc.sqln = out_desc.sqld;
  for ( i = 0; i < out_desc.sqld; ++i )
  {
    out_desc.sqlvar[i].sqldata = NULL ;
    out_desc.sqlvar[i].sqlind  = NULL ;
    out_desc.sqlvar[i].sqlnull = 0;
  }

  RISint_describe(*stmt_idptr, &out_desc, 1);
  if (RISget_sqlcode() != RIS_SUCCESS) goto error;

  *cols = out_desc.sqld;

  /* allocate buffers for each result column */
  for ( i = 0; i < out_desc.sqld; ++i )
  {
    out_desc.sqlvar[i].sqldata = _MALLOC(out_desc.sqlvar[i].sqllen, char);
    out_desc.sqlvar[i].sqlind = _MALLOC(1, long );
    out_desc.sqlvar[i].sqlnull = 1;
  }

  for (j = 0, count = 0;;)
  {
      /* fetch a row of output */

     RISint_fetch(*stmt_idptr, 0, &out_desc,0,7);
     SqlError = RISget_sqlcode();

     if (SqlError == END_OF_DATA) goto not_found;

     if (SqlError != RIS_SUCCESS) goto error;

     count++;

     for (i = 0; i < out_desc.sqld; ++i)
     {
        /* Check if value is NULL */
        /* Get column name  */
        strncpy( out_data[j].name, out_desc.sqlvar[i].sqlname.sqlnamec,
                                     out_desc.sqlvar[i].sqlname.sqlnamel );
        out_data[j].name[out_desc.sqlvar[i].sqlname.sqlnamel] = 0;

        switch(out_desc.sqlvar[i].sqltype)
        {
          case RIS_CHARACTER:
            out_data[j].data.type = VR_RISDB_TEXT;
            take_trailing_blanks_off( out_desc.sqlvar[i].sqldata,
                                      out_desc.sqlvar[i].sqllen);
/*          strncpy(out_data[j].data.val.attr_c, out_desc.sqlvar[i].sqldata,
                                                out_desc.sqlvar[i].sqllen); */
            strcpy(out_data[j].data.val.attr_c, out_desc.sqlvar[i].sqldata); 
            out_data[j].data.val.attr_c[out_desc.sqlvar[i].sqllen] = 0;
            break;

          case RIS_INTEGER:
            out_data[j].data.type = VR_RISDB_INT;
            sprintf(buffer,"%d", *(int*)out_desc.sqlvar[i].sqldata);
            out_data[j].data.val.attr_int = atoi(buffer);
            break;

          case RIS_SMALLINT:
            out_data[j].data.type = VR_RISDB_INT;
            sprintf(buffer, "%hd", *(short*)out_desc.sqlvar[i].sqldata);
            out_data[j].data.val.attr_int = atoi(buffer);
            break;

          case RIS_DOUBLE:
            out_data[j].data.type = VR_RISDB_DOUBLE;
            sprintf(buffer,"%lf", *(double*)out_desc.sqlvar[i].sqldata);
            out_data[j].data.val.attr_dbl = atof(buffer);
            break;

          case RIS_REAL:
            out_data[j].data.type = VR_RISDB_DOUBLE;
            sprintf(buffer,"%f", *(float*)out_desc.sqlvar[i].sqldata);
            out_data[j].data.val.attr_dbl = atof(buffer);
            break;

          default:
            break;
        }

        j++;
      }  
    }
                  
not_found:

  RISint_close (*stmt_idptr, 0, 7);
  if (RISget_sqlcode() != RIS_SUCCESS) goto error;

  if( in_desc.sqlvar )
  {
    for(i=0; i< in_desc.sqld; i++)
    {
       _FREE(in_desc.sqlvar[i].sqldata);
       _FREE(in_desc.sqlvar[i].sqlind);          
    }
    _FREE(in_desc.sqlvar);
  }

  if( out_desc.sqlvar )
  {
    for(i=0; i< out_desc.sqld; i++)
    {
      _FREE(out_desc.sqlvar[i].sqldata);
      _FREE(out_desc.sqlvar[i].sqlind);          
    }
    _FREE(out_desc.sqlvar);
  }

  *rows = count;
  *dat_cnt = j;
  return 1;
  
error:

  RISint_report_error(0,&err_ptr);

  puts(err_ptr);

  RISint_close (*stmt_idptr, 0, 7);

  if( in_desc.sqlvar )
  {
    for(i=0; i< in_desc.sqld; i++)
    {
      _FREE(in_desc.sqlvar[i].sqldata);
      _FREE(in_desc.sqlvar[i].sqlind);          
    }
    _FREE(in_desc.sqlvar);
  }

  if( out_desc.sqlvar )
  {
    for(i=0; i< out_desc.sqld; i++)
    {
      _FREE(out_desc.sqlvar[i].sqldata);
      _FREE(out_desc.sqlvar[i].sqlind);          
    }
    _FREE(out_desc.sqlvar);
  }

  return 0;
}


int take_trailing_blanks_off (char *sqlstring,
                              int   sqllen)
{
  int  i;

  i=sqllen -1;
  while( sqlstring[i] == ' ' && i != 0 )
     sqlstring[i--] = 0;
  return 0;
}


