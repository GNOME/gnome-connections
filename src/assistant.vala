/* assistant.vala
 *
 * Copyright (C) Red Hat, Inc
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Author: Felipe Borges <felipeborges@gnome.org>
 *
 */

namespace Connections {
    [GtkTemplate (ui = "/org/gnome/Connections/ui/assistant.ui")]
    private class Assistant : Gtk.Popover {
        [GtkChild]
        private unowned Gtk.Entry url_entry;
        [GtkChild]
        private unowned Gtk.Button create_button; 
        [GtkChild]
        private unowned Gtk.Label learn_more_label;

        construct {
            // Translators: This is a link which takes users to a documentation page in yelp
            var learn_more_string = _("Learn more.");
            learn_more_label.set_markup ("<a href=\'help:gnome-connections/connect\'>%s</a>".printf (learn_more_string));
        }

        [GtkCallback]
        private void on_url_entry_changed () {
            if (url_entry.text == "") {
                create_button.sensitive = false;

                return;
            }

            var uri = Xml.URI.parse (url_entry.text);
            if (uri == null || uri.scheme == null || uri.path != null) {
                create_button.sensitive = false;

                return;
            }

            var port_str = url_entry.text.substring (url_entry.text.last_index_of (":",
                                                                                   int.max (uri.scheme.length + 3,
                                                                                            url_entry.text.index_of ("@"))
                                                                                  )).substring (1);

            if (uri.port > 65535 || port_str != "" && uri.port == 0) {
                create_button.sensitive = false;

                return;
            }

            if (uri.scheme == "vnc" || uri.scheme == "rdp") {
                create_button.sensitive = true;
            }
        }

        [GtkCallback]
        private void on_create_connection_button_clicked () {
            Application.application.add_connection (url_entry.get_text ());
            url_entry.set_text ("");

            popdown ();
        }

        [GtkCallback]
        private void on_url_entry_activated () {
            if (create_button.sensitive)
                create_button.clicked ();
        }
    }
}
