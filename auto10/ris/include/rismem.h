/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							rismem.h
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					3/88
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/

#ifndef RISMEM_H
#define RISMEM_H

#ifndef COM_EXTERN
# ifdef COM_GLOBAL_DEFINE
#  define COM_EXTERN
# else
#  define COM_EXTERN extern
# endif
#endif

#ifndef COM_INITIAL
# ifdef COM_GLOBAL_DEFINE
#  define COM_INITIAL(value) = value
# else
#  define COM_INITIAL(value)
# endif
#endif

 
/*
**	INCLUDES
*/
#include "rislimit.h"

/*
**	DEFINES
*/

/* Types of memory */
#define STATEMENT_MEMORY        0
#define SCHEMA_MEMORY           1
#define PERMANENT_MEMORY        2
#define ASYNC_MEMORY            3
#define SUPERSCHEMA_MEMORY      4

/*	Memory Marks */
#define DEFAULT_MARK            0
#define ALL_MARKS              -1

/* permanent marks */
#define SQL_PERMANENT_MARK      1

/* schema marks */
#define RISSQLSTMT_SCHEMA_MARK  1
#define DBSQLSTMT_SCHEMA_MARK   2

/* superschema marks */
#define RISSQLSTMT_SS_MARK     10
#define DBSQLSTMT_SS_MARK      20


/*
**	Normal allocate for statements
*/
#define ALLOCT(type) \
(type*)RIScom_alloc(sizeof(type),RIS_current_stmt_id,DEFAULT_MARK,STATEMENT_MEMORY)

#define ALLOCN(type, n) \
(type*)RIScom_alloc((n) * sizeof(type),RIS_current_stmt_id,DEFAULT_MARK,STATEMENT_MEMORY)

#define ALLOCB(size) \
RIScom_alloc(size,RIS_current_stmt_id,DEFAULT_MARK,STATEMENT_MEMORY);

#define FREE(id) \
RIScom_free(id, ALL_MARKS, STATEMENT_MEMORY)


/*
**	Normal allocate for permanent memory
*/
#define ALLOCTP(type) \
(type*)RIScom_alloc(sizeof(type),0,DEFAULT_MARK,PERMANENT_MEMORY)

#define ALLOCNP(type, n) \
(type*)RIScom_alloc((n) * sizeof(type),0,DEFAULT_MARK,PERMANENT_MEMORY)

#define ALLOCBP(size) \
RIScom_alloc((size),0,DEFAULT_MARK,PERMANENT_MEMORY)

#define FREEP() \
RIScom_free(0, ALL_MARKS, PERMANENT_MEMORY)

/*
**	Normal allocate for schemas
*/
#define ALLOCTS(id, type) \
(type*)RIScom_alloc(sizeof(type),id,DEFAULT_MARK,SCHEMA_MEMORY)

#define ALLOCNS(id, type, n) \
(type*)RIScom_alloc((n) * sizeof(type),id,DEFAULT_MARK,SCHEMA_MEMORY)

#define ALLOCBS(id, size) \
RIScom_alloc((size),id,DEFAULT_MARK,SCHEMA_MEMORY)

#define FREES(id) RIScom_free(id,ALL_MARKS,SCHEMA_MEMORY)

/*
**	Normal allocate for superschemas
*/
#define ALLOCTSS(id, type) \
(type*)RIScom_alloc(sizeof(type),id,DEFAULT_MARK,SUPERSCHEMA_MEMORY)

#define ALLOCNSS(id, type, n) \
(type*)RIScom_alloc((n) * sizeof(type),id,DEFAULT_MARK,SUPERSCHEMA_MEMORY)

#define ALLOCBSS(id, size) \
RIScom_alloc((size),id,DEFAULT_MARK,SUPERSCHEMA_MEMORY)

#define FREESS(id) RIScom_free(id,ALL_MARKS,SUPERSCHEMA_MEMORY)


/*
**	Normal allocate for async.
*/
#define ALLOCTA(id, type) \
(type*)RIScom_alloc(sizeof(type),id,DEFAULT_MARK,ASYNC_MEMORY)

#define ALLOCNA(id, type, n) \
(type*)RIScom_alloc((n) * sizeof(type),id,DEFAULT_MARK,ASYNC_MEMORY)

#define ALLOCBA(id, size) \
RIScom_alloc((size),id,DEFAULT_MARK,ASYNC_MEMORY)

#define FREEA(id) RIScom_free(id,ALL_MARKS,ASYNC_MEMORY)

/*
** regular system malloc/calloc/realloc/free (ensuring 8 byte alignment)
*/
#define SYS_MALLOC(size)        RIScom_sys_malloc(size)
#define SYS_CALLOC(nelm, elsz)  RIScom_sys_calloc(nelm, elsz)
#define SYS_REALLOC(ptr, size)  RIScom_sys_realloc(ptr, size)
#define SYS_FREE(ptr)           RIScom_sys_free(ptr)

/*	Bits masks for memory_sts in structures controlled in COMstrctmgr.c */
#define SET_IN_USE(flag)      ((flag) |= 0x01)
#define CLEAR_IN_USE(flag)    ((flag) &= ~0x01)
#define IN_USE(flag)          ((flag) & 0x01)

#define SET_PERMANENT(flag)   ((flag) |= 0x02)
#define CLEAR_PERMANENT(flag) ((flag) &= ~0x02)
#define PERMANENT(flag)       ((flag) & 0x02)

/* memory allocation stuctures */
/* Note: ris_block_info must be 8 byte aligned. */
typedef struct ris_block_info
{
  struct ris_block_info	*next;
  unsigned short         count;
  char                   mark;
  char                   malloc_flag;
} ris_block_info;

typedef struct ris_alloc_info
{
  struct ris_block_info *blk;
  struct ris_block_info *end;
  unsigned int           avail; /* only for 0th mark */
  char                  *pos;   /* only for 0th mark */
} ris_alloc_info;

typedef struct ris_mem_info
{
  ris_alloc_info  statement[RIS_MAX_STMTS];
  ris_alloc_info  async    [RIS_MAX_TRANSACTIONS];
  ris_alloc_info  schema   [RIS_MAX_OPEN_SCHEMAS];
  ris_alloc_info  sschema  [RIS_MAX_OPEN_SUPERSCHEMAS];
  ris_alloc_info  permanent;
  ris_block_info *free;
} ris_mem_info;

typedef struct ris_buffer_s
{
  char  data[1]; /* variable length */
} ris_buffer_s;

/*
**	VARIABLES
*/
COM_EXTERN  ris_mem_info *RIS_mem COM_INITIAL(0);

#endif /* COMMON_H */
