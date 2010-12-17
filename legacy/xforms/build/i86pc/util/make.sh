UTIL_DIR=$PWD

UTILITIES="	FI_conv/src	\
		MI_conv/src	\
		FIf_get_text	\
		FIf_set_text	\
		cmds		\
		font_conv	\
		look		\
		menus		\
		mkfont		\
		mksym		\
		modify_font	\
		prev		\
		sfb		\
		show_fonts	\
		show_menus	\
		"

for XXX in $UTILITIES
do
  cd $XXX
  echo "\nMaking $XXX ...\n"
  make
  cd $UTIL_DIR
done
