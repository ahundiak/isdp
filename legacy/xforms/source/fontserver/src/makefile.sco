FS_LIB = /usr/lib/libXFS_s.a
FS_LIB_NAME = libXFS_s.a
CURRENT_PROC_TYPE = c100

XFORMS_FS_LIB_DIR = $(SYSBLD)/fontserver/lib/$(CURRENT_PROC_TYPE)

BOX=`uname -s`

FS_host_shlib:
	@if [ "$(BOX)" = "CLIX" ]; \
	then \
		if [ ! -d $(XFORMS_FS_LIB_DIR) ]; \
		then \
			echo "Create $(XFORMS_FS_LIB_DIR)."; \
			mkdir -p $(XFORMS_FS_LIB_DIR); \
		fi; \
		if [ -f /usr/lib/$(CURRENT_PROC_TYPE)/$(FS_LIB_NAME) ]; \
		then \
			set -x; \
			cp /usr/lib/$(CURRENT_PROC_TYPE)/$(FS_LIB_NAME) \
			   $(XFORMS_FS_LIB_DIR); \
			set +x; \
		elif [ -f /usr/lib/$(FS_LIB_NAME) ]; \
		then \
			set -x; \
			cp /usr/lib/$(FS_LIB_NAME) $(XFORMS_FS_LIB_DIR); \
			set +x; \
		else \
			echo "Error: Can not find $(FS_LIB_NAME)"; \
			exit 2; \
		fi; \
		echo; \
		ls -ls $(XFORMS_FS_LIB_DIR)/$(FS_LIB_NAME); \
		echo; \
	fi;
