/* $Id: SMCompDb.C,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $  */
/* -------------------------------------------------------------------------

/* I/VDS
 *
 * File:	SMcomp/SMCompDB.C 
 *
 * Description:
 *	Function for database access
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCompDb.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1997/10/31  21:22:42  pinnacle
 * Return values
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.2  1996/04/29  08:48:10  pinnacle
 * Replaced: smcomp/func/SMCompDb.C for:  by ksundar for vds.240
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
 *	01/01/92	Mallik 		Creation Date 
 *	03/31/94	adz		vdbmacros conversion.
 *	10/31/97	ah		Return Value warnings
 *
 * -------------------------------------------------------------------------
 */

#include  <stdio.h>
#include  <time.h>
#include  "OMerrordef.h"
#include  "OMprimitives.h"
#include  "PDUerror.h"
#include  "PDUstr.h"
#include  "PDMfs.h"
#include  "igrtypedef.h"
#include  "ACattrib.h"
#include  "ACrg_collect.h"
#include  "VDSutil.h"

#include  "ms.h"
#include  "msdef.h"
#include  "msmacros.h"

#include "SMmsg.h"
#include "SMdef.h"
#include "VDmem.h"

#include "vdbmacros.h"

#define         AS_DEBUG        1
#define  MAX_WORD  81  /* 81 because 80 + \0 = 81 */

extern  struct	PDUrefresh  *refresh;
extern  double	VDconv_to_vdsunits
(char	*family, char	*par_name, int	units_set_in, int units_set_out,
 double	old_value);


/*+fi
  -------------------------------------------------------------------------
 Internal Function SMReadCompPduReview 

  Abstract
	Retreive selected part for PDU. Verify it's a compartment part

  Returns

         OM_S_SUCCESS if success
         OM_E_ABORT or 0 if fails

 -------------------------------------------------------------------------
*/

int SMReadCompPduReview ( type, rev_catalog, rev_partid, rev_revision )
int   type;		   /* [I] Type of catalog Surface/Compart  */
char  rev_catalog[];       /* [O] Catalog name in PDU review area  */
char  rev_partid[];        /* [O] Part Id in PDU review area       */
char  rev_revision[];      /* [O] Part revision in PDU review area */

/*
-fi*/
{
  int   sts;
  char  search[MAX_WORD];
  char  p_compcat[MAX_WORD];
  char  p_comppartno[MAX_WORD];
  char  p_comprev[MAX_WORD];
  char  n_itemno[MAX_WORD];
  int   num;
  char  **buf;
  int   n_attr;
  char  desc[MAX_WORD];

  strcpy ( rev_catalog,"");
  strcpy ( rev_partid,"");
  strcpy ( rev_revision,"");
  
  /*|Check that user is logged in to PDU */
  sts = VDSverify_login();
  if (sts != PDM_S_SUCCESS)
  {
    ex$message(msgnumb = SM_E_CmNoDbLog);
    return 0;
  }

  sts = VDSverify_project();
  if (sts != OM_S_SUCCESS)
  {
    return 0;
  }

  /*|Check PDU refresh area */
  if ( (PDUvalid_catalog("",refresh->rev_catalog) != PDM_S_SUCCESS))
  {
    /* No PDM catalog entered in refresh area */
    ex$message(msgnumb = SM_E_CmNoDbCat);
    return 0;
  }

  if (refresh == NULL)
  {
    ex$message(msgnumb = SM_E_CmNoDbRef);
    return 0;
  }

  if (refresh->rev_catalog    != NULL) 
  {
    /*|Get refresh->rev_catalog */
    strcpy( rev_catalog,  refresh->rev_catalog);
  }
  else 
  {
    ex$message(msgnumb = SM_E_CmNoDbCat); 
    return 0;
  }
  /*"catalog: <%s>\n", rev_catalog*/

  /* ---- Check that rev_catalog is a parametric family */

  sprintf ( search, "n_catalogname = '%s'", rev_catalog);
  n_attr = 3;
  sts =
  vdb$RisSelect(	select		= "p_macrocat,p_macropartno,p_macrorev",
                        table_name	= "pdmparamloc",
                        where		= search,
                        numselect	= n_attr,
                        p_numrows	= &num,
                        p_buffer 	= &buf );
  if(sts != 1) return OM_E_ABORT;
  if (num == 0)
  {
    ex$message(msgnumb = SM_E_CmNoCat,type = "%s",var = `rev_catalog`);
    return 0;
  }
  else
  {
    sts = 
    vdb$RisExtractValue (	nbrows		= num,
                                nbcolumns	= n_attr,
                                buffer		= buf,
                                row		= 0,
                                column		= 0,
                                value 		= p_compcat );

    sts = 
    vdb$RisExtractValue (	nbrows		= num,
                                nbcolumns	= n_attr,
                                buffer		= buf,
                                row		= 0,
                                column		= 1,
                                value 		= p_comppartno );

    sts = 
    vdb$RisExtractValue (	nbrows		= num,
                                nbcolumns	= n_attr,
                                buffer		= buf,
                                row		= 0,
                                column		= 2,
                                value 		= p_comprev );

    sts = 
    vdb$RisFreeBuffer (		buffer		= buf,
				size		= n_attr*num);
  }

  /* ---- Check that parametric family is a compartment*/

  if ( type == SM_COMPART ) {
    sprintf ( search,
       "n_itemname = '%s' and n_itemrev = '%s' and n_itemdesc = 'compartment'",
       p_comppartno,p_comprev);

    strcpy(desc,"COMPARTMENT");
  }
  else if (type == SM_SRF ) {
    sprintf ( search,
       "n_itemname = '%s' and n_itemrev = '%s' and n_itemdesc = 'surface'",
       p_comppartno,p_comprev);
    strcpy(desc,"SURFACE");
  }

  n_attr = 1;
  sts = 
  vdb$RisSelect (	select		= "n_itemno",
			table_name	= p_compcat,
			where		= search,
                        numselect	= n_attr,
			p_numrows	= &num,
			p_buffer	= &buf);
  if(sts != 1) return OM_E_ABORT;
  if (num == 0)
  {
    ex$message(	msgnumb = SM_E_CmNoCompFam,
		type = "%s,%s",
		var = `rev_catalog, desc`); 
    return 0;
  }
  else
  {
    sts = 
    vdb$RisExtractValue (	nbrows		= num,
                                nbcolumns	= n_attr,
                                buffer		= buf,
                                row		= 0,
                                column		= 0,
                                value 		= n_itemno );
    sts =
    vdb$RisFreeBuffer ( 	buffer		= buf,
				size		= n_attr*num );
  }

  if (refresh->rev_partid == NULL || refresh->rev_partid[0] == PDM_FS_DIRECTORY)
  {
    /* No PDM part entered in refresh area */
    ex$message(msgnumb = SM_E_CmNoPartId);
    return 0;
  }
  else
   {
     /*|Get refresh->rev_partid */
     strcpy( rev_partid,  refresh->rev_partid);
   }

  /*"partid: <%s>\n", rev_partid*/
  if (refresh->rev_revision    != NULL) 
  {
    /*|Get refresh->rev_revision */
    strcpy( rev_revision,  refresh->rev_revision);
  }
  else 
  {
    ex$message(msgnumb = SM_E_CmNoRev);
    return 0;
  }
  /*"revision: <%s>\n", rev_revision*/


  return OM_S_SUCCESS;
}

/*+fi
 -------------------------------------------------------------------------
  Internal Function VDquery_att_name

  Abstract
        The function retrieves the list of attributenames and their synonyms, 
        for the given family.

  Returns
         1 if success
         0 if fails
 -------------------------------------------------------------------------
*/

int  VDquery_att_name( family, nb_stat, list_of_attr, units_set_exists)

char		   *family;		/* Input   Family name */
int		   *nb_stat;		/* Output  St Attr Num */
struct	temp_attr  **list_of_attr;	/* List of Static attr */
IGRboolean	   *units_set_exists;	/* FALSE if it does not exist */
					/* TRUE if it exists   */
/*
-fi */
{
	char	mess[100];
	char	search[200];
	int	sts;
	int	num_attr_buf, num;
	char	**attr_buf,**buf;
	char	family_tableno[15];
	int	n_attr_buf, n_attr;
	int	i,nb_s;

	*nb_stat = 0;
	*list_of_attr = (struct temp_attr *)NULL;
	*units_set_exists = FALSE;

	  /* Get n_tableno for table <family> from nfmtables */
	sprintf ( search, "n_tablename = '%s'", family);
	n_attr = 1;

	sts =
        vdb$RisSelect(  select		= "n_tableno",
                        table_name	= "nfmtables",
                        where   	= search,
                        numselect	= n_attr,
                        p_numrows	= &num,
                        p_buffer 	= &buf );
	if( sts != 1) return 0;

	if (num == 0)
	{
	  sprintf(mess,"ERROR:%s not found in the database",family);
	  UI_status(mess);
	  return(0);
	}
	else
	{
	  strcpy(family_tableno,buf[0]);
	  sts =
	  vdb$RisFreeBuffer (	buffer	= buf,
				size	= n_attr*num );
	}

  /* Get static attribute names from nfmattributes for table <family>
     (User defined attributes does not have an "_" in position 2) */

/**** Mallik: 1 Sep 93, This query is misinterpreted for oracle

	sprintf ( search, "n_tableno = %s and n_name not like '_%c_%c'",
                    family_tableno,backslash,percent);
*****/
	sprintf( search,"n_tableno = %s ",family_tableno);

	n_attr_buf = 3;
	sts =
        vdb$RisSelect(  select		= "n_name,n_synonym,n_datatype",
                        table_name	= "nfmattributes",
                        where		= search,
                        numselect	= n_attr_buf,
                        p_numrows	= &num_attr_buf,
                        p_buffer 	= &attr_buf );
        if( sts != 1) return 0;
	sts = VdsRemoveNfmPdmAttributes( n_attr_buf, &num_attr_buf, attr_buf );

	sts = VdsVerifyPdmParameters ( n_attr_buf, num_attr_buf, family, attr_buf );

	*nb_stat = num_attr_buf + 3; /* (+ family name, part name & part rev) */

	if(num_attr_buf == 0)
	{
	  /* No static attributes defined !!! */
	  sprintf(mess,"No static attributes for: %s",family);
	  UI_status(mess);
	}

	if( *nb_stat != 0)
	{
	  *list_of_attr = _MALLOC(*nb_stat, struct temp_attr);
	  if(*list_of_attr == NULL)
	  {
	    UI_status("ERROR in VDquery_att_name, Bad dynamic space alloc");
	    sts =
	    vdb$RisFreeBuffer ( buffer 	= attr_buf,
				size 	= n_attr_buf*num_attr_buf);
	    goto wrapup ;  /* return  0; */
	  }
	}

	strcpy((*list_of_attr)[0].attr_name,"family");
	strcpy((*list_of_attr)[0].attr_syn,"");
	(*list_of_attr)[0].type = AC_ATTRIB_TEXT;

	sprintf(search,"n_tableno = %s and n_name='n_itemname'",family_tableno);
	n_attr = 1;
	sts =
        vdb$RisSelect(  select		= "n_synonym",
                        table_name	= "nfmattributes",
                        where		= search,
                        numselect	= n_attr,
                        p_numrows	= &num,
                        p_buffer 	= &buf );
	if ( sts != 1) goto wrapup ; /* return 0; */
	if ( num == 0)
	{
	   sprintf(mess," Attribute n_itemname does not exist for: %s",family);
	   UI_status(mess);
	   sts =
	   vdb$RisFreeBuffer ( 	buffer 	= attr_buf,
				size 	= n_attr_buf*num_attr_buf);
	   goto wrapup ; /* return  0; */
	}
	strcpy((*list_of_attr)[1].attr_name,"partno");
	strcpy((*list_of_attr)[1].attr_syn, buf[0]);
	(*list_of_attr)[1].type = AC_ATTRIB_TEXT;

	sts =
	vdb$RisFreeBuffer (	buffer	= buf,
				size	= n_attr*num );

	sprintf(search,"n_tableno = %s and n_name='n_itemrev'",family_tableno);
	n_attr = 1;
	sts =
        vdb$RisSelect(  select		= "n_synonym",
                        table_name	= "nfmattributes",
                        where		= search, 
                        numselect	= n_attr,
                        p_numrows	= &num,
                        p_buffer 	= &buf );
	if( sts != 1) goto wrapup ; /* return 0; */


	if ( num == 0)
	{
	   sprintf(mess," Attribute n_itemrev does not exist for: %s",family);
	   UI_status(mess);
	   sts =
	   vdb$RisFreeBuffer ( 	buffer	= attr_buf,
				size	= n_attr_buf*num_attr_buf );
	   goto wrapup ; /* return  0; */
	}
	strcpy((*list_of_attr)[2].attr_name,"partrev");
	strcpy((*list_of_attr)[2].attr_syn, buf[0]);
	(*list_of_attr)[2].type = AC_ATTRIB_TEXT;

	sts = 
	vdb$RisFreeBuffer (	buffer	= buf,
				size	= n_attr*num );

	nb_s = 3;

	for( i=0; i < num_attr_buf; i=i+1 )
	{
	    /* Do not add the units_set as a Static attribute     */
	    if(!strcmp(attr_buf[n_attr_buf*i],"units_set"))
	    { *units_set_exists = TRUE; continue; }

	    strcpy((*list_of_attr)[nb_s].attr_name,attr_buf[n_attr_buf*i]);
	    strcpy((*list_of_attr)[nb_s].attr_syn,attr_buf[n_attr_buf*i + 1]);
	    if(strncmp("char",(char *)attr_buf[n_attr_buf*i + 2], 4) == 0)
	    {
		(*list_of_attr)[nb_s].type = AC_ATTRIB_TEXT;
	    }
	    else if(( strncmp("double", attr_buf[n_attr_buf*i + 2], 6) == 0)||
	    	   ( strncmp("real",   attr_buf[n_attr_buf*i + 2], 4) == 0))
	    {
		(*list_of_attr)[nb_s].type = AC_ATTRIB_DOUBLE;
	    }
	    else if(( strncmp("integer",attr_buf[n_attr_buf*i + 2], 7) == 0)||
	    	   ( strncmp("smallint",attr_buf[n_attr_buf*i + 2], 8) == 0))
	    {
		(*list_of_attr)[nb_s].type = SM_ATTRIB_INT;
	    }
	    else
	    {
		/* Not a good param type */
	    }
	    nb_s++;
	}
	sts = 
	vdb$RisFreeBuffer (	buffer	= attr_buf,
				size 	= n_attr_buf*num_attr_buf );
	*nb_stat = nb_s; 

	return 1;
wrapup :
  _FREE(*list_of_attr);

  /* 10/31/97 Art Hundiak
   * Relying on the comments which indicate anything going here
   * should return 0
   */
  return 0;

}


/*+fi
 -------------------------------------------------------------------------
  Internal Function VDquery_parts

  Abstract
        The function queries the database for all the parts found in the
	given catalog that match to the given select criteria.

  Returns
         1 if success
         0 if fails
 -------------------------------------------------------------------------
*/
int  VDquery_parts( family, nb_stat, list_of_attr, nb_query, query, units_set_exists, nb_parts, parts, dyn_part)
char			*family;		/* Catalog to search     [I]*/
int		   	nb_stat;		/* Number of static attr [I]*/
struct	temp_attr  	*list_of_attr;		/* The list of attr      [I]*/
int			nb_query;		/* No of attr in query   [I]*/
struct query_attr	*query;			/* Attribs of query	 [I]*/
IGRboolean		units_set_exists;	/* if units_exist TRUE   [I]*/
int			*nb_parts;		/* num of Parts found	 [O]*/
struct part_attr	**parts;		/* Parts found           [O]*/
struct part_attr	*dyn_part;		/* Dynamic Attribs	 [O]*/
/*
-fi */
{
	char	*select = NULL;
	char	*where = NULL;
	int	sts, i, j, nb_s;
	char	**attr_buf;
	int	n_attr_buf, num_attr_buf;
	int	part_units;
	double	temp_val;
	char	n_itemname[80],n_itemrev[80];
	int	VDSproject_units;

	VdsGetProjectUnits( &VDSproject_units );
	if(units_set_exists==FALSE) part_units = VDSproject_units;

	*nb_parts = 0;
	*parts = (struct part_attr *) NULL;

	/* FORM THE SELECT STATEMENT */

	select = _MALLOC (MAX_WORD*nb_stat,char);
	if(!select) {printf("Memory problem\n");goto wrapup;}
	select[0] = '\0';
	if(units_set_exists) 
	{
	   strcpy(select,"n_itemname,n_itemrev,units_set");
	   n_attr_buf = nb_stat;
	}
	else 
	{
	   strcpy(select,"n_itemname,n_itemrev");
	   n_attr_buf = nb_stat - 1 ; 
	}

	for( i = 3; i < nb_stat; i++ )
	{
		strcat(select,",");
		strcat(select,list_of_attr[i].attr_name);
	}


	/* FORM THE WHERE STATEMENT */

	if( nb_query == 0 )
	{
	  sts =
          vdb$RisSelect(select		= select,
                        table_name	= family,
                        numselect	= n_attr_buf,
                        p_numrows	= &num_attr_buf,
                        p_buffer 	= &attr_buf );
	  if( sts != 1 ){
	    goto wrapup;
	  }
	}
	else
	{
	   /* Jean : 4/30/93 Malloc here! */
	   where = _MALLOC ((MAX_WORD+5)*nb_query, char);
	   if(!where) {printf("Memory problem\n");goto wrapup;}
	   where[0] = '\0';
	   for( i = 0; i < nb_query; i ++ )
	   {
	       if( i != 0) 
	         strcat(where," and ");
	       VDprepare_where( where, query[i] );
   	   }
	   sts =
           vdb$RisSelect(select		= select,
                        table_name	= family,
                        where		= where,
                        numselect	= n_attr_buf,
                        p_numrows	= &num_attr_buf,
                        p_buffer 	= &attr_buf );
	   if ( sts != 1 ){
	     goto wrapup;
	   }
	}
	
 	*nb_parts = num_attr_buf;
	
	if( num_attr_buf != 0)
	{
	  *parts = _CALLOC(*nb_parts, struct part_attr);
	  if(*parts == NULL){ printf("Memory problem\n"); goto wrapup; } 
	}
	for ( i = 0; i < *nb_parts; i++ )
	{
		/* FOR EACH PART FILL UP THE ATTRIBUTE INFO */
		/* nb_att is the number of the attributes for each part */

/* Jean 9-21 n_attr_buf is not number of attributes in parts */
#if 0
	  (*parts)[i].nb_att = n_attr_buf; /* add family also */
#endif 		
		(*parts)[i].att = _MALLOC( nb_stat, struct VDSatt_family);

		strcpy((*parts)[i].att[0].attr.name,"family");
		(*parts)[i].att[0].stat_dyn = STAT_ATTR;
		(*parts)[i].att[0].attr.desc.type = AC_ATTRIB_TEXT;
		strcpy((*parts)[i].att[0].attr.desc.value.att_txt,family );

		nb_s = 1;
		for( j = 0; j < n_attr_buf; j++ )
		{
			if( j == 0)
			{
			   strcpy((*parts)[i].att[nb_s].attr.name,"partno");
			   strcpy(n_itemname,attr_buf[ i*n_attr_buf]);
			}
			else if (j == 1)
			{
			   strcpy((*parts)[i].att[nb_s].attr.name,"partrev");
			   strcpy(n_itemrev,attr_buf[ i*n_attr_buf + j]);
			  /* VdsGetPartUnits(family,n_itemname,n_itemrev,&part_units); */  /* commented as it is another RIS query so very slow*/
			}
			else if ( units_set_exists && j == 2)
			{
			   sscanf(attr_buf[ i*n_attr_buf+j],"%d",&part_units);
			   continue;
			}

			   strcpy((*parts)[i].att[nb_s].attr.name,list_of_attr[nb_s].attr_name);

			/* Query for the Part Units */

			(*parts)[i].att[nb_s].stat_dyn = STAT_ATTR;
			if( list_of_attr[nb_s].type == AC_ATTRIB_TEXT )
			{
			  (*parts)[i].att[nb_s].attr.desc.type = AC_ATTRIB_TEXT;
			  strcpy((*parts)[i].att[nb_s].attr.desc.value.att_txt, attr_buf[ i*n_attr_buf + j]);

#ifdef DEBUG
printf("Name = %s\n", (*parts)[i].att[nb_s].attr.name );
printf("Text = %s\n", (*parts)[i].att[nb_s].attr.desc.value.att_txt );
#endif
			}
			else
			{
			  (*parts)[i].att[nb_s].attr.desc.type = AC_ATTRIB_DOUBLE;
			  if(!sscanf(attr_buf[i*n_attr_buf+j], "%lf",&temp_val))
			      (*parts)[i].att[nb_s].attr.desc.value.att_exp = 0;
			  else
			      (*parts)[i].att[nb_s].attr.desc.value.att_exp =
				VDconv_to_vdsunits( family,(*parts)[i].att[nb_s].attr.name,part_units, VDSproject_units, temp_val); 
#ifdef DEBUG
printf("Name = %s\n", (*parts)[i].att[nb_s].attr.name );
printf("Value = %lf\n", (*parts)[i].att[nb_s].attr.desc.value.att_exp );
#endif
			}
			nb_s++;
		}
	   /* Jean 9-21 : More simple */
	  (*parts)[i].nb_att = nb_s;
	}

	sts = 
	vdb$RisFreeBuffer ( 	buffer	= attr_buf,
				size	= n_attr_buf*num_attr_buf);
	/* RETRIEVING DYNAMIC ATTRIBUTES  */

	if(dyn_part) VDget_dynattr(part_units, family, dyn_part);

	_FREE(select) ;
	_FREE(where) ;
	return 1;
	
      wrapup:
	for (i=0; i<*nb_parts; i++)
		_FREE((*parts)[i].att);
	_FREE(*parts);
	*nb_parts = 0;
	_FREE(select) ;
	_FREE(where) ;
	return 0;
}

/*+fi
 -------------------------------------------------------------------------
  Internal Function VDget_dynattr

  Abstract

	This function retrieves in the database the dynamic attributes
	of the given family.

  Returns
         1 if success
         0 if fails
 -------------------------------------------------------------------------
*/
int   VDget_dynattr(part_units,family,dyn_part )
int		 part_units; /* (I) part units	*/
char		 *family;    /* (I) family name */
struct part_attr *dyn_part;  /* (O) dynamic attributes of the part */
/*
-fi */
{
	char	search[200];
	int	num_attr_buf, num, nb_dyn, nb_d;
	char	**attr_buf,**buf;
	char	y_family_tableno[15];
	int	n_attr_buf, n_attr;
	int	dyn_load_att;
	int	i,j,sts;
	double	temp_val;
	char	dyn_table[MAX_WORD];
	int	VDSproject_units;

	VdsGetProjectUnits( &VDSproject_units );
	sprintf(dyn_table,"y_%s",family );
	sprintf(search,"n_tablename = '%s'",dyn_table);

	n_attr = 1;
	sts =
        vdb$RisSelect(  select		= "n_tableno",
                        table_name	= "nfmtables",
                        where		= search, 
                        numselect	= n_attr,
                        p_numrows	= &num,
                        p_buffer 	= &buf );
	if( sts != 1) return 0;
	if(num == 0)
	{
	   printf("ERROR: %s not found in nfmtables",dyn_table);
	   return(0);
	}
	strcpy(y_family_tableno,buf[0]);
	sts =
	vdb$RisFreeBuffer ( 	buffer	= buf,
				size	= n_attr*num);

	/* Get the names of Dynamic Locate parameters */
	sprintf( search, "n_catalogname = '%s' and p_iotype = 'DL'",family);
	n_attr = 1;
	sts =
        vdb$RisSelect(  select		= "p_templatename",
                        table_name	= "pdmparameters",
                        where		= search,
                        numselect	= n_attr,
                        p_numrows	= &num,
                        p_buffer 	= &buf );
	if ( sts != 1) return 0;

/* Added: 8-31-93 by mallik */
/* The attributes stored in pdmparameters are upper case & lower case. */
/* While attributes in nfmattributes are all lower case.               */

  	for ( j=0; j < num; j++ )
	{
	   i = 0;
	   while ( buf[j][i] != '\0' )
	   {
	      buf[j][i] = tolower(buf[j][i]);
	      i++;
	   }
	}

	/* Get dynamic attribute names from nfmattributes for dynamic table */
/*** Mallik 8-31-93: Oracle database does not recognise this query.
	sprintf ( search, "n_tableno = %s and n_name not like '_%c_%c'",
                     y_family_tableno,backslash,percent);
***/
	sprintf ( search, "n_tableno = %s",y_family_tableno);
	n_attr_buf = 3;
	sts =
        vdb$RisSelect(  select		= "n_name,n_datatype,n_synonym",
                        table_name	= "nfmattributes", 
                        where		= search,
                        numselect	= n_attr_buf,
                        p_numrows	= &num_attr_buf,
                        p_buffer 	= &attr_buf );
	if ( sts != 1) return 0;

	sts = VdsRemoveNfmPdmAttributes( n_attr_buf, &num_attr_buf, attr_buf );

	sts = VdsVerifyPdmParameters ( n_attr_buf, num_attr_buf, family, attr_buf );

	nb_dyn = num_attr_buf - num;

	if (nb_dyn <= 0)
	{
	  if(num > 0 && buf != NULL){
		sts =
		vdb$RisFreeBuffer (	buffer	= buf,
					size	= n_attr*num );
	  }
	  if(num_attr_buf > 0 && attr_buf != NULL){
		sts =
		vdb$RisFreeBuffer (	buffer	= attr_buf,
					size	= n_attr_buf*num_attr_buf );
	  }
	  return 1;
	}

	dyn_part->nb_att = nb_dyn;

	dyn_part->att = _MALLOC( nb_dyn, struct VDSatt_family);

	if(dyn_part->att == NULL)
	{
	  printf("ERROR in VDSget_dynattr, Bad dynamic space alloc");
	  if(num > 0 && buf != NULL){
		sts =
		vdb$RisFreeBuffer (	buffer	= buf,
					size	= n_attr*num);
	  }
	  if(num_attr_buf > 0 && attr_buf != NULL){
		sts =
		vdb$RisFreeBuffer (	buffer	= attr_buf,
					size 	= n_attr_buf*num_attr_buf);
	  }
	  goto wrapup ; /* return 0; */
	}

	nb_d = 0;

	/* Fill the dynamic attributes */
	for(i=0;i<num_attr_buf;i=i+1)
	{
	  /*" add dynamic # %d, index: %d\n", nb_d, i */
	  if(nb_d >= nb_dyn)
	  { printf("VDSget_dynattr, Error (-1)");
	    if(num > 0 && buf != NULL){
		sts =
		vdb$RisFreeBuffer (	buffer	= buf,
					size	= n_attr*num);
	    }
	    if(num_attr_buf > 0 && attr_buf != NULL){
		sts =
		vdb$RisFreeBuffer (	buffer	= attr_buf,
					size	= n_attr_buf*num_attr_buf);
	    }
	    goto wrapup; /* return 0; */
	  }
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
	  (dyn_part->att)[nb_d].stat_dyn = DYN_ATTR;

	  if(strncmp("char", attr_buf[(n_attr_buf*i)+1], 4) == 0)
	  {
	    (dyn_part->att)[nb_d].attr.desc.type = AC_ATTRIB_TEXT;
	    strcpy((dyn_part->att)[nb_d].attr.desc.value.att_txt,
	    attr_buf[(n_attr_buf*i)+2]);
	  }
	  else if((strncmp("double",   attr_buf[(n_attr_buf*i)+1], 6) == 0) ||
	          (strncmp("integer",  attr_buf[(n_attr_buf*i)+1], 7) == 0) ||
	          (strncmp("real",     attr_buf[(n_attr_buf*i)+1], 4) == 0) ||
	          (strncmp("smallint", attr_buf[(n_attr_buf*i)+1], 8) == 0))
	  {
	    (dyn_part->att)[nb_d].attr.desc.type = AC_ATTRIB_DOUBLE;
	    if(!sscanf(attr_buf[(n_attr_buf*i)+2], "%lf",&temp_val))
	        (dyn_part->att)[nb_d].attr.desc.value.att_exp = 0;
	    else
		(dyn_part->att)[nb_d].attr.desc.value.att_exp =
		   VDconv_to_vdsunits( family,attr_buf[n_attr_buf*i],part_units,					VDSproject_units, temp_val);
	  }
	  else
	  {
      /*"Not a good param type for: %s\n", attr_buf[(i*n_attr_buf)+0] */
	    continue;
	  }
	  strcpy((dyn_part->att)[nb_d].attr.name, attr_buf[(n_attr_buf*i)+0]);
	  nb_d++;
	}
	if(num > 0 && buf != NULL){
		sts =
		vdb$RisFreeBuffer (	buffer	= buf,
					size	= n_attr*num);
	}
	if(num_attr_buf > 0 && attr_buf != NULL){
		sts =
		vdb$RisFreeBuffer (	buffer	= attr_buf,
					size	= n_attr_buf*num_attr_buf);
	}

	return 1;

wrapup :
  _FREE(dyn_part->att);
  _FREE(dyn_part);

  /* 30 Oct 1997 - Art Hundiak
   * according to comments, anything getting here should
   * return 0
   */
  return 0;
}

/*+fi
 -------------------------------------------------------------------------
  Internal Function VDprepare_where

  Abstract
        The function adds the given query in the where statement.
	It basically concatenates in "where" the query structure :
		query.name query.operator query.value

  Returns
         1 always
 -------------------------------------------------------------------------
*/

int   VDprepare_where( where, query )
char			*where; /* (I/O) where statement to fill           */
struct query_attr	query;  /* (I) query to add in the where statement */
/*
-fi */
{
	char temp_str[MAX_WORD];

	/* Modif PL April 18 1994 if operator is between, take off the "'"
	/* in the query value
	/* */


	switch ( query.type ) {
	case AC_ATTRIB_TEXT: 
		if ((!strcmp(query.Operator,"=")) || (!strcmp(query.Operator,"like")) || 
                    (!strcmp(query.Operator,"between")))
		{
		  if(!strcmp(query.name,"partno"))
		   sprintf(temp_str,"%s %s '%s'","n_itemname", query.Operator, query.value.att_txt );
		  else if(!strcmp(query.name,"partrev"))
		   sprintf(temp_str,"%s %s '%s'","n_itemrev", query.Operator, query.value.att_txt );
		  else if(!strcmp(query.Operator,"between"))
		   sprintf(temp_str,"%s %s %s", query.name, query.Operator, query.value.att_txt );
		  else 
		   sprintf(temp_str,"%s %s '%s'", query.name, query.Operator, query.value.att_txt );
		}
		break;

	case AC_ATTRIB_DOUBLE:
		sprintf(temp_str,"%s %s %f", query.name, query.Operator, query.value.att_dbl);
		break;

	case SM_ATTRIB_INT:
		sprintf(temp_str,"%s %s %d", query.name, query.Operator, query.value.att_int);
		break;

	default: break;
	}
	strcat( where, temp_str );

	return 1;
}

/*+fi
 -------------------------------------------------------------------------
  Internal Function VDfree_allocated_parts

  Abstract
        The function is used to free the structures parts and dyn_part
	if they are not NULL. The deallocated pointer are set to NULL.

  Returns
         1 always

 -------------------------------------------------------------------------
*/
int   VDfree_allocated_parts( nb_parts, parts, dyn_part )
int 			nb_parts;	/* (I) nb_part in parts        */
struct part_attr	*parts;		/* (I) parts structure to free */
struct part_attr	*dyn_part;	/* (I) dyn_part structure to free */
/*
-fi */
{
  int i;

  if(parts)
   {
     for( i=0; i < nb_parts; i++ )
       _FREE(parts[i].att) ;
     _FREE(parts);
     parts = NULL;
   }
 
  
  if(dyn_part && dyn_part->att) _FREE(dyn_part->att);

  return(1);
}
