#include <stdio.h>
#include <string.h>
#include <sys/types.h> /* JAS Added to make temp directory */
#include <sys/stat.h>


#include "NFTproto.h"
#include "NFTtypes.h"
#include "NFMerrordef.h"
#include "iftr.h"
#include "iftrp.h"
#include "UTIerrordef.h"
#include "DEBUG.h"
#include "ERR.h"

#define CpN						(char*)NULL
#define COL_NAME_LEN			64
#define ITEMNO_SLOT			66
#define FILENO_SLOT			67
#define KEYWORD_SLOT			80

#define FTR_INTUITIVE 0
#define FTR_REGULAR 1

extern char *strdup();
extern char *tempnam();

FILE *NFTdbg=(FILE *)NULL;
long NFT_ftr_started=0;
char *NFT_col_node=CpN;
char *NFT_col_dir=CpN;
char NFT_options_file[64];
char *NFT_thesaurus_list=CpN;

long NFT_use_gate=1;
long NFT_gate_open=2;
long NFT_lock_wait=1;
long NFT_add_timeout=0;
long NFT_index_timeout=0;
long NFT_save_errors=0;
long NFT_delayed=0;

typedef struct _NFT_pending_rcd {
	char col[COL_NAME_LEN];
	long cid;
	long used;
	struct _NFT_pending_rcd *next;
	} NFT_pending_rcd;

NFT_pending_rcd *NFT_pending=(NFT_pending_rcd *)NULL;

long NFT_close()
{
	unlink(NFT_options_file);
	FTR_terminate();
	return(UTI_S_SUCCESS);
}


long NFT_init(node,dir)
	char *node;
	char *dir;
{
char work[256];
char hold[256];
long size;
FILE *fp;
long netid=-1;

	if (!node || !node[0] || !dir || !dir[0]) {
		ERRload_struct(UTI,UTI_E_INIT_PARAM,"",NULL);
		return(UTI_E_INIT_PARAM);
		}

	if (NFT_ftr_started) {
		if (NFT_col_node) free(NFT_col_node);
		if (NFT_col_dir) free(NFT_col_dir);
		NFT_prepare_collection((-1),0);
		unlink(NFT_options_file);
		}
	else {
		if (!access("/usr/tmp/turnonnft.dbg",00)) {
			sprintf(work,"/usr/tmp/nft_%d.dbg",getpid());
			NFTdbg=fopen(work,"w");
			setbuf(NFTdbg,0);
			}
		if (!access("/usr/tmp/turnonftr.dbg",00)) {
			sprintf(work,"/usr/tmp/ftr_%d.dbg",getpid());
			FTRdbg_open_file(work);
			FTR_set_debug_level(3);
			}
		if (!access("/usr/ip32/nfm/config/ftr.config",04) /* read configuration */
						&& (fp=fopen("/usr/ip32/nfm/config/ftr.config","r"))) {
			while (fgets(work,255,fp)) {
				if (!strncmp("INDEX_TIMEOUT=",work,14))
					NFT_index_timeout=atol(&work[14]);
				else if (!strncmp("ADD_TIMEOUT=",work,12))
					NFT_add_timeout=atol(&work[12]);
				else if (!strncmp("GATE_OPEN=",work,10))
					NFT_gate_open=atol(&work[10]);
				else if (!strncmp("LOCK_WAIT=",work,10))
					NFT_lock_wait=atol(&work[10]);
				else if (!strncmp("USE_GATE=",work,9))
					NFT_use_gate=atol(&work[9]);
				else if (!strncmp("SAVE_ERRORS=",work,12))
					NFT_save_errors=atol(&work[12]);
				else if (!strncmp("DELAYED=",work,8))
					NFT_delayed=atol(&work[8]);
				else if (!strncmp("DISABLE_FTR=",work,12) && atol(&work[12]))
					return(UTI_E_INIT_PARAM);
				}
			fclose(fp);
			}
		}

	NFT_col_node=strdup(node);
	NFT_col_dir=strdup(dir);
	if (!NFT_col_node || !NFT_col_dir) {
		ERRload_struct(UTI,UTI_E_MALLOC,"",NULL);
		return(UTI_E_MALLOC);
		}

	sprintf(work,"FULPATH=");
	putenv(strdup(work));
	sprintf(work,"FULTEMP=/usr/tmp");
	putenv(strdup(work));
	sprintf(work,"FTNPATH=%s/tcp",NFT_col_node);
	putenv(strdup(work));
	if(!NFT_ftr_started && FTR_enter()!=FTR_S_SUCCESS) {
		ERRload_struct(UTI,UTI_E_INIT_PARAM,"",NULL);
		return(UTI_E_INIT_PARAM);
		}
	else
		NFT_ftr_started=1;

	FTR_set_logical_operators("AND","OR","NOT");

/* create us an options file */
	strcpy(NFT_options_file,tempnam("/usr/tmp",".opts"));
	fp=fopen(NFT_options_file,"w");
	if (!fp) {
		ERRload_struct(UTI,UTI_E_INIT_FTR,"",NULL);
		return(UTI_E_INIT_FTR);
		}
	fprintf(fp,"-q -l/usr/tmp/ftserver.log -p/usr/ip32/ftrrt/config:%s -ftcp=0 -unfmadmin\n",dir);
	fclose(fp);

/* retrieve the thesaurus file list */
	if (NFT_thesaurus_list) free(NFT_thesaurus_list);
	NFT_thesaurus_list=CpN;
	strcpy(work,tempnam("/usr/tmp",".thes"));
	if (NFMftr_options_file_lock(node,"root","",NFT_options_file
											,"/usr/ip32/ftrrt/config/ftserver.opt"
											,"/usr/ip32/ftrrt/config/ftserver.bak"
											,&netid,1)==NFM_S_SUCCESS) {
		NFMftr_options_file_unlock("/usr/ip32/ftrrt/config/ftserver.bak"
											,"/usr/ip32/ftrrt/config/ftserver.opt"
											,&netid,1);
		sprintf(hold,"%s/thesaurus.list",NFT_col_dir);
		NFMfile_receive(hold,work,CpN,&size,&netid);
		NFMdisconnect(&netid);
		fp=fopen(work,"r");
		if (fp) {
			size=0;
			while (fgets(hold,255,fp)) size+=strlen(hold);
			rewind(fp);
			NFT_thesaurus_list=(char*)malloc((size+10)*sizeof(char));
			memset(NFT_thesaurus_list,0,size+10);
			if (!NFT_thesaurus_list) {
				fclose(fp);
				unlink(work);
				ERRload_struct(UTI,UTI_E_INIT_FTR,"",NULL);
				return(UTI_E_INIT_FTR);
				}
			while (fgets(hold,255,fp)) strcat(NFT_thesaurus_list,hold);
			fclose(fp);
			unlink(work);
			}
		}
	else {
		ERRload_struct(UTI,UTI_E_INIT_FTR,"",NULL);
		return(UTI_E_INIT_FTR);
		}

	return(UTI_S_SUCCESS);
}


long NFT_prepare_collection(cno,flag)
	long cno;
	long flag;
{
/* Added for debugging - Jujare, 4th Dec 1995 */
char *fname="NFT_prepare_collection";
 
static long old_cno=0;
char name[COL_NAME_LEN];
long sts;
long size;
long locked=0;
char work[256];
char hold[256];
long netid=-1;
 /* JAS Added so collection will not be in /usr/tmp, possible over ride
There is a small chance that two user could try to write to the same collection since they both get stored in /usr/tmp. I added a temp directory name for each collection named so this should not happen. This is in response to TR249407226 */
mode_t _mode=0000777;
char temp_dir[256]; 
/* tmpnam() and mkdir() calls were originally here - PS 11th Oct, 95
   Relocated to take care of TR# 249505476  */


	if (!NFT_ftr_started) {
		ERRload_struct(UTI,UTI_E_INIT,"",NULL);
		return(UTI_E_INIT);
		}

	if (cno==(-1)) { /* clear out stored stuff */
		sprintf(name,"%d@%s",old_cno,NFT_col_node);
		FTRcol_deactivate(name);
		old_cno=0;
		}

	if (old_cno==cno) return(UTI_S_SUCCESS);

	if (!old_cno) {
		NFMftr_options_file_lock(NFT_col_node,"root","",NFT_options_file
											,"/usr/ip32/ftrrt/config/ftserver.opt"
											,"/usr/ip32/ftrrt/config/ftserver.bak"
											,&netid,0);
		locked=1;
		}

	if (flag && old_cno && cno!=old_cno) {
		sprintf(name,"%d@%s",old_cno,NFT_col_node);
		FTRcol_deactivate(name);
		}

	sprintf(name,"%d@%s",cno,NFT_col_node);
/* PS IGI 11th Oct 95 */
	tmpnam(temp_dir); 
        _NFMdebug((fname,"Doing mkdir  %s \n",temp_dir));
        mkdir(temp_dir,_mode);

	if (!FTRcol_access(name,0L)) {
		if (!access("/usr/ip32/nfm/config/default.stp",00)) {
			sprintf(work,"%s/%d.stp",temp_dir,cno);
			link("/usr/ip32/nfm/config/default.stp",work);
			sprintf(work,"%d.stp",cno);
			FTR_set_stopword_file(work);
			}
		sprintf(work,"%s/%d",temp_dir,cno);
		if (FTRcol_create(work,FTR_RECREATE|FTR_SHARE)==FTR_S_SUCCESS) {
			if (old_cno) {
				NFMftr_options_file_lock(NFT_col_node,"root","",NFT_options_file
													,"/usr/ip32/ftrrt/config/ftserver.opt"
													,"/usr/ip32/ftrrt/config/ftserver.bak"
													,&netid,1);
				locked=1;
				}
/* 7/28/94 added check to see if collection already exists on that node */
			sprintf(work,"%s/%d.tst",temp_dir,cno);
			sprintf(hold,"%s/%d.cfg",NFT_col_dir,cno);
			NFMfile_receive(hold,work,CpN,&size,&netid);
			if (!access(work,00)) { /* collection exists, lets exit */
				unlink(work);
				sprintf(work,"%s/%d.cfg",temp_dir,cno);
				unlink(work);
				sprintf(work,"%s/%d.log",temp_dir,cno);
				unlink(work);
				sprintf(work,"%s/%d.cat",temp_dir,cno);
				unlink(work);
				sprintf(work,"%s/%d.cix",temp_dir,cno);
				unlink(work);
				sprintf(work,"%s/%d.dct",temp_dir,cno);
				unlink(work);
				sprintf(work,"%s/%d.ref",temp_dir,cno);
				unlink(work);
				sprintf(work,"%s/%d.stp",temp_dir,cno);
				unlink(work);
				}
			else { /* collection does not exits, lets send one */

				sprintf(work,"%s/%d.cfg",temp_dir,cno);
				sprintf(hold,"%s/%d.cfg",NFT_col_dir,cno);
				NFMfile_send(work,hold,CpN,&size,&netid,0);
				unlink(work);
	
				sprintf(work,"%s/%d.log",temp_dir,cno);
				sprintf(hold,"%s/%d.log",NFT_col_dir,cno);
				NFMfile_send(work,hold,CpN,&size,&netid,0);
				unlink(work);
	
				sprintf(work,"%s/%d.cat",temp_dir,cno);
				sprintf(hold,"%s/%d.cat",NFT_col_dir,cno);
				NFMfile_send(work,hold,CpN,&size,&netid,0);
				unlink(work);
	
				sprintf(work,"%s/%d.cix",temp_dir,cno);
				sprintf(hold,"%s/%d.cix",NFT_col_dir,cno);
				NFMfile_send(work,hold,CpN,&size,&netid,0);
				unlink(work);
	
				sprintf(work,"%s/%d.dct",temp_dir,cno);
				sprintf(hold,"%s/%d.dct",NFT_col_dir,cno);
				NFMfile_send(work,hold,CpN,&size,&netid,0);
				unlink(work);
	
				sprintf(work,"%s/%d.ref",temp_dir,cno);
				sprintf(hold,"%s/%d.ref",NFT_col_dir,cno);
				NFMfile_send(work,hold,CpN,&size,&netid,0);
				unlink(work);
	
				sprintf(work,"%s/%d.stp",temp_dir,cno);
				if (!access(work,00)) {
					sprintf(hold,"%s/%d.stp",NFT_col_dir,cno);
					NFMfile_send(work,hold,CpN,&size,&netid,0);
					unlink(work);
					}
				}
			}
		}

/* PS - 11th Oct 95 */
        _NFMdebug((fname,"Doing rmdir  %s \n",temp_dir));
	rmdir(temp_dir);

	sts=FTRcol_activate(name);

	if (locked)
		NFMftr_options_file_unlock("/usr/ip32/ftrrt/config/ftserver.bak"
											,"/usr/ip32/ftrrt/config/ftserver.opt"
											,&netid,0);
	if (sts!=FTR_S_SUCCESS) {
		ERRload_struct(UTI,UTI_E_OPENING_COL,"",NULL);
		return(UTI_E_OPENING_COL);
		}
	else {
		old_cno=cno;
		return(UTI_S_SUCCESS);
		}
/* rmdir() call were originally here. Relocated to take care of TR# 249505476
   - PS 11th Oct 95 */
}


long NFT_write_key_file(cno,ino,fno,keywords)
	long cno;
	long ino;
	long fno;
	char *keywords;
{
long netid=-1;
long size;
FILE *fp;
char work[256];
char hold[256];

	sprintf(work,"/usr/tmp/%d.%d.%d",cno,ino,fno);
	if (!(fp=fopen(work,"w"))) return(!UTI_S_SUCCESS);
	fprintf(fp,"%s\n",keywords);
	fclose(fp);

	if (NFMftr_options_file_lock(NFT_col_node,"root","",NFT_options_file
											,"/usr/ip32/ftrrt/config/ftserver.opt"
											,"/usr/ip32/ftrrt/config/ftserver.bak"
											,&netid,1)==NFM_S_SUCCESS) {
		NFMftr_options_file_unlock("/usr/ip32/ftrrt/config/ftserver.bak"
											,"/usr/ip32/ftrrt/config/ftserver.opt"
											,&netid,1);
		sprintf(hold,"%s/.keys/%d.%d.%d",NFT_col_dir,cno,ino,fno);
		NFMfile_send(work,hold,CpN,&size,&netid,0);
		NFMdisconnect(&netid);
		unlink(work);
		return(UTI_S_SUCCESS);
		}
	else {
		unlink(work);
		return(!UTI_S_SUCCESS);
		}
}


long NFT_setup_search(search,qry)
	char *search;
	char **qry;
{
char *s,*e;
long ctf;
long i;
long j;
static char *srch=NULL;

	if (!NFT_ftr_started) {
		ERRload_struct(UTI,UTI_E_INIT,"",NULL);
		return(UTI_E_INIT);
		}

	if (srch) free(srch);
	s=srch=strdup(search);
	if (!srch) {
		ERRload_struct(UTI,UTI_E_MALLOC,"",NULL);
		return(UTI_E_MALLOC);
		}

	for (i=0;;i++) {
		if (!(j=ctf=atol(s)) && *s!='0') {
			ERRload_struct(UTI,UTI_E_SEARCH_FORMAT,"",NULL);
			return(UTI_E_SEARCH_FORMAT);
			}
		s+=2;while ((j=j/10)) s++;
		if (strlen(s)<ctf) {
			ERRload_struct(UTI,UTI_E_SEARCH_FORMAT,"",NULL);
			return(UTI_E_SEARCH_FORMAT);
			}
		e=s+ctf; *e=0;
		switch (i) {
			case 0: /* query string */
				*qry=s;
				break;
			case 1: /* proximity setting */
				FTR_set_proximity(atol(s));
				break;
			case 2: /* search mode, 0-regular, 1-intuitive */
/*
				if (atol(s)) 
					FTR_set_search_mode(FTR_INTUITIVE);
				else 
					FTR_set_search_mode(FTR_REGULAR);
*/
				break;
			case 3: /* keywords enabled, 0-no, 1-yes */
				if (atol(s))
					FTR_enable_zones(KEYWORD_SLOT,81L,0L);
				else {
					FTR_disable_zone(KEYWORD_SLOT);
					FTR_disable_zone(81L);
					}
				break;
			case 4: /* root expansion, 0-off, 1-on */
				if (atol(s))
					FTR_enable_word_root_expansion();
				else
					FTR_disable_word_root_expansion();
				break;
			case 5: /* thesaurus file */
				if (*s) {
					FTR_set_thesaurus_file(s);
					FTR_enable_thesaurus();
					}
				else {
					FTR_disable_thesaurus();
					}
				break;
			case 6: /* fuzzy logic, 0-off, 1-on */
				if (atol(s))
					FTR_set_search_mode(FTR_FUZZY);
				else
					FTR_set_search_mode(FTR_BOOLEAN);
				return(UTI_S_SUCCESS);
			}
		s=e+1;
		}
}


long NFT_get_cid(col,ino,fno,cid)
	char *col;
	long ino;
	long fno;
	long *cid;
{
long sts;
char work[128];

	*cid=0;
	sprintf(work,"{prox} ({zone %d} %d) & ({zone %d} %d)",ITEMNO_SLOT,ino,FILENO_SLOT,fno);

	if (FTRcol_search(col,work)<=0) {
		ERRload_struct(UTI,UTI_W_NO_HITS,"",NULL);
		return(UTI_W_NO_HITS);
		}

	sts=FTR_get_cid_count(col);

	if (sts>1) {
		ERRload_struct(UTI,UTI_F_COL_INTEGRITY,"",NULL);
		return(UTI_F_COL_INTEGRITY);
		}

	if (FTR_get_cid_list(col,work,&sts)!=FTR_S_SUCCESS || !(*cid=atol(work))) {
		ERRload_struct(UTI,UTI_E_DATA_TRANSFER,"",NULL);
		return(UTI_E_DATA_TRANSFER);
		}
	
	return(UTI_S_SUCCESS);
}


long NFT_get_cid_list(col,search,list)
	char *col;
	char *search;
	char **list;
{
long sts;

	*list=CpN;

	if (FTRcol_search(col,search)<=0) {
		ERRload_struct(UTI,UTI_W_NO_HITS,"",NULL);
		return(UTI_W_NO_HITS);
		}

	sts=FTR_get_cid_count(col);
	if (!sts) {
		ERRload_struct(UTI,UTI_W_NO_HITS,"",NULL);
		return(UTI_W_NO_HITS);
		}

	*list=(char*)malloc(sts*10*sizeof(char));
	if (!*list) {
		ERRload_struct(UTI,UTI_E_MALLOC,"",NULL);
		return(UTI_E_MALLOC);
		}

	if (FTR_get_cid_list(col,*list,&sts)!=FTR_S_SUCCESS) {
		ERRload_struct(UTI,UTI_E_DATA_TRANSFER,"",NULL);
		return(UTI_E_DATA_TRANSFER);
		}
	
	return(UTI_S_SUCCESS);
}


long NFT_get_thesaurus_list(list)
	char *list;
{
	if (NFT_thesaurus_list) strcpy(list,NFT_thesaurus_list);
	else list[0]=0;
	return(UTI_S_SUCCESS);
}


long NFT_index(cno)
	long cno;
{
long sts;
char col[COL_NAME_LEN];
long timeout;
long some_left;
struct FTR_catalog_record rcd;
NFT_pending_rcd *pen;
char work[256];
char *keywords;
long ino,fno;

	if (NFT_delayed) return(UTI_S_SUCCESS);

	if ((sts=NFT_prepare_collection(cno,1L))!= UTI_S_SUCCESS) {
		ERRload_struct(UTI,sts,"",NULL);
		return(sts);
		}

	sprintf(col,"%d@%s",cno,NFT_col_node);

   if (NFT_index_timeout) timeout=time(0)+NFT_index_timeout;

	if (NFTdbg) fprintf(NFTdbg,"starting index process\n");

   while ((sts=FTRcol_index(col,FTR_NOCATCHECK|FTR_RESETLOG))
															==FTR_E_INDEX_IS_BUSY) {
		if (NFTdbg) fprintf(NFTdbg,"\twaiting\n");
		pen=NFT_pending; some_left=0;
		while (pen) {
			if (pen->used && !strcmp(col,pen->col)) {
	      	FTRcat_get_record(col,pen->cid,&rcd);
      		if (rcd._Status) {
					some_left=1;
					break;
        		 	}
				else
					pen->used=0;
				}
			pen=pen->next;
			}

		if (!some_left) {
			if (NFTdbg) fprintf(NFTdbg,"all my pendings have been indexed\n");
			return(UTI_S_SUCCESS);
			}

      if (NFT_index_timeout && time(0)>timeout) {
			pen=NFT_pending;
			while (pen) {
				if (pen->used && !strcmp(col,pen->col)) {
					FTRdbg_print(1,"<NFM> Index Timeout - cid <%d>",pen->cid);
					if (NFT_save_errors) {
						FTRcol_get_field(col,pen->cid,ITEMNO_SLOT,work);
						ino=atol(work);
						FTRcol_get_field(col,pen->cid,FILENO_SLOT,work);
						fno=atol(work);
						FTRcat_dup_field(col,pen->cid,KEYWORD_SLOT,&keywords);
						NFT_write_key_file(cno,ino,fno,keywords);
						free(keywords);
						}
					}
				pen=pen->next;
				}
			if (NFTdbg) fprintf(NFTdbg,"indexing timed out\n");
			ERRload_struct(UTI,UTI_E_INDEX,"",NULL);
			return(UTI_E_INDEX);
         }

      sleep(NFT_lock_wait);
		FTRcol_unlock(col);
      }

	if (sts==FTR_S_SUCCESS) {
		if (NFTdbg) fprintf(NFTdbg,"I did the indexing successfully\n");
		return(UTI_S_SUCCESS);
		}
	else {
		if (NFTdbg) fprintf(NFTdbg,"My indexing failed: sts %d\n",sts);
		if (NFTdbg) fprintf(NFTdbg,"\tFTR msg <%s>\n",FTRmsg_get());
		ERRload_struct(UTI,UTI_E_INDEX,"",NULL);
		return(UTI_E_INDEX);
		}
}


long NFT_start_group()
{
NFT_pending_rcd *pen;

	pen=NFT_pending;
	while (pen) {
		pen->used=0;
		pen=pen->next;
		}
	if (NFTdbg) fprintf(NFTdbg,"\n--- starting group ---\n");
	return(UTI_S_SUCCESS);
}


long NFT_add_file(cno,ino,fno,file,type,keywords)
	long cno;
	long ino;
	long fno;
	char *file;
	long type;
	char *keywords;
{
long sts;
long cid;
char col[COL_NAME_LEN];
char work[32];
char *filter;
NFT_pending_rcd *pen;
long timeout;

	if (NFT_delayed) {
		if (NFT_write_key_file(cno,ino,fno,keywords)==UTI_S_SUCCESS)
			return(UTI_S_SUCCESS);
		else {
			ERRload_struct(UTI,UTI_E_ADD_FILE,"",NULL);
			return(UTI_E_ADD_FILE);
			}
		}

	if ((sts=NFT_prepare_collection(cno,1L))!= UTI_S_SUCCESS) {
		if (NFT_save_errors) NFT_write_key_file(cno,ino,fno,keywords);
		ERRload_struct(UTI,sts,"",NULL);
		return(sts);
		}

	switch (type) {
		case TEXT_TYPE: /*text*/
			filter="s"; break;
		case IGDS_TYPE: /*igds*/
			filter="igds"; break;
		case AUTOCAD_TYPE:
			filter="acad"; break;
		case MSWORD_TYPE:
			filter="ww/s"; break;
		case WORDPERFECT_TYPE:
			filter="wp/s"; break;
		case WORDSTAR_TYPE:
			filter="ws"; break;
		case WORDMARC_TYPE:
			filter="mc"; break;
		case QONE_TYPE:
			filter="q"; break;
                case NON_INDEXABLE:
                        filter="null"; break;
		default:
			if (NFT_save_errors) NFT_write_key_file(cno,ino,fno,keywords);
			ERRload_struct(UTI,UTI_F_FILE_TYPE,"",NULL);
			return(UTI_F_FILE_TYPE);
		}

	sprintf(col,"%d@%s",cno,NFT_col_node);

	if (NFT_add_timeout) timeout=time(0)+NFT_add_timeout;
	if (NFT_use_gate)
		while (FTRcol_is_locked(col)) {
			FTRcol_unlock(col);
			if (NFT_add_timeout && time(0)>timeout) {
				FTRdbg_print(1,"<NFM> Add Timeout - ino <%d> fno <%d>",ino,fno);
				if (NFT_save_errors) NFT_write_key_file(cno,ino,fno,keywords);
				if (NFTdbg) fprintf(NFTdbg,"add timed out\n");
				ERRload_struct(UTI,UTI_E_ADD_FILE,"",NULL);
				return(UTI_E_ADD_FILE);
				}
			sleep(NFT_lock_wait);
			}

	if ((sts=FTRcol_add_file(col,file,filter,&cid))!=FTR_S_SUCCESS || !cid) {
		if (NFT_save_errors) NFT_write_key_file(cno,ino,fno,keywords);
		if (NFTdbg) fprintf(NFTdbg,"add failed, sts %d\n",sts);
		if (NFTdbg) fprintf(NFTdbg,"\tFTR msg<%s>\n",FTRmsg_get());
		ERRload_struct(UTI,UTI_E_ADD_FILE,"",NULL);
		return(UTI_E_ADD_FILE);
		}
	if (NFTdbg) fprintf(NFTdbg,"added file, cid %d\n",cid);

	pen=NFT_pending;
	while (pen && pen->used) pen=pen->next;
	if (!pen) {
		pen=(NFT_pending_rcd *)malloc(sizeof(NFT_pending_rcd));
		if (!pen) {
			if (NFT_save_errors) NFT_write_key_file(cno,ino,fno,keywords);
			ERRload_struct(UTI,UTI_E_ADD_FILE,"",NULL);
			return(UTI_E_ADD_FILE);
			}
		pen->next=NFT_pending;
		NFT_pending=pen;
		}
	pen->used=1;
	strcpy(pen->col,col);
	pen->cid=cid;
	if (NFTdbg) fprintf(NFTdbg,"added pending entry.\n",cid);

	sprintf(work,"%d",ino);
	if (FTRcat_set_field(col,cid,ITEMNO_SLOT,work)!=FTR_S_SUCCESS) {
		if (NFT_save_errors) NFT_write_key_file(cno,ino,fno,keywords);
		ERRload_struct(UTI,UTI_E_ADD_ITEMNO,"",NULL);
		return(UTI_E_ADD_ITEMNO);
		}

	sprintf(work,"%d",fno);
	if (FTRcat_set_field(col,cid,FILENO_SLOT,work)!=FTR_S_SUCCESS) {
		if (NFT_save_errors) NFT_write_key_file(cno,ino,fno,keywords);
		ERRload_struct(UTI,UTI_E_ADD_FILENO,"",NULL);
		return(UTI_E_ADD_FILENO);
		}

	if (keywords && FTRcat_set_field(col,cid,KEYWORD_SLOT,keywords)
																		!=FTR_S_SUCCESS) {
		if (NFT_save_errors) NFT_write_key_file(cno,ino,fno,keywords);
		ERRload_struct(UTI,UTI_E_ADD_KEYWORDS,"",NULL);
		return(UTI_E_ADD_KEYWORDS);
		}
	if (NFTdbg) fprintf(NFTdbg,"updated fields.\n");

	return(UTI_S_SUCCESS);
}


long NFT_get_keywords(cno,ino,fno,keywords)
	long cno;
	long ino;
	long fno;
	char **keywords;
{
long sts;
long cid;
char col[COL_NAME_LEN];

	*keywords=CpN;
	if ((sts=NFT_prepare_collection(cno,1L))!= UTI_S_SUCCESS) {
		ERRload_struct(UTI,sts,"",NULL);
		return(sts);
		}

	sprintf(col,"%d@%s",cno,NFT_col_node);

	if ((sts=NFT_get_cid(col,ino,fno,&cid))!= UTI_S_SUCCESS) {
		ERRload_struct(UTI,sts,"",NULL);
		return(sts);
		}

	if (FTRcat_dup_field(col,cid,KEYWORD_SLOT,keywords)!=FTR_S_SUCCESS) {
		ERRload_struct(UTI,UTI_E_DATA_TRANSFER,"",NULL);
		return(UTI_E_DATA_TRANSFER);
		}

	return(UTI_S_SUCCESS);
}


long NFT_delete_entry(cno,ino,fno)
	long cno;
	long ino;
	long fno;
{
long sts;
long cid;
char col[COL_NAME_LEN];

	if ((sts=NFT_prepare_collection(cno,1L)) != UTI_S_SUCCESS) {
		ERRload_struct(UTI,sts,"",NULL);
		return(sts);
		}

	sprintf(col,"%d@%s",cno,NFT_col_node);

	if ((sts=NFT_get_cid(col,ino,fno,&cid)) != UTI_S_SUCCESS) {
		ERRload_struct(UTI,sts,"",NULL);
		return(sts);
		}

	if (FTRcol_delete_cid(col,cid)!=FTR_S_SUCCESS) {
		ERRload_struct(UTI,UTI_E_DELETE_FILE,"",NULL);
		return(UTI_E_DELETE_FILE);
		}

	return(UTI_S_SUCCESS);
}


long NFT_delete_item(cno,ino)
	long cno;
	long ino;
{
long sts;
char col[COL_NAME_LEN];
char work[64];
char *list;
char *s;

	if ((sts=NFT_prepare_collection(cno,1L)) != UTI_S_SUCCESS) {
		ERRload_struct(UTI,sts,"",NULL);
		return(sts);
		}

	sprintf(col,"%d@%s",cno,NFT_col_node);
	sprintf(work,"{zone %d} %d",ITEMNO_SLOT,ino);

	if ((sts=NFT_get_cid_list(col,work,&list)) != UTI_S_SUCCESS) {
		ERRload_struct(UTI,sts,"",NULL);
		return(sts);
		}
	
	sts=0;
	if (list) for (s=list;s;s=strchr(s,'\t')) {
		if (s!=list) s++; 
		if (FTRcol_delete_cid(col,atol(s))!=FTR_S_SUCCESS) {
			sts=UTI_E_DELETE_FILE;
			break;
			}
		}
/* ******Inserted For Word Wheel Problem By M.S.R on 15/9/95 ********   */
        if ((sts=NFT_index(cno)) != UTI_S_SUCCESS){
                return(sts);
        }
/*   *********************************************************** */
	if (list) free(list);
	ERRload_struct(UTI,sts,"",NULL);
	return(sts);
}


long NFT_delete_collection(cno)
	long cno;
{
char col[COL_NAME_LEN];

	FTR_deactivate_all_collections();

	sprintf(col,"%d@%s",cno,NFT_col_node);

	if (FTRcol_delete(col,NULL)!=FTR_S_SUCCESS) {
		ERRload_struct(UTI,UTI_E_DELETE_COL,"",NULL);
		return(UTI_E_DELETE_COL);
		}

	return(UTI_S_SUCCESS);
}


long NFT_get_word_wheel(clist,start,count,words)
	char *clist;
	char *start;
	long count;
	char **words;
{
long sts;
char *s;
char work[64];
long hold;

	*words=CpN;
	for (s=clist;s;s=strchr(s,' ')) {
		if (s!=clist) s++; if (!(*s) || !atol(s)) continue;
		if (s==clist) {
			if ((sts=NFT_prepare_collection(atol(s),1L)) != UTI_S_SUCCESS) {
				ERRload_struct(UTI,sts,"",NULL);
				return(sts);
				}
			}
		else {
			if ((sts=NFT_prepare_collection(atol(s),0L)) != UTI_S_SUCCESS) {
				ERRload_struct(UTI,sts,"",NULL);
				return(sts);
				}
			}
		hold=atol(s);
		}

	FTR_enable_zones(KEYWORD_SLOT,81L,0L);

	sprintf(work,"%s+%d",start,count);
	sts=FTR_dup_word_list(work,words);

	/* reset the state */
	FTR_disable_zone(KEYWORD_SLOT);
	FTR_disable_zone(81L);
	FTR_deactivate_all_collections();
	sprintf(work,"%d@%s",hold,NFT_col_node);
	FTRcol_activate(work);

	if (sts<=0) {
		ERRload_struct(UTI,UTI_E_WORD_LIST,"",NULL);
		return(UTI_E_WORD_LIST);
		}

	return(UTI_S_SUCCESS);
}


long NFT_get_preview(clist,search,result)
	char *clist;
	char *search;
	char **result;
{
long sts;
char *s;
char *qry;
char col[COL_NAME_LEN];
char work[64];

	if ((sts=NFT_setup_search(search,&qry)) != UTI_S_SUCCESS) {
		ERRload_struct(UTI,sts,"",NULL);
		return(sts);
		}

	*result=(char*)malloc((sts=((strlen(clist)/2)*10+strlen(clist))*sizeof(char)));
	if (!(*result)) {
		ERRload_struct(UTI,UTI_E_MALLOC,"",NULL);
		return(UTI_E_MALLOC);
		}
	memset(*result,0,sts);

	for (s=clist;s;s=strchr(s,' ')) {
		if (s!=clist) s++; if (!(*s) || !atol(s)) continue;
		if ((sts=NFT_prepare_collection(atol(s),1L)) != UTI_S_SUCCESS) {
			ERRload_struct(UTI,sts,"",NULL);
			return(sts);
			}
		sprintf(col,"%d@%s",atol(s),NFT_col_node);
		sts=FTRcol_search(col,qry);
		if (sts>0) 
			sts=FTR_get_cid_count(col);
		if (sts<0) sts=0;
		sprintf(work,"%d %d;",atol(s),sts);
		strcat(*result,work);
		}

	return(UTI_S_SUCCESS);
}


long NFT_ftr_search(cno,search,inos,fnos)
	long cno;
	char *search;
	char **inos;
	char **fnos;
{
long sts;
char *qry;
char *list;
char col[COL_NAME_LEN];
char work[64];
char hold[16];
char *s;

	*inos=*fnos=CpN;
	if ((sts=NFT_setup_search(search,&qry)) != UTI_S_SUCCESS) {
		ERRload_struct(UTI,sts,"",NULL);
		return(sts);
		}

	if ((sts=NFT_prepare_collection(cno,1L)) != UTI_S_SUCCESS) {
		ERRload_struct(UTI,sts,"",NULL);
		return(sts);
		}

	sprintf(col,"%d@%s",cno,NFT_col_node);

	if ((sts=NFT_get_cid_list(col,qry,&list)) != UTI_S_SUCCESS) {
		ERRload_struct(UTI,sts,"",NULL);
		return(sts);
		}

	if (list) {
		sts=(strlen(list)/2)*sizeof(char)*8;
		*inos=(char*)malloc(sts);
		if (!(*inos)) {
			free(list);
			ERRload_struct(UTI,UTI_E_MALLOC,"",NULL);
			return(UTI_E_MALLOC);
			}
		memset(*inos,0,sts);


		*fnos=(char*)malloc(sts);
		if (!(*fnos)) {
			free(list);free(*inos);*inos=CpN;
			ERRload_struct(UTI,UTI_E_MALLOC,"",NULL);
			return(UTI_E_MALLOC);
			}
		memset(*fnos,0,sts);

		sts=UTI_S_SUCCESS;
		for (s=list;s;s=strchr(s,'\t')) {
			if (s!=list) s++; if (!(*s) || !atol(s)) continue;
			if (FTRcol_get_field(col,atol(s),ITEMNO_SLOT,work)!=FTR_S_SUCCESS) {
				sts=UTI_E_DATA_TRANSFER;
				break;
				}
			sprintf(hold,"%d,",atol(work));
			strcat(*inos,hold);
			if (FTRcol_get_field(col,atol(s),FILENO_SLOT,work)!=FTR_S_SUCCESS) {
				sts=UTI_E_DATA_TRANSFER;
				break;
				}
			sprintf(hold,"%d,",atol(work));
			strcat(*fnos,hold);
			}
		}

	if (sts!=UTI_S_SUCCESS) {
		free(*inos); *inos=CpN;
		free(*fnos); *fnos=CpN;
		}
	else {
		(*inos)[strlen(*inos)-1]=0;
		(*fnos)[strlen(*fnos)-1]=0;
		}

	if (list) free(list);
	ERRload_struct(UTI,sts,"",NULL);
	return(sts);
}


long NFT_gen_highlight(cno,search,ino,fno,buffer)
	long cno;
	char *search;
	long ino;
	long fno;
	char **buffer;
{
long sts;
char *s;
char *qry;
char *list;
char col[COL_NAME_LEN];
char work[64];

	*buffer=CpN;
	if ((sts=NFT_setup_search(search,&qry)) != UTI_S_SUCCESS) {
		ERRload_struct(UTI,sts,"",NULL);
		return(sts);
		}

	if ((sts=NFT_prepare_collection(cno,1L)) != UTI_S_SUCCESS) { 
		ERRload_struct(UTI,sts,"",NULL);
		return(sts);
		}

	sprintf(col,"%d@%s",cno,NFT_col_node);

	if ((sts=NFT_get_cid_list(col,qry,&list)) != UTI_S_SUCCESS) {
		ERRload_struct(UTI,sts,"",NULL);
		return(sts);
		}

	if (list) {
		sts=UTI_W_NO_HITS;
		for (s=list;s;s=strchr(s,'\t')) {
			if (s!=list) s++; if (!(*s) || !atol(s)) continue;
			if (FTRcol_get_field(col,atol(s),ITEMNO_SLOT,work)!=FTR_S_SUCCESS) {
				sts=UTI_E_DATA_TRANSFER;
				break;
				}
			if (ino!=atol(work)) continue;

			if (FTRcol_get_field(col,atol(s),FILENO_SLOT,work)!=FTR_S_SUCCESS) {
				sts=UTI_E_DATA_TRANSFER;
				break;
				}
			if (fno!=atol(work)) continue;

			if (FTRsr_dup_terms(col,atol(s),-1L,buffer)!=FTR_S_SUCCESS)
				sts=UTI_E_CREATE_HIGHLT;
			else
				sts=UTI_S_SUCCESS;
			break;
			}
		}

	if (list) free(list);
	ERRload_struct(UTI,sts,"",NULL);
	return(sts);
}
