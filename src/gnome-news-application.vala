/*
 * gnome-news-application.vala
 * This file is part of gnome news
 *
 * Copyright (C) 2017 - Günther Wutz
 *
 * gnome news is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * gnome news is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with gnome news. If not, see <http://www.gnu.org/licenses/>.
 */

namespace GnomeNews{
    public class Application : Gtk.Application {
        private Controller controller ;
        private TrackerRss tracker_rss ;
        private Tracker tracker ;

        public Application () {
            Object (
                application_id: "org.gnome.News",
                flags : ApplicationFlags.FLAGS_NONE
                ) ;

            controller = new Controller () ;
            try {
                tracker_rss = Bus.get_proxy_sync<TrackerRss>(BusType.SESSION, "org.freedesktop.Tracker1.Miner.RSS",
                                                             "/org/freedesktop/Tracker1/Miner/RSS") ;
                tracker = Bus.get_proxy_sync<Tracker>(BusType.SESSION, "org.freedesktop.Tracker1",
                                                      "/org/freedesktop/Tracker1/Resources") ;
                tracker.graph_updated.connect (() => {
                    print ("Graph Updated\n") ;
                }) ;
                tracker_rss.Start () ;
            } catch ( IOError e ){
                error (e.message) ;
            }
        }

        public override void activate() {
            var window = new GnomeNews.Window () ;
            this.add_window (window) ;
            window.show_all () ;
        }

    }
}
