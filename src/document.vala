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

using Gtk;

public enum SelectionType
{
    NO_SELECTION,
    ONE_LINE,
    MULTIPLE_LINES
}

public class Document : Gtk.SourceBuffer
{
    public File location { get; set; }
    public bool readonly { get; set; default = false; }
    public DocumentTab tab;
    public uint _unsaved_doc_num = 0;
    public int project_id { get; set; default = -1; }
    private bool backup_made = false;
    private string _etag;
    private string? encoding = null;
    private bool new_file = true;
    private DocumentStructure _structure = null;

    public signal void cursor_moved ();

    public Document ()
    {
        // syntax highlighting: LaTeX by default
        var lm = Gtk.SourceLanguageManager.get_default ();
        set_language (lm.get_language ("latex"));

        notify["location"].connect (() =>
        {
            update_syntax_highlighting ();
            update_project_id ();
        });

        mark_set.connect ((location, mark) =>
        {
            if (mark == get_insert ())
                cursor_moved ();
        });

        changed.connect (() =>
        {
            new_file = false;
            cursor_moved ();
        });
    }

    public new bool get_modified ()
    {
        if (new_file)
            return false;

        return base.get_modified ();
    }

    public new void insert (ref TextIter iter, string text, int len)
    {
        Gtk.SourceCompletion completion = tab.view.completion;
        completion.block_interactive ();

        base.insert (ref iter, text, len);

        // HACK: wait one second before delocking completion, it's better than doing a
        // Utils.flush_queue ().
        Timeout.add_seconds (1, () =>
        {
            completion.unblock_interactive ();
            return false;
        });
    }

    public void load (File location)
    {
        this.location = location;

        try
        {
            uint8[] chars;
            location.load_contents (null, out chars, out _etag);
            string text = (string) (owned) chars;

            if (text.validate ())
                set_contents (text);

            // convert to UTF-8
            else
            {
                string utf8_text = to_utf8 (text);
                set_contents (utf8_text);
            }

            update_syntax_highlighting ();

            RecentManager.get_default ().add_item (location.get_uri ());
        }
        catch (Error e)
        {
            warning ("%s", e.message);

            string primary_msg = _("Impossible to load the file '%s'.")
                .printf (location.get_parse_name ());
            tab.add_message (primary_msg, e.message, MessageType.ERROR);
        }
        
        //Updates the structure at the loading of the document.
        get_structure();
    }

    public void set_contents (string contents)
    {
        // if last character is a new line, don't display it
        string? contents2 = null;
        if (contents[contents.length - 1] == '\n')
            contents2 = contents[0:-1];

        begin_not_undoable_action ();
        set_text (contents2 ?? contents, -1);
        new_file = true;
        set_modified (false);
        end_not_undoable_action ();

        // move the cursor at the first line
        TextIter iter;
        get_start_iter (out iter);
        place_cursor (iter);
    }

    public void save (bool check_file_changed_on_disk = true, bool force = false)
    {
        return_if_fail (location != null);

        // if not modified, don't save
        if (! force && ! new_file && ! get_modified ())
            return;

        // we use get_text () to exclude undisplayed text
        TextIter start, end;
        get_bounds (out start, out end);
        string text = get_text (start, end, false);

        // the last character must be \n
        if (text[text.length - 1] != '\n')
            text = @"$text\n";

        try
        {
            GLib.Settings settings =
                new GLib.Settings ("org.gnome.latexila.preferences.editor");
            bool make_backup = ! backup_made
                && settings.get_boolean ("create-backup-copy");

            string? etag = check_file_changed_on_disk ? _etag : null;

            // if encoding specified, convert to this encoding
            if (encoding != null)
                text = convert (text, (ssize_t) text.length, encoding, "UTF-8");

            // else, convert to the system default encoding
            else
                text = Filename.from_utf8 (text, (ssize_t) text.length, null, null);

            // check if parent directories exist, if not, create it
            File parent = location.get_parent ();
            if (parent != null && ! parent.query_exists ())
                parent.make_directory_with_parents ();

            location.replace_contents (text.data, etag, make_backup,
                FileCreateFlags.NONE, out _etag, null);

            set_modified (false);

            RecentManager.get_default ().add_item (location.get_uri ());
            backup_made = true;
        }
        catch (Error e)
        {
            if (e is IOError.WRONG_ETAG)
            {
                string primary_msg = _("The file %s has been modified since reading it.")
                    .printf (location.get_parse_name ());
                string secondary_msg =
                    _("If you save it, all the external changes could be lost. Save it anyway?");
                TabInfoBar infobar = tab.add_message (primary_msg, secondary_msg,
                    MessageType.WARNING);
                infobar.add_button (_("_Save Anyway"), ResponseType.YES);
                infobar.add_button (_("_Don't Save"), ResponseType.CANCEL);
                infobar.response.connect ((response_id) =>
                {
                    if (response_id == ResponseType.YES)
                        save (false);
                    infobar.destroy ();
                });
            }
            else
            {
                warning ("%s", e.message);

                string primary_msg = _("Impossible to save the file.");
                TabInfoBar infobar = tab.add_message (primary_msg, e.message,
                    MessageType.ERROR);
                infobar.add_ok_button ();
            }
        }
    }

    private string to_utf8 (string text) throws ConvertError
    {
        foreach (string charset in Encodings.CHARSETS)
        {
            try
            {
                string utf8_text = convert (text, (ssize_t) text.length, "UTF-8",
                    charset);
                encoding = charset;
                return utf8_text;
            }
            catch (ConvertError e)
            {
                continue;
            }
        }
        throw new GLib.ConvertError.FAILED (
            _("Error trying to convert the document to UTF-8"));
    }

    private void update_syntax_highlighting ()
    {
        Gtk.SourceLanguageManager lm = Gtk.SourceLanguageManager.get_default ();
        string content_type = null;
        try
        {
            FileInfo info = location.query_info (FileAttribute.STANDARD_CONTENT_TYPE,
                FileQueryInfoFlags.NONE, null);
            content_type = info.get_content_type ();
        }
        catch (Error e) {}

        var lang = lm.guess_language (location.get_parse_name (), content_type);
        set_language (lang);
    }

    private void update_project_id ()
    {
        int i = 0;
        foreach (Project project in Projects.get_default ())
        {
            if (location.has_prefix (project.directory))
            {
                project_id = i;
                return;
            }
            i++;
        }

        project_id = -1;
    }

    public string get_uri_for_display ()
    {
        if (location == null)
            return get_unsaved_document_name ();

        return Latexila.utils_replace_home_dir_with_tilde (location.get_parse_name ());
    }

    public string get_short_name_for_display ()
    {
        if (location == null)
            return get_unsaved_document_name ();

        return location.get_basename ();
    }

    private string get_unsaved_document_name ()
    {
        uint num = get_unsaved_document_num ();
        return _("Unsaved Document") + @" $num";
    }

    private uint get_unsaved_document_num ()
    {
        return_val_if_fail (location == null, 0);

        if (_unsaved_doc_num > 0)
            return _unsaved_doc_num;

        // get all unsaved document numbers
        uint[] all_nums = {};
        foreach (Document doc in LatexilaApp.get_instance ().get_documents ())
        {
            // avoid infinite loop
            if (doc == this)
                continue;

            if (doc.location == null)
                all_nums += doc.get_unsaved_document_num ();
        }

        // take the first free num
        uint num;
        for (num = 1 ; num in all_nums ; num++);

        _unsaved_doc_num = num;
        return num;
    }

    public bool is_local ()
    {
        if (location == null)
            return false;
        return location.has_uri_scheme ("file");
    }

    public bool is_externally_modified ()
    {
        if (location == null)
            return false;

        string current_etag = null;
        try
        {
            FileInfo file_info = location.query_info (FileAttribute.ETAG_VALUE,
                FileQueryInfoFlags.NONE, null);
            current_etag = file_info.get_etag ();
        }
        catch (GLib.Error e)
        {
            return false;
        }

        return current_etag != null && current_etag != _etag;
    }

    public void set_style_scheme_from_string (string scheme_id)
    {
        SourceStyleSchemeManager manager = SourceStyleSchemeManager.get_default ();
        style_scheme = manager.get_scheme (scheme_id);
    }

    public void comment_selected_lines ()
    {
        TextIter start;
        TextIter end;
        get_selection_bounds (out start, out end);

        comment_between (start, end);
    }

    // comment the lines between start_iter and end_iter included
    public void comment_between (TextIter start_iter, TextIter end_iter,
        bool end_iter_set = true)
    {
        int start_line = start_iter.get_line ();
        int end_line = start_line;

        if (end_iter_set)
            end_line = end_iter.get_line ();

        TextIter cur_iter;
        get_iter_at_line (out cur_iter, start_line);

        begin_user_action ();

        for (int line_num = start_line ; line_num <= end_line ; line_num++)
        {
            if (cur_iter.ends_line ())
                // Don't insert a trailing space.
                insert (ref cur_iter, "%", -1);
            else
                insert (ref cur_iter, "% ", -1);

            cur_iter.forward_line ();
        }

        end_user_action ();
    }

    public void uncomment_selected_lines ()
    {
        TextIter start, end;
        get_selection_bounds (out start, out end);

        int start_line = start.get_line ();
        int end_line = end.get_line ();
        int line_count = get_line_count ();

        begin_user_action ();

        for (int i = start_line ; i <= end_line ; i++)
        {
            get_iter_at_line (out start, i);

            // if last line
            if (i == line_count - 1)
                get_end_iter (out end);
            else
                get_iter_at_line (out end, i + 1);

            string line = get_text (start, end, false);

            /* find the first '%' character */
            int j = 0;
            int start_delete = -1;
            int stop_delete = -1;
            while (line[j] != '\0')
            {
                if (line[j] == '%')
                {
                    start_delete = j;
                    stop_delete = j + 1;
                    if (line[j + 1] == ' ')
                        stop_delete++;
                    break;
                }

                else if (line[j] != ' ' && line[j] != '\t')
                    break;

                j++;
            }

            if (start_delete == -1)
                continue;

            get_iter_at_line_offset (out start, i, start_delete);
            get_iter_at_line_offset (out end, i, stop_delete);
            this.delete (ref start, ref end);
        }

        end_user_action ();
    }

    public void select_lines (int start, int end)
    {
        TextIter start_iter, end_iter;
        get_iter_at_line (out start_iter, start);
        get_iter_at_line (out end_iter, end);
        select_range (start_iter, end_iter);
        tab.view.scroll_to_cursor ();
    }

    public SelectionType get_selection_type ()
    {
        if (! has_selection)
            return SelectionType.NO_SELECTION;

        TextIter start, end;
        get_selection_bounds (out start, out end);
        if (start.get_line () == end.get_line ())
            return SelectionType.ONE_LINE;

        return SelectionType.MULTIPLE_LINES;
    }

    // If line is bigger than the number of lines of the document, the cursor is moved
    // to the last line and false is returned.
    public bool goto_line (int line)
    {
        return_val_if_fail (line >= -1, false);

        bool ret = true;
        TextIter iter;

        if (line >= get_line_count ())
        {
            ret = false;
            get_end_iter (out iter);
        }
        else
            get_iter_at_line (out iter, line);

        place_cursor (iter);
        return ret;
    }

    public Project? get_project ()
    {
        if (project_id == -1)
            return null;

        return Projects.get_default ().get (project_id);
    }

    public File? get_main_file ()
    {
        if (location == null)
            return null;

        Project? project = get_project ();
        if (project == null)
            return location;

        return project.main_file;
    }

    public bool is_main_file_a_tex_file ()
    {
        File? main_file = get_main_file ();
        if (main_file == null)
            return false;

        string path = main_file.get_parse_name ();
        return path.has_suffix (".tex");
    }

    public string get_current_indentation (TextIter iter)
    {
        TextIter start_iter, end_iter;
        int line = iter.get_line ();
        get_iter_at_line (out start_iter, line);
        get_iter_at_line (out end_iter, line + 1);

        string text = get_text (start_iter, end_iter, false);
        string current_indent = "";

        int index = 0;
        unichar cur_char;
        while (text.get_next_char (ref index, out cur_char))
        {
            if (cur_char == ' ' || cur_char == '\t')
                current_indent += cur_char.to_string ();
            else
                break;
        }

        return current_indent;
    }

    public DocumentStructure get_structure ()
    {
        if (_structure == null)
        {
            _structure = new DocumentStructure (this);
            _structure.parse ();
        }
        return _structure;
    }

    public bool set_tmp_location ()
    {
        /* Create a temporary directory (most probably in /tmp/) */
        string template = "latexila-XXXXXX";
        string tmp_dir;

        try
        {
            tmp_dir = DirUtils.make_tmp (template);
        }
        catch (FileError e)
        {
            warning ("Impossible to create temporary directory: %s", e.message);
            return false;
        }

        /* Set the location as 'tmp.tex' in the temporary directory */
        this.location = File.new_for_path (Path.build_filename (tmp_dir, "tmp.tex"));

        /* Warn the user that the file can be lost */

        TabInfoBar infobar = tab.add_message (
            _("The file has a temporary location. The data can be lost after rebooting your computer."),
            _("Do you want to save the file in a safer place?"),
            MessageType.WARNING);

        infobar.add_button (_("Save _As"), ResponseType.YES);
        infobar.add_button (_("Cancel"), ResponseType.NO);

        infobar.response.connect ((response_id) =>
        {
            if (response_id == ResponseType.YES)
            {
                unowned MainWindow? main_window =
                    Utils.get_toplevel_window (tab) as MainWindow;

                if (main_window != null)
                    main_window.save_document (this, true);
            }

            infobar.destroy ();
        });

        return true;
    }
}
