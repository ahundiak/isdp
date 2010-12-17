/*
**	NAME:							usrmisc.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					10/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
**	Starting with RIS 5.x.x.x , ris_attr_info_2 instead of ris_attr_info 
**	should be used in riscli; ris_attr_info is used in rissrv talking to
**	RIS 4.x.x.x client.      
**
**	06/93:       James Chang
**	changed fieldname 'usr' to 'schowner' in risschema and
**	ris_schema_info structures -- Shiva 11/11/93
**
**	Added a new function to copy contents of risschema to
**	ris_sch_intern_info -- Shiva 2/27/94
**
**	8/26/94 Mark -- Added CheckValidDBLoc to check for / in NT
**                  path strings and \ in unix path strings
**	10/24/94 -Radha
**		Added changes for MSSQL data server.
**
**	11/94:	Added support for INTERNATIONALIZATION. Dianne
*/
 
/*
**	INCLUDES
*/
#include "riscom.h"
#include "risdebug.h"
#include "riscl_pa.h"
#include "riscl_sr.h"
#include "ris.h"
#include "user.h"
#include "commacro.h"
/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define usrmisc_c
#include "usrmisc.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "comuni.prt"
#include "dicdcsch.prt"
#include "sys.prt"
void CheckValidDBLoc(unsigned char, char *);

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISusr_ifx_parms_to_ifx_info(
	risifxparms		*parms,
	ris_ifx_info	*info)
{
	strcpy(info->dir, parms->dir);
	strcpy(info->sqlexec, parms->sqlexec);
	strcpy(info->dbtemp, parms->dbtemp);
	strcpy(info->tbconfig, parms->tbconfig);
}

/******************************************************************************/

extern void RISusr_igs_parms_to_igs_info(
	risigsparms		*parms,
	ris_igs_info	*info)
{
	strcpy(info->dir, parms->dir);
}

/******************************************************************************/

extern void RISusr_ora_parms_to_ora_info(
	risoraparms		*parms,
	ris_ora_info	*info)
{
	strcpy(info->dir, parms->dir);
	strcpy(info->osuser, parms->osuser);
	strcpy(info->ospass, parms->ospass);
}

/******************************************************************************/

extern void RISusr_db2_parms_to_db2_info(
	risdb2parms		*parms,
	ris_db2_info	*info)
{
	strcpy(info->osuser, parms->osuser);
	strcpy(info->ospass, parms->ospass);
	strcpy(info->arch, parms->arch);
	strcpy(info->os, parms->os);
	strcpy(info->env, parms->env);
	strcpy(info->net_protocol, parms->net_protocol);
	strcpy(info->host_program, parms->host_program);
	strcpy(info->ris_lu, parms->ris_lu);
	strcpy(info->host_lu, parms->host_lu);
	strcpy(info->mode, parms->mode);
	strcpy(info->group, parms->group);
	strcpy(info->node, parms->node);
	info->port = parms->port;
}

/******************************************************************************/

 extern void RISusr_os400_parms_to_os400_info(
   risos400parms       *parms,
   ris_os400_info  *info)
 {
   strcpy(info->osuser, parms->osuser);
   strcpy(info->ris_dict_dbname, parms->ris_dict_dbname);
   strcpy(info->ospass, parms->ospass);
   strcpy(info->net_protocol, parms->net_protocol);
   strcpy(info->host_program, parms->host_program);
   strcpy(info->ris_lu, parms->ris_lu);
   strcpy(info->host_lu, parms->host_lu);
   strcpy(info->mode, parms->mode);
   strcpy(info->group, parms->group);
   strcpy(info->node, parms->node);
   info->port = parms->port;
 }

/******************************************************************************/
extern void RISusr_syb_parms_to_syb_info(
	rissybparms		*parms,
	ris_syb_info	*info)
{
	strcpy(info->osuser, parms->osuser);
	strcpy(info->ospass, parms->ospass);
	strcpy(info->dir, parms->dir);
	strcpy(info->dsquery, parms->dsquery);
	strcpy(info->sybifile, parms->sybifile);
}

/******************************************************************************/
extern void RISusr_mssql_parms_to_mssql_info(
	rismssqlparms		*parms,
	ris_mssql_info	*info)
{
	strcpy(info->osuser, parms->osuser);
	strcpy(info->ospass, parms->ospass);
	strcpy(info->dir, parms->dir);
	strcpy(info->dsquery, parms->dsquery);
	strcpy(info->mssqlifile, parms->mssqlifile);
}
/******************************************************************************/

extern void RISusr_db_to_db_info(
	risdb		*db,
	ris_db_info *db_info)
{
	int i;

	USR_DBG(("RISusr_db_to_db_info(db:0x%x db_info:0x%x)\n",
		db, db_info));

	db_info->dbid = db->dbid;
	db_info->dtype = db->dtype;
	db_info->ostype = db->ostype;
	strcpy(db_info->dbname, db->dbname);

	for (i = 0; i < 4; i++)
	{
		db_info->pathways[i].protocol = db->pathways[i].protocol;
		strcpy(db_info->pathways[i].netaddr, db->pathways[i].netaddr);
	}

	switch(db->dtype)
	{
		case 'X':
#if defined(WIN32)
		/* 
		** On NT, Informix-SE requires /d=/usr/risdb style syntax.
		** So ignore / checking. _Hitesh 2/95
		*/
#else
   			            CheckValidDBLoc(db_info->ostype, db->parms.ifx.dir);
#endif
			RISusr_ifx_parms_to_ifx_info(&db->parms.ifx, &db_info->info.ifx);
			break;

		case 'I':
                        CheckValidDBLoc(db_info->ostype, db->parms.igs.dir);
			RISusr_igs_parms_to_igs_info(&db->parms.igs, &db_info->info.igs);
			break;

		case 'O':
                        CheckValidDBLoc(db_info->ostype, db->parms.ora.dir);
			RISusr_ora_parms_to_ora_info(&db->parms.ora, &db_info->info.ora);
			break;

		case 'D':
			RISusr_db2_parms_to_db2_info(&db->parms.db2, &db_info->info.db2);
			break;

		case '4':
           	        RISusr_os400_parms_to_os400_info(&db->parms.os400,
                           &db_info->info.os400);
       		break;

		case 'R':
			/* nothing to do */
			break;

		case 'Y':
                        CheckValidDBLoc(db_info->ostype, db->parms.syb.dir);
			RISusr_syb_parms_to_syb_info(&db->parms.syb, &db_info->info.syb);
			break;

		case 'M':
                        CheckValidDBLoc(db_info->ostype, db->parms.mssql.dir);
			RISusr_mssql_parms_to_mssql_info(&db->parms.mssql, &db_info->info.mssql);
			break;

	}
	USR_DBG(("RISusr_db_to_db_info:returning\n"));
}

/******************************************************************************/

extern void RISusr_schema_to_schema_info(
	risschema		*schema,
	ris_schema_info *schema_info)
{
	USR_DBG(("RISusr_schema_to_schema_info(schema:0x%x schema_info:0x%x)\n",
		schema, schema_info));

	strcpy(schema_info->schname, schema->schname);
	strcpy(schema_info->schowner, schema->schowner);
	strcpy(schema_info->dictowner, schema->dictowner);
	schema_info->dbid = schema->dbid;
	schema_info->server_version_major = schema->major;
	schema_info->server_version_feature = schema->feature;
	if (schema->secure == 'S')
	{
		strcpy(schema_info->schownpass, "");
		schema_info->secure = 1;
	}
	else
	{
		strcpy(schema_info->schownpass, schema->passwd);
		schema_info->secure = 0;
	}

	USR_DBG(("RISusr_schema_to_schema_info: schowner <%s> schownpass <%s>\n",
		schema_info->schowner, schema_info->schownpass));
	USR_DBG(("RISusr_schema_to_schema_info: dictowner <%s> secure:%d\n",
		schema_info->dictowner, schema_info->secure));
	USR_DBG(("RISusr_schema_to_schema_info: major <%d> feature <%d>\n",
		schema_info->server_version_major,schema_info->server_version_feature));

	USR_DBG(("RISusr_schema_to_schema_info:returning\n"));
}

/******************************************************************************/
	/* Shiva : Added the following function to copy the schema
	** structure to an internal schema info structure
	*/

extern void RISusr_schema_to_sch_intern_info(
	risschema		*schema,
	ris_sch_intern_info *sch_intern_info)
{
	USR_DBG(("RISusr_schema_to_sch_intern_info(schema:0x%x sch_intern_info:0x%x)\n",
		schema, sch_intern_info));

	strcpy(sch_intern_info->schname, schema->schname);

	sch_intern_info->major = schema->major;
	sch_intern_info->feature = schema->feature;

	strcpy(sch_intern_info->dictowner, schema->dictowner);
	strcpy(sch_intern_info->schowner, schema->schowner);

	if (schema->secure == 'S')
	{
        risdclrschema *dschema;
 
		strcpy(sch_intern_info->login, schema->login);
		strcpy(sch_intern_info->passwd, schema->loginpd);
		sch_intern_info->schtype = SECURE_SCHEMA;

        /*
        ** check if osuser passwd is null. if it is, then retrieve it
        ** from declare schema statement, if available
        */
        dschema = RISdic_lookup_risdclrsch(schema->schname);

        if ( dschema && dschema->osuserpd )
        {
           switch(schema->db->dtype)
           {
               case '4':
                   if ( !strlen(schema->db->parms.os400.ospass) )
                      strcpy(schema->db->parms.os400.ospass, dschema->osuserpd);
               break;

               case 'O':
                   if ( !strlen(schema->db->parms.ora.ospass) )
                      strcpy(schema->db->parms.ora.ospass, dschema->osuserpd);
               break;

               case 'D':
                   if ( !strlen(schema->db->parms.db2.ospass) )
                      strcpy(schema->db->parms.db2.ospass, dschema->osuserpd);
               break;

               case 'Y':
                   if ( !strlen(schema->db->parms.syb.ospass) )
                      strcpy(schema->db->parms.syb.ospass, dschema->osuserpd);
               break;

               case 'M':
                   if ( !strlen(schema->db->parms.mssql.ospass) )
                      strcpy(schema->db->parms.mssql.ospass, dschema->osuserpd);
               break;

               default:
               break;
           }

           USR_DBG(("RISusr_schema_to_sch_intern_info: got osuserpd for "));
           USR_DBG(("secure schema %s\n", dschema->osuserpd));
        }
	}
	else
	{
		strcpy(sch_intern_info->login, schema->schowner);
		strcpy(sch_intern_info->passwd, schema->passwd);
		sch_intern_info->schtype = STANDARD_SCHEMA;
	}
	sch_intern_info->dbid = schema->dbid;

	USR_DBG(("RISusr_schema_to_sch_intern_info: schowner <%s> passwd <%s>\n",
		sch_intern_info->schowner, sch_intern_info->passwd));
	USR_DBG(("RISusr_schema_to_sch_intern_info: dictowner <%s> login <%s>\n",
		sch_intern_info->dictowner, sch_intern_info->login));
	USR_DBG(("RISusr_schema_to_sch_intern_info: major <%d> feature <%d>\n",
		sch_intern_info->major, sch_intern_info->feature));

	USR_DBG(("RISusr_schema_to_sch_intern_info:returning\n"));
}
/******************************************************************************/

extern void RISusr_attr_info_to_attr(
	ris_attr_info	*attr_info,
	risattr			*attr)
{
	USR_DBG(("RISusr_attr_info_to_attr(attr_info:0x%x attr:0x%x)\n",
		attr_info, attr));

	strcpy(attr->attrname, attr_info->attrname);
	strcpy(attr->extern_attrname, attr_info->extern_attrname);
	attr->atype = attr_info->atype;
	attr->asize.len = attr_info->asize.len;

	/*
	** Added 1/6/92 - Sunil
	*/
	attr->dbsqltype = attr_info->dbsqltype;
	attr->dbsqllen = attr_info->dbsqllen;

	USR_DBG(("RISusr_attr_info_to_attr:returning\n"));
}

/******************************************************************************/

extern void RISusr_access_info_to_access(
	ris_access_info	*access_info,
	risaccess			*access)
{
	USR_DBG(("RISusr_access_info_to_access(access_info:0x%x access:0x%x)\n",
		access_info, access));

	strcpy(access->schname, access_info->schname);
	strcpy(access->relowner, access_info->relowner);
	strcpy(access->relname, access_info->relname);
	strcpy(access->colname, access_info->colname);
	strcpy(access->grantor, access_info->grantor);
	strcpy(access->grantee, access_info->grantee);
	strcpy(access->auth, access_info->auth);
	access->relid = access_info->relid;
	access->insert_flag = access_info->insert_flag;

	USR_DBG(("RISusr_access_info_to_access:returning\n"));
}

/******************************************************************************/

extern void RISusr_access_to_access_info(
	risaccess			*access,
	ris_access_info	*access_info)
{
	USR_DBG(("RISusr_access_to_access_info(access:0x%x access_info:0x%x)\n",
		access, access_info));

	strcpy(access_info->schname, access->schname);
	strcpy(access_info->relowner, access->relowner);
	strcpy(access_info->relname, access->relname);
	strcpy(access_info->colname, access->colname);
	strcpy(access_info->grantor, access->grantor);
	strcpy(access_info->grantee, access->grantee);
	strcpy(access_info->auth, access->auth);
	access_info->relid = access->relid;
	access_info->insert_flag = access->insert_flag;

	USR_DBG(("RISusr_access_to_access_info:returning\n"));
}

/******************************************************************************/

void CheckValidDBLoc(unsigned char ostype, char *db_loc)
{
#define UNIXPATHCHR '/'
#define WINPATHCHR '\\'

	char * output;

	USR_DBG(("CheckValidDBLoc: ostype <%c>, db_loc <%s>\n", ostype, db_loc));

   switch ( ostype ) 
   {
      case 'U' : 
         output = RIScom_strchr(db_loc,WINPATHCHR);
         if ( RIScom_strchr(db_loc,WINPATHCHR))
         {
            USR_DBG(("   found \\ in a unix path string <%s> <%s>\n",db_loc,output));
            LONGJMP(RIS_E_INVALID_DBMS_LOCATION);
         }
         break;

      case 'N' :
         output = RIScom_strchr(db_loc,UNIXPATHCHR);
         if ( RIScom_strchr(db_loc,UNIXPATHCHR))
         {
            USR_DBG(("   found / in an NT path string <%s> <%s>\n",db_loc,output));
            LONGJMP(RIS_E_INVALID_DBMS_LOCATION);
         }
         break;

      default : break;
   }

}
