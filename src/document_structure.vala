/*
 * This file is part of LaTeXila.
 *
 * Copyright © 2011-2012 Sébastien Wilmet
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

// Model: structure_model.vala
// View: structure.vala
// Controller: document_structure.vala

public class DocumentStructure : GLib.Object
{
    // For a figure or table environment, because all the data can not be inserted at once
    private struct EnvData
    {
        TreePath path;
        StructType type;
        string? first_caption;
    }

    private unowned Document _doc;
    private int _nb_marks = 0;
    private static const string MARK_NAME_PREFIX = "struct_item_";
    private TextMark? _end_document_mark = null;
    
    //Default completion provider shared with the other documents.
    private CompletionProvider provider = CompletionProvider.get_default();
	//Contains the labels of the document as strings. Is given to the completion provider.
	private Gee.HashSet<CompletionProvider.CompletionChoice?> 
	  _label_completion_choices = new Gee.HashSet<CompletionProvider.CompletionChoice?>();

    private StructureModel _model = null;

    private static Regex? _chars_regex = null;
    private static Regex? _comment_regex = null;
    private static Regex? _command_name_regex = null;

    private bool _in_verbatim_env = false;

    private EnvData? _last_env_data = null;

    // Only captions, TODOs and FIXMEs are truncated if needed, because the other
    // items are normally short enough.
    private static const int ITEM_MAX_LENGTH = 60;

    private static const int MAX_NB_LINES_TO_PARSE = 2000;
    private int _start_parsing_line = 0;
    private static const bool _measure_parsing_time = false;
    private Timer _timer = null;

    private static string[] _section_names = null;

    public bool parsing_done { get; private set; default = false; }

	public void drop_label_completion_choices()
	{
		//Notifies the CompletionProvider that the label completion choices
		//are being updated.
		provider.set_labels_modified(true);
		provider.set_last_dir(find_directory());
		_label_completion_choices.clear();
	}
	
	public void add_label_completion_choice(string content)
	{
		CompletionProvider.CompletionChoice c = CompletionProvider.CompletionChoice();
		c.name = content;
		_label_completion_choices.add(c);
	}
	
	//Returns the path of the enclosing directory for this document.
	//Used to filter the completion choices.
	public string find_directory()
	{
		string path = _doc.location.get_parse_name();
		string base_name = _doc.location.get_basename();
		string dir = path.replace("/"+base_name, "");
		
		return dir;
	}
	
	//Updates the label completion choices of the completion provider, for this document.
	public void update_label_completion_choices_from_file()
	{		
		string file_path = _doc.location.get_parse_name();
		
		if(!provider.get_labels_from_files().has_key(file_path))
		{
			provider.get_labels_from_files().@set(file_path, _label_completion_choices);
		}
		else
		{
			provider.get_labels_from_files()[file_path] = _label_completion_choices;
		}
	}

    public DocumentStructure (Document doc)
    {
        _doc = doc;

        if (_chars_regex != null)
            return;

        try
        {
            _chars_regex = new Regex ("\\\\|%");

            _comment_regex = new Regex ("^(?P<type>TODO|FIXME)\\s+:?\\s*(?P<text>.*)$",
                RegexCompileFlags.OPTIMIZE);

            // Stop at the first argument, which can be optional (a '[').
            // To find the first non-optional argument, it's more robust to do it
            // character by character.
            _command_name_regex = new Regex ("^(?P<name>[a-z]+\\*?)\\s*(\\[|{)",
                RegexCompileFlags.OPTIMIZE);
        }
        catch (RegexError e)
        {
            warning ("Structure: %s", e.message);
        }
    }

	public void parse ()
    {	
		// reset
        parsing_done = false;
        _model = new StructureModel ();
        _last_env_data = null;
        _start_parsing_line = 0;

        _end_document_mark = null;
        clear_all_structure_marks ();

        Idle.add (() =>
        {
            return parse_impl ();
        });
    }

    public StructureModel get_model ()
    {
        return _model;
    }

    /*************************************************************************/
    // Parsing stuff

    // Parse the document. Returns false if finished, true otherwise.
    private bool parse_impl ()
    {
		//Reset of the label completion choices for this document.
		drop_label_completion_choices();
		
        if (_measure_parsing_time)
        {
            if (_timer == null)
                _timer = new Timer ();
            else
                _timer.continue ();
        }

        // The parsing is done line-by-line.
        TextIter line_iter;
        _doc.get_iter_at_line (out line_iter, _start_parsing_line);

        int nb_lines_parsed = 0;

        do
        {
            // If it's a big document, the parsing is split into several chunks,
            // so the UI is not frozen.
            if (nb_lines_parsed == MAX_NB_LINES_TO_PARSE)
            {
                _start_parsing_line += MAX_NB_LINES_TO_PARSE;

                if (_measure_parsing_time)
                    _timer.stop ();

                return true;
            }

            // get the text of the current line
            string line_text = get_line_contents_at_iter (line_iter);

            // in one line there could be several items
            int start_index = 0;
            int line_length = line_text.length;
            while (start_index < line_length)
            {
                StructType? type;
                string? contents;
                int? start_match_index;
                int? end_match_index;

                bool item_found = search_low_level_item (line_text, start_index, out type,
                    out contents, out start_match_index, out end_match_index);

                if (! item_found)
                    break;

                TextIter iter = line_iter;
                iter.set_line_index (start_match_index);
                handle_item (type, contents, iter);

                start_index = end_match_index;
            }

            nb_lines_parsed++;
        }
        while (line_iter.forward_line ());

        if (_measure_parsing_time)
        {
            _timer.stop ();
            message ("Structure parsing took %f seconds", _timer.elapsed ());
            _timer.reset ();
        }

		//Updates the label compleiton choices of the completion provider.
		update_label_completion_choices_from_file();
		
        parsing_done = true;
        return false;
    }

    // Search a "low-level" item in 'line'. The "high-level" items displayed in the
    // structure can be composed of several low-level items, for example a figure is
    // composed of \begin{figure}, the first \caption{} and \end{figure}.
    //
    // Begin the search at 'start_index'.
    // Returns true if an item has been found, false otherwise.
    // With the out arguments we can fetch the information we are intersted in.
    private bool search_low_level_item (string line, int start_index,
        out StructType? type, out string? contents,
        out int? start_match_index, out int? end_match_index)
    {
        type = null;
        contents = null;
        start_match_index = null;
        end_match_index = null;

        /* search the character '\' or '%' */
        MatchInfo match_info;
        try
        {
            _chars_regex.match_full (line, -1, start_index, 0, out match_info);
        }
        catch (Error e)
        {
            warning ("Structure parsing: chars regex: %s", e.message);
            return false;
        }

        while (match_info.matches ())
        {
            int after_char_index;
            if (! match_info.fetch_pos (0, out start_match_index, out after_char_index))
            {
                warning ("Structure parsing: position can not be fetched");
                return false;
            }

            if (! Utils.char_is_escaped (line, start_match_index))
            {
                string char_matched = match_info.fetch (0);

                // search markup (begin with a backslash)
                if (char_matched == "\\")
                {
                    bool markup_found = search_markup (line, after_char_index, out type,
                        out contents, out end_match_index);

                    if (markup_found)
                        return true;
                }

                // search comments (begin with '%')
                else
                {
                    // It is possible to comment a TODO or a FIXME, for example:
                    // % %TODO tout doux
                    // When we find the first '%', we directly return false. The second
                    // '%' won't be found.
                    return search_comment (line, after_char_index, out type, out contents,
                        out end_match_index);
                }
            }

            try
            {
                match_info.next ();
            }
            catch (RegexError e)
            {
                warning ("Structure parsing: %s", e.message);
                break;
            }
        }

        return false;
    }

    private bool search_markup (string line, int after_backslash_index,
        out StructType? type, out string? contents, out int? end_match_index)
    {
        type = null;
        contents = null;
        end_match_index = null;

        /* get markup name */
        int? begin_contents_index;
        string? name = get_markup_name (line, after_backslash_index,
            out begin_contents_index);

        if (name == null)
            return false;

        /* environment */
        bool is_begin_env = name == "begin";
        if (is_begin_env || name == "end")
        {
            contents = null;
            return search_env (line, begin_contents_index, is_begin_env, out type,
                out end_match_index);
        }

        /* simple markup */
        type = get_markup_type (name);
        if (type == null)
            return false;

        contents = get_markup_contents (line, begin_contents_index, out end_match_index);
        
        /* test label */
        if (type == StructType.LABEL) {
			//For each encountered label, populates the HashSet.
			add_label_completion_choice(contents);
		}
        
        return contents != null;
    }

    private bool search_env (string line, int begin_contents_index, bool is_begin_env,
        out StructType? type, out int? end_match_index)
    {
        type = null;

        string? contents = get_markup_contents (line, begin_contents_index,
            out end_match_index);

        if (contents == null)
            return false;

        if (contents == "verbatim" || contents == "verbatim*")
        {
            type = is_begin_env ? StructType.BEGIN_VERBATIM : StructType.END_VERBATIM;
            return true;
        }

        if (contents == "figure")
        {
            type = is_begin_env ? StructType.BEGIN_FIGURE : StructType.END_FIGURE;
            return true;
        }

        if (contents == "table")
        {
            type = is_begin_env ? StructType.BEGIN_TABLE : StructType.END_TABLE;
            return true;
        }

        if (contents == "document" && ! is_begin_env)
        {
            type = StructType.END_DOCUMENT;
            return true;
        }

        return false;
    }

    // Try to get the markup name (between '\' and '{').
    private string? get_markup_name (string line, int after_backslash_index,
        out int? begin_contents_index = null)
    {
        begin_contents_index = null;

        /* Get the markup name */
        string after_backslash_text = line.substring (after_backslash_index);

        MatchInfo match_info;
        if (! _command_name_regex.match (after_backslash_text, 0, out match_info))
            return null;

        int pos;
        match_info.fetch_pos (0, null, out pos);
        int begin_first_arg_index = after_backslash_index + pos;

        string markup_name = match_info.fetch_named ("name");

        /* Search begin_contents_index */
        if (search_firt_non_optional_arg (line, begin_first_arg_index - 1,
            out begin_contents_index))
        {
            return markup_name;
        }

        return null;
    }

    // line[start_index] must be equal to '{' or '['
    private bool search_firt_non_optional_arg (string line, int start_index,
        out int begin_contents_index)
    {
        begin_contents_index = 0;

        int cur_index = start_index;
        bool in_optional_arg = false;
        int additional_bracket_level = 0;

        while (true)
        {
            int next_index = cur_index;
            unichar cur_char;
            bool end = ! line.get_next_char (ref next_index, out cur_char);

            if (in_optional_arg)
            {
                switch (cur_char)
                {
                    case ']':
                        if (! Utils.char_is_escaped (line, cur_index))
                        {
                            if (0 < additional_bracket_level)
                                additional_bracket_level--;
                            else
                                in_optional_arg = false;
                        }
                        break;

                    case '[':
                        if (! Utils.char_is_escaped (line, cur_index))
                            additional_bracket_level++;
                        break;
                }
            }

            // not in an argument
            else
            {
                switch (cur_char)
                {
                    case '{':
                        begin_contents_index = next_index;
                        return true;

                    case '[':
                        in_optional_arg = true;
                        break;

                    case ' ':
                    case '\t':
                        break;

                    default:
                        return false;
                }
            }

            if (end)
                return false;

            cur_index = next_index;
        }
    }

    // Get the contents between '{' and the corresponding '}'.
    private string? get_markup_contents (string line, int begin_contents_index,
        out int? end_match_index)
    {
        end_match_index = null;

        int brace_level = 0;
        int cur_index = begin_contents_index;

        while (true)
        {
            int next_index = cur_index;
            unichar cur_char;
            bool end = ! line.get_next_char (ref next_index, out cur_char);

            if (cur_char == '{' && ! Utils.char_is_escaped (line, cur_index))
                brace_level++;

            else if (cur_char == '}' && ! Utils.char_is_escaped (line, cur_index))
            {
                if (brace_level > 0)
                    brace_level--;

                // found!
                else
                {
                    string contents = line[begin_contents_index : cur_index];

                    // but empty
                    if (contents == "")
                        return null;

                    end_match_index = next_index;

                    return contents;
                }
            }

            if (end)
                return null;

            cur_index = next_index;
        }
    }

    private bool search_comment (string line, int after_percent_index,
        out StructType? type, out string? contents, out int? end_match_index)
    {
        type = null;
        contents = null;
        end_match_index = null;

        string text_after = line.substring (after_percent_index).strip ();

        MatchInfo match_info;
        if (! _comment_regex.match (text_after, 0, out match_info))
            return false;

        string type_str = match_info.fetch_named ("type");
        type = type_str == "TODO" ? StructType.TODO : StructType.FIXME;

        contents = match_info.fetch_named ("text");
        end_match_index = line.length;

        return true;
    }

    private void handle_item (StructType type, string? contents, TextIter iter)
    {
        // we are currently in a verbatim env
        if (_in_verbatim_env)
        {
            if (type == StructType.END_VERBATIM)
                _in_verbatim_env = false;

            return;
        }

        if (type == StructType.TODO || type == StructType.FIXME)
            add_item (type, truncate (contents) ?? contents, iter);

        // the low-level type is common with the high-level type
        else if (Structure.is_common_type (type))
            add_item (type, contents, iter);

        // begin of a verbatim env
        else if (type == StructType.BEGIN_VERBATIM)
            _in_verbatim_env = true;

        // begin of a figure or table env
        else if (type == StructType.BEGIN_FIGURE || type == StructType.BEGIN_TABLE)
            create_new_environment (type, iter);

        // a caption (we take only the first)
        else if (type == StructType.CAPTION && _last_env_data != null
            && _last_env_data.first_caption == null)
        {
            _last_env_data.first_caption = truncate (contents) ?? contents;
        }

        // end of a figure or table env
        else if (verify_end_environment_type (type))
        {
            TextMark end_mark = create_text_mark_from_iter (iter);
            _model.modify_data (_last_env_data.path, _last_env_data.first_caption,
                end_mark);
            _last_env_data = null;
        }

        // end of the document
        else if (type == StructType.END_DOCUMENT)
            _end_document_mark = create_text_mark_from_iter (iter);
    }

    private void create_new_environment (StructType type, TextIter start_iter)
    {
        return_if_fail (type == StructType.BEGIN_FIGURE
            || type == StructType.BEGIN_TABLE);

        _last_env_data = EnvData ();
        _last_env_data.first_caption = null;

        if (type == StructType.BEGIN_TABLE)
            _last_env_data.type = StructType.TABLE;
        else
            _last_env_data.type = StructType.FIGURE;

        TreeIter tree_iter = add_item (_last_env_data.type, null, start_iter);
        _last_env_data.path = _model.get_path (tree_iter);
    }

    private bool verify_end_environment_type (StructType type)
    {
        if (_last_env_data == null)
            return false;

        if (type == StructType.END_TABLE)
            return _last_env_data.type == StructType.TABLE;

        if (type == StructType.END_FIGURE)
            return _last_env_data.type == StructType.FIGURE;

        return false;
    }

    private TreeIter? add_item (StructType type, string? text, TextIter start_iter)
    {
        StructData data = {};
        data.type = type;
        data.text = text;
        data.start_mark = create_text_mark_from_iter (start_iter);
        data.end_mark = null;

        return add_item_data (data);
    }

    private TreeIter? add_item_data (StructData data)
    {
        if (data.text == null)
            data.text = "";

        return _model.add_item_at_end (data);
    }

    private TextMark create_text_mark_from_iter (TextIter iter)
    {
        TextBuffer doc = iter.get_buffer ();
        string name = MARK_NAME_PREFIX + _nb_marks.to_string ();
        TextMark mark = doc.create_mark (name, iter, false);
        _nb_marks++;

        return mark;
    }

    private void clear_all_structure_marks ()
    {
        for (int i = 0 ; i < _nb_marks ; i++)
        {
            string mark_name = MARK_NAME_PREFIX + i.to_string ();
            TextMark? mark = _doc.get_mark (mark_name);
            if (mark != null)
                _doc.delete_mark (mark);
        }

        _nb_marks = 0;
    }

    // return null if the truncation is not needed
    private string? truncate (string? text)
    {
        if (text == null)
            return null;

        if (text.char_count () <= ITEM_MAX_LENGTH)
            return null;

        int index = text.index_of_nth_char (ITEM_MAX_LENGTH);
        return text.substring (0, index);
    }

    private StructType? get_markup_type (string markup_name)
    {
        switch (markup_name)
        {
            case "part":
            case "part*":
                return StructType.PART;

            case "chapter":
            case "chapter*":
                return StructType.CHAPTER;

            case "section":
            case "section*":
                return StructType.SECTION;

            case "subsection":
            case "subsection*":
                return StructType.SUBSECTION;

            case "subsubsection":
            case "subsubsection*":
                return StructType.SUBSUBSECTION;

            case "paragraph":
            case "paragraph*":
                return StructType.PARAGRAPH;

            case "subparagraph":
            case "subparagraph*":
                return StructType.SUBPARAGRAPH;

            case "label":
                return StructType.LABEL;

            case "input":
            case "include":
                return StructType.INCLUDE;

            case "includegraphics":
                return StructType.IMAGE;

            case "caption":
                return StructType.CAPTION;

            default:
                return null;
        }
    }

    private string get_line_contents_at_iter (TextIter iter)
    {
        TextIter begin_line = iter;
        begin_line.set_line_offset (0);

        TextIter end_line = iter;
        if (! iter.ends_line ())
            end_line.forward_to_line_end ();

        TextBuffer buffer = iter.get_buffer ();
        return buffer.get_text (begin_line, end_line, false);
    }

    /*************************************************************************/
    // Actions: cut, copy, delete, select, comment, shift left/right

    public void do_action (StructAction action_type, TreeIter tree_iter,
        out bool refresh_simple_list) throws StructError
    {
        refresh_simple_list = false;

        /* Comment */

        if (action_type == StructAction.COMMENT)
        {
            if (! comment_item (tree_iter))
                throw new StructError.DATA_OUTDATED ("");

            _model.delete (tree_iter);
            refresh_simple_list = true;
            return;
        }

        /* Shift left/right */

        bool shift_right = action_type == StructAction.SHIFT_RIGHT;
        if (shift_right || action_type == StructAction.SHIFT_LEFT)
        {
            if (shift_right && _model.item_contains_subparagraph (tree_iter))
                throw new StructError.GENERAL (
                    _("The structure item already contains a sub-paragraph."));

            _doc.begin_user_action ();
            bool doc_modified;
            bool success = shift_item (tree_iter, shift_right, out doc_modified);
            _doc.end_user_action ();

            if (! success)
            {
                if (doc_modified)
                    _doc.undo ();

                throw new StructError.DATA_OUTDATED ("");
            }

            if (shift_right)
                _model.shift_right (tree_iter);
            else
                _model.shift_left (tree_iter);
            return;
        }

        /* Select, copy, cut and delete */

        TextIter start_iter;
        TextIter end_iter;
        bool found = get_exact_item_bounds (tree_iter, out start_iter, out end_iter);

        if (! found)
            throw new StructError.DATA_OUTDATED ("");

        if (start_iter.get_line () != end_iter.get_line ())
        {
            backward_indentation (ref start_iter);
            backward_indentation (ref end_iter);
        }

        if (action_type == StructAction.SELECT)
        {
            _doc.select_range (start_iter, end_iter);
            return;
        }

        if (action_type == StructAction.COPY || action_type == StructAction.CUT)
        {
            string data = _doc.get_text (start_iter, end_iter, false);
            Clipboard clipboard = Clipboard.get (Gdk.SELECTION_CLIPBOARD);
            clipboard.set_text (data, -1);
        }

        if (action_type == StructAction.DELETE || action_type == StructAction.CUT)
        {
            _doc.begin_user_action ();
            _doc.delete (ref start_iter, ref end_iter);
            _doc.end_user_action ();

            _model.delete (tree_iter);
            refresh_simple_list = true;
        }
    }

    // Returns true only if the item is correctly commented
    private bool comment_item (TreeIter tree_iter)
    {
        StructType type;
        TextMark start_mark = null;
        TextMark end_mark = null;

        _model.get (tree_iter,
            StructColumn.TYPE, out type,
            StructColumn.START_MARK, out start_mark,
            StructColumn.END_MARK, out end_mark,
            -1);

        TextIter start_iter;
        TextIter end_iter = {};
        bool end_iter_set = false;

        _doc.get_iter_at_mark (out start_iter, start_mark);

        if (end_mark != null)
        {
            _doc.get_iter_at_mark (out end_iter, end_mark);
            end_iter_set = true;
        }

        /* comment a simple item */
        if (! Structure.is_section (type))
        {
            _doc.comment_between (start_iter, end_iter, end_iter_set);
            return true;
        }

        /* comment a section */

        // get next sibling or parent
        TreeIter? next_section_iter = null;
        try
        {
            next_section_iter = _model.get_next_sibling_or_parent (tree_iter);
        }
        catch (StructError e)
        {
            warning ("Structure: get next sibling or parent: %s", e.message);
            return false;
        }

        bool go_one_line_backward = true;

        // the end of the section is the end of the document
        if (next_section_iter == null)
        {
            bool end_of_file;
            end_iter = get_end_document_iter (out end_of_file);
            end_iter_set = true;
            go_one_line_backward = ! end_of_file;
        }

        else
        {
            _model.get (next_section_iter,
                StructColumn.START_MARK, out end_mark,
                -1);

            _doc.get_iter_at_mark (out end_iter, end_mark);
            end_iter_set = true;
        }

        if (go_one_line_backward)
        {
            if (! end_iter.backward_line ())
                end_iter_set = false;
        }

        _doc.comment_between (start_iter, end_iter, end_iter_set);
        return true;
    }

    // Returns true only if the bounds are correctly set.
    private bool get_exact_item_bounds (TreeIter tree_iter, out TextIter start_iter,
        out TextIter end_iter)
    {
        /* get item data */
        StructType item_type;
        TextMark start_mark = null;
        TextMark end_mark = null;
        string item_contents = null;

        _model.get (tree_iter,
            StructColumn.TYPE, out item_type,
            StructColumn.START_MARK, out start_mark,
            StructColumn.END_MARK, out end_mark,
            StructColumn.TEXT, out item_contents,
            -1);

        /* search 'start_iter' */
        _doc.get_iter_at_mark (out start_iter, start_mark);

        // Place 'end_iter' to the end of the low level type. If it's not the good place,
        // it will be changed below.
        bool found = get_low_level_item_bounds (item_type, item_contents, start_iter,
            true, out end_iter);

        if (! found)
            return false;

        /* search 'end_iter' */

        // a section
        if (Structure.is_section (item_type))
        {
            TreeIter? next_section_iter = null;
            try
            {
                next_section_iter = _model.get_next_sibling_or_parent (tree_iter);
            }
            catch (StructError e)
            {
                warning ("Structure: get next sibling or parent: %s", e.message);
                return false;
            }

            // the end of the section is the end of the document
            if (next_section_iter == null)
            {
                end_iter = get_end_document_iter ();
                return true;
            }

            _model.get (next_section_iter,
                StructColumn.TYPE, out item_type,
                StructColumn.START_MARK, out start_mark,
                StructColumn.TEXT, out item_contents,
                -1);

            _doc.get_iter_at_mark (out end_iter, start_mark);

            return get_low_level_item_bounds (item_type, item_contents, end_iter, true,
                null);
        }

        // another common type: the end iter is already at the good place
        else if (Structure.is_common_type (item_type))
            return true;

        // an environment
        if (end_mark == null)
            return false;

        TextIter end_env_iter;
        _doc.get_iter_at_mark (out end_env_iter, end_mark);

        return get_low_level_item_bounds (item_type, item_contents, end_env_iter, false,
            out end_iter);
    }

    private bool get_low_level_item_bounds (StructType item_type, string item_contents,
        TextIter start_match_iter, bool is_start, out TextIter end_match_iter)
    {
        end_match_iter = {};

        string line = get_line_contents_at_iter (start_match_iter);

        /* parse the line */
        int start_index = start_match_iter.get_line_index ();
        StructType? low_level_type;
        string? contents;
        int? start_match_index;
        int? end_match_index;

        bool found = search_low_level_item (line, start_index, out low_level_type,
            out contents, out start_match_index, out end_match_index);

        // If an item is found, it should be located at exactly the same place.
        if (! found || start_index != start_match_index)
            return false;

        if (contents == null)
            contents = "";

        // compare the item found with the structure item
        if (same_items (item_type, item_contents, low_level_type, contents, is_start))
        {
            end_match_iter = start_match_iter;
            end_match_iter.set_line_index (end_match_index);
            return true;
        }

        return false;
    }

    // Compare a structure item with another low-level item
    // If 'start' is true, and if the structure item is an environment, a \begin{} is
    // expected. Otherwise, a \end{} is expected.
    private bool same_items (StructType item_type, string item_contents,
        StructType item_found_type, string item_found_contents, bool start)
    {
        if (Structure.is_common_type (item_found_type))
        {
            bool same_type = item_type == item_found_type;
            bool same_contents = item_contents == item_found_contents;
            return same_type && same_contents;
        }

        if (item_type == StructType.FIGURE)
        {
            if (start)
                return item_found_type == StructType.BEGIN_FIGURE;
            else
                return item_found_type == StructType.END_FIGURE;
        }

        if (item_type == StructType.TABLE)
        {
            if (start)
                return item_found_type == StructType.BEGIN_TABLE;
            else
                return item_found_type == StructType.END_TABLE;
        }

        return false;
    }

    // Take into account \end{document}
    private TextIter get_end_document_iter (out bool end_of_file = null)
    {
        if (_end_document_mark != null)
        {
            end_of_file = false;
            TextIter end_document_iter;
            _doc.get_iter_at_mark (out end_document_iter, _end_document_mark);
            return end_document_iter;
        }

        end_of_file = true;
        TextIter eof_iter;
        _doc.get_end_iter (out eof_iter);
        return eof_iter;
    }

    // If there are some spaces between the beginning of the line and the iter, move
    // the iter at the beginning of the line.
    private void backward_indentation (ref TextIter iter)
    {
        if (iter.starts_line ())
            return;

        int line_num = iter.get_line ();
        TextIter begin_line_iter;
        _doc.get_iter_at_line (out begin_line_iter, line_num);

        string text_between = _doc.get_text (begin_line_iter, iter, false);
        if (text_between.strip () == "")
            iter = begin_line_iter;
    }

    private bool shift_item (TreeIter tree_iter, bool shift_right,
        out bool doc_modified = null)
    {
        doc_modified = false;

        /* Get some data about the item */
        StructType type;
        TextMark mark;
        _model.get (tree_iter,
            StructColumn.TYPE, out type,
            StructColumn.START_MARK, out mark);

        if (shift_right)
            return_val_if_fail (type != StructType.SUBPARAGRAPH, false);
        else
            return_val_if_fail (type != StructType.PART, false);

        if (! Structure.is_section (type))
            return true;

        /* Get the markup name, do some checks, etc. */
        TextIter text_iter;
        _doc.get_iter_at_mark (out text_iter, mark);

        string line = get_line_contents_at_iter (text_iter);

        int backslash_index = text_iter.get_line_index ();
        if (line[backslash_index] != '\\')
            return false;

        int after_backslash_index = backslash_index + 1;
        string? markup_name = get_markup_name (line, after_backslash_index);
        if (markup_name == null)
            return false;

        StructType? markup_type = get_markup_type (markup_name);
        if (markup_type == null)
            return false;

        // TODO remove this hack when the bug is fixed.
        // See https://bugzilla.gnome.org/show_bug.cgi?id=678791
        StructType markup_type_hack = markup_type;
        if ((int) type != (int) markup_type_hack)
            return false;

        /* Get the new markup name */
        bool with_star = markup_name.has_suffix ("*");

        StructType new_type;
        if (shift_right)
            new_type = type + 1;
        else
            new_type = type - 1;

        string? new_markup_name = get_section_name_from_type (new_type);
        return_val_if_fail (new_markup_name != null, false);

        if (with_star)
            new_markup_name += "*";

        /* Replace the markup name */
        TextIter begin_markup_name_iter = text_iter;
        begin_markup_name_iter.set_line_index (after_backslash_index);

        TextIter end_markup_name_iter = text_iter;
        end_markup_name_iter.set_line_index (after_backslash_index + markup_name.length);

        _doc.delete (ref begin_markup_name_iter, ref end_markup_name_iter);
        _doc.insert (ref begin_markup_name_iter, new_markup_name, -1);
        doc_modified = true;

        /* Do the same for all the children */
        int nb_children = _model.iter_n_children (tree_iter);
        for (int child_num = 0 ; child_num < nb_children ; child_num++)
        {
            TreeIter child_iter;
            bool child_iter_set = _model.iter_nth_child (out child_iter, tree_iter,
                child_num);
            return_val_if_fail (child_iter_set, false);

            if (! shift_item (child_iter, shift_right))
                return false;
        }

        return true;
    }

    private string? get_section_name_from_type (StructType type)
    {
        if (_section_names == null)
        {
            _section_names = new string[7];
            _section_names[StructType.PART]             = "part";
            _section_names[StructType.CHAPTER]          = "chapter";
            _section_names[StructType.SECTION]          = "section";
            _section_names[StructType.SUBSECTION]       = "subsection";
            _section_names[StructType.SUBSUBSECTION]    = "subsubsection";
            _section_names[StructType.PARAGRAPH]        = "paragraph";
            _section_names[StructType.SUBPARAGRAPH]     = "subparagraph";
        }

        return_val_if_fail (Structure.is_section (type), null);

        return _section_names[type];
    }
}
