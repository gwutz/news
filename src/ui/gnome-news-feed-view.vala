/*
 * gnome-news-feed-view.vala
 * This file is part of gnome-news
 *
 * Copyright (C) 2017 - Günther Wutz
 *
 * gnome-news is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * gnome-news is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with gnome-news. If not, see <http://www.gnu.org/licenses/>.
 */

namespace News.UI {
    public class FeedView : Gtk.Paned, Updateable {
        private Gtk.ListBox feeds_list;
        private Gtk.FlowBox posts_box;
        
        public FeedView () {
            Object (orientation: Gtk.Orientation.HORIZONTAL, name: "Feeds");
            load_view ();
            show_all ();
        }
        
        private void load_view () {
            // left pane side
            var feeds_scroll = new Gtk.ScrolledWindow (null, null);
            feeds_scroll.width_request = 200;
            feeds_list   = new Gtk.ListBox ();
            feeds_list.get_style_context ().add_class ("sidebar");
            feeds_list.row_activated.connect (feed_selected);
            feeds_scroll.add (feeds_list);
            add1 (feeds_scroll);
            
            // right pane side
            var posts_scroll = new Gtk.ScrolledWindow (null, null);
            posts_box        = new Gtk.FlowBox (); // FIXME: use generic view here
            posts_box.set_min_children_per_line (2);
            posts_box.child_activated.connect (show_article);
            posts_scroll.add (posts_box);
            add2 (posts_scroll);
        }
        
        public void update () {
            var old_list = feeds_list.get_children ();
            foreach(Gtk.Widget w in old_list) {
                w.destroy ();
            }
        
            var app = GLib.Application.get_default () as Application;
            var feeds = app.controller.get_feed_list ();
            foreach (Feed feed in feeds) {
                var row = new FeedRow (feed);
                feeds_list.add (row);
                if (feed == feeds.first ().data) {
                    feeds_list.select_row (row);
                }
            }
            
            var posts = app.controller.post_sorted_by_channel (feeds.first ().data.url);
            populate_box (posts);
        }
        
        private void populate_box (List<Post> posts) {
            var old_boxes = posts_box.get_children ();
            foreach (Gtk.Widget w in old_boxes) {
                w.destroy ();
            }
            
            foreach (Post post in posts) {
                posts_box.add (new ArticleBox (post));
            }
        }
        
        private void feed_selected (Gtk.ListBoxRow row) {
            var feedrow = row as FeedRow;
            var app = GLib.Application.get_default () as Application;
            
            var posts = app.controller.post_sorted_by_channel (feedrow.feed.url);
            populate_box (posts);
        }
        
        private void show_article (Gtk.FlowBoxChild child) {
            var toplevel = child.get_toplevel ();
            if (toplevel is Window) {
                var window = toplevel as Window;
                News.Post post = ((ArticleBox)child.get_child()).post;
                window.show_article (post);
            }
        }
    }
    
    class FeedRow : Gtk.ListBoxRow {
        public Feed feed { get; set; }
        
        public FeedRow (Feed feed) {
            this.feed = feed;
            var label = new Gtk.Label (feed.title);
            label.margin = 10;
            label.xalign = 0.0f;
            add (label);
            set_activatable (true);
            show_all ();
        }
    }
}
