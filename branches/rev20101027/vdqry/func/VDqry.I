/* $Id: VDqry.I,v 1.2 2001/10/17 19:40:45 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdqry/func/VDqry.I
 *
 * Description:	Some qry routines
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDqry.I,v $
 * Revision 1.2  2001/10/17 19:40:45  jdsauby
 * Added vd_attrs to support better reporting JDS 10/17/01
 *
 * Revision 1.1  2001/10/16 15:37:53  jdsauby
 * JTS MP CR 5536
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/08/01  js      Creation
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"

#include "VDobj.h"
#include "VDexp.h"
#include "VDdir.h"
#include "VDos.h"
#include "VDqry.h"
#include "VDrisc.h"
#include "VDassert.h"
#include "VDpdm.h"

VDASSERT_FFN("vdqry/func/VDqry.I");

/* --------------------------------------------------
 * Initializes a VDqryInfos structure
 */
IGRstat VDqryInitQryInfos( TVDqryInfos  *info )
{
    VDASSERT_FN("VDqryInitQryInfos");

    IGRstat retFlag = 0;

    // Argcheck
    if (info == NULL) goto wrapup;

    // say hi
    traceFlag = 0;
    if (traceFlag) printf (">>> VDqryInitQryInfos\n");

    // Clear
    memset(info,0,sizeof(TVDqryInfos));

    // Setup
    info->max = 40;
    info->inc = 10;
    info->infos = malloc(info->max * sizeof(TVDqryInfo));
    info->file_key   = 0;
    *info->catalog   = 0;
    *info->part      = 0;
    *info->rev       = 0;
    *info->vd_option = 0;
    info->cnt        = 0;

    if (info->infos == NULL) {
	printf("*** Problem allocating memory for TVDqryInfos\n");
	goto wrapup;
    }

    // Done
    retFlag = 1;

wrapup:
    if (traceFlag) printf ("<<< VDqryInitQryInfos <%d>\n",retFlag);
    return retFlag;
}

/* ------------------------------------------------
 * Adds a qryInfo to the TVDqryInfos structure
 */
IGRstat VDqryAddInfoToQryInfos( TVDqryInfos  *infos,
                                TVDqryInfo   *info )
{
    VDASSERT_FN("VDqryAddInfoToQryInfos");
    IGRstat retFlag = 0;
    
    TVDqryInfo  *qrys;

    // Arg check
    if (info == NULL)        goto wrapup;
    if (infos == NULL)        goto wrapup;
    if (infos->infos == NULL) goto wrapup;

    // say hi
    //traceFlag = 1;
    if (traceFlag) printf(">>> VDqryAddInfoToQryInfos\n");

    // Expand list if necessary
    if (infos->cnt == infos->max) {

	qrys = realloc(infos->infos,(infos->max + infos->inc) * sizeof(TVDqryInfo));

	if (qrys == NULL) {
	    printf("*** Problem allocating TVDqryInfos list\n");
	    goto wrapup;
	}
	infos->infos = qrys;
	infos->max  += infos->inc;
    }

    // Add it
    infos->infos[infos->cnt] = *info;
    infos->cnt++;

    // Done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< VDqryAddInfoToQryInfos <%d>\n",retFlag);
    return retFlag;
}

/* -----------------------------------------------
 * Frees a TVDqryInfos structure
 */
IGRstat VDqryFreeQryInfos( TVDqryInfos *infos )
{
    VDASSERT_FN("VDqryFreeQryInfos");
    IGRstat retFlag = 0;
    
    IGRint  i;

    // Argcheck
    if (infos == NULL) goto wrapup;
    if (infos->infos == NULL) goto wrapup;

    // say hi
    traceFlag = 0;
    if (traceFlag) printf(">>> VDqryFreeQryInfos\n");
    
    // Free the array of pointers
    if (infos->cnt > 0) 
    {
	for (i = 0; i < infos->cnt; i++) free(&infos->infos[i]);
    }

    free(infos->infos);

    // Done
    retFlag = 1;

wrapup:
    if (infos) memset(infos,0,sizeof(TVDqryInfos));
    if (traceFlag) printf("<<< VDqryFreeQryInfos <%d>\n",retFlag);

    return retFlag;
}

/*------------------------------------------
 * Get the list of tables to be processed
 * **/
IGRstat VDqryGetTableInfo(IGRchar     *option,
	                  IGRchar     *table,
			  TVDqryInfos *infos)
{
    VDASSERT_FN("VDqryGetTableInfo");
    IGRstat retFlag = 0;
    TVDrisInfo  ris;
    IGRint      i,j;
    TVDqryInfo  info;
    IGRchar     **list;
    IGRchar     sqltmp[256];
    IGRchar     sql   [1024];

    // init
    VDrisInitInfo( &ris );
    VDASSERTW(option && *option);
    VDASSERTW(infos);

    // say hi
    traceFlag = 0;
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    
    // build the query
    sprintf(sql,
	    "Select %s,%s,%s,%s,%s,%s from %s where %s='%s'",
	    VDQRY_COLN_PRIORITY,   VDQRY_COLN_TABLE_NAME,
	    VDQRY_COLN_OPTION,     VDQRY_COLN_QUERY,
	    VDQRY_COLN_ATTRIBUTES, VDQRY_COLN_REMARKS,
	    VDQRY_TBL_NAME,
	    VDQRY_COLN_OPTION,option);

    if (table) 
    {
	sprintf(sqltmp," and %s='%s'",VDQRY_COLN_TABLE_NAME,table);
	strcat(sql,sqltmp);
    }

    sprintf(sqltmp," order by %s;",VDQRY_COLN_OPTION);
    strcat(sql,sqltmp);

    // do it
    VDrisQuery( &ris, sql );
    if (ris.rows < 1) goto wrapup;

    // fill the list
    for (i = 0; i < ris.rows; i++)
    {
	memset(&info,0,sizeof(TVDqryInfo));
	j = i * ris.cols;
	strcpy(info.tbl_name,ris.buf[j+VDQRY_COLI_TABLE_NAME]);
	strcpy(info.vd_query,ris.buf[j+VDQRY_COLI_QUERY]);
	strcpy(info.vd_attrs,ris.buf[j+VDQRY_COLI_ATTRIBUTES]);
	strcpy(info.remarks, ris.buf[j+VDQRY_COLI_REMARKS]);

	// add it
	VDqryAddInfoToQryInfos(infos,&info);
	
    }
	
    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return retFlag;
}


/* -------------------------------------------------
 * Fill up the qry infos structure
 * **/
IGRstat VDqryFillInfosStructure(VDosnum     *osnum,
	                        IGRint      *file_key,
		                IGRchar     *catalog,
		                IGRchar     *part,
		                IGRchar     *rev,
		                IGRchar     *option,
				IGRchar     *table,
		                TVDqryInfos *infos)
{
    VDASSERT_FN("VDqryFillInfosStructure");
    IGRstat retFlag = 0;
    IGRstat sts;

    // arg check
    VDASSERTW(option && *option);
    VDASSERTW(infos)

    // say hi
    traceFlag = 0;
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // first, fill the vd_query section of the infos structure
    sts = VDqryGetTableInfo(option,table,infos);
    if (!(sts & 1)) goto wrapup;

    // now set the rest

    // option
    strcpy(infos->vd_option,option);
    
    // if file_key, get catalog, part, and rev, fill it
    if (file_key) {
	infos->file_key = *file_key;
	sts = VDpdmGetCPRForFilekey(file_key,infos->catalog,infos->part,infos->rev);
	if (!(sts & 1)) goto wrapup;
	retFlag = 1;
	goto wrapup;
    }

    // if catalog, part, and rev, get file_key, fill it
    if (catalog && part && rev) {
	strcpy(infos->catalog,catalog);
	strcpy(infos->part   ,part);
	strcpy(infos->rev    ,rev);
	sts = VDpdmGetFileKeyForCPR(catalog,part,rev,&infos->file_key);
	if (!(sts & 1)) goto wrapup;
	retFlag = 1;
	goto wrapup;
    }

    // if osnum, fill CPR and file_key
    if (osnum) {
	sts = VDpdmGetFilekeyForOS(*osnum,&infos->file_key);
	if (!(sts & 1)) goto wrapup;
	sts = VDpdmGetCPRForFilekey(&infos->file_key,infos->catalog,infos->part,infos->rev);
	if (!(sts & 1)) goto wrapup;
	retFlag = 1;
	goto wrapup;
    }

    // done

wrapup:
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return retFlag;
}

/* ----------------------------------------------------------
 * The work horse:  Process the query from the database table
 * into a usable sql statement for execution.
 * **/
static IGRstat processVDquery(IGRint       nth,
	                      TVDqryInfos *infos,
			      IGRchar     *sql,
			      IGRchar     *o_option)   //override option
{
    VDASSERT_FN("processVDquery");
    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar *p;
    IGRchar buf[1024];
    IGRchar buf1[1024];
    IGRchar sqltmp[1024];
    IGRchar option[32];
    IGRchar msg[80];

    // arg check
    VDASSERTW(sql); *sql = 0;

    strcpy(buf,infos->infos[nth].vd_query);
    VDASSERTW(*buf);

    *msg = 0;

    // set the correct option
    if (o_option && *o_option) strcpy(option,o_option);
    else                       strcpy(option,infos->vd_option);

    /* -----------------------------------------------------------
     * Begin the sql statement depending upon the option.  Typically this
     * will be either a delete from table or select * from table
     * **/
    if ( (!strcmp(option,VDQRY_OPTION_DEL_PART)) ||
         (!strcmp(option,VDQRY_OPTION_DEL_POST))   )
    {
	   sprintf(sql,"Delete from %s where ",infos->infos[nth].tbl_name);
	   sprintf(msg,"Deleting from %s",infos->infos[nth].tbl_name);
    }

    else 
    {
	// does it have particular attributes to select
	if ( (*infos->infos[nth].vd_attrs != 0) &&
	     (strcmp(infos->infos[nth].vd_attrs,"")) &&
	     (strcmp(infos->infos[nth].vd_attrs," ")) )
	{
	    sprintf(sql, "Select %s from %s where ",
		    infos->infos[nth].vd_attrs,infos->infos[nth].tbl_name);
	}
	else
	{
	    sprintf(sql,"Select * from %s where ",infos->infos[nth].tbl_name);
	}
	sprintf(msg,"Selecting from %s",infos->infos[nth].tbl_name);
    }

    // good spot to put up a status
    if (*msg) UI_status(msg);
    
	
    /* -----------------------------------------------------------
     * Now process the where clause from the database into a usable sql
     * statement.  Basically replace the %CAT, %PART, %REV, or %FKEY with
     * the actual values.
     * **/
    p = strchr(buf,'%');
    while (p) {
	*p = 0;
	strcat(sql,buf);
	strcpy(buf,p+1);

	if (!strncmp(buf,VDQRY_ATTR_CATALOG,VDQRY_ATTR_CATALOG_LEN))
	{
	    sprintf(sqltmp,"'%s'",infos->catalog);
	    strcat(sql,sqltmp);
	    p = buf;
	    strcpy(buf,p+3);
	}

	if (!strncmp(buf,VDQRY_ATTR_PART,VDQRY_ATTR_PART_LEN))
	{
	    sprintf(sqltmp,"'%s'",infos->part);
	    strcat(sql,sqltmp);
	    p = buf;
	    strcpy(buf,p+4);
	}

	if (!strncmp(buf,VDQRY_ATTR_REVISION,VDQRY_ATTR_REVISION_LEN))
	{
	    sprintf(sqltmp,"'%s'",infos->rev);
	    strcat(sql,sqltmp);
	    p = buf;
	    strcpy(buf,p+3);
	}

	if (!strncmp(buf,VDQRY_ATTR_FILEKEY,VDQRY_ATTR_FILEKEY_LEN))
	{
	    sprintf(sqltmp,"%d",infos->file_key);
	    strcat(sql,sqltmp);
	    p = buf;
	    strcpy(buf,p+4);
	}

	p = strchr(buf,'%');
    }

    // last character
    strcat(sql,buf);
    strcat(sql,";");

    // done
    retFlag = 1;
    
wrapup:
    return retFlag;
}

/* -------------------------------------------------
 * Execute the nth query within the qryinfos structure
 * **/
IGRstat VDqryExecuteNthQry(IGRint        nth,
	                   TVDqryInfos  *infos)
{
    VDASSERT_FN("VDqryExecuteNthQry");
    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar sql[1024];

    // arg check
    VDASSERTW(infos);
    VDASSERTW(infos->infos);
    VDASSERTW(*infos->catalog);
    VDASSERTW(*infos->part);
    VDASSERTW(*infos->rev);
    VDASSERTW(infos->file_key > 0);

    // say hi
    traceFlag = 0;
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    sts = processVDquery(nth,infos,sql,NULL);
    if (!(sts & 1)) goto wrapup;

    // execute it
    VDrisExecute( sql );
    if (traceFlag) printf("SQL <<<%s>>>\n",sql);

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

    
    
    
/*----------------------------------------------------------------
 * Execute it, return 1 for success, 0 for failure
 * **/
IGRstat VDqryExecute(VDosnum   *osnum,
	             IGRint    *file_key,
		     IGRchar   *catalog,
		     IGRchar   *part,
		     IGRchar   *rev,
		     IGRchar   *option)
{
    VDASSERT_FN("VDqryExecute");
    IGRstat     retFlag = 0;
    IGRstat     sts;
    TVDqryInfos infos;
    IGRint      i;

    // arg check
    if (!option) goto wrapup;

    // init infos
    VDqryInitQryInfos( &infos );
    sts = VDqryFillInfosStructure(osnum,file_key,catalog,part,rev,option,NULL,&infos);
    if (!(sts & 1)) goto wrapup;

    // loop through and execute
    for (i = 0; i < infos.cnt; i++)
    {
	VDqryExecuteNthQry(i,&infos);
    }

    // done
    retFlag = 1;

wrapup:
    VDqryFreeQryInfos( &infos );
    return retFlag;
}
    
/* ----------------------------------------------------------------
 * Initialize TVDqryData
 * ***/
IGRstat VDqryInitQryData(TVDqryData *data)
{
    VDASSERT_FN("VDqryInitQryData");
    IGRstat retFlag = 0;
    IGRstat sts;
    
    // Argcheck
    if (data == NULL) goto wrapup;

    // say hi
    traceFlag = 0;
    if (traceFlag) printf (">>> VDqryInitQryData\n");

    // Clear
    memset(data,0,sizeof(TVDqryData));

    // Setup
    data->max = 40;
    data->inc = 10;
    data->cnt = 0;

    // malloc the ris infos
    data->data = malloc(data->max * sizeof(TVDrisInfo));
    data->cols = malloc(data->max * sizeof(TVDrisInfo));

    // malloc the list of tables to max
    data->tbl_name = (IGRchar**) malloc(data->max * sizeof(IGRchar*));
    
    // check
    if ( (data->data == NULL) || (data->cols == NULL) || (data->tbl_name == NULL) )
    {
	printf("**** Problem Allocating TVDqryData ****\n");
	goto wrapup;
    }


    // Done
    retFlag = 1;

wrapup:
    if (traceFlag) printf ("<<< VDqryInitQryData <%d>\n",retFlag);
    return retFlag;
}

/* -----------------------------------------------
 * get the column information
 * **/
static IGRstat getTableColumns( TVDrisInfo  *cols,
	                        IGRchar     *table,
			        IGRchar     *a_sql )
{
    VDASSERT_FN("getTableColumns");
    IGRstat retFlag = 0;

    IGRchar *p,*q;
    IGRchar buf[2056],buf1[2056];
    IGRchar sql1[2056],value_list[2056];
    IGRchar sql[2056];

    // arg check
    VDASSERTW(cols);
    VDASSERTW(table && *table);
    VDASSERTW(a_sql && *a_sql);

    // if it is not a select statement, then just get all the column stuff
    if (strncmp(a_sql,"Select",6)) 
    {
	VDrisQryTableColumns(cols,table);
	retFlag = 1;
	goto wrapup;
    }

    // is it select *
    if (!strncmp(a_sql,"Select *",8)) 
    {
	VDrisQryTableColumns(cols,table);
	retFlag = 1;
	goto wrapup;
    }

    *value_list = 0;
                         //(  just keeping the editor happy
    strcpy(sql1,")");   
    strcpy(buf,a_sql);

    // take out the Select, this is to the first space
    p = strchr(buf,' ');
    if (p) {
	*p = 0;
	strcpy(buf,p+1);
    }
    else goto wrapup;

    //printf("Start BUF: %s\n",buf);
    // it is a select, get the column names from the sql statement
    while (p=strchr(buf,','))
    {
	*p = 0;

	// clean out a potential carriage return
	while (q=strchr(buf,'\n')) {
	    *q = 0;
	    strcpy(buf,q+1);
	}
	sprintf(buf1,",'%s'",buf);
	//printf("VALUE: <%s>\n",buf1);
	
	strcat(buf1,sql1);
	strcpy(sql1,buf1);
	//printf("VALUE_LIST: %s\n",sql1);
	strcpy(buf,p+1);
	//printf("New BUF: %s\n",buf);

    }

    //printf("Last BUF: %s\n",buf);
    // have one more value between the last , and a space 
    p = strchr(buf,' ');
    if (p) {
	*p = 0;
	sprintf(buf1,"('%s'",buf);   // )
	strcat(buf1,sql1);
	strcpy(value_list,buf1);
    }

    if (*value_list == 0) goto wrapup;

    // now, build the sql to get the column information
    sprintf(sql,
	    "Select %s,%s,%s,%s,%s from %s where %s='%s' and %s in %s;",
	    VDRIS_COLN_COLUMNS_NAME,
	    VDRIS_COLN_COLUMNS_TYPE,
	    VDRIS_COLN_COLUMNS_TYPES,
	    VDRIS_COLN_COLUMNS_LEN,
	    VDRIS_COLN_COLUMNS_POS,
	    VDRIS_TBLN_COLUMNS,
	    VDRIS_COLN_COLUMNS_TABLE,
	    table,
	    VDRIS_COLN_COLUMNS_NAME,
	    value_list);
	

    //printf("## sql: <<%s>>\n",sql);

    // Get the column information
    VDrisQuery(cols,sql);
    
    // done
    retFlag = 1;
    

wrapup:
    return retFlag;
}
	
    
/* ------------------------------------------------
 * Adds a qryInfo to the TVDqryInfos structure
 */
IGRstat VDqryAddTableToQryData( IGRchar    *table,
	                        IGRchar    *sql,
                                TVDqryData *data )
{
    VDASSERT_FN("VDqryAddTableToQryData");
    IGRstat retFlag = 0;
    
    //TVDqryInfo  *qrys;
    TVDrisInfo  *datas,*colss;
    IGRchar    **tbls;

    // Arg check
    VDASSERTW(table && *table);
    VDASSERTW(sql && *sql);
    if (data == NULL)            goto wrapup;
    if (data->data == NULL)      goto wrapup;
    if (data->cols == NULL)      goto wrapup;
    if (data->tbl_name == NULL)  goto wrapup;

    VDrisInitInfo( &data->data[data->cnt] );
    VDrisInitInfo( &data->cols[data->cnt] );

    // say hi
    traceFlag = 0;
    if (traceFlag) {
	printf(">>> VDqryAddTableToQryData\n");
	printf("## SQL: <%s>\n## TABLE: <%s>\n",sql,table);
    }

    // Expand list if necessary
    if (data->cnt == data->max) {

	datas = realloc(data->data,(data->max + data->inc) * sizeof(TVDrisInfo));
	colss = realloc(data->cols,(data->max + data->inc) * sizeof(TVDrisInfo));
	tbls  = (IGRchar**) realloc(data->tbl_name,(data->max + data->inc) * sizeof(IGRchar*));

	if ( (datas == NULL) || (colss == NULL) || (tbls == NULL) ) {
	    printf("*** Problem allocating TVDqryData ***\n");
	    goto wrapup;
	}
	data->data = datas;
	data->cols = colss;
	data->tbl_name = tbls;
	data->max  += data->inc;
    }

    // Add it
    // the table
    if (traceFlag) printf("## memcpy data->tbl_name[%d]\n",data->cnt);
    data->tbl_name[data->cnt] = malloc((strlen(table) + 1) * sizeof(char));
    strcpy(data->tbl_name[data->cnt],table);
    //memcpy(data->tbl_name[data->cnt],table,strlen(table) + 1);

    // the data
    if (traceFlag) printf("## the data\n");
    VDrisQuery( &data->data[data->cnt], sql );
    if (data->data[data->cnt].rows < 1) goto wrapup;
    
    // the column names
    if (traceFlag) printf("## the columns\n");
    getTableColumns(&data->cols[data->cnt],table,sql);
    //VDrisQryTableColumns(&data->cols[data->cnt],table);
    if (data->cols[data->cnt].rows < 1) goto wrapup;
    
    // the count
    data->cnt++;

    // Done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< VDqryAddTableToQryData <%d>\n",retFlag);
    return retFlag;
}

/* -----------------------------------------------
 * Frees a TVDqryData structure
 */
IGRstat VDqryFreeQryData( TVDqryData *data )
{
    VDASSERT_FN("VDqryFreeQryData");
    IGRstat retFlag = 0;
    
    IGRint  i;

    // Argcheck
    if (data == NULL) goto wrapup;
    if (data->data == NULL) goto wrapup;
    if (data->cols == NULL) goto wrapup;
    if (data->tbl_name == NULL) goto wrapup;

    // say hi
    traceFlag = 0;
    if (traceFlag) printf(">>> VDqryFreeQryData\n");
    
    // Free the array of pointers
    if (data->cnt > 0) 
    {
	for (i = 0; i < data->cnt; i++) 
	{
	    free(&data->tbl_name[i]);
	    VDrisFreeInfo(&data->data[i]);
	    VDrisFreeInfo(&data->cols[i]);
	}
    }

    free(data->tbl_name);
    free(data->data);
    free(data->cols);

    // Done
    retFlag = 1;

wrapup:
    if (data) memset(data,0,sizeof(TVDqryData));
    if (traceFlag) printf("<<< VDqryFreeQryData <%d>\n",retFlag);

    return retFlag;
}

/* --------------------------------------------------------------
 * For all tables, fill up the data
 * ***/
IGRstat VDqryQueryAllTables(VDosnum    *osnum,
	                    IGRint     *file_key,
		            IGRchar    *catalog,
		            IGRchar    *part,
		            IGRchar    *rev,
		            IGRchar    *option,
		            TVDqryData *data)
{
    VDASSERT_FN("VDqryQueryAllTables");
    IGRstat retFlag = 0;
    IGRstat     sts;
    TVDqryInfos infos;
    IGRint      i;
    IGRchar     sql[1024];


    // arg check
    VDASSERTW(option && *option);

    // say hi
    traceFlag = 0;
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // init infos
    VDqryInitQryInfos( &infos );
    sts = VDqryFillInfosStructure(osnum,file_key,catalog,part,rev,option,NULL,&infos);
    if (!(sts & 1)) goto wrapup;

    // loop through and query
    for (i = 0; i < infos.cnt; i++)
    {
	sts = processVDquery(i,&infos,sql,VDQRY_OPTION_SELECT);
	if (!(sts & 1)) goto wrapup;

	sts = VDqryAddTableToQryData( infos.infos[i].tbl_name,sql,data );
	//if (!(sts & 1)) goto wrapup;
    }

    // done
    retFlag = 1;

wrapup:
    VDqryFreeQryInfos( &infos );
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* --------------------------------------------------------------
 * For one table name given, fill up the data for it
 * ***/
IGRstat VDqryQueryOneTable(VDosnum    *osnum,
	                   IGRint     *file_key,
		           IGRchar    *catalog,
		           IGRchar    *part,
		           IGRchar    *rev,
		           IGRchar    *option,
		           IGRchar    *table,
		           TVDqryData *data)
{
    VDASSERT_FN("VDqryQueryOneTable");
    IGRstat retFlag = 0;
    IGRstat     sts;
    TVDqryInfos infos;
    IGRint      i;
    IGRchar     sql[1024];


    // arg check
    VDASSERTW(table && *table);
    VDASSERTW(option && *option);

    // init infos
    VDqryInitQryInfos( &infos );
    sts = VDqryFillInfosStructure(osnum,file_key,catalog,part,rev,option,table,&infos);
    if (!(sts & 1)) goto wrapup;

    // loop through and query
    for (i = 0; i < infos.cnt; i++)
    {
	sts = processVDquery(i,&infos,sql,VDQRY_OPTION_SELECT);
	if (!(sts & 1)) goto wrapup;

	sts = VDqryAddTableToQryData( table,sql,data );
	//if (!(sts & 1)) goto wrapup;
    }

    // done
    retFlag = 1;

wrapup:
    VDqryFreeQryInfos( &infos );
    return retFlag;
}

    
/* ----------------------------------------------------------------
 * Query it, return 1 for success, 0 for failure.
 * Also, return the data.  this would be used to find all the data
 * that has been posted about a given CPR, osnum, or file_key.
 * It is up to the calling routine to init and free the TVDqryData structure.
 * ***/
IGRstat VDqryQuery(VDosnum    *osnum,
	           IGRint     *file_key,
		   IGRchar    *catalog,
		   IGRchar    *part,
		   IGRchar    *rev,
		   IGRchar    *option,
		   IGRchar    *table,
		   TVDqryData *data)
{
    VDASSERT_FN("VDqryQuery");
    IGRstat retFlag = 0;

    VDASSERTW(data);
    VDASSERTW(data->data);
    VDASSERTW(data->cols);
    VDASSERTW(data->tbl_name);

    if (table) retFlag = VDqryQueryOneTable(osnum,file_key,
	                                    catalog,part,rev,
					    option,table,data);

    else       retFlag = VDqryQueryAllTables(osnum,file_key,
	                                     catalog,part,rev,
					     option,data);

wrapup:
    return retFlag;
}
/* ----------------------------------------------------------------
 * Query it, return 1 for success, 0 for failure.
 * Also, fill up the report file with all of the data
 * ***/
IGRstat VDqryReport(VDosnum    *osnum,
                    IGRint     *file_key,
                    IGRchar    *catalog,
		    IGRchar    *part,
		    IGRchar    *rev,
		    IGRchar    *option,
		    IGRchar    *table,
		    IGRchar    *rpt_file)
{
    VDASSERT_FN("VDqryReport");
    IGRstat  retFlag = 0;
    IGRstat  sts;

    TVDqryData data;
    IGRint     i,j,k;
    FILE       *file = NULL;
    IGRchar    *buf  = NULL;
    IGRchar    *buf1 = NULL;
    IGRint     len,lencolumn;

    // init
    VDqryInitQryData( &data );

    // arg check
    VDASSERTW(rpt_file && *rpt_file);

    // open the file
    file = fopen(rpt_file,"w");
    if (file == NULL) file = stdout;

    // fill the data
    if (table) sts = VDqryQueryOneTable(osnum,file_key,
           	                        catalog,part,rev,
	                                option,table,&data);

    else       sts = VDqryQueryAllTables(osnum,file_key,
	                                 catalog,part,rev,
	                                 option,&data);

    if (!(sts & 1)) goto wrapup;

    // write it out, big looper coming up
    for (k = 0; k < data.cnt; k++)
    {
	// print a table header
	fprintf(file,"BEGIN TABLE: <%s>\n",data.tbl_name[k]);

	// malloc buf, and buf1
	len = 0;
	for(data.cols[k].i = 0; data.cols[k].i < data.cols[k].rows; data.cols[k].i++) {

	    data.cols[k].j = data.cols[k].i * data.cols[k].cols;
	    lencolumn = atoi(data.cols[k].buf[data.cols[k].j+VDRIS_COLI_COLUMNS_LEN]) + 1;
	    if (lencolumn < 12 ) lencolumn = 12;
	    if (traceFlag) printf("### lencolumn = %d\n",lencolumn);

	    len += lencolumn;
	}  
	buf  = malloc((len+1) * sizeof(IGRchar));
	buf1 = malloc((len+1) * sizeof(IGRchar));

	// fill the column names
	strcpy(buf,"");
	len = 0;

	for(data.cols[k].i = 0; data.cols[k].i < data.cols[k].rows; data.cols[k].i++) {

	    data.cols[k].j = data.cols[k].i * data.cols[k].cols;
	    lencolumn = atoi(data.cols[k].buf[data.cols[k].j+VDRIS_COLI_COLUMNS_LEN]) + 1;
	    if (lencolumn < 12 ) lencolumn = 12;
	    if (traceFlag) printf("### lencolumn = %d\n",lencolumn);

	    len += lencolumn;

	    strcat(buf,data.cols[k].buf[data.cols[k].j+VDRIS_COLI_COLUMNS_NAME]);
	    while (strlen(buf) < len) strcat(buf," ");

	}  
	fprintf(file,"%s\n",buf);

	// put in a seperator line
	strcpy(buf,"=");

	while (strlen(buf) < len) strcat(buf,"=");
	fprintf(file,"%s\n",buf);

	// fill in the data section
	for (data.data[k].i = 0; data.data[k].i < data.data[k].rows; data.data[k].i++) {
	    strcpy(buf1,"");
	    len = 0;
    
	    data.data[k].j = data.data[k].i * data.data[k].cols;
    
	    for(i = data.data[k].j; i < (data.data[k].j + data.data[k].cols); i++) {
    
		data.cols[k].j = (i - data.data[k].j) * data.cols[k].cols;
      
		lencolumn = 
		     atoi(data.cols[k].buf[data.cols[k].j+VDRIS_COLI_COLUMNS_LEN]) + 1;
		if (lencolumn < 12 ) lencolumn = 12;
		//if (traceFlag) printf("### lencolumn = %d\n",lencolumn);

		len += lencolumn;
      
		strcat(buf1,data.data[k].buf[i]);
		while (strlen(buf1) < len) strcat(buf1," ");

	    }
	    fprintf(file,"%s\n",buf1);
	}

	// print a table trailer
	fprintf(file,"END TABLE: <%s>\n\n",data.tbl_name[k]);
    }

    // done
    retFlag = 1;

wrapup:
    VDqryFreeQryData( &data );
    if (file) fclose(file);
    if (buf)  free(buf);
    if (buf1) free(buf1);
    return retFlag;
}

		
end implementation Root;
