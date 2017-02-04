/*
 * application.vala
 * This file is part of news
 *
 * Copyright (C) 2017 - Günther Wutz
 *
 * news is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * news is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with news. If not, see <http://www.gnu.org/licenses/>.
 */

namespace News.UI {

    public class Application : Gtk.Application {
        public static string CACHE = Environment.get_user_cache_dir () + "/News/";
        public Controller controller;
        private TrackerRss tracker_rss;
        private Tracker tracker;

        public Application () {
            Object (application_id: "org.gnome.News");

            controller = new Controller ();
            
            if (!FileUtils.test (CACHE, FileTest.EXISTS)) {
                try {
                    File.new_for_path (CACHE).make_directory ();
                } catch (Error e) {
                    warning (e.message);
                }
            }
            var delete_channel_action = new SimpleAction("delete_channel", VariantType.INT32);
            add_action(delete_channel_action);
            
            try {
                tracker_rss = Bus.get_proxy_sync<TrackerRss>(BusType.SESSION, "org.freedesktop.Tracker1.Miner.RSS",
                                                             "/org/freedesktop/Tracker1/Miner/RSS");
                tracker = Bus.get_proxy_sync<Tracker>(BusType.SESSION, "org.freedesktop.Tracker1",
                                                      "/org/freedesktop/Tracker1/Resources");
                tracker.graph_updated.connect ((classname, deleted, inserted) => {
                    // http://www.tracker-project.org/temp/mfo#FeedMessage
                    
                    if (classname == "http://www.tracker-project.org/temp/mfo#FeedMessage") {
                        controller.items_updated ();
                    }
                });
                tracker_rss.Start ();
            } catch ( IOError e ){
                error (e.message);
            }
        }
        
        private void setup_css_theming () {
            var screen = Gdk.Screen.get_default ();
            var cssprovider = new Gtk.CssProvider ();
            cssprovider.load_from_resource ("/org/gnome/News/theme/Adwaita.css");
            Gtk.StyleContext.add_provider_for_screen (screen, cssprovider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
        }

        protected override void startup () {            
            base.startup ();
            
            var builder = new Gtk.Builder.from_resource ("/org/gnome/News/appmenu.ui");
            var menu = (MenuModel) builder.get_object ("appmenu");
            this.set_app_menu (menu);
            
            var quit_action = new SimpleAction ("app.quit", null);
		    quit_action.activate.connect (quit_cb);
		    this.add_action (quit_action);
        }
        
        void quit_cb (SimpleAction action, Variant? param) {
            print ("Quit\n");
        }

        protected override void activate () {
            setup_css_theming ();
            var window = new News.UI.Window (this);
            this.add_window (window);

            window.show ();
        }

    }
}
