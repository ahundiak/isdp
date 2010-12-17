	.section  .init,"x"

	loada	_errno, r0
	storw	r0, _libxfi_errno

	loada	__ctype, r0
	storw	r0, _libxfi__ctype

	loada	__iob, r0
	storw	r0, _libxfi__iob

	loada	_access, r0
	storw	r0, _libxfi_access

	loada	_atoi, r0
	storw	r0, _libxfi_atoi

	loada	_atof, r0
	storw	r0, _libxfi_atof

	loada	_close, r0
	storw	r0, _libxfi_close

	loada	_fclose, r0
	storw	r0, _libxfi_fclose

	loada	_fopen, r0
	storw	r0, _libxfi_fopen

	loada	_fprintf, r0
	storw	r0, _libxfi_fprintf

	loada	_fread, r0
	storw	r0, _libxfi_fread

	loada	_fscanf, r0
	storw	r0, _libxfi_fscanf

	loada	_fseek, r0
	storw	r0, _libxfi_fseek

	loada	_fwrite, r0
	storw	r0, _libxfi_fwrite

	loada	_getlogin, r0
	storw	r0, _libxfi_getlogin

	loada	_longjmp, r0
	storw	r0, _libxfi_longjmp

	loada	_memcpy, r0
	storw	r0, _libxfi_memcpy

	loada	_memset, r0
	storw	r0, _libxfi_memset

	loada	_open, r0
	storw	r0, _libxfi_open

	loada	_printf, r0
	storw	r0, _libxfi_printf

	loada	_read, r0
	storw	r0, _libxfi_read

	loada	_setjmp, r0
	storw	r0, _libxfi_setjmp

	loada	_sprintf, r0
	storw	r0, _libxfi_sprintf

	loada	_sscanf, r0
	storw	r0, _libxfi_sscanf

	loada	_strcat, r0
	storw	r0, _libxfi_strcat

	loada	_strchr, r0
	storw	r0, _libxfi_strchr

	loada	_strcmp, r0
	storw	r0, _libxfi_strcmp

	loada	_strcpy, r0
	storw	r0, _libxfi_strcpy

	loada	_strlen, r0
	storw	r0, _libxfi_strlen

	loada	_strncmp, r0
	storw	r0, _libxfi_strncmp

	loada	_strncpy, r0
	storw	r0, _libxfi_strncpy

	loada	_strrchr, r0
	storw	r0, _libxfi_strrchr

	loada	_time, r0
	storw	r0, _libxfi_time

	loada	_tolower, r0
	storw	r0, _libxfi_tolower

	loada	_toupper, r0
	storw	r0, _libxfi_toupper

	loada	_uname, r0
	storw	r0, _libxfi_uname

	loada	_atan2, r0
	storw	r0, _libxfi_atan2

	loada	_cos, r0
	storw	r0, _libxfi_cos

	loada	_pow, r0
	storw	r0, _libxfi_pow

	loada	_sin, r0
	storw	r0, _libxfi_sin

	loada	_sqrt, r0
	storw	r0, _libxfi_sqrt

	loada	_calloc, r0
	storw	r0, _libxfi_calloc

	loada	_free, r0
	storw	r0, _libxfi_free

	loada	_malloc, r0
	storw	r0, _libxfi_malloc

	loada	_realloc, r0
	storw	r0, _libxfi_realloc

	loada	_select, r0
	storw	r0, _libxfi_select

	loada	_getenv, r0
	storw	r0, _libxfi_getenv

