
/*	File	: svs.c								*/
/* 	Smart View Search							*/
/*	ld -o SVS.o -r svs.o view_parse.o cond_parse.o 				*/

		       
#include <stdio.h>
#include <math.h>
#include <ctype.h>
#include <string.h>
#include <malloc.h>
#include "expression.h"

#include "header.h"

/* Flags */
#define	FALSE	0
#define	TRUE	1

#define	DOUBLE 0
#define STRING 1

#define	COND_ADDED 1

#define	PARAM_NOT_IN_LIST -99

#define SINGLE_COL 0
#define	FUNC_OF_ATTR 1

#define	DEBUG 0
#define	FUNC_TRACE 0
#define	DEBUG3 0

/******************************** 	Macros 		********************************/

#define alloc_error(string, ptr) 							\
	if (ptr == NULL){								\
		printf ("%s : Unable To Allocate Memory\n", string);			\
		return (0);								\
	}

#define AllocError(string, ptr) 							\
	if (ptr == NULL){								\
		printf ("%s : Unable To Allocate Memory\n", string);			\
		goto FreeAndReturn;							\
	}

#define	MyFree(ptr) 									\
	if (ptr != NULL){								\
		free (ptr);								\
		ptr = NULL;								\
	}

#define	MemCheck(ptr){							\
	if (ptr == NULL){						\
		fprintf (stderr, "Unable To Allocate Memory\n");	\
		goto CleanUp;						\
        }                                                               \
}
        
/***************************************************************************************/


extern int	NoSlctd; /* Count of selected params */ 
extern int	NoCols, NoParams, NoRows;
extern int	NoTables, NoExp;
extern int	result[MAX_SVS_COND];

extern char	CurrentSVSView[32];

extern char	ViewTable [MAX_SVS_PARAMS][MAX_SVS_COND][MAX_SVS_COND_LEN];
extern char	ViewParamList[MAX_SVS_PARAMS][SVS_NAME_LEN], 
	TableColList[MAX_SVS_PARAMS][SVS_NAME_LEN*2],
	*VueColTypes[MAX_SVS_PARAMS];

extern char	exp_cond[MAX_SVS_COND_LEN];

static 	char	**computed_vals = NULL;
static	char	oper_to_add[8];

static	short	table_col_type[MAX_SVS_PARAMS];
static	short	slctd_flags_tbl[MAX_SVS_PARAMS][MAX_SVS_COND], RetVal,  AddAnotherAnd = FALSE;

static	int	NoComptdVals, ComptdValCnt, CurrentParam, ParamType;
static	int	NoAnds = 0, SameTableCols = 0;


extern double	**vals_of_cols, values[MAX_SVS_PARAMS];

extern FILE	*PDU_v_yyin, *PDU_c_yyin;

struct  selected {
	char	param[SVS_NAME_LEN];
	int	ndx;
	union	data_type_union	{
/* Conversion problems. 1.5 comes as 1.5007.	*/
/*		double	real;			*/
		char	real[32];
		char	string[32];
	}value;
	short	data_type;		/* STRING (1), DOUBLE (0) */
	} slctd_params[MAX_SVS_PARAMS];	

struct  column_value {
	short 	val_type;	/* 1 - string, 0 - double */
	union {
		double 	number;
		char 	string[132];
	      } value;
	} col_val;

struct	value_list {
	char value[32];
	struct value_list *next;
	} *start[MAX_SVS_PARAMS];

struct	same_table {
	int	ndx;
	short	added;	/* 1 condition added already */
	} from_same_tbl[MAX_SVS_PARAMS];
		
struct	columns_in_formula {
	char	*col_name;
	int	ndx;
	} cols_in_form[MAX_SVS_PARAMS];

char *EXPlocate ();

Search (char *view_name, char *param, char ***param_vals, double ***vals_in_formula, int *no_vals, int *param_ndx)
{
	char 	*query = NULL, *where_part = NULL, *output_string = NULL,
		*table = NULL, table_col[32*2];

	int	i, sts, error, ret,
		max_rows = MAX_SVS_ROWS,
		FuncOfAttr = FALSE;

	short   condition_exists = FALSE;

	struct	value_list *temp1, *temp2;

	_pdm_debug ("In Search ()\n", 0);

	/* Initialize */
	temp1 = temp2 = NULL;
	NoAnds 	= 0;
	AddAnotherAnd = FALSE;
	oper_to_add[0] 	= '\0';
	NoCols 	= 0;
	*no_vals 	= 0;

	for (i = 0; i < MAX_SVS_PARAMS; i++)
		cols_in_form[i].col_name = NULL;
	NoComptdVals = ComptdValCnt = 0;

	for (i = 0; i < NoParams; i ++)
		if (!strcmp (ViewParamList[i], param)){
			*param_ndx = i;
			break;
		}

	if (i == NoParams)
	{	
		_pdm_debug ("Attribute %s not found", param);
		return (0);
	}

	/* Convert viewname to lowercase */
	SVSToLower ( view_name);

	/* The entry in TableColList might just be a single column name, OR
	   a function of other table attributes, we've an array of flags indicating 
	   the type									*/

							/********************************/
	if (table_col_type[*param_ndx] == FUNC_OF_ATTR){/* Function of other attributes */
							/********************************/
		ParamType  = FUNC_OF_ATTR;
 		NoCols = 0;
		if ((FuncOfAttr = ParseColumn (TableColList[*param_ndx], cols_in_form, &NoCols)) == -1)
			goto FreeAndReturn;
		if (!(ret = GetColumnValues (cols_in_form, NoCols)))
			goto FreeAndReturn;
		
		/* All the columns in the formula are selected 		*/
		/* OR							*/
		/* Not all of the columns in formula are selected 	*/
		if (ret == -1 || ret == 1){
			/* '34' for view attribute and '34' for view_name and multiple 
			   of '32 + 3' (3 for a blank and a comma (',') ) for no of 
			   columns in formula
			*/
			query = (char *) malloc (strlen ("select  from ") + 34 + 34 + (32 + 3) * NoCols);
			alloc_error ("Search", query);
			strcpy (query, "select ");

			for (i = 0; i < NoCols; i++){
				strcat (query, " ");
				strcat (query, ViewParamList[cols_in_form[i].ndx]);
				strcat (query, ",");
			}

			strcat (query, " ");
			strcat (query, param);
			strcat (query, " from ");
			strcat (query, view_name);

			/* length of " where " */
			where_part = (char *) malloc (strlen (" where ") + 1);
			AllocError ("Search", where_part);
	
		   	strcpy (where_part, " where ");
		   	strcpy (oper_to_add, "");
		   	
		   	for (i = 0; i < NoCols; i++){
		   		int	len;
				
				if (start[i] != NULL){
					condition_exists = TRUE;
					len = strlen (ViewParamList[cols_in_form[i].ndx]) + strlen (" = ") + strlen (oper_to_add) + strlen (start[i]->value) + 1;
		   		
					where_part = (char *) realloc (where_part, strlen (where_part) + len);
					AllocError ("Search", where_part);

					strcat (where_part, oper_to_add);
					strcat (where_part, ViewParamList[cols_in_form[i].ndx]);
					strcat (where_part, " = ");
					strcat (where_part, start[i]->value);
					strcpy (oper_to_add, " and ");
				}
			}

			if (condition_exists){
				query = (char *) realloc (query, strlen (query) + 1 + strlen (where_part) + 1);
				AllocError ("Search", query);
				strcat (query, where_part);
			}

			_pdm_debug ("\nQUERY : %s\n", query);

			max_rows = MAX_SVS_ROWS;
		        sts = RISquery(query, &max_rows, &output_string, &error);
			
			MyFree (query);
			MyFree (where_part);

			if (!ProcessColsAndFormula (sts, error, output_string, param_vals, vals_in_formula, no_vals))
				return (0);
		}
	}
							/********************************/
	else { 						/* Entry is single column name. */
							/********************************/
		if (NoTables == 1){
			/* '32' for ViewParamlist and '32' for view_name */
			query = (char *) malloc (strlen ("select DISTINCT from ") + 32 + 32 + 1);
			alloc_error ("Search", query);
			
			sprintf (query, "select DISTINCT %s from %s", ViewParamList[*param_ndx], view_name);
		}
		else {
			ParamType  = SINGLE_COL;

			/* Get table to which param belongs */
			strcpy (table_col, TableColList[*param_ndx]);
			table = strtok (table_col, ".");

			/* The Hunt begins */	
			/* '64' for TableColList and '32' for table */
			query = (char *) malloc (strlen ("select DISTINCT from ") + 64 + 32);
			alloc_error ("Search", query);
			
			sprintf (query, "select DISTINCT %s from %s", TableColList[*param_ndx], table);
	
			
			BuildWhere (&query, &where_part, table, *param_ndx, &condition_exists);

			if (NoAnds != 0 ){
				int len = 0;
				len = strlen (where_part) + strlen (" ) ") + 1;
				where_part = (char *) realloc (where_part, len);
				AllocError ("Search", where_part);
				strcat (where_part, " ) ");
			}

			if (condition_exists){
				query = (char *) realloc (query, strlen (query) + 1 + strlen (where_part) + 1);
				AllocError ("Search", query);
				strcat (query, where_part);
			}
		}

		_pdm_debug ("\nQUERY : %s\n", query);

		max_rows = MAX_SVS_ROWS;
	        sts = RISquery(query, &max_rows, &output_string, &error);

		MyFree (query);
		MyFree (where_part);

		if (!ProcessRISoutput (sts, error, output_string, param_vals, no_vals))
			return (0);
	}

	_pdm_debug ("Out Search ()\n", 0);

	return (1);

FreeAndReturn :
	
	MyFree (query);
	MyFree (where_part);

	for (i = 0; i < NoCols; i++){
		MyFree (cols_in_form[i].col_name);
		if (start[i] != NULL){
			temp1 = start[i];
			while (temp1 != NULL){
				temp2 = temp1 -> next;
				MyFree (temp1);
				temp1 = temp2;
			}
		}
	}

	for (i = 0; i < ComptdValCnt; i++){
		MyFree (computed_vals[i]);
		MyFree (vals_of_cols[i]);
	}
		
	MyFree (computed_vals);
	MyFree (vals_of_cols);

	return (0);
}



StoreVal(char *selected_value, char *param, int param_ndx)
{
	int	i;

	/* Put user selected parameter value and all info in the structure 	*/
	/* Insert selected parameter in the 'selected' params struct 		*/

	_pdm_debug ("In StoreVal ()\n", 0);

	/* I'm getting the wrong param_ndx, get the right one here. */
	for (i = 0; i < NoParams; i++)
	{
		if (!strcmp (param, ViewParamList[i]))
		{
			param_ndx = i;
			break;
		}
	}

	if (!strcmp (VueColTypes[param_ndx], "char")){
		/* It's a string ?? */
		strcpy (slctd_params[NoSlctd].value.string, selected_value);
		slctd_params[NoSlctd].data_type = STRING;
	}
	else {
		/* A regular number */
/*		Conversion problems. 1.5 becomes 1.50007.			*/
/*		slctd_params[NoSlctd].value.real = atof (selected_value);	*/
		strcpy (slctd_params[NoSlctd].value.real, selected_value);
		slctd_params[NoSlctd].data_type = DOUBLE;
	}

	strcpy (slctd_params[NoSlctd].param, param);
	slctd_params[NoSlctd].ndx = param_ndx;

	/* Increment no of selected parameters */
	NoSlctd++;

	_pdm_debug ("Out StoreVal ()\n", 0);
}

Initialize ()
{
	int	i, j;

	_pdm_debug ("In Initialize ()\n", 0);

	NoSlctd = 0;
	NoRows = 0;
	NoParams = 0;

	/* Init the arrays */
	for ( i = 0; i < MAX_SVS_PARAMS; i = i + 1){
		strcpy (ViewParamList[i], "");
		strcpy (TableColList[i], "");
		strcpy (slctd_params[i].param, "");
/*		Conversion problems. 1.5 becomes 1.50007.	*/
/*		slctd_params[i].value.real = 0.0;		*/
		strcpy (slctd_params[i].value.real, "");		
		strcpy (slctd_params[i].value.string, "");
		slctd_params[i].data_type = FALSE;
	}
	for (i = 0; i < MAX_SVS_PARAMS; i = i + 1)
		for (j = 0; j < MAX_SVS_COND; j = j + 1)
			ViewTable[i][j][0] = '\0';
	for (i = 0; i < MAX_SVS_PARAMS; i = i + 1)
		for (j = 0; j < MAX_SVS_COND; j = j + 1)
			slctd_flags_tbl[i][j] = FALSE;

	_pdm_debug ("Out Initialize ()\n", 0);

	return (1);
}


GetViewDef (char *viewname, char **view_def, int needwhere)
{
	char	query[1024], *outputstring = NULL, *ptr;
	int	max_rows = 0, error, sts;

	_pdm_debug ("In GetViewDef ()\n", 0);

	/* Convert viewname to lowercase */
	SVSToLower ( viewname);

/* RIS dictionary tables in V5 named different. 26/apr/95 - raj. */
 
#if defined ( RISV4 )

	sprintf (query, "select ris_view_def from risviews where view_name = '%s'", viewname);

#elif defined ( RISV5 )

	sprintf (query, "select ris_view_def from ris5views where view_name = '%s'", viewname);

#else
#error "RIS version must be defined"
#endif

	sts = RISquery(query, &max_rows, &outputstring, &error);

	if (sts < 0){
		_pdm_debug ("Error In RIS query %d\n", error);
		MyFree (outputstring);
		return (0);
	}

	_pdm_debug ("Query = %s\n", query);
	_pdm_debug ("Outputstring = %s\n", outputstring);

	error = 0;

	if ( (ptr = strtok (outputstring, "~")) == NULL){
		_pdm_debug ("View Definition does not exist for : %s\n", viewname);
		MyFree (outputstring);
		return (0);
	}

	if ( (*view_def = (char *) malloc (16 * sizeof (char))) == NULL ){
		fprintf (stderr, "ViewDef : Unable To Allocate Memory\n");
		MyFree (outputstring);
		return (0);
	}
		
	while (ptr != NULL && strncmp (ptr, "nil", 3)){
		if ( (*view_def = (char *) realloc (*view_def, strlen (*view_def) + 64)) == NULL ){
			fprintf (stderr, "ViewDef : Unable To Allocate Memory\n");
			MyFree (outputstring);
			return (0);
		}
		sts = 0;
		while (sts < 64 && ptr[sts] != '\0')
			(*view_def)[error++] = ptr[sts++];

		if (strlen (ptr) < 64)
				(*view_def) [error++] = ' ';

		ptr = strtok (NULL, "~");
	}

	(*view_def)[error] = '\0';

	/* Write 'view definition' into file to be picked up by 'yylex' later */
	{
	 FILE	*fp;
	 if ((fp = fopen ("/usr/tmp/ViewDef.dat", "w")) == NULL){
		fprintf (stderr, "Unable open file for writing \"/usr/tmp/ViewDef.dat\"\n");	
		MyFree (outputstring);
		MyFree (*view_def);
		return (0);
	 }

	 if (needwhere == FALSE) {
		char *cpviewdef;
		/* Get rid of the where clause	*/
		cpviewdef = (char *) malloc ((strlen (*view_def) + 1) * sizeof (char));
		MemCheck (cpviewdef);
		strcpy (cpviewdef, *view_def);
		SVSToLower (cpviewdef);

		ptr = EXPlocate( "where", cpviewdef);
		if (ptr != NULL)
			(*view_def)[ptr - cpviewdef] = '\0';

 		MyFree (cpviewdef);
	 }

	 fprintf (fp, "%s\n", *view_def);

	 fclose (fp);
	}

	MyFree (outputstring);
	MyFree (*view_def);


	_pdm_debug ("Out GetViewDef ()\n", 0);

	return (1);

CleanUp :

	MyFree (*view_def);
	return (0);
}



CreateViewTable (char *viewname)
{
	int	max_rows, error, sts, i;
	char	query[MAX_SVS_QRY_LEN], *output_string = NULL, *ptr, ch;


	_pdm_debug ("In CreateViewTable ()\n", 0);

	if ((PDU_v_yyin = fopen ("/usr/tmp/ViewDef.dat", "r")) == NULL){
		fprintf (stderr, "Unable open file for reading \"/usr/tmp/ViewDef.dat\"\n");	
		return (0);
	}

	if ((sts = PDU_v_yyparse ()) == -2)
		return (0);

/*	for ( i = 0; i < NoParams; i++){
		int cnt;
		if ( 
		    ((vue_col_list[i] = (char *) malloc (strlen (ViewParamList[i]) + 1)) == NULL)
		      ||
		    ((tablecollst[i] = (char *) malloc (strlen (TableColList[i]) + 1)) == NULL)
		   )
		   {
			fprintf (stderr, "CreateViewTable : Unable To Allocate Memory\n");
			for (cnt = 0; cnt < i; cnt ++){
				MyFree (vue_col_list[cnt]);
				MyFree (tablecollst[cnt]);	
			}
			return (0);
		   }
		strcpy (vue_col_list[i], ViewParamList[i]);
		strcpy (tablecollst[i], TableColList[i]);
	}
*/
	fclose (PDU_v_yyin);

	/* Get data_types of all columns */
/* RIS dictionary tables in V5 named different. 26/apr/95 - raj. */
 
#if defined ( RISV4 )

	sprintf (query, "select position, ris_type_string from ris_columns where table_name = '%s' order by position", viewname);

#elif defined ( RISV5 )

	sprintf (query, "select position, ris_type_string from ris5columns where table_name = '%s' order by position", viewname);

#else
#error "RIS version must be defined"
#endif

	max_rows = MAX_SVS_ROWS;
        sts = RISquery(query, &max_rows, &output_string, &error);

       	if( sts < 0 ) {
		MyFree(output_string);
		_pdm_debug ("Error In  RIS Operation %d\n", error);
             	return(0);
       	}
	
	i = 0;
       	ptr = strtok( output_string,"~");	/* got position */
	ptr = strtok(NULL,"~");			/* got type */

       	while( ptr != NULL ) {
		if ((VueColTypes[i] = (char *) malloc (strlen (ptr) + 1)) == NULL){
			int cnt;
			fprintf (stderr, "Process : Unable To Allocate Memory\n");
			for (cnt = 0; cnt < i; cnt ++)
				MyFree (VueColTypes[cnt]);
			return (0);
		}
              	strcpy(VueColTypes[i],ptr);

		_pdm_debug ("%s\n", VueColTypes[i]);

              	ptr = strtok(NULL,"~");			/* got position */
              	ptr = strtok(NULL,"~");		/* got type */

              	i = i + 1 ;
     	}

      	MyFree(output_string);

	/* Fill up table_col_type array which indicates whether the entry in
	   TableColList is a single attribute or a function of other 
	   attributes							  */

	for (i = 0; i < NoParams; i++){
		int	len = strlen(TableColList[i]), j;
		table_col_type[i] = 0;
		for (j = 0; j < len; j++){
			ch = TableColList[i][j];
			if (ch == '*' || ch == '/' || ch == '+' || ch == '-'){
				table_col_type[i] = FUNC_OF_ATTR;
				break;
			}
		}
	}
	

	_pdm_debug ("Out CreateViewTable ()\n", 0);

	return (1);
}



ProcessRISoutput (int sts, int error, char *outputstring, char ***values, int *i)
{
	char	*ptr;


	_pdm_debug ("In ProcessRISoutput ()\n", 0);

       	if( sts < 0 ) {
		MyFree(outputstring);
		_pdm_debug ("Error In  RIS Operation %d\n", error);
             	return(0);
       	}
	
	*i = 0;
       	ptr = strtok( outputstring,"~");

	*values = (char **) malloc ((*i + 1) * sizeof (char *));
	alloc_error ("Process", *values);

       	while( ptr != NULL && strncmp (ptr, "nil", 3)) {
		*values = (char **) realloc (*values, (*i + 1) * sizeof (char *));
		alloc_error ("Process", *values);

		if (((*values)[*i] = (char *) malloc (strlen (ptr) + 1)) == NULL){
			int cnt;
			fprintf (stderr, "Process : Unable To Allocate Memory\n");
			for (cnt = 0; cnt < *i; cnt ++)
				MyFree ((*values)[cnt]);
			return (0);
		}
              	strcpy((*values)[*i],ptr);
		_pdm_debug ("%s\n", (*values)[*i]);
              	ptr = strtok(NULL,"~");
              	*i = *i + 1 ;
     	}

      	MyFree(outputstring);


	_pdm_debug ("Out ProcessRISoutput ()\n", 0);

	return (1);
}


			
ParseAndTest (char *condition)
{

	int	i, ret;


	_pdm_debug ("In ParseAndTest ()\n", 0);

	NoExp = 0;
	for (i = 0; i < MAX_SVS_COND; i++)
		result[i] = 99;

	_pdm_debug ("ParseAndTest () = %s\n", condition );
	_pdm_debug ("ParseAndTest () = %d\n", strlen (condition) );


	if (!strcmp (condition, ""))
		return (1);

	/* got to find a way of redirecting the input to yylex () function */
	/* Till then */
 	if ( (PDU_c_yyin = fopen ("/usr/tmp/Condition.dat", "w")) == NULL){
		fprintf (stderr, "Unable To Open \"/usr/tmp/Condition.dat\" for writing\n");
		return (-1);
	}

	fprintf (PDU_c_yyin, "%s", condition);
	fclose (PDU_c_yyin); 

	if ( (PDU_c_yyin = fopen ("/usr/tmp/Condition.dat", "r")) == NULL){
		fprintf (stderr, "Unable To Open \"/usr/tmp/Condition.dat\" for reading\n");
		return (-1);
	}

	exp_cond[0] = '\0';

	ret = PDU_c_yyparse ();

	fclose (PDU_c_yyin); 

	switch (ret){
		case 0 :
			_pdm_debug ("Single Condition\n", 0);
			_pdm_debug ("Out ParseAndTest ()\n", 0);

			return (result[0]);
		case 1 :

			_pdm_debug ("Multiple Condition\n", 0);

			for (i = 0; i < NoExp; i++)
				if (i == 0)
					RetVal = result[i];
				else
					RetVal &= result[i];

			_pdm_debug ("Out ParseAndTest ()\n", 0);

			return (RetVal);
		default :
			_pdm_debug ("Condition Parser Error\n", 0);
			return (ret);
	}
}


Between (int type, char *op1, char *condition)
{
	short	ONE = FALSE, TWO = FALSE;
	char	table_col_name[32*2], val1[16], val2[16], *ptr; /*tmp1[16], tmp2[16],*/
	char	op2[3], rel[3];

	(!strcmp (op1, ">=")) ? strcpy (op2, "<=") : strcpy (op2, ">=");
	(!strcmp (op1, ">=")) ? strcpy (rel, "&&") : strcpy (rel, "||");

	ptr = strtok (condition, op1);
	strcpy (table_col_name, ptr);

	ptr = strtok (NULL, rel);
	strcpy (val1, ptr);
	ptr = strtok (NULL, op2);
	ptr = strtok (NULL, "~");
	strcpy (val2, ptr);

	/* strings contain '=' in the begining remove it */
	val1[0] = ' ';
	val2[0] = ' ';

	if (type == STRING){
		CleanString (val1);
		CleanString (val2);
	}

	if (!GetColVal (table_col_name))
			return (FALSE);

/*	if (!strcmp (op1, ">=")){
		if (col_val.value.number >= atof (val1))
			ONE = TRUE;
		else
			ONE = FALSE;
		if (col_val.value.number <= atof (val2))
			TWO = TRUE;
		else
			TWO = FALSE;
	}
	else {
		if (col_val.value.number <= atof (val1))
			ONE = TRUE;
		else
			ONE = FALSE;
		if (col_val.value.number >= atof (val2))
			TWO = TRUE;
		else
			TWO = FALSE;
	}
		
	return (ONE && TWO);
*/

	if (type == 1){		/* string */
		return ((!strcmp (op1, ">=")) 
			?
			(ONE = strcmp (col_val.value.string, val1) >= 0 ? TRUE : FALSE)
			 &&
			(TWO = strcmp (col_val.value.string, val2) <= 0 ? TRUE : FALSE )
			:
			(ONE = strcmp (col_val.value.string, val1) <= 0 ? TRUE : FALSE)
			 ||
			(TWO = strcmp (col_val.value.string, val2) >= 0 ? TRUE : FALSE )
		       );
	}
	else {		/* number */
		return ((!strcmp (op1, ">=")) 
			?
			(ONE = col_val.value.number >= atof (val1) ? TRUE : FALSE)
			 &&
			(TWO = col_val.value.number <= atof (val2) ? TRUE : FALSE )
			:
			(ONE = col_val.value.number <= atof (val1) ? TRUE : FALSE)
			 ||
			(TWO = col_val.value.number >= atof (val2) ? TRUE : FALSE )
		       );
	}

}

Expression (int val, char *operator, char *condition)
{
	char	table_col_name[32*2], value[16], *ptr;
	int	i, len;

	ptr = strtok (condition, operator);
	strcpy (table_col_name, ptr);

	ptr = strtok (NULL, "~");
	strcpy (value, ptr);
	if (!GetColVal (table_col_name))
		return (FALSE);


	len = strlen (value);

	/* clean up */
	for (i = 0; i < len; i++)
		if (value[i] < '0' || value[i] > '9')
			value[i] = ' ';

	switch (val) 	{
		case 0 :
			{
				if (col_val.value.number > atof (value))
					return (TRUE);
				else
					return (FALSE); 
			}
		case 1 :
			{
				if (col_val.value.number >= atof (value))
					return (TRUE);
				else
					return (FALSE); 
			}
		case 2 :
			{
				if (col_val.value.number < atof (value))
					return (TRUE);
				else
					return (FALSE); 
			}
		case 3 :
			{
				if (col_val.value.number <= atof (value))
					return (TRUE);
				else
					return (FALSE); 
			}
		case 4 :
			{
				if (col_val.value.number != atof (value))
					return (TRUE);
				else
					return (FALSE); 
			}
		case 5 :
			{
				if (col_val.value.number != atof (value))
					return (TRUE);
				else
					return (FALSE); 
			}
		case 6 :
			{
				if (col_val.val_type == STRING){
					/* string value */
					if (!strcmp (col_val.value.string, value))
						return (TRUE);
					else
						return (FALSE);
				}

				if (col_val.value.number == atof (value))
					return (TRUE);
				else
					return (FALSE); 
			}
	}
}

StringExpression (char *operator, char *condition)
{
	char	*ptr, table_col_name[32*2], string[132];
	int	len, i, j;

	ptr = strtok (condition, operator);
	strcpy (table_col_name, ptr);

	ptr = strtok (NULL, "~");
	strcpy (string, ptr);

	len = strlen (ptr);

	for (i = 0; i < len; i++)
		if (ptr[i] == '\'')
			break;

	/* skip the first '\'' */
	j = 0;
	while (string[j++] = ptr[++i]);

	/* Replace the last '\'' */
	string[j - 2] = '\0';

	if (!GetColVal (table_col_name))
		return (FALSE);



	if (!strcmp (col_val.value.string, string))
		RetVal = TRUE;
	else
		RetVal = FALSE;

	if (!strcmp (operator, "!="))		/* materila != 'steel' */
		return (!RetVal);	
}

InValueList (int flag, char *condition)
{
#define VAL_IN		1
#define VAL_NOT_IN	0
#define	NO_MAX_VALS	32	/* GBTYL */

	char	*ptr, table_col_name[32*2];
	double	*values[NO_MAX_VALS];
	int	i, j;

	RetVal = FALSE;

	if (flag == VAL_IN ){	/* value in (value list) */
		ptr = strtok (condition, "in");
		strcpy (table_col_name, ptr);
	}
	else if (flag == VAL_NOT_IN){	/* value not in (value list) */
		ptr = strtok (condition, "not");
		strcpy (table_col_name, ptr);
		ptr = strtok (NULL, "in");
	}

	if (!GetColVal (table_col_name))
		return (FALSE);

	ptr = strtok (NULL, "(");

	i = 0;
	while (ptr != NULL){
		ptr = strtok (NULL, ",");
		values[i] = (double *) malloc (sizeof (double));
		*values[i++] = atof (ptr);
	}

	/* last value before closing parantheses */
	ptr = strtok (NULL, ")");
	values[i] = (double *) malloc (sizeof (double));
	*values[i] = atof (ptr);
	
	if (col_val.val_type == DOUBLE){	/* double val */
		for (j = 0; j <= i; j++){
			if (col_val.value.number == *values[j]){
				RetVal = TRUE;
				break;
			}
		}
	}

	for (j = 0; j < i; j++)
		MyFree (values[j]);

	return (flag ? RetVal : !RetVal);
}

IsValueInTable (char *query, char *col_name)
{
	char	table_col_name[32*2], value[16], *ptr;
	int	i, len;
	int	max_rows, sts, error;
	char	*output_string;

	_pdm_debug ("IsValueINTable () <%s>", query);

	if (!GetColVal (table_col_name))
		return (FALSE);
	if (col_val.val_type == DOUBLE)
	{
		char	numstr[32];
		sprintf (numstr, "%lf", col_val.value.number);
		strcat (query, numstr);
	}
	else
	if (col_val.val_type == STRING)
	{
		strcat (query, " '");
		strcat (query, col_val.value.string);
		strcat (query, "' ");
	}

	_pdm_debug ("\nQUERY : %s\n", query);

	max_rows = 1;
	sts = RISquery(query, &max_rows, &output_string, &error);
	MyFree(output_string);
       	if( sts < 0 ) {
		sprintf (query, "Error In  RIS Operation %d\n", error);
		printf ("%s\n", query);
             	return(0);
       	}
	
	_pdm_debug ("IsValueInTable () - %d -", max_rows);

	return (max_rows);
}

IsNull (int flag, char *condition)
{
}


GetColVal (char *table_col_name)
{
	int len, i, ndx;

	/* Remove trailing blanks */
	len = strlen (table_col_name) - 1;
	for (i = len ; i > 0; i--){
		if (table_col_name[i] == ' ')
			table_col_name[i] = '\0';
		else
			break;
	}

	if (ParamType == FUNC_OF_ATTR){	/* Specail process params which are functions of other attributes */
		for (i = 0; i < NoCols; i++){
			if (!strcmp (table_col_name, cols_in_form[i].col_name)){
					col_val.val_type = DOUBLE;
					col_val.value.number = values[i]; 

					/* Array 'values' is filled in function Param () 
					   with the present combination of values of 
					   columns in the formula 
					*/

					break;
			}
		}
		return (1);
	}
	
	for (ndx = 0; ndx < NoParams; ndx++)
		if (!strcmp (table_col_name, TableColList[ndx]))
			break;

	if (ndx == NoParams){
		_pdm_debug ("Column Name Not In List\n", 0);
		return (0);
	}
	
	for (i = 0; i < NoSlctd; i++){
		if (!strcmp (ViewParamList[ndx], slctd_params[i].param)){
			if (slctd_params[i].data_type != STRING){
				col_val.val_type = DOUBLE;
				col_val.value.number = atof (slctd_params[i].value.real);
				break;
			}
			else {
				col_val.val_type = STRING;
				strcpy (col_val.value.string, slctd_params[i].value.string);
				break;
			}
		}
	}

	if (i == NoSlctd)
		return (FALSE);

	return (1);
}

LikeString (int	type, char *condition)
{
	char 	*ptr, table_col_name[32*2], *string = NULL;
	int	len_str;

	if (!type){	/* 'not like "string"' */
		ptr = strtok (condition, " != ");

	}
	else{		/* 'like "string"' */
		ptr = strtok (condition, " = ");
	}

	strcpy (table_col_name, ptr);

	if (!GetColVal (table_col_name))
		return (FALSE);

	ptr = strtok (NULL, "~");
	string  = (char *) malloc (strlen (ptr) + 1);
	strcpy (string, ptr);
	CleanString (string);

	len_str = strlen (string);

	if ((string[0] == '%') && (string[len_str - 1] == '%')){
		if (!EXPlocate( string, col_val.value.string, 0, strlen (col_val.value.string)))
			goto FreeAndReturn;
	}
	else if (string[0] == '%'){
			if (!StartWithWildCard (string, col_val.value.string, len_str))
				goto FreeAndReturn;
	     }
	     else if (string[len_str - 1] == '%'){
				if (!EndWithWildCard (string, col_val.value.string, len_str))
					goto FreeAndReturn;
		  }
		  else if (strcmp (string, col_val.value.string))
					goto FreeAndReturn;

	MyFree (string);
	return (type ? TRUE : FALSE);

FreeAndReturn :
	MyFree (string);
	return (type ? FALSE : TRUE);
}

CleanString (char *string)
{
	int i, j;
	char c;

	for (i = 0; string[i] != '\'' && string[i] != '\0'; i++);

	for (j = 0;((c = string[j++] = string[++i]) != '\'') && (c != '\0'););

	string[--j] = '\0';
}

StartWithWildCard (char *pattern, char *source, int len_ptrn)
{
	int	i, j;

	for ( i = len_ptrn - 1, j = (strlen (source) - 1); 
	      i >= 0; 
	      i++, j++)
		
		if (pattern[i] != source[j])
			return (FALSE);

	return (TRUE);
}

EndWithWildCard (char *pattern, char *source, int len_ptrn)
{
	int	i, j;

	for (i = 0, j = 0;
	     (i < len_ptrn - 2) || (source[j] != '\0');
	     i++, j++)
		
		if (pattern[i] != source[j])
			return (FALSE);

	return (TRUE);
}

SameTableColumns (int param_ndx, char *table, char **where_part, 
		  short *condition_exists, char tablecollist[][SVS_NAME_LEN * 2])
{

/* First time an attribute is searched on, the where condition part needs to 
   include the conditions for the other attributes belonging to the same 
   table								     */

	int	ndx, row, i, cnt;
	char	table_col[32*2];

	_pdm_debug ("In SameTableColumns\n", 0);

	/* get the indexes of parameters which come from the same table 
	   as the current parameters. 					*/
	for (i = 0; i < NoParams; i++){
		if (i != param_ndx){
			if (table_col_type[i] != FUNC_OF_ATTR){
				strcpy (table_col, tablecollist[i]);
				if (!strcmp (table, strtok (table_col, "."))){
					from_same_tbl[SameTableCols].ndx = i;
					from_same_tbl[SameTableCols++].added = 0;
				}
			}
		}
	}

	if (SameTableCols == 0)
		return (1);

	for (cnt = 0; cnt < NoSlctd; cnt++){	/* Loop by selected parameters */
	    for (ndx = 0; ndx < SameTableCols; ndx ++){	/* Loop by cols from same table */
		if (slctd_params[cnt].ndx == from_same_tbl[ndx].ndx){ /* If the current selected 
				       parameter is one of the cols from the same table */

			/************ Memory Management ************/
			int	len = 0;
			len = strlen (oper_to_add);
			len += strlen (*where_part) + 
			      strlen (tablecollist[slctd_params[cnt].ndx]) +
			      strlen (" = ");
		        if (slctd_params[cnt].data_type == STRING) /* String */
				  len += strlen (slctd_params[cnt].value.string);
			else	/* Double val */
/*	Conversion problems. 1.5 comes as 1.5007. Changed real to char[32]. */
/*				  len += 16;				    */
				  len += 32;
			if ( (!strcmp (oper_to_add, " and ( ")) && NoAnds != 0)
				len += strlen (" ) ");
			/* Accommodate two qoutes and the final NULL */
			len += 2 + 1;
			if ((*where_part = (char *) realloc (*where_part, len)) == NULL){
				  fprintf (stderr, "SameTableColumns : Unable To Allocate Memory\n");
				  return (0);
			}
			/*******************************************/

			*condition_exists = TRUE;
			if (!strcmp (oper_to_add, " and ( " )){
				if (NoAnds != 0)
					strcat (*where_part, " ) ");
				NoAnds++;
			}

			strcat (*where_part, oper_to_add);
			strcat (*where_part, tablecollist[slctd_params[cnt].ndx]);
			strcat (*where_part, " = ");
	
			if (slctd_params[cnt].data_type == STRING){
				  strcat (*where_part, "'");
				  strcat (*where_part, slctd_params[cnt].value.string);
				  strcat (*where_part, "'");
			}
			else{	/* Double val */
/*	Convesrion problems. 1.5 comes as 1.5007.	*/
/*				  char number[16];	*/
/*				  sprintf (number, "%.6lf", slctd_params[cnt].value.real);	*/
/*				  strcat (*where_part, number);	*/
				  strcat (*where_part,
						slctd_params[cnt].value.real);
			}

		        /* attach the operator between the condition lines */
			strcpy (oper_to_add, " and ( ");

			AddAnotherAnd = FALSE;
			
			from_same_tbl[ndx].added = COND_ADDED;

		        break;	
		}
	    }			
	}

	for (row = 1; row < NoRows + 1; row++){	/* Row by row of the view table */
	      for (ndx = 0; ndx < SameTableCols; ndx++){/* Loop by cols from same table */

		/* If any of selected parameters stop.( It's already dealt with, above )  */
		 if (from_same_tbl[ndx].added == COND_ADDED)
			continue;

	         if ( (strcmp (ViewTable[row][from_same_tbl[ndx].ndx], "")) ){

		    /************ Memory management ************/
		    int len = 0;
		    len = strlen (oper_to_add);
		    len += strlen (*where_part) + 
			   strlen (ViewTable[row][from_same_tbl[ndx].ndx]) + 1;
						
		    if ( (!strcmp (oper_to_add, " and ( ")) && NoAnds != 0)
			len += strlen (" ) ");

		    if ((*where_part = (char *) realloc (*where_part, len)) == NULL){
		       fprintf (stderr, "SameTableColumns : Unable To Allocate Memory\n");
		       return (0);
		    }
		    /*******************************************/

		    *condition_exists = TRUE;

		    if (strcmp (*where_part, " where ")){
		    	if (!strcmp (oper_to_add, " and ( " )){
			    if (NoAnds != 0)
				strcat (*where_part, " ) ");
			    NoAnds++;
			    AddAnotherAnd = FALSE;
			}

	            	strcat (*where_part, oper_to_add);
		    }

		    strcat (*where_part, ViewTable[row][from_same_tbl[ndx].ndx]);
		    AddAnotherAnd = TRUE;
		    strcpy (oper_to_add, " and ");
		 }
	      }

	      if (!strcmp (ViewTable[row][NoParams], " and ")){
			strcpy (oper_to_add, " and ( ");
			AddAnotherAnd = FALSE;
	      }
	      else{
			if (strcmp (oper_to_add, " and ( ")){
				strcpy (oper_to_add, ViewTable[row][NoParams]);
				AddAnotherAnd = TRUE;
			}
	      }

	}


	_pdm_debug ("Out SameTableColumns\nWHERE  : %s\n", *where_part);

	return (1);
}
/*210171*/

BuildWhere (char **query, char **where_part, char *table, int param_ndx, short *condition_exists)
{
        /* Build condition for parameter search 		     */
	/* Check if the any of the parameters already retrieved      */
	/* have a condition corresponding to the selected parameter, */
	/* in any row of the view table, which evaluates to TRUE.    */
	/* If true : include the corresponding condition of selected */
	/* parameter in the search criteria			     */

	int	i, j, ret;
	short	current_row_added = FALSE;
	

	_pdm_debug ("In BuildWhere () \n", 0);

	/* length of " where " */
	if ( (*where_part = (char *) malloc (10)) == NULL){
		fprintf (stderr, "BuildWhere : Unable To Allocate Memory\n");
		MyFree (*query);
		return (0);
	}
	
   	strcpy (*where_part, " where ");

	SameTableCols = 0;

	if (!SameTableColumns (param_ndx, table, where_part, condition_exists, TableColList)){
		MyFree (*query);
		MyFree (*where_part);
		return (0);
	}

	if (param_ndx == PARAM_NOT_IN_LIST)
		return (1);

	for (j = 1; j < NoRows + 1; j++){
	    short mask = 0;

	    if (strcmp (ViewTable[j][param_ndx], "")){	/* Bypass if condition is NULL */
		mask = 1;

            	for (i = 0; i < NoSlctd; i ++){	/* Loop by all selected parameters */
	        	int ndx;
			short done_already = FALSE;

			/* If the current selected parmaeter is one of columns belonging to the
			   same table as the current param being searched, stop. */
			for (ndx = 0; ndx < SameTableCols; ndx++) 
			    if (slctd_params[i].ndx == from_same_tbl[ndx].ndx){
				done_already = TRUE;
				break;
			    }
			if (done_already == TRUE)
			    continue;
	
			current_row_added = FALSE;
	
	 		ret = ParseAndTest (ViewTable[j][slctd_params[i].ndx]);

			if (ret == -1){
				MyFree (*query);
				MyFree (*where_part);
				return (0);
			}
			else {
				if (i == 0)
				   mask = ret;
				else
				   mask &= ret;
			}

		}	/* Loop by all selected parameters */

	    }	/* Only if current parameter being searched has a condition in the row */

	    if (mask){		/* If all conditions of selected parameters in the 
	    			   current row are satisfied 				*/
				
		/************ Memory Management ************/
		int len;
		len = strlen (oper_to_add);
		len += strlen (*where_part) + 
		       strlen (ViewTable[j][param_ndx]) + 1;
						
		if ( (!strcmp (oper_to_add, " and ( ")) && NoAnds != 0)
			len += strlen (" ) ");

		if ((*where_part = (char *) realloc (*where_part, len)) == NULL){
			fprintf (stderr, "BuildWhere : Unable To Allocate Memory\n");
			MyFree (*query);
			return (0);
		}
		/*******************************************/

		if (strcmp (*where_part, " where ")){
			if (!strcmp (oper_to_add, " and ( " )){
				if (NoAnds != 0)
					strcat (*where_part, " ) ");
			    	NoAnds++;
			    	AddAnotherAnd = FALSE;
			}

	            	strcat (*where_part, oper_to_add);
		}

		strcat (*where_part, ViewTable[j][param_ndx]);
		slctd_flags_tbl[j][param_ndx] = TRUE;
		*condition_exists = TRUE;

		/* attach the operator between the condition lines */
		if (!strcmp (ViewTable[j][NoParams], " and ")){
			strcpy (oper_to_add, " and ( ");
			AddAnotherAnd = FALSE;
		}
		else if (!strcmp (ViewTable[j][NoParams], " or ")){
			/* Now that a condition is added another 'and' can be added later */
			AddAnotherAnd = TRUE;
			strcpy (oper_to_add, ViewTable[j][NoParams]);
		}

		/* This flag is cleared to FALSE before a row is checked
		   and set to TRUE only if that condition is added.
		   This let's me check, for a row having an 'and' at end
		   whether it's already added or needs to be added	
		*/
		current_row_added = TRUE;

	    }			/* If all condition of selected parameters in the 
	    			   current row are satisfied 				*/

	    /* If a condition isn't added in this row and the log oper is 'and' add it 
	       BUT only if a previous row from this set has been added			*/
	    if (!strcmp (ViewTable[j][NoParams], " and ")){
	       if (current_row_added == FALSE && AddAnotherAnd == TRUE){

				/************ Memory Management ***********
				int len = 0;
				len = strlen (oper_to_add);
				len += strlen (*where_part);
				if (NoAnds != 0)
					len += strlen (" ) ");*/
				/* For a final NULL 
				len += 1;

				if ((*where_part = (char *) realloc (*where_part, len )) == NULL){
					fprintf (stderr, "BuildWhere : Unable To Allocate Memory\n");
					MyFree (*query);
					return (0);
				}*/
				/*******************************************/

				strcpy (oper_to_add, " and ( ");
					
				AddAnotherAnd = FALSE;	/* inhibit adding another 'and' before another condition is strcatted to 'where_part' */
	       }
	    }

	}			/* End of row by row loop */

	_pdm_debug ("QUERY : %s\n", *query);
	_pdm_debug ("WHERE : %s\n", *where_part);
	_pdm_debug ("Out BuildWhere () \n", 0);

	return (1);
}

ParseColumn (char *col_exp, struct columns_in_formula cols_in_form[], int *NoCols)
{
	/*							*/
	/* This function parses the given string and, 		*/
	/*							*/
	/* returns : the numner of column_names if it's an 	*/
	/* arithmetic expression of made up of column_names.	*/
	/*							*/
	/* returns : 0 if it's a single column_name.		*/
	/*							*/
	/* It also retuns the column_names in array.		*/
	/*							*/	   

	int	i, j, k, len, ptr, she;
	char	ch;

	len = strlen (col_exp) + 1;	/* Parsing till final NULL */

	ptr = 0;
	for (i = 0; i < len ; i++){

		ch = col_exp[i];
		if (ch == '*' || ch == '/' || ch == '+' || ch == '-' || ch == '\0'){
			if (*NoCols > MAX_SVS_PARAMS)
				return (*NoCols);
			cols_in_form[*NoCols].col_name = (char *) malloc ((i - ptr) + 1);
			AllocError ("ParseColumn", cols_in_form[*NoCols].col_name);
			for (j = ptr; j < i; j++)
				if (isalpha (col_exp[j]))
					break;
			if (j == i){		/* It's a number */
				ptr = i + 1;	
				continue;
			}

			for (j = 0, k = ptr; k < i; k++)
				if (col_exp[k] != ' ')	/* Avoid leading & trailing blanks */
					cols_in_form[*NoCols].col_name[j++] = col_exp[k];

			cols_in_form[*NoCols].col_name[j] = '\0';

			for (she = 0; she < NoParams; she++)
				if (!strcmp (cols_in_form[*NoCols].col_name, TableColList[she])){
					cols_in_form[*NoCols].ndx = she;
					break;
				}

			if (she == NoParams) /* col_name is not in list */
				cols_in_form[*NoCols].ndx = -99;

			/* Increment */
			(*NoCols)++;

			ptr = i + 1;

			if (ch == '\0')		/* At end of string. Parsing finished */
				break;
		}
	}
	return (*NoCols); 

FreeAndReturn :
	for (i = 0; i < *NoCols; i++)
		MyFree (cols_in_form[i].col_name);

	return (0);
}


GetColumnValues (struct columns_in_formula cols_in_form[], int NoCols)
{
	int	value_cnt, i, j;
	struct	value_list *prev, *val_lst;

	/* Initiaslize the pointers */
	for (i = 0; i < NoCols; i++)
		start[i] = NULL;

	value_cnt = 0;

	for (i = 0; i < NoCols; i++){
		for (j = 0; j < NoSlctd; j++)
			if (!strcmp (TableColList[slctd_params[j].ndx], cols_in_form[i].col_name)){
				break;
			}

		/* If column already selected, store that value and increment counter */
		if (j != NoSlctd){
			/* Allocate for structure */
			start[i] = (struct value_list *) malloc (sizeof (struct value_list));
			AllocError ("GetColumnValues", start[i]);
			
			if (slctd_params[j].data_type == DOUBLE){
/*	Conversion problem. 1.5 comes as 1.5007.	*/
/*				sprintf (start[i]->value, "%lf", slctd_params[j].value.real); */
				strcpy (start[i]->value,
						slctd_params[j].value.real);
				/* Single value nothing following */
				start[i] -> next = NULL;
				value_cnt++;
			}
			else {
				_pdm_debug ("Column Has Wrong Data Type\n", 0);
				goto FreeAndReturn;
			}
		}
	}

	if (value_cnt == NoCols)
		return (1);
	
	else
		return (-1);
	
FreeAndReturn :

	for (i = 0; i < NoCols; i++){
		if (start[i] != NULL){
			prev = start[i];
			while (prev != NULL){
				val_lst = prev -> next;
				MyFree (prev);
				prev = val_lst;
			}
		}
	}

	return (0);
}



ProcessColsAndFormula (int sts, int error, char *outputstring, char ***param_vals, double ***vals_in_formula, int *no_vals)
{
	char	*ptr, **tmp_params = NULL;
	int	i, j;
	double	**tmp_vals;


	_pdm_debug ("In ProcessColsAndFormula ()\n", 0);

       	if( sts < 0 ) {
		MyFree(outputstring);
		_pdm_debug ("Error In  RIS Operation %d\n", error);
             	return(0);
       	}
	
	*no_vals = 0;
       	ptr = strtok( outputstring,"~");

       	while( ptr != NULL && strncmp (ptr, "nil", 3)) {

		tmp_vals = *vals_in_formula;
		*vals_in_formula = (double **) realloc (*vals_in_formula, ((*no_vals) + 1) * sizeof (double *));
		AllocError ("ProcessColsAndFormula", *vals_in_formula);

		(*vals_in_formula)[*no_vals] = (double *) malloc (NoCols * sizeof (double ));
		AllocError ("ProcessColsAndFormula", (*vals_in_formula)[*no_vals]); 

        	for (j = 0; j < NoCols; j++){
	        	(*vals_in_formula)[*no_vals][j] = atof (ptr);
	        	ptr = strtok (NULL, "~");
		}

		tmp_params = *param_vals;
		*param_vals = (char **) realloc (*param_vals, (*no_vals + 1) * sizeof (char *));
		AllocError ("ProcessColsAndFormula", *param_vals);
		
		(*param_vals)[*no_vals] = (char *) malloc (strlen (ptr) + 1);
		AllocError ("ProcessColsAndFormula",(*param_vals)[*no_vals]); 

              	strcpy((*param_vals)[*no_vals],ptr);
              	ptr = strtok(NULL,"~");

              	*no_vals = *no_vals + 1 ;
     	}

      	MyFree(outputstring);


	_pdm_debug ("Out ProcessColsAndFormula ()\n", 0);

	return (1);
	
FreeAndReturn :

	if (tmp_vals != NULL){
		for (i = 0; i < (*no_vals) + 1; i++)
			MyFree (tmp_vals[i]);
		
		MyFree (tmp_vals);
	}
	
	if (tmp_params != NULL){
		for (i = 0; i < (*no_vals) + 1; i++)
			MyFree (tmp_params[i]);
		MyFree (tmp_params);
	}
	
	return (0);
}

ClearDependentParams (int param_ndx, int dep_ndxs[], int *no_deps)
{

	int	i;

	*no_deps = 0;

	if (table_col_type[param_ndx] == FUNC_OF_ATTR)
		return (0);

	for (i = 0; i < NoParams; i++){
		if ( (i == param_ndx) || (table_col_type[i] !=  FUNC_OF_ATTR) )
			continue;

					
		if (EXPlocate( TableColList[param_ndx], TableColList[i], 0, strlen (TableColList[i])))
			dep_ndxs[(*no_deps)++] = i;
	}

	return (1);
}

InitSmartViewSearch (view_name)
char *view_name;
{
	char 	*view_def;

	strcpy (CurrentSVSView, "");

	/* Initialize vars */
	view_def = NULL;
	if (!Initialize ())
		return (0);

	/* Convert viewname to lowercase */
	SVSToLower ( view_name);

	/* get the view definition */
	if (!GetViewDef (view_name, &view_def, TRUE))
		return (0);

	/* Create a table from the view definition 			*/
	/* This table has as many columns as the view has parameters 	*/
	/* and as many rows as the view has seperate logical rules 	*/
	/* Create params list */

        if (!CreateViewTable (view_name))
                return (0);

	/* Set global var to the current view in process */
	strcpy (CurrentSVSView, view_name);

        return (1);
}


SVSGetTablesAndColumnsInView (	char *view_name,
				char ***tables, int *numtbls,
				char ***columns, int *numcols )
{
	int	i, j;
	char	*ptr, *tablencolumn = NULL;

	char 	*view_def;

	struct	columns_in_formula cols_in_form2[MAX_SVS_PARAMS];
	int	cols_in_func = 0;

	_pdm_debug ("Enter SVSGetTablesAndColumnsInView ()\n", 0);

	*numtbls = *numcols = 0;

	strcpy (CurrentSVSView, "");

	/* Initialize vars */
	view_def = NULL;
	if (!Initialize ())
		return (0);

	/* Convert viewname to lowercase */
	SVSToLower ( view_name);

	/* Get the view definition */
	if (!GetViewDef (view_name, &view_def, FALSE))
		return (0);

	/* Create Table.Column list */
        if (!ParseViewDefinition (view_name))
                return (0);

	/* Set global var to the current view in process */
	strcpy (CurrentSVSView, view_name);

	(*tables)  = (char **) malloc (1 * sizeof (char *));
	AllocError ("SVSGetTablesAndColumnsInView", (*tables));

	(*columns) = (char **) malloc (1 * sizeof (char *));
	AllocError ("SVSGetTablesAndColumnsInView", (*columns));

	tablencolumn = (char *) malloc (1 * sizeof (char));

	for (i = 0; i < NoParams; i++) {

		tablencolumn = (char *) realloc (tablencolumn, (strlen (TableColList[i]) + 1) * sizeof (char));
		AllocError ("SVSGetTablesAndColumnsInView", tablencolumn);

		strcpy (tablencolumn, TableColList[i]);

		/* Returns zero (0) if it's a single column.	*/
		cols_in_func = 0;
		if (ParseColumn (tablencolumn, cols_in_form2, &cols_in_func))
		{
			for (j = 0; j < cols_in_func; j++)
			{
				ptr = strtok (cols_in_form2[j].col_name, ".");
				if (!AddToList (ptr, tables, numtbls))
					goto FreeAndReturn;
				if (!AddToList (&cols_in_form2[j].col_name[strlen (ptr) + 1], columns, numcols))
					goto FreeAndReturn;

			}

			continue;
		}

		ptr = strtok (tablencolumn, ".");

		if (!AddToList (ptr, tables, numtbls))
			goto FreeAndReturn;

		if (!AddToList (&tablencolumn[strlen (ptr) + 1], columns, numcols))
			goto FreeAndReturn;
	}


	_pdm_debug ("Exit SVSGetTablesAndColumnsInView ()\n", 0);

	MyFree (tablencolumn);	
        return (1);

FreeAndReturn :

	SVSFreeTablesAndColumns (tables, *numtbls, columns, *numcols);
	MyFree (tablencolumn);	
	return (0);
}

SVSFreeTablesAndColumns (char ***tables, int numtbls, char ***columns, int numcols)
{
	int	j;

	for (j = 0; j < numtbls; j++) {
		MyFree ((*tables)[j]);
	}
	MyFree (*tables);

	for (j = 0; j < numcols; j++) {
		MyFree ((*columns)[j]);
	}
	MyFree (*columns);
}

ParseViewDefinition (char *viewname)
{
	int	sts, i;
	char	ch;


	_pdm_debug ("In ParseViewDefinition ()\n", 0);

	if ((PDU_v_yyin = fopen ("/usr/tmp/ViewDef.dat", "r")) == NULL){
		fprintf (stderr, "Unable open file for reading \"/usr/tmp/ViewDef.dat\"\n");	
		return (0);
	}

	if ((sts = PDU_v_yyparse ()) == -2)
		return (0);

	fclose (PDU_v_yyin);

	for (i = 0; i < NoParams; i++){
		int	len = strlen(TableColList[i]), j;
		table_col_type[i] = 0;
		for (j = 0; j < len; j++){
			ch = TableColList[i][j];
			if (ch == '*' || ch == '/' || ch == '+' || ch == '-'){
				table_col_type[i] = FUNC_OF_ATTR;
				break;
			}
		}
	}
	

	_pdm_debug ("Out ParseViewDefinition ()\n", 0);

	return (1);
}

/*
#define	STANDALONE	1
*/

#ifdef STANDALONE

main (int argc, char *argv[])
{
	int	j, numtbls, numcols, sts, err_cod;
	char	**tables, **columns, query[256];

/*
	if (argc <  3) {
		fprintf (stderr, "Usage : SVS schema[.passwd] viewname\n");
		return (0);
	}

	sprintf (query, "default schema %s", argv[1]);
	sts = RISqry_no_output (query, &err_cod);

	if (sts < 0) {
		fprintf (stderr, "Unable To Set Default Schema\n");
		return (0);
	}
*/
	return (InitSmartViewSearch (argv[2]));

	if (!SVSGetTablesAndColumnsInView (argv[2], &tables, &numtbls, &columns, &numcols))
		exit (0);

	for (j = 0; j < NoParams; j++)
		printf ("TableColList[%d] = %s\n", j, TableColList[j]);
	for (j = 0; j < numtbls; j++)
		printf ("Tables[%d] = %s\n", j, tables[j]);
	for (j = 0; j < numcols; j++)
		printf ("Columns[%d] = %s\n", j, columns[j]);

	SVSFreeTablesAndColumns (&tables, numtbls, &columns, numcols);
	
	return (1);
}

#endif			

SVSToLower (char *string)
{
	int	lenstr, chcnt;

	if ((lenstr = strlen (string)) == 0)
		return (1);

	for (chcnt = 0; chcnt < lenstr; chcnt++)
		string[chcnt] = (char) tolower ( (int) string[chcnt] );

	return (1);
}

AddToList (char *ptr, char ***tables, int *numtbls)
{
	int	j;

	/* Avoid duplicate names */
	for (j = 0; j < *numtbls; j++)
		if (!strcmp (ptr, (*tables)[j]))
			break;

	if (j == *numtbls)
	{

		(*tables)  = (char **) realloc ((*tables), (*numtbls + 1) * sizeof (char *));
		AllocError ("SVSGetTablesAndColumnsInView", (*tables));

		(*tables)[*numtbls] = (char *) malloc ((strlen (ptr) + 1) * sizeof (char));
		AllocError ("SVSGetTablesAndColumnsInView", (*tables)[*numtbls]);

		strcpy ((*tables)[*numtbls], ptr);

		(*numtbls)++;
	}

	return (1);

FreeAndReturn :
	return (0);
}
