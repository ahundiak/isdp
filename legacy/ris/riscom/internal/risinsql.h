/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**  NAME:							risinsql.h
**  AUTHORS:						Sunil Murthy
**  CREATION DATE:					11/92
**  ABSTRACT:
**		Definitions of internal sqlvar, sqlda and sqlda_info.
**
**  REVISION HISTORY:

		Two new data structures internal_ris_blob and internal_ris_text
		are added for blob support.

										
									 James Chang 6/93

		Two new fields extern_sqlname and max_blob_sqllen are added 
		into internal sqlvar structure. The old internal_sqlvar is
		renamed as internal_sqlvar_4.

									 James Chang 12/93
*/

#ifndef RISINSQL_H
#define RISINSQL_H

typedef struct internal_ris_blob
{
    char 	*filename;     	/* pointer to the name of file holding blob data */
	char 	*array;			/* pointer to the char array holding blob data	*/ 
	unsigned int  array_size; /* the size of the char array, if it is used */
    unsigned int  input_len;  /* the total length of the blob data inserted,
								 returned by server. */
    unsigned int  output_len; /* the total length of the blob data retrieved,
								 returned by server */
    unsigned int  file_offset; /* retrieval only, the offset of the file  
								  where blob is to be appended; 
								  0 if the file is to be over written */
    unsigned char file_used  ; /* the flag to indicate if a file is used */
	char pad[11];
}internal_ris_blob;

typedef struct internal_ris_text
{
    char 	*filename;     	/* pointer to the name of file holding text data */
	char 	*array;			/* pointer to the char array holding text data */ 
    unsigned int  array_size; /* the size of the char array, if it is used */
    unsigned int  input_len; /* the total length of the blob data inserted,
								 returned by server. */
    unsigned int  output_len; /* the total length of the blob data retrieved,
								 returned by server */
    unsigned int  file_offset; /* retrieval only, the offset of the file  
								  where text is to be appended; 
								  0 if the file is to be over written */
    unsigned char file_used  ; /* the flag to indicate if a file is used */
	char pad[11];
}internal_ris_text;

/*
*** internal_sqlvar byte alignment
*** -----------------
*** |  4    |   4   |
*** -----------------
*** | 2 | 2 | 2 | 2 |
*** -----------------
*** | 2 |           |
*** -----           |
*** |               |
*** |               | 
*** |        34     |
*** |               |
*** |               |
*** |       --------|
*** |       |   4   |
*** -----------------
*** | 2 |     6     |
*** -----------------
*/
typedef struct internal_sqlvar
{
    char   *sqldata;        /* pointer to input or output data buffer       */
    long   *sqlind;         /* pointer to null indicator data buffer        */
    short   sqltype;        /* sql data type of input or output parameter   */
    short   sqlnull;        /* nulls allowed                                */
    short 	sqllen;         /* length of input or output data buffer        */
    short  sqlscale;        /* precision and scale for decimal data type    */
    struct
    {
        short   sqlnamel;        /* length of string in sqlnamec            */
        char    sqlnamec[34];    /* column name (NOT null terminated)       */
    } sqlname;
/*******Caution!!! All fields above this line must match sqlvar structure ****/
/*******           in ris.h                                               ****/
	unsigned int	dbsqllen;  /* db length of input or output data buffer   */
	short	dbsqltype;      /* db sql data type of input or output parameter */
    struct
    {
        short   sqlnamel;        /* length of string in sqlnamec            */
        char    sqlnamec[34];    /* column name (NOT null terminated)       */
    } extern_sqlname;
	char	pad[2];
	unsigned int max_blob_sqllen; /* the max length for blob/text data       */
	char	pad1[12];			/* future usage */
} internal_sqlvar;

typedef struct internal_sqlvar_4
{
    char   *sqldata;        /* pointer to input or output data buffer       */
    long   *sqlind;         /* pointer to null indicator data buffer        */
    short   sqltype;        /* sql data type of input or output parameter   */
    short   sqlnull;        /* nulls allowed                                */
    short 	sqllen;         /* length of input or output data buffer        */
    short  sqlscale;        /* precision and scale for decimal data type    */
    struct
    {
        short   sqlnamel;        /* length of string in sqlnamec            */
        char    sqlnamec[34];    /* column name (NOT null terminated)       */
    } sqlname;
/*******Caution!!! All fields above this line must match sqlvar structure ****/
/*******           in ris.h                                               ****/
	unsigned int	dbsqllen;  /* db length of input or output data buffer   */
	short	dbsqltype;      /* db sql data type of input or output parameter */
	char	pad[6];
} internal_sqlvar_4;

typedef struct internal_sqlda
{
    short   sqln;       /* number of sqlvar structs pointed to by sqlvar    */
    short   sqld;       /* number of input or output sqlvars in statement   */
    internal_sqlvar *sqlvar; /* array of input or output sqlvar structures  */
} internal_sqlda;

/* 
**	This is used to build/interpret client/server dictionary data.  See dd.h.
*/

typedef struct internalsqlda_info
{
    int				sqltype;
    short			sqllen;
	short			dbsqltype;
	unsigned int 	dbsqllen;
} internalsqlda_info;

#endif
