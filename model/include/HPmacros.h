
/*
 *  useful macros
 */
 
#define return_bad(status) if(!((status)&1))return(status)
#define if_bad(status)	   if(!((status)&1))

/*---FILE_WRITE--------------------------------------------------------*/

#define FILE_WRITE( x1, x2, x3, x4 )		\
						\
	{					\
	int	status;				\
						\
	status = fwrite( x1, x2, x3, x4 );	\
	if( status <= 0 )			\
		{				\
		status = HP_F_RasFlWrtErr;	\
		HPmessage( status, NULL, 1 );	\
		exit( 0 );			\
		}				\
	}
	

