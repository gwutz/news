/*
 * star-view.vala
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

    public class StarView : NewView {
    
        public StarView () {
            Object (name: "Starred");
            load_view ();
            var app = GLib.Application.get_default () as Application;
            app.controller.items_updated.connect (update);
            app.controller.item_updated.connect (item_updated);
            show_all ();
        }
    
        public override void update () {
            var app = GLib.Application.get_default () as Application;
            var posts = app.controller.post_sorted_by_date (false, true);
            if (mode == ModeType.FLOW) {
                var old_boxes = posts_box.get_children ();
                foreach (Gtk.Widget w in old_boxes) {
                    w.destroy ();
                }
                
                foreach (Post post in posts) {
                    posts_box.add (new ArticleBox (post));
                }
            } else {
                var old_rowes = posts_list.get_children ();
                foreach (Gtk.Widget w in old_rowes) {
                    w.destroy ();
                }
                
                foreach (Post post in posts) {
                    posts_list.add (new ArticleList (post));
                }
            }
            show_all ();
        }
    }

}
