#include <stdio.h>
#include <MEMerrordef.h>
#include <PDUerror.h>
#include <PDUextdef.h>
#include <PDUcommand.h>
#include <MEMstruct.h>
#include <PDUproto.h>


extern int PDU_command;
static char s[1024];
static long status;

/* this function sets up the format for the dynamic attributes buffer. */

int PDUcreate_dynamic_attr_buffr ( dynamic_attr_buffr )

    MEMptr *dynamic_attr_buffr;
  {

    MEMptr attr = NULL;

    _pdm_debug("In the function PDMcreate_dynamic_attr_buffr",0);
    status = MEMopen( &attr, PDM_BUFFER_SIZE );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMopen failed status ", status);
        PDMdebug(s);
        return( status );
    }

    status = MEMwrite_format( attr, "n_name", "char(20)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }    	
    status = MEMwrite_format( attr, "n_datatype", "char(20)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }    	
    status = MEMwrite_format( attr, "n_synonym", "char(40)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }
    status = MEMwrite_format( attr, "n_application", "char(3)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }
    status = MEMwrite_format( attr, "n_read", "char(1)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }    	
    status = MEMwrite_format( attr, "n_write", "char(1)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }    	
    status = MEMwrite_format( attr, "n_update", "char(1)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }    	
    status = MEMwrite_format( attr, "n_delete", "char(1)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }    	
    status = MEMwrite_format( attr, "n_null", "char(1)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }    	
    status = MEMwrite_format( attr, "n_checkin", "char(1)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }    	
    status = MEMwrite_format( attr, "n_checkout", "char(1)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }    	
    status = MEMwrite_format( attr, "n_seqno", "integer" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }
    /* NFM 3.0 - added n_attrno */
    status = MEMwrite_format( attr, "n_attrno", "integer" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }
    /* NFM 3.0 - end add */
    /* NFM 3.0 - added for n_tableno */
    status = MEMwrite_format( attr, "n_tableno", "integer" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }
    /* NFM 3.0 - end add */
    /* NFM 3.0 - changed n_listno to n_valueno */
    status = MEMwrite_format( attr, "n_valueno", "integer" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }    	
    /* NFM 3.0 - end change */
    /* NFM 3.2 - change n_adviceno to n_advice */
    status = MEMwrite_format( attr, "n_advice", "char(40)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }    	
    if (PDU_command == PDC_M_MODIFY_CATALOG)
    {
    status = MEMwrite_format( attr, "new_n_name", "char(20)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }    	
    status = MEMwrite_format( attr, "new_n_datatype", "char(15)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }    	
    status = MEMwrite_format( attr, "new_n_synonym", "char(40)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }
    status = MEMwrite_format( attr, "new_n_application", "char(3)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }
    status = MEMwrite_format( attr, "new_n_read", "char(1)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }    	
    status = MEMwrite_format( attr, "new_n_write", "char(1)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }    	
    status = MEMwrite_format( attr, "new_n_update", "char(1)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }    	
    status = MEMwrite_format( attr, "new_n_delete", "char(1)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }    	
    status = MEMwrite_format( attr, "new_n_null", "char(1)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }    	
    status = MEMwrite_format( attr, "new_n_checkin", "char(1)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }    	
    status = MEMwrite_format( attr, "new_n_checkout", "char(1)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }    	
    status = MEMwrite_format( attr, "new_n_seqno", "integer" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }
    /* NFM 3.0 - added n_attrno */
    status = MEMwrite_format( attr, "new_n_attrno", "integer" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }
    /* NFM 3.0 - end add */
    /* NFM 3.0 - added for n_tableno */
    status = MEMwrite_format( attr, "new_n_tableno", "integer" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }
    /* NFM 3.0 - end add */
    /* NFM 3.0 - changed n_listno to n_valueno */
    status = MEMwrite_format( attr, "new_n_valueno", "integer" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }    	
    /* NFM 3.0 - end change */
    /* NFM 3.2 - changed n_adviceno to n_advice*/
    status = MEMwrite_format( attr, "new_n_advice", "char(40)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }    	
    }
    /* NFM 3.0 - end add */
    *dynamic_attr_buffr = attr;
    return(PDM_S_SUCCESS );
}

int PDUcreate_new_dynamic_attr_buffr ( dynamic_attr_buffr )

    MEMptr *dynamic_attr_buffr;
  {

    MEMptr attr = NULL;

    _pdm_debug("In the function PDMcreate_new_dynamic_attr_buffr",0);
    status = MEMopen( &attr, PDM_BUFFER_SIZE );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMopen failed status ", status);
        PDMdebug(s);
        return( status );
    }

    status = MEMwrite_format( attr, "n_attrno", "integer" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }    	
    status = MEMwrite_format( attr, "n_name", "char(20)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }    	
    status = MEMwrite_format( attr, "n_datatype", "char(15)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }    	
    status = MEMwrite_format( attr, "n_synonym", "char(40)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }
    status = MEMwrite_format( attr, "n_write", "char(1)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }    	
    status = MEMwrite_format( attr, "n_null", "char(1)" );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMwrite_format failed status ", status);
        PDMdebug(s);
        status = PDM_E_WRITE_FORMAT;
        return( status );
    }    	
    /* NFM 3.0 - end add */
    *dynamic_attr_buffr = attr;
    return(PDM_S_SUCCESS );
}
