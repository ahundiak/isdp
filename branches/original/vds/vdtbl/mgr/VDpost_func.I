
/* $Id: VDpost_func.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDpost_func.I
 *
 * Description:
 *
 * Implementation file for table manager post service functions
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDpost_func.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:28  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.7  1996/02/15  23:15:28  pinnacle
# Replaced: ./vdtbl/mgr/VDpost_func.I for:  by azuurhou for vds.240
#
# Revision 1.6  1995/11/17  22:23:20  pinnacle
# Replaced: vdtbl/mgr/VDpost_func.I for:  by hverstee for vds.240
#
# Revision 1.5  1995/09/08  21:25:18  pinnacle
# Replaced: vdtbl/mgr/VDpost_func.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/08/25  15:17:10  pinnacle
# Replaced: vdtbl/mgr/VDpost_func.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/08/18  20:50:56  pinnacle
# Replaced: vdtbl/mgr/VDpost_func.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/19  19:33:16  pinnacle
# Created: vdtbl/mgr/VDpost_func.I by hverstee for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      06/12/95          HV            New
 *	02/15/96	  HV		ISL Correction.
 *
 * -------------------------------------------------------------------*/

class implementation Root;

#include <ctype.h>
#include <string.h>
#include <stdio.h>

#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "go.h"
#include "ASmatrix.h"
#include "asdef.h"
#include "asmacros.h"
#include "acmacros.h"
#include "asbox.h"
#include "AS_status.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "nddef.h"
#include "acrepdef.h"
#include "exdef.h"
#include "exmacros.h"
#include "msmacros.h"
#include "vdbmacros.h"

#include "VDSpdudef.h"
#include "vdbmacros.h"
#include "VDScheckin.h"
#include "VDScheckdef.h"
#include "VDSris_def.h"
#include "VDSris_siz.h"
#include "VDDbtbldef.h"
#include "vdbmacros.h"

#include "PDUerror.h"

#include "VDdrwlo.h"
#include "VDdrwlo_db.h"
#include "VDdrwlo_int.h"
#include "VDdrwlo_pr.h"
#include "VDmem.h"

#include "v_postproto.h"

typedef  IGRchar   *  ICHRptr;

#define   MY_NUMCOL     30

/*
#define   MY_DEBUG
*/


void   VD_mv_Esc_Quote (IGRchar      *szOut,
                        IGRchar      *szIn,
                        IGRint        MaxLen)
{
  IGRint      iIn, iOut;

  iIn = iOut = 0;

  while (szIn[iIn] != '\0')
  {
    if (szIn[iIn] == '\'')
    {
      if (iOut >= (MaxLen - 2)) break;

      szOut[iOut] = '\\';
      iOut++;
      szOut[iOut] = 'Q';
      iOut++;
    }
    else
    {
      if (iOut >= (MaxLen - 1)) break;

      szOut[iOut] = szIn[iIn];
      iOut++;
    }

    iIn++;
  }

  szOut[iOut]     = '\0';
  szOut[MaxLen-1] = '\0';

  return;
}

void   VD_mv_Iin_Quote (IGRchar      *szOut,
                        IGRchar      *szIn)
{
  IGRint      iIn, iOut;

  iIn = iOut = 0;

  while (szIn[iIn] != '\0')
  {
    if ((szIn[iIn] == '\\') && (szIn[iIn+1] == 'Q'))
    {
      szOut[iOut] = '\'';
      iOut++;
      iIn += 2;
    }
    else
    {
      szOut[iOut] = szIn[iIn];
      iOut++;
      iIn++;
    }
  }

  szOut[iOut] = '\0';

  return;
}


void   VD_post_prt (IGRint     columns,
                    IGRint    *col_typ,
                    IGRchar  **col_value)
{
  IGRint      i;
  IGRshort   *ip;
  IGRchar    *cp;
  IGRdouble  *dp;
  float      *fp;

  for (i=0;i<columns;i++)
  {
    if (col_typ[i] == SMALLINT)
    {
      ip = (IGRshort *) col_value[i];
      printf ("%d ",*ip);
    }
    else
    if (col_typ[i] == DOUBLE)
    {
      dp = (IGRdouble *) col_value[i];
      printf ("%f ",*dp);
    }
    else
    if (col_typ[i] == REAL)
    {
      fp = (float *) col_value[i];
      printf ("%f ",*fp);
    }
    else
    {
      cp = col_value[i];
      printf ("%s ",cp);
    }
  }

  printf ("\n");

  return;
}


IGRboolean  VD_db_table_haskey  (IGRchar      *tabnam,
                                 IGRchar      *keynam,
                                 IGRchar      *keyval)

{
  IGRboolean   bRetval;

  bRetval = FALSE;

  if ((tabnam != NULL) && (keynam != NULL) && (keyval != NULL))
  {
    IGRint         status;
    IGRchar        whout[40];
    IGRchar      **DbIO;
    IGRint         NbRow;

    DbIO = NULL;

    strcpy (whout, keynam);
    strcat (whout, "=\'");
    strcat (whout, keyval);
    strcat (whout, "\'");

#ifdef MY_DEBUG
  printf ("haskey %s %s %s %s\n",tabnam,keynam,keyval,whout);
#endif

    status=
    vdb$RisSelect (select     = keynam,
                   table_name = tabnam,
                   where      = whout,
                   numselect  = 1,
                   p_numrows  = &NbRow,
                   p_buffer   = &DbIO);

    if (status & OM_S_SUCCESS )
      bRetval = (NbRow > 0);

#ifdef MY_DEBUG
  printf ("haskey %d %d\n",NbRow, bRetval);
#endif

    VdsRisFreeBuffer (DbIO, NbRow);
  }

  return (bRetval);
}


/******************************************************************************/
/*     returns SUCCESS or FAILURE!!!!!       */
/******************************************************************************/
IGRint VD_post_SqlInsVal   (IGRchar      *tabnam,
                            IGRint        col_num,
                            IGRint       *col_typ,
                            IGRint       *num_chr,
                            IGRchar     **col_val)

{
  
  char  *query;
  int    i;
  int    alloc_len;
  int    sts;
  int    inc_alloc;
  char   addq[20];
  char   szDumm[VD_DRWLO_CHR_BUFFER];

  int         *ip;
  short int   *sp;
  float       *fp;
  double      *dp;

  query = NULL;
  sts = SUCCESS;

  /*|Open the RIS schema */
  if (VdsRisAttach() != SUCCESS) return FAILURE;

  /*|Discard NULL table */
  if (tabnam == NULL || tabnam[0] == 0)
  {
    printf("Vds_SqlInsVal Error : table name is null\n");
    return FAILURE;
  }

  /*|Discard 0 col_num */
  if (col_num <= 0)
  {
    printf("VD_post_SqlInsVal Error : Number of columns = %d\n",col_num);
    return FAILURE;
  }

  /* Allocate memory for statement */
  alloc_len = strlen(tabnam);
  for (i=0;i<col_num;i=i+1)
  {
    if (col_typ[i] == CHAR) inc_alloc = strlen(col_val[i]) + 5;
    else                    inc_alloc = 10;

    alloc_len += inc_alloc;
  }

  query = _MALLOC ((alloc_len+80) ,char);
  if (query == NULL)
  {
    printf
     ("VdsRisUpdate Error : Cannot allocate memory for statement buffer\n");
    return (FAILURE);
  }

  sprintf ( query, "insert into %s values (", tabnam);

  for (i=0;i<col_num;i++)
  {
     switch (col_typ[i])
     {
        case DATE:
          strcat (query, "timestamp ");
          /*    fall through    */

        case CHAR:
        case NUMERIC:    /*   ?????   */
        case DECIMAL:    /*   ?????   */
        default:
          VD_mv_Esc_Quote (szDumm, col_val[i], num_chr[i]);

          strcat (query, "'");
          strcat (query, szDumm);
          strcat (query, "'");
          break;

        case INT:
          ip = (int *) col_val[i];
          sprintf (addq,"%d", *ip);
          goto ADD_IT;
          
        case SMALLINT:
          sp = (short int *) col_val[i];
          sprintf (addq,"%d", *sp);
          goto ADD_IT;

        case REAL:
          fp = (float *) col_val[i];
          sprintf (addq,"%f", *fp);
          goto ADD_IT;

        case DOUBLE:
          dp = (double *) col_val[i];
          sprintf (addq,"%f", *dp);

          ADD_IT:
          strcat (query,addq);
          break;
     }

     if ( i < col_num -1) strcat (query,",");
  }

  strcat (query,")");

#ifdef MY_DEBUG
  printf ("QUERY - %s\n",query);
#endif

  sts = VDSexecute_sql_stmt ( query );

  _FREE (query);
  return (sts);
}

end implementation Root;

