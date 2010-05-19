/* $Id: VDSPartAtt.C,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdutil / VDSPartAtt.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSPartAtt.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:31  cvs
 *	Initial import to CVS
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
 * Revision 1.2  1996/03/07  21:43:26  pinnacle
 * Replaced: vdutil/VDSPartAtt.C for:  by msmanem for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      03/07/96         Mallik         Fix for TR#179600126
 *
 * -------------------------------------------------------------------*/

/*      File         : VDSPartAtt.C                                       */ 
/*      The function VDGetPartAtt is intended to replace VDSget_attr      */
/*      (structure returned is ACrg_collection instead of  VDSatt_family  */
/*      Author        : Jean Jasinczuk, Mallik Manem                      */ 
/*      Creation date :  19 May 93                                        */
/*	Modification  :   6 Nov 93, Mallik. Added an argument stat_attr_filled */



#include	<stdio.h>
#include	"igrtypedef.h"
#include	"OMprimitives.h"
#include	"ACattrib.h"
#include	"ACrg_collect.h"
#include	"VDSutil.h"
#include	"vdbmacros.h"

#define		MAX_WORD	81

extern double 	VDconv_to_vdsunits();

/* ----------------------------------------------------------------------*/
/*
   VDSGetPartAtt:
  
  	This function returns the parameters with their types, theirs values
   and all which are interesting to create a rg_collection. The returned 
   attributes are split into two structures, one for the dynamic, one
   for the static.
  
   	Inside the static returned structure, the family name, part name
   and the revision has been added at the begining.
  
   Notes:
  
  	The ACrg_collection structures "attr" are allocated by this function 
   and must be freed by the user.
   For dynamic attributes both pointer nb_att and ACrg can be NULL
   (at the same time).
   
*/  
/* ----------------------------------------------------------------------*/

VDSGetPartAtt(
char   *family,                     /* family name               (I) */
char   *part,                       /* part name                 (I) */
char   *part_rev,                   /* part revision             (I) */
char   *category,                   /* category only if "EQUIP"  (I) */ 
int    *nb_stat,                    /* number of static attr     (O) */
struct ACrg_coll  **stat_attr,      /* static attribute descipt  (O) */
int    *nb_dyn,                     /* number of dyn attr        (O) */
struct ACrg_coll   **dyn_attr       /* dynamic attribute descipt (O) */
)
{
  char      mess[100];
  char      search[200];
  char	    *select=NULL;
  int       num_attr_buf,num;
  char      **attr_buf,**buf;
  char      family_tableno[15],y_family_tableno[15];
  /*char      p_macro[15]; */
  int       n_attr_buf,n_attr;
  int       dyn_load_att,ret_msg;
  int	    i,j,nb_s,nb_d;
  int       part_units, VDSproject_units, p_macro_exists=0;
  double    temp_val;

/*
char date[50];
NFMget_datetime(date); printf("Entering ..Date = %s\n",date );
*/

  if(nb_stat)   *nb_stat = 0;
  if(stat_attr) *stat_attr = (struct ACrg_coll *) NULL;
  if(nb_dyn)    *nb_dyn  = 0;
  if(dyn_attr)  *dyn_attr = (struct ACrg_coll *) NULL;


  /* --------------------- Static attributes ----------------------*/

  if(!nb_stat || !stat_attr) goto dyn_attrib;

  VdsGetPartUnits(family,part,part_rev,&part_units);
  VdsGetProjectUnits( &VDSproject_units );

  /* Static attibutes are non NFM/PDM attributes in <family> table */

  /* Get n_tableno for table <family> from nfmtables */

  sprintf ( search, "n_tablename = '%s' ", family );
  n_attr_buf = 1;
  ret_msg =
  vdb$RisSelect(  select      =      "n_tableno",
                  table_name  =      "nfmtables",
                  where       =      search,
                  order       =      NULL,
                  group       =      NULL,
                  numselect   =      n_attr_buf,
                  p_numrows   =      &num,
                  p_buffer    =      &buf );

  if ( ret_msg != 1 ) return 0;
  if ( num != 0 )
  {
    strcpy( family_tableno,buf[0] );
    vdb$RisFreeBuffer ( buffer =      buf,
                        size   =      n_attr_buf*num);
  }

  /* Query the Attributes of the table */

  sprintf ( search, "n_tableno = %s and n_name not like 'units_set'", family_tableno );

  n_attr_buf = 2;
  ret_msg =
  vdb$RisSelect(  select      =      "n_name,n_datatype",
                  table_name  =      "nfmattributes",
                  where       =      search,
                  order       =      NULL,
                  group       =      NULL,
                  numselect   =      n_attr_buf,
                  p_numrows   =      &num_attr_buf,
                  p_buffer    =      &attr_buf );

  if ( ret_msg != 1 ) return 0;

  for ( i=0; i < num_attr_buf; i++ )
    if (!strcmp( attr_buf[i*2], "p_macro" ))
    {
	p_macro_exists = 1;
	break;
    }

/* REPLACED THE JOIN WITH 2 QUERIES Mallik 15/12/95

  sprintf ( search, "nfmattributes.n_tableno = nfmtables.n_tableno and nfmtables.n_tablename = '%s' and n_name not like 'units_set'", family );
  
  n_attr_buf = 2;
  ret_msg =
  vdb$RisSelect(  select      =      "n_name,n_datatype",
                  table_name  =      "nfmattributes,nfmtables",
                  where       =      search,
                  order       =      NULL,
                  group       =      NULL,
                  numselect   =      n_attr_buf,
                  p_numrows   =      &num_attr_buf,
                  p_buffer    =      &attr_buf );

  if ( ret_msg != 1 ) return 0;
*/

  ret_msg = VdsRemoveNfmPdmAttributes( n_attr_buf, &num_attr_buf, attr_buf );

/*  Don't really understand why this piece of code is being executed !!
    Mallik 15/12/95 
*/

   ret_msg = VdsVerifyPdmParameters ( n_attr_buf, num_attr_buf, family, attr_buf );

  /* Verify if macro_name is defined in the family */

/*
  There is no need to query the DB again for p_macro. It can be searched in the
  local buffer. Mallik.

  sprintf ( search, "n_tableno = %s and n_name = 'p_macro'", family_tableno );

  n_attr_buf = 2;
  num = 0;
  p_macro[0] = 0;
  ret_msg =
  vdb$RisSelect(  select      =      "n_name,n_datatype",
                  table_name  =      "nfmattributes",
                  where       =      search,
                  order       =      NULL,
                  group       =      NULL,
                  numselect   =      n_attr_buf,
                  p_numrows   =      &num,
                  p_buffer    =      &buf );

  if ( ret_msg != 1 ) return 0;
  if ( num != 0 )
  {
    strcpy(p_macro,buf[0]);
    vdb$RisFreeBuffer ( buffer =      buf,
                        size   =      n_attr_buf*num);
  }

*/
    num=0;
    if ( p_macro_exists ) num = 1;

    *nb_stat = num_attr_buf + 3 + num; /*  (+ family name, part name & part rev + macro_name if it exists) */

  /*"Dynamic allocation of stat_attr of :%d\n", *nb_stat*/
  if( *nb_stat != 0)
  {
   *stat_attr = (struct ACrg_coll *) om$malloc(size=*nb_stat * sizeof(struct ACrg_coll));
   if(*stat_attr == NULL)
   {
    printf("VDSGetPartAtt, Bad dynamic space alloc");
    vdb$RisFreeBuffer (   buffer   =      attr_buf,
                          size     =      n_attr_buf*num_attr_buf);
    return 0;
   }
  }

  if( category && !strcmp(category,"EQUIP"))
  {
   strcpy((*stat_attr)[0].name,               "eqp_family");
   (*stat_attr)[0].desc.type                  = AC_ATTRIB_TEXT;
   strcpy((*stat_attr)[0].desc.value.att_txt, family);

   strcpy((*stat_attr)[1].name,               "eqp_partno");
   (*stat_attr)[1].desc.type                  = AC_ATTRIB_TEXT;
   strcpy((*stat_attr)[1].desc.value.att_txt, part);

   strcpy((*stat_attr)[2].name,               "eqp_partrev");
   (*stat_attr)[2].desc.type                  = AC_ATTRIB_TEXT;
   strcpy((*stat_attr)[2].desc.value.att_txt, part_rev);
   nb_s = 3;
  }
  else 
  {
   strcpy((*stat_attr)[0].name,               "family");
   (*stat_attr)[0].desc.type                  = AC_ATTRIB_TEXT;
   strcpy((*stat_attr)[0].desc.value.att_txt, family);

   strcpy((*stat_attr)[1].name,               "partno");
   (*stat_attr)[1].desc.type                  = AC_ATTRIB_TEXT;
   strcpy((*stat_attr)[1].desc.value.att_txt, part);

   strcpy((*stat_attr)[2].name,               "partrev");
   (*stat_attr)[2].desc.type                  = AC_ATTRIB_TEXT;
   strcpy((*stat_attr)[2].desc.value.att_txt, part_rev);
   nb_s = 3;
  }

  /* If the macro is defined individually for each part */
  if( p_macro_exists )
  {
   strcpy((*stat_attr)[3].name, "p_macro");
   (*stat_attr)[nb_s].desc.type = AC_ATTRIB_TEXT;
   nb_s++;
  }

  /*D If there are no static attributes it does not make any sense to do the
      following. More over the RIS query to get  the values would fail as the
      select string is empty.
  */

  if( num_attr_buf == 0 ) goto dyn_attrib;

  /*| Fill the static attributes names in stat_attr  */
  for(i=0; i<num_attr_buf; i=i+1)
  {
    strcpy((*stat_attr)[nb_s].name,	attr_buf[n_attr_buf*i]);

    if(strncmp("char",(char *)attr_buf[(i*2)+1], 4) == 0)
      (*stat_attr)[nb_s].desc.type = AC_ATTRIB_TEXT;
    else if((strncmp("double",   attr_buf[(n_attr_buf*i)+1], 6) == 0) ||
            (strncmp("integer",  attr_buf[(n_attr_buf*i)+1], 7) == 0) ||
            (strncmp("real",     attr_buf[(n_attr_buf*i)+1], 4) == 0) ||
            (strncmp("smallint", attr_buf[(n_attr_buf*i)+1], 8) == 0))
      (*stat_attr)[nb_s].desc.type = AC_ATTRIB_DOUBLE;
    nb_s++;
  }
  select = (char *) malloc (MAX_WORD * num_attr_buf * sizeof(char));
  if(!select)
  {
    printf("VDSGetPartAtt, Bad memory allocation \n");
    vdb$RisFreeBuffer (   buffer     =     attr_buf,
                          size       =     n_attr_buf*num_attr_buf);
    return(0);
  }

  /* Prepare the select string from the set of attributes */
  select[0] = '\0';
  for ( i = 3; i < nb_s; i++ )
  {
    strcat(select, (*stat_attr)[i].name );
    if( i != (nb_s -1) )
      strcat(select,"," );
  }

  sprintf ( search, "n_itemname = '%s' and n_itemrev = '%s'",
                      part,part_rev);

  n_attr = nb_s - 3;
  ret_msg =
  vdb$RisSelect(  select      =      select,
                  table_name  =      family,
                  where       =      search,
                  order       =      NULL,
                  group       =      NULL,
                  numselect   =      n_attr,
                  p_numrows   =      &num,
                  p_buffer    =      &buf );

  if ( ret_msg != 1 ) return 0;

  if (num == 0)
  {
    sprintf(mess,"Part not found in the family <%s> Part <%s> Rev <%s>",family,part,part_rev);
    UI_status(mess);
    vdb$RisFreeBuffer (   buffer     =      attr_buf,
                          size       =      n_attr_buf*num_attr_buf);
    return(0);
  }
    
  for( i = 0; i < n_attr; i++ )
  {
    if((*stat_attr)[i+3].desc.type == AC_ATTRIB_TEXT )
      strcpy((*stat_attr)[i+3].desc.value.att_txt, buf[i]);
    else
    {
      if(!sscanf(buf[i], "%lf",&temp_val))
	(*stat_attr)[i+3].desc.value.att_exp = 0;
      else
	(*stat_attr)[i+3].desc.value.att_exp = 
	   VDconv_to_vdsunits( family,attr_buf[n_attr_buf*i],part_units, VDSproject_units, temp_val);
    }
  }

/*
  DEBUG 
  for ( i = 0; i < n_attr; i++ )
  {
      if((*stat_attr)[i].desc.type == AC_ATTRIB_TEXT )
	printf("Value = %s\n", (*stat_attr)[i].desc.value.att_txt );
      else
         printf("Value = %lf \n", (*stat_attr)[i].desc.value.att_exp );
  }
*/


  vdb$RisFreeBuffer (   buffer     =       buf,
                        size       =       n_attr*num);
  buf = NULL;
  vdb$RisFreeBuffer (  buffer   =      attr_buf,
                       size     =      n_attr_buf*num_attr_buf);
  attr_buf = NULL;

/*
NFMget_datetime(date); printf("Date After Static= %s\n",date );
*/


  /* --------------------  Dynamic attributes ---------------------- */

 dyn_attrib:

  /* Check if dynamic attributes required. If not return immediately */  
  
  if(!nb_dyn || !dyn_attr) return 1;

/* REPLACED THE JOINS WITH SIMPLE QUERIES Mallik 15/12/95

  sprintf ( search, "nfmtables.n_tableno = nfmattributes.n_tableno and nfmattributes.n_attrno = nfmvalues.n_attrno and nfmtables.n_tablename = 'y_%s'", family);
  n_attr_buf = 4;
   ret_msg =
  vdb$RisSelect(  select      =      "n_name,n_datatype,n_defaultvalue,n_seqno",
                  table_name  =      "nfmtables, nfmattributes, nfmvalues",
                  where       =      search,
                  order       =      "n_seqno", 
                  group       =      NULL,
                  numselect   =      n_attr_buf,
                  p_numrows   =      &num_attr_buf,
                  p_buffer    =      &attr_buf );

  if ( ret_msg != 1 ) return 0;
  if(num_attr_buf == 0 )
   {
     sprintf ( search, "nfmtables.n_tableno = nfmattributes.n_tableno and nfmtables.n_tablename = 'y_%s'", family);
     ret_msg =
  vdb$RisSelect(  select      =      "n_name,n_datatype,n_synonym,n_seqno",
                  table_name  =      "nfmtables, nfmattributes",
                  where       =       search,
                  order       =      "n_seqno",
                  group       =       NULL,
                  numselect   =       n_attr_buf,
                  p_numrows   =       &num_attr_buf,
                  p_buffer    =       &attr_buf );

  if ( ret_msg != 1 ) return 0;
   }

END REPLACE */

  sprintf ( search, "n_tablename = 'y_%s' ", family );
  n_attr_buf = 1;
  ret_msg =
  vdb$RisSelect(  select      =      "n_tableno",
                  table_name  =      "nfmtables",
                  where       =      search,
                  order       =      NULL,
                  group       =      NULL,
                  numselect   =      n_attr_buf,
                  p_numrows   =      &num,
                  p_buffer    =      &buf );

  if ( ret_msg != 1 ) return 0;
  if ( num != 0 )
  {
    strcpy( y_family_tableno,buf[0] );
    vdb$RisFreeBuffer ( buffer =      buf,
                        size   =      n_attr_buf*num);
  }

  sprintf ( search, "n_tableno = %s and nfmattributes.n_attrno = nfmvalues.n_attrno ", y_family_tableno );
  n_attr_buf = 4;
  ret_msg =
  vdb$RisSelect(  select      =      "n_name,n_datatype,n_defaultvalue,n_seqno",
                  table_name  =      "nfmattributes, nfmvalues",
                  where       =      search,
                  order       =      "n_seqno", 
                  group       =      NULL,
                  numselect   =      n_attr_buf,
                  p_numrows   =      &num_attr_buf,
                  p_buffer    =      &attr_buf );

  if ( ret_msg != 1 ) return 0;
  if(num_attr_buf == 0 )
   {
     n_attr_buf = 4;
     sprintf ( search, "n_tableno = %s", y_family_tableno );
     ret_msg =
     vdb$RisSelect(  select      =      "n_name,n_datatype,n_synonym,n_seqno",
                     table_name  =      "nfmattributes",
                     where       =       search,
                     order       =      "n_seqno",
                     group       =       NULL,
                     numselect   =       n_attr_buf,
                     p_numrows   =       &num_attr_buf,
                     p_buffer    =       &attr_buf );

     if ( ret_msg != 1 ) return 0;
   }

     ret_msg = VdsRemoveNfmPdmAttributes( n_attr_buf, &num_attr_buf, attr_buf );

/*  Don't really understand why this piece of code is being executed !!
    Mallik 15/12/95
*/

    ret_msg = VdsVerifyPdmParameters ( n_attr_buf, num_attr_buf, family, attr_buf );

  /* Dynamic attibutes are non NFM/PDM attributes in y_<family> table
   * Value of attribute n_synonym in table nfmattributes contains default
   * value of the dynamic attribute  
  */

  /* Special care for dynamics that are defined as "Dynamic Locate" (DL)
     in pdmparameters (they should not be included in dyn_attr)
  */
 
  /* Get names of "Dynamic Locate" parameters */
  sprintf ( search, "n_catalogname = '%s' and p_iotype = 'DL'",family);

  n_attr = 1;
  ret_msg =
  vdb$RisSelect(  select      =      "p_templatename", 
                  table_name  =      "pdmparameters",
                  where       =      search,
                  order       =      NULL,
                  group       =      NULL,
                  numselect   =      n_attr,
                  p_numrows   =      &num,
                  p_buffer    =      &buf );
 
  if ( ret_msg != 1 ) return 0;

/* Added: 8-31-93 by mallik */
/* The attributes stored in pdmparameters are upper case & lower case. */
/* While attributes in nfmattributes are all lower case.	       */

/*
  for ( j=0; j < num; j++ )
  {
     i = 0;
     while ( buf[j][i] != '\0' )
     {
	buf[j][i] = tolower(buf[j][i]);
	i++;
     }
  }
*/


  *nb_dyn = num_attr_buf - num;
  if (*nb_dyn <= 0)
  {
    if(num > 0 && buf != NULL) 
     vdb$RisFreeBuffer (  buffer    =       buf, 
                          size      =       n_attr*num);
    if(num_attr_buf > 0 && attr_buf != NULL) 
     vdb$RisFreeBuffer (  buffer    =      attr_buf,
                          size      =      n_attr_buf*num_attr_buf);
    return 1;
  }

  /*"Dynamic allocation of dyn_attr of :%d\n", *nb_dyn*/
  *dyn_attr = (struct ACrg_coll *) om$malloc(size=*nb_dyn *
                                                   sizeof(struct ACrg_coll));
  if(*dyn_attr == NULL)
  {
    printf("VDSGetPartAtt, Bad dynamic space alloc");
    if(num > 0 && buf != NULL) 
     vdb$RisFreeBuffer(   buffer    =     buf, 
                          size      =     n_attr*num);
    if(num_attr_buf > 0 && attr_buf != NULL) 
      vdb$RisFreeBuffer (  buffer   =     attr_buf,
                           size     =     n_attr_buf*num_attr_buf);
    return 0;
  }

  nb_d = 0;

  /* Fill the dynamic attributes */
  for(i=0;i<num_attr_buf;i=i+1)
  {
    /* Skip "Dynamic locate" attributes */
    dyn_load_att = 0;
    for(j=0;j<num;j=j+1)
    {
      if (!case_insensitive_strcmp(buf[j],attr_buf[n_attr_buf*i]))
      {
        dyn_load_att = 1;
        break;
      }
    }

    if (dyn_load_att) continue;

    if(strncmp("char", attr_buf[(n_attr_buf*i)+1], 4) == 0)
    {
      (*dyn_attr)[nb_d].desc.type = AC_ATTRIB_TEXT;
      strcpy((*dyn_attr)[nb_d].desc.value.att_txt, 
               attr_buf[(n_attr_buf*i)+2]);
    }
    else if((strncmp("double",   attr_buf[(n_attr_buf*i)+1], 6) == 0) ||
            (strncmp("integer",  attr_buf[(n_attr_buf*i)+1], 7) == 0) ||
            (strncmp("real",     attr_buf[(n_attr_buf*i)+1], 4) == 0) ||
            (strncmp("smallint", attr_buf[(n_attr_buf*i)+1], 8) == 0))
    {
      (*dyn_attr)[nb_d].desc.type = AC_ATTRIB_DOUBLE;
      if(!sscanf(attr_buf[(n_attr_buf*i)+2], "%lf", &temp_val))
          (*dyn_attr)[nb_d].desc.value.att_exp = 0;
      else
          (*dyn_attr)[nb_d].desc.value.att_exp = temp_val;
    }
    else
    {
      /*"Not a good param type for: %s\n", attr_buf[(i*n_attr_buf)+0] */
      continue;
    }
    strcpy((*dyn_attr)[nb_d].name, attr_buf[(n_attr_buf*i)+0]);
    nb_d++;
  }

 if(num > 0 && buf != NULL)
    vdb$RisFreeBuffer ( buffer   =       buf,
                        size     =       n_attr*num);
 if(num_attr_buf > 0 && attr_buf != NULL)
   vdb$RisFreeBuffer ( buffer  =      attr_buf, 
                       size    =      n_attr_buf*num_attr_buf);
/*
NFMget_datetime(date); printf("Exiting ...Date = %s\n",date );
*/
  return 1;
}

/* Assumption that the string is not more than 29 characters long. Column names have a limitation of NFM column's length */

IGRint  case_insensitive_strcmp( string1, string2 )
char    *string1;
char    *string2;
{
        char    tmp_string1[30];
        char    tmp_string2[30];
        int     i=0;

        while ( string1[i] != '\0' )
        {
                tmp_string1[i] = tolower(string1[i]);
                i++;
        }
	tmp_string1[i]='\0';

        i = 0;
        while ( string2[i] != '\0' )
        {
                tmp_string2[i] = tolower(string2[i]);
                i++;
        }
	tmp_string2[i]='\0';

        return(strcmp(tmp_string1,tmp_string2));
}

IGRint VdsVerifyPdmParameters ( nNbCols, nNbRows, family,  AttrBuffer )
IGRint	nNbCols;
IGRint	nNbRows;
char	*family;
char	**AttrBuffer;

{
  int 		ret_msg, n_attr, num;
  char      	search[200];
  char		**buf;
  int		i,j;

  sprintf ( search, "n_catalogname = '%s' ",family);

  n_attr = 1;
  ret_msg =
  vdb$RisSelect(  select      =      "p_templatename", 
                  table_name  =      "pdmparameters",
                  where       =      search,
                  order       =      NULL,
                  group       =      NULL,
                  numselect   =      n_attr,
                  p_numrows   =      &num,
                  p_buffer    =      &buf );
 
  if ( ret_msg != 1 ) return 0;

  for ( i = 0; i < nNbRows; i++ )
  {
     for( j = 0; j < num; j++ )
     {
	if( !case_insensitive_strcmp( buf[j], AttrBuffer[nNbCols*i] ))
	   strcpy( AttrBuffer[nNbCols*i], buf[j] );
     }
  }
  vdb$RisFreeBuffer ( buffer =      buf,
                      size   =      n_attr*num);
  return 1;
}
