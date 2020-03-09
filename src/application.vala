/* application.vala
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
    public class Application : Gtk.Application {
        public static Application application;

        public ListStore model;

        private List<Connections.Window> windows;
        public unowned Window main_window {
            get { return (windows.length () > 0) ? windows.data : null; }
        }

        construct {
            windows = new List<Connections.Window> ();
            model = new GLib.ListStore (typeof (Connections.Machine));
        }

        public Application () {
            application = this;

            application_id = "org.gnome.Connections";

            var action = new GLib.SimpleAction ("help", null);
            action.activate.connect (show_help);
            add_action (action);

            action = new GLib.SimpleAction ("about", null);
            action.activate.connect (show_about_dialog);
            add_action (action);
        }

        private void show_help () {
            try {
                Gtk.show_uri (main_window.get_screen (),
                              "help:connections",
                              Gtk.get_current_event_time ());
            } catch (GLib.Error error) {
                warning ("Failed to display help: %s", error.message);
            }
        }

        private void show_about_dialog () {
            string[] authors = {
                "Felipe Borges <felipeborges@gnome.org>"
            };
            string[] artists = {
                "Jakub Steiner <jsteiner@redhat.com>"
            };

            Gtk.show_about_dialog (main_window,
                                   "artists", artists,
                                   "authors", authors,
                                   "translator-credits", _("translator-credits"),
                                   "comments", _("A remote connection manager for the GNOME desktop"),
                                   "copyright", "\xc2\xa9 2020 Red Hat, Inc.",
                                   "license-type", Gtk.License.LGPL_2_1,
                                   "program-name", _("Connections"),
                                   "wrap-license", true);
        }

        public override void activate () {
            base.activate ();

            if (main_window != null) {
                return;
            }

            add_new_window ();

            load_machines ();
        }

        public Window add_new_window () {
            var window = new Connections.Window (this);

            windows.append (window);
            window.present ();

            return window;
        }

        public void add_machine (Machine machine) {
            model.insert (0, machine);
            machine.save ();
        }

        public void remove_machine (Machine machine) {
            for (int i = 0; i < model.get_n_items (); i++) {
                if ((model.get_item (i) as Machine) == machine) {
                    model.remove (i);

                    break;
                }
            }
        }

        public void load_machines () {
            var db = new Database ();
            foreach (var machine in db.get_machines ()) {
                model.append (machine);
            }
        }

        public void open_machine (Machine machine) {
            main_window.open_machine (machine);
        }
    }
}
