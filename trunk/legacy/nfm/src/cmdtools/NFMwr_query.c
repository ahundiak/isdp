#include "machine.h"
#include <stdio.h> 
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "NFMapi.h"
#include "DEBUG.h"

long NFMwrite_query_file (report_name, query_type, query_info)
   char     *report_name;
   short    query_type;
   struct NFMquery_info query_info;

{
long    status;
FILE    *fopen (), *out_file;
static  char *fname = "NFMwrite_query_file";

/* This code can be more intelligent by only writing the fields that
   correspond to the type of query. I'm not sure we want to do this now. */

out_file = fopen (report_name, "w");
if (! out_file)
    {
    status = NFM_E_FOPEN_QUERY_FILE; 
    _NFMdebug ((fname, "Open File: <%s>: status = <0x%.8x>\n", report_name,
                status));
    ERRload_struct (NFM, status, "%s", report_name);
    return (status);
    }

/* write SELECT clause */
if (fputs ("SELECT  : ", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write SELECT: status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

/* only write if clause is not NULL */
if (query_info.select_clause)
    {
    if (fputs (query_info.select_clause, out_file) == EOF)
        {
        status = NFM_E_FPUTS_FAILURE;
        _NFMdebug ((fname, "Write SELECT clause <%s>: status = <0x%.8x>\n",
                    query_info.select_clause, status));
        ERRload_struct (NFM, status, NULL);
        return (status);
        }
    }

if (fputs ("\n", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write \"\\n\" : status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

/* write FROM clause */
if (fputs ("FROM    : ", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write FROM: status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

/* only write if clause is not NULL */
if (query_info.from_clause)
    {
    if (fputs (query_info.from_clause, out_file) == EOF)
        {
        status = NFM_E_FPUTS_FAILURE;
        _NFMdebug ((fname, "Write FROM clause <%s>: status = <0x%.8x>\n",
                    query_info.from_clause, status));
        ERRload_struct (NFM, status, NULL);
        return (status);
        }
    }

if (fputs ("\n", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write \"\\n\" : status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

/* write WHERE clause */
if (fputs ("WHERE   : ", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write WHERE: status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

/* only write if clause is not NULL */
if (query_info.where_clause)
    {
    if (fputs (query_info.where_clause, out_file) == EOF)
        {
        status = NFM_E_FPUTS_FAILURE;
        _NFMdebug ((fname, "Write WHERE clause <%s>: status = <0x%.8x>\n",
                    query_info.where_clause, status));
        ERRload_struct (NFM, status, NULL);
        return (status);
        }
    }

if (fputs ("\n", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write \"\\n\" : status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

/* write ORDER clause */
if (fputs ("ORDER   : ", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write ORDER: status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

/* only write if clause is not NULL */
if (query_info.order_by_clause)
    {
    if (fputs (query_info.order_by_clause, out_file) == EOF)
        {
        status = NFM_E_FPUTS_FAILURE;
        _NFMdebug ((fname, "Write ORDER clause <%s>: status = <0x%.8x>\n",
                    query_info.order_by_clause, status));
        ERRload_struct (NFM, status, NULL);
        return (status);
        }
    }

if (fputs ("\n", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write \"\\n\" : status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

/* write PROMPTS */
if (fputs ("PROMPTS : ", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write PROMPTS: status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

/* only write if clause is not NULL */
if (query_info.prompts)
    {
    if (fputs (query_info.prompts, out_file) == EOF)
        {
        status = NFM_E_FPUTS_FAILURE;
        _NFMdebug ((fname, "Write PROMPTS <%s>: status = <0x%.8x>\n",
                    query_info.prompts, status));
        ERRload_struct (NFM, status, NULL);
        return (status);
        }
    }

if (fputs ("\n", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write \"\\n\" : status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

fclose (out_file);

return (NFM_S_SUCCESS);
}

long NFMwrite_ftr_query_file (report_name, query_type, query_info)
   char     *report_name;
   short    query_type;
   struct NFMquery_ftr_info query_info;

{
long    status;
FILE    *fopen (), *out_file;
static  char *fname = "NFMwrite_ftr_query_file";

/* This code can be more intelligent by only writing the fields that
   correspond to the type of query. I'm not sure we want to do this now. */

out_file = fopen (report_name, "w");
if (! out_file)
    {
    status = NFM_E_FOPEN_QUERY_FILE; 
    _NFMdebug ((fname, "Open File: <%s>: status = <0x%.8x>\n", report_name,
                status));
    ERRload_struct (NFM, status, "%s", report_name);
    return (status);
    }

/* write SELECT clause */
if (fputs ("SELECT  : ", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write SELECT: status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

/* only write if clause is not NULL */
if (query_info.select_clause)
    {
    if (fputs (query_info.select_clause, out_file) == EOF)
        {
        status = NFM_E_FPUTS_FAILURE;
        _NFMdebug ((fname, "Write SELECT clause <%s>: status = <0x%.8x>\n",
                    query_info.select_clause, status));
        ERRload_struct (NFM, status, NULL);
        return (status);
        }
    }

if (fputs ("\n", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write \"\\n\" : status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

/* write FROM clause */
if (fputs ("FROM    : ", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write FROM: status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

/* only write if clause is not NULL */
if (query_info.from_clause)
    {
    if (fputs (query_info.from_clause, out_file) == EOF)
        {
        status = NFM_E_FPUTS_FAILURE;
        _NFMdebug ((fname, "Write FROM clause <%s>: status = <0x%.8x>\n",
                    query_info.from_clause, status));
        ERRload_struct (NFM, status, NULL);
        return (status);
        }
    }

if (fputs ("\n", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write \"\\n\" : status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

/* write WHERE clause */
if (fputs ("WHERE   : ", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write WHERE: status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

/* only write if clause is not NULL */
if (query_info.where_clause)
    {
    if (fputs (query_info.where_clause, out_file) == EOF)
        {
        status = NFM_E_FPUTS_FAILURE;
        _NFMdebug ((fname, "Write WHERE clause <%s>: status = <0x%.8x>\n",
                    query_info.where_clause, status));
        ERRload_struct (NFM, status, NULL);
        return (status);
        }
    }

if (fputs ("\n", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write \"\\n\" : status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

/* write ORDER clause */
if (fputs ("ORDER   : ", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write ORDER: status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

/* only write if clause is not NULL */
if (query_info.order_by_clause)
    {
    if (fputs (query_info.order_by_clause, out_file) == EOF)
        {
        status = NFM_E_FPUTS_FAILURE;
        _NFMdebug ((fname, "Write ORDER clause <%s>: status = <0x%.8x>\n",
                    query_info.order_by_clause, status));
        ERRload_struct (NFM, status, NULL);
        return (status);
        }
    }

if (fputs ("\n", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write \"\\n\" : status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

/* write PROMPTS */
if (fputs ("PROMPTS : ", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write PROMPTS: status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

/* only write if clause is not NULL */
if (query_info.prompts)
    {
    if (fputs (query_info.prompts, out_file) == EOF)
        {
        status = NFM_E_FPUTS_FAILURE;
        _NFMdebug ((fname, "Write PROMPTS <%s>: status = <0x%.8x>\n",
                    query_info.prompts, status));
        ERRload_struct (NFM, status, NULL);
        return (status);
        }
    }

if (fputs ("\n", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write \"\\n\" : status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

/* write FTR */
if (fputs ("FTR : ", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write FTR: status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

/* only write if clause is not NULL */
if (query_info.ftr)
    {
    if (fputs (query_info.ftr, out_file) == EOF)
        {
        status = NFM_E_FPUTS_FAILURE;
        _NFMdebug ((fname, "Write FTR <%s>: status = <0x%.8x>\n",
                    query_info.ftr, status));
        ERRload_struct (NFM, status, NULL);
        return (status);
        }
    }

if (fputs ("\n", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write \"\\n\" : status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

/* write Advanced Query Select */
if (fputs ("AQS : ", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write FTR: status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

/* only write if clause is not NULL */
if (query_info.aqs)
    {
    if (fputs (query_info.aqs, out_file) == EOF)
        {
        status = NFM_E_FPUTS_FAILURE;
        _NFMdebug ((fname, "Write AQS <%s>: status = <0x%.8x>\n",
                    query_info.aqs, status));
        ERRload_struct (NFM, status, NULL);
        return (status);
        }
    }

if (fputs ("\n", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write \"\\n\" : status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

/* write Advanced Query From */
if (fputs ("AQF : ", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write AQF: status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

/* only write if clause is not NULL */
if (query_info.aqf)
    {
    if (fputs (query_info.aqf, out_file) == EOF)
        {
        status = NFM_E_FPUTS_FAILURE;
        _NFMdebug ((fname, "Write AQF <%s>: status = <0x%.8x>\n",
                    query_info.aqf, status));
        ERRload_struct (NFM, status, NULL);
        return (status);
        }
    }

if (fputs ("\n", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write \"\\n\" : status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

/* write Advanced Query Where */
if (fputs ("AQW : ", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write AQW: status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

/* only write if clause is not NULL */
if (query_info.aqw)
    {
    if (fputs (query_info.aqw, out_file) == EOF)
        {
        status = NFM_E_FPUTS_FAILURE;
        _NFMdebug ((fname, "Write AQW <%s>: status = <0x%.8x>\n",
                    query_info.aqw, status));
        ERRload_struct (NFM, status, NULL);
        return (status);
        }
    }

if (fputs ("\n", out_file) == EOF)
    {
    status = NFM_E_FPUTS_FAILURE;
    _NFMdebug ((fname, "Write \"\\n\" : status = <0x%.8x>\n", status));
    ERRload_struct (NFM, status, NULL);
    return (status);
    }

fclose (out_file);

return (NFM_S_SUCCESS);
}


