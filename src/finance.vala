/*
 * This file is part of LaTeXila.
 *
 * Copyright © 2015 - Sébastien Wilmet
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

namespace Finance
{
    public void show_dialog (MainWindow window, bool startup)
    {
        if (startup && ! should_show_dialog_on_startup ())
            return;

        Dialog dialog = new Dialog.with_buttons ("LaTeXila Finance",
            window,
            DialogFlags.DESTROY_WITH_PARENT,
            "_Close", ResponseType.CLOSE,
            "_Remind me later", ResponseType.YES,
            "_More information", ResponseType.ACCEPT,
            null);

        dialog.set_resizable (false);
        dialog.set_default_response (ResponseType.ACCEPT);

        Widget close_button = dialog.get_widget_for_response (ResponseType.CLOSE);
        close_button.tooltip_text = "Do not show again this information.";

        Widget remind_button = dialog.get_widget_for_response (ResponseType.YES);
        remind_button.tooltip_text = "Show again this information in one month.";

        unowned Box content_area = dialog.get_content_area ();
        content_area.set_spacing (6);
        content_area.margin = 12;
        content_area.margin_top = 6;

        Image image = new Image.from_file (Config.DATA_DIR + "/images/app/logo.png");
        content_area.add (image);

        Label label = new Label (null);
        label.set_markup ("<big>Did you know...</big>");
        content_area.add (label);

        label = new Label ("...that you can support LaTeXila financially?");
        content_area.add (label);

        label = new Label (null);
        label.set_markup ("LaTeXila is a free/<i>libre</i> LaTeX editor and comes" +
            " free of charge. But if you appreciate this software, you are encouraged" +
            " to make a donation to help its future development.");
        label.max_width_chars = 60;
        label.set_line_wrap (true);
        label.xalign = 0;
        content_area.add (label);

        label = new Label ("You can see again this information at any time by going to the Help menu.");
        label.max_width_chars = 60;
        label.set_line_wrap (true);
        label.xalign = 0;
        content_area.add (label);

        label = new Label ("Thanks!");
        label.xalign = 0;
        content_area.add (label);

        content_area.show_all ();

        while (true)
        {
            int response = dialog.run ();

            if (response == ResponseType.ACCEPT)
            {
                open_donate_page (window);
                continue;
            }

            GLib.Settings settings =
                new GLib.Settings ("org.gnome.latexila.state.dialogs.finance");

            settings.set_boolean ("remind-later", response == ResponseType.YES);
            break;
        }

        dialog.destroy ();
        save_date ();
    }

    private bool should_show_dialog_on_startup ()
    {
        GLib.Settings settings =
            new GLib.Settings ("org.gnome.latexila.state.dialogs.finance");

        string date = settings.get_string ("last-shown-date");

        if (date == "")
            return true;

        if (settings.get_boolean ("remind-later"))
        {
            string[] ymd = date.split ("-");
            if (ymd.length != 3)
                return false;

            int year = int.parse (ymd[0]);
            int month = int.parse (ymd[1]);
            int day = int.parse (ymd[2]);

            DateTime last_time = new DateTime.utc (year, month, day, 0, 0, 0);
            DateTime cur_time = new DateTime.now_utc ();

            // Remind one month later.
            DateTime time_limit = last_time.add_months (1);

            if (time_limit.compare (cur_time) <= 0)
                return true;
        }

        return false;
    }

    private void save_date ()
    {
        GLib.Settings settings =
            new GLib.Settings ("org.gnome.latexila.state.dialogs.finance");

        DateTime time = new DateTime.now_utc ();
        string date = "%d-%d-%d".printf (time.get_year (), time.get_month (),
            time.get_day_of_month ());

        settings.set_string ("last-shown-date", date);
    }

    private void open_donate_page (MainWindow window)
    {
        try
        {
            string uri = "https://wiki.gnome.org/Apps/LaTeXila/donate";
            show_uri (window.get_screen (), uri, Gdk.CURRENT_TIME);
        }
        catch (Error e)
        {
            warning ("Impossible to open the donate page: %s", e.message);
        }
    }
}
