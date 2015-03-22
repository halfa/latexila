/*
 * This file is part of LaTeXila.
 *
 * Copyright © 2010-2012 Sébastien Wilmet
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

using Gtk;

public class FileBrowser : Grid
{
    private enum ParentDirColumn
    {
        PIXBUF,
        NAME,
        FILE,
        N_COLUMNS
    }

    private enum FileColumn
    {
        PIXBUF,
        NAME,
        IS_DIR,
        N_COLUMNS
    }

    private unowned MainWindow _main_window;

    private Gtk.ListStore _parent_dir_store;
    private ComboBox _combo_box;

    private Gtk.ListStore _list_store;
    private TreeView _list_view;

    private File _current_directory;
    private FileMonitor _monitor;

    private ToolButton _parent_button;
    private GLib.Settings _settings;
    private GLib.Settings _latex_settings;
    private uint _timeout_id = 0;

    public FileBrowser (MainWindow main_window)
    {
        _main_window = main_window;

        orientation = Orientation.VERTICAL;

        init_settings ();
        init_combo_box ();
        init_toolbar ();
        init_list ();

        show_all ();
        set_directory (get_default_directory ());
    }

    /*************************************************************************/
    // Init functions

    private void init_settings ()
    {
        _settings = new GLib.Settings ("org.gnome.latexila.preferences.file-browser");
        _settings.changed["show-build-files"].connect (refresh);
        _settings.changed["show-hidden-files"].connect (refresh);

        _latex_settings = new GLib.Settings ("org.gnome.latexila.preferences.latex");
        _latex_settings.changed["clean-extensions"].connect (delayed_refresh);
    }

    // list of parent directories
    private void init_combo_box ()
    {
        _parent_dir_store = new Gtk.ListStore (ParentDirColumn.N_COLUMNS,
            typeof (string),    // pixbuf (icon-name)
            typeof (string),    // directory name
            typeof (File)
        );

        _combo_box = new ComboBox.with_model (_parent_dir_store);
        _combo_box.margin_end = 3;
        add (_combo_box);

        // pixbuf
        CellRendererPixbuf pixbuf_renderer = new CellRendererPixbuf ();
        _combo_box.pack_start (pixbuf_renderer, false);
        _combo_box.set_attributes (pixbuf_renderer,
            "icon-name", ParentDirColumn.PIXBUF);

        // directory name
        CellRendererText text_renderer = new CellRendererText ();
        _combo_box.pack_start (text_renderer, true);
        _combo_box.set_attributes (text_renderer, "text", ParentDirColumn.NAME);
        text_renderer.ellipsize_set = true;
        text_renderer.ellipsize = Pango.EllipsizeMode.END;

        _combo_box.changed.connect (() =>
        {
            TreeIter iter;
            if (_combo_box.get_active_iter (out iter))
            {
                TreeModel model = _combo_box.get_model ();
                File file;
                model.get (iter, ParentDirColumn.FILE, out file);

                set_directory (file);
            }
        });
    }

    // list of files and directories
    private void init_list ()
    {
        _list_store = new Gtk.ListStore (FileColumn.N_COLUMNS,
            typeof (string),    // pixbuf (icon-name)
            typeof (string),    // filename
            typeof (bool)       // is directory
        );

        _list_store.set_sort_func (0, on_sort);
        _list_store.set_sort_column_id (0, SortType.ASCENDING);

        _list_view = new TreeView.with_model (_list_store);
        _list_view.headers_visible = false;
        _list_view.expand = true;

        ScrolledWindow scrolled_window = Utils.add_scrollbar (_list_view);
        scrolled_window.set_shadow_type (ShadowType.IN);
        add (scrolled_window);

        TreeViewColumn column = new TreeViewColumn ();
        _list_view.append_column (column);

        // icon
        CellRendererPixbuf pixbuf_renderer = new CellRendererPixbuf ();
        column.pack_start (pixbuf_renderer, false);
        column.set_attributes (pixbuf_renderer, "icon-name", FileColumn.PIXBUF);

        // filename
        CellRendererText text_renderer = new CellRendererText ();
        column.pack_start (text_renderer, true);
        column.set_attributes (text_renderer, "text", FileColumn.NAME);

        _list_view.row_activated.connect ((path) =>
        {
            TreeModel model = _list_store as TreeModel;
            TreeIter iter;
            if (! model.get_iter (out iter, path))
                return;

            string basename;
            bool is_dir;
            model.get (iter,
                FileColumn.NAME, out basename,
                FileColumn.IS_DIR, out is_dir
            );

            File file = _current_directory.get_child (basename);

            if (is_dir)
            {
                set_directory (file);
                return;
            }

            string extension = Latexila.utils_get_extension (basename);
            if (extension != ".dvi" &&
                extension != ".pdf" &&
                extension != ".ps")
            {
                _main_window.open_document (file);
                return;
            }

            try
            {
                Latexila.utils_show_uri (this.get_screen (), file.get_uri (), Gdk.CURRENT_TIME);
            }
            catch (Error e)
            {
                warning ("Impossible to open the file '%s': %s",
                    file.get_uri (), e.message);
            }
        });
    }

    private void init_toolbar ()
    {
        Toolbar toolbar = new Toolbar ();
        toolbar.set_icon_size (IconSize.MENU);
        toolbar.set_style (ToolbarStyle.ICONS);

        toolbar.insert (get_home_button (), -1);
        toolbar.insert (get_parent_button (), -1);
        toolbar.insert (get_jump_button (), -1);
        toolbar.insert (get_open_directory_button (), -1);
        toolbar.insert (get_properties_button (), -1);

        add (toolbar);
    }

    private ToolButton get_home_button ()
    {
        ToolButton home_button = new ToolButton (null, null);
        home_button.icon_name = "go-home";
        home_button.tooltip_text = _("Go to the home directory");

        home_button.clicked.connect (() =>
        {
            File home_dir = File.new_for_path (Environment.get_home_dir ());
            set_directory (home_dir);
        });

        return home_button;
    }

    private ToolButton get_parent_button ()
    {
        _parent_button = new ToolButton (null, null);
        _parent_button.icon_name = "go-up";
        _parent_button.tooltip_text = _("Go to the parent directory");

        _parent_button.clicked.connect (() =>
        {
            File? parent = _current_directory.get_parent ();
            return_if_fail (parent != null);
            set_directory (parent);
        });

        return _parent_button;
    }

    private ToolButton get_jump_button ()
    {
        ToolButton jump_button = new ToolButton (null, null);
        jump_button.icon_name = "go-jump";
        jump_button.tooltip_text = _("Go to the active document directory");

        jump_button.clicked.connect (() =>
        {
            return_if_fail (_main_window.active_tab != null);
            return_if_fail (_main_window.active_document.location != null);

            set_directory (_main_window.active_document.location.get_parent ());
        });

        // sensitivity
        _main_window.notify["active-document"].connect (() =>
        {
            update_jump_button_sensitivity (jump_button);

            // update when location changes
            if (_main_window.active_document != null)
            {
                _main_window.active_document.notify["location"].connect (() =>
                {
                    update_jump_button_sensitivity (jump_button);
                });
            }
        });

        return jump_button;
    }

    private ToolButton get_open_directory_button ()
    {
        ToolButton open_directory_button = new ToolButton (null, null);
        open_directory_button.icon_name = "document-open";
        open_directory_button.tooltip_text =
            _("Open the current directory in a file manager");

        open_directory_button.clicked.connect (() =>
        {
            return_if_fail (_current_directory != null);

            try
            {
                Latexila.utils_show_uri (this.get_screen (),
                    _current_directory.get_uri (), Gdk.CURRENT_TIME);
            }
            catch (Error error)
            {
                handle_error (error);
            }
        });

        return open_directory_button;
    }

    private ToolButton get_properties_button ()
    {
        /* Show build files */

        CheckMenuItem show_build_files =
            new CheckMenuItem.with_label (_("Show build files"));

        _settings.bind ("show-build-files", show_build_files, "active",
            SettingsBindFlags.DEFAULT);

        /* Show hidden files */

        CheckMenuItem show_hidden_files =
            new CheckMenuItem.with_label (_("Show hidden files"));

        _settings.bind ("show-hidden-files", show_hidden_files, "active",
            SettingsBindFlags.DEFAULT);

        /* Menu */

        Gtk.Menu menu = new Gtk.Menu ();
        menu.append (show_build_files);
        menu.append (show_hidden_files);
        menu.show_all ();

        /* Tool button */

        ToolButton button = new ToolButton (null, null);
        button.icon_name = "document-properties";

        button.clicked.connect (() =>
        {
            menu.popup (null, null, null, 0, get_current_event_time ());
        });

        return button;
    }

    /*************************************************************************/
    // Update the list of parent directories and the list of files

    private void update_parent_directories ()
    {
        _parent_dir_store.clear ();

        Gee.List<File> parent_dirs = new Gee.LinkedList<File> ();
        parent_dirs.add (_current_directory);
        File? parent = _current_directory.get_parent ();

        while (parent != null)
        {
            parent_dirs.insert (0, parent);
            parent = parent.get_parent ();
        }

        int depth = 0;
        foreach (File parent_dir in parent_dirs)
        {
            // basename
            string basename;
            if (depth == 0)
                basename = _("File System");
            else
                basename = parent_dir.get_basename ();

            // pixbuf
            string pixbuf;
            if (depth == 0)
                pixbuf = "drive-harddisk";
            else if (Environment.get_home_dir () == parent_dir.get_path ())
                pixbuf = "go-home";
            else
                pixbuf = "folder";

            // insert
            TreeIter iter;
            _parent_dir_store.append (out iter);
            _parent_dir_store.set (iter,
                ParentDirColumn.FILE, parent_dir,
                ParentDirColumn.NAME, basename,
                ParentDirColumn.PIXBUF, pixbuf
            );

            depth++;
        }

        // select the last parent directory
        _combo_box.set_active (depth - 1);
    }

    private void update_list ()
    {
        _list_store.clear ();
        _list_view.columns_autosize ();

        /* Get settings */

        bool show_build_files = _settings.get_boolean ("show-build-files");
        bool show_hidden_files = _settings.get_boolean ("show-hidden-files");

        string exts = _latex_settings.get_string ("clean-extensions");
        string[] clean_extensions = exts.split (" ");

        /* Get the directory enumerator */

        FileEnumerator enumerator;
        try
        {
            enumerator = _current_directory.enumerate_children (
                "standard::type,standard::display-name", FileQueryInfoFlags.NONE);
        }
        catch (Error error)
        {
            handle_error (error);
            return;
        }

        /* Enumerate the directory */

        while (true)
        {
            FileInfo? info;
            try
            {
                info = enumerator.next_file ();
            }
            catch (Error error)
            {
                handle_error (error);
                return;
            }

            if (info == null)
                break;

            string basename = info.get_display_name ();
            if (basename[0] == '.' && ! show_hidden_files)
                continue;

            FileType type = info.get_file_type ();
            if (type == FileType.DIRECTORY)
            {
                insert_file (true, "folder", basename);
                continue;
            }

            if (! show_build_files)
            {
                bool is_build_file = false;

                foreach (string ext in clean_extensions)
                {
                    if (basename.has_suffix (ext))
                    {
                        is_build_file = true;
                        break;
                    }
                }

                if (is_build_file)
                    continue;
            }

            string extension = Latexila.utils_get_extension (basename);
            string icon_name = get_extension_icon_name (extension);
            insert_file (false, icon_name, basename);
        }

        _list_store.sort_column_changed ();
    }

    private void handle_error (Error error)
    {
        warning ("File browser: %s", error.message);

        // Warning dialog
        MessageDialog dialog = new MessageDialog (_main_window,
            DialogFlags.DESTROY_WITH_PARENT,
            MessageType.WARNING,
            ButtonsType.CLOSE,
            "%s", _("File Browser"));

        dialog.format_secondary_text ("%s", error.message);
        dialog.run ();
        dialog.destroy ();
    }

    private void insert_file (bool is_dir, string icon_name, string basename)
    {
        TreeIter iter;
        _list_store.append (out iter);
        _list_store.set (iter,
            FileColumn.IS_DIR, is_dir,
            FileColumn.PIXBUF, icon_name,
            FileColumn.NAME, basename
        );
    }

    private void monitor_directory ()
    {
        if (_current_directory == null)
        {
            _monitor = null;
            return;
        }

        try
        {
            _monitor = _current_directory.monitor_directory (FileMonitorFlags.NONE);
        }
        catch (IOError e)
        {
            warning ("Can not refresh automatically the file browser: %s", e.message);
            return;
        }

        _monitor.changed.connect (refresh);
    }

    /*************************************************************************/
    // Misc

    private void refresh ()
    {
        set_directory (_current_directory, true);
    }

    private void delayed_refresh ()
    {
        // Call refresh () only after one second.
        // If this function is called a second time during the second, the second is
        // reinitialized.
        if (_timeout_id != 0)
            Source.remove (_timeout_id);

        _timeout_id = Timeout.add_seconds (1, () =>
        {
            _timeout_id = 0;
            refresh ();
            return false;
        });
    }

    // Get the previous directory saved in GSettings, or the user home directory as
    // a fallback.
    private File get_default_directory ()
    {
        string? uri = _settings.get_string ("current-directory");

        if (uri != null && uri != "")
        {
            File directory = File.new_for_uri (uri);

            if (directory.query_exists ())
                return directory;
        }

        return File.new_for_path (Environment.get_home_dir ());
    }

    private void set_directory (File directory, bool force = false)
    {
        if (! force && _current_directory == directory)
            return;

        _current_directory = directory;
        _settings.set_string ("current-directory", directory.get_uri ());
        _parent_button.set_sensitive (directory.get_parent () != null);

        update_parent_directories ();
        update_list ();
        monitor_directory ();
    }

    private void update_jump_button_sensitivity (ToolButton jump_button)
    {
        jump_button.sensitive = _main_window.active_tab != null
            && _main_window.active_document.location != null;
    }

    private int on_sort (TreeModel model, TreeIter a, TreeIter b)
    {
        bool a_is_dir, b_is_dir;
        model.get (a, FileColumn.IS_DIR, out a_is_dir);
        model.get (b, FileColumn.IS_DIR, out b_is_dir);

        if (a_is_dir == b_is_dir)
        {
            string a_name, b_name;
            model.get (a, FileColumn.NAME, out a_name);
            model.get (b, FileColumn.NAME, out b_name);
            return a_name.collate (b_name);
        }

        return a_is_dir ? -1 : +1;
    }

    private string get_extension_icon_name (string file_extension)
    {
        switch (file_extension)
        {
            case ".tex":
                return Stock.EDIT; // TODO find a replacement

            case ".pdf":
                return "latexila-pdf";

            case ".dvi":
                return "latexila-dvi";

            case ".ps":
            case ".eps":
                return "latexila-ps";

            case ".png":
            case ".jpg":
            case ".jpeg":
            case ".gif":
            case ".bmp":
            case ".tif":
            case ".tiff":
                return "image-x-generic";

            default:
                return "text-x-generic";
        }
    }
}
