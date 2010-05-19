/* $Id: zapusrdb.c,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdreports/source/etc / zapusrdb.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: zapusrdb.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:12  cvs
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
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/* *******************************************************************************
   Doc : zapusrdb.c
   
   Abstract : This program patches database user name and database name of given
              reports executable with the given database user name and database
              name.
              
   Notes :    The length of the new database user name should not be longer than 
	      old database user name. The length of database name can not be
	      more than 10 chars.
	      
   History :
   
   12 Jul 1993	Raju	2.2	Creation

   ****************************************************************************/


#include <stdio.h>
#include <fcntl.h>

#define VDS_MAX_DB	10
#define VDS_MAX_USR	8

main ( int argc, char *argv[] )
{
	int fd, c;
	long pos = 0;
	int i, stat;
	char olddb [VDS_MAX_DB+1], olddbfromreport [VDS_MAX_DB+1],
	     newdb [VDS_MAX_DB+1], oldusr [VDS_MAX_USR+3], newusr[VDS_MAX_USR+3];
	char	GeName[81];
        long tmp;
        int olddblen, newdblen, oldusrlen, newusrlen, len_diff;
        int usr_zapped = 0, db_zapped = 0, same_usr;
        
/* check input */ 
        if ( argc != 6 ) { printf("Invalid no. of arguments\n"); exit(1); }
        oldusrlen = strlen(argv[2]);
        newusrlen = strlen(argv[3]);
        if ( oldusrlen > VDS_MAX_USR )
        { fprintf(stderr,"ERROR : Old user name is longer than allowed[%d]\n", VDS_MAX_USR);
          exit(1);
	}
        if ( newusrlen > oldusrlen )
        { fprintf(stderr,"ERROR : New user name is longer than old user name\n");
          exit(1);
	}
        len_diff = oldusrlen - newusrlen;

/*   preprocessing */
	
	same_usr = 0;
	if (!strcmp(argv[2],argv[3]))  same_usr = 1;
/* add " on either side of database user name */
        oldusr[0] = '\0';
        strcat( oldusr, "\"");
        strcat( oldusr, argv[2] );
        strcat( oldusr, "\"");
	oldusrlen = strlen(oldusr);


/* suffix NULL chars to new database user name if it is shorter than old data
   base user name and add " on either side. eg. \0\0"admin" */
	memset(newusr, '\0', oldusrlen+1);
        newusr[len_diff]='"';
        for(i=0; i<strlen(argv[3]); i++)
         newusr[i+len_diff+1] = argv[3][i];
        newusr[newusrlen+len_diff+1] = '"';


	if (!strcmp(argv[4],argv[5]))
	    db_zapped = 1;
        strcpy( olddb, argv[4] );
	olddblen = strlen(olddb);

	strcpy ( newdb, argv[5]);
	newdblen = strlen(newdb);

        if ( same_usr && db_zapped )
        	exit(0);
        if ( olddblen > VDS_MAX_DB || newdblen > VDS_MAX_DB )
        { fprintf(stderr,"ERROR : Length of old(new) database name exceeds %d\n", VDS_MAX_DB);
          exit(1);
	}

	strcpy (GeName, argv[1]);
	if ((fd = open (GeName, O_RDWR, 0)) == -1)
	 {
	   printf ("Error Opening File\n");
	   exit (1);
	 }

        
/* look for .4gl */
/* It will probably faster to look in the aouthdr and use the start of
   .data section to start the search */
   
SEARCH :
 tmp = lseek (fd, pos, 0); /* seek to pos */
 if ( tmp != pos ) { printf("Error while seeking position in file\n"); exit(1); }
 
	  while ((stat = read (fd, &c, 1)) != 0)
	   { 
	       ++pos;

               if ( db_zapped ) goto ZAP_USER;
               	       
    	       if (c == '.') /* "." */
		{ /* . */
		 stat = read (fd, &c, 1);
 	         if (stat <= 0) goto wrap_up;
		 ++pos;
                 if (c  == '4') /* "4" */
	          { /* 4 */
		   stat = read (fd, &c, 1);
  	           if (stat <= 0) goto wrap_up;
		   ++pos;
                   if (c  == 'g') /* g */
		    { /* g */
  		     stat = read (fd, &c, 1);
		     ++pos;
	             if (stat <= 0) goto wrap_up;
                     if (c  == 'l') /* l */
                      { /* l */
		       stat = read (fd, &c, 1);
	               if (stat <= 0) goto wrap_up;
		       ++pos;
		       while (c != olddb [0])
                        {
			 stat = read (fd, &c, 1);
	                 if (stat <= 0) goto wrap_up;
			 pos++;
		        }
		       olddbfromreport[0] = c;
  		       for (i = 1; i < olddblen ; i++)
		       {
  		        stat = read (fd, &c, 1);
	                if (stat <= 0) goto wrap_up; 
			if (c != olddb [i]) goto SEARCH;
			olddbfromreport [i] = c; /* for debugging */
		       }
		       olddbfromreport [olddblen] = '\0';
		       --pos;
		       lseek (fd, pos, 0); /* seek to dbname) */
		       
		       /* write dbname first and then null chars */
		       stat = write (fd, newdb, newdblen);
	               if (stat < newdblen ) goto wrap_up1;
		       for (i=0; i<(VDS_MAX_DB-newdblen); i++)
		       { stat = write(fd, "\0", 1);
		         if ( stat != 1) goto wrap_up1;
	               }
		       db_zapped = 1;
                       pos += VDS_MAX_DB;
		       goto SEARCH;
		       
                      } /* l */
                    } /* g */
		  } /* 4 */
		} /* . */		 

ZAP_USER:
	     if( same_usr ) continue;
	     
             if( c == oldusr[0] )
	     {  for (i = 1; i < oldusrlen ; i++)
	        {
  	          stat = read (fd, &c, 1);
	          if (stat <= 0) goto wrap_up; 
	          if (c != oldusr [i]) goto SEARCH;
                }
		
		pos--;
		lseek (fd, pos, 0);
		
	        stat = write (fd, newusr, oldusrlen);
	        if (stat < oldusrlen ) goto wrap_up1;
	        usr_zapped = 1;
	        pos += olddblen;
	     }

           } /* while */

	  close( fd );
	  if ( !db_zapped )
          {    printf("Could not find old database name\n");
               exit(1);
          }
          exit(0);
     

wrap_up:
   fprintf (stderr,"Error reading File\n"); 
   close ( fd );
   exit (1);

wrap_up1:
   fprintf (stderr,"Error writing File\n"); 
   close ( fd );
   exit (1);


}
