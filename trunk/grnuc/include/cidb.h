/*
 *	 Etienne Beeker
 *
 *	macros to manage INFORMIX from CI
 *	creation : Feb 29th, 88
 */



/*---------------------------------------------------------------------
 *                              db$init() 
 *---------------------------------------------------------------------
 *
 * initialization of the DB
 * - eventually creates and opens named pipes for DB i/o
 * - does a fork on informix ( opens an external process )
 * - opens the database name if specified
   ARGUMENTS:
 	char	*db	name of the database to open
 			( optional )
   RETURN
   	0 if failed
   	1 if success

   NB: 1) 2 shell variables must be positioned

	DBPATH	to find the databases
		ex: /usr/informix:/usr/my_dir/my_db:/usr/his_dir/his_db
	INFORMIXDIR to find the executable isql
		ex: /usr/informix
	these variables can be positioned in the .profile
	of the user
	
	2) names /tmp/fifoerr,/tmp/fifoin, /tmp/fifoout 
	are reserved
 */
 
#omdef db$init( db = NULL )

	DBinit((db))

#endomdef


/*---------------------------------------------------------------------
 *                              db$close()
 *---------------------------------------------------------------------
 *
 * closes the informix session
 * i.e: - closes the opened named pipes
 	- kills the external running informix process
   ARGUMENTS:
   	none   
 */
#omdef db$close()

	DBclose()

#endomdef


/*---------------------------------------------------------------------
 *                              db$open() 
 *---------------------------------------------------------------------
 *
 * open a DB
   ARGUMENTS:
 	char	*db	name of the database to open

   RETURN
   	0 if failed
   	1 if success
   	
   NB: no close is associated with open 
       a DataBase is automatically closed when another one
       is opened or when db$close is called ( see this command )

 */
 
#omdef db$open( db )

	DBopen( db )

#endomdef


/*---------------------------------------------------------------------
 *                              db$cmd()
 *---------------------------------------------------------------------
 *
 * sends a SQL command to the DB
 * result is written in a special window or in a file
 *
 * IMPORTANT TRICK:
   ---------------
   IF INFORMIX SEEMS TO LOOP, OR NO RESPONSE IS COMING ,
   IN ANOTHER WINDOW WRITE ANYTHING
   ON "/tmp/fifoout". ( ex: echo xxx >/tmp/fifout )
   THE MECHANISM OF SYNCHRONIZATION IS WAITING FOR SOMETHING
   TO BE WRITTEN HERE
 *
 *
   ARGUMENTS:
   	char	*cmd		command
   	char	*file		name of the file to output the result
   				( optional )
 */
#omdef db$cmd( cmd,
	       file = NULL )

	DBcmd((cmd), (file))
#endomdef

/*---------------------------------------------------------------------
 *                              db$search()
 *---------------------------------------------------------------------
 *
 * get the objects satisfying a certain criteria
 *
   ARGUMENTS:
	char	*crit		 criteria 
	char	*tbl		 table name
	int	*tobj;		 objects found
				 space must be allocated by user
	short	*tosnum;		'' spaces 
				 space must be allocated by user
	int	*nbobj;		 returns nb of objects satisfying the query
   NOTA
   	the criteria is only a subset of an isql command
   	for instance:
   		crit = "WHERE population > 100000"
   		crit = "WHERE name MATCHES \"A*\""
   		crit = "HAVING clause ... "
   	the command itself is automatically completed to do
   	the selection in the table "tbl" and get
   	the result in a reserved place
 */
#omdef db$search(crit,
		tbl,
		tobj,
		tosnum	= NULL,
		nbobj	= NULL )

	DBsearch( (crit), (tbl), (tobj), (tosnum), (nbobj) )

#endomdef


/*---------------------------------------------------------------------
 *                              db$read()
 *---------------------------------------------------------------------
 * reads data attributes from an object
   ARGUMENTS
	char	*tbl			table name
	int	*obj			object; if NULL see db$write
	short	*osnum				''	space num 
	char 	*col			column name
	char	*value			points on the value returned
					if called from C: must be a string
					if called from CI, an automatic 
					conversion is performed
   NOTA
     	goes through a temporary table
     	if several db$read are done on the same object, they must
     	be grouped to spare time

   	CITMP is a reserved name for a table
 */
#omdef db$read(	tbl,
		obj	= NULL,
		osnum	= NULL,
		col,
		value )

	DBread( (tbl), (obj), (osnum), (col), (value) )

#endomdef


/*---------------------------------------------------------------------
 *                              db$write()
 *---------------------------------------------------------------------
 * writes data attributes from an object
   ARGUMENTS
	char	*tbl			table name
	int	*obj			object; if NULL updates ALL elements 
					in the DB; useful for AE for instance
	short	*osnum				''	space num 
	char 	*col			column name
	char	*value			points on the value passed
					if called from C: must be a string
					if called from CI, an automatic 
					conversion is performed

   NOTA
     	goes through a temporary table
     	if several db$write are done on the same object, they must
     	be grouped to spare time
 */

#omdef db$write(tbl,
		obj	= NULL,
		osnum	= NULL,
		col,
		value )

	DBwrite( (tbl), (obj), (osnum), (col), (value) )

#endomdef



/*---------------------------------------------------------------------
 *                              db$flush()
 *---------------------------------------------------------------------
 * to optimimized DBwrite by keeping data into a temp table
   ARGUMENTS:
	char	*tbl			table name
 */
#omdef db$flush( tbl )

	DBflush( tbl )

#endomdef


/*---------------------------------------------------------------------
 *                              db$select()
 *---------------------------------------------------------------------
 * reads data attributes from an object
 * and put them in the AE ( active entity )
   ARGUMENTS
	char	*tbl			table name
	int	obj			object 
	short	osnum				''	space num 
   NOTA
   	AE is a reserved name for a table
 */
#omdef db$select(tbl,
		obj,
		osnum	= -1 )

	DBselect( (tbl), (obj), (osnum) )

#endomdef


/*---------------------------------------------------------------------
 *                              db$attach()
 *---------------------------------------------------------------------
 * attach the objects in tobj to the active entity AE
   ARGUMENTS
	char	*tbl			table name
	int	*tobj			object table 
	short	*tosnum				''	space num 
	int	nbobj			number of objects in the tables
					( by default =  1 )
 */
#omdef db$attach(tbl,
		tobj,
		tosnum	= -1,
		nbobj   = 1 )

	DBattach( (tbl), (tobj), (tosnum), (nbobj) )

#endomdef


/*---------------------------------------------------------------------
 *                              db$detach()
 ----------------------------------------------------------------------
 * detach the objects in tobj from their links to the table tbl
 * in the DB
   ARGUMENTS
	char	*tbl			table name
	int	*tobj			object table 
	short	*tosnum				''	space num 
	int	nbobj			number of objects in the tables
					( by default =  1 )
 */
#omdef db$detach(tbl,
		tobj,
		tosnum	= -1,
		nbobj   = 1 )

	DBdetach( (tbl), (tobj), (tosnum), (nbobj) )

#endomdef
