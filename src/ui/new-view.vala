/*
 * new-view.vala
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

    public class NewView : Gtk.ScrolledWindow, Updateable, Switchable {
        protected ModeType mode = ModeType.FLOW;
        private Gtk.Viewport container;
        protected Gtk.FlowBox posts_box;
        protected Gtk.ListBox posts_list;
        
        public NewView () {
            Object (name: "New");
            load_view ();
            var app = GLib.Application.get_default () as Application;
            app.controller.items_updated.connect (update);
            app.controller.item_updated.connect (item_updated);
            show_all ();
        }
        
        protected void load_view () {
            container = new Gtk.Viewport (null, null);
            add (container);
            posts_box = new Gtk.FlowBox ();
            posts_box.valign = Gtk.Align.START;
            posts_box.child_activated.connect (show_article_flow);
            container.add (posts_box);
        }
        
        public virtual void update () {
            var app = GLib.Application.get_default () as Application;
            var posts = app.controller.post_sorted_by_date (true);
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
        
        public void switch_mode () {
            if (mode == ModeType.FLOW) {
                mode = ModeType.LIST;
                container.remove (posts_box);
                posts_box = null;
                posts_list = new Gtk.ListBox ();
                posts_list.row_activated.connect (show_article_list);
                container.add (posts_list);
            } else {
                mode = ModeType.FLOW;
                container.remove (posts_list);
                posts_list = null;
                posts_box = new Gtk.FlowBox ();
                posts_box.child_activated.connect (show_article_flow);
                container.add (posts_box);
            }
            update ();
        }
        
         private void show_article_flow (Gtk.FlowBoxChild child) {
            News.Post post = ((ArticleBox)child.get_child()).post;
            show_article (post);
        }
        
        private void show_article_list (Gtk.ListBoxRow row) {
            News.Post post = ((ArticleList)row.get_child()).post;
            show_article (post);
        }
        
        private void show_article (Post post) {
            var toplevel = get_toplevel ();
            if (toplevel is Window) {
                var window = toplevel as Window;
                window.show_article (post);
            }
        }
        
                
        protected void item_updated (Post post, Controller.Updated updated) {
            if (updated == Controller.Updated.MARK_AS_READ) {
                // Do this a second later, so the transition is seamless and nicer
                Timeout.add(1000, () => {
                    update ();
                    return false;
                });
            }
            
        }
    }

}
