/* $Revision: 1.1 $ */
/* Function:	dba_nfm_calls */
#include "dba.ext"

extern FILE *dba_log;
extern int dba_no_user_load;

int dba_nfm_calls(long rcode, char *net_buffer, 
                  int *wcnt, int *status)
{
    int offset, length;
    char *ptr, *server, *user, *passwd, *env, *catalog, 
         *name, *rev, *desc, *filename, *node, *path, *storage,
         *new_catalog, *new_name, *new_rev, *state, *set_name, *set_rev,
          nfm_schema[32], nfm_passwd[32], *set_catalog, *application,
         *wf_file, *wfname, *aclname, *type, *mail, *class, *new_passwd,
         *c_name, *c_value, *synonym, *ci_filename, *co_filename,
         *sa_type, *owner, *xns, *tcp, *nfs, *filetype;
    short debug, aclno, versionlimit, cisano, level;

    switch(rcode)
    {
        case DBA_NFM_LOGIN:
	    
            if (dba_log){
		 fprintf(dba_log,"DBA_LOGIN\n");
		 fflush(dba_log);
	    }
            ptr = net_buffer;
            offset = sizeof(long) * 2;
	    
            server = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, "server = %s\n", server);	      

            user = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, "user = %s\n", user);	      

            passwd = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, "passwd = %s\n", passwd);	      

            env = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, "env = %s\n", env);	      

	    memcpy(&debug, ptr + offset, sizeof(short));
            dba_short_swap_bytes (&debug);

            if (dba_log) fprintf(dba_log, "debug = %hd\n", debug);

            if (!dba_no_user_load)
              NFMload_user_info ("nfmadmin");
              
            *status = dba_nfm_login(server, user, passwd, env, (int)debug);
            if (dba_log) {
              fprintf(dba_log, "status = 0x%.8x\n", *status);
              fflush(dba_log);
            }
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_LOGOUT:
	    
            if (dba_log) fprintf(dba_log,"DBA_LOGOUT\n");
            ptr = net_buffer;
            offset = sizeof(long) * 2;	      
            *status = dba_nfm_logout();
            if (dba_log) {
              fprintf(dba_log, "status = 0x%.8x\n", *status);	    
              fflush(dba_log);
            }
            *wcnt = sizeof(long) * 2;
            break;

        case DBA_NFM_ADD_ITEM:
	    
            if (dba_log) fprintf(dba_log,"DBA_ADD_ITEM\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, "catalog = %s\n", catalog);
			  
            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "name = %s\n", name);	      
			   
            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "rev = %s\n", rev);	      
			   
            desc = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "desc = %s\n", desc);	      
			  
	    memcpy(&aclno, ptr + offset, sizeof(short));
            dba_short_swap_bytes (&aclno);
	    offset += sizeof(short);
            if (dba_log) fprintf(dba_log, "aclno = %hd\n", aclno);
	      
	    memcpy(&versionlimit, ptr + offset, sizeof(short));
	    dba_short_swap_bytes (&versionlimit);
            offset += sizeof(short);
            if (dba_log) fprintf(dba_log, "versionlimit = %hd\n", 
                                   versionlimit);
				   
	    memcpy(&cisano, ptr + offset, sizeof(short));
            dba_short_swap_bytes (&cisano);
	    offset += sizeof(short);
            if (dba_log) fprintf(dba_log, "cisano = %hd\n", 
                                   cisano);
            filename = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "filename = %s\n", filename);	      

            ci_filename = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "ci_filename = %s\n", filename);	      

            filetype = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "filetype = %s\n", filetype);	      

            *status = dba_nfm_add_item(catalog, name, rev, desc, 
                       (int)aclno, (int)versionlimit, (int)cisano,
                       filename, ci_filename, filetype);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_CHECKIN:
	    
            if (dba_log) fprintf(dba_log,"DBA_CHECKIN\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);
			  
            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "name = %s\n", name);	      
			   
            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "rev = %s\n", rev);	      
            storage = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "storage = %s\n", storage);	      

            node = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "node = %s\n", node);	      
			   
            user = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "user = %s\n", user);	      
			   
            passwd = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "passwd = %s\n", passwd);	      
			   
            path = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "path = %s\n", path);	      

            filename = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "filename = %s\n", filename);	      
			  
            *status = dba_nfm_checkin(catalog, name, rev, storage, node, user,
                              passwd, path, filename);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);

            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_CHECKOUT:
	    
            if (dba_log) fprintf(dba_log,"DBA_CHECKOUT\n");
            if (dba_log) fflush(dba_log);

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);
			  
            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "name = %s\n", name);	      
			   
            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "rev = %s\n", rev);	      

            storage = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "storage = %s\n", storage);	      

            node = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "node = %s\n", node);	      
			   
            user = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "user = %s\n", user);	      
			   
            passwd = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "passwd = %s\n", passwd);	      
			   
            path = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "path = %s\n", path);	      

            filename = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "filename = %s\n", filename);	      
			  
            *status = dba_nfm_checkout(catalog, name, rev, storage, node, user,
                              passwd, path, filename);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);
	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_COPY:
	    
            if (dba_log) fprintf(dba_log,"DBA_COPY\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);
			  
            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "name = %s\n", name);	      
			   
            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "rev = %s\n", rev);	      

            storage = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "storage = %s\n", storage);	      

            node = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "node = %s\n", node);	      
			   
            user = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "user = %s\n", user);	      
			   
            passwd = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "passwd = %s\n", passwd);	      
			   
            path = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "path = %s\n", path);	      

            filename = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "filename = %s\n", filename);	      
			  
            *status = dba_nfm_copy(catalog, name, rev, storage, node, user,
                              passwd, path, filename);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_COPY_NEW_ITEM:
	    
            if (dba_log) fprintf(dba_log,"DBA_COPY_NEW_ITEM\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);
			  
            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "name = %s\n", name);	      
			   
            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "rev = %s\n", rev);	      

            new_catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "new_catalog = %s\n", new_catalog);
			  
            new_name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "new_name = %s\n", new_name);	      
			   
            new_rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "new_rev = %s\n", new_rev);	      

            co_filename = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "co_filename = %s\n", co_filename);	      

            ci_filename = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "ci_filename = %s\n", ci_filename);	      

            storage = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "storage = %s\n", storage);	      

            *status = dba_nfm_copy_new_item(catalog, name, rev, 
					new_catalog, new_name, new_rev,
                                        co_filename, ci_filename, storage);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_GET_MESSAGE:
	    
            if (dba_log) fprintf(dba_log,"DBA_GET_MESSAGE\n");
            ptr = net_buffer;
            offset = sizeof(long) * 2;
            *(ptr + offset) = 0;	      
            dba_nfm_get_message(ptr + offset);
            length = strlen(ptr + offset) + 1;
            if (dba_log) fprintf(dba_log,"length = %d\n", length);    
            if (dba_log) fprintf(dba_log,"message = %s\n", ptr + offset);
            if (dba_log) fflush(dba_log);
            offset += length;
            *status = 0;
            *wcnt = offset;
            break;

	case DBA_NFM_DELETE_ITEM:
	   
            if (dba_log) fprintf(dba_log,"DBA_DELETE_ITEM\n");
            ptr = net_buffer;
            offset = sizeof(long) * 2;	      
	      
            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);
			  
            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "name = %s\n", name);	      
			   
            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "rev = %s\n", rev);	      

            *status = dba_nfm_delete_item(catalog, name, rev);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
	    *wcnt = sizeof(long) * 2;
            break;

        case DBA_NFM_FLAG_ITEM_DELETE:
	    
            if (dba_log) fprintf(dba_log,"DBA_FLAG_ITEM_DELETE\n");
            ptr = net_buffer;
            offset = sizeof(long) * 2;	      

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);
			  
            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "name = %s\n", name);	      
			   
            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "rev = %s\n", rev);	      

            *status = dba_nfm_flag_item_delete(catalog, name, rev);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

        case DBA_NFM_CHECKIN_MULTI:
	    
            if (dba_log) fprintf(dba_log,"DBA_CHECKIN_MULTI\n");
            ptr = net_buffer;
            offset = sizeof(long) * 2;	      

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);
			  
            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "name = %s\n", name);	      
			   
            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "rev = %s\n", rev);	      

            storage = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "storage = %s\n", storage);	      

            node = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "node = %s\n", node);	      
			   
            user = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "user = %s\n", user);	      
			   
            passwd = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "passwd = %s\n", passwd);	      
			   
            path = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "path = %s\n", path);	      

            *status = dba_nfm_checkin_multi(catalog, name, rev, storage, 
					node, user, passwd, path);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);
            *wcnt = sizeof(long) * 2;
            break;

        case DBA_NFM_ADD_MULTI:
	    
            if (dba_log) fprintf(dba_log,"DBA_ADD_MULTI\n");
            ptr = net_buffer;
            offset = sizeof(long) * 2;	      

            filename = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "filename = %s\n", filename);	      

            *status = dba_nfm_add_multi(filename);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);
            *wcnt = sizeof(long) * 2;
            break;

        case DBA_NFM_ADD_FILE:
	    
            if (dba_log) fprintf(dba_log,"DBA_ADD_FILE\n");
            ptr = net_buffer;
            offset = sizeof(long) * 2;	      

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);

            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "name = %s\n", name);	      

            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "rev = %s\n", rev);	      

            filename = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "filename = %s\n", filename);	      

            storage = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "storage = %s\n", storage);	      

            ci_filename = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "ci_filename = %s\n", ci_filename);	      

            filetype = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "filetype = %s\n", filetype);	      

            *status = dba_nfm_add_file(catalog, name, rev, filename, storage,
                                       ci_filename, filetype);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);
            *wcnt = sizeof(long) * 2;
            break;
	      
        case DBA_NFM_CANCEL_ITEM:
	    
	    if (dba_log) fprintf(dba_log,"DBA_NFM_CANCEL_ITEM\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;	      

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);

            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "name = %s\n", name);

            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "rev = %s\n", rev);

            *status = dba_nfm_cancel_item(catalog, name, rev);

            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_CREATE_CATALOG:
	    
            if (dba_log) fprintf(dba_log,"DBA_CREATE_CATALOG\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);
			  
            desc = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "desc = %s\n", desc);	
      
	    memcpy(&aclno, ptr + offset, sizeof(short));
            dba_short_swap_bytes (&aclno);
	    if (dba_log)
            	fprintf(dba_log, "aclno = %d\n", aclno);
            *status = dba_nfm_create_catalog(catalog, desc, (int)aclno);
            if (dba_log) fprintf(dba_log, "status = 0x%.8x\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_MAKE_TRANSITION:
	    
            if (dba_log) fprintf(dba_log,"DBA_MAKE_TRANSITION\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);
			  
            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "name = %s\n", name);	      

            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "rev = %s\n", rev);	      

            state = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "state = %s\n", state);	      

            *status = dba_nfm_make_transition(catalog, name, rev, state);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_GET_SCHEMA_NAME:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_GET_SCHEMA_NAME\n");

            ptr = net_buffer;

            offset = sizeof(long) * 2;

            nfm_schema[0] = '\0';
            nfm_passwd[0] = '\0';

            *status = dba_nfm_get_schema_name(nfm_schema, nfm_passwd);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);

            *(ptr + offset) = 0;	      
            strcpy(ptr + offset, nfm_schema);
            length = strlen(nfm_schema) + 1;
            offset += length;

            strcpy(ptr + offset, nfm_passwd);
            length = strlen(nfm_passwd) + 1;
            offset += length;
            *wcnt = offset;

            break;

	case DBA_NFM_SET_COPY:
	    
            if (dba_log) fprintf(dba_log,"DBA_SET_COPY\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);
			  
            set_name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "set_name = %s\n", set_name);	      
			   
            set_rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "set_rev = %s\n", set_rev);	      

	    memcpy(&level, ptr + offset, sizeof(short));
            dba_short_swap_bytes (&level);
            offset += sizeof(short);

            storage = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "storage = %s\n", storage);	      

            node = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "node = %s\n", node);	      
			   
            user = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "user = %s\n", user);	      
			   
            passwd = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "passwd = %s\n", passwd);	      
			   
            path = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "path = %s\n", path);	      

            *status = dba_nfm_set_copy(catalog, set_name, set_rev, (int)level,
                              storage, node, user, passwd, path);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_SET_CHECKIN:
	    
            if (dba_log) fprintf(dba_log,"DBA_SET_CHECKIN\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);
			  
            set_name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "set_name = %s\n", set_name);	      
			   
            set_rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "set_rev = %s\n", set_rev);	      

            storage = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "storage = %s\n", storage);	      

            node = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "node = %s\n", node);	      
			   
            user = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "user = %s\n", user);	      
			   
            passwd = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "passwd = %s\n", passwd);	      
			   
            path = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "path = %s\n", path);	      

            *status = dba_nfm_set_checkin(catalog, set_name, set_rev,
                              storage, node, user, passwd, path);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_SET_CHECKOUT:
	    
            if (dba_log) fprintf(dba_log,"DBA_SET_CHECKOUT\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);
			  
            set_name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "set_name = %s\n", set_name);	      
			   
            set_rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "set_rev = %s\n", set_rev);	      

	    memcpy(&level, ptr + offset, sizeof(short));
            dba_short_swap_bytes (&level);
            offset += sizeof(short);

            storage = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "storage = %s\n", storage);	      

            node = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "node = %s\n", node);	      
			   
            user = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "user = %s\n", user);	      
			   
            passwd = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "passwd = %s\n", passwd);	      
			   
            path = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "path = %s\n", path);	      

            *status = dba_nfm_set_checkout(catalog, set_name, set_rev, 
                              (int)level, storage, node, user, passwd, path);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_ADD_SET:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_ADD_SET\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);
			  
            set_name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "set_name = %s\n", set_name);	      
			   
            set_rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "set_rev = %s\n", set_rev);	      

            desc = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "desc = %s\n", desc);

	    memcpy(&aclno, ptr + offset, sizeof(short));
            dba_short_swap_bytes (&aclno);
            offset += sizeof(short);

	    memcpy(&versionlimit, ptr + offset, sizeof(short));
            dba_short_swap_bytes (&versionlimit);
            offset += sizeof(short);

	    memcpy(&cisano, ptr + offset, sizeof(short));
            dba_short_swap_bytes (&cisano);
            offset += sizeof(short);

            *status = dba_nfm_add_set(catalog, set_name, set_rev, 
                               desc, (int)aclno, (int)versionlimit,
                               (int)cisano);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_ADD_TO_SET2:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_ADD_TO_SET2\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            set_catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "set_catalog = %s\n", set_catalog);
			  
            set_name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "set_name = %s\n", set_name);	      
			   
            set_rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "set_rev = %s\n", set_rev);	      

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);
			  
            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "name = %s\n", name);	      
			   
            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "set_rev = %s\n", set_rev);	      

            type = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "type = %s\n", type);	      


            *status = dba_nfm_add_to_set2(set_catalog, set_name, set_rev, 
                               catalog, name, rev, type);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_ADD_TO_SET:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_ADD_TO_SET\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);
			  
            set_name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "set_name = %s\n", set_name);	      
			   
            set_rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "set_rev = %s\n", set_rev);	      

            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "name = %s\n", name);	      
			   
            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "set_rev = %s\n", set_rev);	      

            type = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "type = %s\n", type);	      


            *status = dba_nfm_add_to_set(catalog, set_name, set_rev, 
                               name, rev, type);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_ADD_USER:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_ADD_USER\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            user = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "user = %s\n", user);
			  
            passwd = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "passwd = %s\n", passwd);	      
			   
            desc = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "desc = %s\n", desc);	      

            mail = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "mail = %s\n", mail);

            *status = dba_nfm_add_user(user, passwd, desc, mail);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_ADD_STORAGE_AREA:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_ADD_STORAGE_AREA\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "name = %s\n", name);
			  
            node = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "node = %s\n", node);	      
			   
            user = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "user = %s\n", user);	      

            passwd = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "passwd = %s\n", passwd);

            path = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "path = %s\n", path);

            type = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "type = %s\n", type);

            sa_type = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "sa_type = %s\n", sa_type);

            owner = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "owner = %s\n", owner);

            *status = dba_nfm_add_storage_area(name, node, user, passwd,
                     path, type, sa_type, owner);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_DELETE_CATALOG:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_DELETE_CATALOG\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);

            *status = dba_nfm_delete_catalog(catalog);

            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_DELETE_STORAGE_AREA:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_DELETE_STORAGE_AREA\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            storage = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "storage = %s\n", storage);

            *status = dba_nfm_delete_storage_area(storage);

            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_DELETE_USER:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_DELETE_USER\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            user = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "user = %s\n", user);

            *status = dba_nfm_delete_user(user);

            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_LOAD_WORKFLOW:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_LOAD_WORKFLOW\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            application = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "application = %s\n", application);

            wf_file = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "wf_file = %s\n", wf_file);


            *status = dba_nfm_load_workflow(application, wf_file);

            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_ADD_ACL:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_ADD_ACL\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            wfname = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "wfname = %s\n", wfname);

            aclname = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "aclname = %s\n", aclname);

            *status = dba_nfm_add_acl(wfname, aclname);

            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_ADD_ACL_USER:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_ADD_ACL_USER\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            aclname = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "aclname = %s\n", aclname);

            class = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "class = %s\n", class);
            user = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "user = %s\n", user);

            wfname = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "wfname = %s\n", wfname);

            *status = dba_nfm_add_acl_user(aclname, class, user, wfname);

            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_CHANGE_USER_PASSWD:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_CHANGE_USER_PASSWD\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            user = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "user = %s\n", user);

            passwd = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "passwd = %s\n", passwd);

            new_passwd = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "new_passwd = %s\n", new_passwd);

            *status = dba_nfm_change_user_passwd(user, passwd, new_passwd);

            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_FLAG_ITEM_BACKUP:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_FLAG_ITEM_BACKUP\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);

            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "name = %s\n", name);

            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "rev = %s\n", rev);

            *status = dba_nfm_flag_item_backup(catalog, name, rev);

            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_CANCEL_ITEM_BACKUP:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_CANCEL_ITEM_BACKUP\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);

            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "name = %s\n", name);

            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "rev = %s\n", rev);

            *status = dba_nfm_cancel_item_backup(catalog, name, rev);

            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_CANCEL_ITEM_ARCHIVE:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_CANCEL_ITEM_ARCHIVE\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);

            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "name = %s\n", name);

            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "rev = %s\n", rev);

            *status = dba_nfm_cancel_item_archive(catalog, name, rev);

            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_CANCEL_ITEM_DELETE:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_CANCEL_ITEM_DELETE\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);

            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "name = %s\n", name);

            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "rev = %s\n", rev);

            *status = dba_nfm_cancel_item_delete(catalog, name, rev);

            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_CANCEL_ITEM_RESTORE:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_CANCEL_ITEM_RESTORE\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);

            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "name = %s\n", name);

            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "rev = %s\n", rev);

            *status = dba_nfm_cancel_item_restore(catalog, name, rev);

            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_FLAG_ITEM_ARCHIVE:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_FLAG_ITEM_ARCHIVE\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);

            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "name = %s\n", name);

            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "rev = %s\n", rev);

            *status = dba_nfm_flag_item_archive(catalog, name, rev);

            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_FLAG_ITEM_RESTORE:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_FLAG_ITEM_RESTORE\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);

            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "name = %s\n", name);

            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "rev = %s\n", rev);

            *status = dba_nfm_flag_item_restore(catalog, name, rev);

            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_CHANGE_SA_PASSWD:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_CHANGE_SA_PASSWD\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            storage = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "storage = %s\n", storage);

            passwd = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "passwd = %s\n", passwd);

            new_passwd = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "new_passwd = %s\n", new_passwd);

            *status = dba_nfm_change_sa_passwd(storage, passwd, new_passwd);

            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_BUILD_SET_LIST:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_BUILD_SET_LIST\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "name = %s\n", name);

            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "rev = %s\n", rev);

            type = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "type = %s\n", type);

            *status = dba_nfm_build_set_list(name, rev, type);

            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_BUILD_SET_LIST2:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_BUILD_SET_LIST2\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);

            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "name = %s\n", name);

            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "rev = %s\n", rev);

            type = ptr + offset;

            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "type = %s\n", type);

            *status = dba_nfm_build_set_list2(catalog, name, rev, type);

            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_ADD_LIST_TO_SET:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_ADD_LIST_TO_SET\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            set_catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "set_catalog = %s\n", set_catalog);

            set_name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "set_name = %s\n", set_name);

            set_rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "set_rev = %s\n", set_rev);

            *status = dba_nfm_add_list_to_set(set_catalog, set_name, set_rev);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_DEFAULT_SCHEMA:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_DEFAULT_SCHEMA\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            *status = dba_nfm_default_schema();
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_DROP_SET:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_DROP_SET\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            set_catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "set_catalog = %s\n", set_catalog);

            set_name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "set_name = %s\n", set_name);

            set_rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "set_rev = %s\n", set_rev);

            *status = dba_nfm_drop_set(set_catalog, set_name, set_rev);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_DELETE_ACL_USER:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_DELETE_ACL_USER\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            aclname = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "aclname = %s\n", aclname);

            class = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "class = %s\n", class);
            user = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "user = %s\n", user);

            wfname = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "wfname = %s\n", wfname);

            *status = dba_nfm_delete_acl_user(aclname, class, user, wfname);

            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_DELETE_FILE:
	   
            if (dba_log) fprintf(dba_log,"DBA_DELETE_FILE\n");
            ptr = net_buffer;
            offset = sizeof(long) * 2;	      
	      
            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);
			  
            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "name = %s\n", name);	      
			   
            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "rev = %s\n", rev);	      

            filename = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "filename = %s\n", filename);	      

            *status = dba_nfm_delete_file(catalog, name, rev, filename);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
	    *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_CHANGE_FILE:
	   
            if (dba_log) fprintf(dba_log,"DBA_NFM_CHANGE_FILE\n");
            ptr = net_buffer;
            offset = sizeof(long) * 2;	      
	      
            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);
			  
            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "name = %s\n", name);	      
			   
            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "rev = %s\n", rev);	      

            filename = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "filename = %s\n", filename);	      

            c_name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "c_name = %s\n", c_name);	      

            c_value = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "c_value = %s\n", c_value);	      

            *status = dba_nfm_change_file(catalog, name, rev, filename, 
				     c_name, c_value);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
	    *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_DROP_FROM_SET:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_DROP_FROM_SET\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            set_catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "set_catalog = %s\n", set_catalog);

            set_name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "set_name = %s\n", set_name);

            set_rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "set_rev = %s\n", set_rev);

            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "name = %s\n", name);

            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "rev = %s\n", rev);

            *status = dba_nfm_drop_from_set(set_catalog, set_name, set_rev,
                                 name, rev);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_DROP_FROM_SET2:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_DROP_FROM_SET2\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            set_catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "set_catalog = %s\n", set_catalog);

            set_name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "set_name = %s\n", set_name);

            set_rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "set_rev = %s\n", set_rev);

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);

            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "name = %s\n", name);

            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "rev = %s\n", rev);

            *status = dba_nfm_drop_from_set2(set_catalog, set_name, set_rev,
                                 catalog, name, rev);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_CHANGE_USER:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_CHANGE_USER\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            user = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "user = %s\n", user);

            c_name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "c_name = %s\n", c_name);

            c_value = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "c_value = %s\n", c_value);

            *status = dba_nfm_change_user(user, c_name, c_value);

            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_SIGNOFF:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_SIGNOFF\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);

            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "name = %s\n", name);

            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "rev = %s\n", rev);

            *status = dba_nfm_signoff(catalog, name, rev);

            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_UNLOCK_ITEM:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_UNLOCK_ITEM\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);

            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "name = %s\n", name);

            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "rev = %s\n", rev);

            *status = dba_nfm_unlock_item(catalog, name, rev);

            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_LOCK_ITEM:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_LOCK_ITEM\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);

            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "name = %s\n", name);

            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "rev = %s\n", rev);

            *status = dba_nfm_lock_item(catalog, name, rev);

            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_CHANGE_ITEM:
	   
            if (dba_log) fprintf(dba_log,"DBA_NFM_CHANGE_ITEM\n");
            ptr = net_buffer;
            offset = sizeof(long) * 2;	      
	      
            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);
			  
            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "name = %s\n", name);	      
			   
            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "rev = %s\n", rev);	      

            c_name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "c_name = %s\n", c_name);	      

            c_value = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "c_value = %s\n", c_value);	      

            *status = dba_nfm_change_item(catalog, name, rev,
				     c_name, c_value);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
	    *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_CANCEL_SET:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_CANCEL_SET\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);

            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "name = %s\n", name);

            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "rev = %s\n", rev);

            *status = dba_nfm_cancel_set(catalog, name, rev);

            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_ADD_USER_CATALOG:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_ADD_USER_CATALOG\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "name = %s\n", name);

            type = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "type = %s\n", type);

            synonym = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "synonym = %s\n", synonym);

            *status = dba_nfm_add_user_catalog(name, type, synonym);

            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_ADD_USER_ITEM:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_ADD_USER_ITEM\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);
			  
            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "name = %s\n", name);	      
			   
            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "rev = %s\n", rev);	      

            desc = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "desc = %s\n", desc);

	    memcpy(&aclno, ptr + offset, sizeof(short));
            dba_short_swap_bytes (&aclno);
            offset += sizeof(short);

	    memcpy(&versionlimit, ptr + offset, sizeof(short));
            dba_short_swap_bytes (&versionlimit);
            offset += sizeof(short);

	    memcpy(&cisano, ptr + offset, sizeof(short));
            dba_short_swap_bytes (&cisano);
            offset += sizeof(short);

            filename = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "filename = %s\n", filename);

            ci_filename = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "ci_filename = %s\n", filename);	      

            filetype = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "filetype = %s\n", filetype);	      

            *status = dba_nfm_add_user_item(catalog, name, rev, 
                               desc, (int)aclno, (int)versionlimit,
                               (int)cisano, filename, ci_filename, filetype);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_CREATE_USER_CATALOG:
	    
            if (dba_log) fprintf(dba_log,"DBA_CREATE_USER_CATALOG\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);
			  
            desc = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "desc = %s\n", desc);	
      
	    memcpy(&aclno, ptr + offset, sizeof(short));
            dba_short_swap_bytes (&aclno);
	    if (dba_log)
            	fprintf(dba_log, "aclno = %d\n", aclno);
            *status = dba_nfm_create_user_catalog(catalog, desc, (int)aclno);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_ADD_USER_DATA:
	   
            if (dba_log) fprintf(dba_log,"DBA_NFM_ADD_USER_DATA\n");
            ptr = net_buffer;
            offset = sizeof(long) * 2;	      
	      
            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "name = %s\n", name);	      
			   
            c_value = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "c_value = %s\n", c_value);	      

            *status = dba_nfm_add_user_data(name, c_value);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
	    *wcnt = sizeof(long) * 2;
            break;

        case DBA_NFM_DELETE_COPIED_FILE:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_DELETE_COPIED_FILE\n");
            ptr = net_buffer;
            offset = sizeof(long) * 2;
	    
            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);

            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "item_name = %s\n", name);

            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                         "rev = %s\n", rev);

            storage = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                            "storage = %s\n", storage);

            node = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log,
                            "node = %s\n", node);

            user = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log,
                            "user = %s\n", user);

            passwd = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log,
                            "passwd = %s\n", passwd);

            path = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log,
                            "path = %s\n", path);

            filename = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log,
                            "filename = %s\n", filename);

	    memcpy(&versionlimit, ptr + offset, sizeof(short));
            dba_short_swap_bytes (&versionlimit);
            
            if (dba_log) fprintf(dba_log, "version = %hd\n", versionlimit);
            if (dba_log) fflush(dba_log);
            *status = dba_nfm_delete_copied_file(catalog, name, rev, storage,
                node, user, passwd, path, filename, (int)versionlimit);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);
            if (dba_log) fflush(dba_log);
            *wcnt = sizeof(long) * 2;
            break;

        case DBA_NFM_SET_LOCAL_FILE_MANAGER:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_SET_LOCAL_FILE_MANAGER\n");
            ptr = net_buffer;
            offset = sizeof(long) * 2;
	    
	    memcpy(&debug, ptr + offset, sizeof(short));
            dba_short_swap_bytes (&debug);

            if (dba_log) fprintf(dba_log, "state = %hd\n", debug);
            if (dba_log) fflush(dba_log);
            *status = dba_nfm_set_local_file_manager ((int) debug);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);
            if (dba_log) fflush(dba_log);
            *wcnt = sizeof(long) * 2;
            break;

        case DBA_NFM_SET_WORKFLOW:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_SET_WORKFLOW\n");
            ptr = net_buffer;
            offset = sizeof(long) * 2;
	    
	    memcpy(&debug, ptr + offset, sizeof(short));
            dba_short_swap_bytes (&debug);

            if (dba_log) fprintf(dba_log, "state = %hd\n", debug);
            if (dba_log) fflush(dba_log);
            *status = dba_nfm_set_workflow ((int) debug);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);
            if (dba_log) fflush(dba_log);
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_ADD_NODE:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_ADD_NODE\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            node = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "node = %s\n", node);
			  
            desc = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "desc = %s\n", desc);	      
			   
            xns = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "xns = %s\n", xns);	      

            tcp = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "tcp = %s\n", tcp);

            nfs = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "nfs = %s\n", nfs);

            *status = dba_nfm_add_node(node, desc, xns, tcp, nfs);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_CHANGE_NODE:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_CHANGE_NODE\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            node = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "node = %s\n", node);
			  
            c_name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "c_name = %s\n", c_name);	      
			   
            c_value = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "c_value = %s\n", c_value);	      

            *status = dba_nfm_change_node(node, c_name, c_value);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_DELETE_NODE:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_DELETE_NODE\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            node = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "node = %s\n", node);
			  
            *status = dba_nfm_delete_node(node);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

	case DBA_NFM_CHANGE_STORAGE_AREA:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_CHANGE_STORAGE_AREA\n");

            ptr = net_buffer;
            offset = sizeof(long) * 2;

            storage = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "storage = %s\n", storage);
			  
            c_name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "c_name = %s\n", c_name);	      
			   
            c_value = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "c_value = %s\n", c_value);	      

            *status = dba_nfm_change_storage_area(storage, c_name, c_value);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

        case DBA_NFM_PLOT_ITEM:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_PLOT_ITEM\n");
            ptr = net_buffer;
            offset = sizeof(long) * 2;	      

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);
			  
            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "name = %s\n", name);	      
			   
            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "rev = %s\n", rev);	      

            *status = dba_nfm_plot_item(catalog, name, rev);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

        case DBA_NFM_PLOT_SET:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_PLOT_SET\n");
            ptr = net_buffer;
            offset = sizeof(long) * 2;	      

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);
			  
            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "name = %s\n", name);	      
			   
            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "rev = %s\n", rev);	      

            *status = dba_nfm_plot_set(catalog, name, rev);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

        case DBA_NFM_SAVE_ITEM:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_SAVE_ITEM\n");
            ptr = net_buffer;
            offset = sizeof(long) * 2;	      

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);
			  
            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "name = %s\n", name);	      
			   
            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "rev = %s\n", rev);	      

            *status = dba_nfm_save_item(catalog, name, rev);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

        case DBA_NFM_SAVE_SET:
	    
            if (dba_log) fprintf(dba_log,"DBA_NFM_SAVE_SET\n");
            ptr = net_buffer;
            offset = sizeof(long) * 2;	      

            catalog = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                          "catalog = %s\n", catalog);
			  
            name = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "name = %s\n", name);	      
			   
            rev = ptr + offset;
            length = strlen(ptr + offset) + 1;
            offset += length;
            if (dba_log) fprintf(dba_log, 
                           "rev = %s\n", rev);	      

            *status = dba_nfm_save_set(catalog, name, rev);
            if (dba_log) fprintf(dba_log, "status = %d\n", *status);	      
            *wcnt = sizeof(long) * 2;
            break;

        default:
            return(-1);
    }	      
    return(0);
}

