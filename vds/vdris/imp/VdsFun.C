/* $Id: VdsFun.C,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdris/imp / VdsFun.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VdsFun.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:12  cvs
 *	Initial import to CVS
 *	
 * Revision 1.3  1999/10/12  20:18:54  pinnacle
 * TR179900807
 *
 * Revision 1.2  1999/04/30  21:55:04  pinnacle
 * Double to string functions
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
 * Revision 1.2  1996/04/21  23:27:24  pinnacle
 * Replaced: vdris/imp/*.C for:  by v240_int for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 * 04/19/96   tlb  Add prototypes
 * 04/30/99   ah   Added standard routines for converting ris data to strings
 * 08/26/99   ejm  TR_179900807: Modified VdsRisSqlDblToStr: a density value 
 *		     of 1.1e-08 was being returned as zero, leading to a sqrt 
 *		     DOMAIN error downstream.
 * -------------------------------------------------------------------*/

#include	<stdio.h>
#include	<string.h>

#include	"VDSris_def.h"
#include	"VDSris_siz.h"
#include	"VDSload.h"
#include	"VDSserver.h"
#include	"v_risproto.h"
#include        "VDrisFunc.h"

#define		AS_DEBUG	1

extern		int		NFMdecrypt();

/* -----------------------------------------------------------------
 * Convert a double to string using 3 digits of percision
 * drop any traling zeros
 * drop decimal point for whole numbers
 * returns empty string if dont have a number at all
 *
 * buf must be big enough
 * 
 * Relying on compiler to convert floats to doubles
 */
int VdsRisSqlDblToStr(double val, char *buf)
{
  int retFlag = 0;
  char *p;
  char  fmt[20];
  int   num = 3;
  
  // Arg check
  if (buf == NULL) goto wrapup;
  
/*
  val: %g: 1.1e-08, %f: 0.000000
*/

  // Need to deal with cases when %g returns more than 3 levels of precision
  // For example 1.1234
  sprintf(buf,"%g",val);

  // TR179900807 Check first for exponential number
  p = strchr(buf,'e');
  if( p ){
    retFlag = 1;
    goto wrapup;
  }

  p = strchr(buf,'.');
  if (p) num = strlen(p+1);

  // Use 3 digitis almost all the time
  if (num <= 3)   sprintf(buf,"%.3f",val);
  else {
    sprintf(fmt,"%%.%df",num);
    sprintf(buf,fmt,val);
  }
  
  // Drop blanks
  for(p = buf + strlen(buf) - 1; (p >= buf) && (*p == '0'); p--);
  if (p < buf) *buf = 0;
  else {
    if (*p == '.') *p = 0;
    else *(p+1) = 0;
  }
  retFlag = 1;

  
wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Convert ris int to string
 * just include for completeness
 *
 * Rely on compiler to convert shorts to ints
 */
int VdsRisSqlIntToStr(int val, char *buf)
{
  int retFlag = 0;
  
  // Arg check
  if (buf == NULL) goto wrapup;
  
  // standard convert
  sprintf(buf,"%d",val);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Convert ris string to c string
 * Use length and null terminate it
 * drop any trailing blanks
 */
int VdsRisSqlStrToStr(char *str, int len, char *buf)
{
  int retFlag = 0;
  char *p;

  // Arg check
  if (buf == NULL) goto wrapup;
  *buf = 0;
  if (str == NULL) goto wrapup;
  if (len < 1) goto wrapup;
  
  // Copy and NULL
  memcpy(buf,str,len);
  p = buf + len;
  *p = 0;
  for(p--; (p >= buf) && (*p == ' '); p--);
  *(p+1) = 0;

  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ---------------------------------------------------------------
 * Converts a ris date time to string
 * input is 6 decimal values (sec,min,hours,day,month,year)
 * output format matches that displayed by risgui
 */
int VdsRisSqlDateTimeToStr(char *str, int len, char *buf)
{
  int retFlag = 0;
  int *d;
  
  // Arg check
  if (buf == NULL) goto wrapup;
  if (str == NULL) goto wrapup;
  if (len != 24) {
    printf("*** Converting ris date time to string, invalid length %d\n",len);
    strcpy(buf,"UNK DATE TIME");
    goto wrapup;
  }

  // Do it
  d = (int*)str;
  sprintf(buf,
	  "%04d-%02d-%02d:%02d:%02d:%02d",
	  d[5],d[4],d[3],d[2],d[1],d[0]);
  retFlag = 1;
  
wrapup:
  return retFlag;
}


/******************************************************************************/
/*
   Author : Marc Fournier (ISDC)
   Date   : 26-Nov-1991         
*/
/******************************************************************************/

/******************************************************************************/
int VdsLeadingTrash ( 	char	*string,
			char	trash,
			int	all
			) 
/*.VdsLeadingTrash*/
{
	int	i;
	int	len;
	char	work[MAXSTRING];

	len  = strlen(string);

again:	if (string[0] == trash)
	  {
	   for(i=1;i<=len;i++) work[i-1] = string[i];
	   strcpy ( string, work);
	   len = strlen(string);
	  }
	else goto quit;
	if (all != NULL) goto again;
quit:
	return	strlen(string);
}
/******************************************************************************/

/******************************************************************************/
int VdsTrailingTrash (  char	*string,
			char	trash,
			int	all
			)
/*.VdsTrailingTrash*/
{
	int	len;

	len = strlen(string);
again:	if (string[len-1] == trash)
	  {
	   string[len-1] = 0;
	   len = strlen(string);
	  }
	else goto quit;
	if (all != NULL) goto again;
quit:
	return	strlen(string);
}
/******************************************************************************/

/******************************************************************************/
VdsCleanString ( char	*string)

/*.VdsCleanString*/
{
	if (VdsLeadingTrash  (string, BACK_N, 1) == FAILURE) return FAILURE;
	if (VdsLeadingTrash  (string, BLANK,  1) == FAILURE) return FAILURE;
	if (VdsTrailingTrash (string, BACK_N, 1) == FAILURE) return FAILURE;
	if (VdsTrailingTrash (string, BLANK,  1) == FAILURE) return FAILURE;
	return strlen(string);
}
/******************************************************************************/

/******************************************************************************/
VdsNormalize (char * string)

/*.VdsNormalize*/
{
	int	i;
	int	j;
	int	len;
	char	work[MAXSTRING];

	len = strlen(string);
	for(i=0,j=0;i<=len;i++,j++)
	  {
	   work[j] = string[i];
	   if (string[i] == C_QUOTE)
	     {
	      j++;
	      work[j] = C_QUOTE;
	     }
	  }
	strcpy(string,work);
	return strlen(string);
}
/******************************************************************************/

/******************************************************************************/
int VdsTwoString (string,before,after)

	char	*string;
	char	*before;
	char	*after;

/*.VdsTwoString*/
{
	int	len;
	int	i;
	int	min;
	int	max;

	len = VdsCleanString(string);
	if (len == FAILURE) return FAILURE;
	len = VdsTrailingTrash (string, C_COMMA,  NULL);
	if (len == FAILURE) return FAILURE;

	for (i=0,min=0,max=0;i<len;i++)
	  {
	   if ( (string[i] == BLANK) || (string[i] == BACK_T) )
	     {
	      if (min == 0) min = i;
	      max = i;
	     }
	  }
	
	before[0] = 0;
	for (i=0;i<min;i++) before[i] = string[i];
	before[min] = 0;

	after[0] = 0;
	for (i=max+1;i<=len;i++) after[i-max-1] = string[i];

	return SUCCESS;
}
/******************************************************************************/

/******************************************************************************/
int VdsSplitString (string,charnum,before,after)

	char	*string;
	int	charnum;
	char	*before;
	char	*after;

/*.VdsSplitString*/
{
	int	len;
	int	i;

	len = VdsCleanString(string);
	if (len == FAILURE) return FAILURE;
        if (charnum >= len) return FAILURE;

        for (i=0; i<=charnum; i++) before[i] = string[i];
        before[charnum+1] = 0;

        for (i=charnum+1; i<=len; i++) after[i-charnum-1] = string[i];

	len = strlen(string);
	return len;
}
/******************************************************************************/

/******************************************************************************/
int VdsZeroForNull (string)

        char    *string;

/*.VdsZeroForNull*/
{
        char    before[MAXSTRING];
        char    after[MAXSTRING];
        int     i;
	int	len;

        len = strlen (string);
        for (i=0; i<len-1; i++)
          {
           if ((string[i] == C_COMMA) && (string[i+1] == C_COMMA))
             {
              if (VdsSplitString ( string, i, before, after) == FAILURE)
	         return FAILURE;
              sprintf ( string, "%s0%s", before, after);
              len = strlen (string);
             }
          }

        return strlen (string);
}
/******************************************************************************/

/******************************************************************************/
int VdsRetrieveLoadData (ascii, p_load)

	char		*ascii;
	struct	MFload	*p_load;

/*.VdsRetrieveLoadData*/
{
	FILE		*p_file;
	char		string[MAXSTRING];

        /*|Open file */
        p_file = fopen ( ascii, "r");
        if (p_file == NULL)
          {
           printf ( "Cannot open file <%s>\n", ascii);
           return FAILURE;
          }

        /*|Store data in MFload structure */
        p_load->num = 0;
        while ( fgets ( string, MAXSTRING, p_file) != 0)
          {
	   if (VdsTwoString( string,
			     p_load->data[p_load->num].table,
			     p_load->data[p_load->num].file) == FAILURE)
	      return FAILURE;
	   if (VdsLeadingTrash  ( p_load->data[p_load->num].file,
				  C_2QUOTE,
				  NULL) == FAILURE)
	      return FAILURE;
	   if (VdsTrailingTrash ( p_load->data[p_load->num].file,
				  C_2QUOTE,
				  NULL) == FAILURE)
	      return FAILURE;
	   p_load->num++;
	  }
        /*|Close file */
        fclose (p_file);

        return SUCCESS;
}
/******************************************************************************/

/******************************************************************************/
int VdsStaticDatatype (table_name,load_path,datatype,p_number,ddl_file)

	char		*table_name;
	char		*load_path;
	int		*datatype;
	int		*p_number;
	char		*ddl_file;

/*.VdsStaticDatatype*/
{
	char		ascii_file[MAXWORD];
	char		line[MAXWORD];
	int		l_lin;
	FILE		*p_file;
	char		string[MAXSTRING];
	int		l_bef;
	int		l_aft;
	int		l_cha;
	int		find = 0;
	char		attr[MAXWORD];
	char		type[MAXWORD];

	/*|Construct absolute path to ASCII file */
	sprintf ( ascii_file, "%s%s", load_path, ddl_file);

	/*|Open ASCII file */
	p_file = fopen ( ascii_file, "r");
	if (p_file == NULL)
	  {
	   printf ("Can't fopen %s\n", ascii_file); 
	   return FAILURE;
	  }

	/*|Prepare data file scan */
	sprintf ( line, "%s %s", CREATE_TABLE_ORDER, table_name);
	l_lin = strlen(line);
	l_bef = strlen(BEFORE_DATA);
	l_aft = strlen(AFTER_DATA);
	l_cha = strlen(CHAR_NAME);
	*p_number = 0;

	/*|Scan data file */
	while ( fgets ( string, MAXSTRING, p_file) != 0)
	  {
	   if ( (strncmp ( string, AFTER_DATA, l_aft) == 0) && (find == 2) )
	     {
	      find = 0;
	      break;
	     }
	   else if (find == 2)
	     {
	      if (VdsTwoString ( string, attr, type) == FAILURE)
		{
		 fclose (p_file);
 		 return FAILURE;
		}
	      if (!strncmp( type, CHAR_NAME, l_cha)) strcpy ( type, CHAR_NAME);
	      datatype[*p_number] =  VdsEvaluateDatatype(type);
	      (*p_number)++;
	     }
	   else if (strncmp ( string, line, l_lin) == 0) find = 1;
	   else if ( (strncmp ( string, BEFORE_DATA, l_bef) == 0)
	        &&   (find == 1) ) find = 2;
	  }

	/*|Close file */
	fclose (p_file);
	return SUCCESS;
}
/******************************************************************************/

/******************************************************************************/
int VdsEvaluateDatatype (datatype)

	char	*datatype;

/*.VdsEvaluateDatatype*/
{

	int	inttype;

	if      (strcmp ( datatype, "char") 	 == 0)
	   inttype = CHAR;
	else if (strcmp ( datatype, "numeric") 	 == 0)
	   inttype = NUMERIC;
	else if (strcmp ( datatype, "decimal") 	 == 0)
	   inttype = DECIMAL;
	else if ( (strcmp ( datatype, "int") 	 == 0)
	     ||   (strcmp ( datatype, "integer") == 0) )
	   inttype = INT;
	else if (strcmp ( datatype, "smallint")  == 0)
	   inttype = SMALLINT;
	else if (strcmp ( datatype, "real") 	 == 0)
	   inttype = REAL;
	else if (strcmp ( datatype, "double") 	 == 0)
	   inttype = DOUBLE;
	else if( strcmp( datatype, "timestamp" ) == 0 )
	   inttype = DATE;
	else inttype = FAILURE;

#ifdef TRACE
printf("VdsEvaluateDatatype on <%s> : %d\n", type, inttype);
#endif

	return inttype;
}
/******************************************************************************/

/******************************************************************************/
int VdsNetdecode ( encode, decode)

	char		encode[];
	char		decode[];

/*.VdsNetdecode*/
{

	int		i;
	int		len;
	int		n=0;

	len = strlen(encode);
	if (encode[len - 1] == '\n') encode[len - 1] = 0;
	len = strlen(encode);

	/*|Search the fist ':' */
	for (i=0;i<len;i++) 
	 {
	  if(encode[i] == ':') 
	   { 
	    n = i; 
	    break;
	   } 
	 }

	/* MF correction (10 August 1992) */
/*
printf("length of <%s> = %d\n", &encode[i], strlen(&encode[i]) );
*/
	if (strlen(&encode[i]) == 27) {
	   NFMdecrypt ( &encode[i+2], decode);
	}
	else {
	   NFMdecrypt ( &encode[i+1], decode);
	}
/*
printf("\t\t>>> decode is <%s>\n", decode);
*/

	return SUCCESS;
}
/******************************************************************************/

/******************************************************************************/
int VdsJoker (  string, number)

	char	*string;
	int	number;

{
	int	i;

	if (number <= 0) return FAILURE;

	if (string == NULL)	string[0] = 0;

	strcat ( string, " (?");
	for ( i=1; i<number; i++) strcat ( string, ",?");
	strcat ( string, ")");

	return SUCCESS;
}
/******************************************************************************/

/*****************************************************************************/
int VdsSqlAscii( tab_nam, col_num, col_typ, col_val, fp )

        char            *tab_nam;
        int             col_num;
        int             *col_typ;    /* Not Used  MSM  040793 */
        char            **col_val;
        FILE            *fp;
{

        int             i;
        char            query[MAXBUFF]; /* SQL query string  */
        char            values[MAXBUFF]; /* SQL query string  */

        sprintf(query,"insert into %s",tab_nam );
        sprintf(values," values (");
        for ( i=0; i<col_num; i++ )
        {
                sprintf(values,"%s \"%s\",",values,col_val[i]);
        }
        values[strlen(values)-1] = 0;
        strcat(values,");");
        strcat(query,values);

        fprintf(fp,"%s\n",query);
        return SUCCESS;

}

int VdsConvertDatatype (inttype, chartype)
int	inttype;
char	*chartype;

/*.VdsConvertDatatype*/
{
	switch ( inttype ) {
	case CHAR:	strcpy(chartype,"char");
			break;
	case NUMERIC:	strcpy(chartype,"numeric");
			break;
	case DECIMAL:	strcpy(chartype,"decimal");
			break;
	case INT:	strcpy(chartype,"integer");
			break;
	case SMALLINT:	strcpy(chartype,"smallint");
			break;
	case REAL:	strcpy(chartype,"real");
			break;
	case DOUBLE:	strcpy(chartype,"double");
			break;
	default:
			return FAILURE;
	}

	return SUCCESS;
}
/******************************************************************************/









