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
 *
 * Authors: Sébastien Wilmet
 *          Pieter Pareit
 */

using Gtk;

public class CompletionProvider : GLib.Object, SourceCompletionProvider
{
    struct CompletionCommand
    {
        string name;
        string? package;
        CompletionArgument[] args;
    }

    struct CompletionArgument
    {
        string label;
        bool optional;
        CompletionChoice[] choices;
    }

    public struct CompletionChoice
    {
        string name;
        string? package;
        string? insert;
        string? insert_after;
    }

    struct ArgumentContext
    {
        string cmd_name;
        string arg_contents;

        // After the command name, list the arguments types encountered.
        // The last one is the argument where the cursor is.
        // The value is 'true' for an optional argument.
        Gee.ArrayList<bool> args_types;
    }

    private static CompletionProvider _instance = null;

    private GLib.Settings _settings;

    private List<SourceCompletionItem> _proposals;
    private Gee.HashMap<string, CompletionCommand?> _commands;
    // contains only environments that have extra info
    private Gee.HashMap<string, CompletionChoice?> _environments;

	//contains the \label completion choices for the \ref command.
	//key is the absolute path of the parsed file.
	private Gee.HashMap<string, Gee.HashSet<CompletionChoice?>> 
	  _labels_from_files = new Gee.HashMap<string, Gee.HashSet<CompletionChoice?>>();
	
	//Boolean used to update the label completion choices only when relevant.
	//String used to filter only the relevant completion choices for the 'current' document.
	//We gain a lot of efficiency compared to the last version.
	private bool _labels_modified = false;
	private string _last_dir = "";
	
    // While parsing the XML file, keep track of current command/argument/choice.
    private CompletionCommand _current_command;
    private CompletionArgument _current_arg;
    private CompletionChoice _current_choice;

    private Gdk.Pixbuf? _icon_cmd;
    private Gdk.Pixbuf? _icon_choice;
    private Gdk.Pixbuf? _icon_package_required;

    private SourceCompletionInfo _calltip_window = null;
    private Label _calltip_window_label = null;

	//Used by document_structure instances.
	//Could be avoided, if the attribute was made public.
	public Gee.HashMap<string, Gee.HashSet<CompletionChoice?>> get_labels_from_files()
	{
		return _labels_from_files;
	}
	
	//Creates the array of completion choices for the 'current' project only, from the HashMap.
	public CompletionChoice[] get_all_labels(string dir)
	{
		CompletionChoice[] choices = {};
		
		foreach(var entry in _labels_from_files.entries)
		{
			if(entry.key.has_prefix(dir))
			{
				foreach(CompletionChoice c in entry.value)
				{
					choices += c;
				}
			}
		}
		
		return choices;
	}
	
	//Called to update the completion choices provided for the \ref command.
	//Populates the choices for the current project only.
	public void update_label_completion_choices()
	{
		if(_last_dir != "")
		{
			CompletionChoice[] choices = get_all_labels(_last_dir);
			CompletionCommand cmd_ref = _commands["\\ref"];
			cmd_ref.args[0].choices = choices;
			_commands["\\ref"] = cmd_ref;
			set_labels_modified(false);
		}
	}
	
	public void set_labels_modified(bool b)
	{
		_labels_modified = b;
	}
	
	public void set_last_dir(string dir)
	{
		_last_dir = dir;
	}

    /* CompletionProvider is a singleton */
    private CompletionProvider ()
    {
        _settings = new GLib.Settings ("org.gnome.latexila.preferences.latex");

        // icons
        _icon_cmd = Latexila.utils_get_pixbuf_from_icon_name ("completion_cmd",
            IconSize.MENU);
        _icon_choice = Latexila.utils_get_pixbuf_from_icon_name ("gray-square",
            IconSize.MENU);
        _icon_package_required = Latexila.utils_get_pixbuf_from_icon_name ("dialog-warning",
            IconSize.MENU);

        load_data ();
    }

    public static CompletionProvider get_default ()
    {
        if (_instance == null)
            _instance = new CompletionProvider ();

        return _instance;
    }

    public string get_name ()
    {
        return "LaTeX";
    }
    
    public SourceCompletionActivation get_activation ()
    {
        var activation = SourceCompletionActivation.USER_REQUESTED;

        if (_settings.get_boolean ("interactive-completion"))
            activation |= SourceCompletionActivation.INTERACTIVE;

        return activation;
    }

    public bool match (SourceCompletionContext context)
    {
        TextIter iter;

        if (!context.get_iter (out iter))
            return false;

        // if text selected, NO completion
        TextBuffer buf = iter.get_buffer ();
        if (buf.has_selection)
            return false;

        return true;
    }

    public bool get_start_iter (SourceCompletionContext context,
        SourceCompletionProposal proposal, out TextIter iter)
    {
        iter = {};
        string? cmd = get_latex_command_at_iter (context.iter);

        // In a LaTeX command argument, use the default implementation.
        if (cmd == null)
            return false;

        // Custom implementation when in a LaTeX command name.
        iter = context.iter;

        TextIter prev = iter;
        if (prev.backward_char () && prev.get_char () == '\\')
        {
            iter = prev;
            return true;
        }

        if (! iter.starts_word ())
            iter.backward_visible_word_start ();

        prev = iter;
        if (prev.backward_char () && prev.get_char () == '\\')
            iter = prev;

        return true;
    }

    /*************************************************************************/
    // Populate: match() has returned true, now show the matches.

    public void populate (SourceCompletionContext context)
    {
        TextIter iter;
		
		//If the label completion choices were modified, even for other projects, 
		//updates the completion choices for the \ref command.
		if(_labels_modified)
			update_label_completion_choices();
		
        if (!context.get_iter (out iter))
        {
            show_no_proposals (context);
            return;
        }

        // Is the cursor in a command name?
        string? cmd = get_latex_command_at_iter (iter);

        if (cmd != null)
        {
            populate_command (context, cmd);
            return;
        }

        // Is the cursor in a command's argument?
        ArgumentContext info;
        bool in_arg = in_latex_command_argument (iter, out info);

        if (in_arg)
        {
            populate_argument (context, info);
            return;
        }

        // Neither in a command name, nor an argument.
        if (is_user_request (context))
            show_all_proposals (context);
        else
            show_no_proposals (context);
    }

    private void populate_command (SourceCompletionContext context, string cmd)
    {
        if (! is_user_request (context))
        {
            uint min_nb_chars;
            _settings.get ("interactive-completion-num", "u", out min_nb_chars);

            if (cmd.length <= min_nb_chars)
            {
                show_no_proposals (context);
                return;
            }
        }

        if (cmd == "\\")
        {
            show_all_proposals (context);
            return;
        }

        show_filtered_proposals (context, _proposals, cmd);
    }

    private void populate_argument (SourceCompletionContext context, ArgumentContext info)
    {
        // invalid argument's command
        if (! _commands.has_key (info.cmd_name))
        {
            show_no_proposals (context);
            return;
        }

        unowned List<SourceCompletionItem> proposals_to_filter =
            get_argument_proposals (info);

        if (proposals_to_filter == null)
        {
            if (is_user_request (context))
                show_calltip_cmd_prototype (info.cmd_name, info.args_types);
            else
                show_no_proposals (context);
            return;
        }

        show_filtered_proposals (context, proposals_to_filter, info.arg_contents);
    }

    private unowned List<SourceCompletionItem>? get_argument_proposals (
        ArgumentContext arg_context)
    {
        return_val_if_fail (_commands.has_key (arg_context.cmd_name), null);

        CompletionCommand cmd = _commands[arg_context.cmd_name];
        string cmd_info = get_command_info (cmd);

        int arg_num = get_argument_num (cmd.args, arg_context.args_types);
        if (arg_num == -1)
            return null;

        CompletionArgument arg = cmd.args[arg_num - 1];
        unowned List<SourceCompletionItem> items = null;

        foreach (CompletionChoice choice in arg.choices)
        {
            Gdk.Pixbuf pixbuf;
            string? arg_info = null;
            if (choice.package != null)
            {
                pixbuf = _icon_package_required;
                arg_info = cmd_info + "\nPackage: " + choice.package;
            }
            else
                pixbuf = _icon_choice;

            SourceCompletionItem item = new SourceCompletionItem (
                choice.name, choice.name, pixbuf, arg_info ?? cmd_info);
            items.prepend (item);
        }

        if (items == null)
            return null;

        items.sort ((CompareFunc) compare_proposals);
        return items;
    }

    // It has the same effect as returning false in match().
    private void show_no_proposals (SourceCompletionContext context)
    {
        context.add_proposals ((SourceCompletionProvider) this, null, true);
    }

    private void show_all_proposals (SourceCompletionContext context)
    {
        context.add_proposals ((SourceCompletionProvider) this, _proposals, true);
    }

    private void show_filtered_proposals (SourceCompletionContext context,
        List<SourceCompletionItem> proposals_to_filter, string? prefix)
    {
        // No filtering needed.
        if (prefix == null || prefix == "")
        {
            context.add_proposals ((SourceCompletionProvider) this,
                proposals_to_filter, true);
            return;
        }

        // TODO this is a O(n) time complexity. This could be reduced to a O(log n) by
        // using a GSequence for example, like it is done by the words completion provider
        // in GtkSourceView.
        List<SourceCompletionItem> filtered_proposals = null;
        foreach (SourceCompletionItem item in proposals_to_filter)
        {
            if (item.text.has_prefix (prefix))
                filtered_proposals.prepend (item);
        }

        // Since we have prepend items we must reverse the list to keep the proposals
        // in ascending order.
        if (filtered_proposals != null)
            filtered_proposals.reverse ();

        // No match, show a message so the completion widget doesn't disappear.
        else
        {
            var dummy_proposal = new SourceCompletionItem (_("No matching proposal"),
                "", null, null);
            filtered_proposals.prepend (dummy_proposal);
        }

        context.add_proposals ((SourceCompletionProvider) this, filtered_proposals, true);
    }

    /*************************************************************************/
    // Calltip: completion information, but without proposals

    private void init_calltip_window ()
    {
        _calltip_window = new SourceCompletionInfo ();
        _calltip_window_label = new Label (null);
        _calltip_window.add (_calltip_window_label);
    }

    // Show the LaTeX command prototype, with the current argument in bold.
    private void show_calltip_cmd_prototype (string arg_cmd,
        Gee.ArrayList<bool> arguments)
    {
        return_if_fail (_commands.has_key (arg_cmd));

        CompletionCommand command = _commands[arg_cmd];
        int arg_num = get_argument_num (command.args, arguments);
        if (arg_num != -1)
        {
            string info = get_command_info (command, arg_num);
            show_calltip_info (info);
        }
    }

    private void show_calltip_info (string markup)
    {
        if (_calltip_window == null)
            init_calltip_window ();

        _calltip_window_label.set_markup (markup);

        MainWindow window = LatexilaApp.get_instance ().active_window as MainWindow;
        _calltip_window.set_transient_for (window);
        _calltip_window.set_attached_to (window.active_view);

        // Calltip at a fixed place (after the '{' or '[' of the current argument).
        TextIter cursor_pos;
        TextBuffer buffer = window.active_view.buffer;
        buffer.get_iter_at_mark (out cursor_pos, buffer.get_insert ());
        TextIter begin_arg_pos = get_begin_arg_pos (cursor_pos);
        _calltip_window.move_to_iter (window.active_view, begin_arg_pos);

        _calltip_window.show_all ();
    }

    public void hide_calltip_window ()
    {
        if (_calltip_window != null)
            _calltip_window.hide ();
    }

    /*************************************************************************/
    // Activate a proposal: the user has e.g. pressed Enter on a proposal.

    public bool activate_proposal (SourceCompletionProposal proposal, TextIter iter)
    {
        string text = proposal.get_text ();
        if (text == null || text == "")
            return true;

        string? cmd = get_latex_command_at_iter (iter);

        /* Command name */
        if (cmd != null || text.has_prefix ("\\"))
            activate_proposal_command_name (proposal, iter, cmd);

        /* Argument choice */
        else
        {
            ArgumentContext info;
            if (in_latex_command_argument (iter, out info))
            {
                activate_proposal_argument_choice (proposal, iter, info.cmd_name,
                    info.arg_contents);
            }
            else
                warning ("Not in a LaTeX command argument.");
        }

        return true;
    }

    private void activate_proposal_command_name (SourceCompletionProposal proposal,
        TextIter iter, string? cmd)
    {
        string text = proposal.get_text ();

        long index_start = cmd != null ? cmd.length : 0;
        string text_to_insert = text[index_start : text.length];

        /* Insert the text */
        TextBuffer doc = iter.get_buffer ();
        TextMark old_pos_mark = doc.create_mark (null, iter, true);

        doc.begin_user_action ();
        doc.insert (ref iter, text_to_insert, -1);
        doc.end_user_action ();

        /* Cursor position */
        TextIter old_pos_iter;
        doc.get_iter_at_mark (out old_pos_iter, old_pos_mark);
        doc.delete_mark (old_pos_mark);
        TextIter match_end;

        if (old_pos_iter.forward_search ("{",
            TextSearchFlags.TEXT_ONLY | TextSearchFlags.VISIBLE_ONLY,
            null, out match_end, iter))
        {
            doc.place_cursor (match_end);
        }
    }

    private void activate_proposal_argument_choice (SourceCompletionProposal proposal,
        TextIter iter, string arg_cmd, string? arg_contents)
    {
        string text = proposal.get_text ();

        long index_start = arg_contents != null ? arg_contents.length : 0;
        string text_to_insert = text[index_start : text.length];

        TextBuffer doc = iter.get_buffer ();
        doc.begin_user_action ();
        doc.insert (ref iter, text_to_insert, -1);

        // close environment: \begin{env} => \end{env}
        if (arg_cmd == "\\begin")
            close_environment (text, iter);

        // TODO place cursor, go to next argument, if any
        else
        {
        }

        doc.end_user_action ();
    }

    private void close_environment (string env_name, TextIter iter)
    {
        Document doc = iter.get_buffer () as Document;

        // Close the bracket if needed.
        if (iter.get_char () == '}')
            iter.forward_char ();
        else
            doc.insert (ref iter, "}", -1);

        string cur_indent = doc.get_current_indentation (iter);
        string indent = doc.tab.view.get_indentation_style ();

        CompletionChoice? env = _environments[env_name];

        doc.insert (ref iter, @"\n$cur_indent$indent", -1);

        if (env != null && env.insert != null)
            doc.insert (ref iter, env.insert, -1);

        TextMark cursor_pos = doc.create_mark (null, iter, true);

        if (env != null && env.insert_after != null)
            doc.insert (ref iter, env.insert_after, -1);

        doc.insert (ref iter, @"\n$cur_indent\\end{$env_name}", -1);

        // Place the cursor.
        doc.get_iter_at_mark (out iter, cursor_pos);
        doc.delete_mark (cursor_pos);
        doc.place_cursor (iter);
    }

    /*************************************************************************/
    // Parsing

    // Get the position of the beginning of the argument. For example:
    // \blah{foobar}
    // The iter will be between the '{' and the 'f'.
    private TextIter get_begin_arg_pos (TextIter in_arg_pos)
    {
        string text = get_text_line_to_iter (in_arg_pos);
        int index = text.length;
        unichar cur_char;

        while (text.get_prev_char (ref index, out cur_char))
        {
            if ((cur_char == '[' || cur_char == '{')
                && ! Utils.char_is_escaped (text, index))
            {
                break;
            }
        }

        TextIter begin_arg_pos = in_arg_pos;
        begin_arg_pos.set_visible_line_index (index);
        begin_arg_pos.forward_char ();

        return begin_arg_pos;
    }

    private string? get_latex_command_at_iter (TextIter iter)
    {
        string text = get_text_line_to_iter (iter);
        return get_latex_command_at_index (text, text.length);
    }

    // Get the LaTeX command found before 'index'. For example:
    // text: "foobar \usepackage{blah}"
    // text[index]: '{'
    // returns: "\usepackage"
    private string? get_latex_command_at_index (string text, int index)
    {
        return_val_if_fail (index <= text.length, null);

        int cur_index = index;
        unichar cur_char;
        while (text.get_prev_char (ref cur_index, out cur_char))
        {
            if (cur_char == '\\')
            {
                // If the backslash is escaped, it's not a LaTeX command.
                if (Utils.char_is_escaped (text, cur_index))
                    break;

                return text[cur_index : index];
            }

            // A LaTeX command contains only normal letters and '*'.
            if (! cur_char.isalpha () && cur_char != '*')
                break;
        }

        return null;
    }

    private bool in_latex_command_argument (TextIter iter, out ArgumentContext info)
    {
        info = ArgumentContext ();
        info.cmd_name = null;
        info.arg_contents = null;
        info.args_types = new Gee.ArrayList<bool> ();

        string text = get_text_line_to_iter (iter);
        int last_index = text.length;
        int cur_index = last_index;

        /* Fetch the argument's contents */
        while (true)
        {
            unichar cur_char;
            if (! text.get_prev_char (ref cur_index, out cur_char))
                return false;

            // End of the argument's contents.
            bool opening_bracket = cur_char == '{' || cur_char == '[';
            if (opening_bracket && ! Utils.char_is_escaped (text, cur_index))
            {
                info.args_types.insert (0, cur_char == '[');
                info.arg_contents = text[cur_index + 1 : last_index];
                break;
            }
        }

        /* Traverse the previous arguments, and find the command name */
        bool in_prev_arg = false;
        unichar prev_arg_opening_bracket = '{';

        while (true)
        {
            unichar cur_char;
            if (! text.get_prev_char (ref cur_index, out cur_char))
                return false;

            // In the contents of a previous argument.
            if (in_prev_arg)
            {
                if (cur_char == prev_arg_opening_bracket)
                    in_prev_arg = Utils.char_is_escaped (text, cur_index);
            }

            // Maybe the end of a previous argument.
            else if (cur_char == '}' || cur_char == ']')
            {
                if (Utils.char_is_escaped (text, cur_index))
                    return false;

                in_prev_arg = true;
                prev_arg_opening_bracket = cur_char == '}' ? '{' : '[';

                info.args_types.insert (0, cur_char == ']');
            }

            // Maybe the last character of the command name.
            else if (cur_char.isalpha () || cur_char == '*')
            {
                info.cmd_name = get_latex_command_at_index (text, cur_index + 1);
                return info.cmd_name != null;
            }

            // Spaces are allowed between arguments.
            else if (! cur_char.isspace ())
                return false;
        }
    }

    /*************************************************************************/
    // Various utilities functions

    private bool is_user_request (SourceCompletionContext context)
    {
        return context.activation == SourceCompletionActivation.USER_REQUESTED;
    }

    // static because of bug #627736
    // (and also because it's more efficient)
    private static int compare_proposals (SourceCompletionItem a, SourceCompletionItem b)
    {
        return a.text.collate (b.text);
    }

    // Get the text between the start of the line and the iter.
    private string get_text_line_to_iter (TextIter iter)
    {
        int line = iter.get_line ();
        TextBuffer doc = iter.get_buffer ();

        TextIter iter_start;
        doc.get_iter_at_line (out iter_start, line);

        return doc.get_text (iter_start, iter, false);
    }

    // Get the command information: the prototype, and the package required if a package
    // is required. In the prototype, the current argument ('cur_arg') is in bold.
    // By default, no argument is in bold.
    private string get_command_info (CompletionCommand cmd, int cur_arg = -1)
    {
        string info = cmd.name;
        int arg_num = 1;
        foreach (CompletionArgument arg in cmd.args)
        {
            if (arg_num == cur_arg)
                info += "<b>";

            if (arg.optional)
                info += "[" + arg.label + "]";
            else
                info += "{" + arg.label + "}";

            if (arg_num == cur_arg)
                info += "</b>";

            arg_num++;
        }

        if (cmd.package != null)
            info += "\nPackage: " + cmd.package;

        return info;
    }

    /* Get argument number (begins at 1).
     * 'all_args': all the possible arguments of a LaTeX command.
     * 'args': the encounter arguments, beginning just after the command name.
     * Returns -1 if it doesn't match.
     */
    private int get_argument_num (CompletionArgument[] all_args,
        Gee.ArrayList<bool> args)
    {
        if (all_args.length < args.size)
            return -1;

        int num = 0;
        foreach (bool arg in args)
        {
            while (true)
            {
                if (all_args.length <= num)
                    return -1;

                if (all_args[num].optional == arg)
                    break;

                // missing non-optional argument
                else if (! all_args[num].optional)
                    return -1;

                num++;
            }
            num++;
        }

        // first = 1
        return num;
    }

    private string get_command_text_to_insert (CompletionCommand cmd)
    {
        string text_to_insert = cmd.name;
        foreach (CompletionArgument arg in cmd.args)
        {
            if (! arg.optional)
                text_to_insert += "{}";
        }
        return text_to_insert;
    }

    /*
    private void print_command_args (CompletionCommandArgs cmd_args)
    {
        stdout.printf ("\n=== COMMAND ARGS ===\n");
        foreach (unowned List<SourceCompletionItem> items in cmd_args.optional_args)
        {
            stdout.printf ("= optional arg =\n");
            foreach (SourceCompletionItem item in items)
                stdout.printf ("%s\n", item.label);
        }

        foreach (unowned List<SourceCompletionItem> items in cmd_args.args)
        {
            stdout.printf ("= normal arg =\n");
            foreach (SourceCompletionItem item in items)
                stdout.printf ("%s\n", item.label);
        }
    }
    */

    /*************************************************************************/
    // Load the data contained in the XML file

    private void load_data ()
    {
        _commands = new Gee.HashMap<string, CompletionCommand?> ();
        _environments = new Gee.HashMap<string, CompletionChoice?> ();

        File file = File.new_for_path (
            Path.build_filename (Config.DATA_DIR, "completion.xml"));

        string? contents = Utils.load_file (file);
        if (contents == null)
            return;

        try
        {
            MarkupParser parser = { parser_start, parser_end, parser_text, null, null };
            MarkupParseContext context = new MarkupParseContext (parser, 0, this, null);
            context.parse (contents, -1);
            _proposals.sort ((CompareFunc) compare_proposals);
        }
        catch (GLib.Error e)
        {
            warning ("Impossible to load completion data: %s", e.message);
        }
    }

    private void parser_start (MarkupParseContext context, string name,
        string[] attr_names, string[] attr_values) throws MarkupError
    {
        switch (name)
        {
            case "commands":
                break;

            case "command":
                parser_add_command (attr_names, attr_values);
                break;

            case "argument":
                parser_add_argument (attr_names, attr_values);
                break;

            case "choice":
                parser_add_choice (attr_names, attr_values);
                break;

            // insert and insert_after don't contain any attributes, but
            // contain content, which is parsed in parser_text()
            case "insert":
            case "insert_after":
                break;

            // not yet supported
            case "placeholder":
            case "component":
                break;

            default:
                throw new MarkupError.UNKNOWN_ELEMENT (
                    "unknown element \"" + name + "\"");
        }
    }

    private void parser_add_command (string[] attr_names, string[] attr_values)
        throws MarkupError
    {
        _current_command = CompletionCommand ();
        for (int attr_num = 0 ; attr_num < attr_names.length ; attr_num++)
        {
            switch (attr_names[attr_num])
            {
                case "name":
                    _current_command.name = "\\" + attr_values[attr_num];
                    break;

                case "package":
                    _current_command.package = attr_values[attr_num];
                    break;

                // not yet supported
                case "environment":
                    break;

                default:
                    throw new MarkupError.UNKNOWN_ATTRIBUTE (
                        "unknown command attribute \"" + attr_names[attr_num] + "\"");
            }
        }
    }

    private void parser_add_argument (string[] attr_names, string[] attr_values)
        throws MarkupError
    {
        _current_arg = CompletionArgument ();
        _current_arg.optional = false;

        for (int attr_num = 0 ; attr_num < attr_names.length ; attr_num++)
        {
            switch (attr_names[attr_num])
            {
                case "label":
                    _current_arg.label = attr_values[attr_num];
                    break;

                case "type":
                    _current_arg.optional = attr_values[attr_num] == "optional";
                    break;

                default:
                    throw new MarkupError.UNKNOWN_ATTRIBUTE (
                        "unknown argument attribute \"" + attr_names[attr_num] + "\"");
            }
        }
    }

    private void parser_add_choice (string[] attr_names, string[] attr_values)
        throws MarkupError
    {
        _current_choice = CompletionChoice ();

        for (int attr_num = 0 ; attr_num < attr_names.length ; attr_num++)
        {
            switch (attr_names[attr_num])
            {
                case "name":
                    _current_choice.name = attr_values[attr_num];
                    break;

                case "package":
                    _current_choice.package = attr_values[attr_num];
                    break;

                default:
                    throw new MarkupError.UNKNOWN_ATTRIBUTE (
                        "unknown choice attribute \"" + attr_names[attr_num] + "\"");
            }
        }
    }

    private void parser_end (MarkupParseContext context, string name) throws MarkupError
    {
        switch (name)
        {
            case "command":
                Gdk.Pixbuf pixbuf = _current_command.package != null
                    ? _icon_package_required : _icon_cmd;

                var item = new SourceCompletionItem (_current_command.name,
                    get_command_text_to_insert (_current_command),
                    pixbuf,
                    get_command_info (_current_command));

                _proposals.prepend (item);

                // We don't need to store commands that have no arguments,
                // they are only in _proposals, it's sufficient.
                if (0 < _current_command.args.length)
                    _commands[_current_command.name] = _current_command;
                break;

            case "argument":
                _current_command.args += _current_arg;
                break;

            case "choice":
                _current_arg.choices += _current_choice;
                if (_current_choice.insert != null
                    || _current_choice.insert_after != null)
                    _environments[_current_choice.name] = _current_choice;
                break;
        }
    }

    private void parser_text (MarkupParseContext context, string text, size_t text_len)
        throws MarkupError
    {
        switch (context.get_element ())
        {
            case "insert":
                _current_choice.insert = text;
                break;

            case "insert_after":
                _current_choice.insert_after = text;
                break;
        }
    }    
}
