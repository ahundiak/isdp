#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "UTIerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

long  NFMarchive_files( server, env, user, passwd, sa_no, label,
                        file_list, msg_buffer )
    char   *server;
    char   *env;
    char   *user;
    char   *passwd;
    char   *sa_no;
    char   *label;
    MEMptr file_list;
    MEMptr *msg_buffer;
{
    long   status;

    static char *fname = "NFMarchive_files";

    _NFMdebug(( fname, "Server  <%s>\n", server ));
    _NFMdebug(( fname, "Env     <%s>\n", env ));
    _NFMdebug(( fname, "User    <%s>\n", user ));
    _NFMdebug(( fname, "Passwd  <%s>\n", passwd ));
    _NFMdebug(( fname, "SA Num  <%s>\n", sa_no ));
    _NFMdebug(( fname, "Label   <%s>\n", label ));

    status = UTIarchive_files( server, env, user, passwd, sa_no, label,
				file_list, msg_buffer );
    if( status != UTI_S_SUCCESS )
    {
	_NFMdebug(( fname, "UTIarchive_files <0x%.8x>\n", status ));
	return( status );
    }

    _NFMdebug(( fname, "%s\n", "Returning Success ..." ));

    return( NFM_S_SUCCESS );
}

long  NFMbackup_files( server, env, user, passwd, sa_no, label,
                        file_list, msg_buffer )
    char   *server;
    char   *env;
    char   *user;
    char   *passwd;
    char   *sa_no;
    char   *label;
    MEMptr file_list;
    MEMptr *msg_buffer;
{
    long   status;

    static char *fname = "NFMbackup_files";

    _NFMdebug(( fname, "Server  <%s>\n", server ));
    _NFMdebug(( fname, "Env     <%s>\n", env ));
    _NFMdebug(( fname, "User    <%s>\n", user ));
    _NFMdebug(( fname, "Passwd  <%s>\n", passwd ));
    _NFMdebug(( fname, "SA Num  <%s>\n", sa_no ));
    _NFMdebug(( fname, "Label   <%s>\n", label ));

    status = UTIbackup_files( server, env, user, passwd, sa_no, label,
				file_list, msg_buffer );
    if( status != UTI_S_SUCCESS )
    {
	_NFMdebug(( fname, "UTIbackup_files <0x%.8x>\n", status ));
	return( status );
    }

    _NFMdebug(( fname, "%s\n", "Returning Success ..." ));

    return( NFM_S_SUCCESS );
}

long  NFMrestore_files( server, env, user, passwd, file_list, msg_buffer )
    char   *server;
    char   *env;
    char   *user;
    char   *passwd;
    MEMptr file_list;
    MEMptr *msg_buffer;
{
    long   status;

    static char *fname = "NFMrestore_files";

    _NFMdebug(( fname, "Server  <%s>\n", server ));
    _NFMdebug(( fname, "Env     <%s>\n", env ));
    _NFMdebug(( fname, "User    <%s>\n", user ));
    _NFMdebug(( fname, "Passwd  <%s>\n", passwd ));

    status = UTIrestore_files( server, env, user, passwd, file_list, 
				msg_buffer );
    if( status != UTI_S_SUCCESS )
    {
	_NFMdebug(( fname, "UTIrestore_files <0x%.8x>\n", status ));
	return( status );
    }

    _NFMdebug(( fname, "%s\n", "Returning Success ..." ));

    return( NFM_S_SUCCESS );
}

long  NFMdelete_files( server, env, user, passwd, file_list )
    char   *server;
    char   *env;
    char   *user;
    char   *passwd;
    MEMptr file_list;
{
    long   status;

    static char *fname = "NFMdelete_files";

    _NFMdebug(( fname, "Server  <%s>\n", server ));
    _NFMdebug(( fname, "Env     <%s>\n", env ));
    _NFMdebug(( fname, "User    <%s>\n", user ));
    _NFMdebug(( fname, "Passwd  <%s>\n", passwd ));

    status = UTIdelete_files( server, env, user, passwd, file_list );
    if( status != UTI_S_SUCCESS )
    {
	_NFMdebug(( fname, "UTIdelete_files <0x%.8x>\n", status ));
	return( status );
    }

    _NFMdebug(( fname, "%s\n", "Returning Success ..." ));

    return( NFM_S_SUCCESS );
}

long  NFMdelete_label(label)
    MEMptr   label;
{
    long   status;

    static char *fname = "NFMdelete_label";

    _NFMdebug(( fname, "Label   <%s>\n", label ));

    status = UTIdelete_label(label);
    if( status != UTI_S_SUCCESS )
    {
	_NFMdebug(( fname, "UTIdelete_label Failed <0x%.8x>\n", status ));
	return( status );
    }

    _NFMdebug(( fname, "%s\n", "Returning Success ..." ));

    return( NFM_S_SUCCESS );
}
