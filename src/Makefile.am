SUBDIRS = gedit ui

bin_PROGRAMS = latexila

VALAFLAGS =			\
	--pkg gtk+-3.0		\
	--pkg gtksourceview-3.0	\
	--pkg gtkspell3-3.0	\
	--pkg gee-0.8		\
	--pkg posix		\
	--target-glib=2.40

# The valac command is always executed in the sources directory, not the build
# directory. If $(top_srcdir) is used, it will be relative to the build directory.
vapidir = ../vapi

vala_files =				\
	app_settings.vala		\
	bottom_panel.vala		\
	build_command_runner.vala	\
	build_job_runner.vala		\
	build_tool_dialog.vala		\
	build_tool_runner.vala		\
	build_tools_preferences.vala	\
	build_tools.vala		\
	build_view.vala			\
	clean_build_files.vala		\
	completion.vala			\
	custom_statusbar.vala		\
	dialogs.vala			\
	documents_panel.vala		\
	document_structure.vala		\
	document_tab.vala		\
	document.vala			\
	document_view.vala		\
	encodings.vala			\
	error_entry.vala		\
	file_browser.vala		\
	finance.vala			\
	latexila.vala			\
	latex_menu.vala			\
	latex_post_processor.vala	\
	main.vala			\
	main_window_build_tools.vala	\
	main_window_documents.vala	\
	main_window_edit.vala		\
	main_window_file.vala		\
	main_window_structure.vala	\
	main_window.vala		\
	menu_in_toolbar.vala		\
	most_used_symbols.vala		\
	post_processors.vala		\
	preferences_dialog.vala		\
	project_dialogs.vala		\
	projects.vala			\
	search.vala			\
	side_panel.vala			\
	stock_icons.vala		\
	structure_model.vala		\
	structure.vala			\
	symbols.vala			\
	symbols_view.vala		\
	synctex.vala			\
	tab_info_bar.vala		\
	templates_dialogs.vala		\
	templates.vala			\
	utils.vala

latexila_SOURCES = 			\
	$(vala_files)			\
	$(vapidir)/config.vapi		\
	$(vapidir)/gedit.vapi		\
	$(vapidir)/menu_tool_action.vapi

latexila_CPPFLAGS =		\
	-I$(top_srcdir)		\
	-I$(srcdir)/gedit	\
	-include config.h

latexila_LDADD = 		\
	gedit/libgedit.la

MAINTAINERCLEANFILES =		\
	$(vala_files:.vala=.c)	\
	latexila_vala.stamp

# GResource

xml = latexila.gresource.xml
res = latexila-resources.c
$(res): $(xml) $(shell $(GLIB_COMPILE_RESOURCES) --sourcedir=$(srcdir) --generate-dependencies $(xml))
	$(AM_V_GEN) $(GLIB_COMPILE_RESOURCES) --target=$@ --sourcedir=$(srcdir) --generate-source $(xml)

latexila.$(OBJEXT): $(res)

latexila_SOURCES += $(res)
EXTRA_DIST = $(xml)
MAINTAINERCLEANFILES += $(res)

-include $(top_srcdir)/git.mk
