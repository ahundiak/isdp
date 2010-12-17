#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include <math.h>
#include <PALmsg.h>

#define	FALSE	0
#define	TRUE	1

#define DEL1	"$"
#define DEL2	"!"

#define COLNAMESIZ  32
#define TXTSIZ      256
#define MAX_PARAM_IN_FORMULA 45 

char	**ConditionTable[2];

#define	MemCheck(ptr)							\
	if (ptr == NULL) {						\
		fprintf (stderr, "Unable To Allocate Memory\n");	\
		goto CleanUp;						\
	}

#define	MyFree(ptr){							\
	if (ptr != NULL)                                                \
	        free ((char *) ptr);                                    \
	ptr = NULL;							\
}

#define PurifyString(string, ptr) {		\
	int	i, j, len;			\
						\
						\
	len = strlen (ptr);			\
						\
	for (i = 0; i < len; i++)		\
		if (ptr[i] == '\'' || ptr[i] == '\0')	\
			break;			\
	if (i != len) { /* Enquoted */		\
						\
		/* skip the first '\'' */		\
		i++;					\
		j = 0;					\
		while (ptr[i] != '\'')			\
			string[j++] = ptr[i++];		\
							\
		/* Replace the last '\'' */		\
		string[j] = '\0';			\
	}						\
}

#define EXP_MAX_LEN 		5120
#define EXP_S_SUCCESS 		1
#define EXP_SUCCESS   		1
#define ERRO			2
#define EXP_INV_INPUT   	(ERRO | 0x230)
#define EXP_E_TOO_LONG		(ERRO | 0x240)
#define EXP_TOO_LONG    	(ERRO | 0x240)

FILE	*CID_yyin;
extern char	*DLexp_cond;
int	NoExpressions, DLresult[10];
int	RetVal;

static  char	**param_names, **param_types;
static  char	**param_vals;
static  int	no_params;

extern	int CID_yydebug;
extern  char *EXPlocate();

static int MyStrLen(char *string)
{
	if (string == NULL)
		return (0);
	else
		return (strlen (string));
}


int  FreeConditionTable (char **conditions, char **assignments,
						int no_conds, int no_assigns)
{
	int	i;

/*	_pdm_debug ("Problems 1??\n", 0);	*/
	
	for (i = 0; i < no_conds; i++)
		MyFree (conditions[i]);
	
/*	_pdm_debug ("Problems 2??\n", 0);	*/

	for (i = 0; i < no_assigns; i++)
		MyFree (assignments[i]);

/*	_pdm_debug ("Problems 3??\n", 0);	*/

 	MyFree (conditions);
	MyFree (assignments);

	return (1);
}

 int  GetCondition (char *source, char ***conditions, int no_conds)
{
    int	i, j, len, begin = 0, end = 0;

    _pdm_debug ("GetCondition :%s:", source);
    if (source == NULL) {
	/* Must be a sigle statement, just put null in the conditon, return */
    	(*conditions)[no_conds] = (char *) malloc ((MyStrLen ("") + 1 ) * sizeof (char));
	MemCheck ((*conditions)[no_conds]);
    
	strcpy ((*conditions)[no_conds], "");

	return (1);
    }

    len = MyStrLen (source);

    for (i = 0; i < len; i++)
	if (source[i] == '(')
		break;

    if (i == len) {
	/* Must have reached an ENDIF, just put NULL in the condition, return */
    	(*conditions)[no_conds] = (char *) malloc ((MyStrLen ("") + 1 ) * sizeof (char));
	MemCheck ((*conditions)[no_conds]);
    
	strcpy ((*conditions)[no_conds], "");

	return (1);
    }

    begin = i;

    for (; i < len; i++)
	if (source[i] == ')')
		break;
    end = i;

    (*conditions)[no_conds] = (char *) malloc ((end - begin + 1) * sizeof (char));
    MemCheck ((*conditions)[no_conds]);
    
    for (i = begin + 1, j = 0; i < end; i++, j++)
		(*conditions)[no_conds][j] = source[i];
    (*conditions)[no_conds][j] = '\0';

    _pdm_debug ("no_conds : %d", no_conds);
    _pdm_debug ("Condition %s\n",(*conditions)[no_conds]);

    return (1);

CleanUp :
    for (i = 0; i < no_conds; i++)
	MyFree ((*conditions)[i]);
    MyFree (*conditions);

    return (0);
}

 int  GetAssignment (char *source, char ***assignments, int no_assigns, char *LHS, int param_index)
{
    int	i, j, len, begin = 0, end = 0;

    _pdm_debug ("GetAssignment :%s:", source);

    len = MyStrLen (source);


/***** NOTE: HERE since the n_itemname is retrieved from database it will have only
             one quote 
******/

    if ( !strcmp (LHS, "KT=") || !strcmp (LHS, "NB=")  ){
	/* Advance past single quote*/    
	i = 0;
	while (source[i++] != '\'');
	begin = i;

    }
    else {
	/* Advance past '=' */
	i = 0;
	while (source[i++] != '=');
	begin = i; 
    }

    /* Go till the last |but one single| quote */
    while (source[i++] != '\'');
    end = i - 1;

    (*assignments)[no_assigns] = (char *) malloc ((end - begin + 1) * sizeof (char));
    MemCheck ((*assignments)[no_assigns]);
    
    for (i = begin, j = 0; i < end; i++, j++)
	(*assignments)[no_assigns][j] = source[i];
    (*assignments)[no_assigns][j] = '\0';

    _pdm_debug ("no_assigns : %d", no_assigns);
    _pdm_debug ("Assignment %s\n", (*assignments)[no_assigns]);

    return (1);

CleanUp :

    for (i = 0; i < no_assigns; i++)
	MyFree ((*assignments)[i]);
    MyFree (*assignments);

    return (0);
}


 int  MakeConditionTable (char *cond_assign_str, char *lhs,
			char ***conditions, char ***assignments,
			int  *no_conditions)
{
    int		no_conds, no_assigns, param_index;
    char	*ptr, *swap_ptr, *cond_assign_cp1, *cond_assign_cp2, LHS[32];

    cond_assign_cp1 = cond_assign_cp2 =  NULL;
    no_conds = no_assigns = *no_conditions = 0;

    sprintf (LHS, "%s=", lhs);

    /* KT and NB are not parameters */
    if (strcmp (lhs, "KT") && strcmp (lhs, "NB"))
	    GetParamIndex (lhs, &param_index);


    /* 	Allocate initially	*/
    *conditions  = (char **) malloc ((no_conds + 1) * sizeof (char *));
    MemCheck (*conditions);
    *assignments = (char **) malloc ((no_assigns + 1) * sizeof (char *));
    MemCheck (*assignments);

    /* Get the conditions and assignments in two seperate loops		*/
    /* Copy 'cond_assign_str' for use in the second loop		*/
    cond_assign_cp1 = (char *) malloc ((MyStrLen (cond_assign_str) + 1) * sizeof (char));
    MemCheck (cond_assign_cp1);
    strcpy (cond_assign_cp1, cond_assign_str);

    cond_assign_cp2  = (char *) malloc ((MyStrLen (cond_assign_str) + 1) * sizeof (char));
    MemCheck (cond_assign_cp2);
    strcpy (cond_assign_cp2, cond_assign_str);


    /* Loop for IF (CONDITION) 	*/
    /* Get the IF (condition)	*/
    swap_ptr = EXPlocate ("IF", cond_assign_cp1);
    if (!GetCondition (swap_ptr, conditions, no_conds))
	return (0);

    /* Advance pointer past this pattern	*/
    ptr = swap_ptr + MyStrLen ("IF");

    /* Increment to 'one'	*/
    no_conds++;

    while (swap_ptr != NULL) {
	/* Look for the IF (condition) construct	*/
	if (swap_ptr = EXPlocate ("IF", ptr)) {
		/* IF (conditions) exists, get it	*/
		*conditions = (char **) realloc (*conditions, (no_conds + 1) * sizeof (char *));
		MemCheck (*conditions);

		if (!GetCondition (swap_ptr, conditions, no_conds))
			return (0);

		/* Increment conditions Counter	*/
		no_conds++;

		ptr = swap_ptr + MyStrLen ("IF");
	}
    }

    /* Loop for LHS= assignment	*/
    /*	Get the LHS assignment	*/
    _pdm_debug("cond_assign_cp2 = %s",cond_assign_cp2);

/**** Added ---- KK ****/
    swap_ptr = NULL;
    swap_ptr = EXPlocate (LHS, cond_assign_cp2);

    _pdm_debug ("swap_ptr for NB= <%s>", swap_ptr);

/* Fix for TR#139304866, if no NB= assignment present, take entire string as assignment
   ONLY if the partnumber func doesnot contain IF-THEN-ELSE constructs and thus a
   SINGLE formula like 'DIN601-$A!x$B!'
*/
    if ( (swap_ptr == NULL) && ((no_conds == 1) && (!strcmp ((*conditions)[0], ""))) )
    {
	/* NO 'NB=' and NO if-then-else constructs (SINGLE formula)	*/

	*no_conditions = 1;
        (*assignments)[0] = (char *) malloc (strlen(cond_assign_cp2) * sizeof (char));
        MemCheck ((*assignments)[0]);
	strcpy((*assignments)[0], cond_assign_cp2);

        MyFree (cond_assign_cp1);
        MyFree (cond_assign_cp2);

        return (1);
    }
    else	if ( (swap_ptr == NULL) && (no_conds > 1) )
		{
			/* NO 'NB=' and if-then-else constructs DO EXIST. Error out.	*/

			warn_box ("PART NUMBER FUCNTION MUST CONTAIN THE DELIMITER 'NB='"); 
/*                        PALstatus_msg(PDR_E_NB);*/
			_pdm_debug ("\n\nPART NUMBER FUCNTION MUST CONTAIN THE DELIMITER 'NB=' \n\n", 0); 

		        MyFree (cond_assign_cp1);
		        MyFree (cond_assign_cp2);

		        return (0);
		
		}

/*** end ****/

    if (!GetAssignment (swap_ptr, assignments, no_assigns, LHS, param_index))
	return (0);

    /* Advance pointer past this pattern	*/
    ptr = swap_ptr + MyStrLen (LHS);

    /* Increment to 'one'	*/
    no_assigns++;

    while (swap_ptr != NULL) {
	/* Look for LHS= assignment	*/
	if (swap_ptr = EXPlocate (LHS, ptr)){
		/* LHS= assignment exists, get it	*/
		*assignments = (char **) realloc (*assignments, (no_assigns + 1) * sizeof (char *));
		MemCheck (*assignments);
	
		if (!GetAssignment (swap_ptr, assignments, no_assigns, LHS, param_index))
			return (0);

		/* Increment assignments Counter	*/
		no_assigns++;

		ptr = swap_ptr + MyStrLen (LHS);
	}
    }

    if (no_conds < no_assigns) {
	/* There's an extra assignment without a 	*/
	/* corresponding IF (condition). i.e., last 	*/
	/* line contains an ELSE assignment construct	*/
	/* Put a null as the last condition.		*/
	*conditions = (char **) realloc (*conditions, (no_conds + 1) * sizeof (char *));
	MemCheck (*conditions);

	(*conditions)[no_conds] = (char *) malloc ((MyStrLen ("") + 1) * sizeof (char));
	MemCheck ((*conditions)[no_conds]);
		
	strcpy ((*conditions)[no_conds], "");

	no_conds++;
    }

    if (no_conds > no_assigns) {
	/* If there's no dangling ELSE and if there's and ENDIF at the	*/
	/* end of the construct, my routine GetCondition () is adding	*/
	/* an extra NULL condition at end even though there's no	*/
	/* corresponding assignment. Loose this .			*/
	MyFree ((*conditions)[no_conds - 1]);
	no_conds = no_conds - 1;
    }

    *no_conditions = no_conds;

    MyFree (cond_assign_cp1);
    MyFree (cond_assign_cp2);

    return (1);
	
CleanUp :
	MyFree (cond_assign_cp1);
    	MyFree (cond_assign_cp2);
	FreeConditionTable (*conditions, *assignments, no_conds, no_assigns);
	return (0);
}


 int  EvaluateCondition (char *condition)
	/* This function evaluates the given condition and 	*/
	/* returns a TRUE or FALSE.				*/
	/* In case of a dangling ELSE, with NO corresponding	*/
	/* condition, this function receives a NULL string	*/
	/* and returns TRUE.					*/ 
{

	int	i, ret;


	NoExpressions = 0;

	_pdm_debug  ("Entered EvaluateCondition () :%s:", condition);

	for (i = 0; i < 10; i++)
		DLresult[i] = 99;

	if (!strcmp (condition, ""))
		return (1);

	/* got to find a way of redirecting the input to yylex () function */
	/* Till then */
 	if ( (CID_yyin = fopen ("/usr/tmp/.Condition.dat", "w")) == NULL){
		_pdm_debug ("Unable To Open \"/usr/tmp/.Condition.dat\" for writing\n",0);
		return (-1);
	}

	fprintf (CID_yyin, "%s", condition);
	fclose (CID_yyin); 

	if ( (CID_yyin = fopen ("/usr/tmp/.Condition.dat", "r")) == NULL){
		_pdm_debug ("Unable To Open \"/usr/tmp/.Condition.dat\" for reading\n",0);
		return (-1);
	}

	ret = CID_yyparse ();

	fclose (CID_yyin); 

	_pdm_debug ("Exiting EvaluateCondition () :%s:", condition);

	switch (ret){
		case 0 :
			_pdm_debug ("Single Condition",0);
			return (DLresult[0]);

		case 1 :
			_pdm_debug ("Multiple Condition",0);

			for (i = 0; i < NoExpressions; i++)
				if (i == 0)
					RetVal = DLresult[i];
				else
					RetVal &= DLresult[i];
			return (RetVal);

		default :
			_pdm_debug ("Error",0);
			return (ret);
	}
}

int  GetParamIndex (char *columnname, int *index)
{
	int	i, len;

	/* Remove trailing blanks */
	len = MyStrLen (columnname) - 1;
	for (i = len ; i > 0; i--){
		if (columnname[i] == ' ')
			columnname[i] = '\0';
		else
			break;
	}

	for (*index = 0; *index < no_params; (*index)++)
		if (!strcmp (columnname, param_names[*index]))
			break;

	if (*index == no_params){
		*index = -1;
		_pdm_debug ("Column Name Not In List",0);
		return (0);
	}
	
	return (1);
}

DLExpression (int oper_type, char *operator, char *condition, int *retval)
{
	char	columnname[32*2], value[16], *ptr;
	int	i, len, index;

	ptr = strtok (condition, operator);
	strcpy (columnname, ptr);

	ptr = strtok (NULL, "~");
	strcpy (value, ptr);

	if (!GetParamIndex (columnname, &index)) {
		*retval = FALSE;
		return (1);
	}

	len = MyStrLen (value);

	/* clean up */
	for (i = 0; i < len; i++)
		if (value[i] < '0' || value[i] > '9')
			value[i] = ' ';

	switch (oper_type) 	{
		case 0 :
			{
				if (atof (param_vals[index]) > atof (value))
					*retval = TRUE;
				else
					*retval = FALSE; 
				break;
			}
		case 1 :
			{
				if (atof (param_vals[index]) >= atof (value))
					*retval = TRUE;
				else
					*retval = FALSE; 
				break;
			}
		case 2 :
			{
				if (atof (param_vals[index]) < atof (value))
					*retval = TRUE;
				else
					*retval = FALSE; 
				break;
			}
		case 3 :
			{
				if (atof (param_vals[index]) <= atof (value))
					*retval = TRUE;
				else
					*retval = FALSE; 
				break;
			}
		case 4 :
			{
				if (atof (param_vals[index]) != atof (value))
					*retval = TRUE;
				else
					*retval = FALSE; 
				break;
			}
		case 5 :
			{
				if (atof (param_vals[index]) != atof (value))
					*retval = TRUE;
				else
					*retval = FALSE; 
				break;
			}
		case 6 :
			{
				if (!strncmp (param_types[index], "char", 4) ||
				    !strcmp (param_types[index], "Expression text")){
					/* string value */
					if (!strcmp (param_vals[index], value))
						*retval = TRUE;
					else
						*retval = FALSE;
				}
				else {
					if (atof (param_vals[index]) == atof (value))
						*retval = TRUE;
					else
						*retval = FALSE; 
				}

				break;
			}
	}

	return (1);
}

DLStringExpression (char *operator, char *condition, int *retval)
{
	char	*ptr, columnname[32*2], string1[132], string2[132];
	int	index;

	ptr = strtok (condition, operator);
	strcpy (columnname, ptr);

	ptr = strtok (NULL, "~");
	strcpy (string1, ptr);

	PurifyString (string1, ptr);

	if (!GetParamIndex(columnname, &index)) {
		*retval = FALSE;
		return (1);
	}


	PurifyString (string2, param_vals[index]);

	if (
	    !strcmp (string1, string2) ||
	    (!strcmp (string1, " ") && !strcmp (param_vals[index], "NULL"))
	   )
		*retval = TRUE;
	else
		*retval = FALSE;

	if (!strcmp (operator, "!="))		/* materila != 'steel' */
		*retval = !(*retval);

	return (1);
}

/****************************  			*******************************/

GetID_N_Compute(catname, attrs, vals, types, numattrs, computed_id, flag )
char	*catname;                  /* I */
char	**attrs, **vals, **types;  /* I */
int	numattrs;                  /* I */
char    **computed_id;             /* O */
int	flag;			   /* I */
{
char    *fn = "GetID_N_Compute";
int	i, j, k, col, ind ;
int	len ;
int	x, texts, params ;
char	*ptr, *columns[MAX_PARAM_IN_FORMULA], 
        *text[MAX_PARAM_IN_FORMULA], str1[20],str2[20];
char    *rawid, *partnum_desc;
char    *to_lower();
int	NumConditions = 0, NoColsInID, col_indxs[MAX_PARAM_IN_FORMULA];

	
	for (i = 0; i < MAX_PARAM_IN_FORMULA; i = i + 1)
	{
		columns[i] = NULL;
		text[i]    = NULL;
	}

	MyFree( *computed_id ); /* Free any previous memory */

	_pdm_debug("Enter: GetID_N_Compute",0);

/*
	if( !GetPartnumberDesc( catname, attrs, types, vals, numattrs, &partnum_desc ))
		return( 0 );
*/
	if( !Getpartnumber( catname, &partnum_desc, flag ))
		return( 0 );

	/* Check to see if it is a formula */
	ptr = partnum_desc;
	while( *ptr )
		if( *ptr++ == '$' )
			break;
	if( *ptr == '\0')
	{
		_pdm_debug("returning computedID as it is %s", partnum_desc);
	        *computed_id = (char *)malloc(strlen(partnum_desc) + 1) ;
		strcpy(*computed_id, partnum_desc);
		MyFree ( partnum_desc );
		return(1);
	}

	_pdm_debug("attributes sent to getid_n_compute",0);
	for(i = 0;i<numattrs;i++)
	{
		_pdm_debug("%s",attrs[i]);	
		_pdm_debug("%s",vals[i]);	
	}
	
	/* For the given attrs and values, get the relevant function */
	/* This will be rawid */

	param_names = attrs;
	param_vals  = vals;
	param_types = types;
	no_params   = numattrs;

	if (!MakeConditionTable (partnum_desc, "NB", &ConditionTable[0], 
					   &ConditionTable[1],
					   &NumConditions))
	{
		MyFree (partnum_desc);
		return (0);
	}

	_pdm_debug("After MakeconditionTable: noconds = %d",NumConditions );
	_pdm_debug("ConditionTable[0][0] = %s",ConditionTable[0][0]);
	_pdm_debug("ConditionTable[1][0] = %s",ConditionTable[1][0]);

	rawid = (char *)malloc(10);
	for (i = 0; i < NumConditions; i++)
	{
	 	if( EvaluateCondition (ConditionTable[0][i]))
		{
			rawid = (char *)realloc( rawid,strlen( ConditionTable[1][i] ) + 1 );
			MemCheck(rawid);
		
			strcpy( rawid, ConditionTable[1][i]);	
			_pdm_debug( "raw id = %s", rawid );	
			break;
		}
	}

	if ( i == NumConditions )
	{
		/* None of the conditions satisfied with given values */
		/* Ideally should never ever happen */
		_pdm_debug("Some Errror Some Where\n",0);
		goto CleanUp;
	}

	/* Allocate local arrays */
	for (i = 0; i < MAX_PARAM_IN_FORMULA; i = i + 1)
	{
		columns[i] = (char *) malloc (COLNAMESIZ);
		text[i]    = (char *) malloc (TXTSIZ);
        	if ((columns[i] == NULL) || (text[i] == NULL))
		{
			_pdm_debug("Unable To Allocate Memory\n",0);
			goto CleanUp;
		}
	}
       
	/* Start parsing */
	j = 0;
	i = 0;
/* This part of code has been modified since it was not taking of
   formulae like XXXXXXXX$attr1!$attr2!. It expects something
   betn ! and $. ex XXXXXXXX$attr1!#$attr2!. Notice that # is there
   between ! and $ differentiating the attrnames. MaC 081393 */
/*
	ptr = NULL;

	ptr = strtok (rawid, DEL1);

	if (ptr == NULL) 
	{
		_pdm_debug( "Invalid string for Compute:%s:\n", rawid );
		goto CleanUp;
	}

	while (ptr != NULL)
	{
		_pdm_debug( "ptr = %s", ptr);
		strcpy (text[j++], ptr);	      Text in the string 
		ptr = strtok (NULL, DEL2);
		_pdm_debug("ptr = %s",ptr);
		strcpy (columns[i++] ,ptr);           Column names in the string
		ptr = strtok (NULL, DEL1);
	}

	NoColsInID = i;
*/
/***************************************************************************/

 len = strlen (rawid);
 _PDMdebug (fn, "length = %d\n", len);

 ptr = (char *) malloc (len);
 i=0; j=0; 

 x = 0;
 params = 0;
 texts = 0;
 while (x<len) {
  if (rawid[x] == '$' ) {
    i = 0; x++;
    while ((x<len) && rawid[x] != '!') {
     columns[params][i] = rawid[x];
     x++; i++;
       }
    if (x<len){
    columns[params][i] = '\0';
    _PDMdebug (fn, "columns[%d] = [%s]\n", params, columns[params]);
    params++;
      }
      }
  if (rawid[x] == '!' ) {
    j = 0; x++;
    while ((x<len) && rawid[x] != '$') {
     text[texts][j] = rawid[x];
     x++; j++;
       }
    if (x<len){
    text[texts][j] = '\0';
    _PDMdebug (fn, "text[%d] = [%s]\n", texts, text[texts]);
    texts++;
    }
      }
  if (rawid[x] != '$' && rawid[x] != '!' ) {
    j = 0;
    while ((x<len) && rawid[x] != '$') {
     text[texts][j] = rawid[x];
     x++; j++;
       }
    if (x<len){
    text[texts][j] = '\0';
    _PDMdebug (fn, "texts[%d] = [%s]\n", texts, text[texts]);
    texts++;
_PDMdebug (fn, "texts[%d] params[%d]\n", texts, params);
     }
   }
  }
_PDMdebug (fn, "texts[%d] params[%d]\n", texts, params);
     
	NoColsInID = params;
	j = params;



/***************************************************************************/
	_pdm_debug( "NocolsInID = %d ", NoColsInID);
	for(i = 0; i < NoColsInID; i++ )
	{
		_pdm_debug("Colname:%s", columns[i]);
		_pdm_debug("text:%s", text[i]);
	}

	/* Get the indexes of the column in the rawid	*/
	for (col = 0; col < NoColsInID;  col++ )
	{
                col_indxs[col] = -1 ;
		for (k = 0; k < numattrs ; k = k + 1)
		{
                        ptr = to_lower(columns[col]);
                        strcpy(str1,ptr);
                        ptr = to_lower(attrs[k]);
                        strcpy(str2,ptr);

			_pdm_debug("str1=%s",str1);
			_pdm_debug("str2=%s",str2);
			if (!strcmp (str1,str2))
			{
				_pdm_debug("Found Matching %s", str1);
				_pdm_debug("Matching Index %d", k);
				col_indxs[col] = k;
			        break;
			}
	        }

	        if (col_indxs[col] == -1 ) 
		{
			_pdm_debug( "Part Number Has Non-existent column\n",0 );
                        goto CleanUp;
	        }
	}
	
	/* Having gotten the indexes, construct the ID */
	/*  Set the ptr to the begining */
        *computed_id = (char *)malloc(1024) ;

	for (k = 0; k < j; k = k + 1) /* Notice j */
	{
               	if( k )
	   		strcat(*computed_id, text[k]);
               	else	 
                       	strcpy(*computed_id,text[0]); 

	   	strcat( *computed_id, DEL1);
	
	   	if (k < NoColsInID)
	   	{
			ind = col_indxs[k];
 		       	strcat (*computed_id, vals[ind]);
		       	strcat (*computed_id, DEL2);
		}
	}

	_pdm_debug("ComputedID = %s", *computed_id);


	FreeConditionTable (ConditionTable[0], ConditionTable[1],
						 NumConditions, NumConditions);

	for (i = 0; i < MAX_PARAM_IN_FORMULA; i = i + 1)
	{
	   MyFree(columns[i]);
	   MyFree(text[i]) ;
	}

	MyFree ( partnum_desc );

	return( 1 );


CleanUp:
	MyFree ( partnum_desc );

	FreeConditionTable (ConditionTable[0], ConditionTable[1],
						 NumConditions, NumConditions);

	for (i = 0; i < MAX_PARAM_IN_FORMULA; i = i + 1)
	{
	   MyFree(columns[i]);
	   MyFree(text[i]) ;
	}

	return( 0 );
}

GetattrsGivenID( computed_id, catname )     /* , noattrs, attrs, attrtype, vals )*/
char *computed_id, *catname;            /* I */
/*char **attrs, **attrtype, **vals;	* I *
int  noattrs;				* I */
{
char *partnum_desc, *cidpattn, *pattn;
int  i, NumConditions = 0;
char tmpstr[512];

	_pdm_debug("Enter: GetattrsGivenID= %s",computed_id);

/*
	if(! GetPartnumberDesc( catname, attrs, attrtype, vals, noattrs, &partnum_desc ) )
		return( 0 );
*/
	if( !Getpartnumber( catname, &partnum_desc,0 ))
		return( 0 );

	if (!MakeConditionTable (partnum_desc, "NB", &ConditionTable[0], 
					   &ConditionTable[1],
					   &NumConditions)) {
		MyFree ( partnum_desc );
		return (0);
	}

	_pdm_debug("Num of conditions = %d", NumConditions );

	strcpy( tmpstr, computed_id );
#if defined (clipper)
	PosMarkers( tmpstr, &cidpattn, 1“ );
#else
	PosMarkers( tmpstr, &cidpattn, 1 );
#endif
	_pdm_debug("cidpattern = %s", cidpattn );

	/* CondtionTable[1] contains all the formulae */
	for(i = 0;i < NumConditions; i++ )
	{
		strcpy( tmpstr, ConditionTable[1][i] );
		PosMarkers( tmpstr, &pattn, 0 );
		_pdm_debug("pattern = %s", pattn );

		if( !strcmp( pattn, cidpattn ) )
		{
			_pdm_debug("Matching pattern index = %d", i );
			break;
		}
	}

	if( i == NumConditions )
	{
		printf("Great Error, Should not come here\n");
		MyFree ( partnum_desc );
		FreeConditionTable (ConditionTable[0], ConditionTable[1],
					 NumConditions, NumConditions);
		return(0);
	}

	/* Now get the column names from the Matching Function */

	if( !getattrs( catname, ConditionTable[1][i], computed_id )) {
		MyFree ( partnum_desc );
		FreeConditionTable (ConditionTable[0], ConditionTable[1],
					 NumConditions, NumConditions);
		return(0);
	}


	MyFree ( partnum_desc );

	FreeConditionTable (ConditionTable[0], ConditionTable[1],
						 NumConditions, NumConditions);
	return( 1 );

}


GetPartnumberDesc_PDMNORM( catname, attr, attrtype, vals, numattr, partnum_desc )
char *catname;                   /* I */
char **attr, **attrtype, **vals; /* I */
int  numattr;			 /* I */
char **partnum_desc;             /* O */
{
char *query, *output_str, *ptr;
int  max_rows, error_code;
int  sts, i;
char *temp;

	_pdm_debug("Enter: GetPartnumberDesc",0);
	_pdm_debug(" catalog name= %s",catname);

	/* Prepare query to get n_itemname (IF THEN ELSE) from view ... */
	query = (char *)malloc(1024);
	MemCheck(query);

	sprintf( query, "Select n_itemno, n_itemname from %s ", catname );
	strcat( query, " where n_itemno < 0" );

	/* add the static attributes/values to the where clause */
	temp = (char *)malloc(3);
	temp[0]='\0';
	for( i = 0; i < numattr; i++ )
	{
		if( !strcmp( attr[i],"p_quantity")) /* do not add dyn attrs */
			break;
		if( !strcmp( attr[i],"n_catalogname") ||
		    !strcmp( attr[i],"serial_no")    ||
		    !strcmp( attr[i],"p_explode")    ||
		    !strcmp( attr[i],"p_attach")     ||
		    !strcmp( attr[i],"p_incstr")     ||
		    !strcmp( attr[i],"p_incbom"))
			continue;
		temp = (char *)realloc(temp, strlen(temp) + strlen(attr[i]) +
					     strlen( vals[i] ) + 25);
		MemCheck(temp);
		strcat(temp, " and ");
		strcat(temp, attr[i]);
		strcat(temp,"=");
		if( !strncmp(attrtype[i],"char",4) ||
		    !strcmp(attrtype[i],"Expression text"))
		{
			strcat(temp,"'");
			strcat(temp,vals[i]);
			strcat(temp,"'");
		}
		else
			strcat(temp,vals[i]);
	}
	_pdm_debug(" clause = %s",temp);

	query = (char *)realloc(query, strlen(temp) + strlen(query) + 1 );
	MemCheck(query);
	
	strcat(query, temp);
	MyFree(temp);

	_pdm_debug("RIS query = %s", query );

	/* Send RIS query */
	max_rows = 0;
	sts = RISquery (query, &max_rows, &output_str, &error_code);

	MyFree(query);
	if (sts < 0)
	{
		_pdm_debug ("Error In RIS Operation - %d\n", error_code);
		free(output_str);
		return(0);
	}

	_pdm_debug("RISquery output_str = %s", output_str );

	*partnum_desc = (char *) malloc( 10 );
	MemCheck( *partnum_desc );

	/* From the output_str get the n_itemname */
	ptr = strtok( output_str, "~" ); /* n_itemno */
	ptr = strtok( NULL, "~" ); /* n_itemname */

	(*partnum_desc)[0] = '\0';
	while( ptr )
	{
		*partnum_desc = (char *)realloc ( *partnum_desc, strlen(*partnum_desc) + 
							strlen(ptr) + 1 );
		MemCheck( *partnum_desc );
		strcat( *partnum_desc, ptr );

		ptr = strtok( NULL, "~" ); /* n_itemno */
		ptr = strtok( NULL, "~" ); /* n_itemname */
	}

	free( output_str );

	_pdm_debug( "Total partnum_desc is %s", *partnum_desc );

 /* No IF THEN construct 
	if( strncmp( *partnum_desc, "ID,NB,",6) )
	{
		temp = (char *)malloc(strlen(*partnum_desc) + 1);
		MemCheck( temp );
		*partnum_desc = (char *)realloc( *partnum_desc, strlen(*partnum_desc) +
								strlen("ID,NB,NB=''''") + 5 );
		MemCheck( (*partnum_desc) );
		strcpy( temp, *partnum_desc );

		sprintf( *partnum_desc,"%s","NB='" );
		strcat( *partnum_desc, temp );
		strcat( *partnum_desc,"'");
	}
*/
	_pdm_debug( "Finally, partnum_desc is %s", *partnum_desc );
		
	return( 1 );

CleanUp:
	return( 0 );


}

NOTUSED_GetPartnumberDesc( catname, attr, attrtype, vals, numattr, partnum_desc )
char *catname;                   /* I */
char **attr, **attrtype, **vals; /* I */
int  numattr;			 /* I */
char **partnum_desc;             /* O */
{
char *query, *output_str, *ptr;
int  max_rows, error_code;
int  sts;

	_pdm_debug("Enter: GetPartnumberDesc",0);
	_pdm_debug(" catalog name= %s",catname);

	/* Prepare query to get n_itemname (IF THEN ELSE) from e_<catalog> ... */
	query = (char *)malloc(1024);
	MemCheck(query);

	sprintf( query, "Select n_itemno, n_itemname from e_%s ", catname );
	strcat( query, " where n_itemno < 0" );

	_pdm_debug("RIS query = %s", query );

	/* Send RIS query */
	max_rows = 0;
	sts = RISquery (query, &max_rows, &output_str, &error_code);

	MyFree(query);
	if (sts < 0)
	{
		_pdm_debug ("Error In RIS Operation - %d\n", error_code);
		free(output_str);
		return(0);
	}

	_pdm_debug("RISquery output_str = %s", output_str );

	*partnum_desc = (char *) malloc( 10 );
	MemCheck( *partnum_desc );

	/* From the output_str get the n_itemname */
	ptr = strtok( output_str, "~" ); /* n_itemno */
	ptr = strtok( NULL, "~" ); /* n_itemname */

	(*partnum_desc)[0] = '\0';
	while( ptr )
	{
		*partnum_desc = (char *)realloc ( *partnum_desc, strlen(*partnum_desc) + 
							strlen(ptr) + 1 );
		MemCheck( *partnum_desc );
		strcat( *partnum_desc, ptr );

		ptr = strtok( NULL, "~" ); /* n_itemno */
		ptr = strtok( NULL, "~" ); /* n_itemname */
	}

	free( output_str );

	_pdm_debug( "Total partnum_desc is %s", *partnum_desc );

	return( 1 );

CleanUp:
	return( 0 );


}

#define	N_ITEMNAME	0
#define	N_ITEMDESC	1

Getpartnumber( catname, partnum_desc, flag )
char *catname;                   /* I */
char **partnum_desc;             /* O */
int	flag;			 /* I */	/* n_itemname or n_itemdesc ? */
{
char *query, *output_str, *ptr;
int  max_rows, error_code;
int  sts;

	_pdm_debug("Enter: GetPartnumberDesc",0);
	_pdm_debug(" catalog name= %s",catname);

	/* Prepare query to get n_itemname (IF THEN ELSE) from e_<catalog> ... */
	query = (char *)malloc(1024);
	MemCheck(query);

	if (flag == N_ITEMNAME)
		sprintf( query, "Select n_itemno, n_itemNAME from e_%s ", catname );
	else if (flag == N_ITEMDESC)
		sprintf( query, "Select n_itemno, n_itemDESC from e_%s ", catname );
	else
	{
		_pdm_debug ("Unknown flag in Getpartnumber(), expected 0 or 1 (N_ITEMNAME or N_ITEMDESC)", 0);
		return (0);
	}

	strcat( query, " where n_itemno < 0" );

	_pdm_debug("RIS query = %s", query );

	/* Send RIS query */
	max_rows = 0;
	sts = RISquery (query, &max_rows, &output_str, &error_code);

	MyFree(query);
	if (sts < 0)
	{
		_pdm_debug ("Error In RIS Operation - %d\n", error_code);
		free(output_str);
		return(0);
	}

	_pdm_debug("RISquery output_str = %s", output_str );

	*partnum_desc = (char *) malloc( 10 );
	MemCheck( *partnum_desc );

	/* From the output_str get the n_itemname */
	ptr = strtok( output_str, "~" ); /* n_itemno */
	ptr = strtok( NULL, "~" ); /* n_itemname */

	(*partnum_desc)[0] = '\0';
	while( ptr )
	{
		*partnum_desc = (char *)realloc ( *partnum_desc, strlen(*partnum_desc) + 
							strlen(ptr) + 1 );
		MemCheck( *partnum_desc );
		strcat( *partnum_desc, ptr );

		ptr = strtok( NULL, "~" ); /* n_itemno */
		ptr = strtok( NULL, "~" ); /* n_itemname */
	}

	free( output_str );

	_pdm_debug( "Total partnum_desc is %s", *partnum_desc );

	return( 1 );

CleanUp:
	return( 0 );
}

PosMarkers( inpattn, outpattn, flg )
char *inpattn;      /* I */
int  flg;	    /* I */
char **outpattn;    /* O */
{
char *ptr = NULL;
char tmp[3];
int  i = 1;

	_pdm_debug( " Entered PosMarkers with pattn: %s", inpattn );

	ptr = strtok( inpattn, DEL1 );

	if( ptr == NULL )
	{
		printf(" Illegal Pattern " , 0 );
		return(0);
	}

	*outpattn = (char *) malloc( sizeof(char) );

	(*outpattn)[0] = '\0';
	while( ptr != NULL )
	{
		/* Add for $XXX. */
		*outpattn = (char *) realloc( *outpattn, strlen( *outpattn ) +
						strlen( ptr ) + 7 + 1 ); 
		MemCheck( *outpattn );

		strcat( *outpattn, ptr ); /* Text */
		strcat( *outpattn, DEL1 );
		sprintf( tmp, "%d%s", i++,DEL2 );
		strcat( *outpattn, tmp );

		ptr = strtok( NULL, DEL2 ); /* Ignore this */
		ptr = strtok( NULL, DEL1 );
/*		if( flg && (ptr!=NULL))  The values in ComputedID itself can have a '.' like 2.00
                                   in which case we need to skip to the next dot 
		{
			strcpy(tmpstr, ptr);
			j = 0;
			while( tmpstr[j] )
			{
				if ( tmpstr[j] == '.' ) 
					ptr = &tmpstr[++j];
				else j++;
			}
		}
*/	}

	_pdm_debug( "Output pattn %s", *outpattn);

	return( 1 );

CleanUp:
	return( 0 );
}


