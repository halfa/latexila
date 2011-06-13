/* post_processors.c generated by valac 0.10.3, the Vala compiler
 * generated from post_processors.vala, do not modify */

/*
 * This file is part of LaTeXila.
 *
 * Copyright © 2010-2011 Sébastien Wilmet
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
#include <gio/gio.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>


#define TYPE_POST_PROCESSOR (post_processor_get_type ())
#define POST_PROCESSOR(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_POST_PROCESSOR, PostProcessor))
#define IS_POST_PROCESSOR(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_POST_PROCESSOR))
#define POST_PROCESSOR_GET_INTERFACE(obj) (G_TYPE_INSTANCE_GET_INTERFACE ((obj), TYPE_POST_PROCESSOR, PostProcessorIface))

typedef struct _PostProcessor PostProcessor;
typedef struct _PostProcessorIface PostProcessorIface;

#define TYPE_BUILD_ISSUE (build_issue_get_type ())

#define TYPE_BUILD_MESSAGE_TYPE (build_message_type_get_type ())
typedef struct _BuildIssue BuildIssue;

#define TYPE_NO_OUTPUT_POST_PROCESSOR (no_output_post_processor_get_type ())
#define NO_OUTPUT_POST_PROCESSOR(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_NO_OUTPUT_POST_PROCESSOR, NoOutputPostProcessor))
#define NO_OUTPUT_POST_PROCESSOR_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_NO_OUTPUT_POST_PROCESSOR, NoOutputPostProcessorClass))
#define IS_NO_OUTPUT_POST_PROCESSOR(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_NO_OUTPUT_POST_PROCESSOR))
#define IS_NO_OUTPUT_POST_PROCESSOR_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_NO_OUTPUT_POST_PROCESSOR))
#define NO_OUTPUT_POST_PROCESSOR_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_NO_OUTPUT_POST_PROCESSOR, NoOutputPostProcessorClass))

typedef struct _NoOutputPostProcessor NoOutputPostProcessor;
typedef struct _NoOutputPostProcessorClass NoOutputPostProcessorClass;
typedef struct _NoOutputPostProcessorPrivate NoOutputPostProcessorPrivate;

#define TYPE_ALL_OUTPUT_POST_PROCESSOR (all_output_post_processor_get_type ())
#define ALL_OUTPUT_POST_PROCESSOR(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_ALL_OUTPUT_POST_PROCESSOR, AllOutputPostProcessor))
#define ALL_OUTPUT_POST_PROCESSOR_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_ALL_OUTPUT_POST_PROCESSOR, AllOutputPostProcessorClass))
#define IS_ALL_OUTPUT_POST_PROCESSOR(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_ALL_OUTPUT_POST_PROCESSOR))
#define IS_ALL_OUTPUT_POST_PROCESSOR_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_ALL_OUTPUT_POST_PROCESSOR))
#define ALL_OUTPUT_POST_PROCESSOR_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_ALL_OUTPUT_POST_PROCESSOR, AllOutputPostProcessorClass))

typedef struct _AllOutputPostProcessor AllOutputPostProcessor;
typedef struct _AllOutputPostProcessorClass AllOutputPostProcessorClass;
typedef struct _AllOutputPostProcessorPrivate AllOutputPostProcessorPrivate;
#define _g_free0(var) (var = (g_free (var), NULL))

#define TYPE_RUBBER_POST_PROCESSOR (rubber_post_processor_get_type ())
#define RUBBER_POST_PROCESSOR(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_RUBBER_POST_PROCESSOR, RubberPostProcessor))
#define RUBBER_POST_PROCESSOR_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_RUBBER_POST_PROCESSOR, RubberPostProcessorClass))
#define IS_RUBBER_POST_PROCESSOR(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_RUBBER_POST_PROCESSOR))
#define IS_RUBBER_POST_PROCESSOR_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_RUBBER_POST_PROCESSOR))
#define RUBBER_POST_PROCESSOR_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_RUBBER_POST_PROCESSOR, RubberPostProcessorClass))

typedef struct _RubberPostProcessor RubberPostProcessor;
typedef struct _RubberPostProcessorClass RubberPostProcessorClass;
typedef struct _RubberPostProcessorPrivate RubberPostProcessorPrivate;
#define _g_regex_unref0(var) ((var == NULL) ? NULL : (var = (g_regex_unref (var), NULL)))
#define _g_error_free0(var) ((var == NULL) ? NULL : (var = (g_error_free (var), NULL)))
#define _g_match_info_free0(var) ((var == NULL) ? NULL : (var = (g_match_info_free (var), NULL)))
#define _g_object_unref0(var) ((var == NULL) ? NULL : (var = (g_object_unref (var), NULL)))

typedef enum  {
	BUILD_MESSAGE_TYPE_ERROR,
	BUILD_MESSAGE_TYPE_WARNING,
	BUILD_MESSAGE_TYPE_BADBOX,
	BUILD_MESSAGE_TYPE_OTHER
} BuildMessageType;

struct _BuildIssue {
	char* message;
	BuildMessageType message_type;
	char* filename;
	gint start_line;
	gint end_line;
};

struct _PostProcessorIface {
	GTypeInterface parent_iface;
	void (*process) (PostProcessor* self, GFile* file, const char* output, gint status);
	BuildIssue* (*get_issues) (PostProcessor* self, int* result_length1);
	gboolean (*get_successful) (PostProcessor* self);
	void (*set_successful) (PostProcessor* self, gboolean value);
};

struct _NoOutputPostProcessor {
	GObject parent_instance;
	NoOutputPostProcessorPrivate * priv;
};

struct _NoOutputPostProcessorClass {
	GObjectClass parent_class;
};

struct _NoOutputPostProcessorPrivate {
	gboolean _successful;
};

struct _AllOutputPostProcessor {
	GObject parent_instance;
	AllOutputPostProcessorPrivate * priv;
};

struct _AllOutputPostProcessorClass {
	GObjectClass parent_class;
};

struct _AllOutputPostProcessorPrivate {
	gboolean _successful;
	BuildIssue* issues;
	gint issues_length1;
	gint _issues_size_;
};

struct _RubberPostProcessor {
	GObject parent_instance;
	RubberPostProcessorPrivate * priv;
};

struct _RubberPostProcessorClass {
	GObjectClass parent_class;
};

struct _RubberPostProcessorPrivate {
	gboolean _successful;
	BuildIssue* issues;
	gint issues_length1;
	gint _issues_size_;
};


static gpointer no_output_post_processor_parent_class = NULL;
static PostProcessorIface* no_output_post_processor_post_processor_parent_iface = NULL;
static gpointer all_output_post_processor_parent_class = NULL;
static PostProcessorIface* all_output_post_processor_post_processor_parent_iface = NULL;
static GRegex* rubber_post_processor_pattern;
static GRegex* rubber_post_processor_pattern = NULL;
static gpointer rubber_post_processor_parent_class = NULL;
static PostProcessorIface* rubber_post_processor_post_processor_parent_iface = NULL;

GType build_issue_get_type (void) G_GNUC_CONST;
GType build_message_type_get_type (void) G_GNUC_CONST;
BuildIssue* build_issue_dup (const BuildIssue* self);
void build_issue_free (BuildIssue* self);
void build_issue_copy (const BuildIssue* self, BuildIssue* dest);
void build_issue_destroy (BuildIssue* self);
GType post_processor_get_type (void) G_GNUC_CONST;
void post_processor_process (PostProcessor* self, GFile* file, const char* output, gint status);
BuildIssue* post_processor_get_issues (PostProcessor* self, int* result_length1);
gboolean post_processor_get_successful (PostProcessor* self);
void post_processor_set_successful (PostProcessor* self, gboolean value);
GType no_output_post_processor_get_type (void) G_GNUC_CONST;
#define NO_OUTPUT_POST_PROCESSOR_GET_PRIVATE(o) (G_TYPE_INSTANCE_GET_PRIVATE ((o), TYPE_NO_OUTPUT_POST_PROCESSOR, NoOutputPostProcessorPrivate))
enum  {
	NO_OUTPUT_POST_PROCESSOR_DUMMY_PROPERTY,
	NO_OUTPUT_POST_PROCESSOR_SUCCESSFUL
};
static void no_output_post_processor_real_process (PostProcessor* base, GFile* file, const char* output, gint status);
static BuildIssue* no_output_post_processor_real_get_issues (PostProcessor* base, int* result_length1);
static void _vala_BuildIssue_array_free (BuildIssue* array, gint array_length);
NoOutputPostProcessor* no_output_post_processor_new (void);
NoOutputPostProcessor* no_output_post_processor_construct (GType object_type);
static void no_output_post_processor_finalize (GObject* obj);
static void no_output_post_processor_get_property (GObject * object, guint property_id, GValue * value, GParamSpec * pspec);
static void no_output_post_processor_set_property (GObject * object, guint property_id, const GValue * value, GParamSpec * pspec);
GType all_output_post_processor_get_type (void) G_GNUC_CONST;
#define ALL_OUTPUT_POST_PROCESSOR_GET_PRIVATE(o) (G_TYPE_INSTANCE_GET_PRIVATE ((o), TYPE_ALL_OUTPUT_POST_PROCESSOR, AllOutputPostProcessorPrivate))
enum  {
	ALL_OUTPUT_POST_PROCESSOR_DUMMY_PROPERTY,
	ALL_OUTPUT_POST_PROCESSOR_SUCCESSFUL
};
static void all_output_post_processor_real_process (PostProcessor* base, GFile* file, const char* output, gint status);
static BuildIssue* all_output_post_processor_real_get_issues (PostProcessor* base, int* result_length1);
static BuildIssue* _vala_array_dup4 (BuildIssue* self, int length);
AllOutputPostProcessor* all_output_post_processor_new (void);
AllOutputPostProcessor* all_output_post_processor_construct (GType object_type);
static void all_output_post_processor_finalize (GObject* obj);
static void all_output_post_processor_get_property (GObject * object, guint property_id, GValue * value, GParamSpec * pspec);
static void all_output_post_processor_set_property (GObject * object, guint property_id, const GValue * value, GParamSpec * pspec);
GType rubber_post_processor_get_type (void) G_GNUC_CONST;
#define RUBBER_POST_PROCESSOR_GET_PRIVATE(o) (G_TYPE_INSTANCE_GET_PRIVATE ((o), TYPE_RUBBER_POST_PROCESSOR, RubberPostProcessorPrivate))
enum  {
	RUBBER_POST_PROCESSOR_DUMMY_PROPERTY,
	RUBBER_POST_PROCESSOR_SUCCESSFUL
};
RubberPostProcessor* rubber_post_processor_new (void);
RubberPostProcessor* rubber_post_processor_construct (GType object_type);
static void rubber_post_processor_real_process (PostProcessor* base, GFile* file, const char* output, gint status);
static void _vala_array_add12 (BuildIssue** array, int* length, int* size, const BuildIssue* value);
static BuildIssue* rubber_post_processor_real_get_issues (PostProcessor* base, int* result_length1);
static BuildIssue* _vala_array_dup5 (BuildIssue* self, int length);
static void rubber_post_processor_finalize (GObject* obj);
static void rubber_post_processor_get_property (GObject * object, guint property_id, GValue * value, GParamSpec * pspec);
static void rubber_post_processor_set_property (GObject * object, guint property_id, const GValue * value, GParamSpec * pspec);
static void _vala_array_destroy (gpointer array, gint array_length, GDestroyNotify destroy_func);
static void _vala_array_free (gpointer array, gint array_length, GDestroyNotify destroy_func);
static gint _vala_array_length (gpointer array);



void post_processor_process (PostProcessor* self, GFile* file, const char* output, gint status) {
	POST_PROCESSOR_GET_INTERFACE (self)->process (self, file, output, status);
}


BuildIssue* post_processor_get_issues (PostProcessor* self, int* result_length1) {
	return POST_PROCESSOR_GET_INTERFACE (self)->get_issues (self, result_length1);
}


gboolean post_processor_get_successful (PostProcessor* self) {
	return POST_PROCESSOR_GET_INTERFACE (self)->get_successful (self);
}


void post_processor_set_successful (PostProcessor* self, gboolean value) {
	POST_PROCESSOR_GET_INTERFACE (self)->set_successful (self, value);
}


static void post_processor_base_init (PostProcessorIface * iface) {
	static gboolean initialized = FALSE;
	if (!initialized) {
		initialized = TRUE;
		g_object_interface_install_property (iface, g_param_spec_boolean ("successful", "successful", "successful", FALSE, G_PARAM_STATIC_NAME | G_PARAM_STATIC_NICK | G_PARAM_STATIC_BLURB | G_PARAM_READABLE | G_PARAM_WRITABLE));
	}
}


GType post_processor_get_type (void) {
	static volatile gsize post_processor_type_id__volatile = 0;
	if (g_once_init_enter (&post_processor_type_id__volatile)) {
		static const GTypeInfo g_define_type_info = { sizeof (PostProcessorIface), (GBaseInitFunc) post_processor_base_init, (GBaseFinalizeFunc) NULL, (GClassInitFunc) NULL, (GClassFinalizeFunc) NULL, NULL, 0, 0, (GInstanceInitFunc) NULL, NULL };
		GType post_processor_type_id;
		post_processor_type_id = g_type_register_static (G_TYPE_INTERFACE, "PostProcessor", &g_define_type_info, 0);
		g_type_interface_add_prerequisite (post_processor_type_id, G_TYPE_OBJECT);
		g_once_init_leave (&post_processor_type_id__volatile, post_processor_type_id);
	}
	return post_processor_type_id__volatile;
}


static void no_output_post_processor_real_process (PostProcessor* base, GFile* file, const char* output, gint status) {
	NoOutputPostProcessor * self;
	self = (NoOutputPostProcessor*) base;
	g_return_if_fail (file != NULL);
	g_return_if_fail (output != NULL);
	post_processor_set_successful ((PostProcessor*) self, status == 0);
}


static void _vala_BuildIssue_array_free (BuildIssue* array, gint array_length) {
	if (array != NULL) {
		int i;
		for (i = 0; i < array_length; i = i + 1) {
			build_issue_destroy (&array[i]);
		}
	}
	g_free (array);
}


static BuildIssue* no_output_post_processor_real_get_issues (PostProcessor* base, int* result_length1) {
	NoOutputPostProcessor * self;
	BuildIssue* result = NULL;
	gint issues_length1;
	gint _issues_size_;
	BuildIssue* _tmp1_;
	BuildIssue* _tmp0_ = NULL;
	BuildIssue* issues;
	BuildIssue* _tmp2_;
	self = (NoOutputPostProcessor*) base;
	issues = (_tmp1_ = (_tmp0_ = g_new0 (BuildIssue, 0), _tmp0_), issues_length1 = 0, _issues_size_ = issues_length1, _tmp1_);
	result = (_tmp2_ = issues, *result_length1 = issues_length1, _tmp2_);
	return result;
	issues = (_vala_BuildIssue_array_free (issues, issues_length1), NULL);
}


NoOutputPostProcessor* no_output_post_processor_construct (GType object_type) {
	NoOutputPostProcessor * self = NULL;
	self = (NoOutputPostProcessor*) g_object_new (object_type, NULL);
	return self;
}


NoOutputPostProcessor* no_output_post_processor_new (void) {
	return no_output_post_processor_construct (TYPE_NO_OUTPUT_POST_PROCESSOR);
}


static gboolean no_output_post_processor_real_get_successful (PostProcessor* base) {
	gboolean result;
	NoOutputPostProcessor* self;
	self = (NoOutputPostProcessor*) base;
	result = self->priv->_successful;
	return result;
}


static void no_output_post_processor_real_set_successful (PostProcessor* base, gboolean value) {
	NoOutputPostProcessor* self;
	self = (NoOutputPostProcessor*) base;
	self->priv->_successful = value;
	g_object_notify ((GObject *) self, "successful");
}


static void no_output_post_processor_class_init (NoOutputPostProcessorClass * klass) {
	no_output_post_processor_parent_class = g_type_class_peek_parent (klass);
	g_type_class_add_private (klass, sizeof (NoOutputPostProcessorPrivate));
	G_OBJECT_CLASS (klass)->get_property = no_output_post_processor_get_property;
	G_OBJECT_CLASS (klass)->set_property = no_output_post_processor_set_property;
	G_OBJECT_CLASS (klass)->finalize = no_output_post_processor_finalize;
	g_object_class_override_property (G_OBJECT_CLASS (klass), NO_OUTPUT_POST_PROCESSOR_SUCCESSFUL, "successful");
}


static void no_output_post_processor_post_processor_interface_init (PostProcessorIface * iface) {
	no_output_post_processor_post_processor_parent_iface = g_type_interface_peek_parent (iface);
	iface->process = no_output_post_processor_real_process;
	iface->get_issues = no_output_post_processor_real_get_issues;
	iface->get_successful = no_output_post_processor_real_get_successful;
	iface->set_successful = no_output_post_processor_real_set_successful;
}


static void no_output_post_processor_instance_init (NoOutputPostProcessor * self) {
	self->priv = NO_OUTPUT_POST_PROCESSOR_GET_PRIVATE (self);
}


static void no_output_post_processor_finalize (GObject* obj) {
	NoOutputPostProcessor * self;
	self = NO_OUTPUT_POST_PROCESSOR (obj);
	G_OBJECT_CLASS (no_output_post_processor_parent_class)->finalize (obj);
}


GType no_output_post_processor_get_type (void) {
	static volatile gsize no_output_post_processor_type_id__volatile = 0;
	if (g_once_init_enter (&no_output_post_processor_type_id__volatile)) {
		static const GTypeInfo g_define_type_info = { sizeof (NoOutputPostProcessorClass), (GBaseInitFunc) NULL, (GBaseFinalizeFunc) NULL, (GClassInitFunc) no_output_post_processor_class_init, (GClassFinalizeFunc) NULL, NULL, sizeof (NoOutputPostProcessor), 0, (GInstanceInitFunc) no_output_post_processor_instance_init, NULL };
		static const GInterfaceInfo post_processor_info = { (GInterfaceInitFunc) no_output_post_processor_post_processor_interface_init, (GInterfaceFinalizeFunc) NULL, NULL};
		GType no_output_post_processor_type_id;
		no_output_post_processor_type_id = g_type_register_static (G_TYPE_OBJECT, "NoOutputPostProcessor", &g_define_type_info, 0);
		g_type_add_interface_static (no_output_post_processor_type_id, TYPE_POST_PROCESSOR, &post_processor_info);
		g_once_init_leave (&no_output_post_processor_type_id__volatile, no_output_post_processor_type_id);
	}
	return no_output_post_processor_type_id__volatile;
}


static void no_output_post_processor_get_property (GObject * object, guint property_id, GValue * value, GParamSpec * pspec) {
	NoOutputPostProcessor * self;
	self = NO_OUTPUT_POST_PROCESSOR (object);
	switch (property_id) {
		case NO_OUTPUT_POST_PROCESSOR_SUCCESSFUL:
		g_value_set_boolean (value, post_processor_get_successful ((PostProcessor*) self));
		break;
		default:
		G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
		break;
	}
}


static void no_output_post_processor_set_property (GObject * object, guint property_id, const GValue * value, GParamSpec * pspec) {
	NoOutputPostProcessor * self;
	self = NO_OUTPUT_POST_PROCESSOR (object);
	switch (property_id) {
		case NO_OUTPUT_POST_PROCESSOR_SUCCESSFUL:
		post_processor_set_successful ((PostProcessor*) self, g_value_get_boolean (value));
		break;
		default:
		G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
		break;
	}
}


static glong string_get_length (const char* self) {
	glong result;
	g_return_val_if_fail (self != NULL, 0L);
	result = g_utf8_strlen (self, (gssize) (-1));
	return result;
}


static void all_output_post_processor_real_process (PostProcessor* base, GFile* file, const char* output, gint status) {
	AllOutputPostProcessor * self;
	gint lines_length1;
	gint _lines_size_;
	char** _tmp1_;
	char** _tmp0_;
	char** lines;
	gint l;
	BuildIssue* _tmp2_;
	BuildIssue issue = {0};
	char* _tmp3_;
	self = (AllOutputPostProcessor*) base;
	g_return_if_fail (file != NULL);
	g_return_if_fail (output != NULL);
	post_processor_set_successful ((PostProcessor*) self, status == 0);
	if (string_get_length (output) == 0) {
		return;
	}
	lines = (_tmp1_ = _tmp0_ = g_strsplit (output, "\n", 0), lines_length1 = _vala_array_length (_tmp0_), _lines_size_ = lines_length1, _tmp1_);
	l = lines_length1;
	g_return_if_fail (l > 0);
	if (string_get_length (lines[l - 1]) == 0) {
		l--;
	}
	self->priv->issues = (_tmp2_ = g_new0 (BuildIssue, l), self->priv->issues = (_vala_BuildIssue_array_free (self->priv->issues, self->priv->issues_length1), NULL), self->priv->issues_length1 = l, self->priv->_issues_size_ = self->priv->issues_length1, _tmp2_);
	memset (&issue, 0, sizeof (BuildIssue));
	issue.message_type = BUILD_MESSAGE_TYPE_OTHER;
	issue.filename = (_tmp3_ = NULL, _g_free0 (issue.filename), _tmp3_);
	issue.start_line = -1;
	issue.end_line = -1;
	{
		gint i;
		i = 0;
		{
			gboolean _tmp4_;
			_tmp4_ = TRUE;
			while (TRUE) {
				BuildIssue _tmp5_ = {0};
				BuildIssue _tmp6_;
				char* _tmp7_;
				char* _tmp8_;
				if (!_tmp4_) {
					i++;
				}
				_tmp4_ = FALSE;
				if (!(i < l)) {
					break;
				}
				self->priv->issues[i] = (_tmp6_ = (build_issue_copy (&issue, &_tmp5_), _tmp5_), build_issue_destroy (&self->priv->issues[i]), _tmp6_);
				self->priv->issues[i].message = (_tmp8_ = (_tmp7_ = lines[i], lines[i] = NULL, _tmp7_), _g_free0 (self->priv->issues[i].message), _tmp8_);
			}
		}
	}
	build_issue_destroy (&issue);
	lines = (_vala_array_free (lines, lines_length1, (GDestroyNotify) g_free), NULL);
}


static BuildIssue* _vala_array_dup4 (BuildIssue* self, int length) {
	BuildIssue* result;
	int i;
	BuildIssue _tmp0_ = {0};
	result = g_new0 (BuildIssue, length);
	for (i = 0; i < length; i++) {
		result[i] = (build_issue_copy (&self[i], &_tmp0_), _tmp0_);
	}
	return result;
}


static BuildIssue* all_output_post_processor_real_get_issues (PostProcessor* base, int* result_length1) {
	AllOutputPostProcessor * self;
	BuildIssue* result = NULL;
	BuildIssue* _tmp0_;
	BuildIssue* _tmp1_;
	self = (AllOutputPostProcessor*) base;
	result = (_tmp1_ = (_tmp0_ = self->priv->issues, (_tmp0_ == NULL) ? ((gpointer) _tmp0_) : _vala_array_dup4 (_tmp0_, self->priv->issues_length1)), *result_length1 = self->priv->issues_length1, _tmp1_);
	return result;
}


AllOutputPostProcessor* all_output_post_processor_construct (GType object_type) {
	AllOutputPostProcessor * self = NULL;
	self = (AllOutputPostProcessor*) g_object_new (object_type, NULL);
	return self;
}


AllOutputPostProcessor* all_output_post_processor_new (void) {
	return all_output_post_processor_construct (TYPE_ALL_OUTPUT_POST_PROCESSOR);
}


static gboolean all_output_post_processor_real_get_successful (PostProcessor* base) {
	gboolean result;
	AllOutputPostProcessor* self;
	self = (AllOutputPostProcessor*) base;
	result = self->priv->_successful;
	return result;
}


static void all_output_post_processor_real_set_successful (PostProcessor* base, gboolean value) {
	AllOutputPostProcessor* self;
	self = (AllOutputPostProcessor*) base;
	self->priv->_successful = value;
	g_object_notify ((GObject *) self, "successful");
}


static void all_output_post_processor_class_init (AllOutputPostProcessorClass * klass) {
	all_output_post_processor_parent_class = g_type_class_peek_parent (klass);
	g_type_class_add_private (klass, sizeof (AllOutputPostProcessorPrivate));
	G_OBJECT_CLASS (klass)->get_property = all_output_post_processor_get_property;
	G_OBJECT_CLASS (klass)->set_property = all_output_post_processor_set_property;
	G_OBJECT_CLASS (klass)->finalize = all_output_post_processor_finalize;
	g_object_class_override_property (G_OBJECT_CLASS (klass), ALL_OUTPUT_POST_PROCESSOR_SUCCESSFUL, "successful");
}


static void all_output_post_processor_post_processor_interface_init (PostProcessorIface * iface) {
	all_output_post_processor_post_processor_parent_iface = g_type_interface_peek_parent (iface);
	iface->process = all_output_post_processor_real_process;
	iface->get_issues = all_output_post_processor_real_get_issues;
	iface->get_successful = all_output_post_processor_real_get_successful;
	iface->set_successful = all_output_post_processor_real_set_successful;
}


static void all_output_post_processor_instance_init (AllOutputPostProcessor * self) {
	BuildIssue* _tmp0_ = NULL;
	self->priv = ALL_OUTPUT_POST_PROCESSOR_GET_PRIVATE (self);
	self->priv->issues = (_tmp0_ = g_new0 (BuildIssue, 0), _tmp0_);
	self->priv->issues_length1 = 0;
	self->priv->_issues_size_ = self->priv->issues_length1;
}


static void all_output_post_processor_finalize (GObject* obj) {
	AllOutputPostProcessor * self;
	self = ALL_OUTPUT_POST_PROCESSOR (obj);
	self->priv->issues = (_vala_BuildIssue_array_free (self->priv->issues, self->priv->issues_length1), NULL);
	G_OBJECT_CLASS (all_output_post_processor_parent_class)->finalize (obj);
}


GType all_output_post_processor_get_type (void) {
	static volatile gsize all_output_post_processor_type_id__volatile = 0;
	if (g_once_init_enter (&all_output_post_processor_type_id__volatile)) {
		static const GTypeInfo g_define_type_info = { sizeof (AllOutputPostProcessorClass), (GBaseInitFunc) NULL, (GBaseFinalizeFunc) NULL, (GClassInitFunc) all_output_post_processor_class_init, (GClassFinalizeFunc) NULL, NULL, sizeof (AllOutputPostProcessor), 0, (GInstanceInitFunc) all_output_post_processor_instance_init, NULL };
		static const GInterfaceInfo post_processor_info = { (GInterfaceInitFunc) all_output_post_processor_post_processor_interface_init, (GInterfaceFinalizeFunc) NULL, NULL};
		GType all_output_post_processor_type_id;
		all_output_post_processor_type_id = g_type_register_static (G_TYPE_OBJECT, "AllOutputPostProcessor", &g_define_type_info, 0);
		g_type_add_interface_static (all_output_post_processor_type_id, TYPE_POST_PROCESSOR, &post_processor_info);
		g_once_init_leave (&all_output_post_processor_type_id__volatile, all_output_post_processor_type_id);
	}
	return all_output_post_processor_type_id__volatile;
}


static void all_output_post_processor_get_property (GObject * object, guint property_id, GValue * value, GParamSpec * pspec) {
	AllOutputPostProcessor * self;
	self = ALL_OUTPUT_POST_PROCESSOR (object);
	switch (property_id) {
		case ALL_OUTPUT_POST_PROCESSOR_SUCCESSFUL:
		g_value_set_boolean (value, post_processor_get_successful ((PostProcessor*) self));
		break;
		default:
		G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
		break;
	}
}


static void all_output_post_processor_set_property (GObject * object, guint property_id, const GValue * value, GParamSpec * pspec) {
	AllOutputPostProcessor * self;
	self = ALL_OUTPUT_POST_PROCESSOR (object);
	switch (property_id) {
		case ALL_OUTPUT_POST_PROCESSOR_SUCCESSFUL:
		post_processor_set_successful ((PostProcessor*) self, g_value_get_boolean (value));
		break;
		default:
		G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
		break;
	}
}


RubberPostProcessor* rubber_post_processor_construct (GType object_type) {
	RubberPostProcessor * self = NULL;
	GError * _inner_error_ = NULL;
	self = (RubberPostProcessor*) g_object_new (object_type, NULL);
	if (rubber_post_processor_pattern == NULL) {
		{
			GRegex* _tmp0_;
			GRegex* _tmp1_;
			_tmp0_ = g_regex_new ("(?P<file>[^:\n]+)(:(?P<line>[0-9\\-]+))?:(?P<text>.+)$", G_REGEX_MULTILINE, 0, &_inner_error_);
			if (_inner_error_ != NULL) {
				if (_inner_error_->domain == G_REGEX_ERROR) {
					goto __catch29_g_regex_error;
				}
				g_critical ("file %s: line %d: unexpected error: %s (%s, %d)", __FILE__, __LINE__, _inner_error_->message, g_quark_to_string (_inner_error_->domain), _inner_error_->code);
				g_clear_error (&_inner_error_);
				return NULL;
			}
			rubber_post_processor_pattern = (_tmp1_ = _tmp0_, _g_regex_unref0 (rubber_post_processor_pattern), _tmp1_);
		}
		goto __finally29;
		__catch29_g_regex_error:
		{
			GError * e;
			e = _inner_error_;
			_inner_error_ = NULL;
			{
				fprintf (stderr, "Warning in RubberPostProcessor: %s\n", e->message);
				_g_error_free0 (e);
			}
		}
		__finally29:
		if (_inner_error_ != NULL) {
			g_critical ("file %s: line %d: uncaught error: %s (%s, %d)", __FILE__, __LINE__, _inner_error_->message, g_quark_to_string (_inner_error_->domain), _inner_error_->code);
			g_clear_error (&_inner_error_);
			return NULL;
		}
	}
	return self;
}


RubberPostProcessor* rubber_post_processor_new (void) {
	return rubber_post_processor_construct (TYPE_RUBBER_POST_PROCESSOR);
}


static gboolean string_contains (const char* self, const char* needle) {
	gboolean result = FALSE;
	g_return_val_if_fail (self != NULL, FALSE);
	g_return_val_if_fail (needle != NULL, FALSE);
	result = strstr (self, needle) != NULL;
	return result;
}


static void _vala_array_add12 (BuildIssue** array, int* length, int* size, const BuildIssue* value) {
	if ((*length) == (*size)) {
		*size = (*size) ? (2 * (*size)) : 4;
		*array = g_renew (BuildIssue, *array, *size);
	}
	(*array)[(*length)++] = *value;
}


static void rubber_post_processor_real_process (PostProcessor* base, GFile* file, const char* output, gint status) {
	RubberPostProcessor * self;
	GMatchInfo* match_info;
	GMatchInfo* _tmp0_ = NULL;
	GMatchInfo* _tmp1_;
	GError * _inner_error_ = NULL;
	self = (RubberPostProcessor*) base;
	g_return_if_fail (file != NULL);
	g_return_if_fail (output != NULL);
	post_processor_set_successful ((PostProcessor*) self, status == 0);
	if (rubber_post_processor_pattern == NULL) {
		return;
	}
	match_info = NULL;
	g_regex_match (rubber_post_processor_pattern, output, 0, &_tmp0_);
	match_info = (_tmp1_ = _tmp0_, _g_match_info_free0 (match_info), _tmp1_);
	while (TRUE) {
		BuildIssue issue = {0};
		char* _tmp2_;
		char* text;
		gboolean _tmp3_ = FALSE;
		char* line;
		gboolean _tmp4_ = FALSE;
		char* _tmp9_;
		BuildIssue _tmp13_ = {0};
		BuildIssue _tmp14_;
		if (!g_match_info_matches (match_info)) {
			break;
		}
		memset (&issue, 0, sizeof (BuildIssue));
		text = g_strdup (issue.message = (_tmp2_ = g_match_info_fetch_named (match_info, "text"), _g_free0 (issue.message), _tmp2_));
		issue.message_type = BUILD_MESSAGE_TYPE_ERROR;
		if (string_contains (text, "Underfull")) {
			_tmp3_ = TRUE;
		} else {
			_tmp3_ = string_contains (text, "Overfull");
		}
		if (_tmp3_) {
			issue.message_type = BUILD_MESSAGE_TYPE_BADBOX;
		}
		issue.start_line = issue.end_line = -1;
		line = g_match_info_fetch_named (match_info, "line");
		if (line != NULL) {
			_tmp4_ = string_get_length (line) > 0;
		} else {
			_tmp4_ = FALSE;
		}
		if (_tmp4_) {
			gint parts_length1;
			gint _parts_size_;
			char** _tmp6_;
			char** _tmp5_;
			char** parts;
			gboolean _tmp7_ = FALSE;
			gboolean _tmp8_ = FALSE;
			parts = (_tmp6_ = _tmp5_ = g_strsplit (line, "-", 0), parts_length1 = _vala_array_length (_tmp5_), _parts_size_ = parts_length1, _tmp6_);
			issue.start_line = atoi (parts[0]);
			if (parts_length1 > 1) {
				_tmp8_ = parts[1] != NULL;
			} else {
				_tmp8_ = FALSE;
			}
			if (_tmp8_) {
				_tmp7_ = string_get_length (parts[1]) > 0;
			} else {
				_tmp7_ = FALSE;
			}
			if (_tmp7_) {
				issue.end_line = atoi (parts[1]);
			}
			parts = (_vala_array_free (parts, parts_length1, (GDestroyNotify) g_free), NULL);
		}
		issue.filename = (_tmp9_ = g_match_info_fetch_named (match_info, "file"), _g_free0 (issue.filename), _tmp9_);
		if (g_utf8_get_char (g_utf8_offset_to_pointer (issue.filename, 0)) != '/') {
			GFile* _tmp10_;
			char* _tmp11_;
			char* _tmp12_;
			issue.filename = (_tmp12_ = g_strdup_printf ("%s/%s", _tmp11_ = g_file_get_parse_name (_tmp10_ = g_file_get_parent (file)), issue.filename), _g_free0 (issue.filename), _tmp12_);
			_g_free0 (_tmp11_);
			_g_object_unref0 (_tmp10_);
		}
		_vala_array_add12 (&self->priv->issues, &self->priv->issues_length1, &self->priv->_issues_size_, (_tmp14_ = (build_issue_copy (&issue, &_tmp13_), _tmp13_), &_tmp14_));
		{
			g_match_info_next (match_info, &_inner_error_);
			if (_inner_error_ != NULL) {
				if (_inner_error_->domain == G_REGEX_ERROR) {
					goto __catch30_g_regex_error;
				}
				_g_free0 (line);
				_g_free0 (text);
				build_issue_destroy (&issue);
				_g_match_info_free0 (match_info);
				g_critical ("file %s: line %d: unexpected error: %s (%s, %d)", __FILE__, __LINE__, _inner_error_->message, g_quark_to_string (_inner_error_->domain), _inner_error_->code);
				g_clear_error (&_inner_error_);
				return;
			}
		}
		goto __finally30;
		__catch30_g_regex_error:
		{
			GError * e;
			e = _inner_error_;
			_inner_error_ = NULL;
			{
				fprintf (stderr, "Warning: RubberPostProcessor: %s\n", e->message);
				_g_error_free0 (e);
				_g_free0 (line);
				_g_free0 (text);
				build_issue_destroy (&issue);
				break;
			}
		}
		__finally30:
		if (_inner_error_ != NULL) {
			_g_free0 (line);
			_g_free0 (text);
			build_issue_destroy (&issue);
			_g_match_info_free0 (match_info);
			g_critical ("file %s: line %d: uncaught error: %s (%s, %d)", __FILE__, __LINE__, _inner_error_->message, g_quark_to_string (_inner_error_->domain), _inner_error_->code);
			g_clear_error (&_inner_error_);
			return;
		}
		_g_free0 (line);
		_g_free0 (text);
		build_issue_destroy (&issue);
	}
	_g_match_info_free0 (match_info);
}


static BuildIssue* _vala_array_dup5 (BuildIssue* self, int length) {
	BuildIssue* result;
	int i;
	BuildIssue _tmp0_ = {0};
	result = g_new0 (BuildIssue, length);
	for (i = 0; i < length; i++) {
		result[i] = (build_issue_copy (&self[i], &_tmp0_), _tmp0_);
	}
	return result;
}


static BuildIssue* rubber_post_processor_real_get_issues (PostProcessor* base, int* result_length1) {
	RubberPostProcessor * self;
	BuildIssue* result = NULL;
	BuildIssue* _tmp0_;
	BuildIssue* _tmp1_;
	self = (RubberPostProcessor*) base;
	result = (_tmp1_ = (_tmp0_ = self->priv->issues, (_tmp0_ == NULL) ? ((gpointer) _tmp0_) : _vala_array_dup5 (_tmp0_, self->priv->issues_length1)), *result_length1 = self->priv->issues_length1, _tmp1_);
	return result;
}


static gboolean rubber_post_processor_real_get_successful (PostProcessor* base) {
	gboolean result;
	RubberPostProcessor* self;
	self = (RubberPostProcessor*) base;
	result = self->priv->_successful;
	return result;
}


static void rubber_post_processor_real_set_successful (PostProcessor* base, gboolean value) {
	RubberPostProcessor* self;
	self = (RubberPostProcessor*) base;
	self->priv->_successful = value;
	g_object_notify ((GObject *) self, "successful");
}


static void rubber_post_processor_class_init (RubberPostProcessorClass * klass) {
	rubber_post_processor_parent_class = g_type_class_peek_parent (klass);
	g_type_class_add_private (klass, sizeof (RubberPostProcessorPrivate));
	G_OBJECT_CLASS (klass)->get_property = rubber_post_processor_get_property;
	G_OBJECT_CLASS (klass)->set_property = rubber_post_processor_set_property;
	G_OBJECT_CLASS (klass)->finalize = rubber_post_processor_finalize;
	g_object_class_override_property (G_OBJECT_CLASS (klass), RUBBER_POST_PROCESSOR_SUCCESSFUL, "successful");
}


static void rubber_post_processor_post_processor_interface_init (PostProcessorIface * iface) {
	rubber_post_processor_post_processor_parent_iface = g_type_interface_peek_parent (iface);
	iface->process = rubber_post_processor_real_process;
	iface->get_issues = rubber_post_processor_real_get_issues;
	iface->get_successful = rubber_post_processor_real_get_successful;
	iface->set_successful = rubber_post_processor_real_set_successful;
}


static void rubber_post_processor_instance_init (RubberPostProcessor * self) {
	BuildIssue* _tmp0_ = NULL;
	self->priv = RUBBER_POST_PROCESSOR_GET_PRIVATE (self);
	self->priv->issues = (_tmp0_ = g_new0 (BuildIssue, 0), _tmp0_);
	self->priv->issues_length1 = 0;
	self->priv->_issues_size_ = self->priv->issues_length1;
}


static void rubber_post_processor_finalize (GObject* obj) {
	RubberPostProcessor * self;
	self = RUBBER_POST_PROCESSOR (obj);
	self->priv->issues = (_vala_BuildIssue_array_free (self->priv->issues, self->priv->issues_length1), NULL);
	G_OBJECT_CLASS (rubber_post_processor_parent_class)->finalize (obj);
}


GType rubber_post_processor_get_type (void) {
	static volatile gsize rubber_post_processor_type_id__volatile = 0;
	if (g_once_init_enter (&rubber_post_processor_type_id__volatile)) {
		static const GTypeInfo g_define_type_info = { sizeof (RubberPostProcessorClass), (GBaseInitFunc) NULL, (GBaseFinalizeFunc) NULL, (GClassInitFunc) rubber_post_processor_class_init, (GClassFinalizeFunc) NULL, NULL, sizeof (RubberPostProcessor), 0, (GInstanceInitFunc) rubber_post_processor_instance_init, NULL };
		static const GInterfaceInfo post_processor_info = { (GInterfaceInitFunc) rubber_post_processor_post_processor_interface_init, (GInterfaceFinalizeFunc) NULL, NULL};
		GType rubber_post_processor_type_id;
		rubber_post_processor_type_id = g_type_register_static (G_TYPE_OBJECT, "RubberPostProcessor", &g_define_type_info, 0);
		g_type_add_interface_static (rubber_post_processor_type_id, TYPE_POST_PROCESSOR, &post_processor_info);
		g_once_init_leave (&rubber_post_processor_type_id__volatile, rubber_post_processor_type_id);
	}
	return rubber_post_processor_type_id__volatile;
}


static void rubber_post_processor_get_property (GObject * object, guint property_id, GValue * value, GParamSpec * pspec) {
	RubberPostProcessor * self;
	self = RUBBER_POST_PROCESSOR (object);
	switch (property_id) {
		case RUBBER_POST_PROCESSOR_SUCCESSFUL:
		g_value_set_boolean (value, post_processor_get_successful ((PostProcessor*) self));
		break;
		default:
		G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
		break;
	}
}


static void rubber_post_processor_set_property (GObject * object, guint property_id, const GValue * value, GParamSpec * pspec) {
	RubberPostProcessor * self;
	self = RUBBER_POST_PROCESSOR (object);
	switch (property_id) {
		case RUBBER_POST_PROCESSOR_SUCCESSFUL:
		post_processor_set_successful ((PostProcessor*) self, g_value_get_boolean (value));
		break;
		default:
		G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
		break;
	}
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


static gint _vala_array_length (gpointer array) {
	int length;
	length = 0;
	if (array) {
		while (((gpointer*) array)[length]) {
			length++;
		}
	}
	return length;
}



