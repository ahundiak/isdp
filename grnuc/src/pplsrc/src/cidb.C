/*
 *	 Etienne Beeker
 *
 *	functions managing the DataBAse calls
 *
 *	creation : Feb 29th, 88
 */
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <exmacros.h>

/* names of the named pipes used here */
#define FIFOIN	"/tmp/fifoin"
#define FIFOOUT	"/tmp/fifoout"
#define FIFOERR	"/tmp/fifoerr"


FILE	*fifoin;	/* fifo to pass commands to informix */
FILE	*fifoout;	/* fifo to get results from informix */
int 	_fifoout;	/* index of the FILE */
FILE	*fifoerr;	/* fifo to get results from informix on stderr */
int 	_fifoerr;	/* index of the FILE */

int	isql_pid = 0;	/* process_id of the running isql */
int	AE_filled = 0;	/* to know if the active entity has been filled */

char	sqlcmd[256];	/* current sql command */

DBopen(dbname)
char *dbname;
/*
 * open the DB
 */
{
	if( dbname == NULL )
		return 1;

	sprintf(sqlcmd, "DATABASE %s", dbname );
	sendsqlcmd(1);

	/* must scan fifoerr to see if no errors occured */
	return 1;
}


DBinit(dbname)
char *dbname;
/*
 * initialization of the DB
 * - eventually creates and opens named pipes for DB i/o
 * - call isql with the good DB
 */
{
	int 	rc;
	char	isql[256];	/* where informix is */
	char	ixcall[256];
	char 	*getenv();

#ifdef DEBUG
printf("entering DBinit\n");
fflush(stdout);
#endif
	if( isql_pid ){
		/* isql is already running */
		return DBopen(dbname);
	}

	/* creates named pipe for i/o of isql */
	if( mknod( FIFOIN, 0010666, 0 ) == -1 ){
		unlink(FIFOIN);
		if( mknod( FIFOIN, 0010666, 0 ) == -1 ){
			erreur("named pipe FIFOIN creation error");
			return 0;
		}
	}
	chmod(FIFOIN, 0010666);

	if( mknod( FIFOOUT, 0010666, 0 ) == -1 ){
		unlink(FIFOOUT);
		if( mknod( FIFOOUT, 0010666, 0 ) == -1 ){
			erreur("named pipe FIFOOUT creation error");
			return 0;
		}
	}
	chmod(FIFOOUT, 0010666);

	if( mknod( FIFOERR, 0010666, 0 ) == -1 ){
		unlink(FIFOERR);
		if( mknod( FIFOERR, 0010666, 0 ) == -1 ){
			erreur("named pipe FIFOERR creation error");
			return 0;
		}
	}
	chmod(FIFOERR, 0010666);

	/* open informix session */
	sprintf(isql,"%s/bin/isql", getenv("INFORMIXDIR"));

#ifdef DEBUG
printf("%s\n",isql);
fflush(stdout);
#endif

	if( access( isql, 01 | 04 ) == -1 ) {
		erreur( "cannot access informix ( maybe bad INFORMIXDIR shell variable)" ) ;
		return 0;
	}
	sprintf( ixcall, "%s - - <%s >%s 2>%s", 
			isql,FIFOIN, FIFOOUT, FIFOERR  );

	if( ex$is_driver_exist() ) {
		char *arg[3];
		arg[0] = "/bin/sh";
		arg[1] = "-c";
		arg[2] = ixcall;
		rc = ex$fork(
		      num_entry = 3	,
	              argu	= arg   ,
	              childpid  = &isql_pid,
	              wait_flag = 0	) ;
	} else {
/*		erreur( "WARNING: driver not present, loading informix can cause swap overflow");
 */
		if( (isql_pid = fork()) == 0 ){
			execl("/bin/sh","sh","-c", ixcall, 0 );
			/* must never come here */
			erreur("error in forking informix");
		}
	}

#ifdef DEBUG
printf("after fork\n");
fflush(stdout);
#endif

	/* open the named pipes */
	if(( _fifoout = open(FIFOOUT, O_RDONLY | O_NDELAY)) == -1) {
		erreur("named pipe FIFOOUT open error");
		return 0;
	}
	if(( fifoout = (FILE *)fdopen(_fifoout, "r")) == NULL ){
		erreur("named pipe FIFOOUT open error");
		return 0;
	}

	if(( _fifoerr = open(FIFOERR, O_RDONLY | O_NDELAY)) == -1) {
		erreur("named pipe FIFOERR open error");
		return 0;
	}
	if(( fifoerr = (FILE *)fdopen(_fifoerr, "r")) == NULL ){
		erreur("named pipe FIFOERR open error");
		return 0;
	}

	if(( fifoin = fopen(FIFOIN,"w")) == NULL ){
		erreur("named pipe FIFOIN open error");
		return 0;
	}

	/* open the database now */
	return DBopen(dbname);
}

DBclose()
/*
 * closes the DB
 */
{
	/* kills the running informix */
	if( isql_pid ){
		kill( isql_pid, SIGTERM );
		isql_pid = 0;
	}

	/* closes and deletes the named pipes */
	if( fifoin != NULL ) 
		fclose(fifoin);
	if( fifoout != NULL ) { 
		fclose(fifoout); 
		close (_fifoout);
	}
	if( fifoerr != NULL ) { 
		fclose(fifoerr); 
		close (_fifoerr);
	}
	unlink(FIFOIN);
	unlink(FIFOOUT);
	unlink(FIFOERR);

	return 1;
}

DBcmd(dbcmd, fout)
char *dbcmd;
char *fout;
/*
 * sends a SQL command to the DB
 * result is written in a special window or in a file except if
 * fout is specified ( for result output )
 */
{
	char	s[128];		/* tmp */
	FILE	*fdout;		/* file descriptor for the output file */
	int	nl = 0;		/* line counter for the window */

	if( fout != NULL ){
		if((fdout = fopen(fout, "w")) == NULL){
			sprintf(s,"DBcmd: cannot open %s",fout);
			erreur(s);
			return 0;
		}
	}

	strcpy(sqlcmd, dbcmd );

	/* completely empirical: if query is "INFO"
	   result is put on stdout ( so fifoout ) but no flush is
	   performed. So we appen to the command a empty
	   request that only generates a small syntax error
	   that we try to swallow after */
	sscanf(dbcmd,"%s",s);
	if( !strcmp(s, "info") || !strcmp(s, "INFO")  )
		strcat(sqlcmd,";\n");
		
	/* sends the query */
	sendsqlcmd(1);

	/* now the output is done on the special window */
	while( fgets(s, 128, fifoout) ){
		if( nl == 0 ){
			char s1[32];
			/* eliminates the first empty lines */
			if( !strcmp( s, "\n" ) )
				continue;

			/* eliminates error messages, [empirical] */
			/* informix is rather strange in flushing its
			   output messages, so sometimes one is still here */
			sscanf(s,"%s", s1);
			if( !strcmp( s1, "Error" ) ){
				/* eliminates the next line as well */
				fgets(s, 128, fifoout);
				continue;
			}

			if( fout == NULL ){
				/* creates window only if we have
				   consistent results to write */
				CIcreate_wind("     CI - INFORMIX");
			}
		}
		if( fout != NULL ){
			fprintf(fdout,"%s",s);
			nl++;
		} else {
			if( !CIwrite_wind(nl++, s ) ){
				empty_fifos();
				return 1;
			}
		}
	}
	if( fout != NULL ){
		fprintf(fdout,"\n");
		fclose(fdout);
	} else {
		if( nl != 0 )
			CIescape_win();
	}

	return 1;
}


#argsused
DBsearch(criteria, tblname, tobj, tosnum, nbobj )
char	*criteria, 		
	*tblname;	/* table name */
int	*tobj;		/* points on result */
short	*tosnum;	/*	''	    */
int	*nbobj;		/* nb of objects satisfying the query */
/*
 * get the objects satisfying a certain criteria
 */
{
	int i;
	char stmp[32];
	
	/* constructs and sends the query */
/*	sprintf(sqlcmd, 
	"OUTPUT TO \"%s\" WITHOUT HEADINGS SELECT objid FROM %s %s",
		FIFOOUT, tblname, criteria );
 */
	sprintf(sqlcmd, 
		"SELECT objid FROM %s %s", tblname, criteria );
	sendsqlcmd(1);


	do {
		i = fscanf(fifoout,"%s", stmp);
	} while( strcmp("objid", stmp) && i > 0 ); 
#ifdef DEBUG
printf("DBsearch: objid must be %s\n",stmp);
fflush(stdout);
#endif
	if( strcmp("objid", stmp) || i <= 0 ){
		erreur("DBsearch error");
		return 0;
	}

	/* read and put the result into tobj */
	i = 0;
	while( fscanf(fifoout,"%d", tobj + i) > 0 )
		i++;

	if( nbobj != NULL )
		*nbobj = i;

	return 1;
}


#argsused
DBread(tblname, obj, osnum, colname, value)
char	*tblname;		/* table name */
int	*obj;			/* object */
short	*osnum;			/*	''	space num    */
char 	*colname;		/* column name */
char	*value;			/* to get the value we want */
/*
 * reads data attributes from an object
 * goes through a temp table
 */
{
	char stmp[32];
	int i;
	
	if( obj != NULL ){
		fillCITMP(obj, tblname, 0);

		/* get the wanted attribute from CITMP */
/*		sprintf(sqlcmd, 
		   "OUTPUT TO \"%s\" WITHOUT HEADINGS SELECT %s FROM CITMP",
			FIFOOUT, colname );
 */
		sprintf(sqlcmd, "SELECT %s FROM CITMP", colname );
	} else {
/*
		sprintf(sqlcmd, 
		   "OUTPUT TO \"%s\" WITHOUT HEADINGS SELECT %s FROM %s",
			FIFOOUT, colname, tblname );
*/
		sprintf(sqlcmd, "SELECT %s FROM %s", colname, tblname );
	}
	sendsqlcmd(1);

	do {
		i = fscanf(fifoout,"%s", stmp);
	} while( strcmp(colname, stmp) && i > 0 ); 
#ifdef DEBUG
printf("DBread: %s must be %s\n",colname, stmp);
fflush(stdout);
#endif
	if( strcmp(colname, stmp) || i <= 0 ){
		erreur("DBread error");
		return 0;
	}

	/* read and put the result into value */
	if( fscanf(fifoout,"%s", value) <= 0 )
		return 0;

	/* must empty the content as soon as 1 has been read */
	fflush(fifoout);

	return 1;
}

#argsused
DBwrite(tblname, obj, osnum, colname, value)
char	*tblname;		/* table name */
int	*obj;			/* object */
short	*osnum;			/*	''	space num    */
char 	*colname;		/* column name */
char	*value;			/* to get the value we want */
/*
 * writes data attributes from an object
 */
{
	char objsel[32];

	if( obj != NULL )
		sprintf(objsel," WHERE objid = %d", *obj );
	else
		/* updates all records in the DB, useful for AE for instance */
		strcpy( objsel, ""); 

	sprintf(sqlcmd, "UPDATE %s SET %s = \"%s\"%s",
			tblname, colname, value, objsel );
	sendsqlcmd(1);

	fillCITMP(obj, tblname, 1);

	return 1;
}

#argsused
DBflush(tblname)
char *tblname;
/*
 * to optimimized DBwrite by keeping data into a temp variable
 * not yet active
 */
{
	return 1;
}

fillCITMP(obj, tblname, clear)
int	*obj;			/* object */
char	*tblname;		/* table name */
int	clear;	/* 0: sent by DBread
		 * 1: sent by DBwrite. must clear cur_obj and cur_tbl
		 *     if it has ben updated
		 */
{
	static int	cur_obj = -1;	/* current object */
	static char	*cur_tbl = NULL;

	/* if first time we read this object, write the tmp table */
	if(( cur_obj != *obj || strcmp( cur_tbl, tblname)) && clear == 0 ){
		/* first selete table CITMP if already exists */
		sprintf(sqlcmd,"DROP TABLE CITMP");
		sendsqlcmd(1);

		sprintf(sqlcmd,
		     "SELECT * FROM %s WHERE objid = %d INTO TEMP CITMP",
		     tblname, *obj );
		sendsqlcmd(1);

		cur_obj = *obj;
		cur_tbl = tblname;
	} else if( clear == 1 ){
		/* set to default values */
		cur_obj = -1;
		cur_tbl = NULL;
	}
}


#argsused
DBselect(tblname, obj, osnum )
char	*tblname;		/* table name */
int	obj;			/* object */
short	osnum;			/*	''	space num    */
/*
 * reads data attributes from an object
 * and put them in the AE ( active entity )
 */
{
	/* first selete table AE if already exists */
	sprintf(sqlcmd, "DROP TABLE AE");
	sendsqlcmd(1);

	sprintf(sqlcmd, "SELECT * FROM %s WHERE objid = %d INTO TEMP AE",
			tblname, obj );
	sendsqlcmd(1);

	AE_filled = 1;
	return 1;
}

#argsused
DBattach(tblname, tobj, tosnum, nbobj )
char	*tblname;		/* table name */
int	*tobj;			/* object id's */
short	*tosnum;		/*	''	space num    */
int	nbobj;			/* number of objects */
/*
 * attach the objects in tobj to the active entity AE
 */
{
	int i;

	if( !AE_filled ){
		erreur("DB: active entity not filled, cnnot attch object");
		return 0;
	}
	
	for(i=0; i<nbobj; i++){
		sprintf(sqlcmd, "UPDATE AE SET objid = %d;\n\
				 INSERT INTO %s SELECT * FROM AE",
				*(tobj+i), tblname );
		sendsqlcmd(1);
	}
	return 1;
}

#argsused
DBdetach(tblname, tobj, tosnum, nbobj )
char	*tblname;		/* table name */
int	*tobj;			/* object id's */
short	*tosnum;		/*	''	space num    */
int	nbobj;			/* number of objects */
/*
 * detach the objects in tobj from table tblname
 */
{
	int i;
	
	for(i=0; i<nbobj; i++){
		sprintf(sqlcmd, "DELETE FROM %s WHERE objid = %d",
						tblname, *(tobj+i) );
		sendsqlcmd(1);
	}
	return 1;
}

sendsqlcmd(flag)
int flag;
/*
 * writes the command to fifoin
 * flag: 0: no synchro
 	 1: synchro
 */
{
	char c;

	empty_fifos();

#ifdef DEBUG
printf("SQL:[%s",sqlcmd);
fflush(stdout);
#endif
	fprintf( fifoin,"%s;\n",sqlcmd);
	fflush(fifoin);

#ifdef DEBUG
printf(";]\n");
fflush(stdout);
#endif

	/* waits for the command to be executed */
	if( flag )
		DBsynchro();

#ifdef DEBUG
	fprintf(stderr,"FIFOERR: ");
	fflush(stderr);
#endif
	while( ( c = fgetc(fifoerr)) != -1 )
		putc(c, stderr);
}

DBsynchro()
/*
 * synchro, waits for a character to be output on fifoerr or fifoout
 * a bit dirty for process synchro, but it works
 *
 * a clean method would be to synchronize the processes with
 * semaphores, or to put timeouts, etc...
 */
{ 
	char c;
	int i;
	
	for(i=0;;i++){
		/* scan successively fifoout and  fifoerr */
		if( ( c = fgetc(fifoout)) != -1 ){
#ifdef DEBUG
printf("je suis synchro sur fifoout ( c=%c)\n",c);
fflush(stdout);
#endif
			ungetc(c, fifoout);
			break;
		}
		if( ( c = fgetc(fifoerr)) != -1 ){
			if( c == '\n')
				continue;	/* empirical */
#ifdef DEBUG
printf("je suis synchro sur fifoerr (c=%c)\n",c);
fflush(stdout);
#endif
			ungetc(c, fifoerr);
			break;
		}
		/* not burden the cpu */
/*		if( i%100 == 0 ){
#ifdef DEBUG
printf("synchro: 100 tours pour rien\n");
fflush(stdout);
#endif
			sleep(1);
		}
*/	}
	return 1;
}

empty_fifos()
/* 
 * empty the pipes for synchro
 */
{
	fflush(fifoerr);
	fflush(fifoout);
	/* redundant but it seems as if it was not working from time to
	   time */
	while( fgetc(fifoerr) != -1 )
		;
	while( fgetc(fifoout) != -1 )
		;
}
