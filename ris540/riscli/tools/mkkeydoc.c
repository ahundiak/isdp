/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**  NAME:                           mkkeydoc.c
**  AUTHORS:
**  CREATION DATE:
**  ABSTRACT:
**
**  REVISION HISTORY:
**      Removed this file from ristools and put it under riscli/tools
**      Also prototyped this file.
**      - Sunil 1/20/93
**      Updated the Sybase, Oracle and Ingres keywords with the change
** 		of versions. 
**	Added the MSSQL keywords.
**		- Radha 10/3/94
*/

/*
**	INCLUDES
*/
#include <stdio.h>
#include <string.h>
#include "ris.h"
#include "keyword.h"
#if defined(WIN32) || defined(DOS)
#include <sys\stat.h>
#else
#include <sys/stat.h>
#endif

  
/*
**  DEFINES
*/

/*
**  TYPES
*/

/*
**  FUNCTION PROTOTYPES
*/
#define mkkeydoc_c
#include "mkkeydoc.prt"
#include "sys.prt"
#include "wrap.prt"

/*
**  VARIABLES
*/
char tablefile[256] = "words_table";
char ris[256] = "ris_words";
char informix[256] = "informix_words";
char oracle[256] = "oracle_words";
char ingres[256] = "ingres_words";
char db2[256] = "db2_words";
char rdb[256] = "rdb_words";
char sybase[256] = "sybase_words";
char mssqlsr[256] = "MSsqlsr_words";
char sqlds[256] = "sqlds_words";
char adabas[256] = "adabas_words";
char os400[256] = "os400_words";

FILE *fdDOC;
FILE *fdX;
FILE *fdO;
FILE *fdI;
FILE *fdD;
FILE *fdR;
FILE *fdY;
FILE *fdM;
FILE *fdS;
FILE *fdA;
FILE *fd4;
FILE *fdZ;

int xflag = 0, oflag = 0, iflag = 0, dflag = 0;
int rflag = 0, yflag = 0, mflag = 0, sflag = 0, aflag = 0;
int _4flag = 0, zflag = 0, tflag = 0;

/*
**  FUNCTIONS
*/

/******************************************************************************/

int main(
	int argc,
	char **argv)
{

	int	i = 0;

	if (argc == 1)
	{
		gen_exit(0);
	}
	while (++i<argc)
	{
		if (argv[i][0] == '-')
		{
			switch (argv[i][1]) {
				case 'x':
				case 'X': 	xflag = 1;
							i = fnamecpy(argv,argc,i,informix);
							break;	
				case 'o':
				case 'O': 	
							oflag = 1;
							i = fnamecpy(argv,argc,i,oracle);
							break;	
				case 'i': 
				case 'I': 	iflag = 1;
							i = fnamecpy(argv,argc,i,ingres);
							break;	
				case 'd':
				case 'D': 	dflag = 1;
							i = fnamecpy(argv,argc,i,db2);
							break;	
				case 'r': 
				case 'R': 	rflag = 1;
							i = fnamecpy(argv,argc,i,rdb);
							break;	
				case 'y':
				case 'Y': 	yflag = 1;
							i = fnamecpy(argv,argc,i,sybase);
							break;	
				case 'm':
				case 'M': 	mflag = 1;
							i = fnamecpy(argv,argc,i,mssqlsr);
							break;	
				case 's':
				case 'S': 	sflag = 1;
							i = fnamecpy(argv,argc,i,sqlds);
							break;	
				case 'a':
				case 'A': 	aflag = 1;
							i = fnamecpy(argv,argc,i,adabas);
							break;	
				case '4':
							_4flag = 1;
							i = fnamecpy(argv,argc,i,os400);
							break;	
				case 'z': 
				case 'Z': 	zflag = 1;
							i = fnamecpy(argv,argc,i,ris);
							break;	
				case 't':
				case 'T': 	tflag = 1;
							i = fnamecpy(argv,argc,i,tablefile);
							break;	
				default:
							gen_exit(0);
			}	
		}
		else
			{
			gen_exit(0);
			}
	}

   	if (tflag)
		DOCgen(tablefile);
	DOCgen2();

	return 0;
}

/******************************************************************************/

static void DOCgen(
	char *genfile)
{

	int	i, count;
	struct Keyword	*ptr = keywords;
	
	count = sizeof(keywords)/sizeof(struct Keyword);
    fdDOC = open_words(genfile);
	fprintf(fdDOC," **************************************************"
	       "*****************************\n");
    fprintf(fdDOC," Copyright 1994, Intergraph Corporation, All Rights Reserved\n");
	fprintf(fdDOC," **************************************************"
	       "*****************************\n");
    fprintf(fdDOC,"\n\n");
    fprintf(fdDOC," R = reserved word or keyword.\n");
    fprintf(fdDOC," May not be used as an identifier in any interface to the specified system.\n");
    fprintf(fdDOC,"\n");
    fprintf(fdDOC," RIS: Intergraph's Relational Interface System\n");
    fprintf(fdDOC," IFX: Informix Version 4.1\n");
    fprintf(fdDOC," ORA: Oracle Version 6.0 and Oracle Version 7.0\n");
    fprintf(fdDOC," IGS: Ingres Version 6.4\n");
    fprintf(fdDOC," DB2: IBM DB2 Release 2\n");
    fprintf(fdDOC," RDB: Rdb Version 4.0\n");
    fprintf(fdDOC," MSSQL: Microsoft SQL Server Version 4.x\n");
    fprintf(fdDOC," SYB10: Sybase System 10\n");
    fprintf(fdDOC," SDS: IBM SQL/DS Version 2 Release 2\n");
    fprintf(fdDOC," ADB: Adabas Version 5\n");
    fprintf(fdDOC," OS4: IBM os400\n");
    fprintf(fdDOC,"\n");

	fprintf(fdDOC," **************************************************"
	       "*****************************\n");
	fprintf(fdDOC," KEYWORD                  |RIS|IFX|ORA|IGS|DB2|RDB|"
	       "MSQL|SYB10|SDS|ADB|OS4|\n");
	fprintf(fdDOC," -------                  |---|---|---|---|---|---|"
           "----|-----|---|---|---|\n");

	for (i=0; i<count; i++) {
		fprintf(fdDOC," %-24s | %c | %c | %c | %c | %c | %c | %c  |"
		       "  %c  | %c | %c | %c |\n",
			ptr->keyword,
			ptr->dbms&Z?'R':' ',
			ptr->dbms&X?'R':' ',
			ptr->dbms&O?'R':' ',
			ptr->dbms&I?'R':' ',
			ptr->dbms&D?'R':' ',
			ptr->dbms&R?'R':' ',
			ptr->dbms&Y?'R':' ',
			ptr->dbms&M?'R':' ',
			ptr->dbms&S?'R':' ',
			ptr->dbms&A?'R':' ',
			ptr->dbms&_4?'R':' ');
		ptr++;
	}
    fprintf(fdDOC," **************************************************"
               "*************************\n");
	close_words(fdDOC);
}

/******************************************************************************/

static void DOCgen2()
{
    int     i, count;
    struct Keyword  *ptr = keywords;

    count = sizeof(keywords)/sizeof(struct Keyword);

	if (zflag) fdZ = open_words(ris);
	if (xflag) fdX = open_words(informix);
	if (oflag) fdO = open_words(oracle);
	if (iflag) fdI = open_words(ingres);
	if (dflag) fdD = open_words(db2);
	if (rflag) fdR = open_words(rdb);
	if (yflag) fdY = open_words(sybase);
	if (mflag) fdM = open_words(mssqlsr);
	if (sflag) fdS = open_words(sqlds);
	if (aflag) fdA = open_words(adabas);
	if (_4flag) fd4 = open_words(os400);

    for (i=0; i<count; i++) {
  		if ((ptr->dbms&Z)&&zflag) fprintf(fdZ,"%s\n",ptr->keyword);
        if ((ptr->dbms&X)&&xflag) fprintf(fdX,"%s\n",ptr->keyword);
        if ((ptr->dbms&O)&&oflag) fprintf(fdO,"%s\n",ptr->keyword);
        if ((ptr->dbms&I)&&iflag) fprintf(fdI,"%s\n",ptr->keyword);
        if ((ptr->dbms&D)&&dflag) fprintf(fdD,"%s\n",ptr->keyword);
        if ((ptr->dbms&R)&&rflag) fprintf(fdR,"%s\n",ptr->keyword);
        if ((ptr->dbms&Y)&&yflag) fprintf(fdY,"%s\n",ptr->keyword);
        if ((ptr->dbms&M)&&mflag) fprintf(fdM,"%s\n",ptr->keyword);
        if ((ptr->dbms&S)&&sflag) fprintf(fdS,"%s\n",ptr->keyword);
        if ((ptr->dbms&A)&&aflag) fprintf(fdA,"%s\n",ptr->keyword);
        if ((ptr->dbms&_4)&&_4flag) fprintf(fd4,"%s\n",ptr->keyword);
		ptr++;
	}
	if (zflag) close_words(fdZ);
	if (xflag) close_words(fdX);
	if (oflag) close_words(fdO);
	if (iflag) close_words(fdI);
	if (dflag) close_words(fdD);
	if (rflag) close_words(fdR);
	if (yflag) close_words(fdY);
	if (mflag) close_words(fdM);
	if (sflag) close_words(fdS);
	if (aflag) close_words(fdA);
	if (_4flag) close_words(fd4);
}

/******************************************************************************/
static int fnamecpy(
    char **argv,
    int argc,
    int index,
    char *filename)
{

    if (argv[index][2] == '\0') {   /* -X filename  */
        index++;
        if ((argv[index][0] != '\0')&&(argv[index][0] != '-')&&(index<argc))
            strcpy(filename,argv[index]);
        else
            index--;
    }
    else /* -Xdir  */
        strcpy(filename,&argv[index][2]);

    return(index);
}

/******************************************************************************/

static FILE *open_words(
	char *filename)
{
	FILE *f;

	if ((f = fopen(filename, "w")) == NULL) { 
		fprintf(stderr, "Open of %s for writing failed!\n", filename);
		exit(1);
	}
	
	return f;
}

/******************************************************************************/

static int close_words(
	FILE *f)
{
	int	s = 0;

	if (f == NULL) return s;
	if ((s = fclose(f)) == EOF)
		fprintf(stderr, "Close failed\n");
	return s;
}

/******************************************************************************/

static void gen_exit(
	int i)
{
	fprintf(stdout,"mkkeydoc: usage mkkeydoc [-x [file1]] [-o [file2]] [-i [file3]] [-d [file4]] [-r [file5]] [-y [file6]] [-m [file7]] [-s [file8]] [-a [file9]] [-z [file10]] [-4 [file11]] [-t [tabfile]]\n"); 
	exit(i); 
}

/******************************************************************************/
