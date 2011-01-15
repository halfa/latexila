/* dialogs.c generated by valac 0.10.2, the Vala compiler
 * generated from dialogs.vala, do not modify */

/*
 * This file is part of LaTeXila.
 *
 * Copyright © 2010 Sébastien Wilmet
 *
 * LaTeXila is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * LaTeXila is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with LaTeXila.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <glib.h>
#include <glib-object.h>
#include <gtk/gtk.h>
#include <gtksourceview/gtksourceview.h>
#include <glib/gi18n-lib.h>
#include <float.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <gio/gio.h>


#define DIALOGS_TYPE_UNSAVED_DOC_COLUMN (dialogs_unsaved_doc_column_get_type ())

#define TYPE_MAIN_WINDOW (main_window_get_type ())
#define MAIN_WINDOW(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_MAIN_WINDOW, MainWindow))
#define MAIN_WINDOW_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_MAIN_WINDOW, MainWindowClass))
#define IS_MAIN_WINDOW(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_MAIN_WINDOW))
#define IS_MAIN_WINDOW_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_MAIN_WINDOW))
#define MAIN_WINDOW_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_MAIN_WINDOW, MainWindowClass))

typedef struct _MainWindow MainWindow;
typedef struct _MainWindowClass MainWindowClass;

#define TYPE_DOCUMENT (document_get_type ())
#define DOCUMENT(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_DOCUMENT, Document))
#define DOCUMENT_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_DOCUMENT, DocumentClass))
#define IS_DOCUMENT(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_DOCUMENT))
#define IS_DOCUMENT_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_DOCUMENT))
#define DOCUMENT_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_DOCUMENT, DocumentClass))

typedef struct _Document Document;
typedef struct _DocumentClass DocumentClass;
#define _g_free0(var) (var = (g_free (var), NULL))
typedef struct _DocumentPrivate DocumentPrivate;

#define TYPE_DOCUMENT_TAB (document_tab_get_type ())
#define DOCUMENT_TAB(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_DOCUMENT_TAB, DocumentTab))
#define DOCUMENT_TAB_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_DOCUMENT_TAB, DocumentTabClass))
#define IS_DOCUMENT_TAB(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_DOCUMENT_TAB))
#define IS_DOCUMENT_TAB_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_DOCUMENT_TAB))
#define DOCUMENT_TAB_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_DOCUMENT_TAB, DocumentTabClass))

typedef struct _DocumentTab DocumentTab;
typedef struct _DocumentTabClass DocumentTabClass;
#define _g_object_unref0(var) ((var == NULL) ? NULL : (var = (g_object_unref (var), NULL)))
#define _gtk_tree_path_free0(var) ((var == NULL) ? NULL : (var = (gtk_tree_path_free (var), NULL)))
#define __g_list_free_g_object_unref0(var) ((var == NULL) ? NULL : (var = (_g_list_free_g_object_unref (var), NULL)))
typedef struct _Block17Data Block17Data;

#define DIALOGS_TYPE_CLEAN_FILE_COLUMN (dialogs_clean_file_column_get_type ())
typedef struct _Block18Data Block18Data;

typedef enum  {
	DIALOGS_UNSAVED_DOC_COLUMN_SAVE,
	DIALOGS_UNSAVED_DOC_COLUMN_NAME,
	DIALOGS_UNSAVED_DOC_COLUMN_DOC,
	DIALOGS_UNSAVED_DOC_COLUMN_N_COLUMNS
} DialogsUnsavedDocColumn;

struct _Document {
	GtkSourceBuffer parent_instance;
	DocumentPrivate * priv;
	DocumentTab* tab;
};

struct _DocumentClass {
	GtkSourceBufferClass parent_class;
};

struct _Block17Data {
	int _ref_count_;
	GtkListStore* store;
};

typedef enum  {
	DIALOGS_CLEAN_FILE_COLUMN_DELETE,
	DIALOGS_CLEAN_FILE_COLUMN_NAME,
	DIALOGS_CLEAN_FILE_COLUMN_N_COLUMNS
} DialogsCleanFileColumn;

struct _Block18Data {
	int _ref_count_;
	GtkListStore* store;
};



GType dialogs_unsaved_doc_column_get_type (void) G_GNUC_CONST;
GType main_window_get_type (void) G_GNUC_CONST;
GType document_get_type (void) G_GNUC_CONST;
void dialogs_close_several_unsaved_documents (MainWindow* window, GList* unsaved_docs);
GType document_tab_get_type (void) G_GNUC_CONST;
const char* document_tab_get_label_text (DocumentTab* self);
static void _lambda62_ (const char* path_str, Block17Data* _data17_);
static void __lambda62__gtk_cell_renderer_toggle_toggled (GtkCellRendererToggle* _sender, const char* path, gpointer self);
GtkWidget* utils_add_scrollbar (GtkWidget* child);
void main_window_remove_all_tabs (MainWindow* self);
GList* main_window_get_documents (MainWindow* self);
gboolean document_get_modified (Document* self);
gboolean main_window_close_tab (MainWindow* self, DocumentTab* tab, gboolean force_close);
static void _g_list_free_g_object_unref (GList* self);
gboolean main_window_save_document (MainWindow* self, Document* doc, gboolean force_save_as);
static Block17Data* block17_data_ref (Block17Data* _data17_);
static void block17_data_unref (Block17Data* _data17_);
GType dialogs_clean_file_column_get_type (void) G_GNUC_CONST;
gboolean dialogs_confirm_clean_build_files (MainWindow* window, GFile* directory, char** basenames, int basenames_length1);
static void _lambda13_ (const char* path_str, Block18Data* _data18_);
static void __lambda13__gtk_cell_renderer_toggle_toggled (GtkCellRendererToggle* _sender, const char* path, gpointer self);
static void _vala_array_add13 (char*** array, int* length, int* size, char* value);
void utils_delete_file (GFile* file);
static Block18Data* block18_data_ref (Block18Data* _data18_);
static void block18_data_unref (Block18Data* _data18_);
static void _vala_array_destroy (gpointer array, gint array_length, GDestroyNotify destroy_func);
static void _vala_array_free (gpointer array, gint array_length, GDestroyNotify destroy_func);



GType dialogs_unsaved_doc_column_get_type (void) {
	static volatile gsize dialogs_unsaved_doc_column_type_id__volatile = 0;
	if (g_once_init_enter (&dialogs_unsaved_doc_column_type_id__volatile)) {
		static const GEnumValue values[] = {{DIALOGS_UNSAVED_DOC_COLUMN_SAVE, "DIALOGS_UNSAVED_DOC_COLUMN_SAVE", "save"}, {DIALOGS_UNSAVED_DOC_COLUMN_NAME, "DIALOGS_UNSAVED_DOC_COLUMN_NAME", "name"}, {DIALOGS_UNSAVED_DOC_COLUMN_DOC, "DIALOGS_UNSAVED_DOC_COLUMN_DOC", "doc"}, {DIALOGS_UNSAVED_DOC_COLUMN_N_COLUMNS, "DIALOGS_UNSAVED_DOC_COLUMN_N_COLUMNS", "n-columns"}, {0, NULL, NULL}};
		GType dialogs_unsaved_doc_column_type_id;
		dialogs_unsaved_doc_column_type_id = g_enum_register_static ("DialogsUnsavedDocColumn", values);
		g_once_init_leave (&dialogs_unsaved_doc_column_type_id__volatile, dialogs_unsaved_doc_column_type_id);
	}
	return dialogs_unsaved_doc_column_type_id__volatile;
}


static gpointer _g_object_ref0 (gpointer self) {
	return self ? g_object_ref (self) : NULL;
}


static void _lambda62_ (const char* path_str, Block17Data* _data17_) {
	GtkTreePath* path;
	GtkTreeIter iter = {0};
	gboolean active = FALSE;
	g_return_if_fail (path_str != NULL);
	path = gtk_tree_path_new_from_string (path_str);
	gtk_tree_model_get_iter ((GtkTreeModel*) _data17_->store, &iter, path);
	gtk_tree_model_get ((GtkTreeModel*) _data17_->store, &iter, DIALOGS_UNSAVED_DOC_COLUMN_SAVE, &active, -1, -1);
	gtk_list_store_set (_data17_->store, &iter, DIALOGS_UNSAVED_DOC_COLUMN_SAVE, !active, -1, -1);
	_gtk_tree_path_free0 (path);
}


static void __lambda62__gtk_cell_renderer_toggle_toggled (GtkCellRendererToggle* _sender, const char* path, gpointer self) {
	_lambda62_ (path, self);
}


static void _g_list_free_g_object_unref (GList* self) {
	g_list_foreach (self, (GFunc) g_object_unref, NULL);
	g_list_free (self);
}


static Block17Data* block17_data_ref (Block17Data* _data17_) {
	g_atomic_int_inc (&_data17_->_ref_count_);
	return _data17_;
}


static void block17_data_unref (Block17Data* _data17_) {
	if (g_atomic_int_dec_and_test (&_data17_->_ref_count_)) {
		_g_object_unref0 (_data17_->store);
		g_slice_free (Block17Data, _data17_);
	}
}


void dialogs_close_several_unsaved_documents (MainWindow* window, GList* unsaved_docs) {
	Block17Data* _data17_;
	GtkDialog* dialog;
	GtkHBox* hbox;
	GtkVBox* content_area;
	GtkImage* image;
	GtkVBox* vbox;
	GtkLabel* primary_label;
	char* _tmp0_;
	char* _tmp1_;
	char* _tmp2_;
	GtkVBox* vbox2;
	GtkLabel* select_label;
	GtkTreeView* treeview;
	GtkCellRendererToggle* renderer1;
	GtkTreeViewColumn* column;
	GtkCellRendererText* renderer2;
	GtkTreeViewColumn* _tmp3_;
	GtkScrolledWindow* sw;
	GtkLabel* secondary_label;
	gint resp;
	g_return_if_fail (window != NULL);
	_data17_ = g_slice_new0 (Block17Data);
	_data17_->_ref_count_ = 1;
	g_return_if_fail (g_list_length (unsaved_docs) >= 2);
	dialog = g_object_ref_sink ((GtkDialog*) gtk_dialog_new_with_buttons (NULL, (GtkWindow*) window, GTK_DIALOG_DESTROY_WITH_PARENT, _ ("Close without Saving"), GTK_RESPONSE_CLOSE, GTK_STOCK_CANCEL, GTK_RESPONSE_CANCEL, GTK_STOCK_SAVE, GTK_RESPONSE_ACCEPT, NULL, NULL));
	gtk_dialog_set_has_separator (dialog, FALSE);
	hbox = g_object_ref_sink ((GtkHBox*) gtk_hbox_new (FALSE, 12));
	gtk_container_set_border_width ((GtkContainer*) hbox, (guint) 5);
	content_area = _g_object_ref0 (GTK_VBOX (gtk_dialog_get_content_area (dialog)));
	gtk_box_pack_start ((GtkBox*) content_area, (GtkWidget*) hbox, TRUE, TRUE, (guint) 0);
	image = g_object_ref_sink ((GtkImage*) gtk_image_new_from_stock (GTK_STOCK_DIALOG_WARNING, GTK_ICON_SIZE_DIALOG));
	gtk_misc_set_alignment ((GtkMisc*) image, (float) 0.5, (float) 0.0);
	gtk_box_pack_start ((GtkBox*) hbox, (GtkWidget*) image, FALSE, FALSE, (guint) 0);
	vbox = g_object_ref_sink ((GtkVBox*) gtk_vbox_new (FALSE, 12));
	gtk_box_pack_start ((GtkBox*) hbox, (GtkWidget*) vbox, TRUE, TRUE, (guint) 0);
	primary_label = g_object_ref_sink ((GtkLabel*) gtk_label_new (NULL));
	gtk_label_set_line_wrap (primary_label, TRUE);
	gtk_label_set_use_markup (primary_label, TRUE);
	gtk_misc_set_alignment ((GtkMisc*) primary_label, (float) 0.0, (float) 0.5);
	gtk_label_set_selectable (primary_label, TRUE);
	gtk_label_set_markup (primary_label, _tmp2_ = g_strconcat (_tmp1_ = g_strconcat ("<span weight=\"bold\" size=\"larger\">", _tmp0_ = g_strdup_printf (_ ("There are %d documents with unsaved changes. Save changes before closi" \
"ng?"), g_list_length (unsaved_docs)), NULL), "</span>", NULL));
	_g_free0 (_tmp2_);
	_g_free0 (_tmp1_);
	_g_free0 (_tmp0_);
	gtk_box_pack_start ((GtkBox*) vbox, (GtkWidget*) primary_label, FALSE, FALSE, (guint) 0);
	vbox2 = g_object_ref_sink ((GtkVBox*) gtk_vbox_new (FALSE, 8));
	gtk_box_pack_start ((GtkBox*) vbox, (GtkWidget*) vbox2, FALSE, FALSE, (guint) 0);
	select_label = g_object_ref_sink ((GtkLabel*) gtk_label_new (_ ("Select the documents you want to save:")));
	gtk_label_set_line_wrap (select_label, TRUE);
	gtk_misc_set_alignment ((GtkMisc*) select_label, (float) 0.0, (float) 0.5);
	gtk_box_pack_start ((GtkBox*) vbox2, (GtkWidget*) select_label, FALSE, FALSE, (guint) 0);
	treeview = g_object_ref_sink ((GtkTreeView*) gtk_tree_view_new ());
	gtk_widget_set_size_request ((GtkWidget*) treeview, 260, 120);
	gtk_tree_view_set_headers_visible (treeview, FALSE);
	gtk_tree_view_set_enable_search (treeview, FALSE);
	_data17_->store = gtk_list_store_new ((gint) DIALOGS_UNSAVED_DOC_COLUMN_N_COLUMNS, G_TYPE_BOOLEAN, G_TYPE_STRING, TYPE_DOCUMENT);
	{
		GList* doc_collection;
		GList* doc_it;
		doc_collection = unsaved_docs;
		for (doc_it = doc_collection; doc_it != NULL; doc_it = doc_it->next) {
			Document* doc;
			doc = _g_object_ref0 ((Document*) doc_it->data);
			{
				GtkTreeIter iter = {0};
				gtk_list_store_append (_data17_->store, &iter);
				gtk_list_store_set (_data17_->store, &iter, DIALOGS_UNSAVED_DOC_COLUMN_SAVE, TRUE, DIALOGS_UNSAVED_DOC_COLUMN_NAME, document_tab_get_label_text (doc->tab), DIALOGS_UNSAVED_DOC_COLUMN_DOC, doc, -1, -1);
				_g_object_unref0 (doc);
			}
		}
	}
	gtk_tree_view_set_model (treeview, (GtkTreeModel*) _data17_->store);
	renderer1 = g_object_ref_sink ((GtkCellRendererToggle*) gtk_cell_renderer_toggle_new ());
	g_signal_connect_data (renderer1, "toggled", (GCallback) __lambda62__gtk_cell_renderer_toggle_toggled, block17_data_ref (_data17_), (GClosureNotify) block17_data_unref, 0);
	column = g_object_ref_sink (gtk_tree_view_column_new_with_attributes ("Save?", (GtkCellRenderer*) renderer1, "active", DIALOGS_UNSAVED_DOC_COLUMN_SAVE, NULL, NULL));
	gtk_tree_view_append_column (treeview, column);
	renderer2 = g_object_ref_sink ((GtkCellRendererText*) gtk_cell_renderer_text_new ());
	column = (_tmp3_ = g_object_ref_sink (gtk_tree_view_column_new_with_attributes ("Name", (GtkCellRenderer*) renderer2, "text", DIALOGS_UNSAVED_DOC_COLUMN_NAME, NULL, NULL)), _g_object_unref0 (column), _tmp3_);
	gtk_tree_view_append_column (treeview, column);
	sw = GTK_SCROLLED_WINDOW (utils_add_scrollbar ((GtkWidget*) treeview));
	gtk_scrolled_window_set_shadow_type (sw, GTK_SHADOW_IN);
	gtk_box_pack_start ((GtkBox*) vbox2, (GtkWidget*) sw, TRUE, TRUE, (guint) 0);
	secondary_label = g_object_ref_sink ((GtkLabel*) gtk_label_new (_ ("If you don't save, all your changes will be permanently lost.")));
	gtk_label_set_line_wrap (secondary_label, TRUE);
	gtk_misc_set_alignment ((GtkMisc*) secondary_label, (float) 0.0, (float) 0.5);
	gtk_label_set_selectable (secondary_label, TRUE);
	gtk_box_pack_start ((GtkBox*) vbox2, (GtkWidget*) secondary_label, FALSE, FALSE, (guint) 0);
	gtk_widget_show_all ((GtkWidget*) hbox);
	resp = gtk_dialog_run (dialog);
	if (resp == GTK_RESPONSE_CLOSE) {
		main_window_remove_all_tabs (window);
	} else {
		if (resp == GTK_RESPONSE_ACCEPT) {
			GList* selected_docs;
			GtkTreeIter iter = {0};
			gboolean valid;
			{
				GList* doc_collection;
				GList* doc_it;
				doc_collection = main_window_get_documents (window);
				for (doc_it = doc_collection; doc_it != NULL; doc_it = doc_it->next) {
					Document* doc;
					doc = _g_object_ref0 ((Document*) doc_it->data);
					{
						if (!document_get_modified (doc)) {
							main_window_close_tab (window, doc->tab, FALSE);
						}
						_g_object_unref0 (doc);
					}
				}
				__g_list_free_g_object_unref0 (doc_collection);
			}
			selected_docs = NULL;
			valid = gtk_tree_model_get_iter_first ((GtkTreeModel*) _data17_->store, &iter);
			while (TRUE) {
				gboolean selected = FALSE;
				Document* doc;
				if (!valid) {
					break;
				}
				doc = NULL;
				gtk_tree_model_get ((GtkTreeModel*) _data17_->store, &iter, DIALOGS_UNSAVED_DOC_COLUMN_SAVE, &selected, DIALOGS_UNSAVED_DOC_COLUMN_DOC, &doc, -1, -1);
				if (selected) {
					selected_docs = g_list_prepend (selected_docs, _g_object_ref0 (doc));
				} else {
					main_window_close_tab (window, doc->tab, TRUE);
				}
				valid = gtk_tree_model_iter_next ((GtkTreeModel*) _data17_->store, &iter);
				_g_object_unref0 (doc);
			}
			selected_docs = g_list_reverse (selected_docs);
			{
				GList* doc_collection;
				GList* doc_it;
				doc_collection = selected_docs;
				for (doc_it = doc_collection; doc_it != NULL; doc_it = doc_it->next) {
					Document* doc;
					doc = _g_object_ref0 ((Document*) doc_it->data);
					{
						if (main_window_save_document (window, doc, FALSE)) {
							main_window_close_tab (window, doc->tab, TRUE);
						}
						_g_object_unref0 (doc);
					}
				}
			}
			__g_list_free_g_object_unref0 (selected_docs);
		}
	}
	gtk_object_destroy ((GtkObject*) dialog);
	_g_object_unref0 (secondary_label);
	_g_object_unref0 (sw);
	_g_object_unref0 (renderer2);
	_g_object_unref0 (column);
	_g_object_unref0 (renderer1);
	_g_object_unref0 (treeview);
	_g_object_unref0 (select_label);
	_g_object_unref0 (vbox2);
	_g_object_unref0 (primary_label);
	_g_object_unref0 (vbox);
	_g_object_unref0 (image);
	_g_object_unref0 (content_area);
	_g_object_unref0 (hbox);
	_g_object_unref0 (dialog);
	block17_data_unref (_data17_);
}


GType dialogs_clean_file_column_get_type (void) {
	static volatile gsize dialogs_clean_file_column_type_id__volatile = 0;
	if (g_once_init_enter (&dialogs_clean_file_column_type_id__volatile)) {
		static const GEnumValue values[] = {{DIALOGS_CLEAN_FILE_COLUMN_DELETE, "DIALOGS_CLEAN_FILE_COLUMN_DELETE", "delete"}, {DIALOGS_CLEAN_FILE_COLUMN_NAME, "DIALOGS_CLEAN_FILE_COLUMN_NAME", "name"}, {DIALOGS_CLEAN_FILE_COLUMN_N_COLUMNS, "DIALOGS_CLEAN_FILE_COLUMN_N_COLUMNS", "n-columns"}, {0, NULL, NULL}};
		GType dialogs_clean_file_column_type_id;
		dialogs_clean_file_column_type_id = g_enum_register_static ("DialogsCleanFileColumn", values);
		g_once_init_leave (&dialogs_clean_file_column_type_id__volatile, dialogs_clean_file_column_type_id);
	}
	return dialogs_clean_file_column_type_id__volatile;
}


static void _lambda13_ (const char* path_str, Block18Data* _data18_) {
	GtkTreePath* path;
	GtkTreeIter iter = {0};
	gboolean active = FALSE;
	g_return_if_fail (path_str != NULL);
	path = gtk_tree_path_new_from_string (path_str);
	gtk_tree_model_get_iter ((GtkTreeModel*) _data18_->store, &iter, path);
	gtk_tree_model_get ((GtkTreeModel*) _data18_->store, &iter, DIALOGS_CLEAN_FILE_COLUMN_DELETE, &active, -1, -1);
	gtk_list_store_set (_data18_->store, &iter, DIALOGS_CLEAN_FILE_COLUMN_DELETE, !active, -1, -1);
	_gtk_tree_path_free0 (path);
}


static void __lambda13__gtk_cell_renderer_toggle_toggled (GtkCellRendererToggle* _sender, const char* path, gpointer self) {
	_lambda13_ (path, self);
}


static void _vala_array_add13 (char*** array, int* length, int* size, char* value) {
	if ((*length) == (*size)) {
		*size = (*size) ? (2 * (*size)) : 4;
		*array = g_renew (char*, *array, (*size) + 1);
	}
	(*array)[(*length)++] = value;
	(*array)[*length] = NULL;
}


static Block18Data* block18_data_ref (Block18Data* _data18_) {
	g_atomic_int_inc (&_data18_->_ref_count_);
	return _data18_;
}


static void block18_data_unref (Block18Data* _data18_) {
	if (g_atomic_int_dec_and_test (&_data18_->_ref_count_)) {
		_g_object_unref0 (_data18_->store);
		g_slice_free (Block18Data, _data18_);
	}
}


gboolean dialogs_confirm_clean_build_files (MainWindow* window, GFile* directory, char** basenames, int basenames_length1) {
	gboolean result = FALSE;
	Block18Data* _data18_;
	GtkDialog* dialog;
	GtkHBox* hbox;
	GtkVBox* content_area;
	GtkImage* image;
	GtkVBox* vbox;
	GtkLabel* primary_label;
	char* _tmp0_;
	char* _tmp1_;
	GtkVBox* vbox2;
	GtkLabel* select_label;
	GtkTreeView* treeview;
	GtkCellRendererToggle* renderer1;
	GtkTreeViewColumn* column;
	GtkCellRendererText* renderer2;
	GtkTreeViewColumn* _tmp2_;
	GtkScrolledWindow* sw;
	gboolean ret;
	g_return_val_if_fail (window != NULL, FALSE);
	g_return_val_if_fail (directory != NULL, FALSE);
	_data18_ = g_slice_new0 (Block18Data);
	_data18_->_ref_count_ = 1;
	g_return_if_fail (basenames_length1 > 0);
	dialog = g_object_ref_sink ((GtkDialog*) gtk_dialog_new_with_buttons (NULL, (GtkWindow*) window, GTK_DIALOG_DESTROY_WITH_PARENT, GTK_STOCK_CANCEL, GTK_RESPONSE_CANCEL, GTK_STOCK_DELETE, GTK_RESPONSE_ACCEPT, NULL, NULL));
	gtk_dialog_set_has_separator (dialog, FALSE);
	hbox = g_object_ref_sink ((GtkHBox*) gtk_hbox_new (FALSE, 12));
	gtk_container_set_border_width ((GtkContainer*) hbox, (guint) 5);
	content_area = _g_object_ref0 (GTK_VBOX (gtk_dialog_get_content_area (dialog)));
	gtk_box_pack_start ((GtkBox*) content_area, (GtkWidget*) hbox, TRUE, TRUE, (guint) 0);
	image = g_object_ref_sink ((GtkImage*) gtk_image_new_from_stock (GTK_STOCK_DIALOG_WARNING, GTK_ICON_SIZE_DIALOG));
	gtk_misc_set_alignment ((GtkMisc*) image, (float) 0.5, (float) 0.0);
	gtk_box_pack_start ((GtkBox*) hbox, (GtkWidget*) image, FALSE, FALSE, (guint) 0);
	vbox = g_object_ref_sink ((GtkVBox*) gtk_vbox_new (FALSE, 12));
	gtk_box_pack_start ((GtkBox*) hbox, (GtkWidget*) vbox, TRUE, TRUE, (guint) 0);
	primary_label = g_object_ref_sink ((GtkLabel*) gtk_label_new (NULL));
	gtk_label_set_line_wrap (primary_label, TRUE);
	gtk_label_set_use_markup (primary_label, TRUE);
	gtk_misc_set_alignment ((GtkMisc*) primary_label, (float) 0.0, (float) 0.5);
	gtk_label_set_selectable (primary_label, TRUE);
	gtk_label_set_markup (primary_label, _tmp1_ = g_strconcat (_tmp0_ = g_strconcat ("<span weight=\"bold\" size=\"larger\">", _ ("Do you really want to delete these files?"), NULL), "</span>", NULL));
	_g_free0 (_tmp1_);
	_g_free0 (_tmp0_);
	gtk_box_pack_start ((GtkBox*) vbox, (GtkWidget*) primary_label, FALSE, FALSE, (guint) 0);
	vbox2 = g_object_ref_sink ((GtkVBox*) gtk_vbox_new (FALSE, 8));
	gtk_box_pack_start ((GtkBox*) vbox, (GtkWidget*) vbox2, FALSE, FALSE, 0);
	select_label = g_object_ref_sink ((GtkLabel*) gtk_label_new (_ ("Select the files you want to delete:")));
	gtk_label_set_line_wrap (select_label, TRUE);
	gtk_misc_set_alignment ((GtkMisc*) select_label, (float) 0.0, (float) 0.5);
	gtk_box_pack_start ((GtkBox*) vbox2, (GtkWidget*) select_label, FALSE, FALSE, (guint) 0);
	treeview = g_object_ref_sink ((GtkTreeView*) gtk_tree_view_new ());
	gtk_widget_set_size_request ((GtkWidget*) treeview, 260, 120);
	gtk_tree_view_set_headers_visible (treeview, FALSE);
	gtk_tree_view_set_enable_search (treeview, FALSE);
	_data18_->store = gtk_list_store_new ((gint) DIALOGS_CLEAN_FILE_COLUMN_N_COLUMNS, G_TYPE_BOOLEAN, G_TYPE_STRING);
	{
		char** basename_collection;
		int basename_collection_length1;
		int basename_it;
		basename_collection = basenames;
		basename_collection_length1 = basenames_length1;
		for (basename_it = 0; basename_it < basenames_length1; basename_it = basename_it + 1) {
			char* basename;
			basename = g_strdup (basename_collection[basename_it]);
			{
				GtkTreeIter iter = {0};
				gtk_list_store_append (_data18_->store, &iter);
				gtk_list_store_set (_data18_->store, &iter, DIALOGS_CLEAN_FILE_COLUMN_DELETE, TRUE, DIALOGS_CLEAN_FILE_COLUMN_NAME, basename, -1, -1);
				_g_free0 (basename);
			}
		}
	}
	gtk_tree_view_set_model (treeview, (GtkTreeModel*) _data18_->store);
	renderer1 = g_object_ref_sink ((GtkCellRendererToggle*) gtk_cell_renderer_toggle_new ());
	g_signal_connect_data (renderer1, "toggled", (GCallback) __lambda13__gtk_cell_renderer_toggle_toggled, block18_data_ref (_data18_), (GClosureNotify) block18_data_unref, 0);
	column = g_object_ref_sink (gtk_tree_view_column_new_with_attributes ("Delete?", (GtkCellRenderer*) renderer1, "active", DIALOGS_CLEAN_FILE_COLUMN_DELETE, NULL, NULL));
	gtk_tree_view_append_column (treeview, column);
	renderer2 = g_object_ref_sink ((GtkCellRendererText*) gtk_cell_renderer_text_new ());
	column = (_tmp2_ = g_object_ref_sink (gtk_tree_view_column_new_with_attributes ("Name", (GtkCellRenderer*) renderer2, "text", DIALOGS_CLEAN_FILE_COLUMN_NAME, NULL, NULL)), _g_object_unref0 (column), _tmp2_);
	gtk_tree_view_append_column (treeview, column);
	sw = GTK_SCROLLED_WINDOW (utils_add_scrollbar ((GtkWidget*) treeview));
	gtk_scrolled_window_set_shadow_type (sw, GTK_SHADOW_IN);
	gtk_box_pack_start ((GtkBox*) vbox2, (GtkWidget*) sw, TRUE, TRUE, (guint) 0);
	gtk_widget_show_all ((GtkWidget*) hbox);
	ret = FALSE;
	if (gtk_dialog_run (dialog) == GTK_RESPONSE_ACCEPT) {
		gint selected_files_length1;
		gint _selected_files_size_;
		char** _tmp4_;
		char** _tmp3_ = NULL;
		char** selected_files;
		GtkTreeIter iter = {0};
		gboolean valid;
		selected_files = (_tmp4_ = (_tmp3_ = g_new0 (char*, 0 + 1), _tmp3_), selected_files_length1 = 0, _selected_files_size_ = selected_files_length1, _tmp4_);
		valid = gtk_tree_model_get_iter_first ((GtkTreeModel*) _data18_->store, &iter);
		while (TRUE) {
			gboolean selected = FALSE;
			char* basename;
			if (!valid) {
				break;
			}
			basename = NULL;
			gtk_tree_model_get ((GtkTreeModel*) _data18_->store, &iter, DIALOGS_CLEAN_FILE_COLUMN_DELETE, &selected, DIALOGS_CLEAN_FILE_COLUMN_NAME, &basename, -1, -1);
			if (selected) {
				_vala_array_add13 (&selected_files, &selected_files_length1, &_selected_files_size_, g_strdup (basename));
			}
			valid = gtk_tree_model_iter_next ((GtkTreeModel*) _data18_->store, &iter);
			_g_free0 (basename);
		}
		{
			char** selected_file_collection;
			int selected_file_collection_length1;
			int selected_file_it;
			selected_file_collection = selected_files;
			selected_file_collection_length1 = selected_files_length1;
			for (selected_file_it = 0; selected_file_it < selected_files_length1; selected_file_it = selected_file_it + 1) {
				char* selected_file;
				selected_file = g_strdup (selected_file_collection[selected_file_it]);
				{
					GFile* file;
					ret = TRUE;
					file = g_file_get_child (directory, selected_file);
					utils_delete_file (file);
					_g_object_unref0 (file);
					_g_free0 (selected_file);
				}
			}
		}
		selected_files = (_vala_array_free (selected_files, selected_files_length1, (GDestroyNotify) g_free), NULL);
	}
	gtk_object_destroy ((GtkObject*) dialog);
	result = ret;
	_g_object_unref0 (sw);
	_g_object_unref0 (renderer2);
	_g_object_unref0 (column);
	_g_object_unref0 (renderer1);
	_g_object_unref0 (treeview);
	_g_object_unref0 (select_label);
	_g_object_unref0 (vbox2);
	_g_object_unref0 (primary_label);
	_g_object_unref0 (vbox);
	_g_object_unref0 (image);
	_g_object_unref0 (content_area);
	_g_object_unref0 (hbox);
	_g_object_unref0 (dialog);
	block18_data_unref (_data18_);
	return result;
}


static void _vala_array_destroy (gpointer array, gint array_length, GDestroyNotify destroy_func) {
	if ((array != NULL) && (destroy_func != NULL)) {
		int i;
		for (i = 0; i < array_length; i = i + 1) {
			if (((gpointer*) array)[i] != NULL) {
				destroy_func (((gpointer*) array)[i]);
			}
		}
	}
}


static void _vala_array_free (gpointer array, gint array_length, GDestroyNotify destroy_func) {
	_vala_array_destroy (array, array_length, destroy_func);
	g_free (array);
}




