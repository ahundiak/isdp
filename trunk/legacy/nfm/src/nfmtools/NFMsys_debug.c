#include "machine.h"
#include <stdio.h>
#include <string.h>
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "NFMSextern.h"
#include "NFMstruct.h"

#ifndef NFM_DEBUG_SUBSYSTEMS
#define NFM_DEBUG_SUBSYSTEMS 15
#endif

extern   struct NFMglobal_st NFMglobal;

long _NFMall_debug ( toggles, files )

int  toggles[NFM_DEBUG_SUBSYSTEMS];
                 /* i - array of subsystem debugs on (1) or off (0) */
char files[NFM_DEBUG_SUBSYSTEMS][NFM_DEBUG_FILE_SIZE];
                 /* i - array of subsystem debug filenames */
{
    static char *fname = "_NFMall_debug";

    _NFMdebug(( fname, "%s\n", "Entering ..." ));

/*  NFI  */
    _NFMdebug_st.NFIdebug_on = toggles[0];
    if( toggles[0] == 1 )
        strncpy( _NFMdebug_st.NFIdebug_file, files[0],
             sizeof( _NFMdebug_st.NFIdebug_file ) - 1 );

/*  NFMR  */
    _NFMdebug_st.NFMRdebug_on = toggles[2];
    if( toggles[2] == 1 )
        strncpy( _NFMdebug_st.NFMRdebug_file, files[2],
             sizeof( _NFMdebug_st.NFMRdebug_file ) - 1 );

/*  NETC  */
    _NFMdebug_st.NETCdebug_on = toggles[3];
    if( toggles[3] == 1 )
        strncpy( _NFMdebug_st.NETCdebug_file, files[3],
             sizeof( _NFMdebug_st.NETCdebug_file ) - 1 );

/*  MEMC  */
    _NFMdebug_st.MEMdebug_on = toggles[4];
    if( toggles[4] == 1 )
        strncpy( _NFMdebug_st.MEMdebug_file, files[4],
             sizeof( _NFMdebug_st.MEMdebug_file ) - 1 );
    else if( toggles[11] == 1 )
    {
        _NFMdebug_st.MEMdebug_on = toggles[11];
        strncpy( _NFMdebug_st.MEMdebug_file, files[11],
             sizeof( _NFMdebug_st.MEMdebug_file ) - 1 );
    }

/*  ERRC  */
    _NFMdebug_st.ERRdebug_on = toggles[5];
    if( toggles[5] == 1 )
        strncpy( _NFMdebug_st.ERRdebug_file, files[5],
             sizeof( _NFMdebug_st.ERRdebug_file ) - 1 );
    else if (toggles[14] == 1 )
    {
        _NFMdebug_st.ERRdebug_on = toggles[14];
        strncpy( _NFMdebug_st.ERRdebug_file,
            files[14], NFM_DEBUG_FILE_SIZE - 1);
    }

/*  NETS  */
    _NFMdebug_st.NETSdebug_on = toggles[6];
    if( toggles[6] == 1 )
        strncpy( _NFMdebug_st.NETSdebug_file, files[6],
             sizeof( _NFMdebug_st.NETSdebug_file ) - 1 );

/*  NFMS  */
    _NFMdebug_st.NFMSdebug_on = toggles[7];
    if( toggles[7] == 1 )
        strncpy( _NFMdebug_st.NFMSdebug_file, files[7],
             sizeof( _NFMdebug_st.NFMSdebug_file ) - 1 );

/*  NFM  */
    _NFMdebug_st.NFMdebug_on = toggles[8];
    if( toggles[8] == 1 )
        strncpy( _NFMdebug_st.NFMdebug_file, files[8],
             sizeof( _NFMdebug_st.NFMdebug_file ) - 1 );

/*  SQL  */
    _NFMdebug_st.SQLdebug_on = toggles[9];
    if( toggles[9] == 1 )
        strncpy( _NFMdebug_st.SQLdebug_file, files[9],
             sizeof( _NFMdebug_st.SQLdebug_file ) - 1 );

/*  MEMS  */
    _NFMdebug_st.MEMdebug_on = toggles[11];
    if( toggles[11] == 1 )
        strncpy( _NFMdebug_st.MEMdebug_file, files[11],
             sizeof( _NFMdebug_st.MEMdebug_file ) - 1 );

/*  UTI  */
    _NFMdebug_st.UTIdebug_on = toggles[12];
    if( toggles[12] == 1 )
        strncpy( _NFMdebug_st.UTIdebug_file, files[12],
             sizeof( _NFMdebug_st.UTIdebug_file ) - 1 );

/*  ERR  */
    _NFMdebug_st.ERRdebug_on = toggles[14];
    if( toggles[14] == 1 )
        strncpy( _NFMdebug_st.ERRdebug_file, files[14],
             sizeof( _NFMdebug_st.ERRdebug_file ) - 1 );

_NFMdebug(( fname, "%s\n", "Exiting ..."));

return (NFM_S_SUCCESS);
}

long _NFMtranslate_dbg_file(dbg_file,input,pid)
	char *dbg_file, *input;
	int pid;
{
	char *fname="_NFMtranslate_dbg_file";
	char *ptr, *ptr2;
	long i;
        char tmp[15],tmp2[15];
	
	if(dbg_file == NULL)
	{
		_NFMdebug((fname,"dbg_file variable is NULL\n"));
		return(NFM_E_FAILURE);
	}
	if(input == NULL || *input == '\0')
	{
		_NFMdebug((fname,"input variable is NULL\n"));
		sprintf(dbg_file,"/usr/tmp/nfmdbg.%d",pid);
		_NFMdebug((fname,"dbg_file is <%s>\n",dbg_file));
		return(NFM_S_SUCCESS);
	}

	_NFMdebug((fname,"Entry: dbg_file <%lp> : input <%s> : pid <%d>\n",
dbg_file,input,pid));
	i = strlen(input);
	if ( input[i-1] != '$')
	{
		if(input[i-1] != '/')
			strcpy(dbg_file,input);
		else
			sprintf(dbg_file,"%snfmdbg.%d",input,pid);
		_NFMdebug((fname,"Input has no $:dbg_file <%s>: NFM_S_SUCCESS\n",dbg_file));
		return(NFM_S_SUCCESS);
	}

	ptr = strrchr(input,'/');
	if(ptr != NULL)
	{
		strncpy(dbg_file,input, (ptr - input));
		dbg_file[ptr-input] = '\0';
		strcat(dbg_file,"/");
		ptr++;
	}
	else
		ptr= input;

	sprintf(tmp,"%d",pid);
	i=strlen(ptr);
	if(i > 0 )
	{
		ptr2 = ptr + i - 1;
		while ( ptr2 > ptr && *ptr2=='$') 
		{
			*ptr2 = '\0';
			ptr2--;
		}
		i=14 - strlen(tmp);
		strncpy(tmp2,ptr,i);
		tmp2[i]= '\0';
	}
	else
	{
		i=14 - strlen(tmp);
		strncpy(tmp2,"nfmdbg.",i);
		tmp2[i]= '\0';
	}
	
	strcat(tmp2,tmp);
	strcat(dbg_file,tmp2);
	
	_NFMdebug((fname,"NFM_S_SUCCESS: debug file name is <%s>\n",dbg_file));
	return(NFM_S_SUCCESS);
	
}
