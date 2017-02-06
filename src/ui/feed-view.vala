/*
 * feed-view.vala
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
    public class FeedView : Gtk.Paned, Updateable, Switchable {
        private ModeType mode = ModeType.FLOW;
        private Gtk.ScrolledWindow posts_scroll;
        private Gtk.ListBox feeds_list;
        private Gtk.FlowBox posts_box;
        private Gtk.ListBox posts_list;
        private Gtk.Widget selected_article = null;
        private bool should_update = true;
        
        public FeedView () {
            Object (orientation: Gtk.Orientation.HORIZONTAL, name: "Feeds");
            load_view ();
            show_all ();
        }
        
        private void load_view () {
            var app = GLib.Application.get_default () as Application;
            app.controller.items_updated.connect (update);

            // left pane side
            var feeds_scroll = new Gtk.ScrolledWindow (null, null);
            feeds_scroll.width_request = 200;
            feeds_list   = new Gtk.ListBox ();
            feeds_list.get_style_context ().add_class ("sidebar");
            feeds_list.row_activated.connect (feed_selected);
            feeds_list.button_release_event.connect (list_box_button_release);
            feeds_scroll.add (feeds_list);
            add1 (feeds_scroll);
            
            // right pane side
            posts_scroll = new Gtk.ScrolledWindow (null, null);
            posts_box        = new Gtk.FlowBox ();
            posts_box.set_min_children_per_line (2);
            posts_scroll.vexpand = false;
            posts_box.valign = Gtk.Align.START;
            posts_box.child_activated.connect (show_article_box);
            posts_scroll.add (posts_box);
            add2 (posts_scroll);

            posts_list = new Gtk.ListBox ();
            posts_list.row_activated.connect (show_article_list);
            
            var delete_action = app.lookup_action("delete_channel") as SimpleAction;
            delete_action.activate.connect (delete_channel);
            var mark_all_as_read_action = app.lookup_action("mark_all_as_read") as SimpleAction;
            mark_all_as_read_action.activate.connect (mark_all_as_read);
        }
        
        public void update () {
            // only update the articlebox and leave view untouched
            if (!should_update && selected_article != null) {
                debug ("update only child");
                should_update = true;
                News.Post post;
                if (mode == ModeType.FLOW) {
                    post = (selected_article as ArticleBox).post;
                    post.read = true;
                    (selected_article as ArticleBox).set_post_data (post);
                    posts_box.unselect_child (posts_box.get_selected_children ().first ().data);
                } else {
                    post = (selected_article as ArticleList).post;
                    post.read = true;
                    (selected_article as ArticleList).set_post_data (post);
                    posts_list.unselect_row(posts_list.get_selected_row());
                }
                selected_article = null;
                return;
            }
            var old_list = feeds_list.get_children ();
            foreach(Gtk.Widget w in old_list) {
                w.destroy ();
            }
            var app = GLib.Application.get_default () as Application;
            var feeds = app.controller.get_feed_list ();
            debug ("start update");
            foreach (Feed feed in feeds) {
                debug ("add Feed %s", feed.title);
                var row = new FeedRow (feed);
                feeds_list.add (row);
                if (feed == feeds.first ().data) {
                    feeds_list.select_row (row);
                }
            }
            
            if (feeds.length () != 0) {
                var posts = app.controller.post_sorted_by_channel (feeds.first ().data.url);
                populate_posts (posts);            
            }
            show_all ();
        }
        
        public void switch_mode () {
            if (mode == ModeType.FLOW) {
                mode = ModeType.LIST;
                posts_scroll.remove (posts_box);
                posts_box.@foreach ((w) => { w.destroy (); });
                posts_scroll.add (posts_list);
            } else {
                mode = ModeType.FLOW;
                posts_scroll.remove (posts_list);
                posts_list.@foreach ((w) => { w.destroy (); });
                posts_scroll.add (posts_box);
            }

            update ();
        }
        
        private void populate_posts (List<Post> posts) {
            if (mode == ModeType.FLOW) {
                var old_boxes = posts_box.get_children ();
                foreach (Gtk.Widget w in old_boxes) {
                    w.destroy ();
                }
                
                foreach (Post post in posts) {
                    posts_box.add (new ArticleBox (post));
                }
            } else {
                var old_rows = posts_list.get_children ();
                foreach (Gtk.Widget w in old_rows) {
                    w.destroy ();
                }
                
                foreach (Post post in posts) {
                    posts_list.add (new ArticleList (post));
                }
            }
        }
        
        private void feed_selected (Gtk.ListBoxRow row) {
            var feedrow = row as FeedRow;
            var app = GLib.Application.get_default () as Application;
            
            var posts = app.controller.post_sorted_by_channel (feedrow.feed.url);
            populate_posts (posts);
        }
        
        private bool list_box_button_release (Gdk.EventButton event) {
            var selected_row = feeds_list.get_row_at_y ((int)event.y);
            var button = event.button;
            if (button == Gdk.BUTTON_PRIMARY) {
                return Gdk.EVENT_PROPAGATE;
            }
            else if (button == Gdk.BUTTON_SECONDARY) {
                int index = selected_row.get_index ();
                var menu = new Menu ();
                menu.append ("Remove Channel", "app.delete_channel(%d)".printf (index));
                menu.append ("Mark all as read", "app.mark_all_as_read(%d)".printf (index));
                var popover = new Gtk.Popover.from_model (selected_row, menu);
                popover.set_position (Gtk.PositionType.BOTTOM);
                popover.show ();
            }
            return Gdk.EVENT_STOP;
        }

        private void show_article_list (Gtk.ListBoxRow row) {
            selected_article = row.get_child () as ArticleList;
            show_article ();
        }

        private void show_article_box (Gtk.FlowBoxChild child) {
            selected_article = child.get_child () as ArticleBox;
            show_article ();
        }
        
        private void show_article () {
            should_update = false;
        
            var toplevel = get_toplevel ();
            if (toplevel is Window) {
                var window = toplevel as Window;
                News.Post post;
                if (mode == ModeType.FLOW)
                    post = (selected_article as ArticleBox).post;
                else
                    post = (selected_article as ArticleList).post;
                window.show_article (post);
            }
        }
        
        private void delete_channel (Variant? parameter) {
            int index = (int)parameter.get_int32 ();
            var row = feeds_list.get_children ().nth_data (index) as FeedRow;
            if (row != null) {
                var app = GLib.Application.get_default () as Application;
                app.controller.remove_channel (row.feed.url);
            }
        }
        
        private void mark_all_as_read (Variant? parameter) {
            var outer = posts_box.get_children ();
            var app = GLib.Application.get_default () as Application;
            foreach (Gtk.Widget child in outer) {
                var flowchild = child as Gtk.FlowBoxChild;
                var box = flowchild.get_child () as ArticleBox;
                
                if (box != null) {
                    app.controller.mark_post_as_read (box.post);
                }
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
